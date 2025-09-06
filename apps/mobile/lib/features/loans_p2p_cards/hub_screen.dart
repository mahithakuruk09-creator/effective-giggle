import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../shop/repo.dart';
import '../../widgets/investment_card.dart';
import '../../widgets/loan_offer_card.dart';
import '../../screens/loan_application_screen.dart';

// --- Reuse HTTP for servers ---
import 'package:http/http.dart' as http;

// Loans repo
class LoansHubRepository {
  final String baseUrl;
  LoansHubRepository({this.baseUrl = 'http://localhost:8000'});
  Future<List<Map<String, dynamic>>> offers() async {
    final r = await http.get(Uri.parse('$baseUrl/loans/offers'));
    if (r.statusCode >= 400) throw Exception('offers');
    return (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
  }
  Future<Map<String, dynamic>> p2pPortfolio() async {
    final r = await http.get(Uri.parse('$baseUrl/p2p/portfolio'));
    if (r.statusCode >= 400) throw Exception('portfolio');
    return jsonDecode(r.body) as Map<String, dynamic>;
  }
  Future<List<Map<String, dynamic>>> p2pPools() async {
    final r = await http.get(Uri.parse('$baseUrl/p2p/pools'));
    if (r.statusCode >= 400) throw Exception('pools');
    return (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
  }
  Future<void> p2pInvest(String id, int amount) async {
    final r = await http.post(Uri.parse('$baseUrl/p2p/invest'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'pool_id': id, 'amount': amount}));
    if (r.statusCode >= 400) throw Exception('invest');
  }
  Future<List<Map<String, dynamic>>> cardOffers() async {
    final r = await http.get(Uri.parse('$baseUrl/cards/offers'));
    if (r.statusCode >= 400) throw Exception('card offers');
    return (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
  }
  Future<Map<String, dynamic>> applyCard(String offerId) async {
    final r = await http.post(Uri.parse('$baseUrl/cards/apply'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'offer_id': offerId}));
    if (r.statusCode >= 400) throw Exception('card apply');
    return jsonDecode(r.body) as Map<String, dynamic>;
  }
}

final loansHubRepoProvider = Provider<LoansHubRepository>((_) => LoansHubRepository());

class LoansP2PCardsHub extends ConsumerWidget {
  const LoansP2PCardsHub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: const Text('Loans Hub'), bottom: const TabBar(tabs: [Tab(text: 'Borrow'), Tab(text: 'Invest'), Tab(text: 'Credit Cards')],)),
        body: const TabBarView(children: [ _BorrowTab(), _InvestTab(), _CardsTab() ]),
      ),
    );
  }
}

class _BorrowTab extends ConsumerWidget {
  const _BorrowTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(loansHubRepoProvider);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: repo.offers(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final list = snap.data!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children:[
            GlassCard(child: Row(children: const [Icon(Icons.verified), SizedBox(width:8), Expanded(child: Text('Check your eligibility in minutes'))])),
            const SizedBox(height: 12),
            SizedBox(height: 180, child: ListView.separated(scrollDirection: Axis.horizontal, itemBuilder: (c,i)=> LoanOfferCard(id: list[i]['id'], apr: (list[i]['apr'] as num).toDouble(), amount: (list[i]['amount'] as num).toInt(), termMonths: (list[i]['term_months'] as num).toInt(), monthlyRepayment: (list[i]['monthly_repayment'] as num).toInt(), onApply: () => Navigator.push(context, MaterialPageRoute(builder: (_)=> const LoanApplicationScreen()))), separatorBuilder: (_, __)=> const SizedBox(width:12), itemCount: list.length)),
          ]),
        );
      },
    );
  }
}

class _InvestTab extends ConsumerWidget {
  const _InvestTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(loansHubRepoProvider);
    return FutureBuilder<Map<String, dynamic>>(
      future: repo.p2pPortfolio(),
      builder: (context, pf) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children:[
            GlassCard(child: Row(children: [const Icon(Icons.account_balance_wallet), const SizedBox(width:8), Expanded(child: Text('Invested £${pf.data?['invested'] ?? 0} • Expected ${(pf.data?['expected_return'] ?? 0).toString()} p.a.'))])),
            const SizedBox(height: 12),
            Expanded(child: FutureBuilder<List<Map<String, dynamic>>>(
              future: repo.p2pPools(),
              builder:(context, pools){
                if(!pools.hasData) return const Center(child:CircularProgressIndicator());
                final list = pools.data!;
                return ListView.separated(scrollDirection: Axis.horizontal, itemCount: list.length, separatorBuilder: (_, __)=> const SizedBox(width: 12), itemBuilder:(c,i)=> InvestmentCard(risk:list[i]['risk'], apr:(list[i]['apr'] as num).toDouble(), available:(list[i]['available'] as num).toInt(), onInvest: () async { await repo.p2pInvest(list[i]['id'], 500); if(c.mounted) ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('Investment added'))); }));
              },
            ))
          ]),
        );
      }
    );
  }
}

class _CardsTab extends ConsumerWidget {
  const _CardsTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(loansHubRepoProvider);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: repo.cardOffers(),
      builder: (context, snap){
        if(!snap.hasData) return const Center(child:CircularProgressIndicator());
        final list = snap.data!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children:[
            SizedBox(height: 200, child: _CardsCarousel(offers: list, onApply: (off) async { final res = await repo.applyCard(off); if(context.mounted){ showModalBottomSheet(context: context, showDragHandle: true, builder: (_) => Padding(padding: const EdgeInsets.all(16), child: Text('Application ${res['decision']}'))); } })),
          ]),
        );
      },
    );
  }
}

class _CardsCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> offers; final Future<void> Function(String offerId) onApply;
  const _CardsCarousel({required this.offers, required this.onApply});
  @override State<_CardsCarousel> createState()=> _CardsCarouselState();
}
class _CardsCarouselState extends State<_CardsCarousel>{
  final PageController _pc = PageController(viewportFraction: 0.86);
  @override Widget build(BuildContext context){
    return PageView.builder(controller: _pc, itemCount: widget.offers.length, itemBuilder:(c,i){ final off=widget.offers[i]; return AnimatedBuilder(animation: _pc, builder:(ctx,child){ double delta=0; if(_pc.position.haveDimensions){ delta = (_pc.page ?? _pc.initialPage.toDouble()) - i; } final angle = delta * 0.18; final scale = 1 - (delta.abs()*0.08).clamp(0,.2); return Transform(alignment: Alignment.center, transform: Matrix4.identity()..setEntry(3,2,0.001)..rotateY(angle)..scale(scale), child: child); }, child: GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[ Text(off['name'], style: const TextStyle(fontWeight: FontWeight.w700)), const Spacer(), Text('APR ${off['apr']}%  •  Limit £${off['limit']}'), Text('Annual fee £${off['annual_fee']}'), const SizedBox(height:8), AppButtons.primary(label: 'Apply', icon: Icons.arrow_forward, onPressed: () => widget.onApply(off['id'])) ])) ); });
  }
}
