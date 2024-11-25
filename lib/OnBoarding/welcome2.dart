import 'package:Shepower/OnBoarding/users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil
    ScreenUtil.init(context, designSize: Size(414, 896));

    // Get screen width and height
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.17,
                  vertical: screenHeight * 0.011,
                ),
                child: Image.asset(
                  'assets/Splash/shepower.png',
                ),
              ),
              SizedBox(
                  height: screenHeight * 0.011),
              Text(
                'Join and\nparticipate',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: ScreenUtil().setSp(30),
                  fontWeight: FontWeight.w800,
                  color: Color.fromRGBO(24, 25, 31, 1),
                ),
              ),
              SizedBox(
                  height: screenHeight * 0.007),
              Text(
                'in empowering events and\nactivities..',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: ScreenUtil().setSp(21),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 23.sp, vertical: 16.sp),
        child: SizedBox(
          height: 50.72.h,
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(216, 6, 131, 1),
                  Color.fromRGBO(99, 7, 114, 1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(15.36.r),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => UserScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.36.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Get Started",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w800,
                      fontSize: 21.sp,
                      color: Color.fromRGBO(255, 255, 255, 1),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color.fromRGBO(255, 255, 255, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
