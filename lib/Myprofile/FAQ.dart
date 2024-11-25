import 'dart:convert';

import 'package:Shepower/service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class FAQScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  List<Map<String, dynamic>> faqs = [];
  int activeIndex = -1;

  @override
  void initState() {
    super.initState();
    fetchFAQs();
  }

  Future<void> fetchFAQs() async {
    final storage = FlutterSecureStorage();
    String? accesstoken = await storage.read(key: 'accessToken');

    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };
      var request =
          http.Request('GET', Uri.parse('${ApiConfig.baseUrl}getAllFAQ'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();

        final faqData = json.decode(responseBody);
        print("kkkkkk $faqData");
        setState(() {
          for (var item in faqData['FAQ']) {
            faqs.add(item);
          }
        });
      } else {
        print('Failed to fetch FAQs. Status Code: ${response.statusCode}');
        print('Reason: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('vvvv---$error');
      print('Error fetching FAQs: $error');
    }
  }

  void toggleAnswer(int index) {
    setState(() {
      activeIndex = (activeIndex == index) ? -1 : index;
    });
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
          'FAQ’s'.tr(),
          style: GoogleFonts.montserrat(
            color: const Color.fromRGBO(25, 41, 92, 1),
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: faqs.length,
          itemBuilder: (context, index) {
            final faq = faqs[index];
            return FAQItem(
              question: faq['Question'],
              answer: faq['Answer'],
              isActive: activeIndex == index,
              onTap: () => toggleAnswer(index),
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;
  final bool isActive;
  final VoidCallback onTap;

  FAQItem({
    required this.question,
    required this.answer,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: isActive ? 200 : 100,
        child: Card(
          elevation: isActive ? 5 : 2,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: Color.fromARGB(255, 237, 233, 234),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        question,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.purple : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Icon(
                      isActive
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 24,
                      color: isActive ? Colors.purple : Colors.black,
                    ),
                  ],
                ),
                if (isActive)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      answer,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.teal,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
