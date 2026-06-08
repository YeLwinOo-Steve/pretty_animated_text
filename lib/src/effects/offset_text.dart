import 'package:flutter/material.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';
import 'package:pretty_animated_text/src/utils/offset_tween_by_slide_type.dart';

/// A widget that animates text with a sliding effect, making each character or word
/// slide into place from a specified direction with a fade-in animation.
///
/// The animation can be customized with different slide directions and timing effects.
class OffsetText extends StatelessWidget {
  /// The text to animate
  final String text;

  /// The style to apply to the text
  final TextStyle? style;

  /// The text alignment
  final TextAlign textAlign;

  /// The animation configuration
  final AnimationConfig config;

  /// The type of slide animation to apply (e.g., top to bottom, left to right)
  /// This determines the direction from which the text will slide in
  final SlideAnimationType slideType;

  /// On controller created
  final void Function(AnimatedTextController)? onControllerCreated;

  const OffsetText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    required this.config,
    this.slideType = SlideAnimationType.topBottom,
    this.onControllerCreated,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTextBase(
      text: text,
      style: style,
      textAlign: textAlign,
      config: config,
      onControllerCreated: onControllerCreated,
      builder: (context, animations, segments) {
        return Wrap(
          alignment: textAlign == TextAlign.center
              ? WrapAlignment.center
              : textAlign == TextAlign.end
                  ? WrapAlignment.end
                  : WrapAlignment.start,
          children: List.generate(segments.length, (index) {
            final offsetAnimation = offsetTweenBySlideType(
              slideType,
              index: index,
            ).animate(
              CurvedAnimation(
                parent: animations[index],
                curve: config.curve,
              ),
            );

            return AnimatedBuilder(
              animation: offsetAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: offsetAnimation.value,
                  child: Opacity(
                    opacity: animations[index].value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: ParagraphText(
                segments[index],
                style: style,
              ),
            );
          }),
        );
      },
    );
  }
}
