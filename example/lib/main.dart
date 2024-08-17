import 'package:flutter/material.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';

void main() {
  runApp(const ChimeBellDemo());
}

class ChimeBellDemo extends StatelessWidget {
  const ChimeBellDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: ChimeBellText(
            text: 'Hello Pretty Chimebell Effect!',
          ),
        ),
      ),
    );
  }
}
