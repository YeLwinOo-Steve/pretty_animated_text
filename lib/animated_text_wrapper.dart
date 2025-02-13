import 'package:flutter/material.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';
import 'package:pretty_animated_text/src/dto/dto.dart';
import 'package:pretty_animated_text/src/extensions/animation_playback_mode.dart';
import 'package:pretty_animated_text/src/utils/text_transformation.dart';
import 'package:pretty_animated_text/src/utils/total_duration.dart';

import 'src/constants/constants.dart';

abstract class AnimatedTextWrapper extends StatefulWidget {
  final String text;
  final AnimationType type;
  final AnimationMode mode;
  final TextAlignment textAlignment;
  final double overlapFactor;
  final Duration duration;
  final TextStyle? textStyle;
  final void Function(AnimationController)? onPlay;
  final void Function(AnimationController)? onComplete;
  final void Function(AnimationController)? onDismissed;
  final void Function(AnimationController)? onPause;
  final void Function(AnimationController)? onResume;
  final void Function(AnimationController)? onRepeat;
  final bool autoPlay;
  final void Function(AnimationController controller)? builder;

  const AnimatedTextWrapper({
    super.key,
    required this.text,
    this.type = AnimationType.word,
    this.mode = AnimationMode.forward,
    this.textAlignment = TextAlignment.start,
    this.overlapFactor = kOverlapFactor,
    this.duration = const Duration(milliseconds: 200),
    this.textStyle,
    this.onPlay,
    this.onComplete,
    this.onDismissed,
    this.onPause,
    this.onResume,
    this.onRepeat,
    this.autoPlay = true,
    this.builder,
  });

  @override
  AnimatedTextWrapperState createState();
}

abstract class AnimatedTextWrapperState<T extends AnimatedTextWrapper>
    extends State<T> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final List<EffectDto> data;

  @override
  void initState() {
    super.initState();
    data = switch (widget.type) {
      AnimationType.letter => widget.text.splittedLetters,
      _ => widget.text.splittedWords,
    };

    final wordCount = data.length;
    final int totalDuration = getTotalDuration(
      wordCount: wordCount,
      duration: widget.duration,
      overlapFactor: widget.overlapFactor,
    );

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalDuration),
      reverseDuration: Duration(milliseconds: totalDuration),
    );

    controller.addStatusListener(_handleAnimationStatus);

    if (widget.builder != null) {
      widget.builder!(controller);
    }
    if (widget.autoPlay) {
      controller.forward();
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.completed:
        widget.onComplete?.call(controller);
        break;
      case AnimationStatus.forward:
        widget.onPlay?.call(controller);
        break;
      case AnimationStatus.reverse:
        widget.onRepeat?.call(controller);
        break;
      case AnimationStatus.dismissed:
        widget.onComplete?.call(controller);
        break;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void listen(void Function(double) callback) {
    controller.addListener(() {
      callback(controller.value);
    });
  }

  void play() {
    controller.forward();
    widget.onPlay?.call(controller);
  }

  void pause() {
    controller.stop();
    widget.onPause?.call(controller);
  }

  void resume() {
    controller.forward();
    widget.onResume?.call(controller);
  }

  void reverse() {
    controller.reverse();
  }

  void restart() {
    controller.reset();
    Future.delayed(const Duration(milliseconds: 10), () {
      controller.animationByMode(widget.mode);
      widget.onPlay?.call(controller);
    });
  }

  void repeat({bool reverse = false}) {
    controller.repeat(reverse: reverse);
    widget.onRepeat?.call(controller);
  }
}
