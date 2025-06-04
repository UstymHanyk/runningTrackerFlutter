import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _isLoggedInKey = 'isLoggedIn';

  // Save user login information
  Future<bool> saveUserLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_isLoggedInKey, true);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Log out user
  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_isLoggedInKey, false);
  }
} 