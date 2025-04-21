import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:batchloreskitchen/Pages/Map.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class RecentOrder extends StatefulWidget {
  const RecentOrder({Key? key}) : super(key: key);

  @override
  State<RecentOrder> createState() => _RecentOrderState();
}

class _RecentOrderState extends State<RecentOrder> {
  final Map<String, Timer> _orderTimers = {};

  @override
  void initState() {
    super.initState();
    // Initialize timers for active orders when the widget loads
    _initializeOrderTimers();
  }

  @override
  void dispose() {
    // Cancel all active timers when disposing the widget
    _orderTimers.values.forEach((timer) => timer.cancel());
    super.dispose();
  }

  // Initialize timers for all active orders
  Future<void> _initializeOrderTimers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .where('status', whereNotIn: ['delivered', 'cancelled'])
          .get();

      for (final doc in snapshot.docs) {
        final order = doc.data();
        final status = order['status'] as String;
        _startOrderTimer(doc.id, status);
      }
    } catch (e) {
      print('Error initializing order timers: $e');
    }
  }

  // Method to start order timer for auto delivery status update
  void _startOrderTimer(String orderId, String currentStatus) {
    if (currentStatus.toLowerCase() != 'delivered' && 
        currentStatus.toLowerCase() != 'cancelled') {
      // Cancel existing timer if any
      _orderTimers[orderId]?.cancel();
      
      // Check when the order was created to calculate remaining time
      FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get()
          .then((snapshot) {
            if (snapshot.exists) {
              final orderData = snapshot.data()!;
              final createdAt = (orderData['createdAt'] as Timestamp).toDate();
              final now = DateTime.now();
              final difference = now.difference(createdAt).inMinutes;
              
              // If order is less than 10 minutes old, set timer for remaining time
              if (difference < 10) {
                final remainingTime = 10 - difference;
                _orderTimers[orderId] = Timer(Duration(minutes: remainingTime), () {
                  _updateOrderStatus(orderId);
                });
                print('Order $orderId timer set for $remainingTime minutes');
              } else {
                // If order is already older than 10 minutes, update now
                _updateOrderStatus(orderId);
              }
            }
          })
          .catchError((error) {
            print('Error checking order time: $error');
          });
    }
  }
  
  // Update order status to delivered
  void _updateOrderStatus(String orderId) {
    FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'status': 'delivered'})
        .then((_) async {
          print('Order $orderId automatically marked as delivered');
          // Remove the timer from the map
          _orderTimers.remove(orderId);
          
          // Get order details for the notification
          final orderDoc = await FirebaseFirestore.instance
              .collection('orders')
              .doc(orderId)
              .get();
          
          if (orderDoc.exists) {
            final orderData = orderDoc.data()!;
            final totalAmount = orderData['totalAmount'];
            final items = List<Map<String, dynamic>>.from(orderData['items']);
            final itemCount = items.length;
            
            // Send delivery notification
            await AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: DateTime.now().millisecond,
                channelKey: 'order_channel',
                title: '🎉 Order Delivered Successfully!',
                body: 'Your order of $itemCount item${itemCount > 1 ? 's' : ''} worth ₹$totalAmount has been delivered. Enjoy your meal! 🍽️',
                notificationLayout: NotificationLayout.Default,
                payload: {'orderId': orderId},
              ),
              actionButtons: [
                NotificationActionButton(
                  key: 'VIEW_ORDER',
                  label: 'View Details',
                ),
              ],
            );
          }
        })
        .catchError((error) {
          print('Failed to update order status: $error');
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recent Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22.sp,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16.sp,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user?.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          if (snapshot.hasError) {
            if (snapshot.error.toString().contains('index')) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 70.sp,
                        color: theme.colorScheme.error,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Database Index Required',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Please create the required index in Firebase Console.\n\nError: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            );
          }

          final orders = snapshot.data?.docs ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      size: 80.sp,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'No orders yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Text(
                      'Your recent orders will appear here',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.shopping_bag),
                    label: Text('Start Shopping'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Delete older records if there are more than 4
          if (orders.length > 4) {
            for (int i = 4; i < orders.length; i++) {
              orders[i].reference.delete();
            }
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
            itemCount: orders.length > 4 ? 4 : orders.length,
            itemBuilder: (context, index) {
              final orderDoc = orders[index];
              final order = orderDoc.data() as Map<String, dynamic>;
              final orderId = orderDoc.id;
              final items = List<Map<String, dynamic>>.from(order['items']);
              final status = order['status'] as String;
              final createdAt = (order['createdAt'] as Timestamp).toDate();
              final address = order['deliveryAddress'] as Map<String, dynamic>;
              
              // Start the order timer for status update
              _startOrderTimer(orderId, status);

              final isFirstOrder = index == 0;
              
              // Only show tracking option for first order that is in progress AND not delivered
              final showTrackingOption = isFirstOrder && 
                  (status.toLowerCase() == 'on the way' || status.toLowerCase() == 'preparing') &&
                  status.toLowerCase() != 'delivered' && 
                  status.toLowerCase() != 'cancelled';

              return Container(
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order header with gradient background for first order
                      Container(
                        decoration: isFirstOrder
                            ? BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.8),
                                    theme.colorScheme.primary.withOpacity(0.6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16.r),
                                  topRight: Radius.circular(16.r),
                                ),
                              )
                            : null,
                        padding: EdgeInsets.all(16.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order #${orderId.substring(0, 8)}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isFirstOrder ? Colors.white : null,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  _formatDate(createdAt),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isFirstOrder 
                                        ? Colors.white.withOpacity(0.8) 
                                        : theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                            _buildStatusChip(status, theme, isFirstOrder),
                          ],
                        ),
                      ),
                      
                      // Order details
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Items section with rounded background
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.shopping_bag_outlined,
                                        size: 18.sp,
                                        color: theme.colorScheme.primary,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Items (${items.length})',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),
                                  ...items.map((item) => Padding(
                                    padding: EdgeInsets.only(bottom: 8.h),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 6.w,
                                              height: 6.h,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: theme.colorScheme.primary,
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              '${item['name']} x${item['quantity']}',
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '₹${item['price'] * item['quantity']}',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )).toList(),
                                ],
                              ),
                            ),
                            
                            SizedBox(height: 16.h),
                            
                            // Total amount with accent background
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Amount',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '₹${order['totalAmount']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            SizedBox(height: 16.h),
                            
                            // Delivery address with icon
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 18.sp,
                                  color: theme.colorScheme.primary,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Delivery Address:',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        '${address['address']}\n${address['landmark']}',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            // Display tracking option only for in-progress orders
                            if (showTrackingOption) ...[
                              SizedBox(height: 20.h),
                              Container(
                                height: 150.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withOpacity(0.3),
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Stack(
                                  children: [
                                    // Placeholder for Google Map
                                    Container(
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: Text(
                                          'Order Location Map',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.outline,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 12.h,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.7),
                                            ],
                                          ),
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: () => _openTrackingMap(context, orderId),
                                          icon: Icon(
                                            Icons.map_outlined,
                                            size: 18.sp,
                                          ),
                                          label: Text('Track Order'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: theme.colorScheme.primary,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30.r),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 10.h,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            
                            // For delivered orders, show delivery time estimation instead of tracking
                            if (status.toLowerCase() == 'delivered') ...[
                              SizedBox(height: 16.h),
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: Colors.green.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        'Your order was delivered successfully',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openTrackingMap(BuildContext context, String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderTrackingPage(),
      ),
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme, bool isFirstOrder) {
    Color chipColor;
    IconData statusIcon;
    String displayStatus;

    switch (status.toLowerCase()) {
      case 'preparing':
        chipColor = Colors.orange;
        statusIcon = Icons.restaurant;
        displayStatus = 'Preparing';
        break;
      case 'on the way':
        chipColor = Colors.blue;
        statusIcon = Icons.delivery_dining;
        displayStatus = 'On the way';
        break;
      case 'delivered':
        chipColor = Colors.green;
        statusIcon = Icons.check_circle;
        displayStatus = 'Delivered';
        break;
      case 'cancelled':
        chipColor = Colors.red;
        statusIcon = Icons.cancel;
        displayStatus = 'Cancelled';
        break;
      default:
        chipColor = theme.colorScheme.primary;
        statusIcon = Icons.info;
        displayStatus = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: isFirstOrder ? Colors.white.withOpacity(0.2) : chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isFirstOrder ? Colors.white.withOpacity(0.3) : chipColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14.sp,
            color: isFirstOrder ? Colors.white : chipColor,
          ),
          SizedBox(width: 4.w),
          Text(
            displayStatus,
            style: TextStyle(
              color: isFirstOrder ? Colors.white : chipColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '${date.day} ${months[date.month]}, ${date.year} • $hour:$minute $period';
  }
}