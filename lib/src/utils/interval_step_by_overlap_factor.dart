double intervalStepByOverlapFactor(int wordCount, double overlapFactor) {
  return wordCount > 1 ? (1.0 / ((wordCount) * overlapFactor)) : 1.0;
}
