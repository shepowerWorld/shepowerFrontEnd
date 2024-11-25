import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  static const platform = const MethodChannel("razorpay_flutter");

  final _razorpay = Razorpay();

  @override
  void initState(){
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
    void dispose() {
      super.dispose();
      _razorpay.clear(); // Removes all listeners
    }

  var options = {
    'key': '<YOUR_KEY_ID>',
    'amount': 500, //in the smallest currency sub-unit.
    'name': 'Acme Corp.',
    'order_id': 'order_EMBFqjDHEEn80l', // Generate order_id using Orders API
    'description': 'Dog T-Shirt',
    'timeout': 60, // in seconds
    'prefill': {
      'contact': '9000090000',
      'email': 'gaurav.kumar@example.com'
    }
  };

  Future<void> _makePayment() async{
    try {
      _razorpay.open(options);
    }catch (e) {
      print('payment error : $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}