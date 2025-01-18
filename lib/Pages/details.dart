import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SlidingUpPanel(
        maxHeight: _panelHeightOpen,
        minHeight: _panelHeightClosed,
        parallaxEnabled: true,
        parallaxOffset: .5,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        body: Stack(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 16.h),
                  _buildHeader(),
                  Center(
                    child: Image.asset(
                      "images/SaladQ.png",
                      width: 350.w,
                      height: 230.h,
                      fit: BoxFit.contain,
                    ),
                  ).animate().fadeIn(duration: 600.ms).scale(),
                ],
              ),
            ),
          ],
        ),
        panel: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                      color: Colors.grey[300],
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
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [
                              Color(0xFFFF7F50),
                              Color(0xFFFF6B3D),
                            ],
                          ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideX(),
                    SizedBox(height: 8.h),
                    Text(
                      "Savory Street Eats",
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              color: const Color(0xFFFF7F50),
                              size: 24.w,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "Ingredients",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: const Color(0xFFFF7F50),
                              size: 24.w,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "4.6",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms),
                    SizedBox(height: 16.h),
                    Wrap(
                      spacing: 8.w,
                      children: [
                        _buildIngredientChip("Rice"),
                        _buildIngredientChip("Carrot"),
                        _buildIngredientChip("Broccoli"),
                      ],
                    ).animate().fadeIn(delay: 600.ms),
                    SizedBox(height: 24.h),
                    Text(
                      "Harmonious blend of vibrant vegetables, fluffy couscous, and creamy hummus drizzled with a zesty lemon tahini dressing",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    _buildNutritionalInfo(),
                    SizedBox(height: 32.h),
                    _buildBottomBar(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
            color: const Color(0xFFFF7F50),
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: const Color(0xFFFF7F50),
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

  Widget _buildIngredientChip(String label) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: const Color(0xFFFF7F50),
          fontSize: 14.sp,
        ),
      ),
      backgroundColor: const Color(0xFFFF7F50).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }

  Widget _buildNutritionalInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
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
                ),
              ),
              DropdownButton<String>(
                value: dropdownValue,
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFF7F50)),
                style: TextStyle(
                  color: const Color(0xFFFF7F50),
                  fontSize: 14.sp,
                ),
                underline: Container(
                  height: 1,
                  color: const Color(0xFFFF7F50),
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
              color: const Color(0xFFFF7F50),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildBottomBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFFF7F50)),
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: decrementItemCount,
                icon: const Icon(Icons.remove, color: Color(0xFFFF7F50)),
              ),
              Text(
                "$itemCount",
                style: TextStyle(
                  fontSize: 20.sp,
                  color: const Color(0xFFFF7F50),
                ),
              ),
              IconButton(
                onPressed: incrementItemCount,
                icon: const Icon(Icons.add, color: Color(0xFFFF7F50)),
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
            backgroundColor: const Color(0xFFFF7F50),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.r),
            ),
            elevation: 2,
          ),
          child: Text(
            "Add to cart \u{20B9}${(12.8 * itemCount).round()}",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 1000.ms);
  }
}