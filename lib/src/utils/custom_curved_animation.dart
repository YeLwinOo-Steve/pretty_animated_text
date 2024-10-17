import 'package:flutter/material.dart';

CurvedAnimation curvedAnimation(
  AnimationController controller,
  int index,
  double intervalStep,
  double overlapFactor, {
  Curve curve = Curves.easeInOut,
}) {
  double start = index * intervalStep * (1 - overlapFactor); // start before the previous animation finishes
  double end = start + intervalStep; // finishes its own step
  return CurvedAnimation(
    parent: controller,
    curve: Interval(
      start.clamp(0.0, 1.0), // Ensure the interval stays within bounds
      end.clamp(0.0, 1.0),
      curve: curve,
    ),
  );
}
