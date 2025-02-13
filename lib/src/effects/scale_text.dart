import 'package:flutter/material.dart';
import 'package:pretty_animated_text/animated_text_wrapper.dart';
import 'package:pretty_animated_text/src/utils/custom_curved_animation.dart';
import 'package:pretty_animated_text/src/utils/interval_step_by_overlap_factor.dart';
import 'package:pretty_animated_text/src/utils/spring_curve.dart';
import 'package:pretty_animated_text/src/utils/wrap_alignment_by_text_align.dart';

/// A widget that animates text with a scale effect, making each character or word
/// grow from zero to full size with a spring animation.
class ScaleText extends AnimatedTextWrapper {
  /// The alignment of the scale transformation
  final Alignment alignment;

  const ScaleText({
    super.key,
    required super.text,
    super.type,
    super.mode,
    super.textAlignment,
    super.overlapFactor,
    super.duration,
    super.textStyle,
    super.onPlay,
    super.onComplete,
    super.onPause,
    super.onResume,
    super.onRepeat,
    super.autoPlay,
    super.builder,
    this.alignment = Alignment.bottomCenter,
  });

  @override
  ScaleTextState createState() => ScaleTextState();
}

class ScaleTextState extends AnimatedTextWrapperState<ScaleText> {
  /// Controls the scale animation for each text segment
  late List<Animation<double>> _scales;

  @override
  void initState() {
    super.initState();

    // Calculate the interval step based on the number of segments and overlap factor
    final double intervalStep = intervalStepByOverlapFactor(
      data.length,
      widget.overlapFactor,
    );

    // Create scale animations for each text segment with spring effect
    _scales = data.map((item) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        curvedAnimation(
          controller,
          item.index,
          intervalStep,
          widget.overlapFactor,
          curve: SpringCurve(), // Custom spring curve for bouncy scaling
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
                final scaleValue = _scales[dto.index].value;
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.015) // Add perspective effect
                    ..scale(scaleValue, scaleValue), // Apply uniform scaling
                  alignment: widget.alignment,
                  child: child,
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