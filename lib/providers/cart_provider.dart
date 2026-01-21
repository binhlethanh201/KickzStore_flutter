import 'package:flutter/material.dart';
import '../data/models/cart_model.dart';
import '../data/services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  CartModel? _cart;
  bool _isLoading = false;

  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;

  Future<void> fetchCart(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _cart = await _cartService.getCart(userId);
    } catch (e) {
      _cart = CartModel(items: []);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(String productId, int quantity, double size, String color, String userId) async {
    try {
      await _cartService.addToCart(productId, quantity, size, color);
      await fetchCart(userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateQuantity(String productId, int newQuantity, double? size, String? color, String userId) async {
    try {
      await _cartService.updateQuantity(productId, newQuantity, size, color);
      await fetchCart(userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeItem(String productId, double? size, String? color, String userId) async {
    try {
      await _cartService.deleteItem(productId, size, color);
      await fetchCart(userId);
    } catch (e) {
      rethrow;
    }
  }
}