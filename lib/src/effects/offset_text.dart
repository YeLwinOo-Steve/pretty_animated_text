import 'package:flutter/material.dart';
import 'package:pretty_animated_text/animated_text_wrapper.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';
import 'package:pretty_animated_text/src/utils/custom_curved_animation.dart';
import 'package:pretty_animated_text/src/utils/interval_step_by_overlap_factor.dart';
import 'package:pretty_animated_text/src/utils/offset_tween_by_slide_type.dart';
import 'package:pretty_animated_text/src/utils/spring_curve.dart';
import 'package:pretty_animated_text/src/utils/wrap_alignment_by_text_align.dart';

/// A widget that animates text with a sliding effect, making each character or word
/// slide into place from a specified direction with a fade-in animation.
///
/// The animation can be customized with different slide directions and timing effects.
class OffsetText extends AnimatedTextWrapper {
  /// The type of slide animation to apply (e.g., top to bottom, left to right)
  /// This determines the direction from which the text will slide in
  final SlideAnimationType slideType;

  const OffsetText({
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
    this.slideType = SlideAnimationType.topBottom,
  });

  @override
  OffsetTextState createState() => OffsetTextState();
}

class OffsetTextState extends AnimatedTextWrapperState<OffsetText> {
  /// Controls the offset (position) animation for each text segment
  /// Each segment will slide from its starting position to its final position
  late List<Animation<Offset>> _offsets;

  /// Controls the opacity animation for each text segment
  /// Allows text to fade in as it slides into position
  late List<Animation<double>> _opacities;

  @override
  void initState() {
    super.initState();

    // Calculate the interval step based on the number of segments and overlap factor
    // This determines how much delay there is between each segment's animation
    final double intervalStep = intervalStepByOverlapFactor(
      data.length,
      widget.overlapFactor,
    );

    // Create offset animations with staggered delays and spring effect
    // Each text segment will have its own offset animation
    _offsets = data.map((item) {
      return offsetTweenBySlideType(
        widget.slideType,
        index: item.index,
      ).animate(
        curvedAnimation(
          controller,
          item.index,
          intervalStep,
          widget.overlapFactor,
          curve: SpringCurve(), // Adds a bouncy effect to the slide animation
        ),
      );
    }).toList();

    // Create opacity animations with staggered starts
    // Each text segment will fade in as it slides into position
    _opacities = data.map((item) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        curvedAnimation(
          controller,
          item.index,
          intervalStep,
          widget.overlapFactor,
          curve: Curves.easeIn, // Smooth fade-in effect
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      // Align the text based on the specified text alignment
      alignment: wrapAlignmentByTextAlign(widget.textAlignment),
      children: data
          .map(
            (dto) => AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return Opacity(
                  // Apply the fade-in effect
                  opacity: _opacities[dto.index].value,
                  child: Transform.translate(
                    // Apply the sliding movement
                    offset: _offsets[dto.index].value,
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
