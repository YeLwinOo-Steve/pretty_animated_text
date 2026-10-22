// Glyph-count scaling benchmark. Skipped by default (see dart_test.yaml).
// Run with:
//   flutter test test/perf/glyph_perf_test.dart --run-skipped
// Prints one `PERF {json}` line per (effect, glyph count) sample.
@Tags(['perf'])
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';

const _lorem =
    'Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod '
    'tempor incididunt ut labore et dolore magna aliqua Ut enim ad minim veniam ';

String _textOf(int glyphs) {
  final buf = StringBuffer();
  while (buf.length < glyphs) {
    buf.write(_lorem);
  }
  return buf.toString().substring(0, glyphs);
}

const _style = TextStyle(fontSize: 16, color: Colors.black);
const _sizes = [10, 50, 100, 250, 500, 1000, 2000];
const _warmupFrames = 3;
const _measuredFrames = 20;

typedef _Builder = Widget Function(String text, AnimationConfig config);

final Map<String, _Builder> _effects = {
  'Baseline (single Text + Fade)': (t, c) => _BaselineFade(text: t),
  'BlurText': (t, c) => BlurText(text: t, style: _style, config: c),
  'ScaleText': (t, c) => ScaleText(text: t, style: _style, config: c),
  'OffsetText': (t, c) => OffsetText(text: t, style: _style, config: c),
  'SpringText': (t, c) => SpringText(text: t, style: _style, config: c),
  'RotateText': (t, c) => RotateText(text: t, style: _style, config: c),
  'ChimeBellText': (t, c) => ChimeBellText(text: t, style: _style, config: c),
  'SlideText': (t, c) => SlideText(text: t, style: _style, config: c),
  'ScrambleText': (t, c) => ScrambleText(text: t, style: _style, config: c),
  'RevealText': (t, c) => RevealText(text: t, style: _style, config: c),
  'GlitchText': (t, c) => GlitchText(text: t, style: _style, config: c),
  'SquashBounceText': (t, c) =>
      SquashBounceText(text: t, style: _style, config: c),
  'GravityText': (t, c) => SizedBox(
        width: 1200,
        height: 800,
        child: GravityText(text: t, style: _style, config: c),
      ),
};

class _BaselineFade extends StatefulWidget {
  const _BaselineFade({required this.text});
  final String text;
  @override
  State<_BaselineFade> createState() => _BaselineFadeState();
}

class _BaselineFadeState extends State<_BaselineFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 5))
        ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _c, child: Text(widget.text, style: _style));
}

int _renderObjectCount(WidgetTester tester) {
  var count = 0;
  void visit(RenderObject r) {
    count++;
    r.visitChildren(visit);
  }

  visit(tester.binding.renderViews.first);
  return count;
}

double _median(List<double> xs) {
  final s = [...xs]..sort();
  return s[s.length ~/ 2];
}

double _p90(List<double> xs) {
  final s = [...xs]..sort();
  return s[((s.length - 1) * 0.9).round()];
}

void main() {
  // Long run: frame time over a full playthrough, and the cost of
  // the frame where the status flips to completed (fans out to every status
  // listener that accumulated on the controller).
  for (final entry in {
    'ScaleText': _effects['ScaleText']!,
    'SquashBounceText': _effects['SquashBounceText']!,
  }.entries) {
    testWidgets('longrun ${entry.key}', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // 300 letters @ 40ms, overlap 0.5 -> 40 * (1 + 299 * 0.5) = 6020ms.
      const glyphs = 300;
      const config = AnimationConfig(duration: Duration(milliseconds: 40));
      var completedAtFrame = -1;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: entry.value(_textOf(glyphs), config.copyWith(
              onComplete: (_) => completedAtFrame = -2,
            )),
          ),
        ),
      ));
      final samples = <Map<String, Object>>[];
      final frames = <double>[];
      for (var i = 0; i < 420; i++) {
        final sw = Stopwatch()..start();
        await tester.pump(const Duration(milliseconds: 16));
        sw.stop();
        frames.add(sw.elapsedMicroseconds / 1000.0);
        if (completedAtFrame == -2) completedAtFrame = i;
        if (i % 30 == 29) {
          samples.add({
            'frame': i + 1,
            'frameMs': _median(frames.sublist(frames.length - 30)),
          });
        }
      }
      // ignore: avoid_print
      print('LONGRUN ${jsonEncode({
            'effect': entry.key,
            'glyphs': glyphs,
            'completedAtFrame': completedAtFrame,
            'completionFrameMs':
                completedAtFrame >= 0 ? frames[completedAtFrame] : null,
            'medianFrameMs': _median(frames),
            'samples': samples,
          })}');
      await tester.pumpWidget(const SizedBox());
    });
  }

  for (final mode in [AnimationType.letter, AnimationType.word]) {
    for (final entry in _effects.entries) {
      for (final glyphs in _sizes) {
        // Word mode is only interesting for the per-segment effects.
        if (mode == AnimationType.word &&
            !{'BlurText', 'ScaleText', 'OffsetText', 'SquashBounceText'}
                .contains(entry.key)) {
          continue;
        }
        testWidgets('${entry.key} ${mode.name} $glyphs', (tester) async {
          tester.view.physicalSize = const Size(1200, 800);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          final text = _textOf(glyphs);
          final config = AnimationConfig(
            duration: const Duration(milliseconds: 500),
            type: mode,
          );

          var curvedCreated = 0;
          var curvedDisposed = 0;
          void onAlloc(ObjectEvent e) {
            if (e.object is! CurvedAnimation) return;
            if (e is ObjectCreated) curvedCreated++;
            if (e is ObjectDisposed) curvedDisposed++;
          }

          final mountSw = Stopwatch()..start();
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: entry.value(text, config),
              ),
            ),
          ));
          mountSw.stop();

          for (var i = 0; i < _warmupFrames; i++) {
            await tester.pump(const Duration(milliseconds: 16));
          }

          FlutterMemoryAllocations.instance.addListener(onAlloc);
          final frames = <double>[];
          for (var i = 0; i < _measuredFrames; i++) {
            final sw = Stopwatch()..start();
            await tester.pump(const Duration(milliseconds: 16));
            sw.stop();
            frames.add(sw.elapsedMicroseconds / 1000.0);
          }
          FlutterMemoryAllocations.instance.removeListener(onAlloc);

          final segments = mode == AnimationType.letter
              ? text.length
              : RegExp(r'\S+\s*').allMatches(text).length;
          final result = {
            'effect': entry.key,
            'mode': mode.name,
            'glyphs': glyphs,
            'segments': segments,
            'mountMs': mountSw.elapsedMicroseconds / 1000.0,
            'frameMedianMs': _median(frames),
            'frameP90Ms': _p90(frames),
            'elements': tester.allElements.length,
            'renderObjects': _renderObjectCount(tester),
            'curvedCreatedPerFrame': curvedCreated / _measuredFrames,
            'curvedLeakedPerFrame':
                (curvedCreated - curvedDisposed) / _measuredFrames,
          };
          // ignore: avoid_print
          print('PERF ${jsonEncode(result)}');

          // Unmount before the test ends so pending timers/tickers stop.
          await tester.pumpWidget(const SizedBox());
        });
      }
    }
  }
}
