import 'package:flutter/material.dart';
import 'package:pretty_animated_text/src/enums/animation_type.dart';

extension AnimationPlaybackMode on AnimationController {
  void animationByMode(AnimationMode mode) => switch (mode) {
        AnimationMode.forward => forward(),
        AnimationMode.reverse => reverse(),
        AnimationMode.repeatNoReverse => repeat(),
        AnimationMode.repeatWithReverse => repeat(reverse: true),
      };
}
