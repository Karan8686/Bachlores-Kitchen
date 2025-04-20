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


class OrderProcessingScreen extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> items;

  const OrderProcessingScreen({
    Key? key,
    required this.totalAmount,
    required this.items,
  }) : super(key: key);

  @override
  _OrderProcessingScreenState createState() => _OrderProcessingScreenState();
}

class _OrderProcessingScreenState extends State<OrderProcessingScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isLoadingLocation = false;
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  String _selectedAddressType = 'Home';
  LatLng? _selectedLocation;

  late Razorpay _razorpay;
  

  @override
  void dispose() {
    _razorpay.clear();
    _addressController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
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

  Widget _buildAddressForm() {
    final theme = Theme.of(context);
    final addressProvider = Provider.of<AddressProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Delivery Address',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            Row(
              children: [
                if (addressProvider.savedAddresses.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.bookmark_border, color: theme.colorScheme.primary),
                    onPressed: _showSavedAddresses,
                    tooltip: 'Saved Addresses',
                  ),
                IconButton(
                  icon: Icon(
                    Icons.my_location,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                  tooltip: 'Use Current Location',
                ),
                IconButton(
                  icon: Icon(
                    Icons.map,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: _openLocationPicker,
                  tooltip: 'Pick on Map',
                ),
              ],
            ),
          ],
        ),
        if (_isLoadingLocation)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: const LinearProgressIndicator(),
          ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: _addressController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter your complete address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
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
            fillColor: theme.colorScheme.surface,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Address Type',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: ['Home', 'Work', 'Other'].map((type) {
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: ChoiceChip(
                label: Text(type),
                selected: _selectedAddressType == type,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedAddressType = type);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Summary',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.secondary,
          ),
        ),
        SizedBox(height: 16.h),
        ...widget.items.map((item) => ListTile(
          title: Text(item['name']),
          subtitle: Text('Quantity: ${item['quantity']}'),
          trailing: Text('₹${item['price'] * item['quantity']}'),
        )),
        Divider(color: theme.colorScheme.outline),
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
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complete Order',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.secondary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 1) {
                  setState(() => _currentStep++);
                } else {
                  _startPayment(); // Start payment instead of directly placing order
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                }
              },
              steps: [
                Step(
                  title: const Text('Delivery Address'),
                  content: _buildAddressForm(),
                  isActive: _currentStep >= 0,
                ),
                Step(
                  title: const Text('Confirm Order'),
                  content: _buildOrderSummary(),
                  isActive: _currentStep >= 1,
                ),
              ],
            ),
    );
  }
}
