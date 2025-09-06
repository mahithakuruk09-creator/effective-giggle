import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('onboarding flag persists', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('onboarding_complete'), isNull);
    await prefs.setBool('onboarding_complete', true);
    final again = await SharedPreferences.getInstance();
    expect(again.getBool('onboarding_complete'), isTrue);
  });
}
