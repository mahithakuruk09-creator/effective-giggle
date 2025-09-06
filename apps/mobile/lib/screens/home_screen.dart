import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../models/pinto_model.dart';
import 'credit_score_screen.dart';

final _pintoRepoProvider = Provider<PintoRepository>((_) => PintoRepositoryHttp());
final _balanceProvider = FutureProvider<int>((ref) => ref.read(_pintoRepoProvider).balance());
final _creditRepo = Provider<CreditRepository>((_) => const CreditRepositoryHttp());
final _creditScore = FutureProvider<CreditScoreData?>((ref) => ref.read(_creditRepo).score());

String _bandForLocal(int s) {
  if (s >= 880) return 'Excellent';
  if (s >= 740) return 'Very Good';
  if (s >= 670) return 'Good';
  if (s >= 560) return 'Fair';
  return 'Poor';
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bal = ref.watch(_balanceProvider).valueOrNull ?? 0;
    final score = ref.watch(_creditScore).valueOrNull?.score ?? 0;
    final band = ref.watch(_creditScore).valueOrNull?.band ?? _bandForLocal(score);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GlassCard(child: Row(children: [const Icon(Icons.account_balance_wallet_outlined), const SizedBox(width:8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[ const Text('Pinto Balance'), Text(bal.toString(), style: Theme.of(context).textTheme.headlineSmall) ])), TextButton(onPressed: ()=> Navigator.pushNamed(context, '/wallet'), child: const Text('Wallet')) ])),
            const SizedBox(height: 12),
            GlassCard(child: ListTile(leading: const Icon(Icons.score), title: const Text('Credit Score'), subtitle: Text('$score • $band'), trailing: TextButton(onPressed: ()=> Navigator.pushNamed(context, '/credit'), child: const Text('View')))),
            const SizedBox(height: 12),
            Row(children:[ Expanded(child: AppButtons.primary(label: 'Shop', icon: Icons.store, onPressed: ()=> Navigator.pushNamed(context, '/shop'))), const SizedBox(width: 12), Expanded(child: AppButtons.primary(label: 'Loans', icon: Icons.request_page, onPressed: ()=> Navigator.pushNamed(context, '/loans'))), ])
          ],
        ),
      ),
    );
  }
}
