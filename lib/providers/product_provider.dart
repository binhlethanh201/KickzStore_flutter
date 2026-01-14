import 'package:flutter/material.dart';
import '../data/models/product_model.dart';
import '../data/services/product_service.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;

  final ProductService _productService = ProductService();

  Future<void> getAllProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _productService.fetchProducts();
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}