import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'widgets.dart';

class NotDataWidget extends StatelessWidget {
  final String? message;
  final String? buttonText;
  final void Function()? onButton;
  final Widget? other;
  const NotDataWidget({super.key, this.message, this.buttonText, this.onButton, this.other});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 46.wMin,
        children: [
          SvgPicture.asset(
            "assets/svg/public/not_data.svg",
            width: 200.wMin,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message??"",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Visibility(
                visible: buttonText != null,
                child: Container(
                  margin: EdgeInsets.only(left: 10.wMin),
                  child: _buildButtonWidget(),
                ),
              ),
            ],
          ),
          SizedBox(child: other),
        ],
      ),
    );
  }

  Widget _buildButtonWidget(){
    return TapScaleWidget(
      onTap: onButton,
      sclae: 1.05,
      child: Text(
        buttonText??"",
        style: TextStyle(
          fontSize: 28.wMin,
          color: AppTheme.cFeedbackInfoText,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: AppTheme.cFeedbackInfoText,
        ),
      ),
    );

  }
}