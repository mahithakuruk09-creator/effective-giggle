import 'dart:convert';
import 'package:http/http.dart' as http;

enum PintoTxnType { earn, redeem }

class PintoTransaction {
  final String id;
  final DateTime date;
  final PintoTxnType type;
  final String source;
  final int amount; // positive for earn, negative for spend

  const PintoTransaction({
    required this.id,
    required this.date,
    required this.type,
    required this.source,
    required this.amount,
  });

  factory PintoTransaction.fromJson(Map<String, dynamic> j) => PintoTransaction(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        type: (j['type'] as String) == 'earn' ? PintoTxnType.earn : PintoTxnType.redeem,
        source: j['source'] as String,
        amount: (j['amount'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String().substring(0, 10),
        'type': type == PintoTxnType.earn ? 'earn' : 'redeem',
        'source': source,
        'amount': amount,
      };
}

abstract class PintoRepository {
  Future<int> balance();
  Future<List<PintoTransaction>> ledger();
  Future<int> redeem(String itemId);
}

class PintoRepositoryHttp implements PintoRepository {
  final String baseUrl;
  PintoRepositoryHttp({this.baseUrl = 'http://localhost:8000'});

  @override
  Future<int> balance() async {
    final uri = Uri.parse('$baseUrl/rewards/balance');
    final res = await _get(uri);
    return (res['balance'] as num).toInt();
  }

  @override
  Future<List<PintoTransaction>> ledger() async {
    final uri = Uri.parse('$baseUrl/rewards/ledger');
    final res = await _getList(uri);
    return res.map((e) => PintoTransaction.fromJson(e)).toList();
  }

  @override
  Future<int> redeem(String itemId) async {
    final uri = Uri.parse('$baseUrl/rewards/redeem');
    final res = await _post(uri, {'item_id': itemId});
    return (res['new_balance'] as num).toInt();
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    final r = await http.get(uri);
    if (r.statusCode >= 400) throw Exception('GET ${uri.path} failed');
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> _getList(Uri uri) async {
    final r = await http.get(uri);
    if (r.statusCode >= 400) throw Exception('GET ${uri.path} failed');
    final l = jsonDecode(r.body) as List<dynamic>;
    return l.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> _post(Uri uri, Map<String, dynamic> body) async {
    final r = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
    if (r.statusCode >= 400) throw Exception('POST ${uri.path} failed');
    return jsonDecode(r.body) as Map<String, dynamic>;
  }
}

// Simple in-memory fake for tests
class PintoRepositoryFake implements PintoRepository {
  int _balance;
  final List<PintoTransaction> _txns;
  PintoRepositoryFake({int initialBalance = 1000, List<PintoTransaction>? ledger})
      : _balance = initialBalance,
        _txns = List.of(ledger ?? const []);

  @override
  Future<int> balance() async => _balance;

  @override
  Future<List<PintoTransaction>> ledger() async => List.unmodifiable(_txns);

  @override
  Future<int> redeem(String itemId) async {
    // For tests, assume item id encodes price like s500 or fallback 100
    final price = int.tryParse(itemId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 100;
    if (_balance < price) {
      throw Exception('Insufficient balance');
    }
    _balance -= price;
    _txns.add(PintoTransaction(
      id: 't${_txns.length + 1}',
      date: DateTime.now(),
      type: PintoTxnType.redeem,
      source: 'Redeem $itemId',
      amount: -price,
    ));
    return _balance;
  }
}

// For tests, override pintoRepositoryProvider in the screen file.
