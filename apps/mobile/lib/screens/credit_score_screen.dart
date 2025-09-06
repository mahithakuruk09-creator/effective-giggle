import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../widgets/credit_score_dial.dart';
import '../widgets/insight_card.dart';
import '../widgets/score_simulator.dart';

// Data models
class CreditScoreData {
  final int score;
  final String band;
  final String lastRefreshed; // YYYY-MM-DD
  const CreditScoreData({required this.score, required this.band, required this.lastRefreshed});
  factory CreditScoreData.fromJson(Map<String, dynamic> j) =>
      CreditScoreData(score: (j['score'] as num).toInt(), band: j['band'] as String, lastRefreshed: j['last_refreshed'] as String);
}

class CreditInsight {
  final String factor;
  final String value;
  final String recommendation;
  const CreditInsight({required this.factor, required this.value, required this.recommendation});
  factory CreditInsight.fromJson(Map<String, dynamic> j) =>
      CreditInsight(factor: j['factor'] as String, value: j['value'] as String, recommendation: j['recommendation'] as String);
}

class CreditSimulationResult {
  final int projectedScore;
  final String band;
  const CreditSimulationResult({required this.projectedScore, required this.band});
  factory CreditSimulationResult.fromJson(Map<String, dynamic> j) =>
      CreditSimulationResult(projectedScore: (j['projected_score'] as num).toInt(), band: j['band'] as String);
}

// Repository
abstract class CreditRepository {
  Future<CreditScoreData?> score();
  Future<List<CreditInsight>> insights();
  Future<CreditSimulationResult> simulate(List<String> actions);
}

class CreditRepositoryHttp implements CreditRepository {
  final String baseUrl;
  const CreditRepositoryHttp({this.baseUrl = 'http://localhost:8000'});

  @override
  Future<List<CreditInsight>> insights() async {
    final r = await http.get(Uri.parse('$baseUrl/credit/insights'));
    if (r.statusCode >= 400) throw Exception('insights failed');
    final data = jsonDecode(r.body) as List<dynamic>;
    return data.map((e) => CreditInsight.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<CreditScoreData?> score() async {
    final r = await http.get(Uri.parse('$baseUrl/credit/score'));
    if (r.statusCode == 204) return null;
    if (r.statusCode >= 400) throw Exception('score failed');
    return CreditScoreData.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  @override
  Future<CreditSimulationResult> simulate(List<String> actions) async {
    final r = await http.post(Uri.parse('$baseUrl/credit/simulate'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode({'actions': actions}));
    if (r.statusCode >= 400) throw Exception('simulate failed');
    return CreditSimulationResult.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }
}

class CreditRepositoryFake implements CreditRepository {
  CreditScoreData _score = const CreditScoreData(score: 725, band: 'Good', lastRefreshed: '2025-09-05');
  final List<CreditInsight> _insights = const [
    CreditInsight(factor: 'utilisation', value: '42%', recommendation: 'Reduce below 30%'),
    CreditInsight(factor: 'payment_history', value: '98%', recommendation: 'Maintain on-time payments'),
    CreditInsight(factor: 'length_of_history', value: '5y 4m', recommendation: 'Keep accounts open to age'),
    CreditInsight(factor: 'enquiries', value: '1 in 6m', recommendation: 'Limit new applications'),
    CreditInsight(factor: 'mix', value: 'Cards, Loan', recommendation: 'Diverse mix helps'),
  ];

  @override
  Future<List<CreditInsight>> insights() async => _insights;

  @override
  Future<CreditScoreData?> score() async => _score;

  @override
  Future<CreditSimulationResult> simulate(List<String> actions) async {
    int s = _score.score;
    for (final a in actions) {
      switch (a) {
        case 'pay_500':
          s += 12;
          break;
        case 'reduce_utilisation':
          s += 22;
          break;
        case 'close_oldest':
          s -= 18;
          break;
        case 'add_new_line':
          s -= 8;
          break;
      }
    }
    s = s.clamp(0, 999);
    final band = _bandFor(s);
    _score = CreditScoreData(score: s, band: band, lastRefreshed: _score.lastRefreshed);
    return CreditSimulationResult(projectedScore: s, band: band);
  }
}

String _bandFor(int s) {
  if (s >= 880) return 'Excellent';
  if (s >= 740) return 'Very Good';
  if (s >= 670) return 'Good';
  if (s >= 560) return 'Fair';
  return 'Poor';
}

final creditRepositoryProvider = Provider<CreditRepository>((ref) => CreditRepositoryHttp());
final creditScoreProvider = FutureProvider<CreditScoreData?>((ref) async => ref.read(creditRepositoryProvider).score());
final creditInsightsProvider = FutureProvider<List<CreditInsight>>((ref) async => ref.read(creditRepositoryProvider).insights());

class CreditScoreScreen extends ConsumerStatefulWidget {
  const CreditScoreScreen({super.key});

  @override
  ConsumerState<CreditScoreScreen> createState() => _CreditScoreScreenState();
}

class _CreditScoreScreenState extends ConsumerState<CreditScoreScreen> {
  int _displayed = 0;
  String _band = '';
  String _last = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ref.read(creditRepositoryProvider).score();
      if (data != null && mounted) {
        setState(() {
          _displayed = data.score;
          _band = data.band;
          _last = data.lastRefreshed;
        });
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't fetch credit score. Retry.")));
    }
  }

  Future<void> _simulate(List<String> actions) async {
    try {
      final res = await ref.read(creditRepositoryProvider).simulate(actions);
      if (!mounted) return;
      setState(() {
        _displayed = res.projectedScore;
        _band = res.band;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Score updated')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simulation failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final insights = ref.watch(creditInsightsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Credit Score & Insights')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CreditScoreDial(score: _displayed),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Band: ${_band.isEmpty ? _bandFor(_displayed) : _band}'),
                Text('Last refreshed: ${_last.isEmpty ? '—' : _last}')
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: insights.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: TextButton(onPressed: () => ref.refresh(creditInsightsProvider), child: const Text('Retry')),
                ),
                data: (list) => list.isEmpty
                    ? const Center(child: Text('Link a bank to fetch your credit score.'))
                    : ListView(
                        children: [
                          ...list.map((i) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InsightCard(factor: i.factor, value: i.value, recommendation: i.recommendation),
                              )),
                          const SizedBox(height: 8),
                          ScoreSimulator(onSimulate: _simulate),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => showModalBottomSheet(
                                context: context,
                                showDragHandle: true,
                                builder: (_) => const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('Tips: Keep utilisation low, pay on time, avoid frequent hard searches.'),
                                ),
                              ),
                              child: const Text('Get More Tips'),
                            ),
                          ),
                        ],
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

 
