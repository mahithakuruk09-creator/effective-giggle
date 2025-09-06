import 'dart:io' show Platform;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PushStubService {
  final String baseUrl;
  PushStubService({this.baseUrl = 'http://localhost:8000'});

  Future<void> registerToken(String token) async {
    await http.post(Uri.parse('$baseUrl/push/token'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'token': token}));
  }

  Future<void> subscribe(String token, String topic) async {
    await http.post(Uri.parse('$baseUrl/push/subscribe'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'token': token, 'topic': topic}));
  }
}

final pushStubProvider = Provider<PushStubService>((_) => PushStubService());

final startupPushProvider = Provider<void>((ref) {
  // Plug point: replace with FirebaseMessaging/APNs token fetch
  final token = 'stub-${Platform.isIOS ? 'ios' : 'android'}-device';
  final svc = ref.read(pushStubProvider);
  // fire-and-forget
  svc.registerToken(token).then((_) => svc.subscribe(token, 'rewards')); // rewards topic
});

