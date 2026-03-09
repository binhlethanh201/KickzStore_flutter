import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/uniqlo_widgets.dart';
import '../auth/login_screen.dart';
import '../../widgets/cart_widgets.dart';
import './checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Set<String> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final authProv = Provider.of<AuthProvider>(context, listen: false);
      final userId =
          authProv.userProfile?['id'] ?? authProv.userProfile?['_id'];
      if (authProv.isAuthenticated && userId != null) {
        Provider.of<CartProvider>(
          context,
          listen: false,
        ).fetchCart(userId.toString()).then((_) {
          _selectAllItems();
        });
      }
    });
  }

  void _selectAllItems() {
    final cartProv = Provider.of<CartProvider>(context, listen: false);
    if (cartProv.cart != null) {
      setState(() {
        _selectedItems = cartProv.cart!.items
            .map((e) => "${e.productId}_${e.size}_${e.color}")
            .toSet();
      });
    }
  }

  double _calculateSelectedTotal(CartProvider cartProv) {
    if (cartProv.cart == null) return 0.0;
    double total = 0.0;
    for (var item in cartProv.cart!.items) {
      String itemKey = "${item.productId}_${item.size}_${item.color}";
      if (_selectedItems.contains(itemKey)) {
        total += item.price * item.quantity;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final cartProv = Provider.of<CartProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);
    final userId = authProv.userProfile?['id'] ?? authProv.userProfile?['_id'];

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
      body: !authProv.isAuthenticated
          ? _buildGuestView(context)
          : (cartProv.isLoading && cartProv.cart == null)
          ? const CartShimmer()
          : (cartProv.cart?.items.isEmpty ?? true)
          ? _buildEmptyCart()
          : _buildMemberCart(cartProv, userId?.toString()),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 100,
            color: Color(0xFFEEEEEE),
          ),
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

  Widget _buildMemberCart(CartProvider cartProv, String? userId) {
    bool isAllSelected =
        cartProv.cart != null &&
        _selectedItems.length == cartProv.cart!.items.length;
    double selectedTotal = _calculateSelectedTotal(cartProv);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: Row(
            children: [
              Checkbox(
                value: isAllSelected,
                activeColor: Colors.black,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectAllItems();
                    } else {
                      _selectedItems.clear();
                    }
                  });
                },
              ),
              const Text(
                "Select All",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: cartProv.cart!.items.length,
            separatorBuilder: (context, index) => const Divider(height: 40),
            itemBuilder: (context, index) {
              final item = cartProv.cart!.items[index];
              String itemKey = "${item.productId}_${item.size}_${item.color}";
              bool isSelected = _selectedItems.contains(itemKey);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: isSelected,
                    activeColor: Colors.black,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedItems.add(itemKey);
                        } else {
                          _selectedItems.remove(itemKey);
                        }
                      });
                    },
                  ),
                  Image.network(
                    item.img,
                    width: 90,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Size: ${item.size} | Color: ${item.color}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "\$${item.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFE60012),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _qtyBtn(Icons.remove, () {
                              if (userId != null && item.quantity > 1) {
                                cartProv.updateQuantity(
                                  item.productId,
                                  item.quantity - 1,
                                  item.size,
                                  item.color,
                                  userId,
                                );
                              }
                            }),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Text("${item.quantity}"),
                            ),
                            _qtyBtn(Icons.add, () {
                              if (userId != null) {
                                cartProv.updateQuantity(
                                  item.productId,
                                  item.quantity + 1,
                                  item.size,
                                  item.color,
                                  userId,
                                );
                              }
                            }),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 22,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                if (userId != null) {
                                  cartProv.removeItem(
                                    item.productId,
                                    item.size,
                                    item.color,
                                    userId,
                                  );
                                  setState(
                                    () => _selectedItems.remove(itemKey),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        _buildCheckoutSection(selectedTotal, cartProv.cart!.items),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Text(
        "YOUR CART IS EMPTY",
        style: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
        child: Icon(icon, size: 14),
      ),
    );
  }

  Widget _buildCheckoutSection(double total, List items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TOTAL",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              Text(
                "\$${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          UniqloButton(
            text: "Proceed to Checkout",
            onPressed: () {
              if (_selectedItems.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Please select at least one item to checkout",
                    ),
                    backgroundColor: Colors.black,
                  ),
                );
                return;
              }

              final selectedCartItems = items
                  .where(
                    (item) => _selectedItems.contains(
                      "${item.productId}_${item.size}_${item.color}",
                    ),
                  )
                  .toList();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CheckoutScreen(selectedCartItems: selectedCartItems),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
