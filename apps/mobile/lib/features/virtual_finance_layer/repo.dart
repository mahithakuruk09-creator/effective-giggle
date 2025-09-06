import 'dart:convert';
import 'package:http/http.dart' as http;

class AccountInfo { final String sortCode; final String accountNumber; const AccountInfo(this.sortCode, this.accountNumber); }
class VflCard { final String id; final String name; final String last4; final String network; final String type; bool frozen; VflCard(this.id,this.name,this.last4,this.network,this.type,this.frozen); }
class VflTx { final String id; final String date; final String merchant; final int amount; VflTx(this.id,this.date,this.merchant,this.amount); }
class Balances { final int gbp, eur, usd; const Balances(this.gbp,this.eur,this.usd); }

abstract class VflRepository {
  Future<AccountInfo> account();
  Future<List<VflCard>> cards();
  Future<VflCard> freeze(String id, bool frozen);
  Future<List<VflTx>> transactions(String id);
  Future<Balances> wallet();
  Future<Balances> topup(String currency, int amount);
}

class VflRepositoryHttp implements VflRepository {
  final String baseUrl; VflRepositoryHttp({this.baseUrl='http://localhost:8000'});
  @override Future<AccountInfo> account() async { final r=await http.get(Uri.parse('$baseUrl/mock/account')); if(r.statusCode>=400) throw Exception('account'); final j=jsonDecode(r.body); return AccountInfo(j['sort_code'], j['account_number']); }
  @override Future<List<VflCard>> cards() async { final r=await http.get(Uri.parse('$baseUrl/mock/cards')); if(r.statusCode>=400) throw Exception('cards'); final l=(jsonDecode(r.body) as List).cast<Map<String,dynamic>>(); return [for(final e in l) VflCard(e['id'],e['name'],e['last4'],e['network'],e['type'],e['frozen'] as bool)]; }
  @override Future<VflCard> freeze(String id,bool frozen) async { final r=await http.post(Uri.parse('$baseUrl/mock/cards/$id/freeze'), headers:{'Content-Type':'application/json'}, body: jsonEncode({'frozen': frozen})); if(r.statusCode>=400) throw Exception('freeze'); final e=jsonDecode(r.body); return VflCard(e['id'],e['name'],e['last4'],e['network'],e['type'],e['frozen']); }
  @override Future<List<VflTx>> transactions(String id) async { final r=await http.get(Uri.parse('$baseUrl/mock/cards/$id/transactions')); if(r.statusCode>=400) throw Exception('tx'); final l=(jsonDecode(r.body) as List).cast<Map<String,dynamic>>(); return [for(final e in l) VflTx(e['id'],e['date'],e['merchant'],(e['amount'] as num).toInt())]; }
  @override Future<Balances> wallet() async { final r=await http.get(Uri.parse('$baseUrl/mock/wallet')); if(r.statusCode>=400) throw Exception('wallet'); final j=jsonDecode(r.body); return Balances((j['GBP'] as num).toInt(), (j['EUR'] as num).toInt(), (j['USD'] as num).toInt()); }
  @override Future<Balances> topup(String currency,int amount) async { final r=await http.post(Uri.parse('$baseUrl/mock/wallet/topup'), headers:{'Content-Type':'application/json'}, body: jsonEncode({'currency':currency,'amount':amount})); if(r.statusCode>=400) throw Exception('topup'); final j=jsonDecode(r.body); return Balances((j['GBP'] as num).toInt(), (j['EUR'] as num).toInt(), (j['USD'] as num).toInt()); }
}

class VflRepositoryFake implements VflRepository {
  AccountInfo acc = const AccountInfo('12-34-56','12345678');
  List<VflCard> _cards = [VflCard('v','Virtual','4433','Mastercard','virtual',false), VflCard('p','Physical','8765','Mastercard','physical',false)];
  List<VflTx> _tx = [VflTx('t1','2025-09-05','Pret',-5)];
  Balances b = const Balances(100, 0, 0);
  @override Future<AccountInfo> account() async => acc;
  @override Future<List<VflCard>> cards() async => _cards.map((e)=>VflCard(e.id,e.name,e.last4,e.network,e.type,e.frozen)).toList();
  @override Future<VflCard> freeze(String id,bool frozen) async { final i=_cards.indexWhere((c)=>c.id==id); _cards[i].frozen=frozen; return _cards[i]; }
  @override Future<List<VflTx>> transactions(String id) async => _tx;
  @override Future<Balances> wallet() async => b;
  @override Future<Balances> topup(String currency,int amount) async { b = Balances(b.gbp + (currency=='GBP'?amount:0), b.eur + (currency=='EUR'?amount:0), b.usd + (currency=='USD'?amount:0)); return b; }
}

