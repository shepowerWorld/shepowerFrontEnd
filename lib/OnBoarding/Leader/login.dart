import 'dart:convert';

import 'package:Shepower/OnBoarding/Leader/FaceDetect.dart';
import 'package:Shepower/OnBoarding/Leader/otpScreen.dart';
import 'package:Shepower/OnBoarding/Leader/otpscreenn.dart';
import 'package:Shepower/service.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../common/common_dialog.dart';
import '../users.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final TextEditingController mobileNumberController = TextEditingController();
  final FocusNode mobileNumberFocus = FocusNode();
  bool isPhoneNumberContainerClicked = false;
  bool compressed = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String storedVerificationId = "";
  String mobileNumber = "";
  String? fcmToken;
  bool isLoading = false;
  String message = '';
  String id = "";
  String auth = "";
  bool? profile;
  String? Authrozition;

  void setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
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

  bool isValidMobileNumber() {
    return mobileNumberController.text.trim().length ==
        phoneNumberLengths[selectedCountryCode];
  }

  @override
  void initState() {
    super.initState();
    mobileNumberController.addListener(() {
      setState(() {});
    });

    mobileNumberFocus.addListener(() {
      setState(() {});
    });

    _getFCMTokenFromStorage().then((token) {
      setState(() {
        fcmToken = token;
      });
      print('fcmToken:::$fcmToken');
    });
  }

  Future<String?> _getFCMTokenFromStorage() async {
    return await _secureStorage.read(key: 'fcmToken');
  }

  Future<void> secondLogin() async {
    String? deviceId = await _secureStorage.read(key: 'DeviceId');
    String mobileNumber = mobileNumberController.text.trim();
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('${ApiConfig.baseUrl}loginViaOtpleader'));
    request.body = json.encode({
      "mobilenumber": mobileNumber,
      "token": fcmToken,
      "Authorization": Authrozition,
      "device_id": deviceId
    });
    print('tokentoken$fcmToken');
    print('tokentoken11$request.body');
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> loginUser() async {
    String mobileNumber = mobileNumberController.text.trim();
    String? deviceId = await _secureStorage.read(key: 'DeviceId');
    try {
      setLoading(true); // Show loading indicator

      await Future.delayed(const Duration(seconds: 10));

      var request = http.Request(
          'POST', Uri.parse('${ApiConfig.baseUrl}registrationleader'));
      request.body = json.encode({
        "mobilenumber": mobileNumber,
        "token": fcmToken,
        "device_id": deviceId
      });
      request.headers.addAll({'Content-Type': 'application/json'});

      http.StreamedResponse response = await request.send();

      String result = await response.stream.bytesToString();

      Map<String, dynamic> data = json.decode(result);
      final resultjson = json.decode(result);
      setState(() {
        message = data['message'];
      });

      if (data.containsKey('response') && data['response'] != null) {
        profile = data['response']['profile'];
      } else {
        profile = false;
      }

      if (message == 'You have already registerd with the Shepower') {
        Authrozition = data['istherearenot']?['Authorization'];
        secondLogin();
        phoneAuth(mobileNumber, context);
      } else if (message == "Already registerd") {
        showregisterd(
          context,
          "Already Registered in Citizen Please  login",
        );
      } else if (message == "OTP verified" && profile == false) {
        final String? id = resultjson['response']['_id'];
        String accesstoken = resultjson['tokens']['accessToken'];
        await _secureStorage.write(key: '_id', value: id);
        await _secureStorage.write(key: 'accessToken', value: accesstoken);

        showSuccessDialog(
          context,
          "Already otp Verified Please go to profile Creation",
        );
      } else {
        phoneAuthentication(mobileNumber, context);
      }
    } catch (e) {
      print('Request error: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> phoneAuth(String mobileNumber, BuildContext context) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: "$selectedCountryCode$mobileNumber",
        timeout: const Duration(seconds: 90),
        verificationCompleted: (PhoneAuthCredential credential) async {
          print("Verification completed: ${credential.smsCode}");
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException authException) {
          print("Verification failed: ${authException.message}");
          if (authException.code == 'invalidPhoneNumber') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => otpscreenn(
                mobileNumber: mobileNumber,
                storedVerificationId: verificationId,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("Code auto retrieval timeout: $verificationId");
        },
      );
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  Future<void> phoneAuthentication(
      String mobileNumber, BuildContext context) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: "$selectedCountryCode$mobileNumber",
        timeout: const Duration(seconds: 90),
        verificationCompleted: (PhoneAuthCredential credential) async {
          print("Verification completed: ${credential.smsCode}");
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException authException) {
          print("Verification failed: ${authException.message}");
          // Handle verification failure based on authException.code
          if (authException.code == 'invalidPhoneNumber') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
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

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => otpscreen(
                mobileNumber: mobileNumber,
                storedVerificationId: verificationId,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("Code auto retrieval timeout: $verificationId");
        },
      );
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  void showSuccessDialog(BuildContext context, String message) {
    CommonDialog.showSuccessDialog(context, message, handleOkPressed);
  }

  void incompletemobileNumber(BuildContext context, String message) {
    CommonDialog.errormessagemodel(context, message);
  }

  void showdialogueblocked(BuildContext context, String message) {
    CommonDialog.simpledialogmsg(context, message);
  }

  void showregisterd(BuildContext context, String message) {
    CommonDialog.showSuccessDialog(context, message, onPressed);
  }

  void onPressed() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => UserScreen()));
  }

  void handleOkPressed() {
    navigatetoCitizenProfile();
  }

  void navigatetoCitizenProfile() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Facescan()));
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    _shepowerlogo(),
                    SizedBox(
                      height: 80.h,
                    ),
                    _entermobiletext(),
                    SizedBox(
                      height: 15.h,
                    ),
                    _mobiletextfeild(),
                    SizedBox(height: 106.h),
                    _letsgobutton()
                  ],
                ),
              ),
            ],
          ),
        ),
        resizeToAvoidBottomInset: true,
      ),
    );
  }

  Widget _shepowerlogo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 35.w),
      child: Column(
        children: [
          SizedBox(
            width: 289.32.w,
            height: 235.01.h,
            child: Image.asset(
              'assets/Splash/shepower.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _entermobiletext() {
    return Padding(
      padding: EdgeInsets.only(left: 25.sp),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text('Enter Phone Number to LogIn',
            style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color.fromRGBO(18, 13, 38, 1))),
      ),
    );
  }

  Widget _mobiletextfeild() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isPhoneNumberContainerClicked = !isPhoneNumberContainerClicked;
        });
      },
      child: SizedBox(
        width: 335,
        child: Row(
          children: [
            Container(
              width: 81.w,
              height: 50.h,
              decoration: BoxDecoration(
                border: Border.all(
                    width: 1.w, color: const Color.fromRGBO(24, 25, 31, 1)),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: CountryListPick(
                theme: CountryTheme(
                  isShowTitle: false,
                  isShowFlag: true,
                  isShowCode: false,
                  isDownIcon: true,
                  showEnglishName: true,
                ),
                initialSelection: selectedCountryCode,
                onChanged: (code) {
                  setState(() {
                    selectedCountryCode = code?.dialCode ?? '';
                    phoneNumberFormatter = LengthLimitingTextInputFormatter(
                        phoneNumberLengths[selectedCountryCode] ?? 10);
                  });
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Container(
                height: 50.h,
                width: 216.w,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1.w,
                    color: const Color.fromRGBO(24, 25, 31, 1),
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        "$selectedCountryCode ",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: const Color.fromRGBO(18, 13, 38, 1),
                        ),
                      ),
                    ),
                    VerticalDivider(
                      thickness: 1.sp,
                      color: const Color.fromRGBO(24, 25, 31, 1),
                    ),
                    Expanded(
                      child: TextField(
                        focusNode: mobileNumberFocus,
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        controller: mobileNumberController,
                        keyboardType: TextInputType.phone,
                        cursorColor: const Color.fromRGBO(24, 25, 31, 1),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          phoneNumberFormatter,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _letsgobutton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () async {
          setLoading(false); // Show loading indicator
          if (!isValidMobileNumber()) {
            incompletemobileNumber(
              context,
              "Please enter 10- Digits Mobile Number",
            );
          } else {
            await loginUser();
          }
        },
        child: Container(
          height: 48.h,
          width: 327.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              colors: isLoading
                  ? [
                      const Color.fromRGBO(255, 255, 255, 1),
                      const Color.fromRGBO(216, 6, 131, 1),
                    ]
                  : isValidMobileNumber()
                      ? [
                          const Color.fromRGBO(216, 6, 131, 1),
                          const Color.fromRGBO(99, 7, 114, 1)
                        ]
                      : [
                          const Color.fromRGBO(216, 6, 131, 0.5),
                          const Color.fromRGBO(99, 7, 114, 0.5),
                        ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isLoading
                  ? const CircularProgressIndicator() // Show a loading indicator
                  : Text('Let’s Go !',
                      style: GoogleFonts.montserrat(
                          fontSize: 21.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color.fromRGBO(255, 255, 255, 1))),
            ],
          ),
        ),
      ),
    );
  }
}
