import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Đăng ký
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/register'),
        headers: {"Content-Type": "application/json"},
        // Chỉ gửi các trường bắt buộc theo model Backend của bạn để tối giản form
        body: jsonEncode({
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Đăng nhập
  Future<String> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Lưu token vào máy
        final token = body['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        return token;
      } else {
        throw Exception(body['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // Get Profile
  Future<Map<String, dynamic>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/users/profile'),
      headers: {
        "Content-Type": "application/json",
        "Authorization":
            "Bearer $token", // Đính kèm token để qua middleware verifyToken
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['user'];
    } else {
      throw Exception('Failed to load profile');
    }
  }

  //update Profile
  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/users/profile'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to update profile');
    }
  }

  //Change password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/users/password'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "oldPassword": oldPassword,
        "newPassword": newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to change password');
    }
  }
}
