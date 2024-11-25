import 'package:Shepower/core/utils/image_constant.dart';
import 'package:Shepower/core/utils/size_utils.dart';
import 'package:Shepower/theme/custom_button_style.dart';
import 'package:Shepower/theme/custom_text_style.dart';
import 'package:Shepower/theme/theme_helper.dart';
import 'package:Shepower/widgets/custom_elevated_button.dart';
import 'package:Shepower/widgets/custom_image_view.dart';
import 'package:flutter/material.dart';

class PayNowScreen extends StatelessWidget {
  const PayNowScreen({Key? key})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);

    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: double.maxFinite,
          child: Column(
            children: [
              Container(
                height: 8.v,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onErrorContainer.withOpacity(1),
                ),
              ),
              SizedBox(height: 16.v),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16.h),
                  child: Row(
                    children: [
                      CustomImageView(
                        imagePath:
                            ImageConstant.imgIconlyCurvedTwoToneArrow23x24,
                        height: 23.v,
                        width: 24.h,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 12.h,
                          top: 2.v,
                        ),
                        child: Text(
                          "Pay Now",
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50.v),
              Text(
                "Enter amount",
                style: CustomTextStyles.titleLargeIndigo900,
              ),
              SizedBox(height: 58.v),
              Text(
                "35000",
                style: theme.textTheme.displayMedium,
              ),
              SizedBox(height: 5.v),
            ],
          ),
        ),
        bottomNavigationBar: _buildPayButton(context),
      ),
    );
  }

  /// Section Widget
  Widget _buildPayButton(BuildContext context) {
    return CustomElevatedButton(
      width: 215.h,
      text: "Pay",
      margin: EdgeInsets.only(
        left: 72.h,
        right: 72.h,
        bottom: 20.v,
      ),
      buttonStyle: CustomButtonStyles.none,
      decoration: CustomButtonStyles.gradientPinkAToPrimaryTL10Decoration,
    );
  }
}
