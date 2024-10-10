import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';
import 'package:pretty_animated_text/src/dto/dto.dart';
import 'package:pretty_animated_text/src/utils/text_transformation.dart';

class BlurText extends StatefulWidget {
  final String text;
  final AnimationType type;
  final Duration duration;
  final TextStyle? textStyle;
  const BlurText({
    super.key,
    required this.text,
    this.textStyle,
    this.type = AnimationType.word,
    this.duration = const Duration(milliseconds: 4000),
  });

  @override
  State<BlurText> createState() => _BlurTextState();
}

class _BlurTextState extends State<BlurText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _opacities;
  late List<Animation<double>> _blurSigmaList;
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

    // Creating the opacity animation with staggered delays.
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

    // Creating the blur sigma value animation
    _blurSigmaList = _data.map((data) {
      return Tween<double>(begin: 10.0, end: 0.0).animate(
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
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Text.rich(
          TextSpan(
            children: _data
                .map(
                  (data) => WidgetSpan(
                    child: Opacity(
                      opacity: _opacities[data.index].value,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: _blurSigmaList[data.index].value,
                          sigmaY: _blurSigmaList[data.index].value,
                          tileMode: TileMode.decal,
                        ),
                        child: Text(data.text,
                            style: const TextStyle(fontSize: 40)),
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
