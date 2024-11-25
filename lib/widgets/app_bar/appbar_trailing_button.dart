import 'package:Shepower/core/utils/size_utils.dart';
import 'package:flutter/material.dart';
import 'package:Shepower/core/app_export.dart';
import 'package:Shepower/widgets/custom_elevated_button.dart';

import '../../theme/custom_text_style.dart';

// ignore: must_be_immutable
class AppbarTrailingButton extends StatelessWidget {
  AppbarTrailingButton({
    Key? key,
    this.margin,
    this.onTap,
  }) : super(
          key: key,
        );

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
        child: CustomElevatedButton(
          height: 23.v,
          width: 57.h,
          text: "Next",
          buttonStyle: CustomButtonStyles.none,
          decoration:
              CustomButtonStyles.gradientBlueGrayToBlueGrayTL6Decoration,
          buttonTextStyle: CustomTextStyles.montserratOnErrorContainer,
        ),
      ),
    );
  }
}
