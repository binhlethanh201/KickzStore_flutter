import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/order_provider.dart';
import '../../widgets/uniqlo_widgets.dart';

class CheckoutScreen extends StatefulWidget {
  final List<dynamic> selectedCartItems;

  const CheckoutScreen({super.key, required this.selectedCartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _shippingMethod = "standard";
  String _paymentMethod = "vnpay";
  final TextEditingController _voucherController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProv = Provider.of<AuthProvider>(context, listen: false);
      final addressObj = authProv.userProfile?['address'];
      if (addressObj != null && addressObj['street'] != null) {
        _addressController.text =
            "${addressObj['street']}, ${addressObj['district']}, ${addressObj['city']}";
      }
    });
  }

  @override
  void dispose() {
    _voucherController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _launchVNPayUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch payment gateway')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final cartProv = Provider.of<CartProvider>(context);
    final orderProv = Provider.of<OrderProvider>(context);

    double subtotal = 0.0;
    for (var item in widget.selectedCartItems) {
      subtotal += (item.price * item.quantity);
    }

    double shippingFee = _shippingMethod == "express" ? 5 : 0;
    double total = subtotal + shippingFee;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "CHECKOUT",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("SHIPPING ADDRESS"),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText:
                    "Enter your full shipping address (Street, District, City)",
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 30),

            _buildSectionTitle("SHIPPING METHOD"),
            RadioGroup<String>(
              groupValue: _shippingMethod,
              onChanged: (v) {
                if (v != null) {
                  setState(() => _shippingMethod = v);
                }
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text(
                      "Standard Shipping (Free)",
                      style: TextStyle(fontSize: 14),
                    ),
                    value: "standard",
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.black,
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                  RadioListTile<String>(
                    title: const Text(
                      "Express Shipping (\$5.00)",
                      style: TextStyle(fontSize: 14),
                    ),
                    value: "express",
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.black,
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            _buildSectionTitle("PAYMENT METHOD"),
            const SizedBox(height: 10),
            _buildPaymentOption(
              "vnpay",
              "Thanh toán VNPay (ATM/Internet Banking)",
              Icons.account_balance_wallet,
            ),
            _buildPaymentOption("cod", "Cash on Delivery", Icons.money),
            _buildPaymentOption(
              "credit_card",
              "Credit Card (Mockup)",
              Icons.credit_card,
            ),
            const SizedBox(height: 30),

            _buildSectionTitle("PROMO CODE"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: UniqloInput(
                    label: "Voucher Code",
                    controller: _voucherController,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      if (_voucherController.text.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("PROMO CODE APPLIED")),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: const Text(
                      "APPLY",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            _buildSectionTitle("ORDER SUMMARY"),
            const SizedBox(height: 15),
            _buildSummaryRow("Subtotal", "\$${subtotal.toStringAsFixed(2)}"),
            _buildSummaryRow(
              "Shipping Fee",
              "\$${shippingFee.toStringAsFixed(2)}",
            ),
            const Divider(height: 30),
            _buildSummaryRow(
              "TOTAL",
              "\$${total.toStringAsFixed(2)}",
              isTotal: true,
            ),
            const SizedBox(height: 40),

            UniqloButton(
              text: "PLACE ORDER",
              isLoading: orderProv.isLoading,
              onPressed: () async {
                final address = _addressController.text.trim();
                if (address.isEmpty || address.length < 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid shipping address!"),
                    ),
                  );
                  return;
                }
                final formattedItems = widget.selectedCartItems
                    .map(
                      (item) => {
                        "productId": item.productId,
                        "size": item.size,
                        "color": item.color,
                        "quantity": item.quantity,
                      },
                    )
                    .toList();

                await orderProv.placeOrder(
                  selectedItems: formattedItems,
                  shippingMethod: _shippingMethod,
                  address: address,
                  paymentMethod: _paymentMethod,
                  onSuccess: (String? vnpayUrl) {
                    cartProv.fetchCart(
                      authProv.userProfile?['id'] ??
                          authProv.userProfile?['_id'],
                    );

                    if (!context.mounted) return;

                    if (vnpayUrl != null && vnpayUrl.isNotEmpty) {
                      _launchVNPayUrl(vnpayUrl);
                    } else {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => AlertDialog(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          title: const Text(
                            "SUCCESS",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: const Text(
                            "Your order has been placed successfully!",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                Navigator.of(
                                  context,
                                ).popUntil((route) => route.isFirst);
                              },
                              child: const Text(
                                "BACK TO HOME",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  onError: (err) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(err),
                        backgroundColor: Colors.red[900],
                      ),
                    );
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
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 13,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w400,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
              fontSize: isTotal ? 20 : 14,
              color: isTotal ? const Color(0xFFE60012) : Colors.black,
            ),
          ),
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
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.black : Colors.grey,
            ),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, size: 20),
          ],
        ),
      ),
    );
  }
}
