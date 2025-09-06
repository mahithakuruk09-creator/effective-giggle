import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../widgets/loan_offer_card.dart';
import '../theme/app_theme.dart';
import 'loan_application_screen.dart';
import 'p2p_investor_screen.dart';

class LoanOffer {
  final String id;
  final double apr;
  final int amount;
  final int termMonths;
  final int monthly;
  const LoanOffer({required this.id, required this.apr, required this.amount, required this.termMonths, required this.monthly});
  factory LoanOffer.fromJson(Map<String, dynamic> j) => LoanOffer(
      id: j['id'] as String,
      apr: (j['apr'] as num).toDouble(),
      amount: (j['amount'] as num).toInt(),
      termMonths: (j['term_months'] as num).toInt(),
      monthly: (j['monthly_repayment'] as num).toInt());
}

abstract class LoansRepository {
  Future<List<LoanOffer>> offers();
}

class LoansRepositoryHttp implements LoansRepository {
  final String baseUrl;
  const LoansRepositoryHttp({this.baseUrl = 'http://localhost:8000'});
  @override
  Future<List<LoanOffer>> offers() async {
    final r = await http.get(Uri.parse('$baseUrl/loans/offers'));
    if (r.statusCode >= 400) throw Exception('offers failed');
    final data = (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
    return data.map(LoanOffer.fromJson).toList();
  }
}

class LoansRepositoryFake implements LoansRepository {
  @override
  Future<List<LoanOffer>> offers() async => const [
        LoanOffer(id: 'lo_001', apr: 12.9, amount: 5000, termMonths: 24, monthly: 237),
        LoanOffer(id: 'lo_002', apr: 8.5, amount: 8000, termMonths: 36, monthly: 252),
        LoanOffer(id: 'lo_003', apr: 17.9, amount: 2000, termMonths: 12, monthly: 185),
      ];
}

final loansRepositoryProvider = Provider<LoansRepository>((ref) => LoansRepositoryHttp());
final loanOffersProvider = FutureProvider<List<LoanOffer>>((ref) async => ref.read(loansRepositoryProvider).offers());

class LoansScreen extends ConsumerWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(loanOffersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Loans & P2P Lending')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GlassCard(
            child: Row(children: const [
              Icon(Icons.verified, color: Colors.greenAccent),
              SizedBox(width: 8),
              Expanded(child: Text('You may be eligible for personalised loan offers')),
            ]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 170,
            child: offers.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: TextButton(onPressed: () => ref.refresh(loanOffersProvider), child: const Text('Retry'))),
              data: (list) => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) => LoanOfferCard(
                  id: list[i].id,
                  apr: list[i].apr,
                  amount: list[i].amount,
                  termMonths: list[i].termMonths,
                  monthlyRepayment: list[i].monthly,
                  onApply: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoanApplicationScreen(defaultAmount: list[i].amount, defaultTerm: list[i].termMonths))),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: AppButtons.primary(label: 'Apply for Loan', icon: Icons.request_page, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoanApplicationScreen())))),
            const SizedBox(width: 12),
            Expanded(child: AppButtons.primary(label: 'Explore P2P Lending', icon: Icons.timeline, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const P2PInvestorScreen())))),
          ]),
        ]),
      ),
    );
  }
}

 
