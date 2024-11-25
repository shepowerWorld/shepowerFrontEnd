import 'dart:convert';

import 'package:Shepower/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class PaymentsList {
  final List<Payments> payments;

  PaymentsList({required this.payments});

  factory PaymentsList.fromJson(List<dynamic> json) {
    List<Payments> payments =
        json.map((item) => Payments.fromJson(item)).toList();
    return PaymentsList(payments: payments);
  }
}

class Payments {
  final String orderId;
  final int amount;
  final String currency;
  final String receipt;
  final String razorpayTimeStamp;
  final UserDetails userDetails;

  Payments({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.receipt,
    required this.razorpayTimeStamp,
    required this.userDetails,
  });

  factory Payments.fromJson(Map<String, dynamic> json) {
    return Payments(
      orderId: json['order_id'] ?? '',
      amount: json['amount'],
      currency: json['currency'] ?? '',
      receipt: json['receipt'] ?? '',
      razorpayTimeStamp: json['razorpay_timestamp'] ?? '',
      userDetails: UserDetails.fromJson(json['userDetails']),
    );
  }
}

class UserDetails {
  String? id;
  String? firstname;
  String? profileImg;

  UserDetails({
    this.id,
    this.firstname,
    this.profileImg,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['_id'] ?? '',
      firstname: json['firstname'] ?? '',
      profileImg: json['profile_img'] ?? '',
    );
  }
}

class WeShare extends StatefulWidget {
  const WeShare({Key? key}) : super(key: key);

  @override
  _WeShareState createState() => _WeShareState();
}

class _WeShareState extends State<WeShare> {
  final secureStorage = const FlutterSecureStorage();
  List<Payments> myPayments = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getPayments();
  }

  Future<void> getPayments() async {
    setState(() {
      isLoading = true;
    });
    final custId = await secureStorage.read(key: 'customer_id');
 final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
     var headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accesstoken'
        };    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}getPayments'));
    request.body = json.encode({"customer_Id": custId ?? ""});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    // final resonseJson = json.decode(await response.stream.bytesToString());
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonMap =
          json.decode(await response.stream.bytesToString());

      // Extract the 'payments' field from the Map
      List<dynamic> paymentsJson = jsonMap['payments'];

      // Convert the JSON array to a List of Payments using the factory method
      List<Payments> paymentsList =
          paymentsJson.map((payment) => Payments.fromJson(payment)).toList();
      setState(() {
        myPayments = paymentsList;
        isLoading = false;
      });
    } else {
      print(response.reasonPhrase);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [
                    Color.fromRGBO(99, 7, 114, 0.8),
                    Color.fromRGBO(228, 65, 163, 0.849),
                  ],
                ).createShader(bounds);
              },
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    width: 1,
                    color: const Color.fromRGBO(99, 1, 114, 0.8),
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Icon(
                  Icons.navigate_before,
                  color: Colors.black,
                ),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text('Payments',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: const Color.fromRGBO(25, 41, 92, 12))),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : myPayments.isEmpty
                ? const Center(
                    child: Text("No Payments available."),
                  )
                : ListView.builder(
                    itemCount: myPayments.length,
                    itemBuilder: (context, index) {
                      final myPayment = myPayments[index];

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: InkWell(
                          onTap: () {},
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10.h,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 23.r,
                                    backgroundImage: NetworkImage(
                                      '${imagespath.baseUrl}${myPayment.userDetails.profileImg}',
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width:
                                            250.0, // Set your desired maximum width
                                        child: Text.rich(
                                          TextSpan(
                                            children: <InlineSpan>[
                                              TextSpan(
                                                text: myPayment.amount
                                                    .toString()
                                                    .replaceRange(
                                                        myPayment.amount
                                                                .toString()
                                                                .length -
                                                            2,
                                                        myPayment.amount
                                                            .toString()
                                                            .length,
                                                        ""), // Get the first word
                                                style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16.sp,
                                                  height: 1.21875,
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    ' ${myPayment.currency}', // Get the rest of the text
                                                style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14.sp,
                                                  height: 1.21875,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5.h,
                                      ),
                                      Text(
                                        formatNotificationTime(
                                            myPayment.razorpayTimeStamp),
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                          height: 1.21875,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ));
  }

  String formatNotificationTime(String createdAt) {
    try {
      final currentTime = DateTime.now();
      final notificationTime = DateTime.parse(createdAt);
      final timeDifference = currentTime.difference(notificationTime);

      if (timeDifference.inMinutes < 1) {
        return 'Just now';
      } else if (timeDifference.inHours < 1) {
        return '${timeDifference.inMinutes} minute${timeDifference.inMinutes > 1 ? 's' : ''} ago';
      } else if (timeDifference.inHours < 24) {
        return '${timeDifference.inHours} hour${timeDifference.inHours > 1 ? 's' : ''} ago';
      } else if (timeDifference.inDays < 7) {
        return '${timeDifference.inDays} day${timeDifference.inDays > 1 ? 's' : ''} ago';
      } else if (timeDifference.inDays < 30) {
        final weeks = (timeDifference.inDays / 7).floor();
        return '$weeks week${weeks > 1 ? 's' : ''} ago';
      } else if (timeDifference.inDays < 365) {
        final months = (timeDifference.inDays / 30).floor();
        return '$months month${months > 1 ? 's' : ''} ago';
      } else {
        final years = (timeDifference.inDays / 365).floor();
        return '$years year${years > 1 ? 's' : ''} ago';
      }
    } catch (e) {
      // Handle the parsing error gracefully. You can return a default message or format.
      return 'Invalid Date Format';
    }
  }
}
