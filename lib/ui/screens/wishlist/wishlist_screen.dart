import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/wishlist_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/uniqlo_widgets.dart';
import '../auth/login_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authProv = Provider.of<AuthProvider>(context, listen: false);
      if (authProv.isAuthenticated) {
        Provider.of<WishlistProvider>(
          context,
          listen: false,
        ).fetchWishlist(authProv.userProfile?['id']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProv = Provider.of<WishlistProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "WISHLIST",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      // LOGIC: Nếu đã login hiện Grid, nếu chưa hiện Guest View
      body: authProv.isAuthenticated
          ? _buildMemberWishlist(wishlistProv, authProv.userProfile?['id'])
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
          const Icon(
            Icons.favorite_outline,
            size: 100,
            color: Color(0xFFEEEEEE),
          ),
          const SizedBox(height: 30),
          const Text(
            "SAVE YOUR FAVORITES",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          const Text(
            "Log in to save items to your wishlist and access them from any device.",
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

  // Giao diện cho thành viên
  Widget _buildMemberWishlist(WishlistProvider prov, String? userId) {
    if (prov.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }

    if (prov.wishlistItems.isEmpty) {
      return const Center(
        child: Text(
          "YOUR WISHLIST IS EMPTY",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        // SỬA: Đổi từ 0.65 sang 0.58
        childAspectRatio: 0.58,
        crossAxisSpacing: 15,
        mainAxisSpacing: 25,
      ),
      itemCount: prov.wishlistItems.length,
      itemBuilder: (context, index) {
        final product = prov.wishlistItems[index];
        return Stack(
          children: [
            ProductCard(product: product),
            Positioned(
              top: 5,
              right: 5,
              child: GestureDetector(
                onTap: () => prov.toggleWishlist(product, userId!),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  // Tăng độ mờ nền để icon X rõ ràng hơn trên ảnh trắng
                  color: Colors.white.withOpacity(0.9),
                  child: const Icon(Icons.close, size: 18, color: Colors.black),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
