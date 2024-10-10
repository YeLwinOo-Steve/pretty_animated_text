import 'package:flutter/material.dart';
import 'package:pretty_animated_text/src/dto/dto.dart';
import 'package:pretty_animated_text/src/enums/animation_type.dart';
import 'dart:math';
import 'package:pretty_animated_text/src/utils/spring_curve.dart';
import 'package:pretty_animated_text/src/utils/text_transformation.dart';

class SpringText extends StatefulWidget {
  final TextStyle? textStyle;
  final String text;
  final AnimationType type;
  final Duration duration;
  const SpringText({
    required this.text,
    this.textStyle,
    this.type = AnimationType.word,
    this.duration = const Duration(milliseconds: 4000),
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SpringTextState createState() => _SpringTextState();
}

class _SpringTextState extends State<SpringText> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _rotations;
  late final List<EffectDto> _data;
  late List<Animation<double>> _opacities;
  late List<Animation<double>> _springAnimations; // To store spring animations

  @override
  void initState() {
    super.initState();
    _data = switch (widget.type) {
      AnimationType.letter => widget.text.splittedLetters,
      _ => widget.text.splittedWords,
    };
    final wordCount = _data.length;

    // Define an overlap factor: this is how much each animation overlaps with the previous one.
    const double overlapFactor = 0.5; // 50% overlap between animations

    // Calculate the interval step with overlap in mind
    final double intervalStep = wordCount > 1
        ? (1.0 / (wordCount + (wordCount - 1) * overlapFactor))
        : 1.0;

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Create opacity animations with staggered starts (50% overlap)
    _opacities = _data.map((data) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            data.index *
                intervalStep *
                overlapFactor, // Start halfway through the previous word
            data.index * intervalStep * overlapFactor +
                intervalStep, // Finish at its own step
            curve: Curves.easeIn,
          ),
        ),
      );
    }).toList();

    // Create rotation animations with the same staggered starts
    _rotations = _data
        .map(
          (data) => Tween<double>(
            begin: 180.0,
            end: 0.0,
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(
                data.index *
                    intervalStep *
                    overlapFactor, // Start halfway through the previous word
                data.index * intervalStep * overlapFactor +
                    intervalStep, // Ensure each word finishes at its own step
                curve: Curves.easeInOutBack,
              ),
            ),
          ),
        )
        .toList();

//  Add spring animation for each word
    _springAnimations = _data.map(
      (data) {
        return Tween<double>(begin: 1, end: 0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: SpringCurve(),
          ),
        );
      },
    ).toList();

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

  Widget _animatedBuilder(EffectDto data, Widget? child) {
    return Opacity(
      opacity: _opacities[data.index].value,
      child: Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.identity()
          // Apply the spring animation for translation
          ..translate(0.0, _springAnimations[data.index].value)
          // Apply rotation
          ..rotateZ(_rotations[data.index].value * pi / 180),
        child: child,
      ),
    );
  }
}
