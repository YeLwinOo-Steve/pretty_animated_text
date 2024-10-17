int getTotalDuration({
  required int wordCount,
  required Duration duration,
  required double overlapFactor,
}) =>
    (wordCount * duration.inMilliseconds * overlapFactor).toInt();
