import 'dart:async';
import 'dart:convert';

import 'package:Shepower/Myprofile/FAQ.dart';
import 'package:Shepower/Myprofile/privacyandpolicy.dart';
import 'package:Shepower/OnBoarding/Splash.dart';
import 'package:Shepower/core/utils/image_constant.dart';
import 'package:Shepower/service.dart';
import 'package:Shepower/widgets/custom_image_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:http/http.dart' as http;

import 'Account_settings.dart';
import 'Contacts.dart';
import 'EditProfile.dart';
import 'TermsCondition.dart';

class profilesetting extends StatefulWidget {
  const profilesetting({Key? key});

  @override
  State<profilesetting> createState() => _profileState();
}

class _profileState extends State<profilesetting> {
  final secureStorage = const FlutterSecureStorage();
  String? responseData;
  String profileID = '';
  String profileImg = '';
  String location = '';
  String myId = '';
  String firstname = '';
  String lastname = '';
  String email = '';
  String connection = '';
  String weShare = '';
  String proffession = '';
  String dob = '';
  String education = '';
  String mobileNumber = '';
  bool isWeShareOn = false;

  @override
  void initState() {
    super.initState();
    _loadProfileID();
    const fiveMinutes = const Duration(minutes: 5);
    Timer.periodic(fiveMinutes, (Timer timer) {
      _loadProfileID();
    });
  }

