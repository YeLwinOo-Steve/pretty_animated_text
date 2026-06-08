import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpeedSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final ColorScheme colorScheme;

  const SpeedSelector({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    required this.colorScheme,
  });

  static const _options = [
    (label: 'Slow', emoji: '🐢'),
    (label: 'Medium', emoji: '🐕'),
    (label: 'Fast', emoji: '🐇'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_options.length, (index) {
          final opt = _options[index];
          final isSelected = index == selectedIndex;
          return Tooltip(
            message: '${opt.label} speed',
            child: InkWell(
              onTap: () => onChanged(index),
              borderRadius: BorderRadius.circular(100),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 8,
                              offset: Offset(0, 2)),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(opt.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 5),
                    Text(
                      opt.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
