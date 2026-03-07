import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isPrimary ? colorScheme.primary : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isPrimary ? colorScheme.onPrimary : colorScheme.onSurface,
            size: 24,
          ),
        ),
      ),
    );
  }
}
