import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/physics.dart';

class SpringText extends StatefulWidget {
  final List<String> text;
  final Duration duration;
  const SpringText({
    required this.text,
    this.duration = const Duration(milliseconds: 4000),
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
  late List<Animation<double>> _springAnimations; // To store spring animations

  @override
  void initState() {
    super.initState();

    final wordCount = widget.text.length;

    // Define an overlap factor: this is how much each animation overlaps with the previous one.
    const double overlapFactor = 0.5; // 50% overlap between animations

    // Calculate the interval step with overlap in mind
    final double intervalStep = wordCount > 1
        ? (1.0 / (wordCount + (wordCount - 1) * overlapFactor))
        : 1.0;

    _controllers = List.generate(
      wordCount,
      (index) => AnimationController(
        vsync: this,
        duration:
            widget.duration, // Define total duration for each word's animation
      ),
    );

    // Create opacity animations with staggered starts (50% overlap)
    _opacities = List.generate(
      wordCount,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _controllers[index],
          curve: Interval(
            index *
                intervalStep *
                overlapFactor, // Start halfway through the previous word
            index * intervalStep * overlapFactor +
                intervalStep, // Finish at its own step
            curve: Curves.easeIn,
          ),
        ),
      ),
    );

    // Create rotation animations with the same staggered starts
    _rotations = List.generate(
      wordCount,
      (index) => Tween<double>(
        begin: 180.0,
        end: 0.0,
      ).animate(
        CurvedAnimation(
          parent: _controllers[index],
          curve: Interval(
            index *
                intervalStep *
                overlapFactor, // Start halfway through the previous word
            index * intervalStep * overlapFactor +
                intervalStep, // Ensure each word finishes at its own step
            curve: Curves.easeInOutBack,
          ),
        ),
      ),
    );

//  Add spring animation for each word
    _springAnimations = List.generate(
      widget.text.length,
      (index) {
        return Tween<double>(begin: 1, end: 0).animate(
          _controllers[index].drive(
            CurveTween(curve: _SpringCurve()), // Custom spring curve
          ),
        );
      },
    );

    // Start all animations
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
                  // Apply the spring animation for translation
                  ..translate(0.0, _springAnimations[index].value)
                  // Apply rotation
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

// Custom Spring Curve using Flutter's SpringSimulation
class _SpringCurve extends Curve {
  @override
  double transform(double t) {
    // A SpringSimulation that will simulate spring physics.
    final simulation = SpringSimulation(
      const SpringDescription(
        mass: 1,
        stiffness: 100, // Stiffness of the spring
        damping: 10, // Damping to control oscillation
      ),
      0, // Initial position
      1, // Target position
      0, // Initial velocity
    );

    return simulation.x(t); // The position of the spring at time t
  }
}
