class CartItemData {
  final String imageUrl;
  final String name;
  final String details;
  final double price;
  int quantity;
  bool isSelected;

  CartItemData({
    required this.imageUrl,
    required this.name,
    required this.details,
    required this.price,
    this.quantity = 1,
    this.isSelected = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'name': name,
      'details': details,
      'price': price,
      'quantity': quantity,
      'isSelected': isSelected,
    };
  }

  factory CartItemData.fromJson(Map<String, dynamic> json) {
    return CartItemData(
      imageUrl: json['imageUrl'],
      name: json['name'],
      details: json['details'],
      price: json['price'],
      quantity: json['quantity'],
      isSelected: json['isSelected'],
    );
  }
}