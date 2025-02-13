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
  final AnimationController? controller;
  final TextStyle? textStyle;
  final VoidCallback? onPlay;
  final VoidCallback? onComplete;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onRepeat;
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
    this.controller,
    this.onPlay,
    this.onComplete,
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

    controller = widget.controller ??
        AnimationController(
          vsync: this,
          duration: Duration(milliseconds: totalDuration),
          reverseDuration: Duration(milliseconds: totalDuration),
        );

    controller.addStatusListener(_handleAnimationStatus);

    if (widget.builder != null) {
      widget.builder!(controller);
    } else if (widget.autoPlay) {
      controller.forward();
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.completed:
        widget.onComplete?.call();
        break;
      case AnimationStatus.forward:
        widget.onPlay?.call();
        break;
      case AnimationStatus.reverse:
        widget.onRepeat?.call();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
  }

  void play() {
    controller.forward();
    widget.onPlay?.call();
  }

  void pause() {
    controller.stop();
    widget.onPause?.call();
  }

  void resume() {
    controller.forward();
    widget.onResume?.call();
  }

  void reverse() {
    controller.reverse();
  }

  void restart() {
    controller.reset();
    Future.delayed(const Duration(milliseconds: 10), () {
      controller.animationByMode(widget.mode);
      widget.onPlay?.call();
    });
  }

  void repeat({bool reverse = false}) {
    controller.repeat(reverse: reverse);
    widget.onRepeat?.call();
  }
}
