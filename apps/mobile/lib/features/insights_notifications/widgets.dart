import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'repo.dart';

class AnimatedPieChart extends StatelessWidget {
  final List<SpendingCategory> categories;
  final ValueChanged<SpendingCategory?>? onHover;
  const AnimatedPieChart({super.key, required this.categories, this.onHover});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0, end: 1),
      builder: (context, v, _) => GestureDetector(
        onTapDown: (d){
          final tapped = _hitTest(d.localPosition, categories, const Size(double.infinity, 180));
          if(onHover!=null) onHover!(tapped);
        },
        child: CustomPaint(size: const Size(double.infinity, 180), painter: _PiePainter(categories, v)),
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<SpendingCategory> cats; final double progress;
  _PiePainter(this.cats, this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final center = Offset(size.width/2, size.height/2);
    final arcRect = Rect.fromCircle(center: center, radius: radius);
    double start = -math.pi/2;
    final colors = [Colors.purpleAccent, Colors.blueAccent, Colors.cyanAccent, Colors.orangeAccent, Colors.tealAccent];
    for (int i=0;i<cats.length;i++){
      final sweep = (cats[i].percentage * 2*math.pi) * progress;
      final p = Paint()..style = PaintingStyle.stroke..strokeWidth = radius..strokeCap = StrokeCap.butt..shader = SweepGradient(colors:[colors[i%colors.length].withOpacity(0.9), colors[i%colors.length].withOpacity(0.6)], startAngle: start, endAngle: start+sweep).createShader(arcRect);
      canvas.drawArc(arcRect, start, sweep, false, p);
      start += cats[i].percentage * 2*math.pi;
    }
  }
  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate)=> oldDelegate.progress!=progress || oldDelegate.cats!=cats;
}

SpendingCategory? _hitTest(Offset p, List<SpendingCategory> cats, Size size){
  // Simple hit test by angle only; assumes chart centered horizontally
  final center = Offset(size.width/2, size.height/2);
  final v = p - center; if (v.distance == 0) return null;
  var ang = math.atan2(v.dy, v.dx);
  if (ang < -math.pi/2) ang += 2*math.pi; // normalize around start
  double start = -math.pi/2;
  for(final c in cats){
    final sweep = c.percentage * 2*math.pi;
    if (ang >= start && ang <= start + sweep) return c; start += sweep;
  }
  return null;
}

class AnimatedTrendLine extends StatelessWidget {
  final List<SpendingTrend> trends;
  const AnimatedTrendLine({super.key, required this.trends});
  @override
  Widget build(BuildContext context){
    return TweenAnimationBuilder<double>(duration: const Duration(milliseconds: 900), tween: Tween(begin:0, end:1), builder:(c,v,_)=> CustomPaint(size: const Size(double.infinity, 120), painter: _TrendPainter(trends, v)));
  }
}

class _TrendPainter extends CustomPainter {
  final List<SpendingTrend> t; final double p;
  _TrendPainter(this.t,this.p);
  @override
  void paint(Canvas canvas, Size size){
    if(t.isEmpty) return;
    final maxVal = t.map((e)=>e.total).reduce(math.max).toDouble();
    final dx = size.width / (t.length-1);
    final path = Path();
    for(int i=0;i<t.length;i++){
      final x = i*dx; final y = size.height - (t[i].total / maxVal) * size.height;
      if(i==0) path.moveTo(x,y); else path.lineTo(x,y);
    }
    final drawPath = PathMetrics().addPath(path).first.extractPath(0, PathMetrics().addPath(path).first.length * p);
    final paint = Paint()..style=PaintingStyle.stroke..strokeWidth=3..shader = const LinearGradient(colors:[AppColors.accentStart, AppColors.accentEnd]).createShader(Rect.fromLTWH(0,0,size.width,size.height));
    canvas.drawPath(drawPath, paint);
  }
  @override bool shouldRepaint(covariant _TrendPainter old)=> old.p!=p || old.t!=t;
}

class TipCard extends StatelessWidget {
  final Tip tip; const TipCard({super.key, required this.tip});
  @override
  Widget build(BuildContext context){
    return GlassCard(child: Row(children:[ const Icon(Icons.lightbulb_outline), const SizedBox(width:8), Expanded(child: Text(tip.text)) ]));
  }
}

class AvgVsMonthBars extends StatelessWidget {
  final int monthTotal; final int avgTotal;
  const AvgVsMonthBars({super.key, required this.monthTotal, required this.avgTotal});
  @override
  Widget build(BuildContext context){
    final maxVal = (monthTotal > avgTotal ? monthTotal : avgTotal).toDouble().clamp(1, double.infinity);
    double h(int v) => 120 * (v / maxVal);
    return GlassCard(child: Padding(padding: const EdgeInsets.all(12), child: Row(crossAxisAlignment: CrossAxisAlignment.end, children:[
      Expanded(child: _bar(context, 'This month', monthTotal, h(monthTotal), Colors.purpleAccent)), const SizedBox(width: 12),
      Expanded(child: _bar(context, '3‑mo avg', avgTotal, h(avgTotal), Colors.blueAccent)),
    ])));
  }
  Widget _bar(BuildContext c, String label, int val, double height, Color color){
    return Column(mainAxisSize: MainAxisSize.min, children:[ Container(height: height, decoration: BoxDecoration(color: color.withOpacity(0.5), borderRadius: BorderRadius.circular(12))), const SizedBox(height: 6), Text('$label  £$val', style: Theme.of(c).textTheme.bodySmall) ]);
  }
}
