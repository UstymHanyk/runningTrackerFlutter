import 'package:my_project/models/user.dart';

abstract class UserRepositoryInterface {
  Future<bool> registerUser(User user);
  Future<User?> getUserByEmail(String email);
  Future<User?> getCurrentUser();
  Future<bool> saveUser(User user);
  Future<bool> login(String email, String password);
  Future<bool> logout();
  Future<bool> isLoggedIn();
} 