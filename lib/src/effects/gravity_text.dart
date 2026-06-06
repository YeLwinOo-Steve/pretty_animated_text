import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:forge2d/forge2d.dart';
import 'package:pretty_animated_text/src/animated_text_controller.dart';
import 'package:pretty_animated_text/src/animation_config.dart';
import 'package:pretty_animated_text/src/enums/animation_type.dart';
import 'package:pretty_animated_text/src/utils/bounding_rect_of_boxes.dart';
import 'package:pretty_animated_text/src/utils/clamp_vector_length.dart';
import 'package:pretty_animated_text/src/utils/gravity_release_step.dart';
import 'package:pretty_animated_text/src/utils/gravity_wall_layout.dart';
import 'package:pretty_animated_text/src/utils/simulation_time_step.dart';
import 'package:pretty_animated_text/src/utils/text_transformation.dart';

/// A text widget with realistic 2D physics powered by Forge2D.
///
/// The text starts in its normal position. When the animation plays,
/// each letter or word falls under gravity, collides, and stacks up.
///
/// You can tap letters to push them, or drag and release to throw them.
///
/// Use [AnimatedTextController] to play, restart, repeat, pause,
/// or resume the animation.
class GravityText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final AnimationConfig config;
  final void Function(AnimatedTextController)? onControllerCreated;

  final double gravity;
  
  /// pixels per simulated metre - range (~0.1–10 m).
  final double pixelsPerMeter;
  final double density;
  final double friction;
  final double restitution;

  // explicit height
  final double? height;

  /// enable/disable interaction
  final bool enableInteraction;

  final double kickStrength;

  // spin words/letters in mid-air
  final double maxSpin;

  const GravityText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    required this.config,
    this.onControllerCreated,
    this.gravity = 30.0,
    this.pixelsPerMeter = 50.0,
    this.density = 1.0,
    this.friction = 0.4,
    this.restitution = 0.1,
    this.height,
    this.enableInteraction = true,
    this.kickStrength = 9.0,
    this.maxSpin = 2.5,
  });

  @override
  State<GravityText> createState() => _GravityTextState();
}

