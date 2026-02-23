import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/order_provider.dart';
import '../../widgets/uniqlo_widgets.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _shippingMethod = "standard";
  String _paymentMethod = "cod"; 
  final TextEditingController _voucherController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final cartProv = Provider.of<CartProvider>(context);
    final orderProv = Provider.of<OrderProvider>(context);

    // Lấy địa chỉ từ profile user
    final addressObj = authProv.userProfile?['address'];
    final fullAddress = addressObj != null 
        ? "${addressObj['street']}, ${addressObj['district']}, ${addressObj['city']}"
        : "No address provided. Please update profile.";

    double subtotal = cartProv.cart?.totalPrice ?? 0;
    double shippingFee = _shippingMethod == "express" ? 5 : 0;
    double total = subtotal + shippingFee;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("CHECKOUT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ĐỊA CHỈ
            _buildSectionTitle("SHIPPING ADDRESS"),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
              child: Text(fullAddress, style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: 30),

            // 2. VẬN CHUYỂN
            _buildSectionTitle("SHIPPING METHOD"),
            RadioListTile(
              title: const Text("Standard Shipping (Free)"),
              value: "standard",
              groupValue: _shippingMethod,
              onChanged: (v) => setState(() => _shippingMethod = v.toString()),
              contentPadding: EdgeInsets.zero,
              activeColor: Colors.black,
            ),
            RadioListTile(
              title: const Text("Express Shipping (\$5.00)"),
              value: "express",
              groupValue: _shippingMethod,
              onChanged: (v) => setState(() => _shippingMethod = v.toString()),
              contentPadding: EdgeInsets.zero,
              activeColor: Colors.black,
            ),
            const SizedBox(height: 30),

            // 3. THANH TOÁN
            _buildSectionTitle("PAYMENT METHOD"),
            const SizedBox(height: 10),
            _buildPaymentOption("cod", "Cash on Delivery", Icons.money),
            _buildPaymentOption("credit_card", "Credit Card (Mockup)", Icons.credit_card),
            const SizedBox(height: 30),

            // 4. TÓM TẮT ĐƠN HÀNG
            _buildSectionTitle("ORDER SUMMARY"),
            const SizedBox(height: 15),
            _buildSummaryRow("Subtotal", "\$${subtotal.toStringAsFixed(2)}"),
            _buildSummaryRow("Shipping Fee", "\$${shippingFee.toStringAsFixed(2)}"),
            const Divider(height: 30),
            _buildSummaryRow("TOTAL", "\$${total.toStringAsFixed(2)}", isTotal: true),
            const SizedBox(height: 40),

            UniqloButton(
              text: "PLACE ORDER",
              isLoading: orderProv.isLoading,
              onPressed: () async {
                if (addressObj == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please update your shipping address in profile!")));
                  return;
                }

                // Chuyển đổi format items cho Backend
                final selectedItems = cartProv.cart!.items.map((item) => {
                  "productId": item.productId,
                  "size": item.size,
                  "color": item.color,
                  "quantity": item.quantity
                }).toList();

                await orderProv.placeOrder(
                  selectedItems: selectedItems,
                  shippingMethod: _shippingMethod,
                  address: fullAddress,
                  paymentMethod: _paymentMethod,
                  onSuccess: () {
                    // Xóa giỏ hàng local và về trang chủ hoặc trang thành công
                    cartProv.fetchCart(authProv.userProfile?['id'] ?? authProv.userProfile?['_id']);
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => AlertDialog(
                        title: const Text("SUCCESS"),
                        content: const Text("Your order has been placed successfully!"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            }, 
                            child: const Text("BACK TO HOME", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
                          )
                        ],
                      ),
                    );
                  },
                  onError: (err) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red[900]));
                  },
                );
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1));
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.w900 : FontWeight.w400, fontSize: isTotal ? 16 : 14)),
          Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600, fontSize: isTotal ? 20 : 14, color: isTotal ? const Color(0xFFE60012) : Colors.black)),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    bool isSelected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.black : Colors.grey[300]!, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.black : Colors.grey),
            const SizedBox(width: 15),
            Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, size: 20)
          ],
        ),
      ),
    );
  }
}