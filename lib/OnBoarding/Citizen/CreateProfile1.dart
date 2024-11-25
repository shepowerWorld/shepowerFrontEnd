import 'dart:convert';

import 'package:Shepower/Events/place.model.dart';
import 'package:Shepower/OnBoarding/Citizen/location1.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:http/http.dart' as http;

import '../../Events/createeven.services.dart';
import '../../common/common_dialog.dart';
import '../../leneargradinent.dart';
import '../../service.dart';

class CitizenProfile extends StatefulWidget {
  @override
  _CreateProfile createState() => _CreateProfile();
}

class _CreateProfile extends State<CitizenProfile> {
  List<String> languagesList = [];
  String? selectedLanguage;
  DateTime? selectedDate;
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController professionController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController membersController = TextEditingController();
  // final TextEditingController languageController = TextEditingController();
  final TextEditingController familyMembercontroller = TextEditingController();
  List<Predictions> predictions = [];
  int selectedNumber = 0;

  String? selectedAddress;
  final secureStorage = const FlutterSecureStorage();

  String? abouttext;
  String? itseasyText;

  @override
  void initState() {
    super.initState();
    getStoredParameters();
    fetchLanguages();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dobController.text = DateFormat.yMMMd().format(picked);
      });
    }
  }

  Future<Map<String, String?>> getStoredParameters() async {
    const storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    return {
      'id': id,
      'Authorization': accesstoken,
    };
  }

  Future<void> createProfile() async {
    String firstName = firstnameController.text;
    String lastName = lastnameController.text;
    String email = emailController.text;
    String dob = dobController.text;
    String education = educationController.text;
    String profession = professionController.text;
    String city = cityController.text;
    String familymembers = familyMembercontroller.text;

    // Check if any of the fields are empty
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        dob.isEmpty ||
        education.isEmpty ||
        profession.isEmpty ||
        city.isEmpty) {
      showSErrorDialog(
        context,
        "Please Fill All Details",
      );
      return;
    }
    try {
      final storage = FlutterSecureStorage();
      String? id = await storage.read(key: '_id');
      String? accesstoken = await storage.read(key: 'accessToken');

      if (id == null || accesstoken == null) {
        print('ID and/or Authorization not found in secure storage.');
        return;
      }

      final jsonData = {
        "_id": id,
        "lastname": lastName,
        "firstname": firstName,
        "email": email,
        "dob": dob,
        "education": education,
        "proffession": profession,
        "familymembers": [familymembers],
        "languages": [selectedLanguage],
        "movies": ["", ""],
        "music": ["", ""],
        "books": ["", ""],
        "dance": ["", ""],
        "sports": ["", ""],
        "otherintrests": ["", ""],
        "location": city
      };
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}createProfileCitizen'),
        headers: headers,
        body: json.encode(jsonData),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        await secureStorage.write(
            key: 'ProfileCreate', value: json.encode(responseData));
        String? customer_id = responseData['response']['customer_Id'];

        await secureStorage.write(key: 'customer_id', value: customer_id);
        await secureStorage.write(key: 'email', value: email);
        print('Profile created successfully');
        print('Response Data: $responseData');

        showSuccessDialog(
          context,
          "Your Profile created successfully.",
        );
      } else {
        print('Failed to create profile: ${response.reasonPhrase}');
        print('Error Response: ${response.body}');
      }
    } catch (e) {
      print('Error during API request: $e');
      // Handle other exceptions (e.g., network errors)
    }
  }

  void showSuccessDialog(BuildContext context, String message) {
    CommonDialog.showSuccessDialog(context, message, navitoFace);
  }

  void showSErrorDialog(BuildContext context, String message) {
    CommonDialog.errormessagemodel(context, message);
  }

  void navitoFace() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Citywelcome(),
      ),
    );
  }

  Future<void> fetchLanguages() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };
      var request =
          http.Request('GET', Uri.parse('${ApiConfig.baseUrl}getLanguages'));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print('objnvhfect');
        final responseBody = await response.stream.bytesToString();
        Map<String, dynamic> data = json.decode(responseBody);

        if (data['result'] is List) {
          var languages = (data['result'] as List);
          languages.forEach((lang) {
            setState(() {
              languagesList.add(lang['languages']);
            });
            print('Language: ${lang['languages']}');
          });
        } else {
          print(response.reasonPhrase);
          throw Exception('Failed to fetch data');
        }
      } else {
        print(response.reasonPhrase);
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15.w, top: 40.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Let me know more about you...'.tr(),
                            style: GoogleFonts.montserrat(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color.fromRGBO(24, 25, 31, 1),
                            )),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child:
                            Text('Its easy, just fill the details below'.tr(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color.fromRGBO(24, 25, 31, 1),
                                )),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Name'.tr(),
                            style: GoogleFonts.montserrat(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color.fromRGBO(24, 25, 31, 1))),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: SizedBox(
                              height: 45.h,
                              width: 192.w,
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'first Name',
                                  hintStyle: GoogleFonts.nunitoSans(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400),
                                  counterText: '',
                                  border: GradientOutlineInputBorder(
                                    gradient: const LinearGradient(colors: [
                                      Color.fromRGBO(216, 6, 131, 1),
                                      Color.fromRGBO(99, 7, 114, 1),
                                    ]),
                                    width: 1.w,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  focusedBorder: GradientOutlineInputBorder(
                                      gradient: const LinearGradient(colors: [
                                        Color.fromRGBO(216, 6, 131, 1),
                                        Color.fromRGBO(99, 7, 114, 1),
                                      ]),
                                      width: 1.w),
                                  contentPadding:
                                      const EdgeInsets.only(left: 20),
                                ),
                                controller: firstnameController,
                                keyboardType: TextInputType.text,
                                cursorColor: const Color.fromARGB(162, 0, 0, 0),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 11.w, vertical: 8.h),
                            child: SizedBox(
                              height: 45.h,
                              width: 114.w,
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'last name ',
                                  hintStyle: GoogleFonts.nunitoSans(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400),
                                  counterText: '',
                                  border: GradientOutlineInputBorder(
                                    gradient: const LinearGradient(colors: [
                                      Color.fromRGBO(216, 6, 131, 1),
                                      Color.fromRGBO(99, 7, 114, 1),
                                    ]),
                                    width: 1.w,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  focusedBorder: GradientOutlineInputBorder(
                                    gradient: const LinearGradient(colors: [
                                      Color.fromRGBO(216, 6, 131, 1),
                                      Color.fromRGBO(99, 7, 114, 1),
                                    ]),
                                    width: 1.w,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.only(left: 20),
                                ),
                                controller: lastnameController,
                                keyboardType: TextInputType.text,
                                cursorColor: const Color.fromRGBO(0, 0, 0, 1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Mail ID'.tr(),
                            style: GoogleFonts.montserrat(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color.fromRGBO(24, 25, 31, 1))),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
                      child: SizedBox(
                        height: 48.h,
                        width: 328.w,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'enter your mail ID ',
                            hintStyle: GoogleFonts.nunitoSans(
                                fontSize: 16.sp, fontWeight: FontWeight.w400),
                            counterText: '',
                            border: GradientOutlineInputBorder(
                              gradient: const LinearGradient(colors: [
                                Color.fromRGBO(216, 6, 131, 1),
                                Color.fromRGBO(99, 7, 114, 1),
                              ]),
                              width: 1.w,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            focusedBorder: GradientOutlineInputBorder(
                              gradient: const LinearGradient(colors: [
                                Color.fromRGBO(216, 6, 131, 1),
                                Color.fromRGBO(99, 7, 114, 1),
                              ]),
                              width: 1.w,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            contentPadding: const EdgeInsets.only(left: 20),
                          ),
                          controller: emailController,
                          keyboardType: TextInputType.text,
                          cursorColor: Color.fromARGB(255, 194, 97, 97),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Date Of Birth'.tr(),
                            style: GoogleFonts.montserrat(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color.fromRGBO(0, 0, 0, 1))),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 45.h,
                              width: 328.w,
                              child: TextFormField(
                                readOnly: true,
                                onTap: () => _selectDate(context),
                                decoration: InputDecoration(
                                  hintText: 'Enter your date of birth',
                                  hintStyle: GoogleFonts.nunitoSans(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400),
                                  counterText: '',
                                  border: GradientOutlineInputBorder(
                                    gradient: const LinearGradient(colors: [
                                      Color.fromRGBO(216, 6, 131, 1),
                                      Color.fromRGBO(99, 7, 114, 1),
                                    ]),
                                    width: 1.w,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  focusedBorder: GradientOutlineInputBorder(
                                    gradient: const LinearGradient(colors: [
                                      Color.fromRGBO(216, 6, 131, 1),
                                      Color.fromRGBO(99, 7, 114, 1),
                                    ]),
                                    width: 1.w,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                      left: 20.w), // Adjust the values
                                  suffixIcon: Icon(
                                    Icons.edit_calendar_outlined,
                                    color: Color(0xFF630772),
                                  ),
                                  // Use Alignment to center the hint text vertically
                                  alignLabelWithHint: true,
                                ),
                                controller: dobController,
                                keyboardType: TextInputType.phone,
                                cursorColor: const Color.fromARGB(0, 0, 0, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Education'.tr(),
                            style: GoogleFonts.montserrat(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color.fromRGBO(24, 25, 31, 1))),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
                      child: SizedBox(
                        height: 45.h,
                        width: 323.w,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'enter your educational details',
                            hintStyle: GoogleFonts.nunitoSans(
                                fontSize: 16.sp, fontWeight: FontWeight.w400),
                            counterText: '',
                            border: GradientOutlineInputBorder(
                              gradient: const LinearGradient(colors: [
                                Color.fromRGBO(216, 6, 131, 1),
                                Color.fromRGBO(99, 7, 114, 1),
                              ]),
                              width: 1.w,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            focusedBorder: GradientOutlineInputBorder(
                              gradient: const LinearGradient(colors: [
                                Color.fromRGBO(216, 6, 131, 1),
                                Color.fromRGBO(99, 7, 114, 1),
                              ]),
                              width: 1.w,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            contentPadding: const EdgeInsets.only(left: 20),
                          ),
                          controller: educationController,
                          keyboardType: TextInputType.text,
                          cursorColor: const Color.fromRGBO(0, 0, 0, 1),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Profession'.tr(),
                            style: GoogleFonts.montserrat(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color.fromRGBO(24, 25, 31, 1))),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
                      child: SizedBox(
                        height: 45.h,
                        width: 323.w,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'enter your profession details',
                            hintStyle: GoogleFonts.nunitoSans(
                                fontSize: 16.sp, fontWeight: FontWeight.w400),
                            counterText: '',
                            border: GradientOutlineInputBorder(
                              gradient: const LinearGradient(colors: [
                                Color.fromRGBO(216, 6, 131, 1),
                                Color.fromRGBO(99, 7, 114, 1),
                              ]),
                              width: 1.w,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            focusedBorder: GradientOutlineInputBorder(
                              gradient: const LinearGradient(colors: [
                                Color.fromRGBO(216, 6, 131, 1),
                                Color.fromRGBO(99, 7, 114, 1),
                              ]),
                              width: 1.w,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            contentPadding: const EdgeInsets.only(left: 20),
                          ),
                          controller: professionController,
                          keyboardType: TextInputType.text,
                          cursorColor: const Color.fromRGBO(0, 0, 0, 1),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16.w),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'City'.tr(),
                              style: GoogleFonts.montserrat(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color.fromRGBO(24, 25, 31, 1),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 11.w, vertical: 8.h),
                          child: SizedBox(
                            height: 45.h,
                            width: 323.w,
                            child: TypeAheadField<Predictions>(
                              textFieldConfiguration: TextFieldConfiguration(
                                decoration: InputDecoration(
                                  hintText: 'City you live in',
                                  hintStyle: GoogleFonts.nunitoSans(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  counterText: '',
                                  border: GradientOutlineInputBorder(
                                    gradient: const LinearGradient(colors: [
                                      Color.fromRGBO(216, 6, 131, 1),
                                      Color.fromRGBO(99, 7, 114, 1),
                                    ]),
                                    width: 1.w,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  focusedBorder: GradientOutlineInputBorder(
                                    gradient: const LinearGradient(colors: [
                                      Color.fromRGBO(216, 6, 131, 1),
                                      Color.fromRGBO(99, 7, 114, 1),
                                    ]),
                                    width: 1.w,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.only(left: 20),
                                ),
                                controller: cityController,
                                keyboardType: TextInputType.text,
                                cursorColor: const Color.fromRGBO(0, 0, 0, 1),
                              ),
                              suggestionsCallback: (pattern) async {
                                print('Searching for $pattern');
                                return await EventService().getPlaces(pattern);
                              },
                              itemBuilder: (context, suggestion) {
                                return ListTile(
                                  title: Text(suggestion.description ?? "-"),
                                );
                              },
                              onSuggestionSelected: (suggestion) {
                                setState(() {
                                  cityController.text =
                                      suggestion.description ?? "";
                                  print(cityController
                                      .text); // Print the selected value for debugging
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Family Members'.tr(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color.fromRGBO(24, 25, 31, 1),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                      child: SizedBox(
                        height: 45.h,
                        width: 323.w,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'add family members',
                                  hintStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  counterText: '',
                                  border: GradientOutlineInputBorder(
                                    gradient: const LinearGradient(colors: [
                                      Color.fromRGBO(216, 6, 131, 1),
                                      Color.fromRGBO(99, 7, 114, 1),
                                    ]),
                                    width: 1,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: GradientOutlineInputBorder(
                                    gradient: const LinearGradient(colors: [
                                      Color.fromRGBO(216, 6, 131, 1),
                                      Color.fromRGBO(99, 7, 114, 1),
                                    ]),
                                    width: 1,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.only(left: 20),
                                  suffixIcon: PopupMenuButton<int>(
                                    icon: Icon(Icons.arrow_drop_down),
                                    itemBuilder: (context) {
                                      return List.generate(11, (index) {
                                        return PopupMenuItem<int>(
                                          value: index,
                                          child: Text(index.toString()),
                                        );
                                      });
                                    },
                                    onSelected: (value) {
                                      setState(() {
                                        selectedNumber = value;
                                        // Use the selectedNumber value as needed
                                        // For example, you can update the TextField with this value
                                        familyMembercontroller.text =
                                            value.toString();
                                      });
                                    },
                                  ),
                                ),
                                controller: familyMembercontroller,
                                keyboardType: TextInputType.text,
                                cursorColor: const Color.fromRGBO(0, 0, 0, 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'App Languages'.tr(),
                          style: GoogleFonts.montserrat(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color.fromRGBO(24, 25, 31, 1),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: GestureDetector(
                        onTap: () {
                          _openModalDialog(
                            context,
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              height: 45.h,
                              width: 323.w,
                              padding: EdgeInsets.only(left: 20.w, top: 10.h),
                              decoration: BoxDecoration(
                                border: GradientBoxBorder(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromRGBO(216, 6, 131, 1),
                                      Color.fromRGBO(99, 7, 114, 1),
                                    ],
                                  ),
                                  width: 1.w,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  selectedLanguage ??
                                      'Select Language', // Provide a default value if selectedLanguage is null
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(72, 0, 72, 15),
          child: SizedBox(
            width: 215.9.w, // Set your desired width
            height: 40.13.h, // Set your desired height
            child: Container(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(10.56.r),
              ),
              child: ElevatedButton(
                  onPressed: () {
                    createProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.56.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Let’s Go".tr(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                            fontSize: 21.sp,
                            fontWeight: FontWeight.w800,
                            color: Color.fromRGBO(255, 255, 255, 1)),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Color.fromRGBO(255, 255, 255, 1),
                        size: 30.sp,
                      )
                    ],
                  )),
            ),
          )),
    );
  }

  Map<String, String> languageCodeMapping = {
    'Arabic': 'ar',
    'Bengali': 'bn',
    'Belarusian': 'be',
    'Gujarati': 'gu',
    'Kannada': 'kn',
    'Maithili': 'mai',
    'Odia': 'or',
    'Meitei': 'mni',
    'Tamil': 'ta',
    'Telugu': 'te',
    'Marathi': 'mr',
    'Hindi': 'hi',
    'Assamese': 'as',
    'Malayalam': 'ml',
    'English': 'en',
    'Tibetic': 'bo'
  };

  void _openModalDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Choose the App Language'),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: Colors.grey),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: languagesList.map((String languageName) {
                          return ListTile(
                            title: Text(languageName),
                            onTap: () {
                              String? languageCode =
                                  languageCodeMapping[languageName];
                              if (languageCode != null) {
                                context.setLocale(Locale(languageCode));
                                setState(() {
                                  selectedLanguage = languageName;
                                  // languageController.text = languageName;
                                });
                              }
                              print('languageCode$languageCode');

                              Navigator.of(context).pop();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Colors.grey),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class Citywelcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/explore/welcome.jpg',
            fit: BoxFit.fill,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 95.h),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color.fromRGBO(217, 217, 217, 1),
                            Color.fromRGBO(216, 6, 131, 1),
                            Color.fromRGBO(99, 7, 114, 1),
                            Color.fromRGBO(217, 217, 217, 0),
                          ],
                        ).createShader(bounds);
                      },
                      child: Text("That's all".tr(),
                          textAlign: TextAlign.start,
                          style: GoogleFonts.montserrat(
                              fontSize: 39.67.sp,
                              fontWeight: FontWeight.w600,
                              color: Color.fromRGBO(255, 255, 255, 1))),
                    ),
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color.fromRGBO(217, 217, 217, 1),
                            Color.fromRGBO(216, 6, 131, 1),
                            Color.fromRGBO(99, 7, 114, 1),
                            Color.fromRGBO(217, 217, 217, 0),
                          ],
                        ).createShader(bounds);
                      },
                      child: Text("you’re In...".tr(),
                          textAlign: TextAlign.start,
                          style: GoogleFonts.montserrat(
                              fontSize: 39.67.sp,
                              fontWeight: FontWeight.w600,
                              color: Color.fromRGBO(255, 255, 255, 1))),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 70, // Adjust the height from the bottom
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Container(
                width: 250.9.w,
                height: 40.13.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(216, 6, 131, 1),
                      Color.fromRGBO(99, 7, 114, 1)
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10.56.r),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => Citylocation()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.56.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        child: Text(
                          "Start the adventure now".tr(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: Color.fromRGBO(255, 255, 255, 1)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
