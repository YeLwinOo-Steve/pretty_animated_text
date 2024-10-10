import 'package:flutter/material.dart';

CurvedAnimation curvedAnimation(
  AnimationController controller,
  int index,
  double intervalStep,
  double overlapFactor, {
  Curve curve = Curves.easeInOut,
}) =>
    CurvedAnimation(
      parent: controller,
      curve: Interval(
        index *
            intervalStep *
            overlapFactor, // Start halfway through the previous word
        index * intervalStep * overlapFactor +
            intervalStep, // Finish at its own step
        curve: curve,
      ),
    );
