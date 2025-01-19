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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Cart", style: textTheme.headline6?.copyWith(color: colorScheme.onSurface)),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: colorScheme.onSurface),
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
                  colorScheme,
                  textTheme,
                ),
                SizedBox(height: 16.h),
              ],
            )),
            SizedBox(height: 24.h),
            Divider(color: colorScheme.outline, thickness: 1),
            SizedBox(height: 16.h),
            _buildPriceRow("Subtotal", "₹${subtotal.toStringAsFixed(2)}", textTheme, colorScheme),
            SizedBox(height: 12.h),
            _buildPriceRow("Shipping", "₹50.00", textTheme, colorScheme), // Example shipping cost
            SizedBox(height: 12.h),
            _buildPriceRow(
              "Total",
              "₹${(subtotal + 50).toStringAsFixed(2)}",
              textTheme,
              colorScheme,
              isTotal: true,
            ),
            SizedBox(height: 170.h),
            _PayButton("Click To Pay", _openCheckout, colorScheme, textTheme),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(
      String imageUrl,
      String name,
      String details,
      String price,
      ColorScheme colorScheme,
      TextTheme textTheme,
      ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.network(
              imageUrl,
              width: 60.w,
              height: 20.w,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Shimmer.fromColors(
                  baseColor: colorScheme.onBackground.withOpacity(0.3),
                  highlightColor: colorScheme.onBackground.withOpacity(0.1),
                  child: Container(
                    width: 60.w,
                    height: 60.w,
                    color: colorScheme.onBackground,
                  ),
                );
              },
              errorBuilder: (context, object, stackTrace) =>
                  Icon(Icons.error, color: colorScheme.error),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold)),
                Text(details, style: textTheme.bodyText2?.copyWith(color: colorScheme.onSurface)),
              ],
            ),
          ),
          Text(price, style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, TextTheme textTheme, ColorScheme colorScheme,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: textTheme.bodyText1?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            )),
        Text(value,
            style: textTheme.bodyText1?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? colorScheme.primary : null,
            )),
      ],
    );
  }

  Widget _PayButton(String text, VoidCallback onPressed, ColorScheme colorScheme, TextTheme textTheme) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.r),
        ),
        minimumSize: Size.fromHeight(50.h),
      ),
      child: Text(
        text,
        style: textTheme.button?.copyWith(fontSize: 17.sp),
      ),
    );
  }
}
