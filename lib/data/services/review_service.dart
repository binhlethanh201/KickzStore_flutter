import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../models/review_model.dart';

class ReviewService {
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/reviews/product/$productId'),
      );
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((item) => ReviewModel.fromJson(item)).toList();
      }
    } catch (e) {
      print("Error fetching reviews: $e");
    }
    return [];
  }

  Future<bool> createReview({
    required String productId,
    required int rating,
    required String comment,
    List<String>? images,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/reviews'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "productId": productId,
          "rating": rating,
          "comment": comment,
          "images": images ?? [],
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> replyReview({
    required String reviewId,
    required String comment,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/reviews/$reviewId/reply'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"comment": comment}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
