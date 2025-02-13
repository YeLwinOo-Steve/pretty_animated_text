import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pretty_animated_text/animated_text_wrapper.dart';
import 'package:pretty_animated_text/src/utils/custom_curved_animation.dart';
import 'package:pretty_animated_text/src/utils/interval_step_by_overlap_factor.dart';
import 'package:pretty_animated_text/src/utils/text_align_by_text_alignment.dart';

/// A widget that animates text with a chime bell effect, making each character or word
/// appear with a 3D rotation and fade-in animation.
class BlurText extends AnimatedTextWrapper {
  const BlurText({
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
  });

  @override
  BlurTextState createState() => BlurTextState();
}

class BlurTextState extends AnimatedTextWrapperState<BlurText> {
  /// Controls the opacity animation for each text segment
  late List<Animation<double>> _opacities;

  /// Controls the rotation animation for each text segment
  late List<Animation<double>> _blurSigmaList;

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
          curve: Curves.easeIn,
        ),
      );
    }).toList();

    _blurSigmaList = data.map((item) {
      return Tween<double>(begin: 10.0, end: 0.0).animate(
        curvedAnimation(
          controller,
          item.index,
          intervalStep,
          widget.overlapFactor,
          curve: Curves.easeIn,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return RichText(
          textAlign: textAlignByTextAlign(widget.textAlignment),
          text: TextSpan(
            children: data
                .map(
                  (item) => WidgetSpan(
                    child: Opacity(
                      opacity: _opacities[item.index].value,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: _blurSigmaList[item.index].value,
                          sigmaY: _blurSigmaList[item.index].value,
                          tileMode: TileMode.decal,
                        ),
                        child: Text(
                          item.text,
                          style: widget.textStyle,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
