import 'package:flutter/material.dart';
import '../data/models/product_model.dart';
import '../data/services/wishlist_service.dart';

class WishlistProvider with ChangeNotifier {
  final WishlistService _wishlistService = WishlistService();
  List<ProductModel> _wishlistItems = [];
  bool _isLoading = false;

  List<ProductModel> get wishlistItems => _wishlistItems;
  bool get isLoading => _isLoading;

  Future<void> fetchWishlist(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _wishlistItems = await _wishlistService.getWishlist(userId);
    } catch (e) {
      _wishlistItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleWishlist(ProductModel product, String userId) async {
    final isExist = _wishlistItems.any((item) => item.id == product.id);
    try {
      if (isExist) {
        await _wishlistService.removeFromWishlist(product.id);
        _wishlistItems.removeWhere((item) => item.id == product.id);
      } else {
        await _wishlistService.addToWishlist(product.id);
        _wishlistItems.add(product);
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  bool isFavorite(String productId) {
    return _wishlistItems.any((item) => item.id == productId);
  }
}