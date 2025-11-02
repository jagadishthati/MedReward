import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class AuthService {
  // Auto-detect platform and use appropriate URL
  static String get baseUrl {
    if (kIsWeb) {
      // Flutter Web
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      // Android Emulator
      return 'http://10.0.2.2:3000';
    } else if (Platform.isIOS) {
      // iOS Simulator
      return 'http://localhost:3000';
    } else {
      // Default (or use your computer's IP for real devices)
      return 'http://localhost:3000';
    }
  }

  // Email/Password Signup
  Future<bool> signup(
    String email,
    String password,
    String name,
    String dob,
    String? gender,
  ) async {
    try {
      // Convert date format from DD/MM/YYYY to YYYY-MM-DD
      final dobFormatted = _convertDateFormat(dob);

      print('Attempting signup to: $baseUrl/auth/signup/email');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup/email'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'full_name': name,
          'date_of_birth': dobFormatted,
          'gender': gender ?? 'Other',
          'email': email,
          'password': password,
        }),
      );

      print('Signup Response Status: ${response.statusCode}');
      print('Signup Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Optionally store user data locally
          return true;
        }
      } else if (response.statusCode == 409) {
        // Email already exists
        print('Email already registered');
      } else if (response.statusCode == 400) {
        // Validation error
        print('Validation error');
      }

      return false;
    } catch (e) {
      print('Signup Error: $e');
      return false;
    }
  }

  // Phone Number/OTP Signup
  Future<bool> signupWithPhoneNumber(
    String phoneNumber,
    String otp,
    String name,
    String dob,
    String? gender,
  ) async {
    try {
      // Convert date format from DD/MM/YYYY to YYYY-MM-DD
      final dobFormatted = _convertDateFormat(dob);

      print('Attempting phone signup to: $baseUrl/auth/signup/phone');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup/phone'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'full_name': name,
          'date_of_birth': dobFormatted,
          'gender': gender ?? 'Other',
          'phone_number': phoneNumber,
          'otp': otp,
        }),
      );

      print('Phone Signup Response Status: ${response.statusCode}');
      print('Phone Signup Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return true;
        }
      } else if (response.statusCode == 400) {
        print('Invalid or expired OTP');
      } else if (response.statusCode == 409) {
        print('Phone number already registered');
      }

      return false;
    } catch (e) {
      print('Phone Signup Error: $e');
      return false;
    }
  }

  // Send OTP to Phone Number
  Future<String?> sendOtp(String phoneNumber) async {
    try {
      print('Sending OTP to: $baseUrl/auth/send-otp');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
        }),
      );

      print('Send OTP Response Status: ${response.statusCode}');
      print('Send OTP Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // In development, the OTP is returned in the response
          // In production, this should be removed
          return data['otp'];
        }
      }

      return null;
    } catch (e) {
      print('Send OTP Error: $e');
      return null;
    }
  }

  // Email/Password Login
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      print('Attempting login to: $baseUrl/auth/login/email');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/email'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['user'];
        }
      }

      return null;
    } catch (e) {
      print('Login Error: $e');
      return null;
    }
  }

  // Get User by ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      print('Fetching user: $baseUrl/users/$userId');

      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Get User Response Status: ${response.statusCode}');
      print('Get User Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['user'];
        }
      }

      return null;
    } catch (e) {
      print('Get User Error: $e');
      return null;
    }
  }

  // Calculate age from date of birth
  int calculateAge(String dateOfBirth) {
    try {
      // Parse YYYY-MM-DD format
      final dob = DateTime.parse(dateOfBirth);
      final today = DateTime.now();
      int age = today.year - dob.year;

      // Check if birthday hasn't occurred this year yet
      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }

      return age;
    } catch (e) {
      print('Age calculation error: $e');
      return 0;
    }
  }

  // Helper function to convert date format
  String _convertDateFormat(String dateStr) {
    try {
      // Input format: DD/MM/YYYY
      // Output format: YYYY-MM-DD
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day';
      }
    } catch (e) {
      print('Date conversion error: $e');
    }
    return dateStr;
  }
}
