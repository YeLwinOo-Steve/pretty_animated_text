import 'package:flutter/material.dart';
import 'package:pretty_animated_text/animated_text_wrapper.dart';
import 'package:pretty_animated_text/src/utils/custom_curved_animation.dart';
import 'package:pretty_animated_text/src/utils/interval_step_by_overlap_factor.dart';
import 'package:pretty_animated_text/src/utils/spring_curve.dart';
import 'package:pretty_animated_text/src/utils/wrap_alignment_by_text_align.dart';
import 'dart:math';

/// A widget that animates text with a spring effect, making each character or word
/// bounce into place with rotation and fade-in animation.
class SpringText extends AnimatedTextWrapper {
  const SpringText({
    super.key,
    required super.text,
    super.type,
    super.mode,
    super.textAlignment,
    super.overlapFactor,
    super.duration,
    super.textStyle,
    super.controller,
    super.onPlay,
    super.onComplete,
    super.onPause,
    super.onResume,
    super.onRepeat,
    super.autoPlay,
    super.builder,
  });

  @override
  SpringTextState createState() => SpringTextState();
}

class SpringTextState extends AnimatedTextWrapperState<SpringText> {
  /// Controls the opacity animation for each text segment
  late List<Animation<double>> _opacities;

  /// Controls the rotation animation for each text segment
  late List<Animation<double>> _rotations;

  /// Controls the spring bounce animation for each text segment
  late List<Animation<double>> _springAnimations;

  @override
  void initState() {
    super.initState();

    // Calculate the interval step based on the number of segments and overlap factor
    final double intervalStep = intervalStepByOverlapFactor(
      data.length,
      widget.overlapFactor,
    );

    // Create opacity animations for each text segment
    _opacities = data.map((item) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        curvedAnimation(
          controller,
          item.index,
          intervalStep,
          widget.overlapFactor,
        ),
      );
    }).toList();

    // Create rotation animations for each text segment
    _rotations = data.map((item) {
      return Tween<double>(begin: 180.0, end: 0.0).animate(
        curvedAnimation(
          controller,
          item.index,
          intervalStep,
          widget.overlapFactor,
        ),
      );
    }).toList();

    // Create spring animations for vertical bounce effect
    _springAnimations = data.map((item) {
      return Tween<double>(begin: 1, end: 0).animate(
        curvedAnimation(
          controller,
          item.index,
          intervalStep,
          widget.overlapFactor,
          curve: SpringCurve(), // Custom spring curve for bouncy effect
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: wrapAlignmentByTextAlign(widget.textAlignment),
      children: data
          .map(
            (dto) => AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacities[dto.index].value,
                  child: Transform(
                    alignment: Alignment.bottomCenter,
                    transform: Matrix4.identity()
                      // Apply vertical translation with spring effect
                      ..translate(0.0, _springAnimations[dto.index].value)
                      // Apply Z-axis rotation for spinning effect
                      ..rotateZ(_rotations[dto.index].value * pi / 180),
                    child: child,
                  ),
                );
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
}