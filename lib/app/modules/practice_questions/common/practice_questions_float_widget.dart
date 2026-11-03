
import 'package:draggable_float_widget/draggable_float_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../theme/theme.dart';

class PracticeQuestionsFloatWidget extends StatelessWidget {
  final void Function()? onTap;
  const PracticeQuestionsFloatWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return DraggableFloatWidget(
      key: ValueKey(MediaQuery.of(context).size),
      onTap: onTap,
      width: 330.wMin,
      height: 58.wMin,
      config: DraggableFloatWidgetBaseConfig(
        initPositionYInTop: true,
        initPositionXInLeft: true,
        delayShowDuration: const Duration(milliseconds: 200),
        animDuration: const Duration(milliseconds: 200),
        borderRight: 24.wMin,
        borderLeft: 24.wMin,
        borderTop: 110.wMin,
        exposedPartWidthWhenHidden: 70.wMin,
        borderBottom: 24.wMin + MediaQuery.of(context).padding.bottom,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          height: 58.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: AppTheme.cFeedbackDefaultBackground.color,
            border: Border.all(width: 1.wMin, color: AppTheme.cFeedbackDefaultBorder.color),
          ),
          child: Row(
            spacing: 8.wMin,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58.wMin,
                height: 88.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.wMin),
                  color: AppTheme.cFeedbackDefaultIcon.color,
                ),
                child: SvgPicture.asset(
                  "assets/svg/public/x.svg",
                  width: 48.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cStaticWhite.color, BlendMode.srcIn),
                ),
              ),
              Text(
                "不会做？点击跳过此题",
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cFeedbackDefaultText.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}