import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/wishlist_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/uniqlo_widgets.dart';
import '../auth/login_screen.dart';
import '../product/product_detail_screen.dart';

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
        final userId =
            authProv.userProfile?['id'] ?? authProv.userProfile?['_id'];
        if (userId != null) {
          Provider.of<WishlistProvider>(
            context,
            listen: false,
          ).fetchWishlist(userId.toString());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProv = Provider.of<WishlistProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);
    final currentUserId =
        authProv.userProfile?['id'] ?? authProv.userProfile?['_id'];

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
      body: authProv.isAuthenticated
          ? _buildMemberWishlist(wishlistProv, currentUserId?.toString())
          : _buildGuestView(context),
    );
  }

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

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: prov.wishlistItems.length,
      separatorBuilder: (context, index) => const Divider(height: 40),
      itemBuilder: (context, index) {
        final product = prov.wishlistItems[index];
        final String wishlistHeroTag = "${product.id}-wishlist";

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: wishlistHeroTag,
              child: Image.network(
                product.img,
                width: 110,
                height: 130,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(width: 110, height: 130, color: Colors.grey[200]),
              ),
            ),
            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.brand.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (userId != null)
                            prov.toggleWishlist(product, userId);
                        },
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Sizes: ${product.size.isNotEmpty ? product.size.join(', ') : 'N/A'}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "\$${product.price.toInt()}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFE60012),
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 35,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            product: product,
                            heroTag: wishlistHeroTag,
                          ),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                      ),
                      child: const Text(
                        "VIEW DETAILS",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
