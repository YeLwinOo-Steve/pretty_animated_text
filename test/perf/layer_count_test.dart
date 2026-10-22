import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';

const _s = TextStyle(fontSize: 16);
final _effects = <String, Widget Function(String, AnimationConfig)>{
  'BlurText': (t, c) => BlurText(text: t, style: _s, config: c),
  'ScaleText': (t, c) => ScaleText(text: t, style: _s, config: c),
  'OffsetText': (t, c) => OffsetText(text: t, style: _s, config: c),
  'SpringText': (t, c) => SpringText(text: t, style: _s, config: c),
  'RotateText': (t, c) => RotateText(text: t, style: _s, config: c),
  'ChimeBellText': (t, c) => ChimeBellText(text: t, style: _s, config: c),
  'SlideText': (t, c) => SlideText(text: t, style: _s, config: c),
  'ScrambleText': (t, c) => ScrambleText(text: t, style: _s, config: c),
  'RevealText': (t, c) => RevealText(text: t, style: _s, config: c),
  'GlitchText': (t, c) => GlitchText(text: t, style: _s, config: c),
  'SquashBounceText': (t, c) => SquashBounceText(text: t, style: _s, config: c),
};

void main() {
  for (final e in _effects.entries) {
    testWidgets('layers ${e.key}', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final text = List.filled(5, 'Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua ').join().substring(0, 500);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: e.value(text, const AnimationConfig(duration: Duration(milliseconds: 40))),
          ),
        ),
      ));
      // 40ms * (1 + 499*0.5) ~= 10s; sample mid-flight at ~3s.
      for (var i = 0; i < 180; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      var layers = 0;
      final kinds = <String, int>{};
      void visit(Layer l) {
        layers++;
        kinds.update(l.runtimeType.toString(), (v) => v + 1, ifAbsent: () => 1);
        if (l is ContainerLayer) {
          var c = l.firstChild;
          while (c != null) {
            visit(c);
            c = c.nextSibling;
          }
        }
      }
      visit(tester.binding.renderView.debugLayer!);
      // ignore: avoid_print
      print('LAYERS ${jsonEncode({'effect': e.key, 'glyphs': 500, 'layers': layers, 'kinds': kinds})}');
      await tester.pumpWidget(const SizedBox());
    });
  }
}
