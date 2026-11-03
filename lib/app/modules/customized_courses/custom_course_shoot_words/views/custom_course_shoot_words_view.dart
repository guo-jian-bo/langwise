import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/customized_courses/custom_course_shoot_words/controllers/custom_course_shoot_words_controller.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/camera_macos_custom_curse_dialog.dart';
import 'package:langwise/common/widgets/camera_mobile_custom_curse_dialog.dart';
import 'package:langwise/common/widgets/camera_windows_custom_curse_dialog.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import '../../../../../theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../bindings/custom_course_shoot_words_binding.dart';

class CustomCourseShootWordsView
    extends GetView<CustomCourseShootWordsController> {
  final String tagText;
  const CustomCourseShootWordsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      CustomCourseShootWordsView(tagText: tag),
      binding: CustomCourseShootWordsBinding(tagText: tag),
      routeName: Routes.CUSTOM_COURSE_SHOOT_WORDS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppTheme.cBgPrimary,
        body: Stack(
          children: [
            _cameraWidget(),
            Obx(
              () => Visibility(
                visible: !controller.isShownTip.value,
                child: _wordListExample(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wordListExample() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cBgPrimary,
          borderRadius: BorderRadius.circular(12.wMin),
        ),
        child: Padding(
          padding: EdgeInsets.all(40.wMin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '拍摄小贴士',
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 30.wMin),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _exampleCard(
                    'assets/images/custom_course/course_word_list_right_one.png',
                    'assets/images/custom_course/course_word_list_right_two.png',
                    'assets/svg/public/icon_check.svg',
                    AppTheme.cFeedbackSuccessText,
                    '拍这个 (按课程顺序)',
                    '• 单词按 Unit 1, Unit 2... 分组\n• 标题常为 "Words in each unit" 或 "单元词汇"',
                  ),
                  SizedBox(width: 30.wMin),
                  _exampleCard(
                    'assets/images/custom_course/course_word_list_error_one.png',
                    'assets/images/custom_course/course_word_list_error_two.png',
                    'assets/svg/public/icon_clean.svg',
                    AppTheme.cFeedbackErrorText,
                    '不要拍这个 (按字母顺序)',
                    '• 所有单词混在一起，按 A, B, C... 排序\n• 标题常为 "Glossary" 或 "词汇索引 (Index)"',
                  ),
                ],
              ),
              SizedBox(height: 30.wMin),
              TapScaleWidget(
                onTap: () {
                  controller.isShownTip.value = true;
                },
                sclae: 1.1,
                child: Container(
                  width: 400.wMin,
                  height: 72.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.cTextBrand,
                    borderRadius: BorderRadius.circular(12.wMin),
                  ),
                  child: Text(
                    '已了解，我要扫描',
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _exampleCard(String imagePath1, String imagePath2, String tipImagePath,
      Color titleColor, String title, String subTitle) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cBgTertiary,
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Padding(
        padding: EdgeInsets.all(30.wMin),
        child: Column(
          //mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  tipImagePath,
                  width: 26.wMin,
                  height: 26.wMin,
                  colorFilter: ColorFilter.mode(
                    titleColor,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 10.wMin),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: titleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.wMin),
            Row(
              children: [
                Container(
                  width: 400.wMin,
                  height: 600.wMin,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.wMin),
                  ),
                  child: Image.asset(
                    imagePath1,
                    height: 320.wMin,
                  ),
                ),
                SizedBox(width: 20.wMin),
                Container(
                  width: 400.wMin,
                  height: 600.wMin,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.wMin),
                  ),
                  child: Image.asset(imagePath2),
                ),
              ],
            ),
            Container(
              width: 660.wMin,
              alignment: Alignment.centerLeft,
              child: Text(
                subTitle,
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cameraWidget() {
    if (Platform.isAndroid || Platform.isIOS) {
      return CameraMobileCustomCurseWidget(
        tagText: tagText,
        moduleId: controller.moduleId,
      );
    } else if (Platform.isMacOS) {
      return CameraMacOSCustomCurseWidget(
        tagText: tagText,
        moduleId: controller.moduleId,
        deviceId: controller.deviceId,
      );
    } else if (Platform.isWindows) {
      return CameraWindowsCustomCurseWidget(
        tagText: tagText,
        cameraDescription: controller.cameraDescription,
        moduleId: controller.moduleId,
      );
    }
    return const SizedBox.shrink();
  }
}
