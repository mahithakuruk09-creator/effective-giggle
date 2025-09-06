import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../widgets/card_tile.dart';
import '../theme/app_theme.dart';
import 'card_detail_screen.dart';

class WalletCard { final String id; final String name; final String last4; final int balance; final bool isDefault; final bool frozen; const WalletCard({required this.id, required this.name, required this.last4, required this.balance, required this.isDefault, required this.frozen}); factory WalletCard.fromJson(Map<String, dynamic> j)=>WalletCard(id:j['id'], name:j['name'], last4:j['last4'], balance:(j['balance'] as num).toInt(), isDefault:j['is_default'] as bool, frozen:j['frozen'] as bool); }
class CardTx { final String id; final String date; final String merchant; final int amount; const CardTx({required this.id, required this.date, required this.merchant, required this.amount}); factory CardTx.fromJson(Map<String,dynamic> j)=>CardTx(id:j['id'], date:j['date'], merchant:j['merchant'], amount:(j['amount'] as num).toInt()); }

abstract class CardsRepository { Future<List<WalletCard>> list(); Future<List<CardTx>> tx(String id); Future<void> freeze(String id,bool frozen); }
class CardsRepositoryHttp implements CardsRepository { final String baseUrl; const CardsRepositoryHttp({this.baseUrl='http://localhost:8000'}); @override Future<void> freeze(String id,bool frozen) async {final r=await http.post(Uri.parse('$baseUrl/cards/freeze'), headers:{'Content-Type':'application/json'}, body: jsonEncode({'id':id,'frozen':frozen})); if(r.statusCode>=400) throw Exception('freeze failed'); } @override Future<List<WalletCard>> list() async {final r=await http.get(Uri.parse('$baseUrl/cards')); if(r.statusCode>=400) throw Exception('cards failed'); final data=(jsonDecode(r.body) as List).cast<Map<String,dynamic>>(); return data.map(WalletCard.fromJson).toList(); } @override Future<List<CardTx>> tx(String id) async {final r=await http.get(Uri.parse('$baseUrl/cards/$id/transactions')); if(r.statusCode>=400) throw Exception('tx failed'); final data=(jsonDecode(r.body) as List).cast<Map<String,dynamic>>(); return data.map(CardTx.fromJson).toList(); }}
class CardsRepositoryFake implements CardsRepository { final _cards = [WalletCard(id:'c1', name:'Scredex Metal', last4:'4242', balance:1235, isDefault:true, frozen:false), WalletCard(id:'c2', name:'Scredex Lite', last4:'1881', balance:230, isDefault:false, frozen:false)]; final _tx = <String,List<CardTx>>{'c1':[const CardTx(id:'t1', date:'2025-09-05', merchant:'Apple', amount:-123), const CardTx(id:'t2', date:'2025-09-06', merchant:'Pret', amount:-5)]}; @override Future<void> freeze(String id,bool frozen) async { final i=_cards.indexWhere((e)=>e.id==id); if(i>=0) _cards[i]=WalletCard(id:_cards[i].id, name:_cards[i].name, last4:_cards[i].last4, balance:_cards[i].balance, isDefault:_cards[i].isDefault, frozen:frozen);} @override Future<List<WalletCard>> list() async => _cards; @override Future<List<CardTx>> tx(String id) async => _tx[id] ?? []; }

final cardsRepositoryProvider = Provider<CardsRepository>((ref)=>CardsRepositoryHttp());
final cardsProvider = FutureProvider<List<WalletCard>>((ref)=>ref.read(cardsRepositoryProvider).list());

class CardsScreen extends ConsumerStatefulWidget { const CardsScreen({super.key}); @override ConsumerState<CardsScreen> createState()=>_CardsScreenState(); }
class _CardsScreenState extends ConsumerState<CardsScreen> { int index = 0; List<CardTx> tx = const []; final PageController _pc = PageController(viewportFraction: 0.86);
  Future<void> _loadTx(String id) async { tx = await ref.read(cardsRepositoryProvider).tx(id); if(mounted) setState((){}); }
  @override Widget build(BuildContext context){ final cards = ref.watch(cardsProvider);
    return Scaffold(appBar: AppBar(title: const Text('Cards & Wallet')), body: Padding(padding: const EdgeInsets.all(16), child: cards.when(loading: ()=> const Center(child:CircularProgressIndicator()), error: (e,_)=> Center(child: TextButton(onPressed: ()=> ref.refresh(cardsProvider), child: const Text('Retry'))), data: (list){ if(list.isEmpty){ return const Center(child: Text('No cards yet, add your first card')); } final selected = list[index.clamp(0, list.length-1)]; return Column(children:[
        // Carousel
        SizedBox(height: 190, child: PageView.builder(onPageChanged: (i){ setState(()=> index=i); _loadTx(list[i].id); }, controller: _pc, itemCount: list.length, itemBuilder: (c,i){ final card=list[i]; return AnimatedBuilder(animation: _pc, builder: (ctx, child){ double delta = 0; if(_pc.position.haveDimensions){ delta = (_pc.page ?? _pc.initialPage.toDouble()) - i; } final isCurrent = (delta.abs() < 0.5); final scale = 1 - (delta.abs()*0.08).clamp(0, .2); final angle = delta * 0.15; return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle)..scale(scale),
              child: Opacity(opacity: isCurrent?1:0.9, child: _CardVisual(card: card)),
            ); },); })),
        const SizedBox(height: 12),
        Row(children:[ Expanded(child: AppButtons.primary(label: selected.frozen? 'Unfreeze Card':'Freeze Card', icon: Icons.ac_unit, onPressed: () async { try{ await ref.read(cardsRepositoryProvider).freeze(selected.id, !selected.frozen); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(selected.frozen? 'Unfrozen' : 'Frozen'))); ref.invalidate(cardsProvider);}catch(_){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update')));} })), const SizedBox(width: 12), Expanded(child: AppButtons.primary(label: 'View Details', icon: Icons.credit_card, onPressed: (){ Navigator.push(context, MaterialPageRoute(builder: (_)=> CardDetailScreen(cardId: selected.id, name: selected.name, last4: selected.last4))); })) ]),
        const SizedBox(height: 12),
        Expanded(child: tx.isEmpty? const Center(child: Text('No transactions')): ListView.separated(itemCount: tx.length, separatorBuilder: (_, __)=> const SizedBox(height:10), itemBuilder: (c,i)=> CardTile(icon: Icons.shopping_bag, title: tx[i].merchant, subtitle: tx[i].date, amount: tx[i].amount)))
      ]); } )));
  }
}

class _CardVisual extends StatelessWidget { final WalletCard card; const _CardVisual({required this.card}); @override Widget build(BuildContext context){
    return GlassCard(height: 180, child: Stack(children:[ Align(alignment: Alignment.topLeft, child: Text(card.name, style: const TextStyle(fontWeight: FontWeight.w700))), Align(alignment: Alignment.centerRight, child: Icon(Icons.contactless, size: 36, color: Colors.white.withOpacity(0.7))), Align(alignment: Alignment.bottomLeft, child: Text('**** **** **** ${card.last4}', style: const TextStyle(letterSpacing: 2))), Align(alignment: Alignment.bottomRight, child: Text('£${card.balance}', style: const TextStyle(fontWeight: FontWeight.w700))) ]));
  }}

 
