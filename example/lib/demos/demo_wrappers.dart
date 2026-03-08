import 'package:flutter/material.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';
import '../core/constants.dart';

AnimationConfig _buildConfig(
  Type runtimeType,
  AnimationType type,
  Duration duration,
  void Function(AnimatedTextController)? onCreated,
) {
  return AnimationConfig(
    type: type,
    duration: duration,
    repeat: true,
    onPlay: (c) => debugPrint('$runtimeType animation played!'),
    onPause: (c) => debugPrint('$runtimeType animation paused!'),
    onComplete: (c) => debugPrint('$runtimeType animation completed!'),
    repeatCount: 3,
    reverse: true,
    onRepeat: (c, r) => debugPrint('$runtimeType animation repeated! $r times'),
    onDismissed: (c) => debugPrint('$runtimeType animation dismissed!'),
  );
}

class ChimeBellDemo extends StatelessWidget {
  final AnimationType type;
  final Duration duration;
  final TextAlign textAlign;
  final void Function(AnimatedTextController)? onControllerCreated;

  const ChimeBellDemo({
    super.key,
    this.type = AnimationType.letter,
    this.duration = letterAnimationDuration,
    this.textAlign = TextAlign.start,
    this.onControllerCreated,
  });

  @override
  Widget build(BuildContext context) => ChimeBellText(
        text: demoText,
        style: demoTextStyle,
        textAlign: textAlign,
        config: _buildConfig(runtimeType, type, duration, onControllerCreated),
        onControllerCreated: onControllerCreated,
      );
}

class SpringDemo extends StatelessWidget {
  final AnimationType type;
  final Duration duration;
  final TextAlign textAlign;
  final void Function(AnimatedTextController)? onControllerCreated;

  const SpringDemo({
    super.key,
    this.type = AnimationType.letter,
    this.duration = letterAnimationDuration,
    this.textAlign = TextAlign.start,
    this.onControllerCreated,
  });

  @override
  Widget build(BuildContext context) => SpringText(
        text: demoText,
        style: demoTextStyle,
        textAlign: textAlign,
        config: _buildConfig(runtimeType, type, duration, onControllerCreated),
        onControllerCreated: onControllerCreated,
      );
}

class ScaleTextDemo extends StatelessWidget {
  final AnimationType type;
  final Duration duration;
  final TextAlign textAlign;
  final void Function(AnimatedTextController)? onControllerCreated;

  const ScaleTextDemo({
    super.key,
    this.type = AnimationType.letter,
    this.duration = letterAnimationDuration,
    this.textAlign = TextAlign.start,
    this.onControllerCreated,
  });

  @override
  Widget build(BuildContext context) => ScaleText(
        text: demoText,
        style: demoTextStyle,
        textAlign: textAlign,
        config: _buildConfig(runtimeType, type, duration, onControllerCreated),
        onControllerCreated: onControllerCreated,
      );
}

class RotateTextDemo extends StatelessWidget {
  final AnimationType type;
  final RotateAnimationType direction;
  final Duration duration;
  final TextAlign textAlign;
  final void Function(AnimatedTextController)? onControllerCreated;

  const RotateTextDemo({
    super.key,
    this.direction = RotateAnimationType.clockwise,
    this.type = AnimationType.letter,
    this.duration = letterAnimationDuration,
    this.textAlign = TextAlign.start,
    this.onControllerCreated,
  });

  @override
  Widget build(BuildContext context) => RotateText(
        text: demoText,
        style: demoTextStyle,
        textAlign: textAlign,
        direction: direction,
        config: _buildConfig(runtimeType, type, duration, onControllerCreated),
        onControllerCreated: onControllerCreated,
      );
}

class BlurTextDemo extends StatelessWidget {
  final AnimationType type;
  final Duration duration;
  final TextAlign textAlign;
  final void Function(AnimatedTextController)? onControllerCreated;

  const BlurTextDemo({
    super.key,
    this.type = AnimationType.letter,
    this.duration = letterAnimationDuration,
    this.textAlign = TextAlign.start,
    this.onControllerCreated,
  });

  @override
  Widget build(BuildContext context) => BlurText(
        text: demoText,
        style: demoTextStyle,
        textAlign: textAlign,
        config: _buildConfig(runtimeType, type, duration, onControllerCreated),
        onControllerCreated: onControllerCreated,
      );
}

class SlideTextDemo extends StatelessWidget {
  final AnimationType type;
  final SlideAnimationType slideType;
  final Duration duration;
  final TextAlign textAlign;
  final void Function(AnimatedTextController)? onControllerCreated;

  const SlideTextDemo({
    super.key,
    this.type = AnimationType.letter,
    this.slideType = SlideAnimationType.topBottom,
    this.duration = letterAnimationDuration,
    this.textAlign = TextAlign.start,
    this.onControllerCreated,
  });

  @override
  Widget build(BuildContext context) => SlideText(
        text: demoText,
        style: demoTextStyle,
        textAlign: textAlign,
        slideType: slideType,
        config: _buildConfig(runtimeType, type, duration, onControllerCreated),
        onControllerCreated: onControllerCreated,
      );
}
