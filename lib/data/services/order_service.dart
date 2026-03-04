import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

class OrderService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<Map<String, dynamic>> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/orders'),
      headers: await _getHeaders(),
      body: jsonEncode(orderData),
    );

    final result = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return result;
    } else {
      throw Exception(result['message'] ?? 'Failed to place order');
    }
  }
}
