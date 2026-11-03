import 'package:flutter/material.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/widgets/build_image.dart';
import 'package:langwise/common/widgets/select_user_language_level_dialog.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import 'controller.dart';

class ManageEditLevel {
  static Future<LevelResponseEntity?>? show({
    required BuildContext context,
    required LevelResponseEntity levelEntity,
    void Function(int index)? onTap,
  }) {
    return Get.dialog<LevelResponseEntity?>(
      ManageEditLevelView(
        levelEntity: levelEntity,
      ),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    ).then((value) {
      return value;
    });
  }
}

class ManageEditLevelView extends GetView<ManageEditLevelController> {
  final LevelResponseEntity levelEntity;

  const ManageEditLevelView({super.key, required this.levelEntity});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: ManageEditLevelController(levelEntity),
        id: "manage_edit_level",
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
                        title: "编辑级别",
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
  Widget buildHandMovement(context) {
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
              title: "级别名",
              hintText: '请输入级别名',
              controller: controller.createNameController,
              required: true,
              onChanged: (text) => controller.getHandMovementButtonFlag(),
            ),
            Gaps.getHeight(24.wh),
            ManageTitleInputWidget(
              title: "级别描述",
              hintText: '请输入级别描述',
              required: true,
              controller: controller.createDesController,
              onChanged: (text) => controller.getHandMovementButtonFlag(),
            ),
            Gaps.getHeight(24.wh),
            ManageSelectWidget(
              title: "语言",
              hintText: '请选择语言',
              value: controller.createLanguageTitle,
              readOnly: true,
              required: true,
              options: CommonUtil.languageValues,
              onChanged: (String value, int index) {
                controller.setCreateLanguage(index);
              },
            ),
            Gaps.getHeight(24.wh),
            ManageSelectWidget(
              title: "上架状态",
              hintText: '请选择上架状态',
              value: controller.newAccessName,
              readOnly: false,
              required: true,
              options: StaticData.getOnOffShelfForCreateOrEditNames,
              onChanged: (String value, int index) {
                controller.setAccess(index);
              },
            ),
            Gaps.getHeight(24.wh),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 12.wh),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        // 红色星号
                        TextSpan(
                          text: '*',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14.wMin,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        TextSpan(
                          text: "tier",
                          style: TextStyle(
                            fontSize: 14.wMin,
                            color: const Color(0xffEBEEF3),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    CourseLevelTierEntityList? entityList = await SelectUserLanguageLevelDialog.show(
                      context: context,
                      showUnlocked: false,
                    );
                    if (entityList != null) {
                      controller.createTierTitle = entityList.tier;
                      controller.update(['tier_title']);
                    }
                  },
                  child: AnimatedContainer(
                    height: 50.wh,
                    duration: const Duration(milliseconds: 100),
                    padding: EdgeInsets.symmetric(horizontal: 12.ww),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.wMin),
                      color: Colors.transparent,
                      border: Border.all(
                        width: 1.wMin,
                        color: const Color(0xff4B5268),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GetBuilder<ManageEditLevelController>(
                            id: 'tier_title',
                            builder: (controller) {
                              return Text(
                                controller.createTierTitle?.toString() ?? '请选择级别等级',
                                style: controller.createTierTitle != null
                                    ? TextStyle(
                                        fontSize: 18.wMin,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xffEBEEF3),
                                      )
                                    : TextStyle(
                                        fontSize: 16.wMin,
                                        fontWeight: FontWeight.w400,
                                        color: const Color.fromRGBO(255, 255, 255, 0.4),
                                      ),
                              );
                            },
                          ),
                        ), // Expanded(
                        Gaps.getWidth(10.ww),
                        buildImage(Assets.managerSelecctOptionDown, width: 20.wMax, height: 20.wMax),
                      ],
                    ),
                  ),
                ),
              ],
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
            color: !controller.createButtonFlag.value ? const Color(0xff353E5C) : const Color(0xff2388FF),
            style: TextStyle(
              fontSize: 14.wMin,
              color: controller.createButtonFlag.value ? const Color(0xffEBEEF3) : const Color(0xffACB4C0),
              fontWeight: FontWeight.w400,
            ),
            borderColor: Colors.transparent,
            onTap: controller.createButtonFlag.value
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
