import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/wishlist_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/review_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/review_widgets.dart';
import '../auth/login_screen.dart';
import '../cart/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  final String heroTag;
  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.heroTag,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  double? selectedSize;
  String? selectedColor;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ReviewProvider>(
        context,
        listen: false,
      ).fetchReviews(widget.product.id);
    });
  }

  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: isError ? Colors.red[900] : Colors.black,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final authProv = Provider.of<AuthProvider>(context);
    final cartProv = Provider.of<CartProvider>(context);
    final wishlistProv = Provider.of<WishlistProvider>(context);
    final productProv = Provider.of<ProductProvider>(context);
    final userId = authProv.userProfile?['id'] ?? authProv.userProfile?['_id'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black, size: 22),
        title: Text(
          product.brand.toUpperCase(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _handleChat(context, authProv),
            icon: const Icon(Icons.chat_bubble_outline),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            ),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: double.infinity,
              color: const Color(0xFFF7F7F7),
              child: Hero(
                tag: widget.heroTag,
                child: Image.network(product.img, fit: BoxFit.contain),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "\$${product.price.toInt()}",
                        style: const TextStyle(
                          fontSize: 22,
                          color: Color(0xFFE60012),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.category.toUpperCase(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 30),

                  _buildSectionTitle("COLOR"),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: product.color.map((color) {
                      bool isSelected = selectedColor == color;
                      return GestureDetector(
                        onTap: () => setState(() => selectedColor = color),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            color: isSelected ? Colors.black : Colors.white,
                          ),
                          child: Text(
                            color.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 30),

                  _buildSectionTitle("SIZE"),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: product.size.map((size) {
                      bool isSelected = selectedSize == size;
                      return GestureDetector(
                        onTap: () => setState(() => selectedSize = size),
                        child: Container(
                          width: 65,
                          height: 45,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            color: isSelected ? Colors.black : Colors.white,
                          ),
                          child: Text(
                            size.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 40),

                  _buildSectionTitle("DESCRIPTION"),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : "No description available.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 40),

                  ReviewSection(productId: product.id),

                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 40),

                  _buildSectionTitle("YOU MAY ALSO LIKE"),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.58,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 25,
                        ),
                    itemCount: productProv.products.take(4).length,
                    itemBuilder: (context, index) => ProductCard(
                      product: productProv.products[index],
                      tagSuffix: "related-${productProv.products[index].id}",
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomSheet: _buildBottomAction(
        product,
        authProv,
        cartProv,
        wishlistProv,
        userId,
      ),
    );
  }

  void _handleChat(BuildContext context, AuthProvider auth) {
    if (!auth.isAuthenticated) {
      _showMsg("Please log in to chat with us");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }
    _showMsg("Opening chat support...");
  }

  Widget _buildBottomAction(
    ProductModel product,
    AuthProvider auth,
    CartProvider cart,
    WishlistProvider wish,
    String? userId,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: wish.isLoading
                ? null
                : () async {
                    if (!auth.isAuthenticated || userId == null) {
                      _showMsg("Please log in to save favorites");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => const LoginScreen(),
                        ),
                      );
                      return;
                    }
                    await wish.toggleWishlist(product, userId);
                    _showMsg(
                      wish.isFavorite(product.id)
                          ? "Added to wishlist"
                          : "Removed from wishlist",
                    );
                  },
            child: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: wish.isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : Icon(
                      wish.isFavorite(product.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: wish.isFavorite(product.id)
                          ? const Color(0xFFE60012)
                          : Colors.black,
                    ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  elevation: 0,
                ),
                onPressed: cart.isLoading
                    ? null
                    : () async {
                        if (selectedSize == null || selectedColor == null) {
                          _showMsg(
                            "Please select size and color",
                            isError: true,
                          );
                          return;
                        }
                        if (!auth.isAuthenticated || userId == null) {
                          _showMsg("Please log in to shop");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => const LoginScreen(),
                            ),
                          );
                          return;
                        }
                        try {
                          await cart.addItem(
                            product.id,
                            1,
                            selectedSize!,
                            selectedColor!,
                            userId,
                          );
                          _showMsg("Added to bag successfully");
                        } catch (e) {
                          _showMsg(
                            "Failed to add. Please try again.",
                            isError: true,
                          );
                        }
                      },
                child: cart.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        (selectedSize == null || selectedColor == null)
                            ? "SELECT SIZE & COLOR"
                            : "ADD TO BAG",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }
}
