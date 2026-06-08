int getTotalDuration({
  required int wordCount,
  required Duration duration,
  required double overlapFactor,
}) {
  if (wordCount <= 1) return duration.inMilliseconds;

  final double totalOverlapSteps = 1 + (wordCount - 1) * (1 - overlapFactor);
  return (duration.inMilliseconds * totalOverlapSteps).toInt();
}
