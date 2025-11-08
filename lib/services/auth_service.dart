import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://localhost:3000';

  // Helper method to convert date format from DD/MM/YYYY to YYYY-MM-DD
  String _convertDateFormat(String dateStr) {
    try {
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

  Future<bool> signup(
    String email,
    String password,
    String fullName,
    String dateOfBirth,
    String? gender,
  ) async {
    try {
      print('🔵 Attempting signup with email: $email');

      // Convert date format
      final formattedDate = _convertDateFormat(dateOfBirth);
      print('🔵 Formatted date: $formattedDate');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup/email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
          'date_of_birth': formattedDate,
          'gender': gender,
        }),
      );

      print('🔵 Signup response status: ${response.statusCode}');
      print('🔵 Signup response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('✅ Signup successful');
          return true;
        }
      }

      // Handle error responses
      if (response.statusCode >= 400) {
        final errorData = jsonDecode(response.body);
        print('❌ Signup error: ${errorData['error']}');
      }

      return false;
    } catch (e) {
      print('❌ Signup exception: $e');
      return false;
    }
  }

  Future<bool> signupWithPhoneNumber(
    String phoneNumber,
    String otp,
    String fullName,
    String dateOfBirth,
    String? gender,
  ) async {
    try {
      print('🔵 Attempting phone signup: $phoneNumber');

      // Convert date format
      final formattedDate = _convertDateFormat(dateOfBirth);
      print('🔵 Formatted date: $formattedDate');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup/phone'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'otp': otp,
          'full_name': fullName,
          'date_of_birth': formattedDate,
          'gender': gender,
        }),
      );

      print('🔵 Phone signup response status: ${response.statusCode}');
      print('🔵 Phone signup response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('✅ Phone signup successful');
          return true;
        }
      }

      // Handle error responses
      if (response.statusCode >= 400) {
        final errorData = jsonDecode(response.body);
        print('❌ Phone signup error: ${errorData['error']}');
      }

      return false;
    } catch (e) {
      print('❌ Phone signup exception: $e');
      return false;
    }
  }

  Future<String?> sendOtp(String phoneNumber) async {
    try {
      print('🔵 Sending OTP to: $phoneNumber');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phoneNumber}),
      );

      print('🔵 OTP response status: ${response.statusCode}');
      print('🔵 OTP response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('✅ OTP sent successfully');
          return data['otp']; // Remove this in production
        }
      }

      return null;
    } catch (e) {
      print('❌ Send OTP exception: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      print('🔵 Attempting login with email: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('🔵 Login response status: ${response.statusCode}');
      print('🔵 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('✅ Login successful');
          return data['user'];
        }
      }

      // Handle error responses
      if (response.statusCode >= 400) {
        final errorData = jsonDecode(response.body);
        print('❌ Login error: ${errorData['error']}');
      }

      return null;
    } catch (e) {
      print('❌ Login exception: $e');
      return null;
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      print('🔵 Fetching user by ID: $userId');

      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('🔵 Get user response status: ${response.statusCode}');
      print('🔵 Get user response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('✅ User fetched successfully');
          return data['user'];
        }
      }

      return null;
    } catch (e) {
      print('❌ Get user exception: $e');
      return null;
    }
  }

  // Calculate age from date of birth
  int calculateAge(String? dateOfBirth) {
    if (dateOfBirth == null || dateOfBirth.isEmpty) {
      return 0;
    }

    try {
      final dob = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      int age = now.year - dob.year;

      // Check if birthday hasn't occurred this year yet
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }

      return age;
    } catch (e) {
      print('❌ Age calculation error: $e');
      return 0;
    }
  }
}
