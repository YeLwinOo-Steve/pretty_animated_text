import 'package:flutter/material.dart';
import 'package:pretty_animated_text/src/enums/text_alignment.dart';

WrapAlignment wrapAlignmentByTextAlign(TextAlignment align) => switch (align) {
      TextAlignment.start => WrapAlignment.start,
      TextAlignment.center => WrapAlignment.center,
      TextAlignment.end => WrapAlignment.end,
      TextAlignment.spaceAround => WrapAlignment.spaceAround,
      TextAlignment.spaceBetween => WrapAlignment.spaceBetween,
      TextAlignment.spaceEvenly => WrapAlignment.spaceEvenly,
    };
