import 'dart:convert';

import 'package:Shepower/core/app_export.dart';
import 'package:Shepower/service.dart';
import 'package:Shepower/widgets/custom_elevated_button.dart';
import 'package:Shepower/widgets/custom_text_form_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PayNowOneScreen extends StatefulWidget {
  const PayNowOneScreen({Key? key})
      : super(
          key: key,
        );

  @override
  State<PayNowOneScreen> createState() => _PayNowOneScreenState();
}

class _PayNowOneScreenState extends State<PayNowOneScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController _amountController = TextEditingController();

  String errorMessage = '';
  bool isLoading = false;
  static const platform = const MethodChannel("razorpay_flutter");

  final _razorpay = Razorpay();
  String orderId = '';

  @override
  void initState() {
    super.initState();
    //Implement your own logic to validate the fields
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear(); // Removes all listeners
  }

  Future<void> _createOrder() async {
    setState(() {
      isLoading = true;
    });
    double formattedValue = double.parse(_amountController.text) * 100;
    final storage = FlutterSecureStorage();
    String? customer_Id = await storage.read(key: 'customer_id');
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}createOrder'));
    request.body = json.encode({
      "amount": '${_amountController.text}00',
      "currency": "INR",
      "receipt": "We Share",
      "customer_Id": customer_Id
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    // print(await response.stream.bytesToString());
    final responseData = json.decode(await response.stream.bytesToString());
    print('order_id.............${responseData}');
    setState(() {
      isLoading = false;
    });
    setState(() {
      orderId = responseData['savedOrder']['order_id'] ?? '';
    });
    _makePayment(responseData['savedOrder']['order_id']);
    if (response.statusCode == 200) {
      // print(await response.stream.bytesToString());
      // final responseData = json.decode(await response.stream.bytesToString());
      print('ordercreated.....$responseData');
      // _makePayment(responseData['savedOrder']['order_id']);
    } else {
      print(response.reasonPhrase);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _makePayment(String orderId) async {
    double formattedValue = double.parse(_amountController.text) * 100;
    print('formattedValue...${formattedValue}');
    // var amount = _amountController.text;
    final storage = const FlutterSecureStorage();
    String? email = await storage.read(key: 'email');
    String? mobilenumber = await storage.read(key: 'phonenumber');
    print('email...$email, $mobilenumber...$orderId');
    var options = {
      'key': PaymentKey.apiKey,
      'amount': formattedValue.toString(), //in the smallest currency sub-unit.
      'name': 'ShePower',
      'order_id': orderId, // Generate order_id using Orders API
      'description': 'Contribution to create a strong community',
      'timeout': 120,
      'currency': 'INR', // in seconds
      'prefill': {
        'contact': mobilenumber,
        'email': email,
      }
    };
    try {
      _razorpay.open(options);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('payment error : $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print(
        '_handlePaymentSuccess......${response.paymentId},,,${response.signature}');
    String? paymentid = response.paymentId;
    String? signature = response.signature;
    _getTokensApi(paymentid!, signature!);
    // Do something when payment succeeds
    // showSuccessDialog(context);
    // _amountController.clear();
  }

  Future<void> _getTokensApi(String paymentId, String signature) async {
    final storage = FlutterSecureStorage();
    String? customer_Id = await storage.read(key: 'customer_id');
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}gettokens'));
    request.body = json.encode({
      "customer_id": customer_Id,
      "razorpay_payment_id": paymentId,
      "razorpay_signature": signature
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print('gettokens....${await response.stream.bytesToString()}');

    if (response.statusCode == 200) {
      // print('gettokens....${await response.stream.bytesToString()}');
      verifyOrder(paymentId);
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> verifyOrder(String paymentId) async {
 final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}verifyorder'));
    request.body = json.encode({"order_id": orderId, "payment_id": paymentId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      showSuccessDialog(context);
      _amountController.clear();
    } else {
      print(response.reasonPhrase);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    // showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: const Text('Payment Failed'),
    //         content: const Text('Failed to process the Payment. Please try again.'),
    //         actions: [
    //           TextButton(
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //             child: const Text('OK'),
    //           ),
    //         ],
    //       );
    //     });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
  }

  void showSuccessDialog(BuildContext context) {
    showPlatformDialog(
      context: context,
      builder: (_) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
        ),
        child: BasicDialogAlert(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(150),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD80683),
                      Color(0xFF630772),
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 16.0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.done,
                      size: 48.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              const Center(
                child: Text(
                  "Payment Done successfully.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFD80683),
                        Color(0xFF630772),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 24.0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ok',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);

    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                width: double.maxFinite,
                child: Column(
                  children: [
                    Container(
                      height: 8.v,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.onErrorContainer.withOpacity(1),
                      ),
                    ),
                    SizedBox(height: 16.v),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 16.h),
                        child: Row(
                          children: [
                            CustomImageView(
                              onTap: () => Navigator.pop(context),
                              imagePath: ImageConstant
                                  .imgIconlyCurvedTwoToneArrow23x24,
                              height: 23.v,
                              width: 24.h,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 12.h,
                                top: 2.v,
                              ),
                              child: Text(
                                "pay_now".tr(),
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 50.v),
                    Text(
                      "enter_amount".tr(),
                      style: CustomTextStyles.titleLargeIndigo900,
                    ),
                    SizedBox(height: 58.v),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.h),
                      child: CustomTextFormField(
                        borderDecoration: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                                color: Colors.black,
                                width: 1.0,
                                style: BorderStyle.solid)),
                        alignment: Alignment.center,
                        controller: _amountController,
                        textInputType: const TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        textStyle: CustomTextStyles.paymentAmountText,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.v, horizontal: 25.h),
                      ),
                    ),
                    SizedBox(height: 50.v),
                    CustomElevatedButton(
                      onPressed: () => _createOrder(),
                      width: 215.h,
                      height: 56.v,
                      text: "Pay".tr(),
                      margin:
                          EdgeInsets.only(left: 72.h, right: 72.h, top: 50.v),
                      buttonStyle: CustomButtonStyles.none,
                      decoration: CustomButtonStyles
                          .gradientPinkAToPrimaryTL10Decoration,
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
