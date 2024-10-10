import 'dart:ui';

import 'package:flutter/material.dart';

class BlurText extends StatefulWidget {
  const BlurText({super.key});

  @override
  State<BlurText> createState() => _BlurTextState();
}

class _BlurTextState extends State<BlurText> {
  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus molestie ullamcorper libero ut feugiat.'
                .split('')
                .map(
                  (e) => WidgetSpan(
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10,tileMode: TileMode.decal),
                      child: Text(e, style: const TextStyle(fontSize: 40)),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}
