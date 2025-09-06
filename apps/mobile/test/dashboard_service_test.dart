import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:scredex_mobile/features/dashboard/dashboard_service.dart';

void main() {
  test('parses dashboard response', () async {
    final mockClient = MockClient((req) async {
      return http.Response(jsonEncode({
        'wallet_balance': 100.0,
        'linked_accounts': [
          {'bank': 'Monzo', 'balance': 80.0}
        ],
        'pintos_balance': 200,
        'bills': [],
        'credit_score': {
          'value': 700,
          'band': 'Good',
          'last_refreshed': '2025-09-01'
        }
      }), 200);
    });
    final service = DashboardService(client: mockClient);
    final data = await service.fetchDashboard();
    expect(data.walletBalance, 100.0);
    expect(data.linkedAccounts.first.bank, 'Monzo');
    expect(data.pintosBalance, 200);
    expect(data.creditScore.value, 700);
  });
}
