// ignore_for_file: use_key_in_widget_constructors

import 'package:Shepower/leneargradinent.dart';
import 'package:Shepower/weShare/MyThoughts.dart';
import 'package:Shepower/weShare/buddyThoughts.dart';
import 'package:Shepower/weShare/sendideas.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pay_now_one_screen/pay_now_one_screen.dart';

class WeSharescreen extends StatelessWidget {
  const WeSharescreen({Key? key});
  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context);
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 15.h,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      height: 50, // Adjust height as needed
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                            color: Color.fromARGB(255, 175, 216, 243),
                            width: 1),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 175, 216, 243),
                            Color.fromARGB(255, 247, 249, 249),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Center(
                        child: TextButton(
                          style: ButtonStyle(
                            overlayColor: MaterialStateColor.resolveWith(
                                (states) => Colors.pink.withOpacity(0.4)),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) {
                                return const MyThoughts();
                              },
                            ));
                          },
                          child: FittedBox(
                            child: Text("My_Thoughts".tr(),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.48.sp,
                                    color:
                                        const Color.fromRGBO(24, 25, 31, 1))),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                            color: Color.fromARGB(255, 175, 216, 243),
                            width: 1),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 175, 216, 243),
                            Color.fromARGB(255, 247, 249, 249),
                          ],
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                        ),
                      ),
                      child: Center(
                        child: TextButton(
                          style: ButtonStyle(
                            overlayColor: MaterialStateColor.resolveWith(
                                (states) => Colors.pink.withOpacity(0.10)),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) {
                                return const BuddyThoughts();
                              },
                            ));
                          },
                          child: FittedBox(
                            child: Text("buddy_thoughts".tr(),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.48.sp,
                                    color:
                                        const Color.fromRGBO(24, 25, 31, 1))),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                Text(
                  "share_today".tr(),
                  style: GoogleFonts.metrophobic(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.sp,
                    color: Color.fromRGBO(0, 0, 0, 1),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            Container(
              height: 190.h,
              width: double.maxFinite,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.brown),
                borderRadius: BorderRadius.circular(10.r),
                image: const DecorationImage(
                  image: AssetImage('assets/weshare.jpg'),
                  fit: BoxFit.cover, // Adjust as needed
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 20, top: 20),
                    //   child: RichText(
                    //     text: TextSpan(
                    //       style: GoogleFonts.montserrat(
                    //         fontWeight: FontWeight.w400,
                    //         fontSize: 19.19.sp,
                    //         color: const Color.fromRGBO(24, 25, 31, 1),
                    //       ),
                    //       children: [
                    //         TextSpan(
                    //             text: "Do_creative".tr(),
                    //             style: const TextStyle(color: Colors.white)),
                    //         TextSpan(
                    //           text: "idea".tr(),
                    //           style: TextStyle(
                    //             foreground: Paint()
                    //               ..shader = const LinearGradient(
                    //                 colors: [
                    //                   Colors.white,
                    //                   Color.fromRGBO(99, 6, 131, 1),
                    //                 ],
                    //                 begin: Alignment.topLeft,
                    //                 end: Alignment.bottomRight,
                    //               ).createShader(
                    //                   Rect.fromLTWH(0.0, 0.0, 200.0, 50.0)),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    Positioned(
                      bottom: 5,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, top: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: gradient,
                            borderRadius: BorderRadius.circular(9.59.r),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SendIdeas()));
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.transparent,
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9.59.r),
                              ),
                            ),
                            child: Text(
                              "Send_Ideas".tr(),
                              textAlign: TextAlign.start,
                              style: GoogleFonts.montserrat(
                                fontSize: 13.43.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromRGBO(255, 255, 255, 1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.h),
            Container(
              height: 190.h,
              width: double.maxFinite,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.brown),
                borderRadius: BorderRadius.circular(10.r),
                image: const DecorationImage(
                  image: AssetImage('assets/images/donate.jpg'),
                  fit: BoxFit.cover, // Adjust as needed
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 20, left: 8, right: 8, bottom: 20),
                child: Stack(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 20, top: 20),
                    //   child: RichText(
                    //     text: TextSpan(
                    //       style: GoogleFonts.montserrat(
                    //         fontWeight: FontWeight.w400,
                    //         fontSize: 19.19.sp,
                    //         color: const Color.fromRGBO(24, 25, 31, 1),
                    //       ),
                    //       children: [
                    //         TextSpan(text: "Contribute_create".tr()),
                    //         TextSpan(
                    //           text: "community".tr(),
                    //           style: TextStyle(
                    //             foreground: Paint()
                    //               ..shader = const LinearGradient(
                    //                 colors: [
                    //                   Color.fromRGBO(216, 6, 131, 1),
                    //                   Color.fromRGBO(99, 6, 131, 1),
                    //                 ],
                    //                 begin: Alignment.topLeft,
                    //                 end: Alignment.bottomRight,
                    //               ).createShader(
                    //                   Rect.fromLTWH(0.0, 0.0, 200.0, 50.0)),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    Positioned(
                      bottom: 0,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, top: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: gradient,
                            borderRadius: BorderRadius.circular(9.59.r),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PayNowOneScreen()));
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.transparent,
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9.59.r),
                              ),
                            ),
                            child: Text(
                              "share_funds".tr(),
                              textAlign: TextAlign.start,
                              style: GoogleFonts.montserrat(
                                fontSize: 13.43.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromRGBO(255, 255, 255, 1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100)
          ],
        ),
      ),
    ));
  }
}
