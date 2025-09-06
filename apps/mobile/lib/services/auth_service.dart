import 'dart:async';

class AuthService {
  Future<String> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'token-123';
  }

  Future<void> signup(String name, String email, String phone, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> verifyOtp(String token, String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (code != '123456') {
      throw Exception('invalid');
    }
  }

  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
