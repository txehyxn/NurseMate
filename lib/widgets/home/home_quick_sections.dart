import 'package:flutter/material.dart';

class HomeQuickSections extends StatelessWidget {
  const HomeQuickSections({
    super.key,
    required this.onDropCalculation,
    required this.onCcPerHour,
    required this.onBmi,
    required this.onOther,
  });

  final VoidCallback onDropCalculation;
  final VoidCallback onCcPerHour;
  final VoidCallback onBmi;
  final VoidCallback onOther;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 350;
        final quick = _QuickCalculationCard(
          onDropCalculation: onDropCalculation,
          onCcPerHour: onCcPerHour,
          onBmi: onBmi,
          onOther: onOther,
          compact: !stacked,
        );
        final dDay = _DDayCard(compact: !stacked);
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
    required this.onBmi,
    required this.onOther,
  });

  final VoidCallback onDropCalculation;
  final VoidCallback onCcPerHour;
  final VoidCallback onBmi;
  final VoidCallback onOther;

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
            onBmi: onBmi,
            onOther: onOther,
            compact: false,
          ),
        ),
        const SizedBox(width: 18),
        const Expanded(flex: 2, child: _DDayCard(compact: false)),
      ],
    );
  }
}

class _QuickCalculationCard extends StatelessWidget {
  const _QuickCalculationCard({
    required this.onDropCalculation,
    required this.onCcPerHour,
    required this.onBmi,
    required this.onOther,
    required this.compact,
  });

  final VoidCallback onDropCalculation;
  final VoidCallback onCcPerHour;
  final VoidCallback onBmi;
  final VoidCallback onOther;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _HomePanel(
      compact: compact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.calculate_outlined,
                color: Color(0xFF62647A),
                size: compact ? 18 : 23,
              ),
              SizedBox(width: compact ? 5 : 9),
              Text(
                '빠른 계산',
                style: TextStyle(
                  color: Color(0xFF303145),
                  fontSize: compact ? 14 : 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (!compact)
                const Text(
                  '더보기  ›',
                  style: TextStyle(
                    color: Color(0xFF898A9B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
                  icon: Icons.person_rounded,
                  title: 'BMI 계산',
                  caption: '체질량지수',
                  onTap: onBmi,
                  compact: compact,
                ),
              ),
              Expanded(
                child: _QuickItem(
                  icon: Icons.dialpad_rounded,
                  title: '기타 계산',
                  caption: '다양한 계산',
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
                color: const Color(0xFF3E4055),
                fontSize: compact ? 9 : 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: compact ? 2 : 3),
            Text(
              caption,
              style: TextStyle(
                color: const Color(0xFF9A9BAC),
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

class _DDayCard extends StatelessWidget {
  const _DDayCard({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _HomePanel(
      compact: compact,
      gradient: const LinearGradient(
        colors: [Color(0xFFF8F6FF), Color(0xFFF0EEFF)],
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
                  'D-Day',
                  style: TextStyle(
                    color: Color(0xFF6554C0),
                    fontSize: compact ? 16 : 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: compact ? 10 : 18),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '120',
                        style: TextStyle(
                          color: Color(0xFF25263A),
                          fontSize: compact ? 28 : 38,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(
                        text: '일',
                        style: TextStyle(
                          color: Color(0xFF55566A),
                          fontSize: compact ? 11 : 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '입사 후 D-Day\n오늘도 성장 중이에요! ♥',
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
              color: const Color(0xFF8272DE),
              borderRadius: BorderRadius.circular(compact ? 15 : 22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x337160CF),
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
}

class _HomePanel extends StatelessWidget {
  const _HomePanel({required this.child, this.gradient, this.compact = false});

  final Widget child;
  final Gradient? gradient;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 22),
      decoration: BoxDecoration(
        color: gradient == null ? Colors.white : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF1F0F8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D5D4DB2),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
