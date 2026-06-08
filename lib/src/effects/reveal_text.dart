import 'package:flutter/material.dart';
import 'package:pretty_animated_text/src/widgets/paragraph_text.dart';
import 'package:pretty_animated_text/src/animated_text_base.dart';
import 'package:pretty_animated_text/src/animated_text_controller.dart';
import 'package:pretty_animated_text/src/animation_config.dart';

/// A widget that reveals text with a sliding cursor.
///
/// All text starts at [dimOpacity] (default 0.3). As the animation plays,
/// a cursor sweeps left-to-right and each character/word transitions to
/// full opacity as the cursor passes it. Works identically for letter
/// and word animation types.
class RevealText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final AnimationConfig config;
  final void Function(AnimatedTextController)? onControllerCreated;

  /// Color of the sliding cursor. Defaults to [style.color].
  final Color? cursorColor;

  /// Opacity of unrevealed text (0.0–1.0). Defaults to 0.3.
  final double dimOpacity;

  const RevealText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    required this.config,
    this.onControllerCreated,
    this.cursorColor,
    this.dimOpacity = 0.3,
  });

  static const _kCursorWidth = 2.5;

  @override
  Widget build(BuildContext context) {
    return AnimatedTextBase(
      text: text,
      style: style,
      textAlign: textAlign,
      config: config,
      onControllerCreated: onControllerCreated,
      builder: (context, animations, segments) {
        return AnimatedBuilder(
          // Rebuild whenever any segment animation ticks so the cursor
          // position stays in sync with the reveal front.
          animation: Listenable.merge(animations),
          builder: (context, _) {
            // Frontier: the highest-index segment that is actively animating
            // (0 < t < 1). The cursor lives at its leading edge.
            int frontier = -1;
            for (var i = 0; i < segments.length; i++) {
              final t = animations[i].value;
              if (t > 0.0 && t < 1.0) frontier = i;
            }

            final effectiveCursorColor = cursorColor ??
                style?.color ??
                DefaultTextStyle.of(context).style.color ??
                Colors.black87;

            // Cursor height tracks the line height of the text style.
            final cursorH =
                (style?.fontSize ?? 16) * (style?.height ?? 1.2);

            return Wrap(
              alignment: textAlign == TextAlign.center
                  ? WrapAlignment.center
                  : textAlign == TextAlign.end
                      ? WrapAlignment.end
                      : WrapAlignment.start,
              children: List.generate(segments.length, (index) {
                final t = animations[index].value.clamp(0.0, 1.0);
                final opacity =
                    (dimOpacity + (1.0 - dimOpacity) * t).clamp(dimOpacity, 1.0);

                return Stack(
                  // Clip.none so the cursor (a Positioned child) can paint
                  // slightly outside the segment bounds without being cut.
                  clipBehavior: Clip.none,
                  children: [
                    // Text at reveal opacity (dimOpacity -> 1.0)
                    Opacity(
                      opacity: opacity,
                      child: ParagraphText(segments[index], style: style),
                    ),
                    // Cursor: pinned to the leading edge of the frontier
                    // segment only. Uses Positioned so it never affects
                    // the Stack/Wrap layout sizing.
                    if (index == frontier)
                      Positioned(
                        right: -_kCursorWidth,
                        top: 0,
                        child: Container(
                          width: _kCursorWidth,
                          height: cursorH,
                          decoration: BoxDecoration(
                            color: effectiveCursorColor,
                            borderRadius:
                                BorderRadius.circular(_kCursorWidth / 2),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            );
          },
        );
      },
    );
  }
}
