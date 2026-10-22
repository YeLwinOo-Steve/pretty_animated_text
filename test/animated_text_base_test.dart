import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';

const _style = TextStyle(fontSize: 16);

final Map<String, Widget Function(String, AnimationConfig)> _tweenEffects = {
  'BlurText': (t, c) => BlurText(text: t, style: _style, config: c),
  'ScaleText': (t, c) => ScaleText(text: t, style: _style, config: c),
  'OffsetText': (t, c) => OffsetText(text: t, style: _style, config: c),
  'SpringText': (t, c) => SpringText(text: t, style: _style, config: c),
  'RotateText': (t, c) => RotateText(text: t, style: _style, config: c),
  'ChimeBellText': (t, c) => ChimeBellText(text: t, style: _style, config: c),
  'SlideText': (t, c) => SlideText(text: t, style: _style, config: c),
  'ScrambleText': (t, c) => ScrambleText(text: t, style: _style, config: c),
};

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

/// Counts live (created but not yet disposed) [CurvedAnimation]s while [body]
/// runs.
Future<int> _liveCurvesDuring(Future<void> Function() body) async {
  var live = 0;
  void onEvent(ObjectEvent e) {
    if (e.object is! CurvedAnimation) return;
    if (e is ObjectCreated) live++;
    if (e is ObjectDisposed) live--;
  }

  FlutterMemoryAllocations.instance.addListener(onEvent);
  try {
    await body();
  } finally {
    FlutterMemoryAllocations.instance.removeListener(onEvent);
  }
  return live;
}

