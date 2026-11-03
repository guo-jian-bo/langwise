import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/app/modules/user_center/views/user_center_language_widget.dart';
import 'package:langwise/common/entities/user_center_option_entity.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';

import '../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../routes/routes.dart';
import '../bindings/user_center_binding.dart';
import '../controllers/user_center_controller.dart';
import 'user_center_activate_students_widget.dart';
import 'user_center_assets_widget.dart';
import 'user_center_basic_widget.dart';
import 'user_center_member_widget.dart';
import 'user_center_students_widget.dart';
import 'user_center_theme_setting_widget.dart';
import 'user_visual_style_widget.dart';

class UserCenterView extends GetView<UserCenterController> {
  final String tagText;
  const UserCenterView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => UserCenterView(tagText: tag),
      binding: UserCenterBinding(tagText: tag),
      routeName: Routes.USER_CENTER,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GuidePageBoxWidget(
          pageCode: AppRoutesCode.userCenter,
          child: Scaffold(
            backgroundColor: AppTheme.cBgPrimary,
            body: Column(
              children: [
                _buildTitleWidget(context),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        child: Container(
                          alignment: Alignment.topCenter,
                          width: 1680.wMin,
                          child: Column(
                            children: [
                              SizedBox(height: 10.wMin),
                              Expanded(
                                child: Obx(() {
                                  if (controller.isLoading.value) return Container();
                                  return SingleChildScrollView(
                                    controller: controller.autoScrollController,
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).padding.bottom + 105.wMin,
                                      left: 10.wMin,
                                      right: 10.wMin,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildPersonalDataWidget(context),
                                        Obx(() {
                                          if (controller.userStore.userInfo.value.memberId == null) return Container();
                                          return AutoScrollTag(
                                            key: const ValueKey("AutoScrollTag1"),
                                            controller: controller.autoScrollController,
                                            index: 0,
                                            child: Container(
                                              margin: EdgeInsets.only(top: 24.wMin),
                                              child: UserCenterActivateStudentsWidget(tagText: tagText),
                                            ),
                                          );
                                        }),
                                        SizedBox(height: 24.wMin),
                                        GuideStepWidget(
                                          id: GuideWidgetIds.userCenterMyStudentListModule,
                                          child: UserCenterStudentsWidget(tagText: tagText),
                                        ),
                                        SizedBox(height: 16.wMin),
                                        Obx(() {
                                          if (controller.userStore.userInfo.value.memberId == null) return Container();
                                          return _buildLearningSettingsWidget(context);
                                        }),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 32.wMin,
                        left: 20.wMin,
                        child: _buildGuideTaskListButtonWidget(context),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

   /// 功能引导浮窗按钮
  Widget _buildGuideTaskListButtonWidget(BuildContext context){
    return Obx((){
      if(!GuideTaskController.to.hasGuideTask()) return Container();
      int uncompletedQuestCount = GuideTaskController.to.getUncompletedQuestCount();
      if(uncompletedQuestCount > 0) return Container();
      return TapScaleWidget(
        onTap: () async{
          controller.openTaskList(context);
        },
        sclae: 1.01,
        child: Container(
          width: 108.wMin,
          height: 108.wMin,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28.wMin),
            color: AppTheme.cBgSolid.color,
          ),
          child: PlatformBackdropFilterWidget(
            sigmaX: 8,
            sigmaY: 8,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28.wMin),
                color: AppTheme.cStaticBlack.color.withValues(alpha: 0.05),
                border: Border.all(
                  width: 1.wMin,
                  color: AppTheme.cInverseTextLight.color.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SvgPicture.asset(
                    "assets/svg/public/icon_guide.svg",
                    width: 40.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                  ),
                  Text(
                    "功能引导",
                    style: TextStyle(
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTitleWidget(BuildContext context) {
    return BreadcrumbWidget(
      actionWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 16.wMin),
          GuideStepWidget(
            id: GuideWidgetIds.userCenterInviterButton,
            onTap: () async {
              controller.toInviter();
            },
            sclae: 1.01,
            child: _buildTitleButtonWidget(text: "推荐有礼"),
          ),
          SizedBox(width: 16.wMin),
          Obx(() {
            String? helperVideoUrl = controller.userPreferenceOptionData.value.helperVideoUrl;
            if (helperVideoUrl == null || helperVideoUrl == "") return Container();
            return Container(
              margin: EdgeInsets.only(right: 10.wMin),
              child: HelpIVideoIconWidget(
                size: 32.wMin,
                padding: EdgeInsets.symmetric(horizontal: 20.wMin),
                helpVideoUrl: helperVideoUrl,
              ),
            );
          }),
          TapScaleWidget(
            onTap: () {
              controller.toAboutUs();
            },
            sclae: 1.1,
            child: Container(
              padding: EdgeInsets.all(16.wMin),
              color: Colors.transparent,
              child: SvgPicture.asset(
                "assets/svg/public/icon_setting1.svg",
                width: 32.wMin,
                height: 32.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleButtonWidget({
    required String text,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.wMin),
      height: 60.wMin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.wMin),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.0, 0.5, 1.0],
          colors: [
            Color(0xFFA78BFA),
            Color(0xFF818CF8),
            Color(0xFFD946EF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA78BFA),
            blurRadius: 10.wMin,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 28.wMin,
          color: AppTheme.cInverseTextLight.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 个人资料
  Widget _buildPersonalDataWidget(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            spacing: 20.wMin,
            children: [
              UserCenterBasicWidget(tagText: tagText),
              UserCenterMemberWidget(tagText: tagText),
            ],
          ),
        ),
        SizedBox(height: 24.wMin),
        Obx(() {
          if (!controller.userStore.userInfo.value.reviewStatus) {
            return Row(
              spacing: 20.wMin,
              children: [
                UserCenterCardCouponsWidget(tagText: tagText),
                UserCenterLearnPointsWidget(tagText: tagText),
                UserCenterNsCoinWidget(tagText: tagText),
              ],
            );
          }
          return Row(
            spacing: 20.wMin,
            children: [
              UserCenterLearnPointsWidget(tagText: tagText),
              UserCenterNsCoinWidget(tagText: tagText),
            ],
          );
        }),
      ],
    );
  }

  /// 学习设置
  Widget _buildLearningSettingsWidget(BuildContext context) {
    return AutoScrollTag(
      key: const ValueKey("AutoScrollTag2"),
      controller: controller.autoScrollController,
      index: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "学习偏好设置",
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20.wMin),
          UserCenterLanguageWidget(tagText: tagText),
          SizedBox(height: 34.wMin),
          //设置显示，播放速度
          Row(
            spacing: 16.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GuideStepWidget(
                  id: GuideWidgetIds.userCenterLearningPreferenceModule,
                  child: _preferenceWidget(controller.userPreferenceOptionData.value.exercisePreference, true),
                ),
              ),
              Expanded(
                child: GuideStepWidget(
                  id: GuideWidgetIds.userCenterExpandPreferenceModule,
                  child: _preferenceWidget(controller.userPreferenceOptionData.value.extensionPreference, false),
                ),
              ),
              
            ],
          ),
          UserVisualStyleWidget(tagText: tagText),
          SizedBox(height: 32.wMin),
          Row(
            spacing: 35.wMin,
            children: [UserCenterThemeSettingWidget(tagText: tagText), Expanded(child: Container())],
          ),
        ],
      ),
    );
  }

  Widget _preferenceWidget(UserPreferenceExercisePreference? preference, bool isStudy) {
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
                  isStudy ? 'assets/svg/user_center/icon_preference_study.svg' : 'assets/svg/user_center/icon_preference_extension.svg',
                  width: 30.wMin,
                  height: 30.wMin,
                ),
              ),
              SizedBox(width: 8.wMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preference!.title ?? "",
                      style: TextStyle(
                        fontSize: 28.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.wMin),
                    Text(
                      preference.description ?? "",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(preference.warning ?? '', style: TextStyle(fontSize: 24.wMin, color: AppTheme.cFeedbackWarningText))
                  ],
                ),
              ),
              SizedBox(width: 8.wMin),
            ],
          ),
          Container(
            height: 1.wMin,
            color: AppTheme.cBorderPrimary,
            margin: EdgeInsets.symmetric(vertical: 24.wMin),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              preference.definitionDisplayMode!.title ?? "",
              style: TextStyle(
                fontSize: 28.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.wMin),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cSurfaceTertiary,
                borderRadius: BorderRadius.circular(16.wMin),
              ),
              padding: EdgeInsets.all(4.wMin),
              child: Row(
                spacing: 4.wMin,
                children: List.generate(
                  preference.definitionDisplayMode!.options!.length,
                  (index) {
                    UserPreferenceDefinitionDisplayModeOption option = preference.definitionDisplayMode!.options![index]!;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (isStudy) {
                            controller.changeExerciseLanguagePreference(option.code!);
                          } else {
                            controller.changeExtensionLanguagePreference(option.code!);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.wMin),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isStudy
                                ? option.code == controller.exercisePreference.value
                                    ? AppTheme.cSurfaceInfo
                                    : AppTheme.cSurfaceQuaternary
                                : option.code == controller.extensionPreference.value
                                    ? AppTheme.cSurfaceInfo
                                    : AppTheme.cSurfaceQuaternary,
                            borderRadius: BorderRadius.circular(8.wMin),
                          ),
                          child: Text(preference.definitionDisplayMode!.options![index]!.title ?? "", style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextPrimary)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 8.wMin),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/svg/manage/icon_info_circle.svg',
                  width: 24.wMin,
                  height: 24.wMin,
                ),
                SizedBox(width: 8.wMin),
                Text(controller.getDescription(preference, isStudy), style: TextStyle(fontSize: 22.wMin, color: AppTheme.cTextBrand))
              ],
            )
          ]),
          _buildPlaySpeedWidget(preference.playSpeed ?? UserCenterOptionEntityNationalConfigsSpeed(), isStudy),
        ],
      ),
    );
  }

  /// 播放速度按钮
  Widget _buildPlaySpeedWidget(UserCenterOptionEntityNationalConfigsSpeed configSpeed, bool isStudy) {
    List<double?> playSpeeds = configSpeed.options ?? [];
    if (playSpeeds.isEmpty) return Container();

    double playSpeed = isStudy ? controller.playSpeed.value : controller.otherPlaySpeed.value;
    return Container(
      margin: EdgeInsets.only(top: 24.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.wMin,
        children: [
          Text(
            configSpeed.title ?? "",
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            width: double.infinity,
            height: 68.wMin,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 12.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: AppTheme.cSurfaceTertiary.color,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(playSpeeds.length, (index) {
                return TapScaleWidget(
                  onTap: () {
                    if (isStudy) {
                      controller.changePlaySpeed(playSpeeds[index] ?? 1.0);
                    } else {
                      controller.changeOtherPlaySpeed(playSpeeds[index] ?? 1.0);
                    }
                  },
                  sclae: 1,
                  child: Container(
                    height: 52.wMin,
                    width: 52.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: playSpeed == playSpeeds[index] ? AppTheme.cBgBrand.color : Colors.transparent,
                    ),
                    child: Text(
                      "${playSpeeds[index] ?? "1.0"}",
                      style: TextStyle(
                        fontSize: 22.wMin,
                        color: playSpeed == playSpeeds[index] ? AppTheme.cStaticWhite.color : AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}
