import 'package:Shepower/OnBoarding/Leader/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Citizen/Login1.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool isLeaderTapped = false;
  bool isCitizenTapped = false;

  void toggleLeaderBorder() {
    setState(() {
      isLeaderTapped = !isLeaderTapped;
    });

    if (isLeaderTapped) {
      showLeaderSuccessDialog(context);
    }
  }

  void toggleCitizenBorder() {
    setState(() {
      isCitizenTapped = !isCitizenTapped;
    });
    if (isCitizenTapped) {
      showCitizenSuccessDialog(context);
    }
  }

  void showLeaderSuccessDialog(BuildContext context) {
    showPlatformDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: Container(
          height: 270,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.pink, Colors.purple],
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30.0),
              const Text(
                "Welcome to your world of women...lead every woman here to feel safe, heard, and understood",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30.0),
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const Login(),
                      ),
                    );
                  },
                  child: Container(
                      height: 30,
                      width: 40,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Center(
                        child: Text(
                          'Ok',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showCitizenSuccessDialog(BuildContext context) {
    showPlatformDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: Container(
          height: 270,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.pink, Colors.purple],
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30.0),
              const Text(
                "Welcome to a safe world run by women and for women",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30.0),
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const Login1(),
                      ),
                    );
                  },
                  child: Container(
                      height: 30,
                      width: 40,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Center(
                        child: Text(
                          'Ok',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      )),
                ),
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
      body: SizedBox(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 289.32.w,
                height: 235.01.h,
                child: Image.asset('assets/Splash/shepower.png'),
              ),
              SizedBox(
                height: 7.37.h,
              ),

              SizedBox(
                height: 16.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: EdgeInsets.only(left: 16.w)),
                  Text('Enter “She Power” as',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        color: Color.fromRGBO(18, 13, 38, 1),
                      )),
                ],
              ),
              SizedBox(
                height: 21.h,
              ),

              // Citizen Button
              SizedBox(
                child: GestureDetector(
                  onTap: toggleCitizenBorder,
                  child: Stack(
                    children: [
                      Container(
                        width: 327.w,
                        height: 48.h,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            width: 1.w,
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
                        width: 327.w,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: () {
                            toggleCitizenBorder();
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.transparent,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
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
                                child: Text("Citizen",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                        fontSize: 21.sp,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Color.fromRGBO(255, 255, 255, 1))),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: 33.h,
              ),
              // Leader Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: GestureDetector(
                  onTap: toggleLeaderBorder,
                  child: Stack(
                    children: [
                      Container(
                        width: 327.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            width: 1.w,
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
                        width: 327.w,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: () {
                            toggleLeaderBorder();
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.transparent,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
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
                                                1), // Change text color
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
                                child: Text("Leader",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 21.sp,
                                        color:
                                            Color.fromRGBO(255, 255, 255, 1))),
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
      ),
    );
  }
}
