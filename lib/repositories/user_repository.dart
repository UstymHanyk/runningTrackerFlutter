import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_project/models/user.dart';
import 'package:my_project/repositories/interfaces/user_repository_interface.dart';

class UserRepository implements UserRepositoryInterface {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'currentUser';
  
  @override
  Future<bool> registerUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final Map<String, dynamic> users = json.decode(usersJson);
    
    if (users.containsKey(user.email)) {
      return false;
    }
    
    users[user.email] = user.toJson();
    return prefs.setString(_usersKey, json.encode(users));
  }
  
  @override
  Future<User?> getUserByEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final Map<String, dynamic> users = json.decode(usersJson);
    
    if (!users.containsKey(email)) {
      return null;
    }
    
    return User.fromJson(users[email]);
  }
  
  @override
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserEmail = prefs.getString(_currentUserKey);
    
    if (currentUserEmail == null) {
      return null;
    }
    
    return getUserByEmail(currentUserEmail);
  }
  
  @override
  Future<bool> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final Map<String, dynamic> users = json.decode(usersJson);
    
    users[user.email] = user.toJson();
    return prefs.setString(_usersKey, json.encode(users));
  }
  
  @override
  Future<bool> login(String email, String password) async {
    final user = await getUserByEmail(email);
    
    if (user == null || user.password != password) {
      return false;
    }
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_currentUserKey, email);
  }
  
  @override
  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_currentUserKey);
  }
  
  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_currentUserKey);
  }
} 