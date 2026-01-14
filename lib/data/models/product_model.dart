class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String img;
  final String brand;
  final String category;
  final List<double> size;
  final List<String> color;
  final bool isFeatured;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.img,
    required this.brand,
    required this.category,
    required this.size,
    required this.color,
    required this.isFeatured,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      img: json['img'] ?? '',
      brand: json['brand'] ?? '',
      category: json['category'] ?? '',
      size: List<double>.from(json['size']?.map((x) => x.toDouble()) ?? []),
      color: List<String>.from(json['color'] ?? []),
      isFeatured: json['isFeatured'] ?? false,
    );
  }
}