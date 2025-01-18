import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shimmer/shimmer.dart';

class CartItemData {
  final String imageUrl;
  final String name;
  final String details;
  final double price;

  CartItemData({
    required this.imageUrl,
    required this.name,
    required this.details,
    required this.price,
  });
}

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Razorpay _razorpay;

  final List<CartItemData> cartItems = [
    CartItemData(
      imageUrl:
      "https://www.healthline.com/hlcmsresource/images/AN_images/almonds-1296x728-feature.jpg",
      name: "A",
      details: "Approx 210gm",
      price: 349,
    ),
    CartItemData(
      imageUrl:
      "https://www.healthline.com/hlcmsresource/images/AN_images/benefits-of-kiwi-1296x728-feature.jpg",
      name: "B",
      details: "Approx 200gm",
      price: 890,
    ),
    CartItemData(
      imageUrl:
      "https://www.healthline.com/hlcmsresource/images/AN_images/benefits-of-broccoli-1296x728-feature.jpg",
      name: "C",
      details: "Approx. 120gm",
      price: 460,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  double get subtotal =>
      cartItems.fold(0, (sum, item) => sum + item.price); // Calculate subtotal

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_Oz8oer6jt57xY7', // Replace with your Razorpay Key ID
      'amount': (subtotal * 100).toInt(), // Convert to paise
      'name': 'Test Payment',
      'description': 'Payment for your cart items',
      'prefill': {
        'contact': '9999999999',
        'email': 'test@example.com',
      },
      'external': {
        'wallets': ['googlepay', 'paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Success: ${response.paymentId!}')),
    );
    Navigator.pop(context); // Go back to the cart page
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Error: ${response.message!}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName!}')),
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
          onPressed: () => Navigator.pop(context),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20.h),
            ...cartItems.map((item) => Column(
              children: [
                _buildCartItem(
                  item.imageUrl,
                  item.name,
                  item.details,
                  "₹${item.price.toStringAsFixed(2)}",
                ),
                SizedBox(height: 16.h),
              ],
            )),
            SizedBox(height: 24.h),
            const Divider(color: Colors.grey, thickness: 1),
            SizedBox(height: 16.h),
            _buildPriceRow("Subtotal", "₹${subtotal.toStringAsFixed(2)}"),
            SizedBox(height: 12.h),
            _buildPriceRow("Shipping", "₹50.00"), // Example shipping cost
            SizedBox(height: 12.h),
            _buildPriceRow(
              "Total",
              "₹${(subtotal + 50).toStringAsFixed(2)}",
              isTotal: true,
            ),
            SizedBox(height: 170.h),
            _PayButton("Click To Pay", _openCheckout),
            SizedBox(height: 24.h), // Extra padding for scrollability
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
              height: 60.w,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 60.w,
                    height: 20.w,
                    color: Colors.grey,
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

  Widget _PayButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.r),
        ),
        minimumSize: Size.fromHeight(50.h),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 17.sp),
      ),
    );
  }
}
