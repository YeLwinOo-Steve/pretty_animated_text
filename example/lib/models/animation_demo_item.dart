import 'package:flutter/material.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';

/// Represents a single variation option for an animation demo.
class VariationOption<T> {
  final String? label;
  final IconData icon;
  final T value;

  const VariationOption({
    this.label,
    required this.icon,
    required this.value,
  });
}

class AnimationDemoItem {
  final String title;
  final Widget Function(
      void Function(AnimatedTextController) onCreated,
      int variationIndex,
      TextAlign textAlign) buildLetter;
  final Widget Function(
      void Function(AnimatedTextController) onCreated,
      int variationIndex,
      TextAlign textAlign) buildWord;

  /// The list of variation options for this animation.
  /// Empty means no variations are available.
  final List<VariationOption> variations;

  AnimationDemoItem({
    required this.title,
    required this.buildLetter,
    required this.buildWord,
    this.variations = const [],
  });

  bool get hasVariations => variations.isNotEmpty;
}
