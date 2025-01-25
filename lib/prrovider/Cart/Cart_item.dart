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
}