double intervalStepByOverlapFactor(int wordCount, double overlapFactor) {
  return wordCount > 1
      ? (1.0 / (wordCount + (wordCount - 1) * overlapFactor))
      : 1.0;
}
