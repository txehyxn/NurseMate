import 'package:flutter/material.dart';

import '../design_system/nursemate_design_system.dart';

class ChecklistProgressCard extends StatelessWidget {
  const ChecklistProgressCard({
    super.key,
    required this.completedCount,
    required this.totalCount,
    this.title = '오늘 진행률',
    this.keyPrefix = 'checklist',
  });

  final int completedCount;
  final int totalCount;
  final String title;
  final String keyPrefix;

  double get _progress {
    if (totalCount == 0) return 0;
    return (completedCount / totalCount).clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress;
    final percentage = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(NurseMateSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [NurseMateColors.primary, NurseMateColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(NurseMateRadii.card),
        boxShadow: NurseMateShadows.floating,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(NurseMateRadii.small),
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: NurseMateSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '$percentage%',
                key: Key('${keyPrefix}ProgressPercent'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: NurseMateSpacing.md),
          Text(
            '$completedCount / $totalCount 완료',
            key: Key('${keyPrefix}ProgressCount'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: NurseMateSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              key: Key('${keyPrefix}ProgressBar'),
              value: progress,
              minHeight: 9,
              color: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.20),
            ),
          ),
        ],
      ),
    );
  }
}
