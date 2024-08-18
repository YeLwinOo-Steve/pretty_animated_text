import 'package:flutter/material.dart';
import 'dart:math';

class SpringText extends StatefulWidget {
  final List<String> text;

  const SpringText({
    required this.text,
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SpringTextState createState() => _SpringTextState();
}

class _SpringTextState extends State<SpringText> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _rotations;
  late List<Animation<double>> _opacities;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      widget.text.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2000),
      ),
    );

    _opacities = List.generate(
      widget.text.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _controllers[index],
          curve: Interval(
            index * 0.15,
            1.0,
            curve: Curves.easeIn,
          ),
        ),
      ),
    );

    _rotations = List.generate(
      widget.text.length,
      (index) => Tween<double>(
        begin: 180.0,
        end: 0.0,
      ).animate(
        CurvedAnimation(
          parent: _controllers[index],
          curve: Interval(
            index * 0.12,
            1.0,
            curve: Curves.easeInOutBack,
          ),
        ),
      ),
    );

    for (var controller in _controllers) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List.generate(widget.text.length, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Opacity(
              opacity: _opacities[index].value,
              child: Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.identity()
                  ..rotateZ(_rotations[index].value * pi / 180),
                child: child,
              ),
            );
          },
          child: Text(
            widget.text[index],
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }),
    );
  }
}