class _GravityTextState extends State<GravityText>
    with TickerProviderStateMixin {
  static const double _fallbackWidth = 360.0;
  static const double _fallbackHeight = 400.0;
  static const double _wallThicknessPx = 24.0;
  static const double _boxInset = 0.82;
  static const double _dragGain = 28.0;
  static const double _maxDragSpeed = 40.0; // m/s
  static const double _maxThrowSpeed = 30.0; // m/s
  static const double _maxInitialTilt = 0.18; // rad (~10°)

  late final AnimationController _clock;
  late final AnimatedTextController _textController;
  late final Ticker _ticker;
  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);
  final math.Random _rng = math.Random();

  World? _world;
  List<_Glyph> _glyphs = const [];
  Size? _builtSize;
  bool _worldDirty = false;

  bool _running = false;
  bool _pendingDrop = false;
  Duration _lastElapsed = Duration.zero;

  double _dropClock = 0.0;

  Body? _dragBody;
  Vector2? _dragTarget;

  double get _ppm => widget.pixelsPerMeter;

  /// Delay between consecutive segments being released to fall
  double get _releaseStepSeconds =>
      gravityReleaseStep(widget.config.duration, widget.config.overlapFactor);

  @override
  void initState() {
    super.initState();
    _clock =
        AnimationController(vsync: this, duration: const Duration(hours: 1));
    _textController = AnimatedTextController()..attach(_clock, widget.config);
    _textController.addListener(_onControllerNotify);
    _clock.addStatusListener(_onClockStatus);
    _ticker = createTicker(_onTick);
    widget.onControllerCreated?.call(_textController);
    _textController.startInitialAnimation();
  }

  void _onControllerNotify() {
    _setRunning(_textController.isAnimating);
  }

  void _onClockStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      _pendingDrop = true;
    } else if (status == AnimationStatus.forward ||
        status == AnimationStatus.reverse) {
      if (_pendingDrop) {
        _pendingDrop = false;
        _resetAndDrop();
      }
    }
  }

  void _setRunning(bool running) {
    if (_running == running) return;
    _running = running;
    _syncTicker();
  }

  void _syncTicker() {
    final shouldTick = _running && _world != null && mounted;
    if (shouldTick && !_ticker.isActive) {
      _lastElapsed = Duration.zero;
      _ticker.start();
    } else if (!shouldTick && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _onTick(Duration elapsed) {
    final world = _world;
    if (world == null) return;

    final dt = simulationTimeStep(elapsed, _lastElapsed);
    _lastElapsed = elapsed;
    if (dt <= 0) return;

    _dropClock += dt;
    _releaseDueGlyphs();
    _followDragTarget();

    world.stepDt(dt);
    _repaint.value++;
  }

  /// Activates any still-frozen glyph whose release time has elapsed.
  void _releaseDueGlyphs() {
    for (final g in _glyphs) {
      if (g.body.bodyType == BodyType.static && _dropClock >= g.releaseTime) {
        _dropGlyph(g);
      }
    }
  }

  /// Turns a frozen glyph dynamic and gives it a random tilt + spin so it
  /// tumbles in mid-air, then enables collisions with walls/floors.
  void _dropGlyph(_Glyph g) {
    g.body.setType(BodyType.dynamic);
    g.fixture.filterData = Filter();
    g.body.setTransform(
      g.initialCenter,
      (_rng.nextDouble() * 2 - 1) * _maxInitialTilt,
    );
    g.body.angularVelocity = (_rng.nextDouble() * 2 - 1) * widget.maxSpin;
    g.body.setAwake(true);
  }

  
  void _followDragTarget() {
    final drag = _dragBody;
    final target = _dragTarget;
    if (drag == null || target == null) return;

    final v = clampVectorLength(
      (target - drag.worldCenter) * _dragGain,
      _maxDragSpeed,
    );
    drag.linearVelocity = v;
    drag.setAwake(true);
  }

  void _resetAndDrop() {
    _dropClock = 0.0;
    for (final g in _glyphs) {
      g.body.setType(BodyType.static);
      g.fixture.filterData = Filter()..maskBits = 0;
      g.body.setTransform(g.initialCenter, 0.0);
      g.body.linearVelocity = Vector2.zero();
      g.body.angularVelocity = 0.0;
    }
  }


  void _buildWorld(Size size, BuildContext context) {
    final glyphs = _measureGlyphs(size, context);

    final world = World(Vector2(0.0, widget.gravity))..setAllowSleep(true);

    for (final wall in gravityWallLayout(size, _ppm, _wallThicknessPx)) {
      _createStatic(world, wall.center, wall.halfWidth, wall.halfHeight);
    }

    final step = _releaseStepSeconds;
    for (var i = 0; i < glyphs.length; i++) {
      _createGlyphBody(world, glyphs[i], i, releaseTime: i * step);
    }

    _dropClock = 0.0;
    _world = world;
    _glyphs = glyphs;
  }

  void _createStatic(World world, Vector2 center, double halfW, double halfH) {
    final body =
        world.createBody(BodyDef(type: BodyType.static, position: center));
    final shape = PolygonShape()..setAsBoxXY(halfW, halfH);
    body.createFixtureFromShape(shape, friction: widget.friction);
  }

  /// Creates a frozen body for [g] at its reading position. 
  /// (colliding with nothing) until released by [_dropGlyph].
  void _createGlyphBody(
    World world,
    _Glyph g,
    int index, {
    required double releaseTime,
  }) {
    g.releaseTime = releaseTime;
    final body = world.createBody(BodyDef(
      type: BodyType.static,
      position: g.initialCenter,
      angularDamping: 0.8,
    ));
    body.userData = index;
    final halfW = (g.width * _boxInset / 2) / _ppm;
    final halfH = (g.height * _boxInset / 2) / _ppm;
    final shape = PolygonShape()..setAsBoxXY(halfW, halfH);
    final fixture = body.createFixtureFromShape(
      shape,
      density: widget.density,
      friction: widget.friction,
      restitution: widget.restitution,
    );
    fixture.filterData = Filter()..maskBits = 0;
    g.body = body;
    g.fixture = fixture;
  }

  List<String> _segments() {
    final data = widget.config.type == AnimationType.letter
        ? widget.text.splittedLetters
        : widget.text.splittedWords;
    return data.map((d) => d.text).toList();
  }

  List<_Glyph> _measureGlyphs(Size size, BuildContext context) {
    final effectiveStyle = _resolveStyle(context);
    final scaler =
        MediaQuery.maybeTextScalerOf(context) ?? TextScaler.noScaling;
    final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;

    final full = TextPainter(
      text: TextSpan(text: widget.text, style: effectiveStyle),
      textAlign: widget.textAlign,
      textDirection: direction,
      textScaler: scaler,
    )..layout(maxWidth: size.width);

    final topOffset = ((size.height - full.height) / 2).clamp(0.0, size.height);

    final glyphs = <_Glyph>[];
    var offset = 0;
    for (final segment in _segments()) {
      final start = offset;
      final end = offset + segment.length;
      offset = end;

      final glyph = _buildGlyph(
        segment: segment,
        start: start,
        end: end,
        full: full,
        topOffset: topOffset,
        style: effectiveStyle,
        direction: direction,
        scaler: scaler,
      );
      if (glyph != null) glyphs.add(glyph);
    }

    full.dispose();
    return glyphs;
  }

  /// Builds a single [_Glyph] for the text range [start]–[end] within [full],
  /// or `null` for whitespace-only / unrenderable segments.
  _Glyph? _buildGlyph({
    required String segment,
    required int start,
    required int end,
    required TextPainter full,
    required double topOffset,
    required TextStyle style,
    required TextDirection direction,
    required TextScaler scaler,
  }) {
    if (segment.trim().isEmpty) return null;

    final rect = boundingRectOfBoxes(full.getBoxesForSelection(
      TextSelection(baseOffset: start, extentOffset: end),
    ));
    if (rect == null) return null;

    final glyphPainter = TextPainter(
      text: TextSpan(text: segment, style: style),
      textDirection: direction,
      textScaler: scaler,
    )..layout();

    final centerPx = Offset(rect.center.dx, rect.center.dy + topOffset);
    return _Glyph(
      painter: glyphPainter,
      width: glyphPainter.width,
      height: glyphPainter.height,
      initialCenter: Vector2(centerPx.dx / _ppm, centerPx.dy / _ppm),
    );
  }

  TextStyle _resolveStyle(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context).style;
    final s = widget.style;
    TextStyle effective = (s == null || s.inherit) ? defaultStyle.merge(s) : s;
    if (MediaQuery.maybeOf(context)?.boldText ?? false) {
      effective = effective.merge(const TextStyle(fontWeight: FontWeight.bold));
    }
    return effective;
  }

  Body? _pick(Offset localPx) {
    final world = _world;
    if (world == null) return null;
    final point = Vector2(localPx.dx / _ppm, localPx.dy / _ppm);
    const d = 0.02;
    final aabb = AABB()
      ..lowerBound.setValues(point.x - d, point.y - d)
      ..upperBound.setValues(point.x + d, point.y + d);
    final cb = _PickCallback(point);
    world.queryAABB(cb, aabb);
    return cb.picked;
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.enableInteraction) return;
    final body = _pick(details.localPosition);
    if (body == null) return;
    final dir = Vector2(_rng.nextDouble() * 0.8 - 0.4, -1.0)..normalize();
    body.applyLinearImpulse(
      dir * (widget.kickStrength * body.mass),
      point: body.worldCenter,
      wake: true,
    );
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.enableInteraction) return;
    _dragBody = _pick(details.localPosition);
    if (_dragBody != null) {
      _dragTarget = Vector2(
        details.localPosition.dx / _ppm,
        details.localPosition.dy / _ppm,
      );
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_dragBody == null) return;
    _dragTarget = Vector2(
      details.localPosition.dx / _ppm,
      details.localPosition.dy / _ppm,
    );
  }

  void _onPanEnd(DragEndDetails details) {
    final body = _dragBody;
    if (body != null) {
      final px = details.velocity.pixelsPerSecond;
      body.linearVelocity = clampVectorLength(
        Vector2(px.dx / _ppm, px.dy / _ppm),
        _maxThrowSpeed,
      );
      body.setAwake(true);
    }
    _dragBody = null;
    _dragTarget = null;
  }


  @override
  void didUpdateWidget(GravityText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.onControllerCreated != widget.onControllerCreated) {
      widget.onControllerCreated?.call(_textController);
    }

    if (oldWidget.config != widget.config) {
      _textController.updateConfig(widget.config);
    }

    if (oldWidget.text != widget.text ||
        oldWidget.style != widget.style ||
        oldWidget.textAlign != widget.textAlign ||
        oldWidget.config.type != widget.config.type ||
        oldWidget.gravity != widget.gravity ||
        oldWidget.pixelsPerMeter != widget.pixelsPerMeter ||
        oldWidget.density != widget.density ||
        oldWidget.friction != widget.friction ||
        oldWidget.restitution != widget.restitution) {
      _worldDirty = true;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.removeStatusListener(_onClockStatus);
    _textController.removeListener(_onControllerNotify);
    _textController.detach();
    _clock.dispose();
    _textController.dispose();
    _repaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stageWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : _fallbackWidth;
        final stageHeight = widget.height ??
            (constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : _fallbackHeight);
        final size = Size(stageWidth, stageHeight);

        if (_world == null || _builtSize != size || _worldDirty) {
          _buildWorld(size, context);
          _builtSize = size;
          _worldDirty = false;
          _syncTicker();
        }

        return SizedBox(
          width: stageWidth,
          height: stageHeight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: widget.enableInteraction ? _onTapUp : null,
            onPanStart: widget.enableInteraction ? _onPanStart : null,
            onPanUpdate: widget.enableInteraction ? _onPanUpdate : null,
            onPanEnd: widget.enableInteraction ? _onPanEnd : null,
            child: CustomPaint(
              size: size,
              painter: _GravityPainter(
                glyphs: _glyphs,
                ppm: _ppm,
                repaint: _repaint,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Glyph {
  final TextPainter painter;
  final double width;
  final double height;
  final Vector2 initialCenter;
  late Body body;
  late Fixture fixture;
  double releaseTime = 0.0;

  _Glyph({
    required this.painter,
    required this.width,
    required this.height,
    required this.initialCenter,
  });
}

class _PickCallback extends QueryCallback {
  final Vector2 point;
  Body? picked;

  _PickCallback(this.point);

  @override
  bool reportFixture(Fixture fixture) {
    if (fixture.body.userData is int && fixture.testPoint(point)) {
      picked = fixture.body;
      return false;
    }
    return true;
  }
}

class _GravityPainter extends CustomPainter {
  final List<_Glyph> glyphs;
  final double ppm;

  _GravityPainter({
    required this.glyphs,
    required this.ppm,
    required Listenable repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    for (final g in glyphs) {
      final p = g.body.position;
      canvas.save();
      canvas.translate(p.x * ppm, p.y * ppm);
      canvas.rotate(g.body.angle);
      g.painter.paint(canvas, Offset(-g.width / 2, -g.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _GravityPainter oldDelegate) =>
      oldDelegate.glyphs != glyphs || oldDelegate.ppm != ppm;
}
