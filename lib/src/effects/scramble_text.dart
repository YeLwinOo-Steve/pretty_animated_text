import 'package:flutter/material.dart';
import 'package:pretty_animated_text/src/widgets/paragraph_text.dart';
import 'package:pretty_animated_text/src/animated_text_base.dart';
import 'package:pretty_animated_text/src/animated_text_controller.dart';
import 'package:pretty_animated_text/src/animation_config.dart';

const _kUpperChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const _kLowerChars = 'abcdefghijklmnopqrstuvwxyz';
const _kOtherChars = '0123456789!@#%&?';

/// Returns the display string for [original] at animation progress [t]
///
/// Phase 1 (t = 0 -> 0.5): all characters cycle through a case-matched pool
/// Phase 2 (t = 0.5 -> 1.0): characters resolve left-to-right
/// Spaces are always kept as-is
String _scrambleDisplay(String original, double t, int segIdx) {
  if (original.trim().isEmpty) return original;
  final resolvedCount =
      (original.length * ((t - 0.5) / 0.5).clamp(0.0, 1.0)).round();
  final buf = StringBuffer();
  for (var i = 0; i < original.length; i++) {
    final ch = original[i];
    if (ch == ' ' || i < resolvedCount) {
      buf.write(ch);
    } else {
      final code = ch.codeUnitAt(0);
      final String pool;
      if (code >= 65 && code <= 90) {
        pool = _kUpperChars;
      } else if (code >= 97 && code <= 122) {
        pool = _kLowerChars;
      } else {
        pool = _kOtherChars;
      }
      // 18 cycles per animation window gives a fast, readable scramble
      final idx = ((t * 18).floor() + i * 5 + segIdx * 13) % pool.length;
      buf.write(pool[idx]);
    }
  }
  return buf.toString();
}

/// A widget that animates text with a scramble effect - characters cycle
/// through random glyphs then resolve left-to-right into the final text
class ScrambleText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final AnimationConfig config;
  final void Function(AnimatedTextController)? onControllerCreated;

  const ScrambleText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    required this.config,
    this.onControllerCreated,
  });

  @override
  State<ScrambleText> createState() => _ScrambleTextState();
}

class _ScrambleTextState extends State<ScrambleText> {
  @override
  Widget build(BuildContext context) {
    return AnimatedTextBase(
      text: widget.text,
      style: widget.style,
      textAlign: widget.textAlign,
      config: widget.config,
      onControllerCreated: widget.onControllerCreated,
      builder: (context, animations, segments) {

        return Wrap(
          alignment: widget.textAlign == TextAlign.center
              ? WrapAlignment.center
              : widget.textAlign == TextAlign.end
                  ? WrapAlignment.end
                  : WrapAlignment.start,
          children: List.generate(segments.length, (index) {
            final opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animations[index],
                curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
              ),
            );

            return Stack(
              // Clip.none: wider scramble chars paint past their slot without
              // being cut.
              clipBehavior: Clip.none,
              children: [
                // Ghost: non-positioned -> determines Stack (and Wrap slot)
                // size to exactly the original segment width. Never changes,
                // so the Wrap layout is stable every frame
                Opacity(
                  opacity: 0.0,
                  child: ParagraphText(segments[index], style: widget.style),
                ),
                // Scramble content: Positioned -> excluded from Stack sizing,
                // free to render at its natural width without shaking the
                // layout or getting clipped
                Positioned(
                  left: 0,
                  top: 0,
                  child: AnimatedBuilder(
                    animation: animations[index],
                    builder: (context, _) {
                      final t = animations[index].value;
                      return Opacity(
                        opacity: opacityAnim.value.clamp(0.0, 1.0),
                        child: ParagraphText(
                          _scrambleDisplay(segments[index], t, index),
                          style: widget.style,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }
}
