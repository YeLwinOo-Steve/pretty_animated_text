import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';

const _loremText =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus molestie ullamcorper libero ut feugiat.';
const _style = TextStyle(
  fontSize: 40,
  fontWeight: FontWeight.bold,
);
const letterAnimationDuration = Duration(seconds: 100);
const wordAnimationDuration = Duration(seconds: 10);

void main() {
  runApp(
    const MaterialApp(
      home: HomeWidget(),
    ),
  );
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({
    super.key,
  });

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  int selectedValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pretty Animated Text'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CupertinoSegmentedControl<int>(
              children: const {
                0: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
                  child: Text('Letters'),
                ),
                1: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
                  child: Text('Words'),
                ),
              },
              groupValue: selectedValue,
              onValueChanged: (int value) {
                setState(() {
                  selectedValue = value;
                });
              },
            ),
            Expanded(
              child: selectedValue == 0
                  ? PageView(
                      children: const [
                        SpringDemo(),
                        ChimeBellDemo(),
                        ScaleTextDemo(),
                        RotateTextDemo(),
                        BlurTextDemo(),
                        OffsetTextDemo(),
                      ],
                    )
                  : PageView(
                      children: const [
                        SpringDemo(
                          type: AnimationType.word,
                          duration: wordAnimationDuration,
                        ),
                        ChimeBellDemo(
                          type: AnimationType.word,
                          duration: wordAnimationDuration,
                        ),
                        ScaleTextDemo(
                          type: AnimationType.word,
                          duration: wordAnimationDuration,
                        ),
                        RotateTextDemo(
                          type: AnimationType.word,
                          duration: wordAnimationDuration,
                        ),
                        BlurTextDemo(
                          type: AnimationType.word,
                          duration: wordAnimationDuration,
                        ),
                        OffsetTextDemo(
                          type: AnimationType.word,
                          duration: wordAnimationDuration,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChimeBellDemo extends StatelessWidget {
  final AnimationType type;
  final Duration duration;
  const ChimeBellDemo({
    super.key,
    this.type = AnimationType.letter,
    this.duration = letterAnimationDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ChimeBellText(
        text: _loremText,
        duration: duration,
        type: type,
        textStyle: _style,
      ),
    );
  }
}

class SpringDemo extends StatelessWidget {
  final AnimationType type;
  final Duration duration;
  const SpringDemo({
    super.key,
    this.type = AnimationType.letter,
    this.duration = letterAnimationDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpringText(
        text: _loremText,
        duration: duration,
        type: type,
        textStyle: _style,
      ),
    );
  }
}

class ScaleTextDemo extends StatelessWidget {
  final AnimationType type;
  final Duration duration;
  const ScaleTextDemo({
    super.key,
    this.type = AnimationType.letter,
    this.duration = letterAnimationDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleText(
        text: _loremText,
        duration: duration,
        type: type,
        textStyle: _style,
      ),
    );
  }
}

class RotateTextDemo extends StatelessWidget {
  final AnimationType type;
  final Duration duration;
  const RotateTextDemo({
    super.key,
    this.type = AnimationType.letter,
    this.duration = letterAnimationDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotateText(
        text: _loremText,
        duration: duration,
        type: type,
        textStyle: _style,
      ),
    );
  }
}

class BlurTextDemo extends StatelessWidget {
  final AnimationType type;
  final Duration duration;
  const BlurTextDemo({
    super.key,
    this.type = AnimationType.letter,
    this.duration = letterAnimationDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlurText(
        text: _loremText,
        duration: duration,
        type: type,
        textStyle: _style,
      ),
    );
  }
}

class OffsetTextDemo extends StatelessWidget {
  final AnimationType type;
  final Duration duration;
  const OffsetTextDemo({
    super.key,
    this.type = AnimationType.letter,
    this.duration = letterAnimationDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OffsetText(
        text: _loremText,
        duration: duration,
        type: type,
        textStyle: _style,
      ),
    );
  }
}
