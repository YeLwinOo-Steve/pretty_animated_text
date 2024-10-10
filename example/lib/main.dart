import 'package:flutter/material.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';

void main() {
  runApp(
    const MaterialApp(
      // home: ScaleTextDemo(),
      home: RotateTextDemo(),
    ),
  );
}

class ChimeBellDemo extends StatelessWidget {
  const ChimeBellDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.repeat),
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: ChimeBellText(
            text:
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus molestie ullamcorper libero ut feugiat.',
            duration: Duration(seconds: 10),
            type: AnimationType.word,
            textStyle: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class SpringDemo extends StatelessWidget {
  const SpringDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: SpringText(
            text:
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus molestie ullamcorper libero ut feugiat.',
            duration: Duration(seconds: 10),
            type: AnimationType.word,
            textStyle: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class ScaleTextDemo extends StatelessWidget {
  const ScaleTextDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: ScaleText(
            text:
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus molestie ullamcorper libero ut feugiat.',
            duration: Duration(seconds: 10),
            type: AnimationType.word,
            textStyle: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class RotateTextDemo extends StatelessWidget {
  const RotateTextDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: RotateText(
            text:
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus molestie ullamcorper libero ut feugiat.',
            duration: Duration(seconds: 50),
            type: AnimationType.letter,
            textStyle: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
