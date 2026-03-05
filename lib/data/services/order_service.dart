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

  Future<List<dynamic>> getUserOrders(String userId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/orders/$userId'),
      headers: await _getHeaders(),
    );

    final result = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return result['orders'] as List<dynamic>;
    } else {
      throw Exception(result['message'] ?? 'Failed to fetch orders');
    }
  }

  Future<Map<String, dynamic>> getOrderDetail(String orderId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/orders/detail/$orderId'),
      headers: await _getHeaders(),
    );

    final result = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return result['order'] as Map<String, dynamic>;
    } else {
      throw Exception(result['message'] ?? 'Failed to load order detail');
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/orders/$orderId/cancel'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final result = jsonDecode(response.body);
      throw Exception(result['message'] ?? 'Failed to cancel order');
    }
  }

  Future<bool> deleteOrder(String orderId) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/orders/$orderId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final result = jsonDecode(response.body);
      throw Exception(result['message'] ?? 'Failed to delete order');
    }
  }
}
