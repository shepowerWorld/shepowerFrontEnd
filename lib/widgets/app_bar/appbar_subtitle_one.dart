import 'package:Shepower/theme/custom_text_style.dart';
import 'package:Shepower/theme/theme_helper.dart';
import 'package:flutter/material.dart';


// ignore: must_be_immutable
class AppbarSubtitleOne extends StatelessWidget {
  AppbarSubtitleOne({
    Key? key,
    required this.text,
    this.margin,
    this.onTap,
  }) : super(
          key: key,
        );

  String text;

  EdgeInsetsGeometry? margin;

  Function? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap!.call();
      },
      child: Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Text(
          text,
          style: CustomTextStyles.titleMediumBlack90017.copyWith(
            color: appTheme.black900,
          ),
        ),
      ),
    );
  }
}
