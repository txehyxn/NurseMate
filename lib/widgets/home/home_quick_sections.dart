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
        final stacked = constraints.maxWidth < 720;
        final quick = _QuickCalculationCard(
          onDropCalculation: onDropCalculation,
          onCcPerHour: onCcPerHour,
          onBmi: onBmi,
          onOther: onOther,
        );
        const dDay = _DDayCard();
        if (stacked) {
          return Column(children: [quick, const SizedBox(height: 18), dDay]);
        }
        return const SizedBox.shrink();
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
          ),
        ),
        const SizedBox(width: 18),
        const Expanded(flex: 2, child: _DDayCard()),
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
  });

  final VoidCallback onDropCalculation;
  final VoidCallback onCcPerHour;
  final VoidCallback onBmi;
  final VoidCallback onOther;

  @override
  Widget build(BuildContext context) {
    return _HomePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(
                Icons.calculate_outlined,
                color: Color(0xFF62647A),
                size: 23,
              ),
              SizedBox(width: 9),
              Text(
                '빠른 계산',
                style: TextStyle(
                  color: Color(0xFF303145),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Spacer(),
              Text(
                '더보기  ›',
                style: TextStyle(
                  color: Color(0xFF898A9B),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _QuickItem(
                  key: const Key('infusionSpeedCheckMenu'),
                  icon: Icons.water_drop_rounded,
                  title: '방울수 계산',
                  caption: 'gtt/min',
                  onTap: onDropCalculation,
                ),
              ),
              Expanded(
                child: _QuickItem(
                  icon: Icons.speed_rounded,
                  title: 'cc/hr 계산',
                  caption: '주입속도',
                  onTap: onCcPerHour,
                ),
              ),
              Expanded(
                child: _QuickItem(
                  icon: Icons.person_rounded,
                  title: 'BMI 계산',
                  caption: '체질량지수',
                  onTap: onBmi,
                ),
              ),
              Expanded(
                child: _QuickItem(
                  icon: Icons.dialpad_rounded,
                  title: '기타 계산',
                  caption: '다양한 계산',
                  onTap: onOther,
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
  });

  final IconData icon;
  final String title;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 7),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF6E83B1), size: 31),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF3E4055),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              caption,
              style: const TextStyle(
                color: Color(0xFF9A9BAC),
                fontSize: 10,
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
  const _DDayCard();

  @override
  Widget build(BuildContext context) {
    return _HomePanel(
      gradient: const LinearGradient(
        colors: [Color(0xFFF8F6FF), Color(0xFFF0EEFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'D-Day',
                  style: TextStyle(
                    color: Color(0xFF6554C0),
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 18),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '120',
                        style: TextStyle(
                          color: Color(0xFF25263A),
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(
                        text: '일',
                        style: TextStyle(
                          color: Color(0xFF55566A),
                          fontSize: 14,
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
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF8272DE),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x337160CF),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 54,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomePanel extends StatelessWidget {
  const _HomePanel({required this.child, this.gradient});

  final Widget child;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
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
