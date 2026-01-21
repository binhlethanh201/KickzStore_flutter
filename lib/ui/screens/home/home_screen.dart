// lib/ui/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../cart/cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final prov = Provider.of<ProductProvider>(context, listen: false);
      prov.fetchCategories();
      prov.fetchProducts(); // All products
      // Bạn có thể tạo thêm hàm fetchFeatured trong Provider tương tự fetchProducts
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProv = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text('KICKZSTORE', 
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 2)),
      actions: [
        // NÚT GIỎ HÀNG LUÔN XUẤT HIỆN Ở GÓC TRÊN
        IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
          },
          icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black, size: 26),
        ),
        const SizedBox(width: 8),
      ],
    ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO BANNER (Dành cho sản phẩm Featured)
            _buildHeroBanner(productProv),

            const SizedBox(height: 30),

            // 2. CATEGORY NAVIGATION (Tabs phẳng)
            _buildCategorySection(productProv),

            const SizedBox(height: 20),

            // 3. TRENDING NOW (Dựa trên route by-price hoặc getAll)
            _buildSectionTitle("TRENDING NOW"),
            _buildHorizontalProductList(productProv),

            const SizedBox(height: 40),

            // 4. MULTI-COLOR COLLECTION (Dựa trên route by-color-count)
            _buildPromoBanner(),

            const SizedBox(height: 40),

            // 5. ALL ITEMS (Grid View chính)
            _buildSectionTitle("EXPLORE ALL"),
            _buildProductGrid(productProv),
          ],
        ),
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildHeroBanner(ProductProvider prov) {
    return Container(
      width: double.infinity,
      height: 450,
      color: Colors.grey[100],
      child: Stack(
        children: [
          // Giả sử lấy cái ảnh đầu tiên của sản phẩm Featured làm Banner
          Positioned.fill(
            child: Image.network(
              "https://images.unsplash.com/photo-1552346154-21d32810aba3?q=80&w=2070", // Thay bằng product image thật
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("NEW ARRIVALS", style: TextStyle(backgroundColor: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                const Text("MODERN COMFORT\nFOR YOUR FEET", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                  child: const Text("SHOP NOW"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategorySection(ProductProvider prov) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: prov.categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          bool isSelected = prov.selectedCategory == prov.categories[index];
          return GestureDetector(
            onTap: () => prov.fetchProducts(category: prov.categories[index]),
            child: Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Text(
                prov.categories[index].toUpperCase(),
                style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.w400, color: isSelected ? Colors.black : Colors.grey, decoration: isSelected ? TextDecoration.underline : null),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
    );
  }

  Widget _buildHorizontalProductList(ProductProvider prov) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        itemCount: prov.products.take(5).length,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            child: ProductCard(product: prov.products[index]),
          );
        },
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(30),
      color: const Color(0xFFE60012), // Uniqlo Red
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("THE COLOR COLLECTION", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Express yourself with over 20+ unique colorways of our classic silhouettes.", style: TextStyle(color: Colors.white, fontSize: 18, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildProductGrid(ProductProvider prov) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true, // Quan trọng khi nằm trong SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 15,
        mainAxisSpacing: 25,
      ),
      itemCount: prov.products.length,
      itemBuilder: (context, index) => ProductCard(product: prov.products[index]),
    );
  }
}