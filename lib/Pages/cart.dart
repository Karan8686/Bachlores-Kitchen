import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'Pay.dart'; // Import your payment page

class CartItemData {
  final String imageUrl;
  final String name;
  final String details;
  final String price;

  CartItemData({
    required this.imageUrl,
    required this.name,
    required this.details,
    required this.price,
  });
}

class CartScreen extends StatelessWidget {

  CartScreen({Key? key}) : super(key: key);


  final List<CartItemData> cartItems = [
    CartItemData(
      imageUrl:
      "https://www.healthline.com/hlcmsresource/images/AN_images/almonds-1296x728-feature.jpg",
      name: "Almond",
      details: "16oz | \$8.99/lb",
      price: "\$8.99",
    ),
    CartItemData(
      imageUrl:
      "https://www.healthline.com/hlcmsresource/images/AN_images/benefits-of-kiwi-1296x728-feature.jpg",
      name: "Kiwifruit",
      details: "Approx 6oz",
      price: "\$8.99",
    ),
    CartItemData(
      imageUrl:
      "https://www.healthline.com/hlcmsresource/images/AN_images/benefits-of-broccoli-1296x728-feature.jpg",
      name: "Broccoli",
      details: "Approx. 0.6lb",
      price: "\$8.99",
    ),
  ];

  void _handlePay(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => RazorpayExample()), // Your payment page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () {

          },
        ),
        title: const Text("Cart", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {},
          ),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20.h),
            ...cartItems.map((item) => Column(
              children: [
                _buildCartItem(
                    item.imageUrl, item.name, item.details, item.price),
                SizedBox(height: 16.h),
              ],
            )),
            SizedBox(height: 24.h),
            Row(
              children: [
                const Icon(Icons.local_offer_outlined, color: Colors.grey),
                SizedBox(width: 8.w),
                const Text("Promo", style: TextStyle(color: Colors.grey)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  child: const Text("Apply"),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            const Divider(color: Colors.grey, thickness: 1),
            SizedBox(height: 16.h),
            _buildPriceRow("Subtotal", "\$26.97"), // Example values
            SizedBox(height: 12.h),
            _buildPriceRow("Discount", "0%"),
            SizedBox(height: 12.h),
            _buildPriceRow("Shipping", "\$5.00"),
            SizedBox(height: 24.h),
            const Divider(color: Colors.grey, thickness: 1),
            SizedBox(height: 16.h),
            _buildPriceRow("Total", "\$31.97", isTotal: true),
            SizedBox(height: 110.h), // Added spacing before button
            _PayButton("Click To Pay", () => _handlePay(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(
      String imageUrl, String name, String details, String price) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.network(
              imageUrl,
              width: 60.w,
              height: 60.h,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, object, stackTrace) =>
              const Icon(Icons.error),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                Text(details,
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
              ],
            ),
          ),
          Text(price,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text("1",
                style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                fontSize: 16.sp)),
        Text(value,
            style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                fontSize: 16.sp)),
      ],
    );
  }
}

Widget _PayButton(String text, VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepOrangeAccent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
    ),
    child: Text(text),
  );
}
