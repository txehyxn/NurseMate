import 'package:flutter/material.dart';

import '../../design_system/nursemate_design_system.dart';
import '../../models/duty_calendar_day.dart';
import '../../models/duty_type.dart';

class DutyCalendarCard extends StatelessWidget {
  const DutyCalendarCard({
    super.key,
    required this.month,
    required this.duties,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onManage,
    required this.onSettings,
    this.onDateTap,
    this.today,
    this.showManageButton = true,
  });

  final DateTime month;
  final Map<String, DutyType> duties;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onManage;
  final VoidCallback onSettings;
  final ValueChanged<DateTime>? onDateTap;
  final DateTime? today;
  final bool showManageButton;

  @override
  Widget build(BuildContext context) {
    return NurseMateCard(
      radius: NurseMateRadii.panel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 430;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DutyHeader(
                compact: compact,
                month: month,
                onPreviousMonth: onPreviousMonth,
                onNextMonth: onNextMonth,
                onManage: onManage,
                onSettings: onSettings,
                showManageButton: showManageButton,
              ),
              SizedBox(height: compact ? 22 : 30),
              DutyCalendarGrid(
                month: month,
                duties: duties,
                today: today ?? DateTime.now(),
                onDateTap: onDateTap,
              ),
              SizedBox(height: compact ? 18 : 24),
              const DutyLegend(),
            ],
          );
        },
      ),
    );
  }
}

class _DutyHeader extends StatelessWidget {
  const _DutyHeader({
    required this.compact,
    required this.month,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onManage,
    required this.onSettings,
    required this.showManageButton,
  });

  final bool compact;
  final DateTime month;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onManage;
  final VoidCallback onSettings;
  final bool showManageButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              color: NurseMateColors.primary,
              size: 28,
            ),
            const SizedBox(width: 10),
            const Text(
              '듀티표',
              style: TextStyle(
                color: NurseMateColors.navy,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            if (!compact && showManageButton)
              DutyManageButton(onPressed: onManage),
            IconButton(
              key: const Key('dutySettingsButton'),
              tooltip: '듀티 설정',
              onPressed: onSettings,
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MonthButton(
              key: const Key('previousDutyMonth'),
              icon: Icons.chevron_left_rounded,
              onPressed: onPreviousMonth,
            ),
            const SizedBox(width: 14),
            AnimatedSwitcher(
              duration: NurseMateMotion.standard,
              switchInCurve: NurseMateMotion.curve,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0.15, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: NurseMateMotion.curve,
                          ),
                        ),
                    child: child,
                  ),
                );
              },
              child: Text(
                dutyMonthLabel(month),
                key: ValueKey('${month.year}-${month.month}'),
                style: const TextStyle(
                  color: NurseMateColors.navy,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            _MonthButton(
              key: const Key('nextDutyMonth'),
              icon: Icons.chevron_right_rounded,
              onPressed: onNextMonth,
            ),
          ],
        ),
        if (compact && showManageButton) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: DutyManageButton(onPressed: onManage),
          ),
        ],
      ],
    );
  }
}

class DutyManageButton extends StatelessWidget {
  const DutyManageButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      key: const Key('manageDutyButton'),
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(44, 46),
        backgroundColor: NurseMateColors.primarySoft,
        foregroundColor: NurseMateColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NurseMateRadii.small),
        ),
      ),
      child: const Text(
        '내 듀티 관리',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({super.key, required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFFF7F5FF),
        foregroundColor: NurseMateColors.primary,
      ),
      icon: Icon(icon),
    );
  }
}

class DutyCalendarGrid extends StatelessWidget {
  const DutyCalendarGrid({
    super.key,
    required this.month,
    required this.duties,
    required this.today,
    this.onDateTap,
  });

  final DateTime month;
  final Map<String, DutyType> duties;
  final DateTime today;
  final ValueChanged<DateTime>? onDateTap;

  @override
  Widget build(BuildContext context) {
    final days = buildDutyCalendarDays(month: month, duties: duties);
    return Column(
      children: [
        const _WeekdayHeader(),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: NurseMateMotion.standard,
          switchInCurve: NurseMateMotion.curve,
          child: LayoutBuilder(
            key: ValueKey('${month.year}-${month.month}'),
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 430;
              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: days.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: DateTime.daysPerWeek,
                  childAspectRatio: compact ? 0.72 : 1.12,
                ),
                itemBuilder: (context, index) {
                  return DutyDayCell(
                    key: Key('dutyDay_${dutyDateKey(days[index].date)}'),
                    day: days[index],
                    weekday: index % DateTime.daysPerWeek,
                    isToday: days[index].isSameDate(today),
                    onTap: onDateTap == null
                        ? null
                        : () => onDateTap!(days[index].date),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    const weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return Row(
      children: [
        for (var index = 0; index < weekdays.length; index++)
          Expanded(
            child: Text(
              weekdays[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: index == 0
                    ? const Color(0xFFE14F6D)
                    : index == 6
                    ? const Color(0xFF4486C7)
                    : const Color(0xFF56586C),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class DutyDayCell extends StatelessWidget {
  const DutyDayCell({
    super.key,
    required this.day,
    required this.weekday,
    required this.isToday,
    this.onTap,
  });

  final DutyCalendarDay day;
  final int weekday;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dateColor = !day.isCurrentMonth
        ? const Color(0xFFB7B8C4)
        : weekday == 0
        ? const Color(0xFFE14F6D)
        : weekday == 6
        ? const Color(0xFF2674C8)
        : NurseMateColors.navy;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 3),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: NurseMateColors.divider),
            right: BorderSide(color: Color(0xFFF4F3F8)),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: isToday
                  ? const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF8C7CF0), NurseMateColors.primary],
                      ),
                    )
                  : null,
              child: Text(
                '${day.date.day}',
                style: TextStyle(
                  color: isToday ? Colors.white : dateColor,
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 5),
            AnimatedSwitcher(
              duration: NurseMateMotion.fast,
              switchInCurve: NurseMateMotion.curve,
              child: day.duty == null
                  ? const SizedBox(height: 25)
                  : DutyBadge(
                      key: ValueKey(day.duty),
                      type: day.duty!,
                      compact: true,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class DutyLegend extends StatelessWidget {
  const DutyLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      spacing: 18,
      runSpacing: 12,
      children: const [
        _LegendItem(type: DutyType.day),
        _LegendItem(type: DutyType.evening),
        _LegendItem(type: DutyType.night),
        _LegendItem(type: DutyType.off),
        _LegendItem(type: DutyType.annualLeave),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.type});

  final DutyType type;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DutyBadge(type: type, compact: true),
        const SizedBox(width: 8),
        Text(
          type.label,
          style: const TextStyle(
            color: NurseMateColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class DutyBadge extends StatelessWidget {
  const DutyBadge({super.key, required this.type, this.compact = false});

  final DutyType type;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: type == DutyType.off ? 44 : 34),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: type.background,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        type.code,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: type.foreground,
          fontSize: compact ? 11 : 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
