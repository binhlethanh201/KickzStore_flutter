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

  // --- ORDERS MANAGEMENT ---
  Future<List<dynamic>> getAllOrders() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/orders'),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/orders/$orderId'),
      headers: {"Authorization": "Bearer $token"},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception("Failed to load order details");
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

  Future<bool> deleteOrder(String orderId) async {
    final token = await _getToken();
    final res = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/admin/orders/$orderId'),
      headers: {"Authorization": "Bearer $token"},
    );
    return res.statusCode == 200;
  }

  // --- PRODUCTS MANAGEMENT ---
  Future<List<dynamic>> getAllProducts() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/products'),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(res.body);
  }

  Future<bool> createProduct(Map<String, dynamic> data) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/admin/products'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );
    return res.statusCode == 201;
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> data) async {
    final token = await _getToken();
    final res = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/admin/products/$id'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );
    return res.statusCode == 200;
  }

  Future<bool> deleteProduct(String id) async {
    final token = await _getToken();
    final res = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/admin/products/$id'),
      headers: {"Authorization": "Bearer $token"},
    );
    return res.statusCode == 200;
  }

  // --- USERS MANAGEMENT ---
  Future<List<dynamic>> getAllUsers() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/users'),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getUserById(String userId) async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/users/$userId'),
      headers: {"Authorization": "Bearer $token"},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception("Failed to load user details");
  }

  Future<bool> updateUserRole(String userId, String role) async {
    final token = await _getToken();
    final res = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/admin/users/$userId'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"role": role}),
    );
    return res.statusCode == 200;
  }

  Future<bool> deleteUser(String userId) async {
    final token = await _getToken();
    final res = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/admin/users/$userId'),
      headers: {"Authorization": "Bearer $token"},
    );
    return res.statusCode == 200;
  }

  // --- VOUCHERS MANAGEMENT ---
  Future<List<dynamic>> getAllVouchers() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/vouchers'),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(res.body);
  }

  Future<bool> createVoucher(Map<String, dynamic> data) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/admin/vouchers'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );
    return res.statusCode == 201;
  }

  Future<bool> updateVoucher(String id, Map<String, dynamic> data) async {
    final token = await _getToken();
    final res = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/admin/vouchers/$id'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );
    return res.statusCode == 200;
  }

  Future<bool> deleteVoucher(String id) async {
    final token = await _getToken();
    final res = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/admin/vouchers/$id'),
      headers: {"Authorization": "Bearer $token"},
    );
    return res.statusCode == 200;
  }
}
