import 'dart:convert';

import 'package:Shepower/service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class AllThought {
  final String content;

  AllThought({
    required this.content,
  });
}

class BuddyThoughts extends StatefulWidget {
  const BuddyThoughts({super.key});

  @override
  State<BuddyThoughts> createState() => _BuddyThoughtsState();
}

class _BuddyThoughtsState extends State<BuddyThoughts> {
  List<AllThought> allThoughts = [];
  bool showMore = false;

  @override
  void initState() {
    super.initState();
    getallThoughts();
  }

  Future<void> getallThoughts() async {
    const storage = FlutterSecureStorage();

    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}getAllShare'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      Map<String, dynamic> data = json.decode(responseBody);

      List<dynamic> responseList = data['response'];
      setState(() {
        allThoughts = responseList
            .map((item) => AllThought(
                  content: item['description'] as String,
                ))
            .toList();
      });
    } else {
      print(response.reasonPhrase);
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
            'buddy_thoughts'.tr(),
            style: TextStyle(
              color: const Color.fromRGBO(25, 41, 92, 1),
              fontFamily: 'Montserrat',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: ListView.builder(
          itemCount: allThoughts.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                allThoughts[index].content,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                ),
              ),
            );
          },
        ));
  }
}
