import 'package:flutter/rendering.dart';

/// Returns the smallest [Rect] that encloses all [boxes], or `null` when the
/// list is empty
//  Used to find the pixel bounds of a selected text segment
Rect? boundingRectOfBoxes(List<TextBox> boxes) {
  if (boxes.isEmpty) return null;
  var rect = boxes.first.toRect();
  for (final b in boxes.skip(1)) {
    rect = rect.expandToInclude(b.toRect());
  }
  return rect;
}
