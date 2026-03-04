import 'package:flutter/material.dart';
import '../../../../data/services/admin_service.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PRODUCTS MANAGEMENT",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text(
              "NEW PRODUCT",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _adminService.getAllProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData)
            return const Center(child: Text("No products found."));

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return ListTile(
                leading: Image.network(
                  p['img'],
                  width: 50,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported),
                ),
                title: Text(
                  p['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("${p['brand']} - \$${p['price']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
