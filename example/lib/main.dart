import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

const _loremText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';
const _style = TextStyle(
  fontSize: 40,
  fontWeight: FontWeight.bold,
);
const letterAnimationDuration = Duration(seconds: 30);
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
  final PageController letterController = PageController();
  final PageController wordController = PageController();
  int selectedValue = 0;
  final int length = 12;

  @override
  void dispose() {
    letterController.dispose();
    wordController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pretty Animated Text'),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              key: const ValueKey('pub.dev'),
              onPressed: () =>
                  _launchUrl('https://pub.dev/packages/pretty_animated_text'),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('assets/pub.png')),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              key: const ValueKey('github'),
              onPressed: () => _launchUrl(
                  'https://github.com/YeLwinOo-Steve/pretty_animated_text'),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('assets/github.png')),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _tabs(),
              if (selectedValue == 0) ...[
                Expanded(
                  flex: 9,
                  child: PageView(
                    controller: letterController,
                    children: const [
                      SpringDemo(),
                      ChimeBellDemo(),
                      ScaleTextDemo(),
                      RotateTextDemo(),
                      RotateTextDemo(
                        direction: RotateAnimationType.anticlockwise,
                      ),
                      BlurTextDemo(),
                      OffsetTextDemo(),
                      OffsetTextDemo(
                        slideType: SlideAnimationType.bottomTop,
                      ),
                      OffsetTextDemo(
                        slideType: SlideAnimationType.alternateTB,
                      ),
                      OffsetTextDemo(
                        slideType: SlideAnimationType.leftRight,
                      ),
                      OffsetTextDemo(
                        slideType: SlideAnimationType.rightLeft,
                      ),
                      OffsetTextDemo(
                        slideType: SlideAnimationType.alternateLR,
                      ),
                    ],
                  ),
                ),
                _pageIndicator(letterController),
              ] else ...[
                Expanded(
                  flex: 9,
                  child: PageView(
                    controller: wordController,
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
                      RotateTextDemo(
                        type: AnimationType.word,
                        direction: RotateAnimationType.anticlockwise,
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
                      OffsetTextDemo(
                        type: AnimationType.word,
                        slideType: SlideAnimationType.bottomTop,
                        duration: wordAnimationDuration,
                      ),
                      OffsetTextDemo(
                        type: AnimationType.word,
                        slideType: SlideAnimationType.alternateTB,
                        duration: wordAnimationDuration,
                      ),
                      OffsetTextDemo(
                        type: AnimationType.word,
                        slideType: SlideAnimationType.leftRight,
                        duration: wordAnimationDuration,
                      ),
                      OffsetTextDemo(
                        type: AnimationType.word,
                        slideType: SlideAnimationType.rightLeft,
                        duration: wordAnimationDuration,
                      ),
                      OffsetTextDemo(
                        type: AnimationType.word,
                        slideType: SlideAnimationType.alternateLR,
                        duration: wordAnimationDuration,
                      ),
                    ],
                  ),
                ),
                _pageIndicator(wordController),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _pageIndicator(PageController controller) {
    return Expanded(
      child: SmoothPageIndicator(
        controller: controller,
        count: length,
        effect: ScrollingDotsEffect(
          activeDotColor: Colors.indigo,
          dotColor: Colors.indigo.withOpacity(0.42),
          dotHeight: 8,
          dotWidth: 8,
        ),
        onDotClicked: (index) {
          controller.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  _tabs() {
    return SizedBox(
      width: double.maxFinite,
      child: CupertinoSegmentedControl<int>(
        children: const {
          0: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Text('Letters'),
          ),
          1: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Text('Words'),
          ),
        },
        groupValue: selectedValue,
        onValueChanged: (int value) {
          setState(() {
            selectedValue = value;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (selectedValue == 0) {
              letterController.jumpToPage(0);
            } else {
              wordController.jumpToPage(0);
            }
          });
        },
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
  final RotateAnimationType direction;
  final Duration duration;
  const RotateTextDemo({
    super.key,
    this.direction = RotateAnimationType.clockwise,
    this.type = AnimationType.letter,
    this.duration = letterAnimationDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotateText(
        text: _loremText,
        direction: direction,
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
  final SlideAnimationType slideType;
  final Duration duration;
  const OffsetTextDemo({
    super.key,
    this.type = AnimationType.letter,
    this.slideType = SlideAnimationType.topBottom,
    this.duration = letterAnimationDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OffsetText(
        text: _loremText,
        duration: duration,
        type: type,
        slideType: slideType,
        textStyle: _style,
      ),
    );
  }
}
