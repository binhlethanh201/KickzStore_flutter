import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/wishlist_provider.dart';
import '../../../providers/product_provider.dart'; // Thêm để lấy sản phẩm liên quan
import '../auth/login_screen.dart';
import '../cart/cart_screen.dart'; // Import để điều hướng giỏ hàng
import '../../widgets/product_card.dart'; // Import để dùng ở mục gợi ý

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  double? selectedSize;
  String? selectedColor;

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
    final productProv = Provider.of<ProductProvider>(
      context,
    ); // Lấy danh sách sp
    final userId = authProv.userProfile?['id'];

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
          // THÊM: Icon Giỏ hàng để đồng bộ UX
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
            // 1. Ảnh sản phẩm
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: double.infinity,
              color: const Color(0xFFF7F7F7),
              child: Hero(
                tag: product.id,
                child: Image.network(product.img, fit: BoxFit.contain),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Tên và Giá
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

                  // 3. Chọn Màu Sắc
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

                  // 4. Chọn Size
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

                  // 5. Mô tả
                  _buildSectionTitle("DESCRIPTION"),
                  const SizedBox(height: 8),
                  Text(
                    product.description ??
                        "No description available for this classic silhouette.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 40),

                  // 6. THÊM: YOU MAY ALSO LIKE (Sử dụng tỉ lệ 0.58 để tránh Overflow)
                  _buildSectionTitle("YOU MAY ALSO LIKE"),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.58, // Tỉ lệ đã sửa lỗi tràn viền
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 25,
                        ),
                    itemCount: productProv.products.take(4).length,
                    itemBuilder: (context, index) =>
                        ProductCard(product: productProv.products[index]),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),

      // 7. BOTTOM BAR (Favorite & Add to Cart)
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: Row(
          children: [
            // NÚT WISHLIST
            Consumer<WishlistProvider>(
              builder: (context, wishlistProv, child) {
                bool isFav = wishlistProv.isFavorite(product.id);

                return GestureDetector(
                  onTap: (wishlistProv.isLoading)
                      ? null // Vô hiệu hóa khi đang xử lý
                      : () async {
                          // Lấy ID an toàn
                          final currentUserId =
                              authProv.userProfile?['id'] ??
                              authProv.userProfile?['_id'];

                          if (!authProv.isAuthenticated ||
                              currentUserId == null) {
                            _showMsg("Please log in to save favorites");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                            return;
                          }

                          try {
                            await wishlistProv.toggleWishlist(
                              product,
                              currentUserId,
                            );
                            if (mounted) {
                              _showMsg(
                                wishlistProv.isFavorite(product.id)
                                    ? "Added to wishlist"
                                    : "Removed from wishlist",
                              );
                            }
                          } catch (e) {
                            if (mounted)
                              _showMsg(
                                "Could not update wishlist",
                                isError: true,
                              );
                          }
                        },
                  child: Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: wishlistProv.isLoading
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
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav
                                ? const Color(0xFFE60012)
                                : Colors.black,
                          ),
                  ),
                );
              },
            ),
            const SizedBox(width: 15),

            // NÚT ADD TO CART (Hiển thị Loading nội bộ)
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
                  onPressed: (cartProv.isLoading)
                      ? null // Vô hiệu hóa nút khi đang gửi request
                      : () async {
                          // 1. Kiểm tra lựa chọn
                          if (selectedSize == null || selectedColor == null) {
                            _showMsg(
                              "Please select size and color",
                              isError: true,
                            );
                            return;
                          }

                          // Sửa dòng lấy UserId
                          final currentUserId =
                              authProv.userProfile?['id'] ??
                              authProv.userProfile?['_id'];

                          if (!authProv.isAuthenticated ||
                              currentUserId == null) {
                            _showMsg("Please log in to shop");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                            return;
                          }

                          try {
                            // 3. Thực hiện gọi Provider
                            await cartProv.addItem(
                              product.id,
                              1,
                              selectedSize!,
                              selectedColor!,
                              currentUserId,
                            );

                            // 4. Phản hồi thành công
                            if (mounted) {
                              _showMsg(
                                "Added to bag successfully",
                                isError: false,
                              );
                            }
                          } catch (e) {
                            // 5. Phản hồi lỗi (Ví dụ: Token hết hạn hoặc lỗi mạng)
                            if (mounted) {
                              _showMsg(
                                "Failed to add. Please try again.",
                                isError: true,
                              );
                            }
                          }
                        },
                  child: cartProv.isLoading
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
