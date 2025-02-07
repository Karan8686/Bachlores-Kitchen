import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:batchloreskitchen/prrovider/Cart/Cart_provider.dart';
import 'package:batchloreskitchen/prrovider/Cart/Cart_item.dart';

class Details extends StatefulWidget {
  final String itemId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final double rating;
  final String restaurant;
  final String category;
  final bool isVegetarian;
  final String deliveryTime; // New: Delivery time from restaurant's delivery_info
  final Map<String, dynamic> nutritionalInfo; // New: Nutritional info of the item

  const Details({
    Key? key,
    required this.itemId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.restaurant,
    required this.category,
    required this.isVegetarian,
    required this.deliveryTime,
    required this.nutritionalInfo,
  }) : super(key: key);

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int itemCount = 1;
  bool isFavorite = false;
  final ScrollController _scrollController = ScrollController();

  void incrementItemCount() {
    if (itemCount < 9) {
      setState(() {
        itemCount++;
      });
    }
  }

  void decrementItemCount() {
    if (itemCount > 1) {
      setState(() {
        itemCount--;
      });
    }
  }

  void _addToCart(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final item = CartItemData(
      imageUrl: widget.imageUrl,
      name: widget.name,
      details: widget.description,
      price: widget.price,
      quantity: itemCount,
    );
    cartProvider.addItem(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${widget.name} to cart'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Full-width image at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.network(
              widget.imageUrl,
              width: double.infinity,
              height: 350.h,
              fit: BoxFit.cover,
            ).animate().fadeIn(duration: 600.ms).scale(),
          ),

          // Back and Favorite buttons
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 16.w,
            right: 16.w,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.surface.withOpacity(0.7),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.pop(context),
                      color: colorScheme.primary,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: colorScheme.surface.withOpacity(0.7),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: colorScheme.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scrollable content
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.95,
            builder: (context, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32.r),
                    topRight: Radius.circular(32.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ListView(
                  controller: controller,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 5.h,
                        margin: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildProductDetails(theme, colorScheme),
                    SizedBox(height: 8.h),
                    _buildAdditionalInfo(colorScheme),
                    SizedBox(height: 16.h),
                    _buildIngredients(colorScheme),
                    SizedBox(height: 16.h),
                    _buildDescription(colorScheme),
                    SizedBox(height: 16.h),
                    _buildNutritionalDetails(colorScheme),
                    SizedBox(height: 100.h), // Extra space for bottom bar
                  ],
                ),
              );
            },
          ),

          // Sticky Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: _buildBottomBar(colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display dish name.
        Text(
          widget.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        // Display restaurant name and rating.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.restaurant,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: colorScheme.primary,
                  size: 24.w,
                ),
                SizedBox(width: 4.w),
                Text(
                  widget.rating.toString(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // New widget: Displays additional info including category, veg flag and delivery time.
  Widget _buildAdditionalInfo(ColorScheme colorScheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Chip(
            label: Text(
              widget.category,
              style: TextStyle(
                fontSize: 14.sp,
                color: colorScheme.primary,
              ),
            ),
            backgroundColor: colorScheme.primary.withOpacity(0.1),
          ),
          SizedBox(width: 8.w),
          Chip(
            label: Text(
              widget.isVegetarian ? "Vegetarian" : "Non-Vegetarian",
              style: TextStyle(
                fontSize: 14.sp,
                color: widget.isVegetarian ? Colors.green : Colors.red,
              ),
            ),
            backgroundColor: widget.isVegetarian
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
          ),
          SizedBox(width: 8.w),
          // Display delivery time from the restaurant.
          Chip(
            label: Text(
              "Delivery: ${widget.deliveryTime} mins",
              style: TextStyle(
                fontSize: 14.sp,
                color: colorScheme.primary,
              ),
            ),
            backgroundColor: colorScheme.primary.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredients(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ingredients",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          children: [
            _buildIngredientChip("Rice", colorScheme),
            _buildIngredientChip("Carrot", colorScheme),
            _buildIngredientChip("Broccoli", colorScheme),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          widget.description,
          style: TextStyle(
            fontSize: 14.sp,
            color: colorScheme.onSurface.withOpacity(0.6),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientChip(String label, ColorScheme colorScheme) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 14.sp,
        ),
      ),
      backgroundColor: colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }

  // New widget: Nicely display nutritional information.
  Widget _buildNutritionalDetails(ColorScheme colorScheme) {
    if (widget.nutritionalInfo.isEmpty) return SizedBox.shrink();
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nutritional Information",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          _buildNutritionRow("Calories", widget.nutritionalInfo["calories"]),
          _buildNutritionRow("Carbs", widget.nutritionalInfo["carbs"]),
          _buildNutritionRow("Protein", widget.nutritionalInfo["protein"]),
          _buildNutritionRow("Prep Time", widget.nutritionalInfo["preparation_time"]),
          _buildNutritionRow("Spice Level", widget.nutritionalInfo["spice_level"]),
        ],
      ),
    );
  }

  // Helper widget to build each nutritional info row.
  Widget _buildNutritionRow(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value != null ? value.toString() : '-',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ColorScheme colorScheme) {
    return Row(
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
                onPressed: decrementItemCount,
                icon: Icon(Icons.remove, color: colorScheme.primary),
              ),
              Text(
                "$itemCount",
                style: TextStyle(
                  fontSize: 20.sp,
                  color: colorScheme.primary,
                ),
              ),
              IconButton(
                onPressed: incrementItemCount,
                icon: Icon(Icons.add, color: colorScheme.primary),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () => _addToCart(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.r),
            ),
          ),
          child: Text(
            "Add to cart",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
