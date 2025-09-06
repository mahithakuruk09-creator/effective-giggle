import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'repo.dart';

class TransactionsVflScreen extends ConsumerWidget {
  final String cardId; final String name;
  const TransactionsVflScreen({super.key, required this.cardId, required this.name});
  @override
  Widget build(BuildContext context, WidgetRef ref){
    final repo = ref.read(vflRepoProvider);
    return Scaffold(appBar: AppBar(title: Text('Transactions • $name')), body: FutureBuilder(
      future: repo.transactions(cardId),
      builder: (context, snap){
        if(!snap.hasData) return const Center(child:CircularProgressIndicator());
        final l = snap.data!;
        if(l.isEmpty) return const Center(child: Text('No transactions yet.'));
        return ListView.separated(padding: const EdgeInsets.all(16), itemCount: l.length, separatorBuilder: (_, __)=> const SizedBox(height: 10), itemBuilder:(c,i)=> GlassCard(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Row(children:[ const Icon(Icons.shopping_bag), const SizedBox(width:8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[ Text(l[i].merchant), Text(l[i].date, style: Theme.of(c).textTheme.bodySmall) ])), Text('£${l[i].amount.abs()}', style: TextStyle(color: l[i].amount<0? Colors.redAccent: Colors.greenAccent)) ])));
      },
    ));
  }
}

