

import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../theme/theme.dart';

class RecommendedTagsWidget extends StatelessWidget {
  const RecommendedTagsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cFeedbackInfoBackground.color,
        border: Border.all(
          color: AppTheme.cFeedbackInfoText.color,
          width: 1.wMin,
        ),
      ),
      child: Text(
        '推荐',
        style: TextStyle(
          fontSize: 24.wMin,
          color: AppTheme.cFeedbackInfoBorder,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}