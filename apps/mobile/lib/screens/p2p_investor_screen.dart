import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../widgets/investment_card.dart';
import '../theme/app_theme.dart';

class P2PPool { final String id; final String risk; final double apr; final int available; const P2PPool({required this.id, required this.risk, required this.apr, required this.available}); factory P2PPool.fromJson(Map<String, dynamic> j)=>P2PPool(id:j['id'],risk:j['risk'],apr:(j['apr'] as num).toDouble(),available:(j['available'] as num).toInt()); }

abstract class P2PRepository { Future<List<P2PPool>> pools(); Future<void> invest(String id, int amount); }

class P2PRepositoryHttp implements P2PRepository {
  final String baseUrl; const P2PRepositoryHttp({this.baseUrl='http://localhost:8000'});
  @override Future<List<P2PPool>> pools() async { final r=await http.get(Uri.parse('$baseUrl/p2p/pools')); if(r.statusCode>=400) throw Exception('pools failed'); final data=(jsonDecode(r.body) as List).cast<Map<String,dynamic>>(); return data.map(P2PPool.fromJson).toList(); }
  @override Future<void> invest(String id,int amount) async { final r=await http.post(Uri.parse('$baseUrl/p2p/invest'), headers:{'Content-Type':'application/json'}, body: jsonEncode({'pool_id':id,'amount':amount})); if(r.statusCode>=400) throw Exception('invest failed'); }
}

class P2PRepositoryFake implements P2PRepository {
  final List<P2PPool> _pools = const [
    P2PPool(id:'pf_low', risk:'Low', apr:4.2, available:20000),
    P2PPool(id:'pf_med', risk:'Med', apr:7.8, available:12000),
    P2PPool(id:'pf_high', risk:'High', apr:12.5, available:6000),
  ];
  @override Future<void> invest(String id,int amount) async {}
  @override Future<List<P2PPool>> pools() async => _pools;
}

final p2pRepositoryProvider = Provider<P2PRepository>((ref)=>P2PRepositoryHttp());
final poolsProvider = FutureProvider<List<P2PPool>>((ref)=>ref.read(p2pRepositoryProvider).pools());

class P2PInvestorScreen extends ConsumerWidget { const P2PInvestorScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref){
    final pools = ref.watch(poolsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('P2P Investor')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children:[
          GlassCard(child: Row(children: const [Icon(Icons.account_balance_wallet), SizedBox(width:8), Expanded(child: Text('Invested £3,500 • Expected 7.1% p.a.'))])),
          const SizedBox(height:16),
          SizedBox(height:200, child:
            pools.when(
              loading: ()=>const Center(child:CircularProgressIndicator()),
              error: (e,_)=>Center(child: TextButton(onPressed: ()=>ref.refresh(poolsProvider), child: const Text('Retry'))),
              data: (list)=>ListView.separated(scrollDirection: Axis.horizontal, itemBuilder: (c,i)=>InvestmentCard(risk:list[i].risk, apr:list[i].apr, available:list[i].available, onInvest: () async {final amount = await _showInvestModal(context); if(amount!=null){ try{ await ref.read(p2pRepositoryProvider).invest(list[i].id, amount); if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invested successfully')));}catch(_){ if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to invest')));} } }), separatorBuilder: (_, __)=>const SizedBox(width:12), itemCount: list.length))
          ),
        ]),
      ),
    );
  }
}

Future<int?> _showInvestModal(BuildContext context) async{
  int amount = 500; return showModalBottomSheet<int>(context: context, showDragHandle: true, builder: (c){ return Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children:[ const Text('Choose amount'), Slider(min:100, max:2000, divisions:19, value: amount.toDouble(), label: '£'+amount.toString(), onChanged: (v){ amount = v.toInt(); }), const SizedBox(height:8), Align(alignment: Alignment.centerRight, child: AppButtons.primary(label:'Invest £'+amount.toString(), onPressed: ()=> Navigator.pop(c, amount))) ])); });
}

 
