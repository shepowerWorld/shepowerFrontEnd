import 'dart:async';
import 'dart:convert';

import 'package:Shepower/service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:http/http.dart' as http;

import 'Profilesetting.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key});

  @override
  State<Profile> createState() => _profileState();
}

class _profileState extends State<Profile> {
  final secureStorage = const FlutterSecureStorage();
  String? responseData;
  String profileID = '';
  String profileImg = '';
  String location = '';
  String myId = '';
  String name = "";
  String mobileNumber = "";
  String mail = "";
  String birth = "";
  String eduction = "";
  String profession = "";
  String city = "";
  String familyMemebers = "";
  String language = "";
  List<String> movies = [];
  List<String> music = [];
  List<String> books = [];
  List<String> dance = [];
  List<String> sports = [];
  List<String> otherintrests = [];
  List<String> areaOfInterest = []; // You can initialize it as an empty list

  @override
  void initState() {
    super.initState();
    _loadProfileID();
    const fiveMinutes = const Duration(minutes: 5);
    Timer.periodic(fiveMinutes, (Timer timer) {
      _loadProfileID();
    });
  }

  Future<void> _loadProfileID() async {
    final profileData = await GetMyProfile();
    setState(() {
      profileImg = profileData['profileImg'];
      profileID = profileData['profileID'];
      location = profileData['location'];
      myId = profileData['myId'];
      name = profileData['name'];
      mail = profileData['email'];
      mobileNumber = profileData['mobileNumber'];
      birth = profileData['dob'];
      eduction = profileData['education'];
      profession = profileData['profession'];
      city = profileData['location'];
      familyMemebers = profileData['Fmily'];
      language = profileData['languages'];
      movies = profileData['movies'];
      music = profileData['music'];
      books = profileData['books'];
      dance = profileData['dance'];
      sports = profileData['sports'];
      otherintrests = profileData['otherintrests'];
    });
  }

