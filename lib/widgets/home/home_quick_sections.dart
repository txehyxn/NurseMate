import 'package:flutter/material.dart';

import '../../models/dday_setting.dart';

class HomeQuickSections extends StatelessWidget {
  const HomeQuickSections({
    super.key,
    required this.onDropCalculation,
    required this.onCcPerHour,
    required this.onAst,
    required this.onOther,
    required this.onMore,
    required this.dDaySetting,
    required this.dDayToday,
    required this.onDDayTap,
  });

  final VoidCallback onDropCalculation;
  final VoidCallback onCcPerHour;
  final VoidCallback onAst;
  final VoidCallback onOther;
  final VoidCallback onMore;
  final DDaySetting dDaySetting;
  final DateTime dDayToday;
  final VoidCallback onDDayTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 350;
        final quick = _QuickCalculationCard(
          onDropCalculation: onDropCalculation,
          onCcPerHour: onCcPerHour,
          onAst: onAst,
          onOther: onOther,
          onMore: onMore,
          compact: !stacked,
        );
        final dDay = DDayCard(
          setting: dDaySetting,
          today: dDayToday,
          onTap: onDDayTap,
          compact: !stacked,
        );
        if (stacked) {
          return Column(children: [quick, const SizedBox(height: 18), dDay]);
        }
        return SizedBox(
          height: 205,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: quick),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: dDay),
            ],
          ),
        );
      },
    );
  }
}

class HomeQuickSectionsWide extends StatelessWidget {
  const HomeQuickSectionsWide({
    super.key,
    required this.onDropCalculation,
    required this.onCcPerHour,
    required this.onAst,
    required this.onOther,
    required this.onMore,
    required this.dDaySetting,
    required this.dDayToday,
    required this.onDDayTap,
  });

  final VoidCallback onDropCalculation;
  final VoidCallback onCcPerHour;
  final VoidCallback onAst;
  final VoidCallback onOther;
  final VoidCallback onMore;
  final DDaySetting dDaySetting;
  final DateTime dDayToday;
  final VoidCallback onDDayTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 3,
          child: _QuickCalculationCard(
            onDropCalculation: onDropCalculation,
            onCcPerHour: onCcPerHour,
            onAst: onAst,
            onOther: onOther,
            onMore: onMore,
            compact: false,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          flex: 2,
          child: DDayCard(
            setting: dDaySetting,
            today: dDayToday,
            onTap: onDDayTap,
            compact: false,
          ),
        ),
      ],
    );
  }
}

class _QuickCalculationCard extends StatelessWidget {
  const _QuickCalculationCard({
    required this.onDropCalculation,
    required this.onCcPerHour,
    required this.onAst,
    required this.onOther,
    required this.onMore,
    required this.compact,
  });

