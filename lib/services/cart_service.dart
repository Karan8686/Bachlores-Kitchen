import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../prrovider/Cart/Cart_item.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userPhone => _auth.currentUser?.phoneNumber;

  Future<void> saveCart(List<CartItemData> items) async {
    if (_userPhone == null) return;

    await _firestore.collection('users').doc(_userPhone).set({
      'cart': items.map((item) => {
        'name': item.name,
        'details': item.details,
        'price': item.price,
        'quantity': item.quantity,
        'imageUrl': item.imageUrl,
      }).toList(),
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<CartItemData>> loadCart() async {
    if (_userPhone == null) return [];

    try {
      final doc = await _firestore.collection('users').doc(_userPhone).get();
      
      if (!doc.exists || !doc.data()!.containsKey('cart')) {
        return [];
      }

      final cartData = doc.data()!['cart'] as List<dynamic>;
      return cartData.map((item) => CartItemData(
        name: item['name'],
        details: item['details'],
        price: (item['price'] as num).toDouble(),
        quantity: item['quantity'],
        imageUrl: item['imageUrl'],
      )).toList();
    } catch (e) {
      print('Error loading cart: $e');
      return [];
    }
  }

  Future<void> clearCart() async {
    if (_userPhone == null) return;
    
    await _firestore.collection('users').doc(_userPhone).update({
      'cart': [],
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
}
