import 'package:flutter/material.dart';
import '../data/services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> placeOrder({
    required List<Map<String, dynamic>> selectedItems,
    required String shippingMethod,
    required String address,
    required String paymentMethod,
    String? voucherCode,
    String? cardId,
    String? cvv,
    required Function(String?) onSuccess,
    required Function(String) onError,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final body = {
        "selectedItems": selectedItems,
        "shippingMethod": shippingMethod,
        "address": address,
        "paymentMethod": paymentMethod,
        if (voucherCode != null) "voucherCode": voucherCode,
        if (cardId != null) "cardId": cardId,
        if (cvv != null) "cvv": cvv,
      };

      final response = await _orderService.createOrder(body);

      final vnpayUrl = response['vnpayUrl'];
      onSuccess(vnpayUrl);
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
