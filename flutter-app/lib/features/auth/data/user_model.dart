// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final String username;
  final String email;
  // final String password;
  final String fullName;
  final String phoneNumber;
  final int age;
  final int exp;
  final String avatarUrl;

  UserModel({
    required this.username,
    required this.email,
    // required this.password,
    required this.fullName,
    required this.phoneNumber,
    required this.age,
    required this.exp,
    required this.avatarUrl,
  });

  // Convert UserModel to a Map (useful for Firebase or other databases)

  UserModel copyWith({
    String? username,
    String? email,
    // String? password,
    String? fullName,
    String? phoneNumber,
    int? age,
    int? exp,
    String? avatarUrl,
  }) {
    return UserModel(
      username: username ?? this.username,
      email: email ?? this.email,
      // password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      age: age ?? this.age,
      exp: exp ?? this.exp,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      // password: map[''] ?? '',
      fullName: map['full_name'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      age: map['age'] ?? 0,
      exp: map['exp'] ?? 0,
      avatarUrl: map['avatar_url'] ?? '',
    );
  }
}
