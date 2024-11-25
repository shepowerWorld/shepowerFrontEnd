import 'package:Shepower/core/utils/size_utils.dart';
import 'package:Shepower/theme/theme_helper.dart';
import 'package:flutter/material.dart';
import '../core/app_export.dart';

/// A collection of pre-defined text styles for customizing text appearance,
/// categorized by different font families and weights.
/// Additionally, this class includes extensions on [TextStyle] to easily apply specific font families to text.

class CustomTextStyles {
  // Body text style
  static get paymentAmountText => theme.textTheme.displayMedium!.copyWith(
        color: appTheme.black900,
      );
  static get paymentAmountPlaceholder =>
      theme.textTheme.displayMedium!.copyWith(
        color: appTheme.blueGray10002,
      );
  static get bodyLargeBlack900 => theme.textTheme.bodyLarge!.copyWith(
        color: appTheme.black900,
      );
  static get bodyLargeGray500 => theme.textTheme.bodyLarge!.copyWith(
        color: appTheme.gray500,
      );
  static get bodyLargeGray50001 => theme.textTheme.bodyLarge!.copyWith(
        color: appTheme.gray50001,
      );
  static get bodyLargeGray90003 => theme.textTheme.bodyLarge!.copyWith(
        color: appTheme.gray90003,
      );
  static get bodyLargeMontserratBlack900 =>
      theme.textTheme.bodyLarge!.montserrat.copyWith(
        color: appTheme.black900,
      );
  static get bodyLargeMontserratBlack900_1 =>
      theme.textTheme.bodyLarge!.montserrat.copyWith(
        color: appTheme.black900,
      );
  static get bodyLargeMontserratBluegray900 =>
      theme.textTheme.bodyLarge!.montserrat.copyWith(
        color: appTheme.blueGray900,
      );
  static get bodyLargeMontserratGray80001 =>
      theme.textTheme.bodyLarge!.montserrat.copyWith(
        color: appTheme.gray80001,
      );
  static get bodyLargeMontserratGray900 =>
      theme.textTheme.bodyLarge!.montserrat.copyWith(
        color: appTheme.gray900,
      );
  static get bodyLargeMontserratGray90002 =>
      theme.textTheme.bodyLarge!.montserrat.copyWith(
        color: appTheme.gray90002,
      );
  static get bodyLargeMontserratGray90003 =>
      theme.textTheme.bodyLarge!.montserrat.copyWith(
        color: appTheme.gray90003,
      );
  static get bodyLargeMontserratGray90019 =>
      theme.textTheme.bodyLarge!.montserrat.copyWith(
        color: appTheme.gray900,
        fontSize: 19.fSize,
      );
  static get bodyLargeMontserratOnErrorContainer =>
      theme.textTheme.bodyLarge!.montserrat.copyWith(
        color: theme.colorScheme.onErrorContainer.withOpacity(1),
        fontSize: 19.fSize,
      );
  static get bodyLargeRobotoBlack900 =>
      theme.textTheme.bodyLarge!.roboto.copyWith(
        color: appTheme.black900,
        fontSize: 18.fSize,
      );
  static get bodyMediumMontserratBlack900 =>
      theme.textTheme.bodyMedium!.montserrat.copyWith(
        color: appTheme.black900,
        fontSize: 14.fSize,
        fontWeight: FontWeight.w100,
      );
  static get bodyMediumMontserratBlack90014 =>
      theme.textTheme.bodyMedium!.montserrat.copyWith(
        color: appTheme.black900,
        fontSize: 14.fSize,
      );
  static get bodyMediumMontserratBluegray90002 =>
      theme.textTheme.bodyMedium!.montserrat.copyWith(
        color: appTheme.blueGray90002,
      );
  static get bodyMediumMontserratGray50002 =>
      theme.textTheme.bodyMedium!.montserrat.copyWith(
        color: appTheme.gray50002,
        fontSize: 14.fSize,
      );
  static get bodyMediumMontserratGray70002 =>
      theme.textTheme.bodyMedium!.montserrat.copyWith(
        color: appTheme.gray70002,
        fontSize: 14.fSize,
      );
  static get bodyMediumMontserratGray900 =>
      theme.textTheme.bodyMedium!.montserrat.copyWith(
        color: appTheme.gray900,
        fontSize: 15.fSize,
      );
  static get bodyMediumMontserratGray90002 =>
      theme.textTheme.bodyMedium!.montserrat.copyWith(
        color: appTheme.gray90002,
        fontSize: 14.fSize,
      );
  static get bodyMediumMontserratIndigo800 =>
      theme.textTheme.bodyMedium!.montserrat.copyWith(
        color: appTheme.indigo800,
        fontSize: 14.fSize,
      );
  static get bodyMediumMontserratIndigo900 =>
      theme.textTheme.bodyMedium!.montserrat.copyWith(
        color: appTheme.indigo900,
        fontSize: 14.fSize,
      );
  static get bodyMediumNunitoSansGray600 =>
      theme.textTheme.bodyMedium!.nunitoSans.copyWith(
        color: appTheme.gray600,
        fontSize: 14.fSize,
      );
  static get bodyMediumOnErrorContainer => theme.textTheme.bodyMedium!.copyWith(
        color: theme.colorScheme.onErrorContainer.withOpacity(1),
      );
  static get bodyMediumRobotoBluegray300 =>
      theme.textTheme.bodyMedium!.roboto.copyWith(
        color: appTheme.blueGray300,
      );
  static get bodyMediumRobotoGray700 =>
      theme.textTheme.bodyMedium!.roboto.copyWith(
        color: appTheme.gray700,
      );
  static get bodyMediumRobotoIndigo800 =>
      theme.textTheme.bodyMedium!.roboto.copyWith(
        color: appTheme.indigo800,
        fontSize: 14.fSize,
      );
  static get bodyMediumRobotoIndigo80014 =>
      theme.textTheme.bodyMedium!.roboto.copyWith(
        color: appTheme.indigo800,
        fontSize: 14.fSize,
      );
  static get bodySmallBlack900 => theme.textTheme.bodySmall!.copyWith(
        color: appTheme.black900,
      );
  static get bodySmallBluegray10001 => theme.textTheme.bodySmall!.copyWith(
        color: appTheme.blueGray10001.withOpacity(0.6),
        fontSize: 10.fSize,
      );
  static get bodySmallBluegray200 => theme.textTheme.bodySmall!.copyWith(
        color: appTheme.blueGray200,
        fontSize: 10.fSize,
      );
  static get bodySmallIBMPlexSansGray70002 =>
      theme.textTheme.bodySmall!.iBMPlexSans.copyWith(
        color: appTheme.gray70002,
        fontSize: 12.fSize,
      );
  static get bodySmallInterBlack900 =>
      theme.textTheme.bodySmall!.inter.copyWith(
        color: appTheme.black900.withOpacity(0.57),
      );
  static get bodySmallMetropolisBlack900 =>
      theme.textTheme.bodySmall!.metropolis.copyWith(
        color: appTheme.black900,
        fontSize: 12.fSize,
      );
  static get bodySmallMontserratBlack900 =>
      theme.textTheme.bodySmall!.montserrat.copyWith(
        color: appTheme.black900,
        fontSize: 12.fSize,
      );
  static get bodySmallMontserratBlack90010 =>
      theme.textTheme.bodySmall!.montserrat.copyWith(
        color: appTheme.black900.withOpacity(0.6),
        fontSize: 10.fSize,
      );
  static get bodySmallMontserratBlack90012 =>
      theme.textTheme.bodySmall!.montserrat.copyWith(
        color: appTheme.black900.withOpacity(0.53),
        fontSize: 12.fSize,
      );
  static get bodySmallMontserratBlack900_1 =>
      theme.textTheme.bodySmall!.montserrat.copyWith(
        color: appTheme.black900,
      );
  static get bodySmallMontserratBluegray10001 =>
      theme.textTheme.bodySmall!.montserrat.copyWith(
        color: appTheme.blueGray10001.withOpacity(0.6),
        fontSize: 10.fSize,
      );
  static get bodySmallMontserratBluegray300 =>
      theme.textTheme.bodySmall!.montserrat.copyWith(
        color: appTheme.blueGray300,
        fontSize: 8.fSize,
      );
  static get bodySmallMontserratBluegray30012 =>
      theme.textTheme.bodySmall!.montserrat.copyWith(
        color: appTheme.blueGray300,
        fontSize: 12.fSize,
      );
  static get bodySmallMontserratBluegray90001 =>
      theme.textTheme.bodySmall!.montserrat.copyWith(
        color: appTheme.blueGray90001,
        fontSize: 12.fSize,
      );
  static get bodySmallMontserratErrorContainer =>
      theme.textTheme.bodySmall!.montserrat.copyWith(
        color: theme.colorScheme.errorContainer,
        fontSize: 10.fSize,
        fontWeight: FontWeight.w200,
      );
  static get bodySmallMontserratGray70002 =>
      theme.textTheme.bodySmall!.montserrat.copyWith(
        color: appTheme.gray70002,
        fontSize: 12.fSize,
      );
  static get bodySmallMontserratGray900 =>
      theme.textTheme.bodySmall!.montserrat.copyWith(
        color: appTheme.gray900,
        fontSize: 12.fSize,
      );
  static get bodySmallMontserratGray90002 =>
      theme.textTheme.bodySmall!.montserrat.copyWith(
        color: appTheme.gray90002,
      );
  static get bodySmallMontserratGray9000210 =>
      theme.textTheme.bodySmall!.montserrat.copyWith(
        color: appTheme.gray90002,
        fontSize: 10.fSize,
      );
  static get bodySmallMontserratGray9000212 =>
      theme.textTheme.bodySmall!.montserrat.copyWith(
        color: appTheme.gray90002,
        fontSize: 12.fSize,
      );
  static get bodySmallMontserratGray90012 =>
      theme.textTheme.bodySmall!.montserrat.copyWith(
        color: appTheme.gray900,
        fontSize: 12.fSize,
      );
  static get bodySmallMontserratGray90012_1 =>
      theme.textTheme.bodySmall!.montserrat.copyWith(
        color: appTheme.gray900,
        fontSize: 12.fSize,
      );
  static get bodySmallMontserratIndigo900 =>
      theme.textTheme.bodySmall!.montserrat.copyWith(
        color: appTheme.indigo900,
        fontSize: 12.fSize,
      );
  static get bodySmallRobotoBlack900 =>
      theme.textTheme.bodySmall!.roboto.copyWith(
        color: appTheme.black900,
      );
  static get bodySmallRobotoBluegray300 =>
      theme.textTheme.bodySmall!.roboto.copyWith(
        color: appTheme.blueGray300,
        fontSize: 8.fSize,
      );
  static get bodySmallRobotoBluegray30010 =>
      theme.textTheme.bodySmall!.roboto.copyWith(
        color: appTheme.blueGray300,
        fontSize: 10.fSize,
      );
  static get bodySmallRobotoBluegray50001 =>
      theme.textTheme.bodySmall!.roboto.copyWith(
        color: appTheme.blueGray50001,
        fontSize: 10.fSize,
      );
  // Display text style
  static get displaySmallGray900 => theme.textTheme.displaySmall!.copyWith(
        color: appTheme.gray900,
        fontSize: 36.fSize,
        fontWeight: FontWeight.w800,
      );
  static get displaySmallGray900ExtraBold =>
      theme.textTheme.displaySmall!.copyWith(
        color: appTheme.gray900,
        fontSize: 34.fSize,
        fontWeight: FontWeight.w800,
      );
  static get displaySmallMervaleScriptPurple300 =>
      theme.textTheme.displaySmall!.mervaleScript.copyWith(
        color: appTheme.purple300,
        fontSize: 34.fSize,
        fontWeight: FontWeight.w400,
      );
  // Headline text style
  static get headlineLargeMontserratBluegray10001 =>
      theme.textTheme.headlineLarge!.montserrat.copyWith(
        color: appTheme.blueGray10001,
        fontWeight: FontWeight.w600,
      );
  static get headlineLargeMontserratRed800 =>
      theme.textTheme.headlineLarge!.montserrat.copyWith(
        color: appTheme.red800,
        fontWeight: FontWeight.w600,
      );
  static get headlineSmallBluegray10001 =>
      theme.textTheme.headlineSmall!.copyWith(
        color: appTheme.blueGray10001,
        fontWeight: FontWeight.w600,
      );
  // Label text style
  static get labelLargeBlack900 => theme.textTheme.labelLarge!.copyWith(
        color: appTheme.black900,
        fontWeight: FontWeight.w600,
      );
  static get labelLargeBlack900Bold => theme.textTheme.labelLarge!.copyWith(
        color: appTheme.black900,
        fontWeight: FontWeight.w700,
      );
  static get labelLargeBlack900SemiBold => theme.textTheme.labelLarge!.copyWith(
        color: appTheme.black900,
        fontWeight: FontWeight.w600,
      );
  static get labelLargeBlack900SemiBold_1 =>
      theme.textTheme.labelLarge!.copyWith(
        color: appTheme.black900,
        fontWeight: FontWeight.w600,
      );
  static get labelLargeBluegray700 => theme.textTheme.labelLarge!.copyWith(
        color: appTheme.blueGray700,
      );
  static get labelLargeBluegray70001 => theme.textTheme.labelLarge!.copyWith(
        color: appTheme.blueGray70001,
      );
  static get labelLargeDeeporange500 => theme.textTheme.labelLarge!.copyWith(
        color: appTheme.deepOrange500,
      );
  static get labelLargeGray90001 => theme.textTheme.labelLarge!.copyWith(
        color: appTheme.gray90001,
      );
  static get labelLargeIndigoA700 => theme.textTheme.labelLarge!.copyWith(
        color: appTheme.indigoA700,
      );
  static get labelLargeOnErrorContainer => theme.textTheme.labelLarge!.copyWith(
        color: theme.colorScheme.onErrorContainer.withOpacity(1),
        fontWeight: FontWeight.w600,
      );
  static get labelLargeOnErrorContainerSemiBold =>
      theme.textTheme.labelLarge!.copyWith(
        color: theme.colorScheme.onErrorContainer.withOpacity(1),
        fontSize: 13.fSize,
        fontWeight: FontWeight.w600,
      );
  static get labelLargePinkA700 => theme.textTheme.labelLarge!.copyWith(
        color: appTheme.pinkA700,
        fontWeight: FontWeight.w600,
      );
  static get labelLargePinkA700Bold => theme.textTheme.labelLarge!.copyWith(
        color: appTheme.pinkA700,
        fontWeight: FontWeight.w700,
      );
  static get labelLargePoppinsBlack900 =>
      theme.textTheme.labelLarge!.poppins.copyWith(
        color: appTheme.black900,
        fontWeight: FontWeight.w700,
      );
  static get labelLargePoppinsBlack900_1 =>
      theme.textTheme.labelLarge!.poppins.copyWith(
        color: appTheme.black900,
      );
  static get labelLargePoppinsBluegray10001 =>
      theme.textTheme.labelLarge!.poppins.copyWith(
        color: appTheme.blueGray10001.withOpacity(0.53),
        fontSize: 13.fSize,
        fontWeight: FontWeight.w600,
      );
  static get labelLargePrimaryContainer => theme.textTheme.labelLarge!.copyWith(
        color: theme.colorScheme.primaryContainer,
      );
  static get labelLargeSemiBold => theme.textTheme.labelLarge!.copyWith(
        fontWeight: FontWeight.w600,
      );
  static get labelMediumBlack900 => theme.textTheme.labelMedium!.copyWith(
        color: appTheme.black900,
        fontSize: 10.fSize,
      );
  static get labelMediumBlack900_1 => theme.textTheme.labelMedium!.copyWith(
        color: appTheme.black900,
      );
  static get labelMediumBluegray700 => theme.textTheme.labelMedium!.copyWith(
        color: appTheme.blueGray700,
        fontWeight: FontWeight.w500,
      );
  static get labelMediumBluegray70001 => theme.textTheme.labelMedium!.copyWith(
        color: appTheme.blueGray70001,
        fontWeight: FontWeight.w500,
      );
  static get labelMediumBluegray90001 => theme.textTheme.labelMedium!.copyWith(
        color: appTheme.blueGray90001.withOpacity(0.8),
        fontSize: 10.fSize,
        fontWeight: FontWeight.w500,
      );
  static get labelMediumGray900 => theme.textTheme.labelMedium!.copyWith(
        color: appTheme.gray900,
        fontSize: 10.fSize,
        fontWeight: FontWeight.w500,
      );
  static get labelMediumGray90010 => theme.textTheme.labelMedium!.copyWith(
        color: appTheme.gray900.withOpacity(0.7),
        fontSize: 10.fSize,
      );
  static get labelMediumGray900Medium => theme.textTheme.labelMedium!.copyWith(
        color: appTheme.gray900,
        fontSize: 10.fSize,
        fontWeight: FontWeight.w500,
      );
  static get labelMediumGray900Medium10 =>
      theme.textTheme.labelMedium!.copyWith(
        color: appTheme.gray900,
        fontSize: 10.fSize,
        fontWeight: FontWeight.w500,
      );
  static get labelMediumOnError => theme.textTheme.labelMedium!.copyWith(
        color: theme.colorScheme.onError,
        fontWeight: FontWeight.w700,
      );
  static get labelMediumOnErrorContainer =>
      theme.textTheme.labelMedium!.copyWith(
        color: theme.colorScheme.onErrorContainer.withOpacity(1),
        fontSize: 10.fSize,
        fontWeight: FontWeight.w500,
      );
  static get labelMediumPrimaryContainer =>
      theme.textTheme.labelMedium!.copyWith(
        color: theme.colorScheme.primaryContainer,
        fontSize: 10.fSize,
        fontWeight: FontWeight.w500,
      );
  static get labelMediumRobotoBluegray10001 =>
      theme.textTheme.labelMedium!.roboto.copyWith(
        color: appTheme.blueGray10001.withOpacity(0.53),
        fontSize: 10.fSize,
        fontWeight: FontWeight.w500,
      );
  static get labelMediumRobotoBluegray50001 =>
      theme.textTheme.labelMedium!.roboto.copyWith(
        color: appTheme.blueGray50001,
        fontSize: 10.fSize,
        fontWeight: FontWeight.w700,
      );
  static get labelMediumRobotoIndigo900 =>
      theme.textTheme.labelMedium!.roboto.copyWith(
        color: appTheme.indigo900,
        fontSize: 10.fSize,
        fontWeight: FontWeight.w500,
      );
  static get labelSmallBlack900 => theme.textTheme.labelSmall!.copyWith(
        color: appTheme.black900,
        fontSize: 8.fSize,
        fontWeight: FontWeight.w600,
      );
  static get labelSmallBluegray10001 => theme.textTheme.labelSmall!.copyWith(
        color: appTheme.blueGray10001,
      );
  static get labelSmallOnErrorContainer => theme.textTheme.labelSmall!.copyWith(
        color: theme.colorScheme.onErrorContainer.withOpacity(1),
      );
  static get labelSmallPinkA700 => theme.textTheme.labelSmall!.copyWith(
        color: appTheme.pinkA700,
      );
  static get labelSmallPoppinsBlack900 =>
      theme.textTheme.labelSmall!.poppins.copyWith(
        color: appTheme.black900,
        fontWeight: FontWeight.w500,
      );
  static get labelSmallPoppinsOnErrorContainer =>
      theme.textTheme.labelSmall!.poppins.copyWith(
        color: theme.colorScheme.onErrorContainer.withOpacity(1),
        fontSize: 8.fSize,
        fontWeight: FontWeight.w500,
      );
  static get labelSmallPrimaryContainer => theme.textTheme.labelSmall!.copyWith(
        color: theme.colorScheme.primaryContainer,
        fontWeight: FontWeight.w500,
      );
  // Lavishly text style
  static get lavishlyYoursBlack900 => TextStyle(
        color: appTheme.black900,
        fontSize: 83.fSize,
        fontWeight: FontWeight.w400,
      ).lavishlyYours;
  // Montserrat text style
  static get montserratOnErrorContainer => TextStyle(
        color: theme.colorScheme.onErrorContainer.withOpacity(1),
        fontSize: 7.fSize,
        fontWeight: FontWeight.w700,
      ).montserrat;
  static get montserratOnErrorContainerSemiBold => TextStyle(
        color: theme.colorScheme.onErrorContainer.withOpacity(1),
        fontSize: 6.fSize,
        fontWeight: FontWeight.w600,
      ).montserrat;
  // Poppins text style
  static get poppinsBlack900 => TextStyle(
        color: appTheme.black900,
        fontSize: 6.fSize,
        fontWeight: FontWeight.w500,
      ).poppins;
  static get poppinsBlack900Regular => TextStyle(
        color: appTheme.black900,
        fontSize: 6.fSize,
        fontWeight: FontWeight.w400,
      ).poppins;
  // Title text style
  static get titleLargeBlack900 => theme.textTheme.titleLarge!.copyWith(
        color: appTheme.black900,
        fontSize: 20.fSize,
        fontWeight: FontWeight.w600,
      );
  static get titleLargeBluegray10001 => theme.textTheme.titleLarge!.copyWith(
        color: appTheme.blueGray10001,
        fontWeight: FontWeight.w600,
      );
  static get titleLargeBluegray300 => theme.textTheme.titleLarge!.copyWith(
        color: appTheme.blueGray300,
        fontSize: 20.fSize,
        fontWeight: FontWeight.w400,
      );
  static get titleLargeBluegray800 => theme.textTheme.titleLarge!.copyWith(
        color: appTheme.blueGray800,
        fontWeight: FontWeight.w500,
      );
  static get titleLargeBluegray90001 => theme.textTheme.titleLarge!.copyWith(
        color: appTheme.blueGray90001,
        fontSize: 20.fSize,
        fontWeight: FontWeight.w400,
      );
  static get titleLargeBluegray90001_1 => theme.textTheme.titleLarge!.copyWith(
        color: appTheme.blueGray90001.withOpacity(0.47),
      );
  static get titleLargeGray900 => theme.textTheme.titleLarge!.copyWith(
        color: appTheme.gray900,
      );
  static get titleLargeGray90004 => theme.textTheme.titleLarge!.copyWith(
        color: appTheme.gray90004,
        fontSize: 20.fSize,
        fontWeight: FontWeight.w600,
      );
  static get titleLargeGray900Medium => theme.textTheme.titleLarge!.copyWith(
        color: appTheme.gray900,
        fontWeight: FontWeight.w500,
      );
  static get titleLargeGray900SemiBold => theme.textTheme.titleLarge!.copyWith(
        color: appTheme.gray900,
        fontSize: 20.fSize,
        fontWeight: FontWeight.w600,
      );
  static get titleLargeIndigo900 => theme.textTheme.titleLarge!.copyWith(
        color: appTheme.indigo900,
        fontSize: 20.fSize,
        fontWeight: FontWeight.w400,
      );
  static get titleLargePinkA700 => theme.textTheme.titleLarge!.copyWith(
        color: appTheme.pinkA700,
      );
  static get titleLargeRobotoGray900 =>
      theme.textTheme.titleLarge!.roboto.copyWith(
        color: appTheme.gray900,
        fontSize: 20.fSize,
        fontWeight: FontWeight.w500,
      );
  static get titleMediumBlack900 => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.black900,
      );
  static get titleMediumBlack90017 => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.black900,
        fontSize: 17.fSize,
      );
  static get titleMediumBlack900Medium => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.black900,
        fontWeight: FontWeight.w500,
      );
  static get titleMediumBlack900Medium18 =>
      theme.textTheme.titleMedium!.copyWith(
        color: appTheme.black900,
        fontSize: 18.fSize,
        fontWeight: FontWeight.w500,
      );
  static get titleMediumBlack900Medium_1 =>
      theme.textTheme.titleMedium!.copyWith(
        color: appTheme.black900,
        fontWeight: FontWeight.w500,
      );
  static get titleMediumBluegray10001 => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.blueGray10001,
      );
  static get titleMediumBluegray1000119 =>
      theme.textTheme.titleMedium!.copyWith(
        color: appTheme.blueGray10001,
        fontSize: 19.fSize,
      );
  static get titleMediumBluegray700 => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.blueGray700.withOpacity(0.5),
        fontWeight: FontWeight.w500,
      );
  static get titleMediumBluegray700Medium =>
      theme.textTheme.titleMedium!.copyWith(
        color: appTheme.blueGray700,
        fontWeight: FontWeight.w500,
      );
  static get titleMediumBluegray900 => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.blueGray900,
      );
  static get titleMediumBluegray90001 => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.blueGray90001,
        fontSize: 19.fSize,
      );
  static get titleMediumGray70001 => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.gray70001,
        fontWeight: FontWeight.w500,
      );
  static get titleMediumGray70001_1 => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.gray70001,
      );
  static get titleMediumGray900 => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.gray900,
        fontSize: 18.fSize,
        fontWeight: FontWeight.w500,
      );
  static get titleMediumGray90018 => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.gray900,
        fontSize: 18.fSize,
      );
  static get titleMediumGray900Medium => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.gray900,
        fontWeight: FontWeight.w500,
      );
  static get titleMediumGray900_1 => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.gray900,
      );
  static get titleMediumGray900_2 => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.gray900,
      );
  static get titleMediumInterBluegray10001 =>
      theme.textTheme.titleMedium!.inter.copyWith(
        color: appTheme.blueGray10001,
        fontWeight: FontWeight.w500,
      );
  static get titleMediumInterGray70001 =>
      theme.textTheme.titleMedium!.inter.copyWith(
        color: appTheme.gray70001,
        fontWeight: FontWeight.w500,
      );
  static get titleMediumMetropolisBlack900 =>
      theme.textTheme.titleMedium!.metropolis.copyWith(
        color: appTheme.black900,
        fontSize: 19.fSize,
        fontWeight: FontWeight.w700,
      );
  static get titleMediumOnErrorContainer =>
      theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onErrorContainer.withOpacity(1),
        fontWeight: FontWeight.w700,
      );
  static get titleMediumOnErrorContainerMedium =>
      theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onErrorContainer.withOpacity(1),
        fontWeight: FontWeight.w500,
      );
  static get titleMediumOnErrorContainerMedium_1 =>
      theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onErrorContainer.withOpacity(1),
        fontWeight: FontWeight.w500,
      );
  static get titleMediumOnErrorContainer_1 =>
      theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onErrorContainer.withOpacity(1),
      );
  static get titleMediumOnPrimaryContainer =>
      theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.65),
        fontWeight: FontWeight.w500,
      );
  static get titleMediumOnPrimaryContainer_1 =>
      theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onPrimaryContainer,
      );
  static get titleMediumOnPrimaryContainer_2 =>
      theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.47),
      );
  static get titleMediumOnPrimaryContainer_3 =>
      theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.65),
      );
  static get titleMediumPinkA700 => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.pinkA700,
        fontSize: 18.fSize,
      );
  static get titleMediumPoppinsGray900 =>
      theme.textTheme.titleMedium!.poppins.copyWith(
        color: appTheme.gray900,
      );
  static get titleMediumPrimaryContainer =>
      theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.primaryContainer,
        fontSize: 18.fSize,
        fontWeight: FontWeight.w700,
      );
  static get titleMediumPrimaryContainerBold =>
      theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.primaryContainer,
        fontWeight: FontWeight.w700,
      );
  static get titleMediumRobotoRedA700 =>
      theme.textTheme.titleMedium!.roboto.copyWith(
        color: appTheme.redA700,
      );
  static get titleMediumSatoshiBlack900 =>
      theme.textTheme.titleMedium!.satoshi.copyWith(
        color: appTheme.black900,
        fontWeight: FontWeight.w700,
      );
  static get titleSmallBluegray10001 => theme.textTheme.titleSmall!.copyWith(
        color: appTheme.blueGray10001,
        fontSize: 14.fSize,
      );
  static get titleSmallBluegray10001SemiBold =>
      theme.textTheme.titleSmall!.copyWith(
        color: appTheme.blueGray10001,
        fontSize: 14.fSize,
        fontWeight: FontWeight.w600,
      );
  static get titleSmallIndigo800 => theme.textTheme.titleSmall!.copyWith(
        color: appTheme.indigo800,
        fontSize: 14.fSize,
        fontWeight: FontWeight.w500,
      );
  static get titleSmallIndigo800Medium => theme.textTheme.titleSmall!.copyWith(
        color: appTheme.indigo800,
        fontSize: 14.fSize,
        fontWeight: FontWeight.w500,
      );
  static get titleSmallIndigo900 => theme.textTheme.titleSmall!.copyWith(
        color: appTheme.indigo900,
        fontSize: 14.fSize,
        fontWeight: FontWeight.w600,
      );
  static get titleSmallIndigo900_1 => theme.textTheme.titleSmall!.copyWith(
        color: appTheme.indigo900,
      );
  static get titleSmallInterGray90002 =>
      theme.textTheme.titleSmall!.inter.copyWith(
        color: appTheme.gray90002,
        fontSize: 14.fSize,
      );
  static get titleSmallMontserrat =>
      theme.textTheme.titleSmall!.montserrat.copyWith(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w600,
      );
  static get titleSmallMontserratBluegray10001 =>
      theme.textTheme.titleSmall!.montserrat.copyWith(
        color: appTheme.blueGray10001,
        fontSize: 14.fSize,
        fontWeight: FontWeight.w600,
      );
  static get titleSmallMontserratBluegray90001 =>
      theme.textTheme.titleSmall!.montserrat.copyWith(
        color: appTheme.blueGray90001,
        fontSize: 14.fSize,
        fontWeight: FontWeight.w500,
      );
  static get titleSmallMontserratErrorContainer =>
      theme.textTheme.titleSmall!.montserrat.copyWith(
        color: theme.colorScheme.errorContainer,
        fontSize: 14.fSize,
        fontWeight: FontWeight.w600,
      );
  static get titleSmallMontserratGray900 =>
      theme.textTheme.titleSmall!.montserrat.copyWith(
        color: appTheme.gray900,
        fontWeight: FontWeight.w600,
      );
  static get titleSmallMontserratGray90001 =>
      theme.textTheme.titleSmall!.montserrat.copyWith(
        color: appTheme.gray90001,
        fontSize: 14.fSize,
        fontWeight: FontWeight.w500,
      );
  static get titleSmallMontserratGray90002 =>
      theme.textTheme.titleSmall!.montserrat.copyWith(
        color: appTheme.gray90002,
        fontSize: 14.fSize,
      );
  static get titleSmallMontserratGray90002SemiBold =>
      theme.textTheme.titleSmall!.montserrat.copyWith(
        color: appTheme.gray90002,
        fontSize: 14.fSize,
        fontWeight: FontWeight.w600,
      );
  static get titleSmallMontserratGray900Medium =>
      theme.textTheme.titleSmall!.montserrat.copyWith(
        color: appTheme.gray900,
        fontSize: 14.fSize,
        fontWeight: FontWeight.w500,
      );
  static get titleSmallMontserratGray900SemiBold =>
      theme.textTheme.titleSmall!.montserrat.copyWith(
        color: appTheme.gray900,
        fontSize: 14.fSize,
        fontWeight: FontWeight.w600,
      );
  static get titleSmallMontserratGray900SemiBold14 =>
      theme.textTheme.titleSmall!.montserrat.copyWith(
        color: appTheme.gray900,
        fontSize: 14.fSize,
        fontWeight: FontWeight.w600,
      );
  static get titleSmallMontserratIndigo900 =>
      theme.textTheme.titleSmall!.montserrat.copyWith(
        color: appTheme.indigo900,
        fontSize: 14.fSize,
        fontWeight: FontWeight.w600,
      );
  static get titleSmallMontserratMedium =>
      theme.textTheme.titleSmall!.montserrat.copyWith(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w500,
      );
  static get titleSmallMontserratPinkA700 =>
      theme.textTheme.titleSmall!.montserrat.copyWith(
        color: appTheme.pinkA700,
        fontSize: 14.fSize,
        fontWeight: FontWeight.w600,
      );
  static get titleSmallMontserratPinkA700SemiBold =>
      theme.textTheme.titleSmall!.montserrat.copyWith(
        color: appTheme.pinkA700.withOpacity(0.79),
        fontSize: 14.fSize,
        fontWeight: FontWeight.w600,
      );
  static get titleSmallMontserratPrimaryContainer =>
      theme.textTheme.titleSmall!.montserrat.copyWith(
        color: theme.colorScheme.primaryContainer,
        fontSize: 14.fSize,
        fontWeight: FontWeight.w500,
      );
  static get titleSmallOnErrorContainer => theme.textTheme.titleSmall!.copyWith(
        color: theme.colorScheme.onErrorContainer.withOpacity(1),
        fontSize: 14.fSize,
      );
  static get titleSmallPoppins => theme.textTheme.titleSmall!.poppins.copyWith(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w600,
      );
  static get titleSmallPoppinsGray900 =>
      theme.textTheme.titleSmall!.poppins.copyWith(
        color: appTheme.gray900,
        fontWeight: FontWeight.w600,
      );
  static get titleSmallPoppinsMedium =>
      theme.textTheme.titleSmall!.poppins.copyWith(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w500,
      );
  static get titleSmallPoppinsSemiBold =>
      theme.textTheme.titleSmall!.poppins.copyWith(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w600,
      );
}

extension on TextStyle {
  TextStyle get metropolis {
    return copyWith(
      fontFamily: 'Metropolis',
    );
  }

  TextStyle get iBMPlexSans {
    return copyWith(
      fontFamily: 'IBM Plex Sans',
    );
  }

  TextStyle get montserrat {
    return copyWith(
      fontFamily: 'Montserrat',
    );
  }

  TextStyle get inter {
    return copyWith(
      fontFamily: 'Inter',
    );
  }

  TextStyle get mervaleScript {
    return copyWith(
      fontFamily: 'Mervale Script',
    );
  }

  TextStyle get lavishlyYours {
    return copyWith(
      fontFamily: 'Lavishly Yours',
    );
  }

  TextStyle get satoshi {
    return copyWith(
      fontFamily: 'Satoshi',
    );
  }

  TextStyle get roboto {
    return copyWith(
      fontFamily: 'Roboto',
    );
  }

  TextStyle get nunitoSans {
    return copyWith(
      fontFamily: 'Nunito Sans',
    );
  }

  TextStyle get poppins {
    return copyWith(
      fontFamily: 'Poppins',
    );
  }
}
