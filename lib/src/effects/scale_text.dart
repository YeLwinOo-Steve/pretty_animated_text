import 'package:flutter/material.dart';
import 'package:pretty_animated_text/src/widgets/paragraph_text.dart';
import 'package:pretty_animated_text/src/animated_text_base.dart';
import 'package:pretty_animated_text/src/animated_text_controller.dart';
import 'package:pretty_animated_text/src/animation_config.dart';

/// A widget that animates text with a scale effect
class ScaleText extends StatelessWidget {
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

  const ScaleText({
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
            return Transform.scale(
              scale: animations[index].value,
              alignment: Alignment.center,
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
