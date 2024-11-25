import 'package:Shepower/OnBoarding/welcome2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'users.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int currentScreen = 0;
  bool allScreensCompleted = false;

  List<String> imagePaths = [
    'assets/Splash/shepower.png',
    'assets/Splash/shepower.png',
    'assets/Splash/shepower.png',
  ];

  List<String> screenTexts = [
    'Empowering Women Nationdwide . . . ',
    'Discover &Connect',
    'Seek and offer  help within the community . . . ',
  ];

  void goToNextScreen() {
    setState(() {
      if (currentScreen < screenTexts.length - 1) {
        currentScreen++;
      } else {
        allScreensCompleted = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return WillPopScope(
        child: Scaffold(
          body: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50.h,
                    ),
                    SizedBox(
                      width: 230.4.w,
                      height: 249.6.h,
                      child: Image.asset(imagePaths[currentScreen],
                          alignment: Alignment.center),
                    ),
                    SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            30.72, 23.04, 30.72, 23.04),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                screenTexts[currentScreen],
                                textAlign: TextAlign.start,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.56.sp,
                                  height: 1.5.h,
                                  color: const Color.fromRGBO(24, 25, 31, 1),
                                ),
                              ),
                              SizedBox(
                                height: 5.36.h,
                              ),
                              // Extra text when currentScreen is 1
                              if (currentScreen == 1)
                                Text(
                                  'with influential women leaders near you...',
                                  textAlign: TextAlign.start,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.56.sp,
                                    height: 1.5.h,
                                    color: const Color.fromRGBO(24, 25, 31, 1),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              // Show the "Skip" button only on the first screen
              Positioned(
                top: 40.sp, // Adjust the top position as needed
                right: 16.sp, // Adjust the right position as needed
                child: SizedBox(
                  width: 79.4.w,
                  height: 24.72.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserScreen(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.black),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.36.sp),
                          side: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.symmetric(horizontal: 29.sp, vertical: 16.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (int i = 0; i < screenTexts.length; i++)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            currentScreen = i;
                          });
                        },
                        child: Container(
                          width: currentScreen == i ? 49 : 15,
                          height: 15,
                          decoration: BoxDecoration(
                            gradient: currentScreen == i
                                ? const LinearGradient(
                                    colors: [
                                      Color.fromRGBO(206, 6, 129, 1),
                                      Color.fromRGBO(101, 7, 114, 1),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(12.48.r),
                            border: Border.all(
                                color: Color.fromRGBO(24, 25, 31, 1)),
                            color: currentScreen == i
                                ? null
                                : Color.fromRGBO(255, 255, 255, 1),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                      ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    if (currentScreen < screenTexts.length - 1) {
                      setState(() {
                        currentScreen++;
                      });
                    } else {
                      // Handle navigation to next screen when all screens completed
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WelcomeScreen1(),
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromRGBO(206, 6, 129, 1),
                          Color.fromRGBO(125, 6, 118, 1)
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    width: 28.8.w,
                    height: 28.8.h,
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          if (currentScreen > 0) {
            // Navigate to the previous screen
            setState(() {
              currentScreen--;
            });
            return false; // Prevent the default back button behavior
          } else {
            return true; // Allow the back button press (close the app)
          }
        });
  }
}
