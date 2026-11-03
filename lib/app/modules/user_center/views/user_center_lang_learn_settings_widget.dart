
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';

class UserCenterLangLearnSettingsWidget extends StatelessWidget {
  /// 学习语言设置
  const UserCenterLangLearnSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ConfigController configController = Get.find<ConfigController>();
    return Container(
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceSecondary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50.wMin,
                height: 50.wMin,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cFeedbackInfoBackground,
                ),
                child: SvgPicture.asset(
                  "assets/svg/public/icon_settings.svg",
                  width: 30.wMin,
                  height: 30.wMin,
                ),
              ),
              SizedBox(width: 8.wMin),
              Text(
                "语言学习设置",
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.wMin),
          Container(height: 1.wMin, color: AppTheme.cBorderPrimary),
          SizedBox(height: 24.wMin),
          Row(
            spacing: 32.wMin,
            children: [
              _buildLanguageLearningSettingSelectWidget("目标语言", configController.getLangStr(configController.userSetting.value.learningLang)),
              _buildLanguageLearningSettingSelectWidget("辅助语言", configController.getLangStr(configController.userSetting.value.localLang)),
            ],
          ),
          SizedBox(height: 24.wMin),
          Text(
            "释义与翻译",
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.wMin),
          Row(
            spacing: 16.wMin,
            children: [
              _buildLanguageLearningSettingsTypeWidget("沉浸模式", "仅用英语学习和理解", configController.userSetting.value.learningLang),
              _buildLanguageLearningSettingsTypeWidget("双语对照", "英语、中文双语显示，方便比较", ""),
              _buildLanguageLearningSettingsTypeWidget("辅助翻译", "主要使用中文释义帮助理解", configController.userSetting.value.localLang),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageLearningSettingsTypeWidget(String name, String subTitle, String lang){
    // ConfigController configController = Get.find<ConfigController>();
    return Expanded(
      child: TapScaleWidget(
        onTap: () {
          // configController.setLearLangSetting(lang);
        },
        sclae: 1.01,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 40.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: AppTheme.cBgTertiary.color,
            border: Border.all(
              width: 2.wMin,
              // color: AppTheme.cBorderBrand.withValues(alpha: configController.learningLangShowSetting.value == lang ? 1 : 0),
            ),
          ),
          child: Column(
            spacing: 8.wMin,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                subTitle,
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 语言学习设置
  Widget _buildLanguageLearningSettingSelectWidget(String title, String enText){
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 16.wMin, right: 8.wMin, top: 8.wMin, bottom: 8.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: AppTheme.cBgTertiary.color,
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              width: 200.wMin,
              height: 56.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.wMin),
                color: AppTheme.cBorderPrimary.color,
              ),
              child: Text(
                enText,
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}