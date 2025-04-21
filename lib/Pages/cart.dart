import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:batchloreskitchen/prrovider/Cart/Cart_provider.dart';
import 'package:batchloreskitchen/prrovider/Cart/Cart_item.dart';
import "package:batchloreskitchen/Pages/order.dart";
import 'package:awesome_notifications/awesome_notifications.dart';

// Main Cart Screen
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with WidgetsBindingObserver {
  bool isLoading = true;
  bool isProcessingPayment = false;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // App is in background or closed
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      if (cartProvider.cartItems.isNotEmpty) {
        _scheduleCartReminder();
      }
    }
  }

  Future<void> _scheduleCartReminder() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final itemCount = cartProvider.cartItems.length;
    final totalAmount = subtotal + 50.0 + (subtotal * 0.18);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecond,
        channelKey: 'order_channel',
        title: '🛒 Items Waiting in Your Cart!',
        body: 'You have $itemCount items worth ₹${totalAmount.toStringAsFixed(2)} in your cart. Complete your order to enjoy your delicious meal!',
        notificationLayout: NotificationLayout.Default,
        payload: {'screen': 'cart'},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'OPEN_CART',
          label: 'View Cart',
        ),
      ],
    );
  }

  double get subtotal {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    return cartProvider.cartItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  void _openCheckout() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cartItems = cartProvider.cartItems;
    if (cartItems.isEmpty) return;

    final totalAmount = (subtotal + 50.0 + (subtotal * 0.18));

    OrderBottomSheet.show(
      context,
      totalAmount: totalAmount,
      items: cartItems.map((item) => {
        'name': item.name,
        'quantity': item.quantity,
        'price': item.price,
      }).toList(),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: theme.colorScheme.secondary,
          size: 22.sp,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Shopping Cart",
        style: TextStyle(
          fontFamily: 'Poppins',
          color: theme.colorScheme.secondary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        if (context.watch<CartProvider>().cartItems.isNotEmpty)
          Center(
            child: Container(
              margin: EdgeInsets.only(right: 16.w),
              child: Text(
                "${context.watch<CartProvider>().cartItems.length} items",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: theme.colorScheme.secondary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(height: 16.h),
          Text(
            "Loading your cart...",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16.sp,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                SizedBox(height: 16.h),
                _buildCartItems(),
                if (context.watch<CartProvider>().cartItems.isNotEmpty) ...[
                  SizedBox(height: 24.h),
                  _buildOrderSummary(),
                  SizedBox(height: 100.h),
                ],
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: const Duration(milliseconds: 300));
  }

  Widget _buildCartItems() {
    return Column(
      children: context.watch<CartProvider>().cartItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return _buildCartItem(item, index);
      }).toList(),
    );
  }

  Widget _buildCartItem(CartItemData item, int index) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.secondary),
        color: theme.colorScheme.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Dismissible(
        key: Key(item.name),
        direction: DismissDirection.endToStart,
        background: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.delete_outline, color: Colors.white),
            ],
          ),
        ),
        onDismissed: (direction) {
          context.read<CartProvider>().removeItem(index);
          _showSnackBar('${item.name} removed from cart');
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      image: DecorationImage(
                        image: NetworkImage(item.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.secondary
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          item.details,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.sp,
                            color: theme.primaryColor,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Quantity: ${item.quantity}",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.sp,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "₹${(item.price * item.quantity).toStringAsFixed(2)}",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.favorite_border,
                          color: theme.colorScheme.secondary,
                        ),
                        onPressed: () {
                          // TODO: Implement favorite functionality
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn()
        .slideX(begin: 0.2, duration: const Duration(milliseconds: 400));
  }

  Widget _buildOrderSummary() {
    final theme = Theme.of(context);
    const shipping = 50.0;
    final total = subtotal + shipping;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.secondary),
        color: theme.colorScheme.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order Summary",
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.secondary
                ),
              ),
              if (context.watch<CartProvider>().cartItems.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "${context.watch<CartProvider>().cartItems.length} items",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildPriceRow("Subtotal", subtotal),
          SizedBox(height: 8.h),
          _buildPriceRow("Shipping", shipping),
          if (context.watch<CartProvider>().cartItems.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildPriceRow("Tax", subtotal * 0.18), // Example: 18% tax
          ],
          SizedBox(height: 16.h),
          Divider(color: Colors.grey[200]),
          SizedBox(height: 16.h),
          _buildPriceRow("Total Amount", total + (subtotal * 0.18), isTotal: true),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 300))
        .slideY(begin: 0.2, duration: const Duration(milliseconds: 400));
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: isTotal ? 18.sp : 16.sp,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal ? Colors.black87 : theme.colorScheme.primary,
          ),
        ),
        Text(
          "₹${amount.toStringAsFixed(2)}",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: isTotal ? 18.sp : 16.sp,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: isTotal
                ? Theme.of(context).primaryColor
                : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final theme = Theme.of(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final isCartEmpty = cartProvider.cartItems.isEmpty;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isProcessingPayment)
              LinearProgressIndicator(
                backgroundColor: theme.primaryColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.primaryColor,
                ),
              ),
            SizedBox(height: isProcessingPayment ? 16.h : 0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCartEmpty || isProcessingPayment ? null : _openCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCartEmpty ? Colors.grey : theme.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
                child: Text(
                  isProcessingPayment ? "Processing..." : "Proceed to Checkout",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 500))
        .slideY(begin: 1, duration: const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(),
      body: isLoading ? _buildLoadingScreen() : _buildContent(),
      bottomNavigationBar: isLoading ? null : _buildBottomBar(),
    );
  }
}