import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'Cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemData> _cartItems = [];
  String? _userLoginId;

  CartProvider() {
    _loadUserLoginId();
  }

  List<CartItemData> get cartItems => _cartItems;

  Future<void> _loadUserLoginId() async {
    final prefs = await SharedPreferences.getInstance();
    _userLoginId = prefs.getString('user_login_id');
    if (_userLoginId != null) {
      _loadCartItems();
    }
  }

  Future<void> _loadCartItems() async {
    if (_userLoginId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString('cart_items_$_userLoginId');
    if (cartData != null) {
      final List<dynamic> decodedData = jsonDecode(cartData);
      _cartItems.addAll(decodedData.map((item) => CartItemData.fromJson(item)).toList());
      notifyListeners();
    }
  }

  Future<void> _saveCartItems() async {
    if (_userLoginId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_cartItems.map((item) => item.toJson()).toList());
    await prefs.setString('cart_items_$_userLoginId', encodedData);
  }

  void addItem(CartItemData item) {
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

  void setCartItems(List<CartItemData> items) {
    _cartItems.clear();
    _cartItems.addAll(items);
    notifyListeners();
  }

  void updateQuantity(CartItemData item, int quantity) {
    final index = _cartItems.indexOf(item);
    if (index != -1) {
      _cartItems[index] = CartItemData(
        name: item.name,
        details: item.details,
        price: item.price,
        quantity: quantity,
        imageUrl: item.imageUrl,
      );
      _saveCartItems();
      notifyListeners();
    }
  }
}