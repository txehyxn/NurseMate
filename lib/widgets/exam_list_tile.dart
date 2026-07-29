import 'package:flutter/material.dart';

import '../design_system/nursemate_design_system.dart';
import '../models/non_covered_exam.dart';
import 'price_text.dart';

class ExamListTile extends StatelessWidget {
  const ExamListTile({
    super.key,
    required this.exam,
    required this.favorite,
    required this.onTap,
    required this.onFavorite,
    this.showPrice = true,
  });

  final NonCoveredExam exam;
  final bool favorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final bool showPrice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NurseMateCard(
      radius: NurseMateRadii.button,
      padding: const EdgeInsets.symmetric(
        horizontal: NurseMateSpacing.lg,
        vertical: NurseMateSpacing.md,
      ),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.name,
                  style: theme.textTheme.titleMedium?.copyWith(height: 1.35),
                ),
                if (showPrice) ...[
                  const SizedBox(height: NurseMateSpacing.xs),
                  PriceText(exam.price),
                ],
              ],
            ),
          ),
          const SizedBox(width: NurseMateSpacing.sm),
          IconButton(
            tooltip: favorite ? '즐겨찾기 해제' : '즐겨찾기 등록',
            onPressed: onFavorite,
            icon: Icon(
              favorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: favorite
                  ? NurseMateColors.yellow
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
