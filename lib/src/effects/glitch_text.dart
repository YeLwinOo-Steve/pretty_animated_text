import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pretty_animated_text/src/animated_text_base.dart';
import 'package:pretty_animated_text/src/animated_text_controller.dart';
import 'package:pretty_animated_text/src/animation_config.dart';
import 'package:pretty_animated_text/src/enums/animation_type.dart';

/// Visual customization for [GlitchText].
///
/// [shadows] `true` tints the sheared slices with [color1]/[color2] and adds an
/// RGB-split shadow fringe (chromatic); `false` gives a clean monochrome tear.
class GlitchStyle {
  /// Tint + RGB-split shadow fringe when `true`; monochrome tear when `false`.
  final bool shadows;

  /// Primary split color. Defaults to neon pink.
  final Color color1;

  /// Secondary split color. Defaults to neon cyan.
  final Color color2;

  /// Dark shadow accent on the sheared slices. Defaults to near-black.
  final Color shadowColor;

  const GlitchStyle({
    this.shadows = true,
    this.color1 = const Color(0xFFFF2E88),
    this.color2 = const Color(0xFF23D7F5),
    this.shadowColor = const Color(0xFF0D0A1A),
  });

  GlitchStyle copyWith({
    bool? shadows,
    Color? color1,
    Color? color2,
    Color? shadowColor,
  }) {
    return GlitchStyle(
      shadows: shadows ?? this.shadows,
      color1: color1 ?? this.color1,
      color2: color2 ?? this.color2,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }
}

// Horizontal band boundaries as fractions of glyph height.
const double _kTopCut = 0.35;
const double _kBottomCut = 0.65;

// Per-slice horizontal shear in logical pixels: [top, middle, bottom]. Any
// slice can tear (including middle-only); an active segment cycles through these.
const List<List<double>> _kShearPatterns = [
  [-5.0, 0.0, 4.0],
  [4.0, -6.0, 0.0],
  [0.0, 5.0, -3.0],
  [0.0, -4.0, 0.0],
  [3.0, 0.0, -5.0],
  [-3.0, 4.0, 5.0],
];

// RGB-split shadow offsets for a sheared slice's chromatic fringe.
const List<List<Offset>> _kFringePatterns = [
  [Offset(2.5, 1.5), Offset(-2.5, -1.5)],
  [Offset(-3.0, 0.0), Offset(3.0, 1.5)],
  [Offset(1.5, -2.0), Offset(-1.5, 2.0)],
];

/// Text that glitches by tearing glyphs into horizontal slices that shear
/// sideways, while every character stays visible and readable.
///
/// A random, rotating subset glitches: at most one word at a time in word mode,
/// or a group of 2-3 letters in letter mode. The order covers every segment
/// once per forward pass and reshuffles on each pass. Loops when
/// [AnimationConfig.repeat] is enabled.
class GlitchText extends StatefulWidget {
  /// The text to animate.
  final String text;

  /// The style to apply to the text.
  final TextStyle? style;

  /// Auto animate when widget is first created
  final bool autoPlay;

  /// The text alignment.
  final TextAlign textAlign;

  /// The animation configuration.
  final AnimationConfig config;

  /// Glitch appearance (chromatic toggle + colors).
  final GlitchStyle glitchStyle;

  /// Called when the controller is created.
  final void Function(AnimatedTextController)? onControllerCreated;

