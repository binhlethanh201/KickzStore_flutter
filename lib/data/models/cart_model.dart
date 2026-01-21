class CartModel {
  final List<CartItemModel> items;

  CartModel({required this.items});

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      items: (json['items'] as List)
          .map((item) => CartItemModel.fromJson(item))
          .toList(),
    );
  }

  double get totalPrice => items.fold(0, (sum, item) => sum + (item.price * item.quantity));
}

class CartItemModel {
  final String productId;
  final String name;
  final String img;
  final double price;
  final String brand;
  final int quantity;
  final double? size;
  final String? color;

  CartItemModel({
    required this.productId,
    required this.name,
    required this.img,
    required this.price,
    required this.brand,
    required this.quantity,
    this.size,
    this.color,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // Lấy thông tin từ object productId đã được populate
    var productInfo = json['productId'];
    return CartItemModel(
      productId: productInfo['_id'],
      name: productInfo['name'],
      img: productInfo['img'],
      price: (productInfo['price'] ?? 0).toDouble(),
      brand: productInfo['brand'],
      quantity: json['quantity'],
      size: (json['size'] != null) ? json['size'].toDouble() : null,
      color: json['color'],
    );
  }
}