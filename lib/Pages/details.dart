import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:batchloreskitchen/Pages/theme.dart'; // Import your theme file

class Details extends StatefulWidget {
  const Details({Key? key}) : super(key: key);

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int itemCount = 1;
  bool isButtonClicked = false;
  bool isFavorite = false;
  String dropdownValue = 'per 100g';
  final double _panelHeightOpen = 575.0;
  final double _panelHeightClosed = 480.0;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Fetch the current theme
    final colorScheme = theme.colorScheme; // Access the color scheme

    return Scaffold(
      backgroundColor: colorScheme.background, // Use theme's background color
      body: SlidingUpPanel(
        maxHeight: _panelHeightOpen,
        minHeight: _panelHeightClosed,
        parallaxEnabled: true,
        parallaxOffset: .5,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        body: Container(
          color: colorScheme.surface, // Use theme's surface color
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 16.h),
              _buildHeader(colorScheme),
              Center(
                child: Image.asset(
                  "images/SaladQ.png",
                  width: 350.w,
                  height: 230.h,
                  fit: BoxFit.contain,
                ).animate().fadeIn(duration: 600.ms).scale(),
              ),
            ],
          ),
        ),
        panel: _buildPanel(colorScheme),
      ),
    );
  }

  Widget _buildPanel(ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface, // Use theme's surface color
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Container(
                width: 40.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mediterranean sunshine bowl",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary, // Use theme's primary color
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(),
                SizedBox(height: 8.h),
                Text(
                  "Savory Street Eats",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: 24.h),
                _buildInfoRow(colorScheme),
                SizedBox(height: 16.h),
                _buildIngredients(colorScheme),
                SizedBox(height: 24.h),
                _buildDescription(colorScheme),
                SizedBox(height: 24.h),
                _buildNutritionalInfo(colorScheme),
                SizedBox(height: 32.h),
                _buildBottomBar(colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.restaurant_menu,
              color: colorScheme.primary, // Use theme's primary color
              size: 24.w,
            ),
            SizedBox(width: 8.w),
            Text(
              "Ingredients",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
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
              "4.6",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildIngredients(ColorScheme colorScheme) {
    return Wrap(
      spacing: 8.w,
      children: [
        _buildIngredientChip("Rice", colorScheme),
        _buildIngredientChip("Carrot", colorScheme),
        _buildIngredientChip("Broccoli", colorScheme),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildDescription(ColorScheme colorScheme) {
    return Text(
      "Harmonious blend of vibrant vegetables, fluffy couscous, and creamy hummus drizzled with a zesty lemon tahini dressing",
      style: TextStyle(
        fontSize: 14.sp,
        color: colorScheme.onSurface.withOpacity(0.6),
        height: 1.5,
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
            color: colorScheme.primary,
          ),
          IconButton(
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
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2);
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

  Widget _buildNutritionalInfo(ColorScheme colorScheme) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Nutritional value",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              DropdownButton<String>(
                value: dropdownValue,
                icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 14.sp,
                ),
                underline: Container(
                  height: 1,
                  color: colorScheme.primary,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: ['per 100g', 'per serving']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            "198 kal",
            style: TextStyle(
              fontSize: 16.sp,
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms);
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
          onPressed: () {
            setState(() {
              isButtonClicked = !isButtonClicked;
            });
            Future.delayed(const Duration(milliseconds: 200), () {
              setState(() {
                isButtonClicked = !isButtonClicked;
              });
            });
          },
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
