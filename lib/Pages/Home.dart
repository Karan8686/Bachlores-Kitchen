import 'package:batchloreskitchen/Pages/details.dart';
import 'package:batchloreskitchen/Pages/profile.dart';
import 'package:batchloreskitchen/Pages/theme.dart';
import 'package:batchloreskitchen/prrovider/Cart/Cart_item.dart';
import 'package:batchloreskitchen/prrovider/Cart/Cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui';
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

  final List<String> _categories = [
    'All', 'Popular', 'Recommended', 'Near You', 'Top Rated'
  ];

  final List<Map<String, dynamic>> _foodItems = [
    {
      'name': 'Veggie Mediterranean Bowl',
      'description': 'Fresh vegetables with quinoa and hummus',
      'price': 280,
      'rating': 4.8,
      'time': '20-25 min',
      'calories': '420 kcal',
      'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
      'isPopular': true,
    },
    {
      'name': 'Crispy Chicken Burger',
      'description': 'Premium chicken with special sauce',
      'price': 459,
      'rating': 4.9,
      'time': '25-30 min',
      'calories': '580 kcal',
      'image': 'https://images.unsplash.com/photo-1562967914-608f82629710',
      'isPopular': true,
    },
    {
      'name': 'Fresh Garden Salad',
      'description': 'Seasonal vegetables with vinaigrette',
      'price': 660,
      'rating': 4.5,
      'time': '15-20 min',
      'calories': '320 kcal',
      'image': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd',
      'isPopular': false,
    },
    {
      'name': 'Grilled Salmon Bowl',
      'description': 'Norwegian salmon with rice and vegetables',
      'price': 340,
      'rating': 4.7,
      'time': '25-30 min',
      'calories': '460 kcal',
      'image': 'https://images.unsplash.com/photo-1467003909585-2f8a72700288',
      'isPopular': true,
    },
  ];

  final List<Map<String, dynamic>> _popularItems = [
    {
      'name': 'Spicy Thai Noodles',
      'description': 'Authentic Thai street food style',
      'price': 299,
      'rating': 4.9,
      'time': '15-20 min',
      'calories': '380 kcal',
      'image': 'https://images.unsplash.com/photo-1617093727343-374698b1b08d',
      'isPopular': true,
    },
    {
      'name': 'Mexican Bowl',
      'description': 'Fresh avocado and beans',
      'price': 349,
      'rating': 4.7,
      'time': '20-25 min',
      'calories': '450 kcal',
      'image': 'https://images.unsplash.com/photo-1543352634-a1c51d9f1fa7',
      'isPopular': true,
    },
    // Add more popular items...
  ];

  final List<Map<String, dynamic>> _recommendedItems = [
    {
      'name': 'Poke Bowl',
      'description': 'Fresh tuna with rice and vegetables',
      'price': 399,
      'rating': 4.6,
      'time': '20-25 min',
      'calories': '320 kcal',
      'image': 'https://images.unsplash.com/photo-1546069901-d5bfd2cbfb1f',
      'isPopular': false,
    },
    {
      'name': 'Buddha Bowl',
      'description': 'Nutritious vegetarian delight',
      'price': 289,
      'rating': 4.8,
      'time': '15-20 min',
      'calories': '280 kcal',
      'image': 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe',
      'isPopular': false,
    },
    // Add more recommended items...
  ];

  final List<Map<String, dynamic>> _nearbyItems = [
    {
      'name': 'Fresh Pasta',
      'description': 'Handmade Italian pasta',
      'price': 329,
      'rating': 4.5,
      'time': '25-30 min',
      'calories': '520 kcal',
      'image': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141',
      'isPopular': false,
    },
    {
      'name': 'Sushi Platter',
      'description': 'Assorted fresh sushi',
      'price': 599,
      'rating': 4.9,
      'time': '20-25 min',
      'calories': '400 kcal',
      'image': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c',
      'isPopular': false,
    },
    // Add more nearby items...
  ];

  final List<Map<String, dynamic>> _topRatedItems = [
    {
      'name': 'Wagyu Burger',
      'description': 'Premium beef burger',
      'price': 649,
      'rating': 5.0,
      'time': '25-30 min',
      'calories': '680 kcal',
      'image': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd',
      'isPopular': true,
    },
    {
      'name': 'Truffle Pizza',
      'description': 'Authentic Italian with truffle',
      'price': 799,
      'rating': 4.9,
      'time': '30-35 min',
      'calories': '720 kcal',
      'image': 'https://images.unsplash.com/photo-1604382355076-af4b0eb60143',
      'isPopular': true,
    },
    // Add more top rated items...
  ];

  List<Map<String, dynamic>> get _currentItems {
    switch (_selectedCategoryIndex) {
      case 0: // All
        return _foodItems;
      case 1: // Popular
        return _popularItems;
      case 2: // Recommended
        return _recommendedItems;
      case 3: // Near You
        return _nearbyItems;
      case 4: // Top Rated
        return _topRatedItems;
      default:
        return _foodItems;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showFloatingButton) {
      setState(() => _showFloatingButton = true);
    } else if (_scrollController.offset <= 200 && _showFloatingButton) {
      setState(() => _showFloatingButton = false);
    }
  }


  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Fetch the current theme
    final colorScheme = theme.colorScheme; // Access the color scheme
    return Scaffold(
      backgroundColor: ColorEffect.neutralValue,
      
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    _buildHeader(colorScheme),
                    SizedBox(height: 24.h),
                    _buildTitle(colorScheme),
                    SizedBox(height: 24.h),
                    _buildSpecialOffer(colorScheme),
                    SizedBox(height: 24.h),
                    _buildCategories(colorScheme),
                    SizedBox(height: 24.h),


                  ],
                ),
              ),
            ),
            SliverPadding(
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
      height: 56.h,
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.secondary
        ),
        color:Colors.white30 ,

        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.white10,
            child: Row(
              children: [
                _buildHeaderButton(
                  colorScheme: colorScheme,
                  icon: Icons.fastfood_rounded,
                  onPressed: () {
                    
                  },
                ),
                Expanded(
                  child: _buildSearchField(colorScheme),
                ),
                _buildHeaderButton(
                  colorScheme: colorScheme,
                  icon: Icons.person_4_outlined,
                  showBadge: false,
                  onPressed: () {
                    Navigator.push(context,MaterialPageRoute(builder: (context) => UserProfile(),) );
                  },
                ),
              ],
            ),
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
          color: colorScheme.secondary ,
        ),


      ],
    );
  }

  Widget _buildSearchField(ColorScheme colorScheme) {
    final theme = Theme.of(context); // Fetch the current theme

    return Container(
      height: 40.h,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(

        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: TextField(
        controller: _searchController,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.secondary
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
          contentPadding: EdgeInsets.symmetric(
            vertical: 8.h,
            horizontal: 12.w,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(ColorScheme colorScheme) {
    final theme = Theme.of(context); // Fetch the current theme

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delicious',
          style: theme.textTheme.displaySmall?.copyWith(
            color: colorScheme.primary,// Use theme's primary color
          ),
        ),
        Text(
          'food for you',
          
          style: theme.textTheme.displaySmall?.copyWith(
            color: colorScheme.onSurface,
            fontSize: 30.sp
          )
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideX();
  }

  Widget _buildSpecialOffer(ColorScheme colorScheme) {
    final theme = Theme.of(context); // Fetch the current theme
    return Container(
      height: 163.h,
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
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Special Offer',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white
                    )
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
      height: 44.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.secondary),
                color: isSelected ? colorScheme.primary.withOpacity(0.3): Colors.white,

                borderRadius: BorderRadius.circular(29.r),


              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: isSelected ? colorScheme.primary : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    fontFamily: "poppins"
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
        },
      ),
    );
  }

  Widget _buildPopularSection(ColorScheme colorScheme) {
    final theme = Theme.of(context); // Fetch the current theme
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            itemCount: _foodItems.where((item) => item['isPopular']).length,
            itemBuilder: (context, index) {
              final popularItems = _foodItems.where((item) => item['isPopular']).toList();
              final item = popularItems[index];
              return _buildPopularItem(item,colorScheme);
            },
          ),
        ),],
    );
  }

  Widget _buildPopularItem(Map<String, dynamic> item,ColorScheme colorScheme) {
    
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: CachedNetworkImage(
                  imageUrl: item['image'],
                  height: 90.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      color: Colors.white,
                      height: 120.h,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: const Color(0xFFFF7F50),
                        size: 16.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        item['rating'].toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  item['description'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 14.w,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      item['time'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Icon(
                      Icons.local_fire_department_outlined,
                      size: 14.w,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      item['calories'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

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

  Widget _buildFoodItem(Map<String, dynamic> item,ColorScheme colorScheme) {
    final theme = Theme.of(context); // Fetch the current theme
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Details(
              name: item['name'],
              description: item['description'],
              price: item['price'].toDouble(), // Ensure price is a double
              imageUrl: item['image'],
              rating: item['rating'].toDouble(), // Ensure rating is a double
              restaurant: "Karan's Dhaba", // Example restaurant name
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.secondary),
          color: colorScheme.background.withOpacity(0.05),
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                  child: CachedNetworkImage(
                    imageUrl: item['image'],
                    height: 80.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: colorScheme.primary.withValues(alpha:0.03),
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
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.deepOrangeAccent,
                          size: 16.w,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          item['rating'].toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.secondary
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item['description'],
                    style:theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\u{20B9}${item['price']}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.secondary,
                          fontFamily: "poppins",
                          fontSize: 19.spMax
                        )
                      ),
                      _buildAddButton(colorScheme),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildAddButton(ColorScheme colorScheme) {
    final theme = Theme.of(context); // Fetch the current theme
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.secondary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            
            // Add item to cart
           
          },
          borderRadius: BorderRadius.circular(8.r),
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Icon(
              Icons.add_rounded,
              color: colorScheme.secondary,
              size: 20.w,
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