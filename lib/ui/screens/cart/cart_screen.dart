import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/uniqlo_widgets.dart'; // Thêm import
import '../auth/login_screen.dart';       // Thêm import

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authProv = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProv.userProfile?['id'];
      if (authProv.isAuthenticated && userId != null) {
        Provider.of<CartProvider>(context, listen: false).fetchCart(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProv = Provider.of<CartProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);
    final userId = authProv.userProfile?['id'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "SHOPPING CART",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      // LOGIC: Nếu đã login hiện Cart, nếu chưa hiện Guest View
      body: authProv.isAuthenticated
          ? _buildMemberCart(cartProv, userId)
          : _buildGuestView(context),
    );
  }

  // Giao diện cho khách (Chưa đăng nhập)
  Widget _buildGuestView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 100, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 30),
          const Text(
            "YOUR BAG IS EMPTY",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          const Text(
            "Log in to see the items you added previously and start shopping.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 40),
          UniqloButton(
            text: "Log In / Register",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
          ),
        ],
      ),
    );
  }

  // Giao diện giỏ hàng cho thành viên
  Widget _buildMemberCart(CartProvider cartProv, String? userId) {
    if (cartProv.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }

    if (cartProv.cart?.items.isEmpty ?? true) {
      return const Center(child: Text("YOUR CART IS EMPTY", style: TextStyle(color: Colors.grey)));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: cartProv.cart!.items.length,
            separatorBuilder: (context, index) => const Divider(height: 40),
            itemBuilder: (context, index) {
              final item = cartProv.cart!.items[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(item.img, width: 100, height: 120, fit: BoxFit.cover),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("Size: ${item.size} | Color: ${item.color}", 
                             style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 10),
                        Text("\$${item.price}", 
                             style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFE60012))),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _qtyBtn(Icons.remove, () => cartProv.updateQuantity(item.productId, item.quantity - 1, item.size, item.color, userId!)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Text("${item.quantity}"),
                            ),
                            _qtyBtn(Icons.add, () => cartProv.updateQuantity(item.productId, item.quantity + 1, item.size, item.color, userId!)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () => cartProv.removeItem(item.productId, item.size, item.color, userId!),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              );
            },
          ),
        ),
        _buildCheckoutSection(cartProv.cart!.totalPrice),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildCheckoutSection(double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("TOTAL", style: TextStyle(fontWeight: FontWeight.w900)),
              Text("\$${total.toStringAsFixed(2)}", 
                   style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 20),
          UniqloButton(
            text: "Proceed to Checkout",
            onPressed: () {
              // Hướng đến trang Checkout
            },
          )
        ],
      ),
    );
  }
}