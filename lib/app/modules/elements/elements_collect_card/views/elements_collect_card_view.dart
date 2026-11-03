import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/widgets/list_animation_widget.dart';
import '../../../../../theme/theme.dart';
import '../../common/elements_ai_animation_widget.dart';
import '../../../../../common/enum/elements_card_type.dart';
import '../controllers/elements_collect_card_controller.dart';

class ElementsCollectCardView extends GetView<ElementsCollectCardController> {
  const ElementsCollectCardView({super.key});
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
                    return _buildResultWidget();
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
              text: "开始集卡学习",
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
    return SingleChildScrollView(
      child: ListAnimationWidget(
        child: Column(
          children: [
            SizedBox(
              height: 400.wMin,
              child: Stack(
                children: [
                  Positioned(
                    left: 150.wMin,
                    top: 152.wMin,
                    child: _buildBubblesWidget("相关短语", 180.wMin, AppTheme.cPhraseCardColor1),
                  ),
                  Positioned(
                    left: 372.wMin,
                    top: 48.wMin,
                    child: _buildBubblesWidget("当前知识", 220.wMin, AppTheme.cWordCardColor1),
                  ),
                  Positioned(
                    left: 584.wMin,
                    top: 216.wMin,
                    child: _buildBubblesWidget("相关单词", 180.wMin, AppTheme.cWordCardColor1),
                  ),
                  Positioned(
                    left: 741.wMin,
                    top: 49.wMin,
                    child: _buildBubblesWidget("相关句子", 180.wMin, AppTheme.cSentenceCardColor1),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.wMin),
            Row(
              children: [
                SvgPicture.asset("assets/svg/elements/icon_sparkle.svg", width: 24.wMin),
                SizedBox(width: 6.wMin),
                Text(
                  "推荐学习的新知识点",
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.wMin),
      
            Column(
              spacing: 12.wMin,
              children: List.generate(3, (index) {
                return _buildKnowledgeWidget();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKnowledgeWidget(){
    ConfigController configController = Get.find<ConfigController>();

    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cBgTertiary,
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16.wMin,
            children: [
              Expanded(
                child: Text(
                  "orange",
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextPrimary,
                  ),
                ),
              ),
              Text(
                "85%",
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.wMin),
          Row(
            spacing: 8.wMin,
            children: [
              StatusKnowlegeTypeTagWidget(
                padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
                type: ElementsCardType.word, 
                value: "单词",
              ),
              StatusTagDifficultyWidget(language: configController.userSetting.value.learningLang, difficulty: 1, fontSize: 18.wMin),
            ],
          ),
          SizedBox(height: 16.wMin),
          Text(
            "与当前知识点在同一语义场景中经常共现",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubblesWidget(String text, double size, Color color){
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 4.wMin, color: color),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: SvgPicture.asset("assets/svg/elements/icon_bubble_bg.svg"),
          ),
          Positioned.fill(
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
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
          name: "全面扫描您的知识图谱",
          svgBackColor: const Color(0xffC084FC),
          iconSvg: "assets/svg/elements/icon_battle.svg",
          subName: "扫描知识网络",
        ),
        AiAnimationModel(
          name: "分析您的学习边界和潜力领域",
          svgBackColor: const Color(0xff38BDF8),
          iconSvg: "assets/svg/elements/icon_scan.svg",
          subName: "评估学习曲线",
        ),
        AiAnimationModel(
          name: "搜索知识网络中的关联知识点",
          svgBackColor: const Color(0xffFB923C),
          iconSvg: "assets/svg/elements/icon_search.svg",
          subName: "扫描知识网络",
        ),
        AiAnimationModel(
          name: "发现适合您学习的新知识点",
          svgBackColor: const Color(0xff2DD4BF),
          iconSvg: "assets/svg/elements/icon_push_pin.svg",
          subName: "构建知识关联图",
        ),
        AiAnimationModel(
          name: "集卡分析完成！",
          svgBackColor: AppTheme.cFeedbackSuccessIcon,
          iconSvg: "assets/svg/elements/icon_check_circle.svg",
          showProgress: false,
        ),
      ],
    );
  }
}
