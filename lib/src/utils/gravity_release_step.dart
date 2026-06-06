/// Delay (in seconds) between consecutive segments being released to fall
double gravityReleaseStep(Duration duration, double overlapFactor) {
  final base = duration.inMilliseconds / 1000.0;
  final step = base * (1 - overlapFactor);
  return step > 0 ? step : base;
}
