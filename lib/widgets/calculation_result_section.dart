import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/infusion_calculation_result.dart';
import 'drip_chamber_visual.dart';

class CalculationResultSection extends StatelessWidget {
  const CalculationResultSection({
    super.key,
    required this.result,
    required this.actualDropsController,
    required this.onCompare,
    this.comparison,
  });

  final InfusionCalculationResult result;
  final TextEditingController actualDropsController;
  final VoidCallback onCompare;
  final InfusionComparison? comparison;

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
        const SizedBox(height: 18),
        _HeroRate(result: result),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: '실제 조절 기준',
                value: '약 ${result.roundedDropsPerMinute}방울/분',
                icon: Icons.water_drop_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                label: '한 방울 간격',
                value: '${result.secondsPerDrop.toStringAsFixed(1)}초',
                icon: Icons.timer_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Divider(),
        const SizedBox(height: 22),
        Text('실제 챔버와 비교', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        const Text('챔버를 1분간 관찰한 뒤 실제 떨어진 방울 수를 입력하세요.'),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                key: const Key('actualDropsField'),
                controller: actualDropsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: '1분간 실제 방울 수',
                  suffixText: '방울',
                ),
                onSubmitted: (_) => onCompare(),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 57,
              child: FilledButton.tonal(
                key: const Key('compareButton'),
                onPressed: onCompare,
                child: const Text('비교'),
              ),
            ),
          ],
        ),
        if (comparison != null) ...[
          const SizedBox(height: 16),
          _ComparisonBanner(comparison: comparison!),
        ],
        const SizedBox(height: 24),
        DripChamberVisual(
          secondsPerDrop: result.secondsPerDrop,
          actualGttPerMinute: comparison?.actualGttPerMinute,
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
          Text(
            result.mlPerHour.toStringAsFixed(1),
            key: const Key('mlPerHourValue'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const Text(
            'mL/hr',
            style: TextStyle(
              color: Color(0xFF64B5F6),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '계산값 ${result.gttPerMinute.toStringAsFixed(1)} gtt/min',
            key: const Key('gttPerMinuteValue'),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
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
        ],
      ),
    );
  }
}

class _ComparisonBanner extends StatelessWidget {
  const _ComparisonBanner({required this.comparison});

  final InfusionComparison comparison;

  @override
  Widget build(BuildContext context) {
    final (color, icon, title, message) = switch (comparison.pace) {
      InfusionPace.tooSlow => (
        const Color(0xFFD97706),
        Icons.south_rounded,
        '목표보다 느려요',
        '목표보다 ${comparison.differencePercent.abs().toStringAsFixed(0)}% 적게 떨어지고 있어요.',
      ),
      InfusionPace.onTarget => (
        const Color(0xFF16836E),
        Icons.check_circle_outline,
        '적정 범위예요',
        '계산 목표와 ±10% 이내로 일치해요.',
      ),
      InfusionPace.tooFast => (
        const Color(0xFFC2413B),
        Icons.north_rounded,
        '목표보다 빨라요',
        '목표보다 ${comparison.differencePercent.abs().toStringAsFixed(0)}% 많이 떨어지고 있어요.',
      ),
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const Key('comparisonBanner'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.32)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: color, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(message),
                ],
              ),
            ),
          ],
        ),
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
