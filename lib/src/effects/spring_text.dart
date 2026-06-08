import 'package:flutter/material.dart';
import 'package:pretty_animated_text/src/widgets/paragraph_text.dart';
import 'package:pretty_animated_text/src/animated_text_base.dart';
import 'package:pretty_animated_text/src/animated_text_controller.dart';
import 'package:pretty_animated_text/src/animation_config.dart';
import 'package:pretty_animated_text/src/utils/spring_curve.dart';

/// A widget that animates text with a spring effect
class SpringText extends StatelessWidget {
  /// The text to animate
  final String text;

  /// The style to apply to the text
  final TextStyle? style;

  /// The text alignment
  final TextAlign textAlign;

  /// The animation configuration
  final AnimationConfig config;

  /// On controller created
  final void Function(AnimatedTextController)? onControllerCreated;

  const SpringText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    required this.config,
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
            // dampingRatio = damping / (2 * sqrt(mass * stiffness)) ≈ 0.28 -> ~37% overshoot.
            // Hard-coded so SpringText always feels like a spring regardless of
            // what curve the caller puts in config.curve.
            final yAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
              CurvedAnimation(
                parent: animations[index],
                curve: const SpringCurve(
                  stiffness: 200.0,
                  damping: 12.0,
                  duration: 1.2,
                ),
              ),
            );

            // Fade in during the first third so the spring bounce is fully visible.
            final opacityAnimation =
                Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animations[index],
                curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
              ),
            );

            return AnimatedBuilder(
              animation: animations[index],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0.0, yAnimation.value),
                  child: Opacity(
                    opacity: opacityAnimation.value.clamp(0.0, 1.0),
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
