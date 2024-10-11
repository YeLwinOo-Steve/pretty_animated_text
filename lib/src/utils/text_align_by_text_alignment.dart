import 'package:flutter/material.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';

TextAlign textAlignByTextAlign(TextAlignment align) => switch (align) {
      TextAlignment.start => TextAlign.start,
      TextAlignment.center => TextAlign.center,
      TextAlignment.end => TextAlign.end,
      _ => TextAlign.justify,
    };
