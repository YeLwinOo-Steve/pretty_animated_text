import 'package:flutter/material.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';

class AnimationDemoItem {
  final String title;
  final Widget Function(void Function(AnimatedTextController)) buildLetter;
  final Widget Function(void Function(AnimatedTextController)) buildWord;

  AnimationDemoItem({
    required this.title,
    required this.buildLetter,
    required this.buildWord,
  });
}
