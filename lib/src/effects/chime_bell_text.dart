import 'package:flutter/material.dart';
import 'dart:math';

import 'package:pretty_animated_text/src/dto/dto.dart';
import 'package:pretty_animated_text/src/enums/animation_type.dart';
import 'package:pretty_animated_text/src/utils/custom_curved_animation.dart';
import 'package:pretty_animated_text/src/utils/spring_curve.dart';
import 'package:pretty_animated_text/src/utils/text_transformation.dart';

class ChimeBellText extends StatefulWidget {
  final String text;
  final AnimationType type;
  final Duration duration;
  final TextStyle? textStyle;

  const ChimeBellText({
    super.key,
    required this.text,
    this.textStyle,
    this.type = AnimationType.word,
    this.duration = const Duration(milliseconds: 4000),
  });

  @override
  // ignore: library_private_types_in_public_api
  _ChimeBellTextState createState() => _ChimeBellTextState();
}

class _ChimeBellTextState extends State<ChimeBellText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _opacities;
  late List<Animation<double>> _rotations;
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
    const double overlapFactor = 0.5; // 50% overlap between animations

    // Calculate the interval step with overlap in mind
    final double intervalStep = wordCount > 1
        ? (1.0 / (wordCount + (wordCount - 1) * overlapFactor))
        : 1.0;
    // Creating the opacity and rotation animations with staggered delays.
    _opacities = _data.map((data) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        curvedAnimation(
          _controller,
          data.index,
          intervalStep,
          overlapFactor,
        ),
      );
    }).toList();

    _rotations = _data.map((data) {
      return Tween<double>(begin: 180, end: 0).animate(
        curvedAnimation(
          _controller,
          data.index,
          intervalStep,
          overlapFactor,
          curve: SpringCurve(),
        ),
      );
    }).toList();

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
      alignment: WrapAlignment.center,
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

  Opacity _animatedBuilder(EffectDto data, Widget? child) {
    return Opacity(
      opacity: _opacities[data.index].value,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.015) // Perspective effect
          ..rotateX(_rotations[data.index].value * pi / 360), // 3D rotation
        alignment: Alignment.topCenter,
        child: child,
      ),
    );
  }
}
