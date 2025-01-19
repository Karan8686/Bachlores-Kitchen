import 'package:flutter/material.dart';
import 'package:batchloreskitchen/Pages/cart.dart';
import 'package:batchloreskitchen/Pages/Home.dart';
import 'package:batchloreskitchen/Pages/wallet.dart';
import 'package:batchloreskitchen/Pages/order.dart';
import 'package:batchloreskitchen/Pages/profile.dart';
import 'package:animations/animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> with SingleTickerProviderStateMixin {
  int currentTabIndex = 0;
  late List<Widget> pages;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    pages = [
      Home(),
      Order(),
      CartScreen(),
      Profile(),
    ];

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBody: true,
      floatingActionButton: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0,
            onPressed: () {
              setState(() {
                currentTabIndex = 2;
                _animationController.forward().then((_) {
                  _animationController.reverse();
                });
              });
            },
            child: Icon(
              Icons.shopping_bag_outlined,
              color: colorScheme.onPrimary,
              size: 28,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomAppBar(
            height: 71.h,
            notchMargin: 12,
            shape: AutomaticNotchedShape(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
            ),
            color: colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem(0, Icons.home_outlined, 'Home', theme),
                _buildTabItem(1, Icons.favorite_border, 'Favorites', theme),
                SizedBox(width: 40.w),
                _buildTabItem(3, Icons.monetization_on_outlined, 'Money', theme),
                _buildTabItem(4, Icons.settings_outlined, 'Notifications', theme),
              ],
            ),
          ),
        ),
      ),
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: pages[currentTabIndex],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label, ThemeData theme) {
    final isSelected = currentTabIndex == index;
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: isSelected ? colorScheme.primary.withOpacity(0.1) : Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            setState(() {
              currentTabIndex = index;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                  size: 25,
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: isSelected ? 4 : 0,
                  width: isSelected ? 4 : 0,
                  margin: EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
