double intervalStepByOverlapFactor(int wordCount, double overlapFactor) {
  if (wordCount <= 1) return 1.0;

  // Each segment takes up a "duration unit"
  // With overlap, next one starts earlier, so the step is reduced
  // Total animation range needs to be covered within [0.0, 1.0]
  final double effectiveAnimationDuration =
      1.0 / (1 + (wordCount - 1) * (1 - overlapFactor));
  return effectiveAnimationDuration;
}
