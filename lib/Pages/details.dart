import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';

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
      backgroundColor: const Color(0xfff0f5f9),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Container
                Container(
                  padding: EdgeInsets.fromLTRB(16.w, 48.h, 16.w, 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                isFavorite = !isFavorite;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      Center(
                        child: Text(
                          "Savory Street Eats",
                          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Center(
                        child: Text(
                          "Mediterranean sunshine bowl",
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Center(
                        child: Image.asset(
                          "images/SaladQ.png", // Replace with your image path
                          width: 350.w,
                          height: 250.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 50.h),
                    ],
                  ),
                ),
                // Bottom Container (Overlapping with the image)
                Transform.translate(
                  offset: Offset(0, -50.h),
                  child: Container(
                    height: 500.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.r),
                        topRight: Radius.circular(30.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text("Ingredients:",
                                    style: TextStyle(
                                        fontSize: 18.sp, fontWeight: FontWeight.bold)),
                                SizedBox(width: 8.w),
                                Text("Manage",
                                    style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber),
                                SizedBox(width: 4.w),
                                Text("4.6", style: TextStyle(fontSize: 16.sp)),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8.w,
                          children: [
                            _buildIngredientChip("Rise"),
                            _buildIngredientChip("Carrot"),
                            _buildIngredientChip("Broccoli"),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "Harmonious blend of vibrant vegetables, fluffy couscous, and creamy hummus drizzled with a zesty lemon tahini dressing",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Nutritional value:",
                              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                            ),
                            DropdownButton<String>(
                              value: dropdownValue,
                              icon: const Icon(Icons.arrow_drop_down),
                              elevation: 16,
                              style: const TextStyle(color: Colors.black),
                              underline: Container(
                                height: 1,
                                color: Colors.grey,
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropdownValue = newValue!;
                                });
                              },
                              items: <String>['per 100g', 'per serving']
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
                        Text("198 kal", style: TextStyle(fontSize: 16.sp)),
                        SizedBox(height: 32.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(25.r),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: decrementItemCount,
                                    icon: const Icon(Icons.remove),
                                  ),
                                  Text("$itemCount",
                                      style: TextStyle(fontSize: 20.sp)),
                                  IconButton(
                                    onPressed: incrementItemCount,
                                    icon: const Icon(Icons.add),
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
                                backgroundColor: isButtonClicked
                                    ? Colors.pink
                                    : Colors.orangeAccent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 32.w, vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.r),
                                ),
                              ),
                              child: Text(
                                  "Add to card \$${(12.8 * itemCount).round()}"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: const Color(0xffe2e2e2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }
}