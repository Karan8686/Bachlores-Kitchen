import 'package:batchloreskitchen/Pages/Home.dart';
import 'package:batchloreskitchen/Pages/cart.dart';
import 'package:batchloreskitchen/Pages/favourate.dart';
import 'package:batchloreskitchen/Pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AestheticBottomNavigation extends StatefulWidget {
  const AestheticBottomNavigation({Key? key}) : super(key: key);

  @override
  _AestheticBottomNavigationState createState() => _AestheticBottomNavigationState();
}

class _AestheticBottomNavigationState extends State<AestheticBottomNavigation> {
  int _currentIndex = 0;

  final List<NavigationItem> _navItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      page: const Home()
    ),
    NavigationItem(
      icon: Icons.favorite_border_rounded,
      activeIcon: Icons.favorite_rounded,
      label: 'Favorites',
      page: const FavoritesPage()
    ),
    NavigationItem(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag_rounded,
      label: 'Cart',
      page: const CartScreen()
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
      page: const SettingsPage()
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _navItems[_currentIndex].page ?? const Placeholder(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
          border: Border.all(
            color: colorScheme.primary,
            width: 1.1.w,
          ),
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _navItems.map((item) {
                final index = _navItems.indexOf(item);
                final isSelected = _currentIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? colorScheme.primary.withOpacity(0.1)
                        : Colors.transparent,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected 
                            ? colorScheme.primary 
                            : colorScheme.onSurface.withOpacity(0.6),
                          size: 24.sp,
                        ),
                        if (isSelected) ...[
                          SizedBox(width: 8.w),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget? page;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.page,
  });
}