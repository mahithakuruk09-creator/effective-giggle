import 'package:flutter_test/flutter_test.dart';
import 'package:scredex_mobile/features/bill_pay/biller_service.dart';

void main() {
  test('calculates pintos for credit card at 0.5/£', () {
    final service = BillerService();
    expect(service.calculatePintos(200, 'Credit Cards'), 100);
  });
  test('calculates pintos for utilities at 0.25/£', () {
    final service = BillerService();
    expect(service.calculatePintos(200, 'Utilities'), 50);
  });
}
