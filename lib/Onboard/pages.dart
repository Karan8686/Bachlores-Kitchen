import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomBar extends StatefulWidget {
  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  Widget _buildNavItem(int index, IconData icon, String label) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.secondary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.onSecondary
                  : theme.colorScheme.onPrimary.withOpacity(0.7),
              size: 24.sp,
            ),
            if (isSelected) ...[
              SizedBox(width: 8.w),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 14.sp,
                  color: theme.colorScheme.onSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    // Replace these with your actual page widgets
    final pages = [
      Center(child: Text('Home Page')),
      Center(child: Text('Search Page')),
      Center(child: Text('Cart Page')),
      Center(child: Text('Profile Page')),
    ];

    return pages[index];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _buildPage(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(0, Icons.home_rounded, "Home"),
                  _buildNavItem(1, Icons.search_rounded, "Search"),
                  _buildNavItem(2, Icons.shopping_cart_rounded, "Cart"),
                  _buildNavItem(3, Icons.person_rounded, "Profile"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}