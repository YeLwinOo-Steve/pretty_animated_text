// Inspired by Eduard Bodak's GSAP SplitText bounce — https://x.com/eduardbodak
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pretty_animated_text/src/widgets/paragraph_text.dart';
import 'package:pretty_animated_text/src/animated_text_base.dart';
import 'package:pretty_animated_text/src/animated_text_controller.dart';
import 'package:pretty_animated_text/src/animation_config.dart';

/// Visual customization for [SquashBounceText].
class SquashBounceStyle {
  /// Peak drop as a fraction of glyph height.
  final double dropFraction;

  /// Vertical scale at the squash peak (`1.0` = none).
  final double squashScaleY;

  /// Peak rotation in degrees, pivoting on the glyph's bottom.
  final double rotateDegrees;

  /// Fraction (0–1) of a glyph's window spent squashing in before it returns.
  final double squashPhase;

  /// Fraction (0–0.95) of the timeline the wave front spans. Smaller = tighter,
  /// more overlapping wave; larger = more sequential glyphs.
  final double waveSpread;

  const SquashBounceStyle({
    this.dropFraction = 0.5,
    this.squashScaleY = 0.3,
    this.rotateDegrees = 17,
    this.squashPhase = 0.2,
    this.waveSpread = 0.6,
  });

  SquashBounceStyle copyWith({
    double? dropFraction,
    double? squashScaleY,
    double? rotateDegrees,
    double? squashPhase,
    double? waveSpread,
  }) {
    return SquashBounceStyle(
      dropFraction: dropFraction ?? this.dropFraction,
      squashScaleY: squashScaleY ?? this.squashScaleY,
      rotateDegrees: rotateDegrees ?? this.rotateDegrees,
      squashPhase: squashPhase ?? this.squashPhase,
      waveSpread: waveSpread ?? this.waveSpread,
    );
  }
}

/// Animates text as a traveling wave: each glyph drops, squashes, and rotates,
/// then elastically settles. Glyphs run over a wide window with tightly-packed
/// starts (see [SquashBounceStyle.waveSpread]) so many overlap mid-flight.
///
/// Auto-plays on mount; honors repeat/reverse/pause from [AnimationConfig].
class SquashBounceText extends StatefulWidget {
  /// The text to animate
  final String text;

  /// The style to apply to the text
  final TextStyle? style;

  /// Auto animate when widget is first created
  final bool autoPlay;

  /// The text alignment
  final TextAlign textAlign;

  /// The animation configuration
  final AnimationConfig config;

  /// Squash/bounce appearance.
  final SquashBounceStyle squashStyle;

  /// On controller created
  final void Function(AnimatedTextController)? onControllerCreated;

  const SquashBounceText({
    super.key,
    required this.text,
    this.style,
    this.autoPlay = true,
    this.textAlign = TextAlign.start,
    required this.config,
    this.squashStyle = const SquashBounceStyle(),
    this.onControllerCreated,
  });

  @override
  State<SquashBounceText> createState() => _SquashBounceTextState();
}

class _SquashBounceTextState extends State<SquashBounceText> {
  AnimatedTextController? _ctrl;

  void _handleController(AnimatedTextController controller) {
    _ctrl = controller;
    widget.onControllerCreated?.call(controller);
  }

  WrapAlignment get _wrapAlignment => widget.textAlign == TextAlign.center
      ? WrapAlignment.center
      : widget.textAlign == TextAlign.end
          ? WrapAlignment.end
          : WrapAlignment.start;

  @override
  Widget build(BuildContext context) {
    // Measure a glyph height once to turn [dropFraction] into pixels.
    final painter = TextPainter(
      text: TextSpan(text: 'M', style: widget.style),
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
      textScaler: MediaQuery.maybeTextScalerOf(context) ?? TextScaler.noScaling,
    )..layout();
    final glyphHeight =
        painter.height > 0 ? painter.height : (widget.style?.fontSize ?? 16.0);

    final squashStyle = widget.squashStyle;
    final spread = squashStyle.waveSpread.clamp(0.0, 0.95);
    final window = 1.0 - spread; // each glyph's own animation window

    return AnimatedTextBase(
      text: widget.text,
      style: widget.style,
      autoPlay: widget.autoPlay,
      textAlign: widget.textAlign,
      config: widget.config,
      onControllerCreated: _handleController,
      builder: (context, animations, segments) {
        final p = _ctrl?.progress ?? 0.0;
        final n = segments.length;

        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          alignment: _wrapAlignment,
          children: List.generate(n, (index) {
            // Stagger starts across [0, spread]; each runs its cycle over [start, start + window].
            final start = n <= 1 ? 0.0 : spread * (index / (n - 1));
            final localT = window <= 0.0
                ? (p >= start ? 1.0 : 0.0)
                : ((p - start) / window).clamp(0.0, 1.0);

            final pose = _pose(localT, squashStyle);
            final dy = glyphHeight * pose.dropFraction;
            return Transform.translate(
              offset: Offset(0, dy),
              child: Transform.rotate(
                angle: pose.rotateDeg * math.pi / 180,
                alignment: Alignment.bottomCenter,
                child: Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.diagonal3Values(1, pose.scaleY, 1),
                  child: ParagraphText(
                    segments[index],
                    style: widget.style,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// A glyph pose: drop (fraction of glyph height), vertical squash, and rotation.
class _Pose {
  const _Pose({
    this.dropFraction = 0,
    this.scaleY = 1,
    this.rotateDeg = 0,
  });

  final double dropFraction;
  final double scaleY;
  final double rotateDeg;

  static _Pose lerp(_Pose a, _Pose b, double t) {
    return _Pose(
      dropFraction: a.dropFraction + (b.dropFraction - a.dropFraction) * t,
      scaleY: a.scaleY + (b.scaleY - a.scaleY) * t,
      rotateDeg: a.rotateDeg + (b.rotateDeg - a.rotateDeg) * t,
    );
  }
}

/// Maps a glyph's local `0→1` progress to a pose: ease into the squash peak,
/// then elastically return to identity.
_Pose _pose(double t, SquashBounceStyle style) {
  final peak = _Pose(
    dropFraction: style.dropFraction,
    scaleY: style.squashScaleY,
    rotateDeg: style.rotateDegrees,
  );
  if (t <= 0) return const _Pose();
  final phase = style.squashPhase.clamp(0.0001, 0.9999);
  if (t < phase) {
    final u = Curves.easeIn.transform(t / phase);
    return _Pose.lerp(const _Pose(), peak, u);
  }
  final u = ((t - phase) / (1 - phase)).clamp(0.0, 1.0);
  final elastic = Curves.elasticOut.transform(u);
  return _Pose.lerp(peak, const _Pose(), elastic);
}
