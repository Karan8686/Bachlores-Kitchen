import 'package:flutter/foundation.dart';
import 'Cart_item.dart';
import '../../Pages/cart.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemData> _cartItems = [];

  List<CartItemData> get cartItems => _cartItems;

  void addItem(CartItemData item) {
    // Check if item already exists to prevent duplicates
    if (!_cartItems.any((cartItem) => cartItem.name == item.name)) {
      _cartItems.add(item);
      notifyListeners();
    }
  }

  void removeItem(int index) {
    _cartItems.removeAt(index);
    notifyListeners();
  }

  double get subtotal =>
      _cartItems.fold(0, (sum, item) => sum + item.price);

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}