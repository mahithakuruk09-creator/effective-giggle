import 'dart:convert';
import 'package:http/http.dart' as http;

class LinkedAccount {
  final String bank;
  final double balance;
  LinkedAccount({required this.bank, required this.balance});
  factory LinkedAccount.fromJson(Map<String, dynamic> json) =>
      LinkedAccount(bank: json['bank'], balance: (json['balance'] as num).toDouble());
}

class Bill {
  final String id;
  final String name;
  final String logoUrl;
  final DateTime dueDate;
  final double amount;
  final String status;
  Bill({required this.id, required this.name, required this.logoUrl, required this.dueDate, required this.amount, required this.status});
  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
        id: json['id'],
        name: json['name'],
        logoUrl: json['logo_url'],
        dueDate: DateTime.parse(json['due_date']),
        amount: (json['amount'] as num).toDouble(),
        status: json['status'],
      );
}

class CreditScore {
  final int value;
  final String band;
  final DateTime lastRefreshed;
  CreditScore({required this.value, required this.band, required this.lastRefreshed});
  factory CreditScore.fromJson(Map<String, dynamic> json) => CreditScore(
        value: json['value'],
        band: json['band'],
        lastRefreshed: DateTime.parse(json['last_refreshed']),
      );
}

class DashboardData {
  final double walletBalance;
  final List<LinkedAccount> linkedAccounts;
  final int pintosBalance;
  final List<Bill> bills;
  final CreditScore creditScore;
  DashboardData({required this.walletBalance, required this.linkedAccounts, required this.pintosBalance, required this.bills, required this.creditScore});
}

class DashboardService {
  final http.Client _client;
  DashboardService({http.Client? client}) : _client = client ?? http.Client();

  Future<DashboardData> fetchDashboard() async {
    final res = await _client.get(Uri.parse('http://localhost:8000/dashboard'));
    if (res.statusCode != 200) {
      throw Exception('failed to load');
    }
    final jsonMap = json.decode(res.body) as Map<String, dynamic>;
    return DashboardData(
      walletBalance: (jsonMap['wallet_balance'] as num).toDouble(),
      linkedAccounts: (jsonMap['linked_accounts'] as List)
          .map((e) => LinkedAccount.fromJson(e))
          .toList(),
      pintosBalance: jsonMap['pintos_balance'],
      bills: (jsonMap['bills'] as List).map((e) => Bill.fromJson(e)).toList(),
      creditScore: CreditScore.fromJson(jsonMap['credit_score']),
    );
  }
}
