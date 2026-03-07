import 'package:flutter/material.dart';

class ModeToggleRound extends StatelessWidget {
  final bool isWordMode;
  final ValueChanged<bool> onChanged;
  final ColorScheme colorScheme;

  const ModeToggleRound({
    super.key,
    required this.isWordMode,
    required this.onChanged,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleItem(
            text: 'Letters',
            isSelected: !isWordMode,
            onTap: () => onChanged(false),
            colorScheme: colorScheme,
          ),
          _ToggleItem(
            text: 'Words',
            isSelected: isWordMode,
            onTap: () => onChanged(true),
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _ToggleItem({
    required this.text,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color:
                isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
