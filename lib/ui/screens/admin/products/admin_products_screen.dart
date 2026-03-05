import 'package:flutter/material.dart';
import '../../../../data/services/admin_service.dart';
import '../../../widgets/uniqlo_widgets.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final AdminService _adminService = AdminService();
  late Future<List<dynamic>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = _adminService.getAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "PRODUCTS MANAGEMENT",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _showProductForm(),
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text("NEW PRODUCT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No products found."));
          }

          final products = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final p = products[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[100],
                  child: Image.network(
                    p['img'],
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported),
                  ),
                ),
                title: Text(p['name'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                subtitle: Text("${p['brand']} • \$${p['price']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () => _showProductForm(product: p)),
                    IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => _confirmDelete(p['_id'])),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- FORM THÊM/SỬA SẢN PHẨM ---
  void _showProductForm({dynamic product}) {
    final isEdit = product != null;
    final nameCtrl = TextEditingController(text: isEdit ? product['name'] : '');
    final brandCtrl = TextEditingController(text: isEdit ? product['brand'] : '');
    final priceCtrl = TextEditingController(text: isEdit ? product['price'].toString() : '');
    final imgCtrl = TextEditingController(text: isEdit ? product['img'] : '');
    final catCtrl = TextEditingController(text: isEdit ? product['category'] : '');
    final descCtrl = TextEditingController(text: isEdit ? product['description'] : '');
    // Chuyển mảng Size/Color thành chuỗi để dễ nhập
    final sizeCtrl = TextEditingController(text: isEdit ? (product['size'] as List).join(', ') : '');
    final colorCtrl = TextEditingController(text: isEdit ? (product['color'] as List).join(', ') : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(isEdit ? "EDIT PRODUCT" : "ADD NEW KICKS", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UniqloInput(label: "Product Name", controller: nameCtrl),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: UniqloInput(label: "Brand", controller: brandCtrl)),
                  const SizedBox(width: 10),
                  Expanded(child: UniqloInput(label: "Price (\$)", controller: priceCtrl, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 15),
              UniqloInput(label: "Image URL", controller: imgCtrl),
              const SizedBox(height: 15),
              UniqloInput(label: "Category", controller: catCtrl),
              const SizedBox(height: 15),
              UniqloInput(label: "Description", controller: descCtrl),
              const SizedBox(height: 15),
              UniqloInput(label: "Sizes (split by comma: 40, 41)", controller: sizeCtrl),
              const SizedBox(height: 15),
              UniqloInput(label: "Colors (split by comma: Black, White)", controller: colorCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            onPressed: () async {
              // Convert chuỗi về List cho đúng Format Backend
              final List<double> sizes = sizeCtrl.text.split(',').map((s) => double.parse(s.trim())).toList();
              final List<String> colors = colorCtrl.text.split(',').map((c) => c.trim()).toList();

              final data = {
                "name": nameCtrl.text,
                "brand": brandCtrl.text,
                "price": double.parse(priceCtrl.text),
                "img": imgCtrl.text,
                "category": catCtrl.text,
                "description": descCtrl.text,
                "size": sizes,
                "color": colors,
              };

              bool success = isEdit ? await _adminService.updateProduct(product['_id'], data) : await _adminService.createProduct(data);
              
              if (!context.mounted) return;
              if (success) {
                Navigator.pop(ctx);
                _refreshProducts();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? "PRODUCT UPDATED" : "PRODUCT ADDED")));
              }
            },
            child: Text(isEdit ? "UPDATE" : "CREATE"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("DELETE PRODUCT", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("This kicks will be gone forever. Confirm?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          TextButton(
            onPressed: () async {
              final success = await _adminService.deleteProduct(id);
              if (!context.mounted) return;
              if (success) {
                Navigator.pop(ctx);
                _refreshProducts();
              }
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}