  Future<Map<String, dynamic>> GetMyProfile() async {
    final storage = const FlutterSecureStorage();
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
      print('responseBody data: $data');

      print('responseBody data: $data');
      String profileID = data['result']['profileID'];
      String profileImg = data['result']['profile_img'];
      String location = data['result']['location'];
      String myId = data['result']['_id'];
      String name = data['result']['firstname'];
      String mobileNumber = data['result']['mobilenumber'].toString();
      String email = data['result']['email'];
      String dob = data['result']['dob'];
      String education = data['result']['education'];
      String profession = data['result']['proffession'];
      String family = data['result']['familymembers'].join(', ');
      String languages = data['result']['languages'].join(', ');
      List<String> movies =
          List<String>.from(data['result']['areaofintrest']['movies']);
      List<String> music =
          List<String>.from(data['result']['areaofintrest']['music']);

      List<String> books =
          List<String>.from(data['result']['areaofintrest']['books']);

      List<String> dance =
          List<String>.from(data['result']['areaofintrest']['dance']);

      List<String> sports =
          List<String>.from(data['result']['areaofintrest']['sports']);

      List<String> otherintrests =
          List<String>.from(data['result']['areaofintrest']['otherintrests']);

      // Return the data as a Map
      return {
        'profileID': profileID,
        'profileImg': profileImg,
        'myId': myId,
        'name': name,
        'mobileNumber': mobileNumber,
        "email": email,
        "dob": dob,
        "education": education,
        "profession": profession,
        "location": location,
        "Fmily": family,
        "languages": languages,
        "movies": movies,
        "music": music,
        "books": books,
        "dance": dance,
        "sports": sports,
        "otherintrests": otherintrests,
      };
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    String birthDateStr = birth.split('T')[0]; // Extract only the date part

    DateTime birthDate;
    String formattedBirthDate;

    try {
      birthDate = DateTime.parse(birthDateStr);
      formattedBirthDate = DateFormat('dd-MM-yyyy').format(birthDate);
    } catch (e) {
      formattedBirthDate = "Invalid date";
      print("Error parsing birth date: $e");
    }

    ScreenUtil.init(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 16, 15, 0),
            child: Container(
              child: Column(
                children: [
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 100,
                          height: 60,
                          child: Image.asset("assets/Splash/shepower.png"),
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
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    height: 84.h,
                    width: 328.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      color: const Color.fromARGB(149, 230, 203, 217),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 15.w,
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    '${imagespath.baseUrl}$profileImg',
                                  ),
                                  radius: 30,
                                ),
                              ),
                              SizedBox(
                                width: 12.w,
                              ),
                              SizedBox(
                                width: 93.w,
                                child: Text(name,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .push(
                                MaterialPageRoute(
                                  builder: (context) => const profilesetting(),
                                ),
                              )
                                  .then((value) {
                                _loadProfileID();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(50, 0, 15, 10),
                              child: ShaderMask(
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
                                      color:
                                          const Color.fromRGBO(99, 1, 114, 0.8),
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.navigate_next,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Name'.tr(),
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(24, 25, 31, 1),
                        )),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                            height: 45.h,
                            width: 323.w,
                            decoration: BoxDecoration(
                              border: const GradientBoxBorder(
                                gradient: LinearGradient(colors: [
                                  Color.fromRGBO(216, 6, 131, 1),
                                  Color.fromRGBO(99, 7, 114, 1)
                                ]),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                  name, // Set the educational details here
                                  style: GoogleFonts.nunitoSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                      height: 1.5,
                                      color: Colors.pink)),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Phone Number'.tr(),
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(24, 25, 31, 1),
                        )),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                            height: 45.h,
                            width: 323.w,
                            decoration: BoxDecoration(
                              border: const GradientBoxBorder(
                                gradient: LinearGradient(colors: [
                                  Color.fromRGBO(216, 6, 131, 1),
                                  Color.fromRGBO(99, 7, 114, 1)
                                ]),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                mobileNumber, // Set the educational details here
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  height: 1.5.h,
                                  fontWeight: FontWeight.bold,
                                  color: Colors
                                      .pink, // Set your desired text color
                                ),
                              ),
                            )),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Mail ID'.tr(),
                        style: GoogleFonts.montserrat(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(24, 25, 31, 1),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      height: 45.h,
                      width: 323.w,
                      decoration: BoxDecoration(
                        border: const GradientBoxBorder(
                          gradient: LinearGradient(colors: [
                            Color.fromRGBO(216, 6, 131, 1),
                            Color.fromRGBO(99, 7, 114, 1)
                          ]),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(11),
                        child: Text(
                          mail,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Date Of Birth'.tr(),
                        style: GoogleFonts.montserrat(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(24, 25, 31, 1),
                        )),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45.h,
                          width: 323.w,
                          decoration: BoxDecoration(
                            border: const GradientBoxBorder(
                              gradient: LinearGradient(colors: [
                                Color.fromRGBO(216, 6, 131, 1),
                                Color.fromRGBO(99, 7, 114, 1)
                              ]),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(11),
                            child: Text(
                              formattedBirthDate,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Education'.tr(),
                        style: GoogleFonts.montserrat(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(24, 25, 31, 1),
                        )),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    height: 45.h,
                    width: 323.w,
                    decoration: BoxDecoration(
                      border: const GradientBoxBorder(
                        gradient: LinearGradient(colors: [
                          Color.fromRGBO(216, 6, 131, 1),
                          Color.fromRGBO(99, 7, 114, 1)
                        ]),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        eduction,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Profession'.tr(),
                        style: GoogleFonts.montserrat(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(24, 25, 31, 1),
                        )),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    height: 45.h,
                    width: 323.w,
                    decoration: BoxDecoration(
                      border: const GradientBoxBorder(
                        gradient: LinearGradient(colors: [
                          Color.fromRGBO(216, 6, 131, 1),
                          Color.fromRGBO(99, 7, 114, 1)
                        ]),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          profession,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        )),
                  ),
                  const SizedBox(height: 10.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('City'.tr(),
                        style: GoogleFonts.montserrat(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(24, 25, 31, 1),
                        )),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    height: 45.h,
                    width: 323.w,
                    decoration: BoxDecoration(
                      border: const GradientBoxBorder(
                        gradient: LinearGradient(colors: [
                          Color.fromRGBO(216, 6, 131, 1),
                          Color.fromRGBO(99, 7, 114, 1)
                        ]),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        city,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Family Members'.tr(),
                        style: GoogleFonts.montserrat(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(24, 25, 31, 1),
                        )),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    height: 45.h,
                    width: 323.w,
                    decoration: BoxDecoration(
                      border: const GradientBoxBorder(
                        gradient: LinearGradient(colors: [
                          Color.fromRGBO(216, 6, 131, 1),
                          Color.fromRGBO(99, 7, 114, 1)
                        ]),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        familyMemebers,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('App Languages'.tr(),
                        style: GoogleFonts.montserrat(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(24, 25, 31, 1),
                        )),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    height: 45.h,
                    width: 323.w,
                    decoration: BoxDecoration(
                      border: const GradientBoxBorder(
                        gradient: LinearGradient(colors: [
                          Color.fromRGBO(216, 6, 131, 1),
                          Color.fromRGBO(99, 7, 114, 1)
                        ]),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        language,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 15.h),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Areas of Interests'.tr(),
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: const Color.fromRGBO(24, 25, 31, 1),
                          )),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Wrap(
                    spacing: 8.0, // Adjust spacing as needed
                    children: [
                      for (int i = 0; i < movies.length; i++) ...[
                        if (movies[i]
                            .isNotEmpty) // Check if the item is not empty
                          Container(
                            width: 90,
                            height: 25,
                            margin: const EdgeInsets.all(
                                8.0), // Adjust margin as needed
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.5,
                                color: const Color(0xFF630772),
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              child: Text(movies[i],
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 11.36.sp,
                                      color: Color.fromRGBO(61, 66, 96, 1))),
                            ),
                          ),
                      ],
                    ],
                  ),
                  Wrap(
                    spacing: 8.0, // Adjust spacing as needed
                    children: [
                      for (int i = 0; i < music.length; i++) ...[
                        if (music[i]
                            .isNotEmpty) // Check if the item is not empty
                          Container(
                            width: 90,
                            height: 25,
                            margin: const EdgeInsets.all(
                                8.0), // Adjust margin as needed
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.5,
                                color: const Color(0xFF630772),
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              child: Text(music[i],
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 11.36.sp,
                                      color: Color.fromRGBO(61, 66, 96, 1))),
                            ),
                          ),
                      ],
                    ],
                  ),
                  Wrap(
                    spacing: 8.0, // Adjust spacing as needed
                    children: [
                      for (int i = 0; i < books.length; i++) ...[
                        if (books[i]
                            .isNotEmpty) // Check if the item is not empty
                          Container(
                            width: 90,
                            height: 25,
                            margin: const EdgeInsets.all(
                                8.0), // Adjust margin as needed
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.5,
                                color: const Color(0xFF630772),
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              child: Text(books[i],
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 11.36.sp,
                                      color: Color.fromRGBO(61, 66, 96, 1))),
                            ),
                          ),
                      ],
                    ],
                  ),
                  Wrap(
                    spacing: 8.0, // Adjust spacing as needed
                    children: [
                      for (int i = 0; i < dance.length; i++) ...[
                        if (dance[i]
                            .isNotEmpty) // Check if the item is not empty
                          Container(
                            width: 90,
                            height: 25,
                            margin: const EdgeInsets.all(
                                8.0), // Adjust margin as needed
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.5,
                                color: const Color(0xFF630772),
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              child: Text(dance[i],
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 11.36.sp,
                                      color: Color.fromRGBO(61, 66, 96, 1))),
                            ),
                          ),
                      ],
                    ],
                  ),
                  Wrap(
                    spacing: 8.0, // Adjust spacing as needed
                    children: [
                      for (int i = 0; i < sports.length; i++) ...[
                        if (sports[i]
                            .isNotEmpty) // Check if the item is not empty
                          Container(
                            width: 90,
                            height: 25,
                            margin: const EdgeInsets.all(
                                8.0), // Adjust margin as needed
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.5,
                                color: const Color(0xFF630772),
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              child: Text(sports[i],
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 11.36.sp,
                                      color: Color.fromRGBO(61, 66, 96, 1))),
                            ),
                          ),
                      ],
                    ],
                  ),
                  Wrap(
                    spacing: 8.0, // Adjust spacing as needed
                    children: [
                      for (int i = 0; i < otherintrests.length; i++) ...[
                        if (otherintrests[i]
                            .isNotEmpty) // Check if the item is not empty
                          Container(
                            width: 90,
                            height: 25,
                            margin: const EdgeInsets.all(
                                8.0), // Adjust margin as needed
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.5,
                                color: const Color(0xFF630772),
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              child: Text(otherintrests[i],
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 11.36.sp,
                                      color: Color.fromRGBO(61, 66, 96, 1))),
                            ),
                          ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