  const GlitchText({
    super.key,
    required this.text,
    this.style,
    this.autoPlay = true,
    this.textAlign = TextAlign.start,
    required this.config,
    this.glitchStyle = const GlitchStyle(),
    this.onControllerCreated,
  });

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText> {
  AnimatedTextController? _ctrl;

  // Per-instance seed so the order differs across app runs.
  late final int _baseSeed;

  // Forward-pass counter; reseeds the schedule so the order varies each repeat.
  int _pass = 0;
  AnimationStatus? _lastStatus;

  @override
  void initState() {
    super.initState();
    _baseSeed = math.Random().nextInt(1 << 31);
  }

  void _handleController(AnimatedTextController controller) {
    if (!identical(_ctrl, controller)) {
      _ctrl?.removeListener(_onControllerStatus);
      _ctrl = controller;
      _ctrl!.addListener(_onControllerStatus);
    }
    widget.onControllerCreated?.call(controller);
  }

  // Bump _pass at the start of each new forward sweep to reshuffle.
  void _onControllerStatus() {
    final status = _ctrl?.status;
    if (status == AnimationStatus.forward &&
        _lastStatus != AnimationStatus.forward) {
      _pass++;
    }
    _lastStatus = status;
  }

  @override
  void dispose() {
    _ctrl?.removeListener(_onControllerStatus);
    super.dispose();
  }

  WrapAlignment get _wrapAlignment => widget.textAlign == TextAlign.center
      ? WrapAlignment.center
      : widget.textAlign == TextAlign.end
          ? WrapAlignment.end
          : WrapAlignment.start;

  /// Segment index -> glitch progress for the current frame; absent when idle.
  Map<int, double> _activeProgress(List<String> segments, double p) {
    // Skip blank segments (spaces in letter mode).
    final targets = <int>[
      for (var i = 0; i < segments.length; i++)
        if (segments[i].trim().isNotEmpty) i,
    ];
    if (targets.isEmpty) return const {};

    final rng = math.Random(_baseSeed + _pass);
    final order = List<int>.of(targets)..shuffle(rng);
    final progress = p.clamp(0.0, 1.0);

    if (widget.config.type == AnimationType.word) {
      // One word at a time.
      final n = order.length;
      final slot = math.min((progress * n).floor(), n - 1);
      final g = (progress * n - slot).clamp(0.0, 1.0);
      return {order[slot]: g};
    }

    // Groups of 2-3 letters glitch together.
    final groups = _partitionGroups(order, rng);
    final g = groups.length;
    final slot = math.min((progress * g).floor(), g - 1);
    final localT = (progress * g - slot).clamp(0.0, 1.0);
    return {for (final index in groups[slot]) index: localT};
  }

  // Consecutive groups of size 2 or 3 (a lone leftover forms a group of 1).
  List<List<int>> _partitionGroups(List<int> order, math.Random rng) {
    final groups = <List<int>>[];
    var i = 0;
    final n = order.length;
    while (i < n) {
      final remaining = n - i;
      int size;
      if (remaining == 1) {
        size = 1;
      } else if (remaining == 2 || remaining == 4) {
        size = 2; // 4 -> 2+2 avoids a trailing size-1 group.
      } else {
        size = rng.nextBool() ? 2 : 3;
      }
      groups.add(order.sublist(i, i + size));
      i += size;
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTextBase(
      text: widget.text,
      style: widget.style,
      autoPlay: widget.autoPlay,
      textAlign: widget.textAlign,
      config: widget.config,
      onControllerCreated: _handleController,
      builder: (context, animations, segments) {
        final p = _ctrl?.progress ?? 0.0;
        final active = _activeProgress(segments, p);

        return Wrap(
          alignment: _wrapAlignment,
          children: List.generate(segments.length, (index) {
            final g = active[index];
            if (g == null) return Text(segments[index], style: widget.style);
            return _GlitchSlices(
              key: ValueKey('glitchActive_$index'),
              text: segments[index],
              style: widget.style,
              glitchStyle: widget.glitchStyle,
              progress: g,
              salt: index,
            );
          }),
        );
      },
    );
  }
}

/// One glitching segment drawn as three disjoint horizontal bands, each free to
/// shear sideways. Since the bands never overlap, the glyph tears without
/// ghosting and stays readable.
class _GlitchSlices extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final GlitchStyle glitchStyle;

  /// Local glitch progress (0 -> 1) across this segment's window.
  final double progress;

  /// Segment index; varies the shear between adjacent segments.
  final int salt;

  const _GlitchSlices({
    super.key,
    required this.text,
    required this.style,
    required this.glitchStyle,
    required this.progress,
    required this.salt,
  });

  @override
  Widget build(BuildContext context) {
    // sin envelope ramps the tear in and out.
    final env = math.sin(math.pi * progress.clamp(0.0, 1.0));
    final variant = ((progress * 6).floor() + salt) % _kShearPatterns.length;
    final shear = _kShearPatterns[variant];
    final fringe = _kFringePatterns[variant % _kFringePatterns.length];
    final base = style ?? const TextStyle();

    // Only a slice that actually tears gets the chromatic tint + fringe.
    TextStyle sliceStyle(double dx) {
      if (!glitchStyle.shadows || dx.abs() < 0.01) return base;
      final tint = dx < 0 ? glitchStyle.color1 : glitchStyle.color2;
      final other = dx < 0 ? glitchStyle.color2 : glitchStyle.color1;
      return base.copyWith(
        color: tint,
        shadows: [
          Shadow(color: other, offset: fringe[0] * env),
          Shadow(color: glitchStyle.shadowColor, offset: fringe[1] * env),
        ],
      );
    }

    Widget band(double top, double bottom, double dx) {
      return ClipRect(
        clipper: _BandClipper(top, bottom),
        child: Transform.translate(
          offset: Offset(dx * env, 0),
          child: Text(text, style: sliceStyle(dx * env)),
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        band(0.0, _kTopCut, shear[0]),
        band(_kTopCut, _kBottomCut, shear[1]),
        band(_kBottomCut, 1.0, shear[2]),
      ],
    );
  }
}

/// Clips a horizontal band between [topFactor] and [bottomFactor] of the height.
class _BandClipper extends CustomClipper<Rect> {
  const _BandClipper(this.topFactor, this.bottomFactor);
  final double topFactor;
  final double bottomFactor;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(
      0,
      size.height * topFactor,
      size.width,
      size.height * bottomFactor,
    );
  }

  @override
  bool shouldReclip(covariant _BandClipper oldClipper) {
    return oldClipper.topFactor != topFactor ||
        oldClipper.bottomFactor != bottomFactor;
  }
}
