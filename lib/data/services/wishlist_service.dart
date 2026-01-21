import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../models/product_model.dart';

class WishlistService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // Lấy danh sách yêu thích của User
  Future<List<ProductModel>> getWishlist(String userId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/wishlists/user/$userId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['wishlist'];
      return data.map((item) => ProductModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load wishlist');
    }
  }

  // Thêm vào danh sách yêu thích
  Future<void> addToWishlist(String productId) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/wishlists'),
      headers: await _getHeaders(),
      body: jsonEncode({"productId": productId}),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to add to wishlist');
    }
  }

  // Xóa khỏi danh sách yêu thích
  Future<void> removeFromWishlist(String productId) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/wishlists/$productId'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to remove from wishlist');
    }
  }
}