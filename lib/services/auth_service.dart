import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isDemo = false;
  String? _userEmail;
  String? _userRole;
  static const String _authKey = 'auth_status';
  static const String _demoKey = 'is_demo';
  static const String _userKey = 'user_email';
  static const String _roleKey = 'user_role';

  AuthService() {
    _loadAuthState();
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isDemo => _isDemo;
  String? get userEmail => _userEmail;
  String? get userRole => _userRole;

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool(_authKey) ?? false;
    _isDemo = prefs.getBool(_demoKey) ?? false;
    _userEmail = prefs.getString(_userKey);
    _userRole = prefs.getString(_roleKey);
    notifyListeners();
  }

  Future<bool> signIn(String email, String password, {String? role}) async {
    try {
      // Demo credentials for testing
      if ((email == 'student@demo.com' &&
              password == '123456' &&
              role == 'student') ||
          (email == 'faculty@demo.com' &&
              password == '123456' &&
              role == 'faculty')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_authKey, true);
        await prefs.setBool(_demoKey, true);
        await prefs.setString(_userKey, email);
        await prefs.setString(_roleKey, role ?? 'student');
        _isAuthenticated = true;
        _isDemo = true;
        _userEmail = email;
        _userRole = role;
        notifyListeners();
        return true;
      }
      // Here you'll add your actual authentication logic later
      return false;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_authKey, false);
      await prefs.setBool(_demoKey, false);
      await prefs.remove(_userKey);
      await prefs.remove(_roleKey);
      _isAuthenticated = false;
      _isDemo = false;
      _userEmail = null;
      _userRole = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }
}
