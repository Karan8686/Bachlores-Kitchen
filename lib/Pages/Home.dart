import 'dart:ui';
import 'package:batchloreskitchen/Pages/details.dart';
import 'package:batchloreskitchen/Pages/profile.dart';

import 'package:batchloreskitchen/prrovider/Cart/Cart_item.dart';
import 'package:batchloreskitchen/prrovider/Cart/Cart_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _selectedCategoryIndex = 0;
  bool _showFloatingButton = false;
 

  // Category titles remain the same.
  final List<String> _categories = [
    'All', 'Popular', 'Recommended', 'Near You', 'Top Rated'
  ];

  // Lists to store food items extracted from Firestore.
  List<Map<String, dynamic>> _allFoodItems = [];
  List<Map<String, dynamic>> _popularFoodItems = [];
  List<Map<String, dynamic>> _moreFoodItems = [];
  bool _isLoading = true;

  // Returns the list to display based on the selected category.
  List<Map<String, dynamic>> get _currentItems {
    switch (_selectedCategoryIndex) {
      case 0: // All
        return _allFoodItems;
      case 1: // Popular
        return _popularFoodItems;
      default:
        return _moreFoodItems;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
   
    fetchFoodItems();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showFloatingButton) {
      setState(() => _showFloatingButton = true);
    } else if (_scrollController.offset <= 200 && _showFloatingButton) {
      setState(() => _showFloatingButton = false);
    }
  }

  // Fetch food items by iterating over each restaurant document and extracting menu_items.
  Future<void> fetchFoodItems() async {
    try {
      QuerySnapshot restaurantSnapshot =
          await FirebaseFirestore.instance.collection('restaurants').get();

      List<Map<String, dynamic>> mergedItems = [];
      for (var doc in restaurantSnapshot.docs) {
        Map<String, dynamic> restaurantData = doc.data() as Map<String, dynamic>;
        if (restaurantData.containsKey('menu_items')) {
          List<dynamic> items = restaurantData['menu_items'];
          for (var item in items) {
            // Create a copy of the item map and attach restaurant name if needed.
            Map<String, dynamic> foodItem = Map<String, dynamic>.from(item);
            foodItem['restaurant_name'] = restaurantData['restaurant_name'];
            mergedItems.add(foodItem);
          }
        }
      }

      setState(() {
        _allFoodItems = mergedItems;
        // Filter popular items: here we assume an item is popular if its 'tags' array contains "Popular"
        _popularFoodItems = mergedItems.where((item) {
          if (item.containsKey('tags') && item['tags'] is List) {
            return (item['tags'] as List).contains("Popular");
          }
          return false;
        }).toList();
        // 'More' items: items that are not popular.
        _moreFoodItems = mergedItems.where((item) {
          if (item.containsKey('tags') && item['tags'] is List) {
            return !(item['tags'] as List).contains("Popular");
          }
          return true;
        }).toList();
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching food items: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: ColorEffect.neutralValue,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    _buildHeader(colorScheme),
                    SizedBox(height: 20.h),
                    _buildTitle(colorScheme),
                    SizedBox(height: 20.h),
                    _buildSpecialOffer(colorScheme),
                    SizedBox(height: 20.h),
                    _buildCategories(colorScheme),
                    SizedBox(height: 20.h),
                    
                  ],
                ),
              ),
            ),
            // While loading, show a progress indicator.
            _isLoading
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 50.h),
                        child:const  CircularProgressIndicator(),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: _buildFoodGrid(colorScheme),
                  ),
            SliverToBoxAdapter(
              child: SizedBox(height: 24.h),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.secondary),
        borderRadius: BorderRadius.circular(16.r),
      ),
    
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
         
          child: Row(
            children: [
              _buildHeaderButton(
                colorScheme: colorScheme,
                icon: Icons.fastfood_rounded,
                onPressed: () {},
              ),
              Expanded(child: _buildSearchField(colorScheme)),
              _buildHeaderButton(
                colorScheme: colorScheme,
                icon: Icons.person_4_outlined,
                showBadge: false,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserProfile(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2);
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required ColorScheme colorScheme,
    required VoidCallback onPressed,
    bool showBadge = false,
  }) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(icon, size: 24.w),
          onPressed: onPressed,
          color: colorScheme.secondary,
        ),
      ],
    );
  }

  Widget _buildSearchField(ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Container(
      height: 30.h,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: TextField(
        controller: _searchController,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.secondary,
          fontSize: 16.sp,
          
        ),
        decoration: InputDecoration(
          hintText: 'Search for food...',
          hintStyle: TextStyle(
            fontSize: 14.sp,
            fontFamily: "poppins",
            color: colorScheme.secondary,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20.w,
            color: colorScheme.secondary,
          ),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        ),
      ),
    );
  }

  Widget _buildTitle(ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delicious',
          style: theme.textTheme.displaySmall?.copyWith(
            color: colorScheme.primary,
          ),
        ),
        Text(
          'food for you',
          style: theme.textTheme.displaySmall?.copyWith(
            color: colorScheme.onSurface,
            fontSize: 30.sp,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideX();
  }

  Widget _buildSpecialOffer(ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Container(
      height: 160.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFDDA01E),
            Color(0xFFDDA00E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDDA15E).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          CustomPaint(
            painter: BubblePatternPainter(),
            size: Size.infinite,
          ),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Special Offer',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Up to 50% OFF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'On selected items',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).scale();
  }

  Widget _buildCategories(ColorScheme colorScheme) {
    return SizedBox(
      height: 40.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.secondary),
                color: isSelected
                    ? colorScheme.primary.withOpacity(0.3)
                    : colorScheme.surface,
                borderRadius: BorderRadius.circular(29.r),
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: isSelected
                        ? colorScheme.primary
                        : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    fontFamily: "poppins",
                  ),
                ),
              ),
            ).animate().fadeIn(
                delay: Duration(milliseconds: 100 * index)),
          );
        },
      ),
    );
  }

  // Popular section – horizontal list of popular food items.
  Widget _buildPopularSection(ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: const Color(0xFFFF7F50),
                  size: 24.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Popular Now',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF7F50),
              ),
              child: Row(
                children: [
                  Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.arrow_forward_rounded, size: 16.w),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 200.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _popularFoodItems.length,
            itemBuilder: (context, index) {
              final item = _popularFoodItems[index];
              return _buildPopularItem(item, colorScheme);
            },
          ),
        ),
      ],
    );
  }

  // Build a popular food item card (showing only image, name, and price).
  Widget _buildPopularItem(Map<String, dynamic> item, ColorScheme colorScheme) {
    return Container(
      width: 200.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(16.r)),
            child: CachedNetworkImage(
              imageUrl: item['image_url'],
              height: 100.h,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  color: Colors.white,
                  height: 100.h,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the food item's name.
                Text(
                  item['name'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                // Display the price.
                Text(
                  '\u{20B9}${item['price']}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  // Build the grid view for food items based on the selected category.
  Widget _buildFoodGrid(ColorScheme colorScheme) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = _currentItems[index];
          return _buildFoodItem(item, colorScheme);
        },
        childCount: _currentItems.length,
      ),
    );
  }

  // Build a food item card (grid item) showing only image, name, and price.
  Widget _buildFoodItem(Map<String, dynamic> item, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Details(
              name: item['name'],
              description: item['description'] ?? '',
              price: (item['price'] is num) ? item['price'].toDouble() : 0.0,
              imageUrl: item['image_url'], // Using image_url from Firestore.
              rating: (item['rating'] is num)
                  ? item['rating'].toDouble()
                  : 0.0,
              restaurant: item['restaurant_name'] ?? "Restaurant Name",
            ),
          ),
        );
      },
      child: Container(
        
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.secondary),
          color: colorScheme.surface.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: colorScheme.secondary.withOpacity(0.01),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food image
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16.r)),
              child: CachedNetworkImage(
                imageUrl: item['image_url'],
                height: 80.h,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: colorScheme.primary.withValues(alpha: 0.03),
                  highlightColor: colorScheme.surface,
                  child: Container(
                    color: colorScheme.surface,
                    height: 120.h,
                  ),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.image_not_supported,
                  color: colorScheme.primary,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food item name
                  Text(
                    item['name'],
                    style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.secondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    maxLines: 2,
                    item['description'] ,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:  EdgeInsets.only(
                left: 12.0.w,
                right: 12.0.w,
                
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween ,
                children: [
                  Text(
                      '\u{20B9}${item['price']}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.secondary,
                        fontFamily: "poppins",
                        fontSize: 19.spMax,
                      ),
                    ),
                  _buildAddButton(item, colorScheme)
                  
                ],
              ),
            ),
            
          ],
        ),
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildAddButton(Map<String, dynamic> item, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.secondary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final cartProvider =
                Provider.of<CartProvider>(context, listen: false);
            final cartItem = CartItemData(
              name: item['name'],
              details: item['description'] ?? '',
              price: (item['price'] is num)
                  ? item['price'].toDouble()
                  : 0.0,
              quantity: 1,
              imageUrl: item['image_url'],
            );
            cartProvider.addItem(cartItem);
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item['name']} added to cart'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.all(1.w),
            child: Icon(
              Icons.add_rounded,
              color: colorScheme.secondary,
              size: 22.w,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class BubblePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final random = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < 20; i++) {
      final x = (random + i * 100) % size.width;
      final y = (random + i * 200) % size.height;
      final radius = (random + i * 50) % 20 + 5;
      canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), radius.toDouble(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
