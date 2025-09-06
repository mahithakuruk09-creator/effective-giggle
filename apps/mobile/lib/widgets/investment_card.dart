import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InvestmentCard extends StatelessWidget {
  final String risk; // Low/Med/High
  final double apr; // %
  final int available; // GBP
  final VoidCallback onInvest;
  const InvestmentCard({super.key, required this.risk, required this.apr, required this.available, required this.onInvest});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(_iconFor(risk)),
            const SizedBox(width: 8),
            Text('$risk risk', style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: CustomPaint(
              painter: _AprDial(apr / 30.0),
              child: Center(child: Text('${apr.toStringAsFixed(1)}% APR')),
            ),
          ),
          const SizedBox(height: 8),
          Text('Available £$available', style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
          AppButtons.primary(label: 'Invest', icon: Icons.trending_up, onPressed: onInvest),
        ],
      ),
    );
  }

  IconData _iconFor(String r) {
    switch (r.toLowerCase()) {
      case 'low':
        return Icons.shield_moon_outlined;
      case 'high':
        return Icons.local_fire_department_outlined;
      default:
        return Icons.speed;
    }
  }
}

class _AprDial extends CustomPainter {
  final double progress; // 0..1 (approx map of APR/30%)
  _AprDial(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = -math.pi * 0.75;
    const sweep = math.pi * 1.5;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = Colors.white.withOpacity(0.08)
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, sweep, false, base);
    final grad = SweepGradient(startAngle: start, endAngle: start + sweep, colors: const [AppColors.accentStart, AppColors.accentEnd]);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..shader = grad.createShader(rect)
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, sweep * progress.clamp(0, 1), false, p);
  }
  @override
  bool shouldRepaint(covariant _AprDial oldDelegate) => oldDelegate.progress != progress;
}

