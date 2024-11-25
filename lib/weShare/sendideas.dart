import 'dart:convert';

import 'package:Shepower/service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class SendIdeas extends StatefulWidget {
  const SendIdeas({super.key});

  @override
  State<SendIdeas> createState() => _SendIdeasState();
}

class _SendIdeasState extends State<SendIdeas> {
  bool isTyping = false;
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future<void> SendIdeas() async {
    final storage = const FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    String text = textController.text;
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}createShare'));
    request.body = json.encode({"user_id": id, "description": text});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      Navigator.of(context).pop();
    } else {
      print(response.reasonPhrase);
    }
  }

  void myThoughtscreated() {
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
                    color: Colors.green),
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
                  "My Thoughts Created Succesfully",
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
                  SendIdeas();
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
        title: Text('Send_Ideas'.tr(),
            style: GoogleFonts.montserrat(
                color: const Color.fromRGBO(25, 41, 92, 1),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 10.h,
              ),
              Container(
                width: 328.w,
                height: 491.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.39.r),
                  border: Border.all(
                      color: Colors.blueGrey), // Customize the border style
                  color: const Color.fromRGBO(241, 244, 245, 1),
                ),
                child: TextField(
                  showCursor: true,
                  controller: textController,
                  onChanged: (text) {
                    setState(() {
                      isTyping = text.isNotEmpty;
                    });
                  },
                  maxLines: null, // Allow the TextField to expand vertically
                  minLines: 3, // Minimum lines to display
                  decoration: InputDecoration(
                    hintText: 'Describe the idea....',
                    hintStyle: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      color: const Color.fromRGBO(83, 87, 103, 0.5),
                    ),
                    contentPadding: EdgeInsets.all(10.0),
                    isDense: true, // Reduces the height of the input field
                    border: InputBorder.none, // Remove the border
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              GestureDetector(
                child: Stack(
                  children: [
                    Container(
                      width: 215.9.w,
                      height: 40.13.h,
                      padding: EdgeInsets.symmetric(horizontal: 72.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.56.r),
                        color: Color.fromRGBO(221, 213, 217, 1),
                        gradient: isTyping
                            ? const LinearGradient(
                                colors: [
                                  Color.fromRGBO(216, 6, 131, 1),
                                  Color.fromRGBO(99, 7, 114, 1),
                                ],
                              )
                            : null,
                      ),
                    ),
                    SizedBox(
                      child: FittedBox(
                        child: Container(
                          height: 40.13.h,
                          child: ElevatedButton(
                              onPressed: () {
                                myThoughtscreated();
                              },
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.transparent,
                                  backgroundColor: Colors.transparent,
                                  elevation: 0.0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.56.r))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return isTyping
                                          ? const LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Color.fromRGBO(255, 255, 255,
                                                    1), // Change text color to white
                                                Color.fromRGBO(255, 255, 255,
                                                    1), // Change text color to white
                                              ],
                                            ).createShader(bounds)
                                          : const LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Color.fromRGBO(255, 255, 255,
                                                    1), // Change text color to white
                                                Color.fromRGBO(255, 255, 255,
                                                    1), // Change text color to white
                                              ],
                                            ).createShader(bounds);
                                    },
                                    child: Text("Send_Ideas".tr(),
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromRGBO(
                                                255, 255, 255, 1))),
                                  )
                                ],
                              )),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
