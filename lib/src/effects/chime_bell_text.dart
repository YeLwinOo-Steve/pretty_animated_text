import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pretty_animated_text/animated_text_wrapper.dart';
import 'package:pretty_animated_text/src/utils/custom_curved_animation.dart';
import 'package:pretty_animated_text/src/utils/interval_step_by_overlap_factor.dart';
import 'package:pretty_animated_text/src/utils/spring_curve.dart';
import 'package:pretty_animated_text/src/utils/wrap_alignment_by_text_align.dart';

/// A widget that animates text with a chime bell effect, making each character or word
/// appear with a 3D rotation and fade-in animation.
class ChimeBellText extends AnimatedTextWrapper {
  const ChimeBellText({
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
  ChimeBellTextState createState() => ChimeBellTextState();
}

class ChimeBellTextState extends AnimatedTextWrapperState<ChimeBellText> {
  /// Controls the opacity animation for each text segment
  late List<Animation<double>> _opacities;

  /// Controls the rotation animation for each text segment
  late List<Animation<double>> _rotations;

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

    // Create rotation animations for each text segment with a spring curve
    _rotations = data.map((item) {
      return Tween<double>(begin: 180, end: 0).animate(
        curvedAnimation(
          controller,
          item.index,
          intervalStep,
          widget.overlapFactor,
          curve: SpringCurve(),
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
                      ..setEntry(3, 2, 0.015) // Adds perspective effect
                      ..rotateX(_rotations[dto.index].value *
                          pi /
                          360), // 3D rotation around X axis
                    alignment: Alignment.topCenter,
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
