import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// A custom text widget that uses [ui.ParagraphBuilder] directly.
// This improves performance and provides better glyph-level customization.
class ParagraphText extends LeafRenderObjectWidget {
  final String text;
  final TextStyle? style;

  const ParagraphText(
    this.text, {
    super.key,
    this.style,
  });

  @override
  RenderParagraphText createRenderObject(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle? effectiveStyle = style;
    if (style == null || style!.inherit) {
      effectiveStyle = defaultTextStyle.style.merge(style);
    }
    if (MediaQuery.maybeOf(context)?.boldText ?? false) {
      effectiveStyle =
          effectiveStyle!.merge(const TextStyle(fontWeight: FontWeight.bold));
    }

    return RenderParagraphText(
      text: text,
      style: effectiveStyle,
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
      textScaler: MediaQuery.maybeTextScalerOf(context) ?? TextScaler.noScaling,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderParagraphText renderObject) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle? effectiveStyle = style;
    if (style == null || style!.inherit) {
      effectiveStyle = defaultTextStyle.style.merge(style);
    }
    if (MediaQuery.maybeOf(context)?.boldText ?? false) {
      effectiveStyle =
          effectiveStyle!.merge(const TextStyle(fontWeight: FontWeight.bold));
    }

    renderObject
      ..text = text
      ..style = effectiveStyle
      ..textDirection = Directionality.maybeOf(context) ?? TextDirection.ltr
      ..textScaler =
          MediaQuery.maybeTextScalerOf(context) ?? TextScaler.noScaling;
  }
}

class RenderParagraphText extends RenderBox {
  String _text;
  TextStyle? _style;
  TextDirection _textDirection;
  TextScaler _textScaler;
  ui.Paragraph? _paragraph;

  RenderParagraphText({
    required String text,
    TextStyle? style,
    required TextDirection textDirection,
    required TextScaler textScaler,
  })  : _text = text,
        _style = style,
        _textDirection = textDirection,
        _textScaler = textScaler;

  String get text => _text;
  set text(String value) {
    if (_text == value) return;
    _text = value;
    _markNeedsParagraphStyle();
  }

  TextStyle? get style => _style;
  set style(TextStyle? value) {
    if (_style == value) return;
    _style = value;
    _markNeedsParagraphStyle();
  }

  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    _markNeedsParagraphStyle();
  }

  TextScaler get textScaler => _textScaler;
  set textScaler(TextScaler value) {
    if (_textScaler == value) return;
    _textScaler = value;
    _markNeedsParagraphStyle();
  }

  void _markNeedsParagraphStyle() {
    _paragraph = null;
    markNeedsLayout();
    markNeedsPaint();
  }

  void _buildParagraph() {
    if (_paragraph != null) return;

    final builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textDirection: _textDirection,
      ),
    );

    if (_style != null) {
      // Apply the TextScaler directly to the font size
      final fontSize = _style!.fontSize ?? 14.0;
      final scaledFontSize = _textScaler.scale(fontSize);
      builder
          .pushStyle(_style!.copyWith(fontSize: scaledFontSize).getTextStyle());
    }

    builder.addText(_text);
    _paragraph = builder.build();
    _paragraph!.layout(const ui.ParagraphConstraints(width: double.infinity));
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    _buildParagraph();
    return _paragraph!.minIntrinsicWidth;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    _buildParagraph();
    return _paragraph!.maxIntrinsicWidth;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    _buildParagraph();
    return _paragraph!.height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    _buildParagraph();
    return _paragraph!.height;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    _buildParagraph();
    return constraints.constrain(Size(
      _paragraph!.maxIntrinsicWidth,
      _paragraph!.height,
    ));
  }

  @override
  void performLayout() {
    _buildParagraph();
    size = constraints.constrain(Size(
      _paragraph!.maxIntrinsicWidth,
      _paragraph!.height,
    ));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _buildParagraph();
    context.canvas.drawParagraph(_paragraph!, offset);
  }
}
