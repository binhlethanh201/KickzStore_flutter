import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

class AdminService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/dashboard-stats'),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(res.body);
  }

  Future<List<dynamic>> getOrderReport(String type) async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/reports/orders?type=$type'),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(res.body);
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    final token = await _getToken();
    final res = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/admin/orders/$orderId/status'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"status": status}),
    );
    return res.statusCode == 200;
  }

  Future<List<dynamic>> getAllOrders() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/orders'),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(res.body);
  }

  Future<List<dynamic>> getAllProducts() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/products'),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(res.body);
  }
}
