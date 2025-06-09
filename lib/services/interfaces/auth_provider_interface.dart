import 'package:flutter/foundation.dart';
import 'package:my_project/models/user.dart';

abstract class AuthProviderInterface extends ChangeNotifier {
  User? get currentUser;
  bool get isLoading;
  String? get error;
  bool get isLoggedIn;

  Future<bool> register(String email, String password, String name);
  Future<bool> login(String email, String password);
  Future<void> logout();
  Future<bool> updateUserProfile(String name);
} 