import 'package:flutter/material.dart';
import '../core/constants.dart';

class ControlButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final ColorScheme colorScheme;
  final bool isPrimary;

  const ControlButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.colorScheme,
    this.isPrimary = false,
  });

  @override
  State<ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<ControlButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          transform: Matrix4.diagonal3Values(
              _pressed ? 0.90 : 1.0, _pressed ? 0.90 : 1.0, 1.0),
          transformAlignment: Alignment.center,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF818CF8), Color(0xFF6366F1)],
                  )
                : null,
            color: widget.isPrimary ? null : Colors.transparent,
            shape: BoxShape.circle,
            boxShadow: widget.isPrimary
                ? (_pressed ? kPlayButtonPressedShadows : kPlayButtonShadows)
                : null,
          ),
          child: Icon(
            widget.icon,
            color: widget.isPrimary
                ? Colors.white
                : widget.colorScheme.onSurface,
            size: 24,
          ),
        ),
      ),
    );
  }
}
