import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../models/cart_model.dart';

class CartService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<CartModel> getCart(String userId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/carts/user/$userId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return CartModel.fromJson(jsonDecode(response.body)['cart']);
    } else {
      throw Exception('Failed to load cart');
    }
  }

  Future<void> addToCart(String productId, int quantity, double size, String color) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/carts'),
      headers: await _getHeaders(),
      body: jsonEncode({
        "productId": productId,
        "quantity": quantity,
        "size": size,
        "color": color,
      }),
    );
    if (response.statusCode != 200) throw Exception('Failed to add to cart');
  }

  Future<void> updateQuantity(String productId, int quantity, double? size, String? color) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/carts/$productId'),
      headers: await _getHeaders(),
      body: jsonEncode({"quantity": quantity, "size": size, "color": color}),
    );
    if (response.statusCode != 200) throw Exception('Failed to update cart');
  }

  Future<void> deleteItem(String productId, double? size, String? color) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/carts/$productId'),
      headers: await _getHeaders(),
      body: jsonEncode({"size": size, "color": color}),
    );
    if (response.statusCode != 200) throw Exception('Failed to delete item');
  }
}