import 'dart:math' as math;

import 'package:flutter/material.dart';

const Duration minimumDripCycleDuration = Duration(milliseconds: 100);
const Duration invalidDripCycleDuration = Duration(seconds: 1);

Duration dripCycleDuration(double secondsPerDrop) {
  if (!secondsPerDrop.isFinite || secondsPerDrop <= 0) {
    return invalidDripCycleDuration;
  }
  final microseconds = (secondsPerDrop * Duration.microsecondsPerSecond)
      .round();
  if (microseconds < minimumDripCycleDuration.inMicroseconds) {
    return minimumDripCycleDuration;
  }
  return Duration(microseconds: microseconds);
}

class AnimatedDripChamber extends StatefulWidget {
  const AnimatedDripChamber({super.key, required this.secondsPerDrop});

  final double secondsPerDrop;

  @override
  State<AnimatedDripChamber> createState() => _AnimatedDripChamberState();
}

class _AnimatedDripChamberState extends State<AnimatedDripChamber>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  late Duration _cycleDuration;
  bool _isRunning = false;

  bool get _usesApproximateCycle =>
      widget.secondsPerDrop.isFinite &&
      widget.secondsPerDrop > 0 &&
      widget.secondsPerDrop <
          minimumDripCycleDuration.inMicroseconds /
              Duration.microsecondsPerSecond;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cycleDuration = dripCycleDuration(widget.secondsPerDrop);
    _controller = AnimationController(vsync: this, duration: _cycleDuration);
    _startFromBeginning();
  }

  @override
  void didUpdateWidget(covariant AnimatedDripChamber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.secondsPerDrop != widget.secondsPerDrop) {
      _cycleDuration = dripCycleDuration(widget.secondsPerDrop);
      _controller.duration = _cycleDuration;
      _startFromBeginning();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _startFromBeginning();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _controller
          ..stop()
          ..value = 0;
        _isRunning = false;
    }
  }

  void _startFromBeginning() {
    _controller
      ..stop()
      ..value = 0
      ..repeat(period: _cycleDuration);
    _isRunning = true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final validSeconds =
        widget.secondsPerDrop.isFinite && widget.secondsPerDrop > 0
        ? widget.secondsPerDrop
        : _cycleDuration.inMicroseconds / Duration.microsecondsPerSecond;
    final gttPerMinute = 60 / validSeconds;
    return Semantics(
      label: '계산된 수액 점적 챔버',
      child: RepaintBoundary(
        key: const Key('animatedDripChamber'),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF6FAFE),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD9E5F0)),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final progress = _isRunning ? _controller.value : 0.0;
              final remainingSeconds = math.max(
                0,
                (1 - progress) * validSeconds,
              );
              return Column(
                children: [
                  SizedBox(
                    width: 190,
                    height: 310,
                    child: CustomPaint(
                      key: const Key('dripChamberPaint'),
                      painter: DripChamberPainter(
                        progress: progress,
                        cycleSeconds:
                            _cycleDuration.inMicroseconds /
                            Duration.microsecondsPerSecond,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '다음 방울까지 ${remainingSeconds.toStringAsFixed(1)}초',
                    key: const Key('dropCountdown'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF17324D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${gttPerMinute.toStringAsFixed(1)} gtt/min · '
                    '${validSeconds.toStringAsFixed(1)}초 간격',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (_usesApproximateCycle) ...[
                    const SizedBox(height: 5),
                    const Text(
                      '매우 빠른 속도로 애니메이션은 근사 표시됩니다.',
                      style: TextStyle(color: Color(0xFF9A6B0A), fontSize: 11),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class DripChamberPainter extends CustomPainter {
  const DripChamberPainter({
    required this.progress,
    required this.cycleSeconds,
  });

  final double progress;
  final double cycleSeconds;

  static const double _preferredMotionSeconds = 0.62;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;
    final outline = Paint()
      ..color = const Color(0xFF8DA3B6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    final softOutline = Paint()
      ..color = const Color(0xFFC7D5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final fluid = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFDAF0FC), Color(0xFFA8D8F2)],
      ).createShader(Rect.fromLTWH(0, 202, size.width, 75));

    _paintTubing(canvas, size, center, outline);

    final chamberRect = Rect.fromLTWH(35, 47, size.width - 70, 218);
    final chamber = RRect.fromRectAndRadius(
      chamberRect,
      const Radius.circular(38),
    );
    canvas.drawRRect(
      chamber,
      Paint()..color = Colors.white.withValues(alpha: .7),
    );
    canvas.drawRRect(chamber, outline);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        chamberRect.deflate(6),
        const Radius.circular(32),
      ),
      softOutline,
    );

    const surfaceY = 205.0;
    final fluidShape = Path()
      ..moveTo(42, surfaceY)
      ..quadraticBezierTo(center, surfaceY + 4, size.width - 42, surfaceY)
      ..lineTo(size.width - 42, 242)
      ..quadraticBezierTo(size.width - 42, 258, size.width - 58, 259)
      ..lineTo(58, 259)
      ..quadraticBezierTo(42, 258, 42, 242)
      ..close();
    canvas.drawPath(fluidShape, fluid);
    canvas.drawPath(
      Path()
        ..moveTo(42, surfaceY)
        ..quadraticBezierTo(center, surfaceY + 4, size.width - 42, surfaceY),
      Paint()
        ..color = const Color(0xFF65AFD6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    _paintHighlights(canvas, chamberRect);
    _paintDrop(canvas, center, surfaceY);
  }

  void _paintTubing(Canvas canvas, Size size, double center, Paint outline) {
    canvas.drawLine(Offset(center, 0), Offset(center, 25), outline);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center, 32), width: 48, height: 18),
        const Radius.circular(7),
      ),
      outline,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center, 48), width: 22, height: 25),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFFD4E0E9),
    );
    canvas.drawLine(
      Offset(center, 49),
      Offset(center, 69),
      Paint()
        ..color = const Color(0xFF7790A5)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(Offset(center, 265), Offset(center, size.height), outline);
  }

  void _paintHighlights(Canvas canvas, Rect chamberRect) {
    canvas.drawArc(
      Rect.fromLTWH(
        chamberRect.left + 12,
        chamberRect.top + 20,
        20,
        chamberRect.height - 52,
      ),
      math.pi * .65,
      math.pi * .65,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: .9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    for (var i = 0; i < 3; i++) {
      final y = 165.0 + i * 12;
      canvas.drawLine(
        Offset(chamberRect.right - 15, y),
        Offset(chamberRect.right - 9, y),
        Paint()
          ..color = const Color(0xFFB7C8D5)
          ..strokeWidth = 1.3,
      );
    }
  }

  void _paintDrop(Canvas canvas, double center, double surfaceY) {
    final motionFraction = math.min(
      1.0,
      _preferredMotionSeconds / cycleSeconds,
    );
    if (progress > motionFraction) return;

    final motionProgress = (progress / motionFraction).clamp(0.0, 1.0);
    const nozzleY = 69.0;

    if (motionProgress < .28) {
      final growth = Curves.easeIn.transform(motionProgress / .28);
      _drawDrop(
        canvas,
        Offset(center, nozzleY + 5 + growth * 5),
        2.8 + growth * 4.3,
      );
      return;
    }

    if (motionProgress < .9) {
      final fall = Curves.easeIn.transform((motionProgress - .28) / .62);
      _drawDrop(
        canvas,
        Offset(center, nozzleY + 13 + fall * (surfaceY - nozzleY - 19)),
        7 - fall * 1.5,
      );
      return;
    }

    final impact = ((motionProgress - .9) / .1).clamp(0.0, 1.0);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center, surfaceY + 2),
        width: 8 + impact * 28,
        height: 3 + impact * 4,
      ),
      Paint()
        ..color = const Color(0xFF389BD0).withValues(alpha: 1 - impact)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawDrop(Canvas canvas, Offset center, double radius) {
    final bounds = Rect.fromCircle(center: center, radius: radius * 1.35);
    final path = Path()
      ..moveTo(center.dx, center.dy - radius * 1.55)
      ..cubicTo(
        center.dx - radius * 1.1,
        center.dy - radius * .15,
        center.dx - radius,
        center.dy + radius,
        center.dx,
        center.dy + radius * 1.15,
      )
      ..cubicTo(
        center.dx + radius,
        center.dy + radius,
        center.dx + radius * 1.1,
        center.dy - radius * .15,
        center.dx,
        center.dy - radius * 1.55,
      );
    canvas.drawPath(
      path,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.35, -.4),
          colors: [Color(0xFFF7FDFF), Color(0xFF67C7F0), Color(0xFF168BC4)],
        ).createShader(bounds),
    );
  }

  @override
  bool shouldRepaint(covariant DripChamberPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.cycleSeconds != cycleSeconds;
  }
}
