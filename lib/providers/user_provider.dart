import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

// User model
class UserModel {
  final int id;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String gender;
  final String dateOfBirth;
  final int age;
  final String authMethod;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.fullName,
    this.email,
    this.phoneNumber,
    required this.gender,
    required this.dateOfBirth,
    required this.age,
    required this.authMethod,
    required this.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final authService = AuthService();
    final age = authService.calculateAge(json['date_of_birth']);

    return UserModel(
      id: json['id'],
      fullName: json['full_name'] ?? 'User',
      email: json['email'],
      phoneNumber: json['phone_number'],
      gender: json['gender'] ?? 'Other',
      dateOfBirth: json['date_of_birth'],
      age: age,
      authMethod: json['auth_method'] ?? 'email',
      isVerified: json['is_verified'] ?? false,
    );
  }
}

// User state notifier
class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null);

  Future<void> loadUser(int userId) async {
    final authService = AuthService();
    final userData = await authService.getUserById(userId);

    if (userData != null) {
      state = UserModel.fromJson(userData);
    }
  }

  void setUser(Map<String, dynamic> userData) {
    state = UserModel.fromJson(userData);
  }

  void logout() {
    state = null;
  }
}

// Provider
final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});
