import 'package:flutter/material.dart';

import '../design_system/nursemate_design_system.dart';
import '../models/intake_calculator_model.dart';

class IntakeCalculatorScreen extends StatefulWidget {
  const IntakeCalculatorScreen({super.key});

  @override
  State<IntakeCalculatorScreen> createState() => _IntakeCalculatorScreenState();
}

class _IntakeCalculatorScreenState extends State<IntakeCalculatorScreen> {
  MealType _mealType = MealType.regular;
  final Map<String, int> _percentages = {
    'main': 0,
    'soup': 0,
    'vegetable': 0,
    'protein': 0,
  };

  void _selectMealType(MealType mealType) {
    if (mealType == _mealType) return;
    setState(() => _mealType = mealType);
  }

  void _selectPercentage(String itemId, int percentage) {
    if (_percentages[itemId] == percentage) return;
    setState(() => _percentages[itemId] = percentage);
  }

  void _reset() {
    setState(() {
      for (final itemId in _percentages.keys) {
        _percentages[itemId] = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = IntakeCalculatorModel.itemsFor(_mealType);
    final itemAmounts = IntakeCalculatorModel.calculateItems(
      mealType: _mealType,
      percentages: _percentages,
    );
    final total = itemAmounts.values.fold(0, (sum, value) => sum + value);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          key: const Key('intakeCalculatorBackButton'),
          tooltip: '뒤로가기',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
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
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const NurseMatePageHeader(
                    title: '섭취량 계산기',
                    subtitle: '퍼센트만 선택하면\n자동으로 섭취량(cc)을 계산합니다.',
                  ),
                  const SizedBox(height: NurseMateSpacing.xl),
                  _MealTypeSelector(
                    selected: _mealType,
                    onSelected: _selectMealType,
                  ),
                  const SizedBox(height: NurseMateSpacing.section),
                  const NurseMateSectionTitle(
                    title: '섭취한 비율',
                    icon: Icons.restaurant_menu_rounded,
                  ),
                  const SizedBox(height: NurseMateSpacing.md),
                  Column(
                    children: [
                      for (var index = 0; index < items.length; index++) ...[
                        _FoodPercentageCard(
                          item: items[index],
                          selectedPercentage:
                              _percentages[items[index].id] ?? 0,
                          onSelected: (percentage) =>
                              _selectPercentage(items[index].id, percentage),
                        ),
                        if (index != items.length - 1)
                          const SizedBox(height: NurseMateSpacing.md),
                      ],
                    ],
                  ),
                  const SizedBox(height: NurseMateSpacing.xl),
                  _TotalIntakeCard(
                    total: total,
                    items: items,
                    itemAmounts: itemAmounts,
                  ),
                  const SizedBox(height: NurseMateSpacing.lg),
                  Align(
                    child: SizedBox(
                      width: 220,
                      child: OutlinedButton.icon(
                        key: const Key('intakeResetButton'),
                        onPressed: _reset,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? NurseMateColors.primary.withValues(alpha: 0.12)
                              : NurseMateColors.primarySoft,
                          foregroundColor: NurseMateColors.primary,
                          side: BorderSide(
                            color: NurseMateColors.primary.withValues(
                              alpha: 0.28,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: const Text('초기화'),
                      ),
                    ),
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

class _MealTypeSelector extends StatelessWidget {
  const _MealTypeSelector({required this.selected, required this.onSelected});

  final MealType selected;
  final ValueChanged<MealType> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const NurseMateSectionTitle(
          title: '식사 종류',
          icon: Icons.rice_bowl_rounded,
        ),
        const SizedBox(height: NurseMateSpacing.md),
        SegmentedButton<MealType>(
          key: const Key('mealTypeSelector'),
          showSelectedIcon: false,
          segments: [
            for (final mealType in MealType.values)
              ButtonSegment<MealType>(
                value: mealType,
                icon: Text(
                  mealType.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
                label: Text(
                  mealType.label,
                  key: Key('mealType-${mealType.name}'),
                ),
              ),
          ],
          selected: {selected},
          onSelectionChanged: (selection) => onSelected(selection.first),
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(Size(0, 52)),
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? colors.onPrimary
                  : colors.onSurfaceVariant,
            ),
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? NurseMateColors.primary
                  : colors.surface,
            ),
            side: WidgetStatePropertyAll(BorderSide(color: colors.outline)),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NurseMateRadii.input),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FoodPercentageCard extends StatelessWidget {
  const _FoodPercentageCard({
    required this.item,
    required this.selectedPercentage,
    required this.onSelected,
  });

  final IntakeFoodItem item;
  final int selectedPercentage;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return NurseMateCard(
      key: Key('intakeItem-${item.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark
                      ? NurseMateColors.mint.withValues(alpha: 0.16)
                      : NurseMateColors.mintSoft,
                  shape: BoxShape.circle,
                ),
                child: AnimatedSwitcher(
                  duration: NurseMateMotion.fast,
                  switchInCurve: NurseMateMotion.curve,
                  child: Text(
                    item.emoji,
                    key: ValueKey(item.emoji),
                    style: const TextStyle(fontSize: 25),
                  ),
                ),
              ),
              const SizedBox(width: NurseMateSpacing.sm),
              Expanded(
                child: Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '$selectedPercentage%',
                key: Key('intakeSelected-${item.id}'),
                style: const TextStyle(
                  color: NurseMateColors.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: NurseMateSpacing.md),
          Wrap(
            spacing: NurseMateSpacing.xs,
            runSpacing: NurseMateSpacing.xs,
            children: [
              for (final percentage in IntakeCalculatorModel.percentages)
                AnimatedScale(
                  scale: selectedPercentage == percentage ? 1.06 : 1,
                  duration: NurseMateMotion.fast,
                  curve: NurseMateMotion.curve,
                  child: ChoiceChip(
                    key: Key('intakeChip-${item.id}-$percentage'),
                    label: Text('$percentage'),
                    selected: selectedPercentage == percentage,
                    showCheckmark: false,
                    onSelected: (_) => onSelected(percentage),
                    backgroundColor: colors.surfaceContainerLow,
                    selectedColor: NurseMateColors.primary,
                    side: BorderSide(
                      color: selectedPercentage == percentage
                          ? NurseMateColors.primary
                          : colors.outline,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NurseMateRadii.small),
                    ),
                    labelStyle: TextStyle(
                      color: selectedPercentage == percentage
                          ? Colors.white
                          : colors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalIntakeCard extends StatelessWidget {
  const _TotalIntakeCard({
    required this.total,
    required this.items,
    required this.itemAmounts,
  });

  final int total;
  final List<IntakeFoodItem> items;
  final Map<String, int> itemAmounts;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    return Container(
      key: const Key('totalIntakeCard'),
      padding: const EdgeInsets.all(NurseMateSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  NurseMateColors.primary.withValues(alpha: 0.24),
                  NurseMateColors.mint.withValues(alpha: 0.15),
                ]
              : const [NurseMateColors.primarySoft, NurseMateColors.mintSoft],
        ),
        borderRadius: BorderRadius.circular(NurseMateRadii.card),
        border: Border.all(color: colors.outline),
        boxShadow: isDark ? const [] : NurseMateShadows.card,
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface.withValues(alpha: 0.88),
            ),
            child: const Text('🍽️', style: TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: NurseMateSpacing.sm),
          Text('총 섭취량', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: NurseMateSpacing.sm),
          Semantics(
            key: const Key('totalIntakeValue'),
            label: '$total cc',
            child: AnimatedSwitcher(
              duration: NurseMateMotion.fast,
              switchInCurve: NurseMateMotion.curve,
              switchOutCurve: NurseMateMotion.curve,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween(begin: 0.96, end: 1.0).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                '$total',
                key: ValueKey(total),
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 56,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.8,
                ),
              ),
            ),
          ),
          const SizedBox(height: NurseMateSpacing.xs),
          const Text(
            'cc',
            style: TextStyle(
              color: NurseMateColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: NurseMateSpacing.xl),
          Divider(color: colors.outlineVariant, height: 1),
          const SizedBox(height: NurseMateSpacing.lg),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '항목별 섭취량',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: NurseMateSpacing.sm),
          for (var index = 0; index < items.length; index++) ...[
            _IntakeBreakdownRow(
              item: items[index],
              amount: itemAmounts[items[index].id] ?? 0,
            ),
            if (index != items.length - 1)
              const SizedBox(height: NurseMateSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _IntakeBreakdownRow extends StatelessWidget {
  const _IntakeBreakdownRow({required this.item, required this.amount});

  final IntakeFoodItem item;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('intakeBreakdown-${item.id}'),
      constraints: const BoxConstraints(minHeight: 46),
      padding: const EdgeInsets.symmetric(
        horizontal: NurseMateSpacing.sm,
        vertical: NurseMateSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(NurseMateRadii.small),
      ),
      child: Row(
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 21)),
          const SizedBox(width: NurseMateSpacing.sm),
          Expanded(
            child: Text(
              item.name,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          AnimatedSwitcher(
            key: Key('intakeAmount-${item.id}'),
            duration: NurseMateMotion.fast,
            switchInCurve: NurseMateMotion.curve,
            switchOutCurve: NurseMateMotion.curve,
            child: Text(
              '${amount}cc',
              key: ValueKey('${item.id}-$amount'),
              style: const TextStyle(
                color: NurseMateColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
