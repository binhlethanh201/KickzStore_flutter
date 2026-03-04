import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/product_model.dart';

class ProductService {
  Future<List<ProductModel>> fetchProducts({String? category}) async {
    try {
      final queryParams = category != null ? '?category=$category' : '';
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/products$queryParams'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/products/categories'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item['name'].toString()).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<ProductModel>> fetchFeaturedProducts() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/products?featured=true'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => ProductModel.fromJson(item)).toList();
    }
    throw Exception('Failed to load featured products');
  }

  Future<List<ProductModel>> fetchByColorCount() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/products/by-color-count'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => ProductModel.fromJson(item)).toList();
    }
    throw Exception('Failed to load color variants');
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/products/search?q=$query'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => ProductModel.fromJson(item)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Lỗi tìm kiếm sản phẩm');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
