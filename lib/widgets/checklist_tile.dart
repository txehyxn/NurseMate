import 'package:flutter/material.dart';

import '../design_system/nursemate_design_system.dart';
import '../models/checklist_item.dart';

class ChecklistTile extends StatelessWidget {
  const ChecklistTile({
    super.key,
    required this.item,
    required this.isCompleted,
    required this.onChanged,
    this.accentColor = NurseMateColors.primary,
    this.iconBackgroundColor = NurseMateColors.primarySoft,
    this.checkButtonKey,
  });

  final ChecklistItem item;
  final bool isCompleted;
  final ValueChanged<bool> onChanged;
  final Color accentColor;
  final Color iconBackgroundColor;
  final Key? checkButtonKey;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: NurseMateMotion.fast,
      curve: NurseMateMotion.curve,
      decoration: BoxDecoration(
        color: isCompleted
            ? NurseMateColors.primarySoft.withValues(alpha: 0.68)
            : NurseMateColors.surface,
        borderRadius: BorderRadius.circular(NurseMateRadii.input),
        border: Border.all(
          color: isCompleted
              ? NurseMateColors.primary.withValues(alpha: 0.24)
              : NurseMateColors.border,
        ),
        boxShadow: NurseMateShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!isCompleted),
          borderRadius: BorderRadius.circular(NurseMateRadii.input),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? NurseMateColors.primarySoft
                        : iconBackgroundColor,
                    borderRadius: BorderRadius.circular(NurseMateRadii.small),
                  ),
                  child: Icon(
                    item.icon,
                    color: isCompleted ? NurseMateColors.primary : accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: NurseMateSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          color: isCompleted
                              ? NurseMateColors.textTertiary
                              : NurseMateColors.navy,
                          fontSize: 16,
                          height: 1.35,
                          fontWeight: FontWeight.w800,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: NurseMateColors.textTertiary,
                          decorationThickness: 1.5,
                        ),
                      ),
                      if (item.subtitle case final subtitle?) ...[
                        const SizedBox(height: NurseMateSpacing.xxs),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: isCompleted
                                ? NurseMateColors.textTertiary
                                : NurseMateColors.textSecondary,
                            fontSize: 13,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: NurseMateSpacing.sm),
                Semantics(
                  button: true,
                  checked: isCompleted,
                  label: '${item.title} 완료',
                  child: InkWell(
                    key: checkButtonKey,
                    customBorder: const CircleBorder(),
                    onTap: () => onChanged(!isCompleted),
                    child: AnimatedContainer(
                      duration: NurseMateMotion.fast,
                      curve: NurseMateMotion.curve,
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? NurseMateColors.primary
                            : NurseMateColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted
                              ? NurseMateColors.primary
                              : NurseMateColors.border,
                          width: 1.6,
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: NurseMateMotion.fast,
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                key: ValueKey('completed'),
                                color: Colors.white,
                                size: 25,
                              )
                            : const SizedBox(
                                key: ValueKey('incomplete'),
                                width: 1,
                                height: 1,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
