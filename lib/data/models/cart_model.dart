class CartModel {
  final List<CartItemModel> items;

  CartModel({required this.items});

  factory CartModel.fromJson(Map<String, dynamic> json) {
    List<CartItemModel> rawItems = (json['items'] as List)
        .map((item) => CartItemModel.fromJson(item))
        .toList();

    Map<String, CartItemModel> mergedMap = {};

    for (var item in rawItems) {
      String key =
          "${item.productId}_${item.size?.toStringAsFixed(1)}_${item.color}";

      if (mergedMap.containsKey(key)) {
        CartItemModel existing = mergedMap[key]!;
        mergedMap[key] = CartItemModel(
          productId: existing.productId,
          name: existing.name,
          img: existing.img,
          price: existing.price,
          brand: existing.brand,
          quantity: existing.quantity + item.quantity,
          size: existing.size,
          color: existing.color,
        );
      } else {
        mergedMap[key] = item;
      }
    }
    return CartModel(items: mergedMap.values.toList());
  }

  double get totalPrice =>
      items.fold(0, (sum, item) => sum + (item.price * item.quantity));
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
    var productInfo = json['productId'];

    String id = "";
    String n = "Unknown";
    String im = "";
    double p = 0.0;
    String b = "";

    if (productInfo is Map) {
      id = productInfo['_id'] ?? "";
      n = productInfo['name'] ?? "";
      im = productInfo['img'] ?? "";
      p = (productInfo['price'] ?? 0).toDouble();
      b = productInfo['brand'] ?? "";
    } else {
      id = productInfo.toString();
    }

    return CartItemModel(
      productId: id,
      name: n,
      img: im,
      price: p,
      brand: b,
      quantity: json['quantity'] ?? 1,
      size: (json['size'] != null) ? (json['size'] as num).toDouble() : null,
      color: json['color'],
    );
  }
}
