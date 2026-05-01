import 'package:flutter/material.dart';

class TextAlignToggle extends StatelessWidget {
  final TextAlign selected;
  final ValueChanged<TextAlign> onChanged;
  final ColorScheme colorScheme;

  const TextAlignToggle({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.colorScheme,
  });

  static const _options = [
    (value: TextAlign.start, icon: Icons.format_align_left, label: 'Start'),
    (value: TextAlign.center, icon: Icons.format_align_center, label: 'Center'),
    (value: TextAlign.end, icon: Icons.format_align_right, label: 'End'),
    (value: TextAlign.justify, icon: Icons.format_align_justify, label: 'Justify'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _options.map((opt) {
          final isSelected = selected == opt.value;
          return Tooltip(
            message: opt.label,
            child: InkWell(
              onTap: () => onChanged(opt.value),
              borderRadius: BorderRadius.circular(100),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 8,
                              offset: Offset(0, 2)),
                        ]
                      : null,
                ),
                child: Icon(
                  opt.icon,
                  size: 18,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
