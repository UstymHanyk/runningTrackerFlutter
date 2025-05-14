import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String email;
  final String password;
  final String name;
  
  const User({
    required this.email,
    required this.password,
    required this.name,
  });
  
  @override
  List<Object> get props => [email, password, name];
  
  User copyWith({
    String? email,
    String? password,
    String? name,
  }) {
    return User(
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
    };
  }
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
    );
  }
} 