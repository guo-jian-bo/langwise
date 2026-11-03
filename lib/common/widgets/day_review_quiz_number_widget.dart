import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';
import 'widgets.dart';


class DayReviewQuizNumberWidget extends StatelessWidget {
  final int reviewLimit;
  final void Function()? onTap;
  /// 每日复习题目数量
  const DayReviewQuizNumberWidget({super.key, required this.reviewLimit, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.wMin,
      padding: EdgeInsets.all(8.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cBgTertiary,
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "每日复习题目数量",
            style: TextStyle(
              color: AppTheme.cTextPrimary,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
            ),
          ),
          CardMinBox2Widget(
            backColor: AppTheme.cBgQuaternary,
            borderColor: AppTheme.cBgQuaternary,
            padding: EdgeInsets.zero,
            radius: 6.wMin,
            child: SizedBox(
              height: double.infinity,
              width: 245.wMin,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        reviewLimit == 0 ? "无限制" : "$reviewLimit",
                        style: TextStyle(
                          color: AppTheme.cTextPrimary,
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1.wMin, color: AppTheme.cTextDisabled),
                  TapScaleWidget(
                    onTap: onTap,
                    sclae: 1.05,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                      child: Text(
                        "编辑",
                        style: TextStyle(
                          color: AppTheme.cFeedbackInfoText,
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}