import 'package:flutter/material.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_public_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'manage_edit_course_controller.dart';

class ManageEditCourse {
  static Future<Map<String, dynamic>?>? show({
    required BuildContext context,
    required CourseResponseEntity courseEntity,
    void Function(int index)? onTap,
  }) {
    return Get.dialog<Map<String, dynamic>?>(
      ManageEditCourseView(
        courseEntity: courseEntity,
      ),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    );
  }
}

class ManageEditCourseView extends GetView<ManageEditCourseController> {
  final CourseResponseEntity courseEntity;

  const ManageEditCourseView({super.key, required this.courseEntity});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: ManageEditCourseController(courseEntity),
        id: "manage_edit_course",
        builder: (_) {
          return LayoutBuilder(builder: (context, constraints) {
            return Scaffold(
              backgroundColor: const Color(0xff040712).withValues(alpha: 0.8),
              body: Center(
                child: Container(
                  width: 1080.ww,
                  padding: EdgeInsets.symmetric(horizontal: 24.ww, vertical: 24.wh),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.wMin),
                    border: Border.all(
                      color: const Color(0xff444B5F),
                      width: 1.wMin, // 边框宽度
                    ),
                    color: const Color(0xff181B25),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ManageTitleWidget(
                        title: "编辑课程",
                        onCloseTap: () {
                          Get.back();
                        },
                      ),
                      Gaps.getHeight(27.wh),
                      buildHandMovement(context),
                      Gaps.getHeight(24.wh),
                      _buildBottomWidget(),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  /// 手动
  Widget buildHandMovement(BuildContext context) {
    return Container(
      height: 580.wh,
      padding: EdgeInsets.symmetric(horizontal: 16.ww, vertical: 16.wh),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: const Color(0xff22293C),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            ManageTitleInputWidget(
              title: "课程名",
              hintText: '请输入课程名',
              controller: controller.handMovementName,
              onChanged: (text) => controller.getHandMovementButtonFlag(),
            ),
            SizedBox(height: 24.wh),
            ManageSelectWidget(
              title: "语言",
              hintText: '请选择语言',
              value: controller.createLanguageTitle,
              controller: controller.handMovementName,
              readOnly: true,
              required: true,
              options: CommonUtil.languageValues,
              onChanged: (String value, int index) {
                controller.setCreateLanguage(index);
              },
            ),
            Gaps.getHeight(24.wh),
            ManageAddCover(
              icon: Assets.managerAdd,
              filePath: controller.courseEntity.coverUrl,
              onTap: () {
                return controller.onAddCover(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ManageButton(
          text: "取消",
          width: 80.ww,
          height: 40.wh,
          borderColor: const Color(0xff666F8D),
          style: TextStyle(
            fontSize: 14.wMin,
            color: const Color(0xffEBEEF3),
            fontWeight: FontWeight.w400,
          ),
          onTap: () => Get.back(),
        ),
        SizedBox(width: 11.ww),
        Obx(() {
          return ManageButton(
            text: "确定",
            width: 80.ww,
            height: 40.wh,
            color: !controller.handMovementButtonFlag.value ? const Color(0xff353E5C) : const Color(0xff2388FF),
            style: TextStyle(
              fontSize: 14.wMin,
              color: controller.handMovementButtonFlag.value ? const Color(0xffEBEEF3) : const Color(0xffACB4C0),
              fontWeight: FontWeight.w400,
            ),
            borderColor: Colors.transparent,
            onTap: controller.handMovementButtonFlag.value
                ? OptimizeUtils.noneThrottle(() {
                    controller.onConfirm();
                  }, 100)
                : null,
          );
        }),
      ],
    );
  }
}
