import 'package:flutter/material.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';

void main() {
  runApp(
    const MaterialApp(
      home: SpringDemo(),
    ),
  );
}

class ChimeBellDemo extends StatelessWidget {
  const ChimeBellDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: ChimeBellText(
          text: 'Hello Pretty Chimebell Effect This is testing you know!',
        ),
      ),
    );
  }
}

class SpringDemo extends StatelessWidget {
  const SpringDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SpringText(
          text:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus molestie ullamcorper libero ut feugiat.'
                  .split('')
                  .map((e) => '$e')
                  .toList(),
          duration: const Duration(seconds: 100),
        ),
      ),
    );
  }
}
