import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pretty_animated_text/animated_text_wrapper.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';
import 'package:pretty_animated_text/src/utils/custom_curved_animation.dart';
import 'package:pretty_animated_text/src/utils/double_tween_by_rotate_type.dart';
import 'package:pretty_animated_text/src/utils/interval_step_by_overlap_factor.dart';
import 'package:pretty_animated_text/src/utils/wrap_alignment_by_text_align.dart';

/// A widget that animates text with a rotation effect, making each character or word
/// rotate into place with a fade-in animation.
class RotateText extends AnimatedTextWrapper {
  /// The type of rotation animation to apply
  final RotateAnimationType direction;

  const RotateText({
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
    this.direction = RotateAnimationType.clockwise,
  });

  @override
  RotateTextState createState() => RotateTextState();
}

class RotateTextState extends AnimatedTextWrapperState<RotateText> {
  /// Controls the rotation animation for each text segment
  late List<Animation<double>> _rotates;

  /// Controls the opacity animation for each text segment
  late List<Animation<double>> _opacities;

  @override
  void initState() {
    super.initState();

    // Calculate the interval step based on the number of segments and overlap factor
    final double intervalStep = intervalStepByOverlapFactor(
      data.length,
      widget.overlapFactor,
    );

    // Create rotation animations with staggered delays
    _rotates = data.map((item) {
      return doubleTweenByRotateType(widget.direction).animate(
        curvedAnimation(
          controller,
          item.index,
          intervalStep,
          widget.overlapFactor,
        ),
      );
    }).toList();

    // Create opacity animations with staggered starts
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
                    transform: Matrix4.identity()
                      ..rotateZ(
                          _rotates[dto.index].value * pi / 180), // 3D rotation
                    alignment: Alignment.center,
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
