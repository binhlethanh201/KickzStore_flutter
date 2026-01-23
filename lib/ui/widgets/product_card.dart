import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../screens/product/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hình ảnh sản phẩm
          Hero(
            tag: product.id, // Phải trùng ID với trang Detail
            child: AspectRatio(
              aspectRatio: 1 / 1.2,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  image: DecorationImage(
                    image: NetworkImage(
                      product.img.isNotEmpty
                          ? product.img
                          : 'https://via.placeholder.com/300',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Dùng Expanded hoặc giới hạn chiều cao các text để tránh Overflow
          Text(
            product.brand.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
            maxLines: 1, // GIỚI HẠN 1 dòng cho Brand
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 35,
            child: Text(
              product.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            "\$${product.price.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE60012),
            ),
          ),
        ],
      ),
    );
  }
}
