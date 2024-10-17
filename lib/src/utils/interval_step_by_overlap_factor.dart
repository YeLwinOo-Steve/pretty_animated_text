double intervalStepByOverlapFactor(int wordCount, double overlapFactor) {
  return wordCount > 1 ? (0.95 / ((wordCount) * overlapFactor)) : 1.0; // had to do a little tweak (not precise calculation) but it works best when ~0.95
}
