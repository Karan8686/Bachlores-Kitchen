import 'dart:async';
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
  bool _showSearchOverlay = false;
  Timer? _debounce;
  
  // Category titles
  final List<String> _categories = [
    'All',
    'Popular',
    'Recommended',
    'Near You',
    'Top Rated'
  ];

  // Lists to store food items
  List<Map<String, dynamic>> _allFoodItems = [];
  List<Map<String, dynamic>> _popularFoodItems = [];
  List<Map<String, dynamic>> _moreFoodItems = [];
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isLoading = true;

  late ThemeData _theme;
  late ColorScheme _colorScheme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache theme data
    _theme = Theme.of(context);
    _colorScheme = _theme.colorScheme;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _filteredItems = _allFoodItems;
    fetchFoodItems();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isEmpty) {
        setState(() {
          _filteredItems = _allFoodItems;
        });
        return;
      }

      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredItems = _allFoodItems.where((item) {
          final name = item['name'].toString().toLowerCase();
          final restaurant = item['restaurant_name'].toString().toLowerCase();
          return name.contains(query) || restaurant.contains(query);
        }).toList();
      });
    });
  }

  List<Map<String, dynamic>> get _currentItems {
    if (_searchController.text.isNotEmpty) {
      return _filteredItems;
    }
    
    switch (_selectedCategoryIndex) {
      case 0:
        return _allFoodItems;
      case 1:
        return _popularFoodItems;
      default:
        return _moreFoodItems;
    }
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showFloatingButton) {
      setState(() => _showFloatingButton = true);
    } else if (_scrollController.offset <= 200 && _showFloatingButton) {
      setState(() => _showFloatingButton = false);
    }
  }

  Future<void> fetchFoodItems() async {
    try {
      QuerySnapshot restaurantSnapshot =
          await FirebaseFirestore.instance.collection('restaurants').get();

      if (restaurantSnapshot.docs.isEmpty) {
        debugPrint('No restaurants found in Firestore.');
      } else {
        debugPrint('Fetched ${restaurantSnapshot.docs.length} restaurants.');
      }

      List<Map<String, dynamic>> mergedItems = [];
      for (var doc in restaurantSnapshot.docs) {
        Map<String, dynamic> restaurantData = doc.data() as Map<String, dynamic>;
        debugPrint('Fetched restaurant: $restaurantData'); // Debug print

        String restaurantName = restaurantData['restaurant_name'] ?? '';
        double restaurantRating = (restaurantData['rating'] is num)
            ? (restaurantData['rating'] as num).toDouble()
            : 0.0;
        String deliveryTime = '';
        if (restaurantData.containsKey('delivery_info') &&
            restaurantData['delivery_info'] is Map) {
          deliveryTime =
              restaurantData['delivery_info']['delivery_time'].toString();
        }
        if (restaurantData.containsKey('menu_items')) {
          List<dynamic> items = restaurantData['menu_items'];
          for (var item in items) {
            Map<String, dynamic> foodItem = Map<String, dynamic>.from(item);
            foodItem['restaurant_name'] = restaurantName;
            foodItem['restaurant_rating'] = restaurantRating;
            foodItem['delivery_time'] = deliveryTime;
            mergedItems.add(foodItem);
          }
        }
      }

      setState(() {
        _allFoodItems = mergedItems;
        _filteredItems = mergedItems;
        _popularFoodItems = mergedItems.where((item) {
          if (item.containsKey('tags') && item['tags'] is List) {
            return (item['tags'] as List).contains("Popular");
          }
          return false;
        }).toList();
        _moreFoodItems = mergedItems.where((item) {
          if (item.containsKey('tags') && item['tags'] is List) {
            return !(item['tags'] as List).contains("Popular");
          }
          return true;
        }).toList();
        _isLoading = false;
      });
      debugPrint('Fetched food items: $_allFoodItems'); // Debug print
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      debugPrint("Error fetching food items: $error"); // Debug print
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorScheme.background,
      body: Stack(
        children: [
          SafeArea(
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
                        _buildHeader(_colorScheme),
                        SizedBox(height: 20.h),
                        _buildTitle(_theme),
                        SizedBox(height: 20.h),
                        _buildSpecialOffer(_colorScheme),
                        SizedBox(height: 20.h),
                        _buildCategories(_colorScheme),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
                _isLoading
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 50.h),
                            child: const CircularProgressIndicator(),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        sliver: _buildFoodGrid(_colorScheme),
                      ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 24.h),
                ),
              ],
            ),
          ),
          if (_showSearchOverlay)
            SearchOverlay(
              searchResults: _filteredItems,
              searchController: _searchController,
              onClose: () {
                setState(() {
                  _showSearchOverlay = false;
                  _searchController.clear();
                });
              },
              colorScheme: _colorScheme,
            ),
        ],
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
        child: Row(
          children: [
            _buildHeaderButton(
              colorScheme: colorScheme,
              icon: Icons.fastfood_rounded,
              onPressed: () {},
            ),
            _buildSearchField(colorScheme),
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
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2);
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required ColorScheme colorScheme,
    required VoidCallback onPressed,
    bool showBadge = false,
  }) {
    return IconButton(
      icon: Icon(icon, size: 24.w),
      onPressed: onPressed,
      color: colorScheme.secondary,
    );
  }

  Widget _buildSearchField(ColorScheme colorScheme) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showSearchOverlay = true;
          });
        },
        child: Container(
          height: 30.h,
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Icon(
                  Icons.search_rounded,
                  size: 20.w,
                  color: colorScheme.secondary,
                ),
              ),
              Text(
                'Search for food...',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: "poppins",
                  color: colorScheme.secondary.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delicious',
          style: theme.textTheme.displaySmall?.copyWith(
            color: _colorScheme.primary,
          ),
        ),
        Text(
          'food for you',
          style: theme.textTheme.displaySmall?.copyWith(
            color: _colorScheme.onSurface,
            fontSize: 30.sp,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideX();
  }

  Widget _buildSpecialOffer(ColorScheme colorScheme) {
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Special Offer',
                    style: _theme.textTheme.bodyMedium?.copyWith(
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
                    color: isSelected ? colorScheme.primary : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    fontFamily: "poppins",
                  ),
                ),
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)),
          );
        },
      ),
    );
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

  // Build a food item card (grid item) showing image, name, description, price and an add button.
  Widget _buildFoodItem(Map<String, dynamic> item, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () {
        // Navigate to Details page with extra fields.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Details(
              itemId: item['item_id'] ?? '',
              name: item['name'],
              description: item['description'] ?? '',
              price: (item['price'] is num) ? item['price'].toDouble() : 0.0,
              imageUrl: item['image_url'],
              rating: (item['restaurant_rating'] is num)
                  ? item['restaurant_rating'].toDouble()
                  : 0.0,
              restaurant: item['restaurant_name'] ?? "Restaurant Name",
              category: item['category'] ?? '',
              isVegetarian: item['is_vegetarian'] ?? false,
              deliveryTime: item['delivery_time'] ?? '',
              nutritionalInfo: item['nutritional_info'] ?? {},
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: CachedNetworkImage(
                imageUrl: item['image_url'],
                height: 80.h,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: colorScheme.primary.withOpacity(0.03),
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
                    style: _theme.textTheme.bodyLarge
                        ?.copyWith(color: colorScheme.secondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    item['description'],
                    style: _theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 12.w, right: 12.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\u{20B9}${item['price']}',
                    style: _theme.textTheme.titleLarge?.copyWith(
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
              price: (item['price'] is num) ? item['price'].toDouble() : 0.0,
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
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

//  SearchOverlay widget class
class SearchOverlay extends StatefulWidget {
  final List<Map<String, dynamic>> searchResults;
  final TextEditingController searchController;
  final VoidCallback onClose;
  final ColorScheme colorScheme;

  const SearchOverlay({
    Key? key,
    required this.searchResults,
    required this.searchController,
    required this.onClose,
    required this.colorScheme,
  }) : super(key: key);

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  RangeValues _priceRange = const RangeValues(0, 2000);
  double _minRating = 0.0;
  bool _isVegOnly = false;
  String _sortBy = 'relevance';
  bool _showFilters = false;
  List<String> _selectedCategories = [];
  List<String> _dietaryPreferences = [];

  final List<String> _categories = [
    'Pizza', 'Burger', 'Salad', 'Drinks', 'Desserts', 'Indian', 'Chinese'
  ];

  final List<String> _dietary = [
    'Gluten Free', 'Low Carb', 'High Protein', 'Keto Friendly'
  ];

  List<Map<String, dynamic>> get filteredResults {
    return widget.searchResults.where((item) {
      final price = (item['price'] as num).toDouble();
      final rating = (item['restaurant_rating'] as num?)?.toDouble() ?? 0.0;
      final isVeg = item['is_vegetarian'] ?? false;
      
      bool passesFilters = price >= _priceRange.start && 
                          price <= _priceRange.end &&
                          rating >= _minRating;

      if (_isVegOnly && !isVeg) return false;
      
      if (_selectedCategories.isNotEmpty) {
        final category = item['category']?.toString().toLowerCase() ?? '';
        if (!_selectedCategories.any((c) => category.contains(c.toLowerCase()))) {
          return false;
        }
      }

      if (_dietaryPreferences.isNotEmpty) {
        final tags = (item['tags'] as List?)?.cast<String>() ?? [];
        if (!_dietaryPreferences.any((pref) => 
          tags.any((tag) => tag.toLowerCase().contains(pref.toLowerCase())))) {
          return false;
        }
      }

      return passesFilters;
    }).toList()..sort((a, b) {
      switch (_sortBy) {
        case 'price_low':
          return (a['price'] as num).compareTo(b['price'] as num);
        case 'price_high':
          return (b['price'] as num).compareTo(a['price'] as num);
        case 'rating':
          final ratingA = (a['restaurant_rating'] as num?)?.toDouble() ?? 0.0;
          final ratingB = (b['restaurant_rating'] as num?)?.toDouble() ?? 0.0;
          return ratingB.compareTo(ratingA);
        default:
          return 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.colorScheme.surface,
      child: Column(
        children: [
          _buildSearchHeader(),
          if (_showFilters) _buildFilters(),
          Expanded(
            child: widget.searchController.text.isEmpty
                ? _buildInitialContent()
                : _buildSearchResults().animate().shimmer(
                    duration: 800.ms,
                    color: widget.colorScheme.secondary.withOpacity(0.1),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: widget.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: widget.colorScheme.onSurface.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onClose,
                ),
                Expanded(
                  child: Container(
                    height: 45.h,
                    decoration: BoxDecoration(
                      color: widget.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: widget.colorScheme.secondary.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: widget.searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search for food or restaurants...',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: widget.colorScheme.secondary.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: widget.colorScheme.secondary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showFilters ? Icons.close : Icons.tune,
                            color: widget.colorScheme.secondary,
                          ),
                          onPressed: () => setState(() => _showFilters = !_showFilters),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (widget.searchController.text.isNotEmpty && !_showFilters)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Row(
                  children: [
                    _buildChip(
                      label: 'Sort: ${_getSortByText()}',
                      onTap: _showSortOptions,
                      icon: Icons.sort,
                    ),
                    if (_isVegOnly)
                      _buildChip(
                        label: 'Veg Only',
                        onTap: () => setState(() => _isVegOnly = false),
                        icon: Icons.eco,
                      ),
                    if (_minRating > 0)
                      _buildChip(
                        label: '${_minRating.toInt()}+ Rating',
                        onTap: () => setState(() => _minRating = 0),
                        icon: Icons.star,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: widget.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: widget.colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Range',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: widget.colorScheme.secondary,
            ),
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 2000,
            divisions: 20,
            labels: RangeLabels(
              '₹${_priceRange.start.round()}',
              '₹${_priceRange.end.round()}',
            ),
            onChanged: (values) => setState(() => _priceRange = values),
            activeColor: widget.colorScheme.primary,
          ),
          SizedBox(height: 16.h),
          
          Text(
            'Minimum Rating',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: widget.colorScheme.secondary,
            ),
          ),
          Slider(
            value: _minRating,
            min: 0,
            max: 5,
            divisions: 5,
            label: '${_minRating.toInt()}+',
            onChanged: (value) => setState(() => _minRating = value),
            activeColor: widget.colorScheme.primary,
          ),
          
          Row(
            children: [
              Switch(
                value: _isVegOnly,
                onChanged: (value) => setState(() => _isVegOnly = value),
                activeColor: widget.colorScheme.primary,
              ),
              Text(
                'Vegetarian Only',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: widget.colorScheme.secondary,
                ),
              ),
            ],
          ),

          Text(
            'Categories',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: widget.colorScheme.secondary,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            children: _categories.map((category) {
              final isSelected = _selectedCategories.contains(category);
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCategories.add(category);
                    } else {
                      _selectedCategories.remove(category);
                    }
                  });
                },
                backgroundColor: widget.colorScheme.surface,
                selectedColor: widget.colorScheme.primary.withOpacity(0.2),
                checkmarkColor: widget.colorScheme.primary,
                side: BorderSide(
                  color: isSelected 
                    ? widget.colorScheme.primary 
                    : widget.colorScheme.secondary.withOpacity(0.3),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 16.h),
          Text(
            'Dietary Preferences',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: widget.colorScheme.secondary,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            children: _dietary.map((pref) {
              final isSelected = _dietaryPreferences.contains(pref);
              return FilterChip(
                label: Text(pref),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _dietaryPreferences.add(pref);
                    } else {
                      _dietaryPreferences.remove(pref);
                    }
                  });
                },
                backgroundColor: widget.colorScheme.surface,
                selectedColor: widget.colorScheme.primary.withOpacity(0.2),
                checkmarkColor: widget.colorScheme.primary,
                side: BorderSide(
                  color: isSelected 
                    ? widget.colorScheme.primary 
                    : widget.colorScheme.secondary.withOpacity(0.3),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: ActionChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: widget.colorScheme.secondary,
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: widget.colorScheme.secondary,
              ),
            ),
          ],
        ),
        onPressed: onTap,
        backgroundColor: widget.colorScheme.surface,
        side: BorderSide(
          color: widget.colorScheme.secondary.withOpacity(0.3),
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort By',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: widget.colorScheme.secondary,
              ),
            ),
            SizedBox(height: 16.h),
            _buildSortOption('Relevance', 'relevance'),
            _buildSortOption('Price: Low to High', 'price_low'),
            _buildSortOption('Price: High to Low', 'price_high'),
            _buildSortOption('Rating', 'rating'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: _sortBy == value ? Icon(
        Icons.check,
        color: widget.colorScheme.primary,
      ) : null,
      onTap: () {
        setState(() => _sortBy = value);
        Navigator.pop(context);
      },
    );
  }

  String _getSortByText() {
    switch (_sortBy) {
      case 'price_low':
        return 'Price ↑';
      case 'price_high':
        return 'Price ↓';
      case 'rating':
        return 'Rating';
      default:
        return 'Relevance';
    }
  }

  Widget _buildInitialContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64.w,
            color: widget.colorScheme.secondary.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'Search for your favorite food\nor restaurant',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.colorScheme.secondary.withOpacity(0.5),
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = filteredResults;
    
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64.w,
              color: widget.colorScheme.secondary.withOpacity(0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              'No results found',
              style: TextStyle(
                color: widget.colorScheme.secondary.withOpacity(0.5),
                fontSize: 16.sp,
              ),
            ),
            if (_showFilters) Text(
              'Try adjusting your filters',
              style: TextStyle(
                color: widget.colorScheme.secondary.withOpacity(0.5),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: results.length,
      itemBuilder: (context, index) => _buildSearchResultItem(context, results[index]),    );
  }

  Widget _buildSearchResultItem(BuildContext context, Map<String, dynamic> item) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: widget.colorScheme.secondary.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Details(
                itemId: item['item_id'] ?? '',
                name: item['name'],
                description: item['description'] ?? '',
                price: (item['price'] is num) ? item['price'].toDouble() : 0.0,
                imageUrl: item['image_url'],
                rating: (item['restaurant_rating'] is num)
                    ? item['restaurant_rating'].toDouble()
                    : 0.0,
                restaurant: item['restaurant_name'] ?? "Restaurant Name",
                category: item['category'] ?? '',
                isVegetarian: item['is_vegetarian'] ?? false,
                deliveryTime: item['delivery_time'] ?? '',
                nutritionalInfo: item['nutritional_info'] ?? {},
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              Hero(
                tag: 'search_${item['item_id']}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: item['image_url'],
                    height: 80.h,
                    width: 80.w,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: widget.colorScheme.secondary.withOpacity(0.1),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.image_not_supported,
                      color: widget.colorScheme.secondary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (item['is_vegetarian'] ?? false)
                          Padding(
                            padding: EdgeInsets.only(right: 4.w),
                            child: Icon(
                              Icons.eco,
                              size: 16.sp,
                              color: Colors.green,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            item['name'],
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: widget.colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item['restaurant_name'] ?? '',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: widget.colorScheme.secondary.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          '₹${item['price']}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: widget.colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Icon(
                          Icons.star,
                          size: 16.sp,
                          color: Colors.amber,
                        ),
                        Text(
                          ' ${(item['restaurant_rating'] as num).toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: widget.colorScheme.secondary,
                          ),
                        ),
                        if (item['delivery_time']?.isNotEmpty ?? false) ...[
                          SizedBox(width: 12.w),
                          Icon(
                            Icons.access_time,
                            size: 16.sp,
                            color: widget.colorScheme.secondary.withOpacity(0.7),
                          ),
                          Text(
                            ' ${item['delivery_time']}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: widget.colorScheme.secondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn().slideX(),
        ),
      ),
    );
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
      canvas.drawCircle(
          Offset(x.toDouble(), y.toDouble()), radius.toDouble(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



