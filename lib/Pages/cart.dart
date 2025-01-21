import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Models
class CartItemData {
  final String imageUrl;
  final String name;
  final String details;
  final double price;
  bool isSelected;

  CartItemData({
    required this.imageUrl,
    required this.name,
    required this.details,
    required this.price,
    this.isSelected = true,
  });
}

// Custom Swipe Button
class SwipeableButton extends StatefulWidget {
  final VoidCallback onSwipeComplete;
  final double amount;
  final bool isEnabled;

  const SwipeableButton({
    Key? key,
    required this.onSwipeComplete,
    required this.amount,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  _SwipeableButtonState createState() => _SwipeableButtonState();
}

class _SwipeableButtonState extends State<SwipeableButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _dragExtent = 0;
  bool _isDragging = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.addListener(() {
      if (_controller.isCompleted && !_isCompleted) {
        setState(() => _isCompleted = true);
        widget.onSwipeComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isCompleted || !widget.isEnabled) return;
    setState(() {
      _isDragging = true;
      _dragExtent += details.delta.dx;
      _dragExtent = _dragExtent.clamp(0, context.size!.width - 80.w);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isCompleted || !widget.isEnabled) return;
    setState(() => _isDragging = false);

    final threshold = context.size!.width - 100.w;
    if (_dragExtent >= threshold) {
      _controller.forward();
    } else {
      setState(() => _dragExtent = 0);
    }
  }

  void reset() {
    setState(() {
      _isCompleted = false;
      _dragExtent = 0;
    });
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = MediaQuery.of(context).size.width - 32.w;
    final theme = Theme.of(context);

    return Container(
      height: 64.h,
      width: buttonWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isEnabled
              ? [theme.primaryColor.withOpacity(0.8), theme.primaryColor]
              : [Colors.grey.shade300, Colors.grey.shade400],
        ),
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: widget.isEnabled ? [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ] : [],
      ),
      child: Stack(
        children: [
          // Static text
          Center(
            child: Text(
              widget.isEnabled
                  ? 'Swipe to Pay ₹${widget.amount.toStringAsFixed(2)}'
                  : 'Cart is Empty',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white.withOpacity(0.8),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Draggable thumb
          if (widget.isEnabled)
            GestureDetector(
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              child: Container(
                margin: EdgeInsets.all(4.w),
                alignment: Alignment.centerLeft,
                child: Transform.translate(
                  offset: Offset(_dragExtent, 0),
                  child: Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isCompleted ? Icons.check : Icons.arrow_forward,
                      color: theme.primaryColor,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Main Cart Screen
class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Razorpay _razorpay;
  bool isLoading = true;
  bool isProcessingPayment = false;

  final List<CartItemData> cartItems = [
    CartItemData(
      imageUrl: "https://www.healthline.com/hlcmsresource/images/AN_images/almonds-1296x728-feature.jpg",
      name: "Premium Almonds",
      details: "Approx 210gm",
      price: 349,
    ),
    CartItemData(
      imageUrl: "https://www.healthline.com/hlcmsresource/images/AN_images/benefits-of-kiwi-1296x728-feature.jpg",
      name: "Fresh Kiwi",
      details: "Approx 200gm",
      price: 890,
    ),
    CartItemData(
      imageUrl: "https://www.healthline.com/hlcmsresource/images/AN_images/benefits-of-broccoli-1296x728-feature.jpg",
      name: "Organic Broccoli",
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

    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _openCheckout() {
    setState(() => isProcessingPayment = true);

    var options = {
      'key': 'rzp_test_Oz8oer6jt57xY7',
      'amount': (subtotal * 100).toInt(),
      'name': 'Batchlores Kitchen',
      'description': 'Payment for cart items',
      'prefill': {
        'contact': '7021511537',
        'email': 'test@example.com',
      },
      'external': {
        'wallets': ['googlepay', 'paytm','phonepay']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => isProcessingPayment = false);
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() => isProcessingPayment = false);
    _showSnackBar('Payment Success: ${response.paymentId!}');
    Navigator.pop(context);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => isProcessingPayment = false);
    _showSnackBar('Payment Error: ${response.message!}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showSnackBar('External Wallet: ${response.walletName!}');
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor:theme.colorScheme.background ,
      appBar: _buildAppBar(),
      body: isLoading ? _buildLoadingScreen() : _buildContent(),
      bottomNavigationBar: isLoading ? null : _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    return AppBar(
      elevation: 0,
      backgroundColor:Colors.transparent,
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
        if (cartItems.isNotEmpty)
          Center(
            child: Container(
              margin: EdgeInsets.only(right: 16.w),
              child: Text(
                "${cartItems.length} items",
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
              color:theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final theme = Theme.of(context);
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                SizedBox(height: 16.h),
                _buildCartItems(),
                SizedBox(height: 24.h),
                _buildOrderSummary(),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: Duration(milliseconds: 300));
  }

  Widget _buildCartItems() {
    return Column(
      children: cartItems.asMap().entries.map((entry) {
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
          color: theme.colorScheme.background.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.delete_outline, color: Colors.white),
              ],
          ),
        ),
      onDismissed: (direction) {
      setState(() {
        cartItems.removeAt(index);
    });
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
        "₹${item.price.toStringAsFixed(2)}",
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
              bool press=true;
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
        .slideX(begin: 0.2, duration: Duration(milliseconds: 400));
  }

  Widget _buildOrderSummary() {
    final theme = Theme.of(context);
    final shipping = 50.0;
    final total = subtotal + shipping;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.secondary),
        color: theme.colorScheme.background.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
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
              if (cartItems.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.background.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "${cartItems.length} items",
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
          if (cartItems.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildPriceRow("Tax", subtotal * 0.18), // Example: 18% tax
          ],
          SizedBox(height: 16.h),
          Divider(color: Colors.grey[200]),
          SizedBox(height: 16.h),
          _buildPriceRow("Total Amount", total + (subtotal * 0.18), isTotal: true),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 300))
        .slideY(begin: 0.2, duration: Duration(milliseconds: 400));
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
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: theme.colorScheme.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isProcessingPayment)
              LinearProgressIndicator(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            SizedBox(height: isProcessingPayment ? 16.h : 0),
            SwipeableButton(
              amount: subtotal + 50 + (subtotal * 0.18),
              onSwipeComplete: _openCheckout,
              isEnabled: cartItems.isNotEmpty && !isProcessingPayment,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 500))
        .slideY(begin: 1, duration: Duration(milliseconds: 400));
  }

  double get subtotal =>
      cartItems.fold(0, (sum, item) => sum + item.price);
}