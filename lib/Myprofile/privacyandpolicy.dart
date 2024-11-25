import 'dart:convert';

import 'package:Shepower/service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class PrivacyAndPOlicy extends StatefulWidget {
  @override
  _PrivacyAndPOlicyState createState() => _PrivacyAndPOlicyState();
}

class _PrivacyAndPOlicyState extends State<PrivacyAndPOlicy> {
  List<String> privacyandpolicy = [];

  @override
  void initState() {
    super.initState();
    privacyandpolicy1();
  }

  Future<void> privacyandpolicy1() async {
    final storage = FlutterSecureStorage();
    String? accesstoken = await storage.read(key: 'accessToken');

    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };
      var request =
          http.Request('GET', Uri.parse('${ApiConfig.baseUrl}getAllPAP'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print('Working fine$responseBody');

        Map<String, dynamic> data = json.decode(responseBody);

        if (data['result'] is List) {
          var languages = data['result'] as List;
          languages.forEach((lang) {
            setState(() {
              privacyandpolicy.add(lang['text']);
            });
            print('Language: ${lang['languages']}');
          });
        } else {
          print(response.reasonPhrase);
          throw Exception('Failed to fetch data');
        }
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [
                  Color.fromRGBO(216, 6, 163, 1),
                  Color.fromRGBO(99, 7, 114, 1),
                ],
              ).createShader(bounds);
            },
            child: Container(
              height: 30.h,
              width: 30.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  width: 1.5.w,
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
        title: Text(
          'Privacy Policy'.tr(),
          style: GoogleFonts.montserrat(
            color: const Color.fromRGBO(25, 41, 92, 1),
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: privacyandpolicy.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Text(
                  privacyandpolicy[index],
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
