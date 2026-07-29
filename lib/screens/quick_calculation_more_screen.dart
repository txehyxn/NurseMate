import 'package:flutter/material.dart';

import '../design_system/nursemate_design_system.dart';
import 'infusion_calculator_screen.dart';
import 'infusion_speed_check_screen.dart';
import 'intake_calculator_screen.dart';
import 'quick_menu_placeholder_screen.dart';

class QuickCalculationMoreScreen extends StatelessWidget {
  const QuickCalculationMoreScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final calculationItems = <_QuickMenuItem>[
      _QuickMenuItem(
        key: 'quickMore-drop',
        icon: Icons.water_drop_rounded,
        title: '방울수 계산',
        subtitle: 'gtt/min',
        onTap: () => _open(context, const InfusionSpeedCheckScreen()),
      ),
      _QuickMenuItem(
        key: 'quickMore-ccPerHour',
        icon: Icons.speed_rounded,
        title: 'cc/hr 계산',
        subtitle: '주입속도',
        onTap: () => _open(context, const InfusionCalculatorScreen()),
      ),
      _QuickMenuItem(
        key: 'quickMore-intake',
        icon: Icons.restaurant_menu_rounded,
        title: '섭취량 계산기',
        subtitle: '식사 섭취량',
        onTap: () => _open(context, const IntakeCalculatorScreen()),
      ),
    ];
    final referenceItems = <_QuickMenuItem>[
      _QuickMenuItem(
        key: 'quickMore-ast',
        icon: Icons.medication_rounded,
        title: 'AST(항생제)',
        subtitle: '항생제 정보',
        onTap: () => _open(
          context,
          const QuickMenuPlaceholderScreen(
            title: 'AST(항생제)',
            icon: Icons.medication_rounded,
          ),
        ),
      ),
      _QuickMenuItem(
        key: 'quickMore-bloodTest',
        icon: Icons.bloodtype_rounded,
        title: '혈액 검사',
        subtitle: '혈액검사 정보',
        onTap: () => _open(
          context,
          const QuickMenuPlaceholderScreen(
            title: '혈액 검사',
            icon: Icons.bloodtype_rounded,
          ),
        ),
      ),
      _QuickMenuItem(
        key: 'quickMore-nonCoveredTest',
        icon: Icons.science_rounded,
        title: '비급여 검사',
        subtitle: '검사/비용',
        onTap: () => _open(
          context,
          const QuickMenuPlaceholderScreen(
            title: '비급여 검사',
            icon: Icons.science_rounded,
          ),
        ),
      ),
      _QuickMenuItem(
        key: 'quickMore-phone',
        icon: Icons.local_phone_rounded,
        title: '병원 전화번호',
        subtitle: '부서 연락처',
        onTap: () => _open(
          context,
          const QuickMenuPlaceholderScreen(
            title: '병원 전화번호',
            icon: Icons.local_phone_rounded,
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('빠른 계산')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            NurseMateSpacing.page,
            NurseMateSpacing.xs,
            NurseMateSpacing.page,
            NurseMateSpacing.section,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const NurseMatePageHeader(
                    title: '빠른 계산 더보기',
                    subtitle: '필요한 계산과 간호 정보를 빠르게 확인하세요.',
                  ),
                  const SizedBox(height: NurseMateSpacing.xl),
                  _QuickMenuSection(
                    titleKey: const Key('quickCategory-calculation'),
                    title: '🧮 계산 도구',
                    items: calculationItems,
                  ),
                  const SizedBox(height: NurseMateSpacing.section),
                  _QuickMenuSection(
                    titleKey: const Key('quickCategory-reference'),
                    title: '📚 업무 자료',
                    items: referenceItems,
                    supporting: const _WorkReferenceSearchBar(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickMenuSection extends StatelessWidget {
  const _QuickMenuSection({
    required this.titleKey,
    required this.title,
    required this.items,
    this.supporting,
  });

  final Key titleKey;
  final String title;
  final List<_QuickMenuItem> items;
  final Widget? supporting;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          key: titleKey,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: NurseMateColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: NurseMateSpacing.sm),
        if (supporting != null) ...[
          supporting!,
          const SizedBox(height: NurseMateSpacing.sm),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final columnCount = constraints.maxWidth >= 640 ? 2 : 1;
            final cardWidth =
                (constraints.maxWidth -
                    NurseMateSpacing.md * (columnCount - 1)) /
                columnCount;
            return Wrap(
              spacing: NurseMateSpacing.md,
              runSpacing: NurseMateSpacing.md,
              children: [
                for (final item in items)
                  SizedBox(
                    width: cardWidth,
                    child: _QuickMenuCard(item: item),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _WorkReferenceSearchBar extends StatelessWidget {
  const _WorkReferenceSearchBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SearchBar(
      key: const Key('workReferenceSearchBar'),
      hintText: '업무 자료 검색',
      leading: const Icon(Icons.search_rounded),
      backgroundColor: WidgetStatePropertyAll(colors.surface),
      elevation: const WidgetStatePropertyAll(0),
      side: WidgetStateProperty.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.focused)
              ? NurseMateColors.primary
              : colors.outline,
          width: states.contains(WidgetState.focused) ? 1.5 : 1,
        ),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NurseMateRadii.input),
        ),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: NurseMateSpacing.md),
      ),
      constraints: const BoxConstraints(minHeight: 56),
      textStyle: WidgetStatePropertyAll(theme.textTheme.bodyLarge),
      hintStyle: WidgetStatePropertyAll(
        theme.textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
      ),
    );
  }
}

class _QuickMenuItem {
  const _QuickMenuItem({
    required this.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String key;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _QuickMenuCard extends StatelessWidget {
  const _QuickMenuCard({required this.item});

  final _QuickMenuItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return NurseMateCard(
      key: Key(item.key),
      padding: const EdgeInsets.all(NurseMateSpacing.lg),
      onTap: item.onTap,
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isDark
                  ? NurseMateColors.primary.withValues(alpha: 0.18)
                  : NurseMateColors.primarySoft,
              borderRadius: BorderRadius.circular(NurseMateRadii.input),
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, size: 28, color: NurseMateColors.primary),
          ),
          const SizedBox(width: NurseMateSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: NurseMateSpacing.xxs),
                Text(
                  item.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: NurseMateSpacing.xs),
          Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }
}