  Future<void> weshareonoff(String weshareon, bool value) async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}weShearOnOff'));
    request.body =
        json.encode({"user_id": id, "weShearOnOff": value.toString()});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> _loadProfileID() async {
    final profileData = await getMyProfile();
    setState(() {
      profileImg = profileData['profileImg'];
      profileID = profileData['profileID'];
      location = profileData['location'];
      myId = profileData['myId'];
      firstname = profileData['firstname'];
      lastname = profileData['lastname'];
      email = profileData['email'];
      dob = profileData['dob'];
      education = profileData['education'];
      proffession = profileData['proffession'];
      connection = profileData['connection'];
      weShare = profileData['weShare'];
      isWeShareOn = profileData['weShearOnOff'] ?? false;
    });
  }

  Future<Map<String, dynamic>> getMyProfile() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('GET', Uri.parse('${ApiConfig.baseUrl}getMyprofile/$id'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      Map<String, dynamic> data = json.decode(responseBody);
      String profileID = data['result']['profileID'];
      String profileImg = data['result']['profile_img'];
      String location = data['result']['location'];
      String myId = data['result']['_id'];
      String firstname = data['result']['firstname'];
      String lastname = data['result']['lastname'];
      String email = data['result']['email'];
      String dob = data['result']['dob'];
      String education = data['result']['education'];
      String proffession = data['result']['proffession'];

      String connection = data['Connection'].toString();
      String weShare = data['weShare'].toString();
      bool weShearOnOff = data['result']['weShearOnOff'] ?? false;

      return {
        'profileID': profileID,
        'profileImg': profileImg,
        'location': location,
        'myId': myId,
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'dob': dob,
        'proffession': proffession,
        'education': education,
        'connection': connection,
        'weShare': weShare,
        'weShearOnOff': weShearOnOff
      };
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  Future<void> handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      final secureStorage = const FlutterSecureStorage();
      await secureStorage.deleteAll();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Splash()),
      );
    } catch (error) {
      print('Error during logout: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SizedBox(
              child: Column(
                children: [
                  SizedBox(
                    height: 30.h,
                  ),
                  _headerview(),
                  SizedBox(
                    height: 13.h,
                  ),
                  _profileimg(),
                  SizedBox(
                    height: 30.h,
                  ),
                  Column(
                    children: [
                      Divider(
                        color: const Color.fromRGBO(232, 232, 232, 1),
                        thickness: 1.sp,
                      ),
                      _editprofile(),
                      Divider(
                        color: const Color.fromRGBO(232, 232, 232, 1),
                        thickness: 1.sp,
                      ),
                      _accountsetting(),
                      Divider(
                        color: const Color.fromRGBO(232, 232, 232, 1),
                        thickness: 1.sp,
                      ),
                      _privacypolicy(),
                      Divider(
                        color: const Color.fromRGBO(232, 232, 232, 1),
                        thickness: 1.w,
                      ),
                      _termscondition(),
                      Divider(
                        color: const Color.fromRGBO(232, 232, 232, 1),
                        thickness: 1.w,
                      ),
                      _buildRow("Weshare".tr(), isWeShareOn, (value) {
                        setState(() {
                          isWeShareOn = value;
                        });
                        weshareonoff("Weshare", value);
                      }),
                      Divider(
                        color: const Color.fromRGBO(232, 232, 232, 1),
                        thickness: 1.w,
                      ),
                      _faqbuilder(),
                      Divider(
                        color: const Color.fromRGBO(
                            232, 232, 232, 1), 
                        thickness: 1.w,
                      ),
                      _contactswidget(),
                      Divider(
                        color: const Color.fromRGBO(
                            232, 232, 232, 1),
                        thickness: 1.w,
                      ),
                      _logoutwidget(),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String text, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomImageView(
              margin: const EdgeInsets.only(left: 5),
              imagePath: ImageConstant.imgNavWeShare,
              width: 25.w,
              height: 25.h,
              color: Color.fromARGB(255, 188, 7, 145),
            ),
            const SizedBox(
              width: 20,
            ),
            Text(text,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 16.sp,
                  color: const Color.fromRGBO(66, 66, 66, 1),
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
        Switch(
          activeColor: Colors.pink[400],
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

//header
  Widget _headerview() {
    return SizedBox(
      height: 54.h,
      width: 364.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 100,
            height: 60,
            child: Image.asset("assets/Splash/shepower.png"),
          ),
          SizedBox(
            width: 100.w,
          ),
          GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: 30.w,
                height: 30.h,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: GradientBoxBorder(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromRGBO(99, 7, 114, 1),
                          Color.fromRGBO(216, 6, 131, 1)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      width: 1.5.w),
                ),
                child: const Icon(Icons.close_rounded,
                    color: Color.fromRGBO(216, 6, 131, 1)),
              )),
        ],
      ),
    );
  }

//profile Container
  Widget _profileimg() {
    return Container(
      height: 84.h,
      width: 328.w,
      decoration: BoxDecoration(
        border: Border.all(
            color: const Color.fromRGBO(151, 151, 151, 1), width: 0.5.sp),
        color: const Color.fromRGBO(151, 151, 151, 1),
        gradient: const LinearGradient(colors: [
          Color.fromRGBO(224, 133, 239, 0.2),
          Color.fromRGBO(250, 163, 215, 0.2)
        ]),
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 8.w,
                ),
                SizedBox(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(31.sp),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        '${imagespath.baseUrl}$profileImg',
                      ),
                      radius: 31.sp,
                    ),
                  ),
                ),
                SizedBox(
                  width: 16.w,
                ),
                SizedBox(
                  width: 150.w,
                  child: Text(
                    firstname,
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Text(mobileNumber,
                    style: GoogleFonts.montserrat(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromRGBO(24, 25, 31, 1))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _editprofile() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => const editprofile(),
          ),
        )
            .then((value) {
          _loadProfileID();
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.mode_edit_rounded,
              size: 25,
              color: Color.fromARGB(255, 188, 7, 145),
            ),
          ),
          SizedBox(
            width: 18.w,
          ),
          Text('Edit Profile'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                color: const Color.fromRGBO(66, 66, 66, 1),
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }

  Widget _accountsetting() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(
            Icons.person_3_outlined,
            size: 25,
            color: Color.fromARGB(255, 188, 7, 145),
          ),
        ),
        SizedBox(
          width: 18.w,
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    AccountSettings(), // Replace with your ProfileScreen widget
              ),
            );
          },
          child: Text('Account Setting'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                color: const Color.fromRGBO(66, 66, 66, 1),
                fontWeight: FontWeight.bold,
              )),
        ),
      ],
    );
  }

  Widget _privacypolicy() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(
            Icons.privacy_tip_outlined,
            size: 25,
            color: Color.fromARGB(255, 188, 7, 145),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PrivacyAndPOlicy(),
              ),
            );
          },
          child: Text('Privacy Policy'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                color: const Color.fromRGBO(66, 66, 66, 1),
                fontWeight: FontWeight.bold,
              )),
        ),
      ],
    );
  }

  Widget _termscondition() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(
            Icons.library_books,
            size: 25,
            color: Color.fromARGB(255, 188, 7, 145),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Flexible(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TermsAndConditions(),
                ),
              );
            },
            child: Text(
              'Terms and Conditions'.tr(),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis, // Add this line
              maxLines: 1, // Add this line to limit to 1 line
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                color: const Color.fromRGBO(66, 66, 66, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _faqbuilder() {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
                border: Border.all(
                    color: Color.fromARGB(255, 188, 7, 145), width: 2),
                borderRadius: BorderRadius.circular(50)),
            child: const Padding(
              padding: EdgeInsets.all(2.0),
              child: Icon(
                Icons.question_mark,
                size: 20,
                color: Color.fromARGB(255, 188, 7, 145),
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      FAQScreen(), // Replace with your ProfileScreen widget
                ),
              );
            },
            child: Text('FAQ’s'.tr(),
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 16.sp,
                  color: const Color.fromRGBO(66, 66, 66, 1),
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      ),
    );
  }

  Widget _contactswidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(
            Icons.contacts_outlined,
            size: 25,
            color: Color.fromARGB(255, 188, 7, 145),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    const ContactsPage(), // Replace with your ProfileScreen widget
              ),
            );
          },
          child: Text('Contacts'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                color: const Color.fromRGBO(66, 66, 66, 1),
                fontWeight: FontWeight.bold,
              )),
        ),
      ],
    );
  }

  Widget _logoutwidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(
            Icons.logout_outlined,
            size: 28,
            color: Color.fromARGB(255, 188, 7, 145),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        GestureDetector(
          onTap: () {
            handleLogout(context);
          },
          child: Text('LogOut'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                color: const Color.fromRGBO(66, 66, 66, 1),
                fontWeight: FontWeight.bold,
              )),
        ),
      ],
    );
  }
}
