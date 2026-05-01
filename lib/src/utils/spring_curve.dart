// Custom Spring Curve using Flutter's SpringSimulation
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// A [Curve] that accurately replicates a physical spring simulation.
///
/// It mathematically calculates the physical position without clamping,
/// allowing for a natural, smooth overshoot and settle behavior.
class SpringCurve extends Curve {
  /// By default, parameters are tuned for a pleasant bounce effect.
  const SpringCurve({
    this.mass = 1.0,
    this.stiffness = 80.0,
    this.damping = 16.0,
    this.duration = 1.0,
  });

  /// The mass of the spring.
  final double mass;

  /// The stiffness of the spring.
  final double stiffness;

  /// The damping of the spring.
  final double damping;

  /// Used to map the parameter [t] into the time domain of the simulation.
  final double duration;

  @override
  double transformInternal(double t) {
    // Return precise endpoints
    if (t == 0.0) return 0.0;
    if (t == 1.0) return 1.0;

    // Creating this simulation on the fly is computationally very lightweight.
    // Use a looser tolerance than Flutter's default (1e-3) so [isDone] reports
    // convergence before the residual oscillation is large enough to render as
    // a visible shake on high-magnitude tweens (e.g. scale 0->1, rotation 180->0).
    final simulation = SpringSimulation(
      SpringDescription(
        mass: mass,
        stiffness: stiffness,
        damping: damping,
      ),
      0.0, // initial position
      1.0, // target position
      0.0, // initial velocity
      tolerance: const Tolerance(distance: 0.01, velocity: 0.05),
    );

    // Evaluate the simulation at the scaled elapsed time
    final time = t * duration;

    // Snap to the settled value once the simulation has effectively converged
    // to eliminate trailing micro-oscillation (perceived as "shake" at the end).
    if (simulation.isDone(time)) return 1.0;

    return simulation.x(time);
  }
}
