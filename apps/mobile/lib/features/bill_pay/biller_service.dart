import 'package:flutter/services.dart' show rootBundle;

import 'biller.dart';

class BillerService {
  Future<List<Biller>> fetchBillers() async {
    final data = await rootBundle.loadString('assets/stubs/billers.json');
    return Biller.listFromJson(data);
  }

  int calculatePintos(double amount, String category) {
    final rate = category == 'Credit Cards' ? 0.5 : 0.25;
    return (amount * rate).floor();
  }
}
