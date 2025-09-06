import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'repo.dart';
import 'widgets.dart';

final insightsRepoProvider = Provider<InsightsRepo>((_) => InsightsRepoHttp());
final insightsBundleProvider = FutureProvider((ref) => ref.read(insightsRepoProvider).spending());

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref){
    final data = ref.watch(insightsBundleProvider);
    SpendingCategory? hovered;
    return Scaffold(appBar: AppBar(title: const Text('Spending Insights')), body: data.when(
      loading: ()=> const Center(child:CircularProgressIndicator()),
      error: (e,_)=> Center(child: TextButton(onPressed: ()=> ref.refresh(insightsBundleProvider), child: const Text('Retry'))),
      data: (b)=> Padding(padding: const EdgeInsets.all(16), child: ListView(children:[
        GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[ const Text("This Month's Spend", style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height:8), Text('Total £${b.categories.fold<int>(0,(s,c)=> s + c.amount)}') ])),
        const SizedBox(height: 12),
        GlassCard(child: Padding(padding: const EdgeInsets.all(8.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[ const Text('Categories'), const SizedBox(height: 8), AnimatedPieChart(categories: b.categories, onHover: (c){ hovered = c; }), const SizedBox(height: 8), Wrap(spacing: 8, runSpacing: 4, children: [ for(final c in b.categories) Chip(label: Text('${c.category}  ${(c.percentage*100).toStringAsFixed(0)}%')) ]), if(hovered!=null) Padding(padding: const EdgeInsets.only(top:8), child: Text('${hovered!.category}: £${hovered!.amount}')) ]))),
        const SizedBox(height: 12),
        GlassCard(child: Padding(padding: const EdgeInsets.all(8.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[ const Text('3-Month Trend'), const SizedBox(height:6), AnimatedTrendLine(trends: b.trends) ]))),
        const SizedBox(height: 12),
        AvgVsMonthBars(monthTotal: b.trends.last.total, avgTotal: (b.trends.map((e)=>e.total).reduce((a,b)=>a+b) / b.trends.length).round()),
        const SizedBox(height: 12),
        const Text('Smart Tips', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        ...b.tips.map((t)=> Padding(padding: const EdgeInsets.only(bottom:8), child: TipCard(tip: t)))
      ])),
    ));
  }
}
