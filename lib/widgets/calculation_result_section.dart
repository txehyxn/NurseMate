import 'package:flutter/material.dart';

import '../models/infusion_calculation_result.dart';
import 'drip_chamber_visual.dart';

class CalculationResultSection extends StatelessWidget {
  const CalculationResultSection({super.key, required this.result});

  final InfusionCalculationResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('계산 결과', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            const _StatusPill(),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '일반 성인 수액세트 20 gtt/mL 기준',
          key: Key('dropFactorBasis'),
          style: TextStyle(
            color: Color(0xFF5B6F82),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 18),
        _HeroRate(result: result),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: '분당 점적 수',
                value: '${_formatFixedTwo(result.gttPerMinute)} gtt/min',
                detail: '약 ${result.roundedDropsPerMinute}방울/분',
                icon: Icons.water_drop_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                label: '한 방울 간격',
                value: '${_formatFixedTwo(result.secondsPerDrop)}초에 한 방울',
                detail: '20 gtt/mL 기준',
                icon: Icons.timer_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Divider(),
        const SizedBox(height: 22),
        Text('수액 점적 시각화', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        const Text('계산된 간격에 맞춰 방울이 반복해서 떨어집니다.'),
        const SizedBox(height: 18),
        AnimatedDripChamber(secondsPerDrop: result.secondsPerDrop),
        const SizedBox(height: 14),
        const Text(
          '화면의 방울은 계산된 점적 간격을 시각화한 값입니다.\n'
          '실제 투여 전 처방과 수액세트 정보를 다시 확인하세요.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF64788B),
            fontSize: 12,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _HeroRate extends StatelessWidget {
  const _HeroRate({required this.result});

  final InfusionCalculationResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF17324D),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '시간당 주입량',
            style: TextStyle(color: Color(0xFFB9C9D8), fontSize: 14),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatFixedTwo(result.mlPerHour),
                key: const Key('mlPerHourValue'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text(
                  'cc/hr',
                  style: TextStyle(
                    color: Color(0xFF64B5F6),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatFixedTwo(double value) => value.toStringAsFixed(2);

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE6F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(height: 12),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 2),
          Text(detail, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5F1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: const Text(
        '계산 완료',
        style: TextStyle(
          color: Color(0xFF16836E),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
