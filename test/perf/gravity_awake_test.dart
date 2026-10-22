import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';

void main() {
  for (final n in [10, 50, 100, 250, 500, 1000, 2000]) {
    testWidgets('gravity awake $n', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final text = List.filled(n, 'a').join();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 800,
            child: GravityText(
              text: text,
              style: const TextStyle(fontSize: 16),
              config: const AnimationConfig(duration: Duration(milliseconds: 1)),
            ),
          ),
        ),
      ));
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final frames = <double>[];
      for (var i = 0; i < 20; i++) {
        final sw = Stopwatch()..start();
        await tester.pump(const Duration(milliseconds: 16));
        frames.add(sw.elapsedMicroseconds / 1000.0);
      }
      frames.sort();
      // ignore: avoid_print
      print('GRAVITY ${jsonEncode({'glyphs': n, 'frameMedianMs': frames[10], 'frameP90Ms': frames[18]})}');
      await tester.pumpWidget(const SizedBox());
    });
  }
}
