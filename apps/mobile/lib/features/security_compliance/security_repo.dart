import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class SecurityRepo {
  Future<void> setPin(String pin);
  Future<bool> verifyPin(String pin);
  Future<bool> toggleBiometric(bool enabled);
  Future<String> sendOtp();
  Future<bool> verifyOtp(String code);
  Future<Map<String, dynamic>> downloadData();
  Future<void> deleteAccount();
  Future<void> audit(String event);
}

class SecurityRepoHttp implements SecurityRepo {
  final String baseUrl; SecurityRepoHttp({this.baseUrl='http://localhost:8000'});
  @override Future<void> setPin(String pin) async { final r=await http.post(Uri.parse('$baseUrl/security/pin'), headers:{'Content-Type':'application/json'}, body: jsonEncode({'pin': pin})); if(r.statusCode>=400) throw Exception('pin'); }
  @override Future<bool> verifyPin(String pin) async { final r=await http.post(Uri.parse('$baseUrl/security/pin/verify'), headers:{'Content-Type':'application/json'}, body: jsonEncode({'pin': pin})); if(r.statusCode>=400) throw Exception('verify'); return (jsonDecode(r.body) as Map<String,dynamic>)['ok'] as bool; }
  @override Future<bool> toggleBiometric(bool enabled) async { final r=await http.post(Uri.parse('$baseUrl/security/biometric/toggle'), headers:{'Content-Type':'application/json'}, body: jsonEncode({'enabled': enabled})); if(r.statusCode>=400) throw Exception('bio'); return (jsonDecode(r.body) as Map<String,dynamic>)['biometric_enabled'] as bool; }
  @override Future<String> sendOtp() async { final r=await http.post(Uri.parse('$baseUrl/security/2fa/send')); if(r.statusCode>=400) throw Exception('otp'); return (jsonDecode(r.body) as Map<String,dynamic>)['code'] as String; }
  @override Future<bool> verifyOtp(String code) async { final r=await http.post(Uri.parse('$baseUrl/security/2fa/verify'), headers:{'Content-Type':'application/json'}, body: jsonEncode({'code': code})); if(r.statusCode>=400) throw Exception('otp verify'); return (jsonDecode(r.body) as Map<String,dynamic>)['ok'] as bool; }
  @override Future<Map<String, dynamic>> downloadData() async { final r=await http.get(Uri.parse('$baseUrl/security/privacy/data')); if(r.statusCode>=400) throw Exception('data'); return jsonDecode(r.body) as Map<String,dynamic>; }
  @override Future<void> deleteAccount() async { final r=await http.post(Uri.parse('$baseUrl/security/privacy/delete')); if(r.statusCode>=400) throw Exception('delete'); }
  @override Future<void> audit(String event) async { final r=await http.post(Uri.parse('$baseUrl/security/audit'), headers:{'Content-Type':'application/json'}, body: jsonEncode({'event': event})); if(r.statusCode>=400) throw Exception('audit'); }
}

class SecurityRepoFake implements SecurityRepo {
  String? pin;
  bool biometric = false;
  bool twofa = false;
  @override Future<void> setPin(String p) async { pin = p; }
  @override Future<bool> verifyPin(String p) async => pin == p;
  @override Future<bool> toggleBiometric(bool enabled) async { biometric = enabled; return biometric; }
  @override Future<String> sendOtp() async => '123456';
  @override Future<bool> verifyOtp(String code) async => code == '123456';
  @override Future<Map<String, dynamic>> downloadData() async => {'user_id':'u1'};
  @override Future<void> deleteAccount() async {}
  @override Future<void> audit(String event) async {}
}

