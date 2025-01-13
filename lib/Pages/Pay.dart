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
      print(e.toString());
    }
  }

  // Payment Success Handler
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Success: ' + response.paymentId!);
    // You can send the payment response to your server for verification
  }

  // Payment Error Handler
  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ' + response.code.toString() + ' - ' + response.message!);
  }

  // External Wallet Handler
  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ' + response.walletName!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Razorpay Flutter Integration")),
      body: Center(
        child: ElevatedButton(
          onPressed: _openCheckout,
          child: Text('Pay with Razorpay'),
        ),
      ),
    );
  }
}
