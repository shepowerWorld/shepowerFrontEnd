import 'dart:async';
import 'dart:convert';

import 'package:Shepower/OnBoarding/Leader/FaceDetect.dart';
import 'package:Shepower/service.dart';
import 'package:Shepower/widgets/custom_pin_code_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../common/common_dialog.dart';

class otpscreen extends StatefulWidget {
  final String mobileNumber;
  final String storedVerificationId;

  const otpscreen({
    Key? key,
    required this.mobileNumber,
    required this.storedVerificationId,
  }) : super(key: key);

  @override
  State<otpscreen> createState() => otpScreenState();
}

class otpScreenState extends State<otpscreen> {
  final TextEditingController mobileNumberController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController pinController = TextEditingController();
  String otp = '';
  FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = false; // Track loading state
  String message = '';
  int remainingTime = 60;
  late Timer timer;

 Future<void> verifyOTP() async {
  setState(() {
    isLoading = true;
  });

  otp = pinController.text;
  if (remainingTime > 0) {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.storedVerificationId, smsCode: otp);

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        verification();
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.message ?? "An unknown error occurred";
      _showErrorDialog(context, errorMessage); // Show error dialog
    } catch (e) {
      // If some other error occurs
      _showErrorDialog(context, "An unknown error occurred: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  } else {
    otpExpire();
    setState(() {
      isLoading = false;
    });
  }
}

// Function to show an alert dialog with the error message
void _showErrorDialog(BuildContext context, String errorMessage) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Verification Error"),
        content: Text(errorMessage),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          timer.cancel(); // Stop the timer when it reaches 0
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  String selectedCountryCode = "+91";
  Map<String, int> phoneNumberLengths = {
    "+1": 10, // Default length
    "+91": 10, // Example: India
    "+86": 11, // Example: China
    "+380": 9 // Ukraine
    // Add more country dial codes and lengths as needed
  };

  LengthLimitingTextInputFormatter phoneNumberFormatter =
      LengthLimitingTextInputFormatter(10);

  bool isValidOtp() {
    return pinController.text.isNotEmpty;
  }

