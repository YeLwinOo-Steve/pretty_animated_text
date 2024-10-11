import 'package:flutter/material.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';

Tween<double> doubleTweenByRotateType(RotateAnimationType direction) =>
    switch (direction) {
      RotateAnimationType.clockwise => Tween<double>(begin: 0.0, end: 360.0),
      RotateAnimationType.anticlockwise =>
        Tween<double>(begin: 360.0, end: 0.0),
    };
