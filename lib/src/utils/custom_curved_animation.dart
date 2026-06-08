import 'package:flutter/material.dart';

CurvedAnimation curvedAnimation(
  AnimationController controller,
  int index,
  double intervalStep,
  double overlapFactor, {
  Curve curve = Curves.easeInOut,
}) {
  final double stepOverlap = intervalStep * (1 - overlapFactor);
  final double start = index * stepOverlap;
  final double end = start + intervalStep;

  return CurvedAnimation(
    parent: controller,
    curve: Interval(
      start.clamp(0.0, 1.0),
      end.clamp(0.0, 1.0),
      curve: curve,
    ),
  );
}
