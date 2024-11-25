import 'dart:ui';
import 'package:Shepower/core/app_export.dart';
import 'package:Shepower/core/utils/size_utils.dart';
import 'package:Shepower/theme/theme_helper.dart';
import 'package:flutter/material.dart';

/// A class that offers pre-defined button styles for customizing button appearance.
class CustomButtonStyles {
  // Filled button style
  static ButtonStyle get fillGray => ElevatedButton.styleFrom(
        backgroundColor: appTheme.gray100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.h),
        ),
      );
  static ButtonStyle get fillGrayTL18 => ElevatedButton.styleFrom(
        backgroundColor: appTheme.gray100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.h),
        ),
      );
  static ButtonStyle get fillGrayTL9 => ElevatedButton.styleFrom(
        backgroundColor: appTheme.gray100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9.h),
        ),
      );

  // Gradient button style
  static BoxDecoration get gradientBlueGrayToBlueGrayDecoration =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(15.h),
        gradient: LinearGradient(
          begin: Alignment(0.5, 0),
          end: Alignment(0.5, 1),
          colors: [
            appTheme.blueGray10001,
            appTheme.blueGray10001.withOpacity(0),
          ],
        ),
      );
  static BoxDecoration get gradientBlueGrayToBlueGrayTL15Decoration =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(15.h),
        boxShadow: [
          BoxShadow(
            color: appTheme.indigo3003f,
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: Offset(
              0,
              10,
            ),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment(0.5, 0),
          end: Alignment(0.5, 1),
          colors: [
            appTheme.blueGray10001,
            appTheme.blueGray10001.withOpacity(0),
          ],
        ),
      );
  static BoxDecoration get gradientBlueGrayToBlueGrayTL151Decoration =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(15.h),
        boxShadow: [
          BoxShadow(
            color: appTheme.yellow90028,
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: Offset(
              0,
              4,
            ),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment(0.5, 0),
          end: Alignment(0.5, 1),
          colors: [
            appTheme.blueGray10001,
            appTheme.blueGray10001.withOpacity(0),
          ],
        ),
      );
  static BoxDecoration get gradientBlueGrayToBlueGrayTL18Decoration =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(18.h),
        gradient: LinearGradient(
          begin: Alignment(0.5, 0),
          end: Alignment(0.5, 1),
          colors: [
            appTheme.blueGray10001,
            appTheme.blueGray10001.withOpacity(0),
          ],
        ),
      );
  static BoxDecoration get gradientBlueGrayToBlueGrayTL6Decoration =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(6.h),
        gradient: LinearGradient(
          begin: Alignment(0.5, 0),
          end: Alignment(0.5, 1),
          colors: [
            appTheme.blueGray10001,
            appTheme.blueGray10001.withOpacity(0),
          ],
        ),
      );
  static BoxDecoration get gradientBlueGrayToBlueGrayTL9Decoration =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(9.h),
        gradient: LinearGradient(
          begin: Alignment(0.5, 0),
          end: Alignment(0.5, 1),
          colors: [
            appTheme.blueGray10001,
            appTheme.blueGray10001.withOpacity(0),
          ],
        ),
      );
  static BoxDecoration get gradientPinkAToPrimaryDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(16.h),
        boxShadow: [
          BoxShadow(
            color: appTheme.black900.withOpacity(0.25),
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: Offset(
              0,
              4,
            ),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment(-0.06, 0),
          end: Alignment(1.0, 0),
          colors: [
            appTheme.pinkA700,
            theme.colorScheme.primary,
          ],
        ),
      );
  static BoxDecoration get gradientPinkAToPrimaryTL10Decoration =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(10.h),
        boxShadow: [
          BoxShadow(
            color: appTheme.black900.withOpacity(0.25),
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: Offset(
              0,
              2,
            ),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment(-0.06, 0),
          end: Alignment(1.0, 0),
          colors: [
            appTheme.pinkA700,
            theme.colorScheme.primary,
          ],
        ),
      );
  static BoxDecoration get gradientPinkAToPrimaryTL15Decoration =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(15.h),
        boxShadow: [
          BoxShadow(
            color: appTheme.black900.withOpacity(0.25),
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: Offset(
              0,
              3,
            ),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment(-0.06, 0),
          end: Alignment(1.0, 0),
          colors: [
            appTheme.pinkA700,
            theme.colorScheme.primary,
          ],
        ),
      );
  static BoxDecoration get gradientPinkAToPrimaryTL16Decoration =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(16.h),
        gradient: LinearGradient(
          begin: Alignment(-0.06, 0),
          end: Alignment(1.0, 0),
          colors: [
            appTheme.pinkA700.withOpacity(0.5),
            theme.colorScheme.primary.withOpacity(0.5),
          ],
        ),
      );

  // Outline button style
  static ButtonStyle get outlineBlack => ElevatedButton.styleFrom(
        backgroundColor: appTheme.blueGray100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.h),
        ),
        shadowColor: appTheme.black900.withOpacity(0.25),
        elevation: 2,
      );
  static ButtonStyle get outlineBlackTL10 => ElevatedButton.styleFrom(
        backgroundColor: appTheme.blueGray10001,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.h),
        ),
        shadowColor: appTheme.black900.withOpacity(0.25),
        elevation: 2,
      );
  static ButtonStyle get outlineBlackTL101 => ElevatedButton.styleFrom(
        backgroundColor: appTheme.gray400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.h),
        ),
        shadowColor: appTheme.black900.withOpacity(0.25),
        elevation: 2,
      );
  static ButtonStyle get outlineBlackTL5 => ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.onErrorContainer.withOpacity(1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.h),
        ),
        shadowColor: appTheme.black900.withOpacity(0.27),
        elevation: 1,
      );
  static ButtonStyle get outlineGray => OutlinedButton.styleFrom(
        backgroundColor: theme.colorScheme.onErrorContainer.withOpacity(1),
        side: BorderSide(
          color: appTheme.gray900,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.h),
        ),
      );
  static ButtonStyle get outlineIndigoF => ElevatedButton.styleFrom(
        backgroundColor: appTheme.blueGray10001,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.h),
        ),
        shadowColor: appTheme.indigo3003f,
        elevation: 10,
      );
  static ButtonStyle get outlineTL12 => OutlinedButton.styleFrom(
        backgroundColor: theme.colorScheme.onErrorContainer.withOpacity(1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.h),
        ),
      );
  static ButtonStyle get outlineTL15 => OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.h),
        ),
      );
  // text button style
  static ButtonStyle get none => ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        elevation: MaterialStateProperty.all<double>(0),
      );
}
