import 'dart:convert';

import 'package:Shepower/service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class AccountSettings extends StatefulWidget {
  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  bool isPublic = true;
  bool isPrivate = false;
  bool isConnected = false;

  init() async {
    var data = await GetMyProfile();
    setNotificationItem(data);
  }

  setNotificationItem(data) {
    setState(() {
      isPublic = data['public'] ?? true;
      isPrivate = data['private'] ?? false;
      isConnected = data['connected'] ?? false;
    });
  }

  Future<Map<String, dynamic>> GetMyProfile() async {
    // ignore: prefer_const_constructors
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
      print('Working fine$responseBody');

      Map<String, dynamic> data = json.decode(responseBody);
      return data['result'];
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  changeSettings(String notificationKey, bool value) async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };
      var request = http.Request(
          'POST', Uri.parse('${ApiConfig.baseUrl}securitySetting'));
      request.body = json.encode({"_id": id, notificationKey: value});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print('Working fine$responseBody');

        Map<String, dynamic> data = json.decode(responseBody);
        setNotificationItem(data['response']);
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    init();
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
        title: Text('account_setting'.tr(),
            style: GoogleFonts.montserrat(
                color: const Color.fromRGBO(25, 41, 92, 1),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow("Public", isPublic, (value) {
              changeSettings("public", value);
            }),
            _buildDivider(),
            _buildRow("Private", isPrivate, (value) {
              changeSettings("private", value);
            }),
            _buildDivider(),
            _buildRow("Connection", isConnected, (value) {
              changeSettings("connected", value);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String text, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              color: Color.fromRGBO(216, 6, 131, 1),
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 2,
      color: Colors.grey[700],
    );
  }
}
