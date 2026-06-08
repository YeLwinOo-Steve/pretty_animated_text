import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/animation_demo_item.dart';

class VariationSelector extends StatelessWidget {
  final List<VariationOption> variations;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final ColorScheme colorScheme;

  const VariationSelector({
    super.key,
    required this.variations,
    required this.selectedIndex,
    required this.onChanged,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    if (variations.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(variations.length, (index) {
          final variation = variations[index];
          final isSelected = index == selectedIndex;

          Widget button = InkWell(
            onTap: () => onChanged(index),
            borderRadius: BorderRadius.circular(100),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                  Icon(
                    variation.icon,
                    size: 18,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  if (variation.label != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      variation.label!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );

          if (variation.label != null) {
            button = Tooltip(message: variation.label!, child: button);
          }

          return button;
        }),
      ),
    );
  }
}
