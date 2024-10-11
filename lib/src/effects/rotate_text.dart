import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';
import 'package:pretty_animated_text/src/constants/constants.dart';
import 'package:pretty_animated_text/src/dto/dto.dart';
import 'package:pretty_animated_text/src/utils/custom_curved_animation.dart';
import 'package:pretty_animated_text/src/utils/double_tween_by_rotate_type.dart';
import 'package:pretty_animated_text/src/utils/interval_step_by_overlap_factor.dart';
import 'package:pretty_animated_text/src/utils/text_transformation.dart';
import 'package:pretty_animated_text/src/utils/wrap_alignment_by_text_align.dart';

class RotateText extends StatefulWidget {
  final String text;
  final AnimationType type;
  final double overlapFactor;
  final TextAlignment textAlignment;
  final RotateAnimationType direction;
  final Duration duration;
  final TextStyle? textStyle;

  const RotateText({
    super.key,
    required this.text,
    this.overlapFactor = kOverlapFactor,
    this.direction = RotateAnimationType.clockwise,
    this.textAlignment = TextAlignment.start,
    this.textStyle,
    this.type = AnimationType.word,
    this.duration = const Duration(milliseconds: 4000),
  });

  @override
  // ignore: library_private_types_in_public_api
  _RotateTextState createState() => _RotateTextState();
}

class _RotateTextState extends State<RotateText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _rotates;
  late List<Animation<double>> _opacities;
  late final List<EffectDto> _data;

  @override
  void initState() {
    super.initState();
    _data = switch (widget.type) {
      AnimationType.letter => widget.text.splittedLetters,
      _ => widget.text.splittedWords,
    };

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    final wordCount = _data.length;
    final double overlapFactor = widget.overlapFactor;

    final double intervalStep =
        intervalStepByOverlapFactor(wordCount, overlapFactor);

    // Creating the rotation animations with staggered delays.
    _rotates = _data.map((data) {
      return doubleTweenByRotateType(widget.direction).animate(
        curvedAnimation(
          _controller,
          data.index,
          intervalStep,
          overlapFactor,
        ),
      );
    }).toList();

    _opacities = _data
        .map(
          (data) => Tween<double>(begin: 0.0, end: 1.0).animate(
            curvedAnimation(
              _controller,
              data.index,
              intervalStep,
              overlapFactor,
            ),
          ),
        )
        .toList();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: wrapAlignmentByTextAlign(widget.textAlignment),
      children: _data
          .map(
            (dto) => AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return _animatedBuilder(dto, child);
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

  Widget _animatedBuilder(EffectDto data, Widget? child) {
    return Opacity(
      opacity: _opacities[data.index].value,
      child: Transform(
        transform: Matrix4.identity()
          ..rotateZ(_rotates[data.index].value * pi / 180), // 3D rotation
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
