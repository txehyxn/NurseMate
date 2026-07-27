import 'package:flutter/material.dart';

class DripChamberVisual extends StatelessWidget {
  const DripChamberVisual({
    super.key,
    required this.secondsPerDrop,
    this.actualGttPerMinute,
  });

  final double secondsPerDrop;
  final double? actualGttPerMinute;

  @override
  Widget build(BuildContext context) {
    final targetGtt = 60 / secondsPerDrop;
    return Semantics(
      label: actualGttPerMinute == null ? '계산된 목표 수액 챔버' : '계산 챔버와 실제 챔버 비교',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 430;
          final chambers = [
            _ChamberColumn(
              title: '계산 챔버',
              value: targetGtt,
              subtitle: '${secondsPerDrop.toStringAsFixed(1)}초마다 1방울',
              color: const Color(0xFF2166D1),
            ),
            if (actualGttPerMinute != null)
              _ChamberColumn(
                title: '실제 챔버',
                value: actualGttPerMinute!,
                subtitle: '${actualGttPerMinute!.toStringAsFixed(0)}방울/분',
                color: const Color(0xFF14A38B),
              ),
          ];
          return compact && chambers.length > 1
              ? Column(
                  children: [
                    chambers.first,
                    const SizedBox(height: 20),
                    chambers.last,
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: chambers
                      .map((chamber) => Expanded(child: chamber))
                      .toList(),
                );
        },
      ),
    );
  }
}

class _ChamberColumn extends StatelessWidget {
  const _ChamberColumn({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final double value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        SizedBox(
          width: 112,
          height: 190,
          child: CustomPaint(
            painter: _DripChamberPainter(color: color, rate: value),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${value.toStringAsFixed(1)} gtt/min',
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _DripChamberPainter extends CustomPainter {
  const _DripChamberPainter({required this.color, required this.rate});

  final Color color;
  final double rate;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()
      ..color = const Color(0xFF91A4B7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final fluid = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final accent = Paint()..color = color;

    final center = size.width / 2;
    canvas.drawLine(Offset(center, 0), Offset(center, 24), outline);
    canvas.drawLine(Offset(center - 12, 24), Offset(center + 12, 24), outline);

    final chamber = RRect.fromRectAndRadius(
      Rect.fromLTWH(18, 25, size.width - 36, 132),
      const Radius.circular(24),
    );
    canvas.drawRRect(chamber, outline);

    final level = 112 - (rate.clamp(0, 120) / 120 * 24);
    final fluidRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(20, level, size.width - 20, 155),
      bottomLeft: const Radius.circular(22),
      bottomRight: const Radius.circular(22),
    );
    canvas.drawRRect(fluidRect, fluid);
    canvas.drawLine(
      Offset(22, level),
      Offset(size.width - 22, level),
      Paint()
        ..color = color
        ..strokeWidth = 2,
    );

    final dropPath = Path()
      ..moveTo(center, 49)
      ..cubicTo(center - 9, 62, center - 8, 73, center, 76)
      ..cubicTo(center + 8, 73, center + 9, 62, center, 49);
    canvas.drawPath(dropPath, accent);

    canvas.drawLine(Offset(center, 157), Offset(center, size.height), outline);
  }

  @override
  bool shouldRepaint(covariant _DripChamberPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.rate != rate;
  }
}
