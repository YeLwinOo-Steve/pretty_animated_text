// Custom Spring Curve using Flutter's SpringSimulation
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class SpringCurve extends Curve {
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
