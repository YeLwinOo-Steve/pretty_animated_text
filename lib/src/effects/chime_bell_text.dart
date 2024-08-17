import 'package:flutter/material.dart';
import 'dart:math';

import 'package:pretty_animated_text/src/dto/dto.dart';
import 'package:pretty_animated_text/src/enums/animation_type.dart';

class ChimeBellText extends StatefulWidget {
  final String text;
  final AnimationType type;

  /// Chime Bell Effect for list of words
  List<ChimeBellDto> get splittedWords => text
      .split(' ')
      .indexed
      .map(
        (e) => ChimeBellDto(index: e.$1, text: '${e.$2} '),
      )
      .toList();

  /// Chime Bell Effect for list of letters
  List<ChimeBellDto> get splittedLetters => text
      .split('')
      .indexed
      .map((e) => ChimeBellDto(index: e.$1, text: e.$2))
      .toList();

  const ChimeBellText({
    super.key,
    required this.text,
    this.type = AnimationType.word,
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
  late final List<ChimeBellDto> _data;

  @override
  void initState() {
    super.initState();
    _data = switch (widget.type) {
      AnimationType.letter => widget.splittedLetters,
      _ => widget.splittedWords,
    };

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Creating the opacity and rotation animations with staggered delays.
    _opacities = widget.splittedLetters.map((data) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            data.index * 0.1,
            1.0,
            curve: Curves.easeIn,
          ),
        ),
      );
    }).toList();

    _rotations = _data.map((data) {
      return Tween<double>(begin: 180, end: 0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            data.index *
                0.08, // Delay equivalent to Swift's .delay for spring animation
            1.0,
            curve: Curves.elasticOut, // Mimicking spring-like bounce
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
    return Wrap(
      children: _data.map((data) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacities[data.index].value,
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.01) // Perspective effect
                  ..rotateX(
                      _rotations[data.index].value * pi / 360), // 3D rotation
                alignment: Alignment.topCenter,
                child: child,
              ),
            );
          },
          child: Text(
            data.text, // Replace with desired text
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }
}
