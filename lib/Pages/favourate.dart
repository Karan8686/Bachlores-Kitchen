import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:batchloreskitchen/prrovider/Cart/Cart_provider.dart';
import 'package:batchloreskitchen/prrovider/Cart/Cart_item.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> _favorites = [];
  Map<String, int> _itemQuantities = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      _favorites = favorites
          .map((item) => Map<String, dynamic>.from(jsonDecode(item)))
          .toList();
      
      // Initialize quantities
      for (var item in _favorites) {
        _itemQuantities[item['id'] ?? item['name']] = 1;
      }
    });
  }

  Future<void> _removeFavorite(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    favorites.remove(jsonEncode(item));
    await prefs.setStringList('favorites', favorites);
    setState(() {
      _favorites.remove(item);
    });
  }

  void _incrementQuantity(String itemId) {
    setState(() {
      _itemQuantities[itemId] = (_itemQuantities[itemId] ?? 1) + 1;
    });
  }

  void _decrementQuantity(String itemId) {
    if ((_itemQuantities[itemId] ?? 1) > 1) {
      setState(() {
        _itemQuantities[itemId] = (_itemQuantities[itemId] ?? 1) - 1;
      });
    }
  }

  void _addToCart(BuildContext context, Map<String, dynamic> item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cartItem = CartItemData(
      imageUrl: item['imageUrl'],
      name: item['name'],
      details: item['description'] ?? '',
      price: (item['price'] is num) ? item['price'].toDouble() : 0.0,
      quantity: _itemQuantities[item['id'] ?? item['name']] ?? 1,
    );
    cartProvider.addItem(cartItem);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${item['name']} to cart'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildFavoriteItem(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final itemId = item['id'] ?? item['name'];
    final double price = (item['price'] is num) ? item['price'].toDouble() : 0.0;
    final int quantity = _itemQuantities[itemId] ?? 1;
    final double totalPrice = price * quantity;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'favorite_${item['name']}',
                      child: Container(
                        width: 100.w,
                        height: 100.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CachedNetworkImage(
                          imageUrl: item['imageUrl'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: colorScheme.primary.withOpacity(0.1),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: colorScheme.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: colorScheme.primary.withOpacity(0.1),
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              color: colorScheme.primary,
                              size: 30.w,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                              letterSpacing: -0.5,
                              fontFamily: "poppins",
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.store_outlined,
                                size: 14.w,
                                color: colorScheme.primary.withOpacity(0.7),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  item['restaurant'],
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.6),
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: colorScheme.primary,
                                      size: 16.w,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      item['rating'],
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (price > 0)
                                Row(
                                  children: [
                                    if (quantity > 1)
                                      Text(
                                        '${quantity}x ₹${price.toStringAsFixed(2)} = ',
                                        style: TextStyle(
                                          color: colorScheme.onSurface.withOpacity(0.6),
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    Text(
                                      '₹${totalPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.primary),
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => _decrementQuantity(itemId),
                            icon: Icon(Icons.remove, color: colorScheme.primary, size: 18.w),
                            padding: EdgeInsets.all(4.w),
                            constraints: BoxConstraints(
                              minWidth: 30.w,
                              minHeight: 30.w,
                            ),
                          ),
                          Text(
                            "${_itemQuantities[itemId] ?? 1}",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: colorScheme.primary,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _incrementQuantity(itemId),
                            icon: Icon(Icons.add, color: colorScheme.primary, size: 18.w),
                            padding: EdgeInsets.all(4.w),
                            constraints: BoxConstraints(
                              minWidth: 30.w,
                              minHeight: 30.w,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _addToCart(context, item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                      ),
                      child: Text(
                        "Add to cart",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20.r),
                onTap: () => _removeFavorite(item),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: colorScheme.primary,
                    size: 20.w,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.background,
        title: Text(
          'Favorites',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.w600,
            fontFamily: "poppins",
          ),
        ),
      ),
      body: SafeArea(
        child: _favorites.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 64.w,
                      color: colorScheme.primary.withOpacity(0.2),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No favorites yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onBackground.withOpacity(0.7),
                        fontFamily: "poppins",
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                height: double.infinity,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: _favorites.length,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemBuilder: (context, index) => _buildFavoriteItem(context, _favorites[index]),
                ),
              ),
      ),
    );
  }
}