void main() {
  group('per-frame CurvedAnimation leak', () {
    for (final entry in _tweenEffects.entries) {
      testWidgets('${entry.key} allocates no CurvedAnimation per frame',
          (tester) async {
        await tester.pumpWidget(_host(entry.value(
          'Hello animated world',
          const AnimationConfig(duration: Duration(milliseconds: 200)),
        )));

        final live = await _liveCurvesDuring(() async {
          for (var i = 0; i < 30; i++) {
            await tester.pump(const Duration(milliseconds: 16));
          }
        });
        expect(live, 0);

        await tester.pumpWidget(const SizedBox());
      });
    }

    testWidgets('segment curves are disposed on unmount and on update',
        (tester) async {
      const config = AnimationConfig(duration: Duration(milliseconds: 100));
      final live = await _liveCurvesDuring(() async {
        await tester.pumpWidget(_host(
          const ScaleText(text: 'abc', style: _style, config: config),
        ));
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pumpWidget(_host(
          const ScaleText(text: 'abcdef', style: _style, config: config),
        ));
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pumpWidget(const SizedBox());
      });
      expect(live, 0);
    });
  });

  group('didUpdateWidget', () {
    testWidgets('re-splits segments when text changes', (tester) async {
      const config = AnimationConfig(duration: Duration(milliseconds: 100));
      await tester.pumpWidget(_host(
        const ScaleText(text: 'ab', style: _style, config: config),
      ));
      expect(find.byType(ParagraphText), findsNWidgets(2));

      await tester.pumpWidget(_host(
        const ScaleText(text: 'abcde', style: _style, config: config),
      ));
      expect(find.byType(ParagraphText), findsNWidgets(5));
      final texts = tester
          .widgetList<ParagraphText>(find.byType(ParagraphText))
          .map((p) => p.text)
          .join();
      expect(texts, 'abcde');

      await tester.pumpAndSettle();
    });

    testWidgets('re-splits segments when the animation type changes',
        (tester) async {
      await tester.pumpWidget(_host(const ScaleText(
        text: 'hello big world',
        style: _style,
        config: AnimationConfig(duration: Duration(milliseconds: 100)),
      )));
      expect(find.byType(ParagraphText), findsNWidgets(15));

      await tester.pumpWidget(_host(const ScaleText(
        text: 'hello big world',
        style: _style,
        config: AnimationConfig(
          duration: Duration(milliseconds: 100),
          type: AnimationType.word,
        ),
      )));
      expect(find.byType(ParagraphText), findsNWidgets(3));

      await tester.pumpAndSettle();
    });

    testWidgets('keeps the controller on the full overlapped timeline',
        (tester) async {
      AnimatedTextController? controller;
      Widget scale(String text, int ms) => _host(ScaleText(
            text: text,
            style: _style,
            config: AnimationConfig(duration: Duration(milliseconds: ms)),
            onControllerCreated: (c) => controller = c,
          ));

      // 5 letters at 100ms with 0.5 overlap -> 100 * (1 + 4 * 0.5) = 300ms.
      await tester.pumpWidget(scale('abcde', 100));
      await tester.pump(const Duration(milliseconds: 290));
      expect(controller!.isCompleted, isFalse);
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller!.isCompleted, isTrue);

      // 9 letters at 200ms -> 200 * (1 + 8 * 0.5) = 1000ms, from a restart.
      await tester.pumpWidget(scale('abcdefghi', 200));
      await tester.pump(const Duration(milliseconds: 990));
      expect(controller!.isCompleted, isFalse);
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller!.isCompleted, isTrue);
    });

    testWidgets('passes new callbacks from an equal config to the controller',
        (tester) async {
      final calls = <String>[];
      AnimatedTextController? controller;
      // AnimationConfig equality ignores callbacks, so these two are "equal".
      Widget scale(String tag) => _host(ScaleText(
            text: 'abc',
            style: _style,
            config: AnimationConfig(
              duration: const Duration(milliseconds: 100),
              onComplete: (_) => calls.add(tag),
            ),
            onControllerCreated: (c) => controller = c,
          ));

      await tester.pumpWidget(scale('first'));
      await tester.pump(const Duration(milliseconds: 100));
      final progress = controller!.progress;
      await tester.pumpWidget(scale('second'));
      // Equal config: no restart.
      expect(controller!.progress, progress);
      await tester.pumpAndSettle();
      expect(calls, ['second']);
    });
  });

  group('rebuild scope', () {
    // 20 letters at 100ms, overlap 0.5: segment i runs over [50i, 50i + 100]ms
    // of a 1050ms timeline.
    const text = 'abcdefghijklmnopqrst';
    const config = AnimationConfig(duration: Duration(milliseconds: 100));

    Widget counting(List<int> segmentBuilds, {bool rebuildOnTick = false,
        void Function()? onBuilder}) {
      return _host(AnimatedTextBase(
        text: text,
        config: config,
        rebuildOnTick: rebuildOnTick,
        builder: (context, animations, segments) {
          onBuilder?.call();
          return Wrap(children: [
            for (var i = 0; i < segments.length; i++)
              AnimatedBuilder(
                animation: animations[i],
                builder: (context, _) {
                  segmentBuilds[i]++;
                  return Opacity(
                    opacity: animations[i].value.clamp(0.0, 1.0),
                    child: Text(segments[i]),
                  );
                },
              ),
          ]);
        },
      ));
    }

    testWidgets('builder runs once instead of on every tick', (tester) async {
      var builderCalls = 0;
      await tester.pumpWidget(counting(List.filled(text.length, 0),
          onBuilder: () => builderCalls++));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(builderCalls, 1);
      await tester.pumpAndSettle();
    });

    testWidgets('builder runs on every tick by default', (tester) async {
      // Backward compatibility: custom builders that read
      // animations[i].value directly must keep animating.
      var builderCalls = 0;
      double? lastValue;
      await tester.pumpWidget(_host(AnimatedTextBase(
        text: text,
        config: config,
        builder: (context, animations, segments) {
          builderCalls++;
          lastValue = animations[0].value;
          return Text(segments.join());
        },
      )));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(builderCalls, greaterThan(15));
      expect(lastValue, 1.0);
      await tester.pumpAndSettle();
    });

    testWidgets('rebuildOnTick calls the builder on every tick',
        (tester) async {
      var builderCalls = 0;
      await tester.pumpWidget(counting(List.filled(text.length, 0),
          rebuildOnTick: true, onBuilder: () => builderCalls++));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(builderCalls, greaterThan(15));
      await tester.pumpAndSettle();
    });

    testWidgets('segments that have not started do not rebuild',
        (tester) async {
      final builds = List.filled(text.length, 0);
      await tester.pumpWidget(counting(builds));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      // ~80ms in: only segments 0 and 1 are in flight.
      expect(builds[0], greaterThan(2));
      expect(builds.sublist(3), everyElement(1)); // initial build only
      await tester.pumpAndSettle();
    });

    testWidgets('finished segments stop rebuilding', (tester) async {
      final builds = List.filled(text.length, 0);
      await tester.pumpWidget(counting(builds));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 150)); // segment 0 done
      final settled = builds[0];
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(builds[0], settled);
      expect(builds[5], greaterThan(1)); // still animating
      await tester.pumpAndSettle();
    });

    testWidgets('every glyph reaches its final state', (tester) async {
      await tester.pumpWidget(_host(const ScaleText(
        text: 'hello world',
        style: _style,
        config: AnimationConfig(duration: Duration(milliseconds: 100)),
      )));
      await tester.pumpAndSettle();
      final opacities =
          tester.widgetList<Opacity>(find.byType(Opacity)).map((o) => o.opacity);
      expect(opacities, everyElement(1.0));
    });

    testWidgets('reverse returns every glyph to its start state',
        (tester) async {
      await tester.pumpWidget(_host(const ScaleText(
        text: 'hello world',
        style: _style,
        config: AnimationConfig(
          duration: Duration(milliseconds: 100),
          reverse: true,
        ),
      )));
      await tester.pumpAndSettle();
      final opacities =
          tester.widgetList<Opacity>(find.byType(Opacity)).map((o) => o.opacity);
      expect(opacities, everyElement(0.0));
    });
  });
}
