import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayExample extends StatefulWidget {
  @override
  _RazorpayExampleState createState() => _RazorpayExampleState();
}

class _RazorpayExampleState extends State<RazorpayExample> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    WidgetsBinding.instance?.addPostFrameCallback((_) => _openCheckout());
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_Oz8oer6jt57xY7', // Replace with your Razorpay Key ID
      'amount': 100, // Amount in paise (100 paise = 1 INR)
      'name': 'Test Payment',
      'description': 'Payment for something',
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
    // Handle success (e.g., show success message)
    Navigator.pop(context); // Go back to the previous screen (Cart Screen)
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Error: ${response.code.toString()} - ${response.message!}')),
    );
    Navigator.pop(context); // Go back to the previous screen (Cart Screen)
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName!}')),
    );
    Navigator.pop(context); // Go back to the previous screen (Cart Screen)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Razorpay Payment'),
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}