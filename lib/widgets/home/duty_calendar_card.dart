import 'package:flutter/material.dart';

class DutyCalendarCard extends StatelessWidget {
  const DutyCalendarCard({
    super.key,
    required this.onManage,
    required this.onSettings,
  });

  final VoidCallback onManage;
  final VoidCallback onSettings;

  static const _days = <_DutyDay>[
    _DutyDay(29, isCurrentMonth: false),
    _DutyDay(30, isCurrentMonth: false),
    _DutyDay(1, duty: 'D'),
    _DutyDay(2, duty: 'E'),
    _DutyDay(3, duty: 'N'),
    _DutyDay(4, duty: 'OFF'),
    _DutyDay(5),
    _DutyDay(6),
    _DutyDay(7, duty: 'D'),
    _DutyDay(8, duty: 'E'),
    _DutyDay(9, duty: 'N'),
    _DutyDay(10, duty: 'D'),
    _DutyDay(11, duty: 'OFF'),
    _DutyDay(12),
    _DutyDay(13),
    _DutyDay(14, duty: 'E'),
    _DutyDay(15, duty: 'N'),
    _DutyDay(16, duty: 'D', isToday: true),
    _DutyDay(17, duty: 'E'),
    _DutyDay(18, duty: 'N'),
    _DutyDay(19),
    _DutyDay(20),
    _DutyDay(21, duty: 'D'),
    _DutyDay(22, duty: 'OFF'),
    _DutyDay(23, duty: 'E'),
    _DutyDay(24, duty: 'N'),
    _DutyDay(25, duty: 'D'),
    _DutyDay(26),
    _DutyDay(27),
    _DutyDay(28, duty: 'E'),
    _DutyDay(29, duty: 'N'),
    _DutyDay(30, duty: 'D'),
    _DutyDay(31, duty: 'OFF'),
    _DutyDay(1, isCurrentMonth: false),
    _DutyDay(2, isCurrentMonth: false),
  ];

  @override
  Widget build(BuildContext context) {
    return _PastelPanel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DutyHeader(
                compact: compact,
                onManage: onManage,
                onSettings: onSettings,
              ),
              SizedBox(height: compact ? 22 : 30),
              const _WeekdayHeader(),
              const SizedBox(height: 8),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _days.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: compact ? 0.72 : 1.12,
                ),
                itemBuilder: (context, index) {
                  return _DutyCell(day: _days[index], weekday: index % 7);
                },
              ),
              SizedBox(height: compact ? 18 : 24),
              const _DutyLegend(),
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
    required this.onManage,
    required this.onSettings,
  });

  final bool compact;
  final VoidCallback onManage;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF6554C0),
              size: 28,
            ),
            const SizedBox(width: 10),
            const Text(
              '듀티표',
              style: TextStyle(
                color: Color(0xFF202238),
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            if (!compact)
              FilledButton.tonal(
                key: const Key('manageDutyButton'),
                onPressed: onManage,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF0EDFF),
                  foregroundColor: const Color(0xFF6554C0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  '내 듀티 관리',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            IconButton(
              key: const Key('dutySettingsButton'),
              onPressed: onSettings,
              color: const Color(0xFF74758A),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MonthButton(icon: Icons.chevron_left_rounded, onPressed: () {}),
            const SizedBox(width: 14),
            const Text(
              '2025년 7월',
              style: TextStyle(
                color: Color(0xFF202238),
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 14),
            _MonthButton(icon: Icons.chevron_right_rounded, onPressed: () {}),
          ],
        ),
        if (compact) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              key: const Key('manageDutyButton'),
              onPressed: onManage,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF0EDFF),
                foregroundColor: const Color(0xFF6554C0),
              ),
              child: const Text('내 듀티 관리'),
            ),
          ),
        ],
      ],
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFFF7F5FF),
        foregroundColor: const Color(0xFF6554C0),
      ),
      icon: Icon(icon),
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

class _DutyCell extends StatelessWidget {
  const _DutyCell({required this.day, required this.weekday});

  final _DutyDay day;
  final int weekday;

  @override
  Widget build(BuildContext context) {
    final dateColor = !day.isCurrentMonth
        ? const Color(0xFFB7B8C4)
        : weekday == 0
        ? const Color(0xFFE14F6D)
        : weekday == 6
        ? const Color(0xFF4486C7)
        : const Color(0xFF303145);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 3),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFF0F0F6)),
          right: BorderSide(color: Color(0xFFF4F3F8)),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: day.isToday
                ? const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF8C7CF0), Color(0xFF6554C0)],
                    ),
                  )
                : null,
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: day.isToday ? Colors.white : dateColor,
                fontSize: 14,
                fontWeight: day.isToday ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
          if (day.duty != null) ...[
            const SizedBox(height: 5),
            _DutyBadge(duty: day.duty!, compact: true),
          ],
        ],
      ),
    );
  }
}

class _DutyLegend extends StatelessWidget {
  const _DutyLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 16,
      runSpacing: 12,
      children: const [
        _LegendItem(duty: 'D', label: '주간 (Day)'),
        _LegendItem(duty: 'E', label: '저녁 (Evening)'),
        _LegendItem(duty: 'N', label: '야간 (Night)'),
        _LegendItem(duty: 'OFF', label: '휴무 (Off)'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.duty, required this.label});

  final String duty;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DutyBadge(duty: duty, compact: true),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF5D5F72),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DutyBadge extends StatelessWidget {
  const _DutyBadge({required this.duty, required this.compact});

  final String duty;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = switch (duty) {
      'D' => (const Color(0xFFE4F7E8), const Color(0xFF16924E)),
      'E' => (const Color(0xFFF0EBFF), const Color(0xFF6547B2)),
      'N' => (const Color(0xFFFFF0DB), const Color(0xFFE47012)),
      _ => (const Color(0xFFF1F1F7), const Color(0xFF606174)),
    };
    return Container(
      constraints: BoxConstraints(minWidth: duty == 'OFF' ? 44 : 34),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        duty,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colors.$2,
          fontSize: compact ? 11 : 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PastelPanel extends StatelessWidget {
  const _PastelPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF1F0F8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D5D4DB2),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DutyDay {
  const _DutyDay(
    this.day, {
    this.duty,
    this.isCurrentMonth = true,
    this.isToday = false,
  });

  final int day;
  final String? duty;
  final bool isCurrentMonth;
  final bool isToday;
}
