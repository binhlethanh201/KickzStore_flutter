import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/product_model.dart';

class ProductService {
  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/products'));

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
}