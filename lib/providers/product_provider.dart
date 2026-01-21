// lib/providers/product_provider.dart
import 'package:flutter/material.dart';
import '../data/models/product_model.dart';
import '../data/services/product_service.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  final ProductService _productService = ProductService();

  List<ProductModel> _searchResults = [];
  List<ProductModel> get searchResults => _searchResults;

  // Lấy tất cả sản phẩm hoặc lọc theo category
  Future<void> fetchProducts({String? category}) async {
    _isLoading = true;
    _selectedCategory = category ?? 'All';
    notifyListeners();
    try {
      // Giả sử service của bạn hỗ trợ query params
      _products = await _productService.fetchProducts(
        category: category == 'All' ? null : category,
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy danh mục từ backend
  Future<void> fetchCategories() async {
    try {
      final data = await _productService
          .getCategories(); // Bạn cần thêm hàm này vào Service
      _categories = ['All', ...data];
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> searchProducts(String query) async {
  if (query.isEmpty) {
    _searchResults = [];
    notifyListeners();
    return;
  }
  
  _isLoading = true;
  notifyListeners();

  try {
    _searchResults = await _productService.searchProducts(query);
  } catch (e) {
    _searchResults = [];
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
}
