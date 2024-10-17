import 'package:flutter/material.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';
import 'package:pretty_animated_text/src/constants/constants.dart';
import 'dart:math';

import 'package:pretty_animated_text/src/dto/dto.dart';
import 'package:pretty_animated_text/src/extensions/animation_playback_mode.dart';
import 'package:pretty_animated_text/src/utils/custom_curved_animation.dart';
import 'package:pretty_animated_text/src/utils/interval_step_by_overlap_factor.dart';
import 'package:pretty_animated_text/src/utils/spring_curve.dart';
import 'package:pretty_animated_text/src/utils/text_transformation.dart';
import 'package:pretty_animated_text/src/utils/total_duration.dart';
import 'package:pretty_animated_text/src/utils/wrap_alignment_by_text_align.dart';

class ChimeBellText extends StatefulWidget {
  final String text;
  final AnimationType type;
  final AnimationMode mode;
  final double overlapFactor;
  final TextAlignment textAlignment;
  final Duration duration;
  final TextStyle? textStyle;

  const ChimeBellText({
    super.key,
    required this.text,
    this.mode = AnimationMode.forward,
    this.overlapFactor = kOverlapFactor,
    this.textAlignment = TextAlignment.start,
    this.textStyle,
    this.type = AnimationType.word,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  ChimeBellTextState createState() => ChimeBellTextState();
}

class ChimeBellTextState extends State<ChimeBellText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _opacities;
  late List<Animation<double>> _rotations;
  late final List<EffectDto> _data;

  @override
  void initState() {
    super.initState();
    _data = switch (widget.type) {
      AnimationType.letter => widget.text.splittedLetters,
      _ => widget.text.splittedWords,
    };
    final wordCount = _data.length;
    final double overlapFactor = widget.overlapFactor;

    final int totalDuration = getTotalDuration(
      wordCount: wordCount,
      duration: widget.duration,
      overlapFactor: overlapFactor,
    );

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalDuration),
      reverseDuration: Duration(milliseconds: totalDuration),
    );

    final double intervalStep =
        intervalStepByOverlapFactor(wordCount, overlapFactor);

    // Creating the opacity and rotation animations with staggered delays.
    _opacities = _data.map((data) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        curvedAnimation(
          _controller,
          data.index,
          intervalStep,
          overlapFactor,
        ),
      );
    }).toList();

    _rotations = _data.map((data) {
      return Tween<double>(begin: 180, end: 0).animate(
        curvedAnimation(
          _controller,
          data.index,
          intervalStep,
          overlapFactor,
          curve: SpringCurve(),
        ),
      );
    }).toList();

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

// Public methods to control the animation
  void playAnimation() {
    _controller.forward();
  }

  void pauseAnimation() {
    _controller.stop();
  }

  void reverseAnimation() {
    _controller.reverse();
  }

  void restartAnimation() {
    _controller.reset();
    Future.delayed(const Duration(milliseconds: 10), () {
      _controller.animationByMode(widget.mode);
    });
  }

  void repeatAnimation({bool reverse = false}) {
    _controller.repeat(reverse: reverse);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: wrapAlignmentByTextAlign(widget.textAlignment),
      children: _data
          .map(
            (dto) => AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return _animatedBuilder(dto, child);
              },
              child: Text(
                dto.text,
                style: widget.textStyle,
              ),
            ),
          )
          .toList(),
    );
  }

  Opacity _animatedBuilder(EffectDto data, Widget? child) {
    return Opacity(
      opacity: _opacities[data.index].value,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.015) // Perspective effect
          ..rotateX(_rotations[data.index].value * pi / 360), // 3D rotation
        alignment: Alignment.topCenter,
        child: child,
      ),
    );
  }
}
