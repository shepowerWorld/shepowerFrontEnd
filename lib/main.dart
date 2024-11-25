import 'dart:async';

import 'package:Shepower/BoLocalizations.dart';
import 'package:Shepower/Notification.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'Myprofile/EditProfile.dart';
import 'Myprofile/Profilesetting.dart';
import 'OnBoarding/Citizen/CreateProfile1.dart';
import 'OnBoarding/Citizen/FaceDetect1.dart';
import 'OnBoarding/Citizen/Login1.dart';
import 'OnBoarding/Citizen/location1.dart';
import 'OnBoarding/Leader/CreateProfile.dart';
import 'OnBoarding/Leader/FaceDetect.dart';
import 'OnBoarding/Leader/location.dart';
import 'OnBoarding/Leader/login.dart';
import 'OnBoarding/Splash.dart';
import 'OnBoarding/WelCome1.dart';
import 'pay_now_screen/pay_now_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('te'),
        Locale('ar'),
        Locale('hi'),
        Locale('kn'),
        Locale('ta'),
        Locale('mr'),
        Locale('as'),
        Locale('or'),
        Locale('mni'),
        Locale('bn'),
        Locale('bo'),
        Locale('ml'),
        Locale('mai')
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'She Power',
          initialRoute: '/Splash',
          supportedLocales: context.supportedLocales,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            EasyLocalization.of(context)!.delegate,
            const BoLocalizationsDelegate(),
          ],
          locale: context.locale,
          routes: {
            '/Splash': (context) => Splash(),
            '/Notification': (context) => NotificationScreen(),
            '/WelcomeScreen': (context) => WelcomeScreen(),
            //Citizen
            '/Login1': (context) => const Login1(),
            '/Facescan1': (context) => const Facescan1(),
            '/CitizenProfile': (context) => CitizenProfile(),
            '/Citylocation': (context) => Citylocation(),
            //Leader
            '/Login': (context) => const Login(),
            '/Facescan': (context) => Facescan(),
            '/CreateProfile': (context) => CreateProfile(),
            '/location': (context) => Leaderlocation(),
            //Profile Creation
            '/editprofile': (context) => const editprofile(),
            '/profilesetting': (context) => const profilesetting(),
            // Other routes...
            '/payment': (context) => const PayNowScreen(),
          },
        );
      },
    );
  }
}
