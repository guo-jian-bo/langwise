
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/widgets/list_animation_widget.dart';
import '../../../../../theme/theme.dart';
import '../../common/elements_ai_animation_widget.dart';
import '../controllers/elements_upgrade_card_controller.dart';

class ElementsUpgradeCardView extends GetView<ElementsUpgradeCardController> {
  const ElementsUpgradeCardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Container(
        padding: EdgeInsets.only(
          top: 56.wMin + MediaQuery.of(context).padding.top,
          left: 68.wMin,
          right: 68.wMin,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BackWidget(title: ""),
                Text(
                  '升卡智能分析',
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextPrimary,
                  ),
                ),
                SizedBox(width: 72.wMin),
              ],
            ),

            Expanded(
              child: SizedBox(
                width: 1075.wMin,
                child: Obx(() {
                  if(controller.aiRunCompleted.value){
                    return Center(
                      child: _buildResultWidget(),
                    );
                  }
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 100.wMin + MediaQuery.of(context).padding.bottom),
                    child: Container(
                      margin: EdgeInsets.only(top: 85.wMin),
                      child: _buildAiWidget(),
                    ),
                  );
                }),
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: Obx((){
        if(!controller.aiRunCompleted.value){
          return Container(height: 0);
        }
        return ListAnimationWidget(
          child: Container(
            height: 64.wMin + 80.wMin + 20.wMin,
            alignment: Alignment.topCenter,
            padding: EdgeInsets.only(top: 20.wMin),
            child: ButtonWidget(
              text: "开始升卡挑战",
              width: 500.wMin,
              height: 80.wMin,
              color: AppTheme.cFeedbackInfoText,
              borderRadius: 8.wMin,
              fontSize: 28.wMin,
              fontColor: AppTheme.cStaticWhite,
              fontWeight: FontWeight.w600,
              sclae: 1.03,
              onTap: (){
                Get.back(result: true);
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResultWidget(){
    return ListAnimationWidget(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cBgSecondary,
              borderRadius: BorderRadius.circular(12.wMin),
            ),
            child: Column(
              spacing: 24.wMin,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset("assets/svg/elements/icon_sparkle.svg", width: 24.wMin),
                    SizedBox(width: 6.wMin),
                    Text(
                      "全面扫描您的卡片学习情况",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cTextPrimary,
                      ),
                    ),
                  ],
                ),
                _buildProgressWidget("发音准确度", "薄弱项", AppTheme.cPronunciationAccuracy),
                _buildProgressWidget("语境应用能力", "需要加强", AppTheme.cContextApplicationAbility),
                _buildProgressWidget("语法结构掌握", "良好", AppTheme.cMasteryOfGrammaticalStructures),
              ],
            ),
          ),
          SizedBox(height: 24.wMin),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cBgSecondary,
              borderRadius: BorderRadius.circular(12.wMin),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset("assets/svg/elements/icon_rocket_launch1.svg", width: 24.wMin),
                    SizedBox(width: 6.wMin),
                    Text(
                      "薄弱项强化计划",
                      style: TextStyle(
                        fontSize: 28.wMin,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cTextPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.wMin),
                _buildTextItemWidget("发音练习：重点强化发音薄弱项，提高发音准确度", AppTheme.cPronunciationAccuracy),
                SizedBox(height: 8.wMin),
                _buildTextItemWidget("语境应用：通过真实语境中的应用场景强化语境理解能力", AppTheme.cContextApplicationAbility),
                
              ],
            ),
          ),
          SizedBox(height: 24.wMin),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10.wMin),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.cFeedbackInfoBackground,
              borderRadius: BorderRadius.circular(8.wMin),
            ),
            child: Text(
              "升卡分析完成！我们已针对您的薄弱项生成了定制化的强化训练计划。完成这些练习将显著提升您的知识点掌握度。",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cFeedbackInfoText,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextItemWidget(String value, Color color){
    return Row(
      spacing: 4.wMin,
      children: [
        Container(
          width: 12.wMin,
          height: 12.wMin,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary,
          ),
        ),
      ],
    );
  }

  /// 进度
  Widget _buildProgressWidget(String name, String info, Color color){
    return Column(
      spacing: 2.wMin,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary,
              ),
            ),
            Text(
              info,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: double.infinity,
              height: 12.wMin,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: AppTheme.cFeedbackDefaultBackground,
                borderRadius: BorderRadius.circular(100.wMin),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                height: double.infinity,
                width: 120.wMin,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(100.wMin),
                ),
              ),
            );
          },
        ),

      ],
    );
  }


  Widget _buildAiWidget(){
    return ElementsAiAnimationWidget(
      introduce: "升卡功能将分析当前知识点的薄弱项，并生成针对性的强化练习。",
      knowledge: controller.knowledge,
      onComplete: (result) {
        controller.aiRunCompleted.value = true;
      },
      animationList: [
        AiAnimationModel(
          name: "全面扫描您的卡片学习情况",
          svgBackColor: const Color(0xffC084FC),
          iconSvg: "assets/svg/elements/icon_battle.svg",
          subName: "分析语言模式",
        ),
        AiAnimationModel(
          name: "分析您的知识薄弱项和潜力领域",
          svgBackColor: const Color(0xff38BDF8),
          iconSvg: "assets/svg/elements/icon_chart_line_up.svg",
          subName: "计算知识点相关性",
        ),
        AiAnimationModel(
          name: "匹配针对性的升卡挑战类型",
          svgBackColor: const Color(0xffFB923C),
          iconSvg: "assets/svg/elements/icon_lightbulb.svg",
          subName: "匹配最佳挑战类型",
        ),
        AiAnimationModel(
          name: "生成强化薄弱项的个性化内容",
          svgBackColor: const Color(0xff2DD4BF),
          iconSvg: "assets/svg/elements/icon_robot.svg",
          subName: "生成个性化内容",
        ),
        AiAnimationModel(
          name: "升卡分析完成！",
          svgBackColor: AppTheme.cFeedbackSuccessIcon,
          iconSvg: "assets/svg/elements/icon_check_circle.svg",
          showProgress: false,
        ),
      ],
    );
  }

}
