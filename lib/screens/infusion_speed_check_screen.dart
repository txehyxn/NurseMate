import 'package:flutter/material.dart';

import '../widgets/drip_chamber_visual.dart';

const Map<int, double> infusionSpeedSecondsPerDrop = {
  30: 6.0,
  40: 4.5,
  60: 3.0,
  80: 2.25,
  100: 1.8,
  120: 1.5,
  150: 1.2,
  180: 1.0,
};

class InfusionSpeedCheckScreen extends StatefulWidget {
  const InfusionSpeedCheckScreen({super.key});

  @override
  State<InfusionSpeedCheckScreen> createState() =>
      _InfusionSpeedCheckScreenState();
}

class _InfusionSpeedCheckScreenState extends State<InfusionSpeedCheckScreen> {
  int _selectedSpeed = 100;

  double get _secondsPerDrop => infusionSpeedSecondsPerDrop[_selectedSpeed]!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          '수액속도 확인하기',
          style: TextStyle(
            color: Color(0xFF17324D),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 36),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '수액속도 확인하기',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '원하는 주입속도를 선택하면\n'
                    '실제 속도로 방울이 떨어지는 모습을 확인할 수 있습니다.',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '일반 성인 수액세트(20 gtt/mL) 기준',
                    style: TextStyle(
                      color: Color(0xFF2166D1),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '주입속도 선택',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 14),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 2.55,
                          children: [
                            for (final speed
                                in infusionSpeedSecondsPerDrop.keys)
                              _SpeedOption(
                                speed: speed,
                                selected: speed == _selectedSpeed,
                                onTap: () {
                                  setState(() => _selectedSpeed = speed);
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SelectedSpeedSummary(
                          speed: _selectedSpeed,
                          secondsPerDrop: _secondsPerDrop,
                        ),
                        const SizedBox(height: 22),
                        AnimatedDripChamber(secondsPerDrop: _secondsPerDrop),
                      ],
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

class _SpeedOption extends StatelessWidget {
  const _SpeedOption({
    required this.speed,
    required this.selected,
    required this.onTap,
  });

  final int speed;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('speedOption_$speed'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFEAF2FD)
                  : const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? const Color(0xFF2166D1)
                    : const Color(0xFFD9E2EC),
                width: selected ? 2 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$speed cc/hr',
              style: TextStyle(
                color: const Color(0xFF17324D),
                fontSize: 16,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedSpeedSummary extends StatelessWidget {
  const _SelectedSpeedSummary({
    required this.speed,
    required this.secondsPerDrop,
  });

  final int speed;
  final double secondsPerDrop;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('selectedSpeedSummary'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF17324D),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            '$speed cc/hr',
            key: const Key('selectedSpeedValue'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '1방울당 ${secondsPerDrop.toStringAsFixed(2)}초',
            key: const Key('selectedSecondsPerDrop'),
            style: const TextStyle(
              color: Color(0xFF90CAF9),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE0E7EF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A17324D),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
