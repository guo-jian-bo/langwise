import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 评测结果弹窗
class EvaluationResultsDialog{

  static Future<void> show({
    required BuildContext context,
    int? tier,
    int? overall,
    String buttonText = "去查看",
  }) async{

    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return EvaluationResultsDialogWidget(
          tier: tier,
          overall: overall,
          buttonText: buttonText,
        );
      },
    );

  }

}

class EvaluationResultsDialogWidget extends StatefulWidget {
  final int? tier;
  final int? overall;
  final String buttonText;
  const EvaluationResultsDialogWidget({super.key, this.tier, this.overall, this.buttonText = "去查看"});

  @override
  State<EvaluationResultsDialogWidget> createState() => _EvaluationResultsDialogWidgetState();
}

class _EvaluationResultsDialogWidgetState extends State<EvaluationResultsDialogWidget> {

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Material(
        color: AppTheme.cOverlayBackground.color,
        child: Center(
          child: Container(
            width: 800.wMin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.wMin),
              color: AppTheme.cBgSecondary.color,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.wMin),
                color: AppTheme.cBgSecondary.color,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.cBgBrand.color.withValues(alpha: 0.3),
                    AppTheme.cBgBrand.color.withValues(alpha: 0),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 64.wMin),
                  _buildTitleWidget(),
                  SizedBox(height: 48.wMin),
                  _buildLevelWidget(),
                  SizedBox(height: 32.wMin),
                  _buildScoreWidget(),
                  SizedBox(height: 64.wMin),
                  _buildButtonWidget(),
                  SizedBox(height: 56.wMin),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Column(
      children: [
        Text(
          "恭喜你完成评测",
          style: TextStyle(
            fontSize: 56.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SizedBox(height: 24.wMin),
        Text(
          "您的评测已完成",
          style: TextStyle(
            fontSize: 36.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelWidget(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 24.wMin,
      children: [
        SvgPicture.asset(
          "assets/svg/public/icon_union_left.svg",
          height: 150.wMin,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          child: Container(
            constraints: BoxConstraints(
              minHeight: 150.wMin,
            ),
            child: FutureBuilder<bool>(
              initialData: false,
              future: Future.delayed(const Duration(milliseconds: 300), (){
                return true;
              }),
              builder: (context, snapshot) {
                if(!(snapshot.data??false)) return const SizedBox();
                return Column(
                  children: [
                    Text(
                      "最终等级",
                      style: TextStyle(
                        fontSize: 28.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                    Text(
                      "Level ${widget.tier??0}",
                      style: TextStyle(
                        fontSize: 90.wMin,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cTextPrimary.color,
                        height: 1.15,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        SvgPicture.asset(
          "assets/svg/public/icon_union_right.svg",
          height: 150.wMin,
        ),

      ],
    );
  }

  Widget _buildScoreWidget(){
    return Column(
      children: [
        Text(
          "本次评测得分",
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        Text.rich(TextSpan(
          style: TextStyle(
            fontSize: 100.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cFeedbackWarningText.color,
            height: 1.25,
          ),
          children: [
            TextSpan(text: "${widget.overall??0}"),
            TextSpan(
              text: "分",
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cFeedbackWarningText.color,
              ),
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildButtonWidget(){
    return ButtonWidget(
      text: widget.buttonText,
      width: 560.wMin,
      height: 80.wMin,
      borderRadius: 12.wMin,
      color: AppTheme.cSurfaceBrand.color,
      fontColor: AppTheme.cStaticWhite.color,
      fontWeight: FontWeight.w500,
      fontSize: 28.wMin,
      sclae: 1.03,
      onTap: () {
        Get.back(result: true);
      },
    );
  }



}