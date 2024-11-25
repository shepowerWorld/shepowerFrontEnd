import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../Dashboard/Bottomnav.dart';

class Citylocation extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<Citylocation> {
  bool isLeaderTapped = false;
  bool isCitizenTapped = false;
  String? currentLocation;

  void toggleLeaderBorder() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      setState(() {
        isLeaderTapped = !isLeaderTapped;
      });

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      setState(() {
        currentLocation =
            'Lat: ${position.latitude}, Long: ${position.longitude}';
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Bottomnavscreen(),
        ),
      );
    } else {
      // Handle the case where the user denied location permission
      // You can show a message or take appropriate action
    }
  }

  void toggleCitizenBorder() {
    setState(() {
      isCitizenTapped = !isCitizenTapped;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 117.26.w),
              child: SizedBox(
                width: 147.89.w,
                height: 111.5.h,
                child: ClipRect(
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/Welcome/location1.png',
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        child: Image.asset(
                          'assets/Welcome/location.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 35.h,
            ),
            SizedBox(
              child: Text('Location'.tr(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(24, 32, 53, 1))),
            ),
            SizedBox(
              height: 20.h,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                    'Allow maps to access your\nlocation while you use the app?'
                        .tr(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(96, 98, 104, 1))),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 62.w, vertical: 20.h),
              child: GestureDetector(
                onTap: toggleLeaderBorder,
                child: Stack(
                  children: [
                    Container(
                      width: 250.w,
                      height: 44.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.7.r),
                        border: Border.all(
                          width: 1.5.w,
                          style: BorderStyle.solid,
                          color: isLeaderTapped
                              ? Colors.transparent
                              : Color(0xFFD80683),
                        ),
                        gradient: isLeaderTapped
                            ? const LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Color.fromRGBO(216, 6, 131, 1),
                                  Color.fromRGBO(99, 7, 114, 1),
                                ],
                              )
                            : null,
                      ),
                    ),
                    SizedBox(
                      width: 250.w,
                      height: 44.h,
                      child: ElevatedButton(
                        onPressed: () {
                          toggleLeaderBorder();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.transparent,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.7.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return isLeaderTapped // Check if the button is tapped
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
                                          Color.fromRGBO(216, 6, 131, 1),
                                          Color.fromRGBO(99, 7, 114, 1),
                                        ],
                                      ).createShader(bounds);
                              },
                              child: Text("Allow".tr(),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromRGBO(255, 255, 255, 1))),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 62.w,
              ),
              child: GestureDetector(
                onTap: toggleCitizenBorder,
                child: Stack(
                  children: [
                    Container(
                      width: 250.w,
                      height: 44.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.7.r),
                        border: Border.all(
                          width: 1.5.w,
                          style: BorderStyle.solid,
                          color: isCitizenTapped
                              ? Colors.transparent
                              : Color(0xFFD80683),
                        ),
                        gradient: isCitizenTapped
                            ? const LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Color.fromRGBO(216, 6, 131, 1),
                                  Color.fromRGBO(99, 7, 114, 1),
                                ],
                              )
                            : null,
                      ),
                    ),
                    SizedBox(
                      width: 250.w,
                      height: 44.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => Bottomnavscreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.transparent,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.7.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return isCitizenTapped // Check if the button is tapped
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
                                          Color.fromRGBO(216, 6, 131, 1),
                                          Color.fromRGBO(99, 7, 114, 1),
                                        ],
                                      ).createShader(bounds);
                              },
                              child: Text("Skip for now".tr(),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromRGBO(255, 255, 255, 1))),
                            ),
                          ],
                        ),
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
}