  final VoidCallback onDropCalculation;
  final VoidCallback onCcPerHour;
  final VoidCallback onAst;
  final VoidCallback onOther;
  final VoidCallback onMore;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return _HomePanel(
      compact: compact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.calculate_outlined,
                color: Theme.of(context).brightness == Brightness.dark
                    ? colors.onSurfaceVariant
                    : const Color(0xFF62647A),
                size: compact ? 18 : 23,
              ),
              SizedBox(width: compact ? 5 : 9),
              Text(
                '빠른 계산',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? colors.onSurface
                      : const Color(0xFF303145),
                  fontSize: compact ? 14 : 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              InkWell(
                key: const Key('quickCalculationMoreButton'),
                onTap: onMore,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  child: Text(
                    '더보기  ›',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? colors.onSurfaceVariant
                          : const Color(0xFF898A9B),
                      fontSize: compact ? 10 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 10 : 18),
          Row(
            children: [
              Expanded(
                child: _QuickItem(
                  key: const Key('infusionSpeedCheckMenu'),
                  icon: Icons.water_drop_rounded,
                  title: '방울수 계산',
                  caption: 'gtt/min',
                  onTap: onDropCalculation,
                  compact: compact,
                ),
              ),
              Expanded(
                child: _QuickItem(
                  icon: Icons.speed_rounded,
                  title: 'cc/hr 계산',
                  caption: '주입속도',
                  onTap: onCcPerHour,
                  compact: compact,
                ),
              ),
              Expanded(
                child: _QuickItem(
                  key: const Key('astQuickMenu'),
                  icon: Icons.medication_rounded,
                  title: 'AST(항생제)',
                  caption: '항생제 정보',
                  onTap: onAst,
                  compact: compact,
                ),
              ),
              Expanded(
                child: _QuickItem(
                  key: const Key('intakeCalculatorMenu'),
                  icon: Icons.restaurant_menu_rounded,
                  title: '섭취량 계산기',
                  caption: '식사 섭취량',
                  onTap: onOther,
                  compact: compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickItem extends StatelessWidget {
  const _QuickItem({
    super.key,
    required this.icon,
    required this.title,
    required this.caption,
    required this.onTap,
    required this.compact,
  });

  final IconData icon;
  final String title;
  final String caption;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 1 : 3,
          vertical: compact ? 4 : 7,
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF6E83B1), size: compact ? 22 : 31),
            SizedBox(height: compact ? 6 : 10),
            Text(
              title,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? colors.onSurface
                    : const Color(0xFF3E4055),
                fontSize: compact ? 9 : 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: compact ? 2 : 3),
            Text(
              caption,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? colors.onSurfaceVariant
                    : const Color(0xFF9A9BAC),
                fontSize: compact ? 8 : 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DDayCard extends StatelessWidget {
  const DDayCard({
    super.key,
    required this.setting,
    required this.today,
    required this.compact,
    this.onTap,
  });

  final DDaySetting setting;
  final DateTime today;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _HomePanel(
      compact: compact,
      onTap: onTap,
      gradient: LinearGradient(
        colors: [
          setting.cardColor.backgroundStart,
          setting.cardColor.backgroundEnd,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  setting.calculationMode.label,
                  style: TextStyle(
                    color: setting.cardColor.accent,
                    fontSize: compact ? 16 : 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: compact ? 10 : 18),
                Text(
                  setting.counterLabel(today),
                  maxLines: 1,
                  style: TextStyle(
                    color: const Color(0xFF25263A),
                    fontSize: compact ? 28 : 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '${setting.title}\n${_formatDate(setting.date)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF696A7E),
                    fontSize: compact ? 9 : 12,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: compact ? 54 : 90,
            height: compact ? 54 : 90,
            decoration: BoxDecoration(
              color: setting.cardColor.accent,
              borderRadius: BorderRadius.circular(compact ? 15 : 22),
              boxShadow: [
                BoxShadow(
                  color: setting.cardColor.accent.withValues(alpha: 0.2),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: compact ? 32 : 54,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

class _HomePanel extends StatelessWidget {
  const _HomePanel({
    required this.child,
    this.gradient,
    this.compact = false,
    this.onTap,
  });

  final Widget child;
  final Gradient? gradient;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decoration = BoxDecoration(
      color: gradient == null ? theme.colorScheme.surface : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(26),
      border: Border.all(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.outline
            : const Color(0xFFF1F0F8),
      ),
      boxShadow: theme.brightness == Brightness.dark
          ? const <BoxShadow>[]
          : const [
              BoxShadow(
                color: Color(0x0D5D4DB2),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
    );
    if (onTap == null) {
      return Container(
        padding: EdgeInsets.all(compact ? 12 : 22),
        decoration: decoration,
        child: child,
      );
    }
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: decoration,
        child: InkWell(
          key: const Key('ddayHomeCard'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: Padding(
            padding: EdgeInsets.all(compact ? 12 : 22),
            child: child,
          ),
        ),
      ),
    );
  }
}
