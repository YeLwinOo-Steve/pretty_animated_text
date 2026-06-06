import 'package:flutter/widgets.dart';
import 'package:forge2d/forge2d.dart';

/// A static rectangular boundary of the gravity stage, expressed in metres.
typedef GravityWall = ({Vector2 center, double halfWidth, double halfHeight});

/// Computes the floor, side walls and ceiling that bound the gravity stage (left at x=0, right at x=width, ceiling // at y=0)
///
/// [size] - the stage size in pixels, [ppm] - the pixels-per-metre scale
/// [wallThicknessPx] the wall thickness in pixels
List<GravityWall> gravityWallLayout(
  Size size,
  double ppm,
  double wallThicknessPx,
) {
  final w = size.width / ppm;
  final h = size.height / ppm;
  final t = wallThicknessPx / ppm;

  return [
    // floor
    (center: Vector2(w / 2, h + t / 2), halfWidth: w / 2 + t, halfHeight: t / 2),
    // left wall
    (center: Vector2(-t / 2, h / 2), halfWidth: t / 2, halfHeight: h / 2 + t),
    // right wall
    (center: Vector2(w + t / 2, h / 2), halfWidth: t / 2, halfHeight: h / 2 + t),
    // ceiling
    (center: Vector2(w / 2, -t / 2), halfWidth: w / 2 + t, halfHeight: t / 2),
  ];
}