  Future<void> generateNewOTP(String mobileNumber) async {
    setState(() {
      remainingTime = 60;
    });
    startTimer();
    FirebaseAuth auth = FirebaseAuth.instance;
    print('auth==>>$auth');
    try {
      print('Nandan3');
      await auth.verifyPhoneNumber(
        phoneNumber: "$selectedCountryCode$mobileNumber",
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          print("Verification completed: ${credential.smsCode}");
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException authException) {
          print("Verification failed: ${authException.message}");
          // Handle verification failure based on authException.code
          if (authException.code == 'invalidPhoneNumber') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid phone number'),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Verification failed: ${authException.message}'),
              ),
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          print("Stored verificationId: $verificationId");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("Code auto retrieval timeout: $verificationId");
        },
      );
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  Future<void> verification() async {
    var headers = {'Content-Type': 'application/json'};
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}otpVerifyleader'));
    request.body = json.encode({"mobilenumber": widget.mobileNumber});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    String responseBody = await response.stream.bytesToString();

    Map<String, dynamic> responseJson = json.decode(responseBody);

    setState(() {
      message = responseJson['message'];
    });

    if (responseJson['Status'] == true) {
      showSuccessDialog(
        context,
        "otp Verified Successfully",
      );
      String id = responseJson['response']['_id'];
      String accesstoken = responseJson['tokens']['accessToken'];

      const storage = FlutterSecureStorage();
      await storage.write(key: '_id', value: id);
      await storage.write(key: 'accessToken', value: accesstoken);

      print('ID: $id');
      print('accesstoken $accesstoken');
    } else {
      if (message == 'otp Verified Successfully') {
        showSuccessDialog(
          context,
          "otp Verified Successfully",
        );
        final storage = FlutterSecureStorage();
        await storage.write(key: 'Signin', value: json.encode(responseJson));
      } else if (message == 'otp verified already') {
        final storage = FlutterSecureStorage();
        await storage.write(key: 'Signin', value: json.encode(responseJson));
      } else if (message == 'Please enter 6 digits OTP') {
        incompleteotp(
          context,
          "Please enter 6- Digits otp",
        );
      } else {
        wrongOtp(
          context,
          "Wrong OTP ",
        );
      }
      print(response.reasonPhrase);
    }
  }

  void showSuccessDialog(BuildContext context, String message) {
    CommonDialog.showSuccessDialog(context, message, navitoFace);
  }

  void otpExpire() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Expired'),
            content: const Text('OTP Expired. Please try with new OTP'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  void incompleteotp(BuildContext context, String message) {
    CommonDialog.simpledialogmsg(context, message);
  }

  void wrongOtp(BuildContext context, String message) {
    CommonDialog.errormessagemodel(context, message);
  }

  void navitoFace() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Facescan()));
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                Container(
                  width: 289.32.w,
                  height: 350.37.h,
                  padding: const EdgeInsets.fromLTRB(36, 20, 36, 7.37),
                  child: Column(
                    // Wrap the child widgets in a Column
                    children: [
                      Image.asset(
                        'assets/Splash/shepower.png',
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 10.h,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 30.sp),
                    child: Text('Enter OTP ',
                        style: GoogleFonts.montserrat(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromRGBO(18, 13, 38, 1))),
                  ),
                ),
                SizedBox(height: 22.59.h),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: CustomPinCodeTextField(
                    context: context,
                    onChanged: (value) {
                      pinController.text = value;
                    },
                  ),
                ),
                Container(
                  height: 210.98.h,
                  width: 360.w,
                  // padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: otpControllers
                      //       .asMap()
                      //       .entries
                      //       .map(
                      //         (entry) => Container(
                      //           width: 50.w,
                      //           height: 50.h,
                      //           padding: const EdgeInsets.all(5),
                      //           child: TextField(
                      //             controller: entry.value,
                      //             keyboardType: TextInputType.number,
                      //             maxLength: 1,
                      //             textAlign: TextAlign.center,
                      //             style: GoogleFonts.montserrat(
                      //               fontSize: 24.sp,
                      //               fontWeight: FontWeight.w800,
                      //               color: const Color.fromRGBO(24, 25, 31, 1),
                      //             ),
                      //             decoration: InputDecoration(
                      //               contentPadding: EdgeInsets.zero,
                      //               counterText: '',
                      //               focusedBorder: OutlineInputBorder(
                      //                 borderSide: BorderSide(
                      //                   color: const Color.fromRGBO(0, 0, 0, 1),
                      //                   width: 1.88.w,
                      //                 ),
                      //                 borderRadius: BorderRadius.circular(10.r),
                      //               ),
                      //               enabledBorder: OutlineInputBorder(
                      //                 borderSide: BorderSide(
                      //                   color: Colors.black,
                      //                   width: 1.88.w,
                      //                 ),
                      //                 borderRadius: BorderRadius.circular(10.r),
                      //               ),
                      //             ),
                      //             onChanged: (value) {
                      //               if (value.isNotEmpty) {
                      //                 if (entry.key <
                      //                     otpControllers.length - 1) {
                      //                   // Move focus to the next TextField
                      //                   FocusScope.of(context).requestFocus(
                      //                       focusNodes[entry.key + 1]);
                      //                 } else {}
                      //               } else {
                      //                 if (entry.key > 0) {
                      //                   FocusScope.of(context).requestFocus(
                      //                       focusNodes[entry.key - 1]);
                      //                 } else {}
                      //               }
                      //             },
                      //           ),
                      //         ),
                      //       )
                      //       .toList(),
                      // ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16.w),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Enter OTP within $remainingTime seconds',
                            textAlign: TextAlign.start,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      RichText(
                        text: TextSpan(
                          text: "Didn’t get OTP? ",
                          style: GoogleFonts.montserrat(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color.fromRGBO(24, 25, 31, 1),
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Get new',
                              style: GoogleFonts.montserrat(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color.fromRGBO(216, 6, 131, 1),
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Handle the "Get New" button tap here
                                  print('Nandan');
                                  generateNewOTP(widget.mobileNumber);
                                  print('Nandan1');
                                },
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (isValidOtp()) {
                                      verifyOTP();
                                    } else {
                                      setState(() {
                                        incompleteotp(
                                          context,
                                          "Please enter 6- Digits otp",
                                        );
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator()
                                : Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.r),
                                      gradient: LinearGradient(
                                        colors: isValidOtp()
                                            ? [
                                                const Color.fromRGBO(
                                                    216, 6, 131, 1),
                                                const Color.fromRGBO(
                                                    99, 7, 114, 1),
                                              ]
                                            : [
                                                const Color.fromRGBO(
                                                    255, 255, 255, 0.5),
                                                const Color.fromRGBO(
                                                    255, 255, 255, 0.5),
                                              ],
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                      horizontal: 24.0,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text('VERIFY',
                                        style: GoogleFonts.montserrat(
                                            fontSize: 21.sp,
                                            fontWeight: FontWeight.w800,
                                            color: const Color.fromRGBO(
                                                255, 255, 255, 1))),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 25.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(
                        'By validating OTP, you are indicating that you have accepted our Privacy Policy & Terms of Service',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(35, 31, 32, 1))),
                  ),
                ),
                // Add more widgets here as needed
              ],
            ),
          ),
        ),
      ),
    );
  }
}
