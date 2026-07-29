import 'package:flutter/material.dart';

import '../design_system/nursemate_design_system.dart';
import '../widgets/home/home_illustration.dart';
import 'day_checklist_screen.dart';
import 'evening_checklist_screen.dart';
import 'night_checklist_screen.dart';

class ChecklistHomeScreen extends StatelessWidget {
  const ChecklistHomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          key: const Key('checklistBackButton'),
          tooltip: '뒤로가기',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            NurseMateSpacing.page,
            NurseMateSpacing.xs,
            NurseMateSpacing.page,
            NurseMateSpacing.section,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _ChecklistHero(),
                  const SizedBox(height: NurseMateSpacing.section),
                  const Text(
                    '근무를 선택해주세요',
                    style: TextStyle(
                      color: NurseMateColors.navy,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: NurseMateSpacing.md),
                  _ShiftCard(
                    key: const Key('dayChecklistCard'),
                    emoji: '🌞',
                    title: 'DAY',
                    description: '파이널 라운딩 1시',
                    iconBackground: NurseMateColors.yellowSoft,
                    accent: NurseMateColors.orange,
                    onTap: () => _open(context, const DayChecklistScreen()),
                  ),
                  const SizedBox(height: NurseMateSpacing.md),
                  _ShiftCard(
                    key: const Key('eveningChecklistCard'),
                    emoji: '🌆',
                    title: 'EVENING',
                    description: '파이널 라운딩 8PM',
                    iconBackground: NurseMateColors.primarySoft,
                    accent: NurseMateColors.primary,
                    onTap: () => _open(context, const EveningChecklistScreen()),
                  ),
                  const SizedBox(height: NurseMateSpacing.md),
                  _ShiftCard(
                    key: const Key('nightChecklistCard'),
                    emoji: '🌙',
                    title: 'NIGHT',
                    description: '파이널 라운딩 5AM',
                    iconBackground: NurseMateColors.blueSoft,
                    accent: NurseMateColors.blue,
                    onTap: () => _open(context, const NightChecklistScreen()),
                  ),
                  const SizedBox(height: NurseMateSpacing.xl),
                  const _ChecklistTipCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChecklistHero extends StatelessWidget {
  const _ChecklistHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          key: const Key('checklistNurseIllustration'),
          width: 156,
          height: 156,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [NurseMateColors.primarySoft, NurseMateColors.blueSoft],
            ),
            boxShadow: NurseMateShadows.card,
          ),
          child: const HomeIllustration(column: 3, row: 0),
        ),
        const SizedBox(height: NurseMateSpacing.lg),
        const Text(
          '신규간호사 체크리스트',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: NurseMateColors.navy,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: NurseMateSpacing.xs),
        const Text(
          '근무에 필요한 항목을 체크해보세요!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: NurseMateColors.textSecondary,
            fontSize: 15,
            height: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.description,
    required this.iconBackground,
    required this.accent,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String description;
  final Color iconBackground;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NurseMateCard(
      onTap: onTap,
      radius: NurseMateRadii.card,
      padding: const EdgeInsets.symmetric(
        horizontal: NurseMateSpacing.lg,
        vertical: NurseMateSpacing.md,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 78),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(NurseMateRadii.input),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 29)),
            ),
            const SizedBox(width: NurseMateSpacing.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: accent,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: NurseMateSpacing.xxs),
                  Text(
                    description,
                    style: const TextStyle(
                      color: NurseMateColors.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: NurseMateSpacing.sm),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: accent,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistTipCard extends StatelessWidget {
  const _ChecklistTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('checklistTipCard'),
      padding: const EdgeInsets.fromLTRB(20, 16, 14, 16),
      decoration: BoxDecoration(
        color: NurseMateColors.primarySoft,
        borderRadius: BorderRadius.circular(NurseMateRadii.card),
        border: Border.all(
          color: NurseMateColors.primary.withValues(alpha: 0.12),
        ),
        boxShadow: NurseMateShadows.card,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: NurseMateColors.primary,
                      size: 21,
                    ),
                    SizedBox(width: NurseMateSpacing.xs),
                    Text(
                      'TIP',
                      style: TextStyle(
                        color: NurseMateColors.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NurseMateSpacing.xs),
                Text(
                  '체크한 항목은 자동 저장됩니다.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: NurseMateColors.text,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: NurseMateSpacing.sm),
          const SizedBox(
            key: Key('checklistTipIllustration'),
            width: 74,
            height: 74,
            child: HomeIllustration(column: 2, row: 0),
          ),
        ],
      ),
    );
  }
}
