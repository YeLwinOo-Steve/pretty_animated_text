/// Frame delta time (in seconds) for a physics step, clamped to a stable range.
///
/// Returns a 1/60 s seed on the first frame ([lastElapsed] is zero) and caps
/// large gaps at 1/30 s so the simulation never takes an unstable giant step.
double simulationTimeStep(Duration elapsed, Duration lastElapsed) {
  if (lastElapsed == Duration.zero) return 1 / 60;
  return ((elapsed - lastElapsed).inMicroseconds / 1e6).clamp(0.0, 1 / 30);
}
