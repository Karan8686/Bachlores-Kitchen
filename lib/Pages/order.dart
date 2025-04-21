import 'package:batchloreskitchen/Pages/cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:batchloreskitchen/prrovider/Cart/Cart_provider.dart';
import 'package:batchloreskitchen/providers/address_provider.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:batchloreskitchen/Pages/location_picker.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:batchloreskitchen/Pages/recent_order.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class OrderBottomSheet extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> items;

  const OrderBottomSheet({
    Key? key,
    required this.totalAmount,
    required this.items,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required double totalAmount,
    required List<Map<String, dynamic>> items,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderBottomSheet(
        totalAmount: totalAmount,
        items: items,
      ),
    );
  }

  @override
  State<OrderBottomSheet> createState() => _OrderBottomSheetState();
}

class _OrderBottomSheetState extends State<OrderBottomSheet> {
  bool _isLoading = false;
  bool _isLoadingLocation = false;
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  String _selectedAddressType = 'Home';
  LatLng? _selectedLocation;
  late Razorpay _razorpay;
  bool _showOrderSummary = false;

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _addressController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedAddress() async {
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    final savedAddress = await addressProvider.getSelectedAddress();
    if (savedAddress != null) {
      setState(() {
        _addressController.text = savedAddress['address'] ?? '';
        _landmarkController.text = savedAddress['landmark'] ?? '';
        _selectedAddressType = savedAddress['type'] ?? 'Home';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _requestLocationService();
        if (!serviceEnabled) return;
      }

      var permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) return;
      }

      if (permission == geo.LocationPermission.deniedForever) {
        _showLocationDeniedDialog();
        return;
      }

      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final address = [
          place.street,
          place.subLocality,
          place.locality,
          place.postalCode,
          place.administrativeArea,
        ].where((element) => element != null && element.isNotEmpty)
         .join(', ');

        setState(() {
          _addressController.text = address;
          _landmarkController.text = place.name ?? '';
        });
      }
    } catch (e) {
      _showError('Error getting location: $e');
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<bool> _requestLocationService() async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Required'),
          content: const Text('Please enable location services to use this feature.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Settings'),
              onPressed: () async {
                await geo.Geolocator.openLocationSettings();
                if (mounted) Navigator.of(context).pop();
                result = await geo.Geolocator.isLocationServiceEnabled();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                result = false;
              },
            ),
          ],
        );
      },
    );
    return result;
  }

  void _showLocationDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location permission is required to fetch your current address. '
          'Please enable it in your device settings.'
        ),
        actions: [
          TextButton(
            child: const Text('Open Settings'),
            onPressed: () async {
              Navigator.pop(context);
              await perm.openAppSettings();
            },
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSavedAddresses() {
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Saved Addresses',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            if (addressProvider.savedAddresses.isEmpty)
              Center(
                child: Text(
                  'No saved addresses',
                  style: theme.textTheme.bodyLarge,
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                itemCount: addressProvider.savedAddresses.length,
                itemBuilder: (context, index) {
                  final address = addressProvider.savedAddresses[index];
                  return ListTile(
                    leading: Icon(
                      address['type'] == 'Home' ? Icons.home
                      : address['type'] == 'Work' ? Icons.work
                      : Icons.location_on,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(address['address']),
                    subtitle: Text(address['landmark'] ?? ''),
                    onTap: () {
                      setState(() {
                        _addressController.text = address['address'];
                        _landmarkController.text = address['landmark'] ?? '';
                        _selectedAddressType = address['type'];
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Create order in Firestore
      final orderDoc = await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'items': widget.items,
        'totalAmount': widget.totalAmount,
        'status': 'preparing',
        'createdAt': FieldValue.serverTimestamp(),
        'deliveryAddress': {
          'address': _addressController.text,
          'landmark': _landmarkController.text,
          'type': _selectedAddressType,
        },
        'estimatedDeliveryTime': DateTime.now().add(const Duration(minutes: 45)),
      });

      // Show enhanced food-themed order confirmation notification
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecond,
          channelKey: 'order_channel',
          title: '🍽️ Order Confirmed!',
          body: 'Your delicious feast worth ₹${widget.totalAmount} is being prepared with love! Our chefs are working their magic in the kitchen. Track your order for live updates! 🚀',
          bigPicture: 'resource://drawable/ic_launcher',
          notificationLayout: NotificationLayout.BigPicture,
          payload: {'orderId': orderDoc.id},
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'TRACK_ORDER',
            label: 'Track Order',
          ),
        ],
      );

      debugPrint('Order created with ID: ${orderDoc.id}');

      // Save address and clear cart
      if (!mounted) return;
      
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      await addressProvider.saveAddress({
        'address': _addressController.text,
        'landmark': _landmarkController.text,
        'type': _selectedAddressType,
      });

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.clearCart();

      // Show success dialog then navigate to recent orders
      

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RecentOrder()),
        
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message ?? "Error occurred"}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const CartScreen(),
      ),
      (route) => false,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName!}')),
    );
  }

  void _startPayment() {
    var options = {
      'key': 'rzp_test_Oz8oer6jt57xY7',
      'amount': (widget.totalAmount * 100).toInt(),
      'name': 'Batchlores Kitchen',
      'description': 'Food Order Payment',
      'prefill': {
        'contact': 'CUSTOMER_PHONE',
        'email': 'CUSTOMER_EMAIL'
      },
      'theme': {
        'color': '#283618',
      },
      'external': {
        'wallets': ['paytm','phonepe'],
        'upis': ['paytm','phonepe']
        
      },
      
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _openLocationPicker() async {
    LatLng? initialLocation;
    if (_selectedLocation != null) {
      initialLocation = _selectedLocation;
    } else {
      try {
        final position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high
        );
        initialLocation = LatLng(position.latitude, position.longitude);
      } catch (e) {
        // Use default India coordinates if location not available
        initialLocation = const LatLng(20.5937, 78.9629);
      }
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLocation: initialLocation,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _addressController.text = result['address'];
        _selectedLocation = result['location'];
      });
    }
  }

  Widget _buildAddressSection() {
    final theme = Theme.of(context);
    final addressProvider = Provider.of<AddressProvider>(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery Address',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                if (addressProvider.savedAddresses.isNotEmpty)
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.bookmark_border),
                      label: Text('Saved'),
                      onPressed: _showSavedAddresses,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.my_location),
                    label: Text('Current'),
                    onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      foregroundColor: theme.colorScheme.onSecondaryContainer,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: IconButton(
                    onPressed: _openLocationPicker,
                    icon: Icon(Icons.map_outlined),
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
          if (_isLoadingLocation)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: LinearProgressIndicator(),
            ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter your complete address *',
                    prefixIcon: Icon(Icons.home_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: _addressController.text.isEmpty 
                            ? theme.colorScheme.error
                            : theme.colorScheme.outline,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: _addressController.text.isEmpty 
                            ? theme.colorScheme.error.withOpacity(0.5)
                            : theme.colorScheme.outline.withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: _addressController.text.isEmpty 
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                      ),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    contentPadding: EdgeInsets.all(16.w),
                    suffixIcon: _addressController.text.isEmpty
                        ? Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.error,
                          )
                        : Icon(
                            Icons.check_circle_outline,
                            color: theme.colorScheme.primary,
                          ),
                  ),
                  onChanged: (value) {
                    setState(() {}); // Rebuild to update validation UI
                  },
                ),
                if (_addressController.text.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h, left: 16.w),
                    child: Text(
                      'Delivery address is required',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _landmarkController,
                  decoration: InputDecoration(
                    hintText: 'Landmark (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    filled: true,
                  ),
                ),
                SizedBox(height: 16.h),
                Wrap(
                  spacing: 8.w,
                  children: ['Home', 'Work', 'Other'].map((type) {
                    return ChoiceChip(
                      label: Text(type),
                      selected: _selectedAddressType == type,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedAddressType = type);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _addressController.text.trim().isEmpty ? null : () {
                      if (_addressController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter delivery address'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: theme.colorScheme.error,
                            action: SnackBarAction(
                              label: 'OK',
                              textColor: theme.colorScheme.onError,
                              onPressed: () {},
                            ),
                          ),
                        );
                        return;
                      }
                      setState(() => _showOrderSummary = true);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _addressController.text.trim().isEmpty
                          ? theme.colorScheme.primary.withOpacity(0.5)
                          : theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection() {
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => setState(() => _showOrderSummary = false),
                    ),
                    Text(
                      'Order Summary',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                ...widget.items.map((item) => ListTile(
                  title: Text(item['name']),
                  subtitle: Text('Quantity: ${item['quantity']}'),
                  trailing: Text('₹${item['price'] * item['quantity']}'),
                )),
                Divider(),
                ListTile(
                  title: Text(
                    'Delivery Address',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(_addressController.text),
                ),
                Divider(),
                ListTile(
                  title: Text(
                    'Total Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    '₹${widget.totalAmount}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _isLoading ? null : _startPayment,
                    child: _isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Text('Proceed to Payment'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 60.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => _showOrderSummary
            ? _buildOrderSummarySection()
            : _buildAddressSection(),
      ),
    );
  }
}
