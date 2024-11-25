import 'dart:convert';

import 'package:Shepower/service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class MyThought {
  final String id; // The ID for the content
  final String content;

  MyThought({
    required this.id,
    required this.content,
  });
}

class MyThoughts extends StatefulWidget {
  const MyThoughts({super.key});

  @override
  State<MyThoughts> createState() => _MyThoughtsState();
}

class _MyThoughtsState extends State<MyThoughts> {
  List<MyThought> myThoughts = [];
  bool showMore = false;

  @override
  void initState() {
    super.initState();
    fetchIdeas();
  }

  Future<void> fetchIdeas() async {
    final storage = const FlutterSecureStorage();

    String? id = await storage.read(key: '_id');

    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}getMyShares'));
    request.body = json.encode({"user_id": id});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      Map<String, dynamic> data = json.decode(responseBody);

      List<dynamic> responseList = data['response'];
      setState(() {
        if (responseList.isEmpty) {
          myThoughts = [];
        } else {
          myThoughts = responseList
              .map((item) => MyThought(
                    id: item['_id'] as String,
                    content: item['description'] as String,
                  ))
              .toList();
        }
      });
    } else {
      print(response.reasonPhrase);
      print('Not fetched data');
    }
  }

  Future<void> deleteideas(String id) async {
    final storage = const FlutterSecureStorage();
    String? userId = await storage.read(key: '_id');

    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('DELETE', Uri.parse('${ApiConfig.baseUrl}deleteShare'));
    request.body = json.encode({"user_id": userId, "weshare_id": id});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      setState(() {
        myThoughts.removeWhere((thought) => thought.id == id);
      });
      print(await response.stream.bytesToString());
      print('Deleted Successfully');
    } else {
      print(response.reasonPhrase);
      print('Failed to delete the content: ${response.reasonPhrase}');
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
            'My_Thoughts'.tr(),
            style: TextStyle(
              color: const Color.fromRGBO(25, 41, 92, 1),
              fontFamily: 'Montserrat',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: myThoughts.isEmpty
            ? Center(
                child: Text(
                  'You didn\'t post anything',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 20.sp,
                    color: Color.fromRGBO(24, 25, 31, 1),
                  ),
                ),
              )
            : ListView.builder(
                itemCount: myThoughts.length,
                itemBuilder: (context, index) {
                  final thought = myThoughts[index];
                  return GestureDetector(
                    onLongPress: () {
                      showPlatformDialog(
                        context: context,
                        builder: (_) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          child: BasicDialogAlert(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 20.h,
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
                                        Icons.delete_forever,
                                        size: 48.0,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 16.w,
                                ),
                                const Center(
                                  child: Text(
                                    "Are you Sure delete ?",
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context)
                                            .pop(); // Cancel, go back to previous screen
                                      },
                                      child: Container(
                                        width: 100.w,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100.r),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Cancel',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        deleteideas(thought.id);
                                        Navigator.of(context)
                                            .pop(); // Delete, close the dialog
                                      },
                                      child: Container(
                                        width: 100.w,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100.r),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Delete',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        myThoughts[index]
                            .content, // Access the content property
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  );
                },
              ));
  }
}
