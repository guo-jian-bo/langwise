import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:langwise/common/widgets/list_animation_widget.dart';
import 'package:themed/themed.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../controllers/guided_settings_controller.dart';

class GuidedSettingsView extends GetView<GuidedSettingsController> {
  const GuidedSettingsView({super.key});

  @override
  Widget build(BuildContext context) {

    /// 语言水平
    Widget buildLanguageLevel() {
      
      Widget languageItem(int index, String name, String content, String svg) {
        return ListAnimationWidget(
          index: index + 1,
          child: SizedBox(
            width: 560.wMin,
            child: CardSelectBoxWidget(
              onTap: () {
                controller.switchLanguageLevel(index);
              },
              svg: svg,
              isSelect: controller.selectLanguageLevelIndex.value == index,
              name: name,
              content: content,
            ),
          ),
        );
      }

      return CardBoxWidget(
        pageIndex: 0,
        currentPageIndex: controller.currentPageIndex.value,
        buttonDisable: controller.selectLanguageLevelIndex.value == -1,
        onContinue: () => controller.languageLevelContinue(),
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            SizedBox(height: 64.wMin, width: double.infinity),
            const CardTitleIconTextWidget(
              title: "你的英语水平怎么样？",
              svg: "assets/svg/guided_settings/title_lang_level.svg",
            ),
            Text(
              "按需学习，助你自信说英语。",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 64.wMin),
            Column(
              spacing: 24.wMin,
              children: [
                languageItem(0, "我是零基础", "从最简单开始，轻松开启英语之旅！", "assets/svg/guided_settings/beginner.svg"),
                languageItem(1, "我懂一点点英语", "先评估，再精准推荐学习起点！", "assets/svg/guided_settings/compass.svg"),
              ],
            ),
          ],
        ),
      );
    }

    /// 所处等级
    Widget buildYourLevel() {
      Widget yourLevelItem(int index, String name, String content, String svg) {
        return ListAnimationWidget(
          index: index + 1,
          child: SizedBox(
            width: 560.wMin,
            child: CardSelectBoxWidget(
              onTap: () {
                controller.switchYouLevel(index, context);
              },
              svg: svg,
              isSelect: controller.selectedLanguageLevel.value == index,
              name: name,
              content: content,
            ),
          ),
        );
      }

      return CardBoxWidget(
        pageIndex: 1,
        currentPageIndex: controller.currentPageIndex.value,
        onContinue: () => controller.youLevelContinue(),
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            SizedBox(height: 64.wMin, width: double.infinity),
            const CardTitleIconTextWidget(
              title: "你已知道自己所处的等级？",
              svg: "assets/svg/guided_settings/columnar.svg",
            ),
            Text(
              "按需学习，助你自信说英语。",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 64.wMin),
            Column(
              spacing: 16.wMin,
              children: [
                yourLevelItem(0, "请选择你所处的等级", "请根据实际情况学习会更高效哦", "assets/svg/guided_settings/thumb.svg"),
                yourLevelItem(1, "开始分级测试", "或者，参加分级测试。该测试大约需要 10分钟", "assets/svg/guided_settings/find.svg"),
              ],
            ),
          ],
        ),
      );
    }


    /// 想学的口音
    Widget buildLikeAccent() {

      Widget accentItemButton(int index, String name) {
        return TapScaleWidget(
          onTap: () {
            controller.switchAccent(index);
          },
          sclae: 1.01,
          child: AnimatedContainer(
            width: 332.wMin,
            duration: const Duration(milliseconds: 100),
            padding: EdgeInsets.all(16.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cTransparentBrand1.addOpacity(controller.accentIndex.value == index ? 1 : 0),
              borderRadius: BorderRadius.circular(16.wMin),
              border: Border.all(
                width: 1.wMin, 
                color: controller.accentIndex.value == index ? AppTheme.cBorderFocus : AppTheme.cBorderPrimary,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    CardSelectDotWidget(isSelected: controller.accentIndex.value == index),
                  ],
                ),
                SizedBox(height: 16.wMin),
                GridView.builder(
                  itemCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.wMin,
                    crossAxisSpacing: 16.wMin,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, index) {
                    return const CardKnowledgeWidget();
                  },
                ),
              ],
            ),
          ),
        );
      }

      return CardBoxWidget(
        pageIndex: 2,
        currentPageIndex: controller.currentPageIndex.value,
        buttonDisable: controller.accentIndex.value == -1,
        padding: EdgeInsets.zero,
        onContinue: () => controller.accentContinue(),
        child: Column(
          children: [
            SizedBox(height: 64.wMin, width: double.infinity),
            const CardTitleIconTextWidget(
              title: "你偏好哪种英语方言？",
              hideIcon: true,
            ),
            Text(
              "英式英语和美式英语在拼写、词汇和表达方式上有所不同",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16.wMin),
            CaedFunctionalDescriptionButton(
              onTap: () {
                controller.showVideo(context);
              },
            ),
            SizedBox(height: 32.wMin),
            ListAnimationWidget(
              index: 1,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 16.wMin,
                  children: [
                    accentItemButton(0, "英音"),
                    accentItemButton(1, "美音"),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    /// 音节划分模式
    Widget buildSyllableDivision() {

      /// 示例
      Widget _syllableDivisionExample(){
        return Column(
          spacing: 16.wMin,
          children: [
            Text(
              "示例",
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Column(
              spacing: 16.wMin,
              children: List.generate(2, (index){
                return SizedBox(
                  width: 140.wMin,
                  height: 140.wMin,
                  child: const CardKnowledgeImageWidget(),
                );
              }),
            ),
          ],
        );
      }

      ///item
      Widget _syllableDivisionItem(int index, String name){
        return TapScaleWidget(
          onTap: () {
            controller.switchSyllableDivision(index);
          },
          sclae: 1.01,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: EdgeInsets.all(8.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cTransparentBrand1.addOpacity(controller.syllableDivisionIndex.value == index ? 1 : 0),
              borderRadius: BorderRadius.circular(12.wMin),
              border: Border.all(
                width: 1.wMin,
                color: AppTheme.cBorderFocus.addOpacity(controller.syllableDivisionIndex.value == index ? 1 : 0),
              ),
            ),
            child: Column(
              spacing: 16.wMin,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Column(
                  spacing: 16.wMin,
                  children: List.generate(2, (index){
                    return Container(
                      width: 140.wMin,
                      height: 140.wMin,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.wMin),
                      ),
                      child: Text(
                        "cho-co-la-te",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      }

      return CardBoxWidget(
        pageIndex: 3,
        currentPageIndex: controller.currentPageIndex.value,
        buttonDisable: controller.syllableDivisionIndex.value == -1,
        padding: EdgeInsets.zero,
        onContinue: () => controller.syllableDivisionContinue(),
        child: Column(
          children: [
            SizedBox(height: 64.wMin, width: double.infinity),
            const CardTitleIconTextWidget(
              title: "请选择音节划分模式",
              hideIcon: true,
            ),
            Text(
              "考试不考音节划分，直观记忆更利于根据发音拼写单词",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16.wMin),
            CaedFunctionalDescriptionButton(
              onTap: () {
                controller.showVideo(context);
              },
            ),
            SizedBox(height: 48.wMin),
            ListAnimationWidget(
              index: 1,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _syllableDivisionExample(),
                    SizedBox(width: 8.wMin),
                    _syllableDivisionItem(0, "直观记忆"),
                    _syllableDivisionItem(1, "词典标准"),
                  ],
                ),
              ),
            ),


          ],
        ),
      );
    }

    /// 喜欢的风格
    Widget buildLikeStyle() {
      
      Widget styleItem(int index) {
        return SizedBox(
          width: 240.wMin,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.wMin),
            child: Column(
              children: [
                Container(
                  width: 240.wMin,
                  height: 240.wMin,
                  color: AppTheme.cBlackAlpha10,
                ),
                Container(
                  padding: EdgeInsets.all(16.wMin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4.wMin,
                    children: [
                      Text(
                        "教育插画",
                        style: TextStyle(
                          fontSize: 20.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        spacing: 16.wMin,
                        children: List.generate(2, (index){
                          return Container(//国旗图标
                            width: 30.wMin,
                            height: 25.wMin,
                            color: AppTheme.cBlackAlpha10,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return CardBoxWidget(
        pageIndex: 4,
        currentPageIndex: controller.currentPageIndex.value,
        padding: EdgeInsets.zero,
        onContinue: () => controller.styleContinue(),
        showButton1: true,
        button1Text: "设置视觉风格",
        onButton1: () => controller.toStyleSetting(),
        child: Column(
          children: [
            SizedBox(height: 64.wMin, width: double.infinity),
            const CardTitleIconTextWidget(
              title: "请选择沉浸学习环境",
              hideIcon: true,
            ),
            Text(
              "选择合适的视觉风格，可以让孩子融入文化，爱看爱学",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16.wMin),
            CaedFunctionalDescriptionButton(
              onTap: () {
                controller.showVideo(context);
              },
            ),
            SizedBox(height: 40.wMin),
            Text(
              "当前课程会用到的视觉风格",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16.wMin),
            ListAnimationWidget(
              index: 1,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 16.wMin,
                  children: List.generate(2, (index) {
                    return styleItem(index);
                  }),
                ),
              ),
            ),
          ],
        ),
      );
    }
    

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: const Color(0xff0E1014),
          extendBody: true,
          body: Container(
            padding: EdgeInsets.only(bottom: 80.wMin),
            child: Obx(() {
              return PageView(
                controller: controller.pageController,
                // physics: const NeverScrollableScrollPhysics(),
                children: [
                  buildLanguageLevel(),
                  if (controller.yourLevelShow.value) buildYourLevel(),
                  if(controller.likeAccentShow.value) buildLikeAccent(),
                  if(controller.syllableDivisionShow.value) buildSyllableDivision(),
                  if (controller.likeStyleShow.value) buildLikeStyle(),
                  
                ],
              );
            }),
          ),
        );
      },
    );
  }
}
