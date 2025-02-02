import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'Cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemData> _cartItems = [];

  CartProvider() {
    _loadCartItems();
  }

  List<CartItemData> get cartItems => _cartItems;

  Future<void> _loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString('cart_items');
    if (cartData != null) {
      final List<dynamic> decodedData = jsonDecode(cartData);
      _cartItems.addAll(decodedData.map((item) => CartItemData.fromJson(item)).toList());
      notifyListeners();
    }
  }

  Future<void> _saveCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_cartItems.map((item) => item.toJson()).toList());
    await prefs.setString('cart_items', encodedData);
  }

  void addItem(CartItemData item) {
    // Check if item already exists to prevent duplicates
    final existingItemIndex = _cartItems.indexWhere((cartItem) => cartItem.name == item.name);
    if (existingItemIndex != -1) {
      _cartItems[existingItemIndex].quantity += item.quantity;
    } else {
      _cartItems.add(item);
    }
    _saveCartItems();
    notifyListeners();
  }

  void removeItem(int index) {
    _cartItems.removeAt(index);
    _saveCartItems();
    notifyListeners();
  }

  double get subtotal =>
      _cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);

  void clearCart() {
    _cartItems.clear();
    _saveCartItems();
    notifyListeners();
  }
}