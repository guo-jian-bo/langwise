import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/user_center/controllers/user_center_controller.dart';
import 'package:langwise/common/entities/user_center_option_entity.dart';
import 'package:langwise/common/values/language_service_code.dart';
import 'package:langwise/common/widgets/user_center_widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class UserCenterLanguageWidget extends GetView<UserCenterController> {
  /// 用户中心 语言显示偏好
  final String tagText;
  const UserCenterLanguageWidget({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  Widget build(BuildContext context) {
    var data = controller.userPreferenceOptionData.value.languageLearningPreference;
    return Obx(() => Container(
          padding: EdgeInsets.all(24.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cBgSecondary.color,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      'assets/svg/user_center/icon_language_preference.svg',
                      width: 30.wMin,
                      height: 30.wMin,
                    ),
                  ),
                  SizedBox(width: 8.wMin),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4.wMin,
                      children: [
                        Text(
                          data?.title ?? "",
                          style: TextStyle(
                            fontSize: 28.wMin,
                            color: AppTheme.cTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          data?.description??'',
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cTextSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.wMin),
                ],
              ),
              SizedBox(height: 24.wMin),
              Container(height: 1.wMin, color: AppTheme.cBorderPrimary),
              SizedBox(height: 24.wMin),
              Text(data!.languageSetting!.title??'语言设置',
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w500,
                  )),
              SizedBox(height: 8.wMin),
              Row(
                  spacing: 24.wMin,
                  children: [
                    Expanded(child: _languageSelectWidget(data.languageSetting!.learningLanguage?.title ?? "", data.languageSetting!.learningLanguage?.languages ?? [])),
                    Expanded(child: _languageSelectWidget(data.languageSetting!.translationLanguage?.title ?? "", data.languageSetting!.translationLanguage?.languages ?? []))
                  ]),
              SizedBox(height: 24.wMin),
              Text(data.nationalConfigs!.title??'英语方言设置',
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w500,
                  )),
              SizedBox(height: 8.wMin),
              _buildDialectSelectWidget(controller.userPreferenceOptionData.value.languageLearningPreference?.nationalConfigs?.options ?? []),
            ],
          ),
        ));
  }

  Widget _buildDialectSelectWidget(List<UserCenterOptionEntityNationalConfigsOptions?> options) {
    return IntrinsicHeight(
        child: Row(
      spacing: 16.wMin,
      children: List.generate(options.length, (index) {
        UserCenterOptionEntityNationalConfigsOptions? option = options[index];
        if (option == null) return Container();
        return Expanded(
          child: UserSettingSelectCardWidget(
            title: option.title ?? "",
            subTitle: option.description ?? "",
            value: option.content ?? "",
            audio: option.audioUrl,
            showRecommendedTags: options[index]?.code == LanguageServiceCode.US,
            selected: controller.currentLanguageDialectCode.value == option.code,
            onTap: () => controller.changeLanguageDialect(option.code ?? ""),
          ),
        );
      }),
    ));
  }

  Widget _languageSelectWidget(String intro, List<UserCenterOptionEntityLanguagePreferenceLanguages?> languages) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.wMin), color: AppTheme.cSurfaceTertiary.color),
      padding: EdgeInsets.all(8.wMin),
      child: Row(
        children: [
          SizedBox(width: 8.wMin),
          Text(
            intro,
            style: TextStyle(color: AppTheme.cTextPrimary, fontSize: 24.wMin, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Container(
            width: 200.wMin,
            height: 56.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.wMin),
              color: AppTheme.cSurfaceQuaternary.color,
            ),
            child: Text(
              languages.isEmpty ? '' : languages[0]!.title ?? '',
              style: TextStyle(color: AppTheme.cTextPrimary, fontSize: 24.wMin, fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }
}
