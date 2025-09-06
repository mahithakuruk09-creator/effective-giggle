import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CreditScoreDial extends StatelessWidget {
  final int score; // 0-999
  final int maxScore;
  final Duration duration;
  const CreditScoreDial({super.key, required this.score, this.maxScore = 999, this.duration = const Duration(milliseconds: 900)});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      height: 200,
      radius: 24,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: score.toDouble()),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          final p = (value / maxScore).clamp(0, 1);
          return CustomPaint(
            painter: _DialPainter(progress: p),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(value.toInt().toString(), style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('UK Credit Score'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  final double progress; // 0..1
  _DialPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 12;

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..color = Colors.white.withOpacity(0.08)
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw base arc (240 degrees)
    const start = math.pi * 0.9; // 162°
    const sweep = math.pi * 1.4; // ~252°
    canvas.drawArc(rect, start, sweep, false, base);

    // Progress arc with gradient
    final gradient = SweepGradient(
      startAngle: start,
      endAngle: start + sweep,
      colors: const [AppColors.accentStart, AppColors.accentEnd],
    );
    final prog = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, start, sweep * progress, false, prog);
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) => oldDelegate.progress != progress;
}

