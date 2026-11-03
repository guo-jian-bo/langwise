import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../common/recommended_tags_widget.dart';
import '../controllers/user_center_controller.dart';

class UserCenterThemeSettingWidget extends GetView<UserCenterController> {
  /// 用户中心 主题设置
  const UserCenterThemeSettingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceSecondary.color,
        ),
        child: Obx(() {
          String currentThemeKey = controller.userStore.userInfo.value.config?.theme ?? AppThemeKey.dark.value;
          String currentThemeName = AppTheme.appThemeNames[currentThemeKey] ?? "";
          UserPreferenceThemePreference? themeConfigs = controller.userPreferenceOptionData.value.themePreference;

          if (themeConfigs?.options?.isNotEmpty ?? false) {
            for (UserCenterOptionEntityThemeConfigsOptions? option in themeConfigs!.options!) {
              if (option?.code == currentThemeKey) {
                currentThemeName = option?.title ?? "";
              }
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserTapTitleWidget(
                title: themeConfigs?.title ?? "",
                subTitle: themeConfigs?.description ?? "",
                value: currentThemeName,
                svg: "assets/svg/user_center/icon_theme.svg",
              ),
              SizedBox(height: 24.wMin),
              Container(height: 1.wMin, color: AppTheme.cBorderPrimary),
              SizedBox(height: 24.wMin),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 16.wMin,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(themeConfigs?.options?.length ?? 0, (index) {
                    return _buildThemeSettingItemWidget(themeConfigs?.options?[index]);
                  }),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildThemeSettingItemWidget(UserCenterOptionEntityThemeConfigsOptions? option) {
    String themeKey = option?.code ?? "";
    Color backColor = const Color(0xff222325);
    Color lineColor = const Color(0xff2C2D2F);

    if (themeKey == AppThemeKey.dark.value) {
      backColor = const Color(0xff000000);
      lineColor = const Color(0x29FFFFFF);
    } else if (themeKey == AppThemeKey.light.value) {
      backColor = const Color(0xffFFFFFF);
      lineColor = const Color(0x1A000000);
    }

    return TapScaleWidget(
      onTap: () {
        controller.changeTheme(themeKey);
      },
      sclae: 1.03,
      child: Container(
        width: 378.wMin,
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: Column(
          spacing: 8.wMin,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  option?.title ?? "",
                  style: TextStyle(
                    fontSize: 28.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 6.wMin),
                Visibility(
                  visible: themeKey == AppThemeKey.dark.value,
                  child: const RecommendedTagsWidget(),
                ),
                const Spacer(),
                Obx(() {
                  String currentThemeKey = controller.userStore.userInfo.value.config?.theme ?? AppThemeKey.dark.value;
                  return CardSelectDot1Widget(isSelected: currentThemeKey == themeKey);
                }),
              ],
            ),
            Text(
              option?.description ?? "",
              style: TextStyle(
                fontSize: 22.wMin,
                color: AppTheme.cTextSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            Container(
              height: 132.wMin,
              padding: EdgeInsets.all(16.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: backColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildThemeSettingDivWidget(172.wMin, lineColor),
                  _buildThemeSettingDivWidget(88.wMin, lineColor),
                  _buildThemeSettingDivWidget(212.wMin, lineColor),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Container(
                      height: 20.wMin,
                      width: 48.wMin,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.wMin),
                        color: AppTheme.cInversePrimary.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSettingDivWidget(double width, Color lineColor) {
    return Container(
      height: 14.wMin,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.wMin),
        color: lineColor,
      ),
    );
  }
}
