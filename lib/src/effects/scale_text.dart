import 'package:flutter/material.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';
import 'package:pretty_animated_text/src/constants/constants.dart';
import 'package:pretty_animated_text/src/dto/dto.dart';
import 'package:pretty_animated_text/src/utils/custom_curved_animation.dart';
import 'package:pretty_animated_text/src/utils/interval_step_by_overlap_factor.dart';
import 'package:pretty_animated_text/src/utils/spring_curve.dart';
import 'package:pretty_animated_text/src/utils/text_transformation.dart';
import 'package:pretty_animated_text/src/utils/wrap_alignment_by_text_align.dart';

class ScaleText extends StatefulWidget {
  final String text;
  final AnimationType type;
  final double overlapFactor;
  final Alignment alignment;
  final TextAlignment textAlignment;
  final Duration duration;
  final TextStyle? textStyle;

  const ScaleText({
    super.key,
    required this.text,
    this.overlapFactor = kOverlapFactor,
    this.alignment = Alignment.bottomCenter,
    this.textAlignment = TextAlignment.start,
    this.textStyle,
    this.type = AnimationType.word,
    this.duration = const Duration(milliseconds: 4000),
  });

  @override
  // ignore: library_private_types_in_public_api
  _ScaleTextState createState() => _ScaleTextState();
}

class _ScaleTextState extends State<ScaleText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _scales;
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

    // Calculate the interval step with overlap in mind
    final double intervalStep =
        intervalStepByOverlapFactor(wordCount, overlapFactor);
    // Creating the scale animations with staggered delays.
    _scales = _data.map((data) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
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
      alignment: wrapAlignmentByTextAlign(widget.textAlignment),
      children: _data
          .map(
            (dto) => AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => _animatedBuilder(dto, child),
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
    var scaleValue = _scales[data.index].value;
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.015) // Perspective effect
        ..scale(
          scaleValue,
          scaleValue,
        ), // 3D rotation
      alignment: widget.alignment,
      child: child,
    );
  }
}
