import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'repo.dart';
import 'transactions_screen.dart';

final vflRepoProvider = Provider<VflRepository>((_) => VflRepositoryHttp());
final accountProvider = FutureProvider((ref) => ref.read(vflRepoProvider).account());
final walletProvider = FutureProvider((ref) => ref.read(vflRepoProvider).wallet());
final cardsProviderVfl = FutureProvider((ref) => ref.read(vflRepoProvider).cards());

class WalletVflScreen extends ConsumerStatefulWidget { const WalletVflScreen({super.key}); @override ConsumerState<WalletVflScreen> createState()=>_WalletVflScreenState(); }
class _WalletVflScreenState extends ConsumerState<WalletVflScreen> {
  int index = 0; bool overlay = false;
  @override
  Widget build(BuildContext context) {
    final acc = ref.watch(accountProvider);
    final bal = ref.watch(walletProvider);
    final cards = ref.watch(cardsProviderVfl);
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet & Virtual Finance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children:[
          acc.when(
            loading: ()=> const LinearProgressIndicator(),
            error: (e,_)=> const SizedBox.shrink(),
            data: (a)=> GlassCard(child: Row(children:[ const Icon(Icons.account_balance), const SizedBox(width:8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[ Text('Sort code: ${a.sortCode}'), Text('Account: ${a.accountNumber}') ])), IconButton(onPressed: (){ Clipboard.setData(ClipboardData(text: '${a.sortCode} ${a.accountNumber}')); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied'))); }, icon: const Icon(Icons.copy)), ]))),
          const SizedBox(height: 12),
          SizedBox(height: 190, child: cards.when(
            loading: ()=> const Center(child: CircularProgressIndicator()),
            error: (e,_)=> Center(child: TextButton(onPressed: ()=> ref.refresh(cardsProviderVfl), child: const Text('Retry'))),
            data: (list)=> PageView.builder(controller: PageController(viewportFraction: 0.86), onPageChanged: (i)=> setState(()=> index=i), itemCount: list.length, itemBuilder: (c,i){ final card = list[i]; return Stack(children:[ GlassCard(height: 180, child: Stack(children:[ Positioned(top: 8,left: 8, child: Text(card.name, style: const TextStyle(fontWeight: FontWeight.w700))), Positioned(top: 8,right: 8, child: Text(card.network)), Center(child: Icon(Icons.credit_card, size: 48)), Positioned(bottom: 12,left: 12, child: Text('**** **** **** ${card.last4}')), Positioned(bottom: 12,right: 12, child: Text(card.type.toUpperCase())), ])), AnimatedOpacity(opacity: card.frozen? 0.6:0.0, duration: const Duration(milliseconds: 200), child: Container(height: 180, decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: Colors.white.withOpacity(0.08)))) ]); }),
          )),
          const SizedBox(height: 8),
          Row(children:[
            Expanded(child: AppButtons.primary(label: 'View Transactions', icon: Icons.receipt_long, onPressed: cards.maybeWhen(orElse: ()=> null, data: (l)=> ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> TransactionsVflScreen(cardId: l[index].id, name: l[index].name)))))),
            const SizedBox(width: 12),
            Expanded(child: AppButtons.primary(label: 'Freeze/Unfreeze', icon: Icons.ac_unit, onPressed: cards.maybeWhen(orElse: ()=> null, data: (l)=> () async { final card=l[index]; final res = await ref.read(vflRepoProvider).freeze(card.id, !card.frozen); ref.invalidate(cardsProviderVfl); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.frozen? 'Card frozen' : 'Card unfrozen'))); }))),
          ]),
          const SizedBox(height: 12),
          bal.when(
            loading: ()=> const LinearProgressIndicator(),
            error: (e,_)=> const SizedBox.shrink(),
            data: (b)=> GridView.count(crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, shrinkWrap: true, children: [
              _bal('GBP', b.gbp), _bal('EUR', b.eur), _bal('USD', b.usd)
            ]),
          ),
          const Spacer(),
          Align(alignment: Alignment.centerRight, child: AppButtons.primary(label: 'Top Up Wallet', icon: Icons.add, onPressed: () async { final res = await _topup(context); if(res!=null){ await ref.read(vflRepoProvider).topup(res.$1, res.$2); ref.invalidate(walletProvider); if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Top-up success'))); }}))
        ]),
      ),
    );
  }

  Widget _bal(String cur, int amount) => GlassCard(child: Column(mainAxisSize: MainAxisSize.min, children:[ Text(cur, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height:4), Text('£$amount') ]));
}

Future<(String,int)?> _topup(BuildContext context) async {
  String currency = 'GBP';
  double amount = 10;
  return showModalBottomSheet<(String,int)>(context: context, showDragHandle: true, builder: (c)=> Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children:[ DropdownButtonFormField<String>(value: currency, items: const [DropdownMenuItem(value:'GBP', child: Text('GBP')), DropdownMenuItem(value:'EUR', child: Text('EUR')), DropdownMenuItem(value:'USD', child: Text('USD'))], onChanged: (v){ currency = v ?? currency; }), Slider(min: 10, max: 500, value: amount, divisions: 49, label: '£'+amount.toInt().toString(), onChanged: (v){ amount = v; (c as Element).markNeedsBuild(); }), const SizedBox(height:8), Align(alignment: Alignment.centerRight, child: AppButtons.primary(label: 'Top Up', onPressed: ()=> Navigator.pop(c, (currency, amount.toInt())))) ])));
}

