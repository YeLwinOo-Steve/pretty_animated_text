import 'package:flutter/material.dart';

CurvedAnimation curvedAnimation(
  AnimationController controller,
  int index,
  double intervalStep,
  double overlapFactor, {
  Curve curve = Curves.easeInOut,
}) {
  double start = index * intervalStep * (1 - overlapFactor);
  double end = start + intervalStep;
  print("\n interval step $intervalStep\n\n");
  print(
      'index $index\nstart --> $start\n end --> $end');

  return CurvedAnimation(
    parent: controller,
    curve: Interval(
      // index *
      //     intervalStep *
      //     overlapFactor, // Start halfway through the previous word
      // index * intervalStep * overlapFactor +
      //     intervalStep, // Finish at its own step
      start.clamp(0.0, 1.0), // Ensure the interval stays within bounds
      end.clamp(0.0, 1.0),
      curve: curve,
    ),
  );
}
