import 'package:forge2d/forge2d.dart';

/// Clamps [v] in place so its magnitude does not exceed [maxLength]
Vector2 clampVectorLength(Vector2 v, double maxLength) {
  if (v.length > maxLength) {
    v.scale(maxLength / v.length);
  }
  return v;
}
