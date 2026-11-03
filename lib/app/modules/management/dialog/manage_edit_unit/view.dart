import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'controller.dart';

class ManageEditUnitDialog {
  static Future<NewUnitResponseEntity?>? show({
    required BuildContext context,
    required NewUnitResponseEntity unitEntity,
    void Function(int index)? onTap,
    bool hidsDifficulty = false,
  }) {
    return Get.dialog<NewUnitResponseEntity?>(
      ManageEditUnitView(
        unitEntity: unitEntity,
        hidsDifficulty: hidsDifficulty,
      ),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    ).then((value) {
      print('---编辑单元弹框消失value:$value---');
      return value;
    });
  }
}

class ManageEditUnitView extends GetView<ManageEditUnitController> {
  final NewUnitResponseEntity unitEntity;
  final bool hidsDifficulty;

  const ManageEditUnitView({super.key, required this.unitEntity, this.hidsDifficulty = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: ManageEditUnitController(unitEntity),
        id: "manage_edit_unit",
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
                        title: "编辑单元",
                        onCloseTap: () {
                          Get.back();
                        },
                      ),
                      Gaps.getHeight(27.wh),
                      buildHandMovement(),
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
  Widget buildHandMovement() {
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
              title: "单元ID",
              hintText: '请输入单元ID',
              controller: controller.idController,
              required: true,
              readOnly: true,
            ),
            Gaps.getHeight(24.wh),
            ManageTitleInputWidget(
              title: "单元名",
              hintText: '请输入单元名',
              controller: controller.createNameController,
              required: true,
              onChanged: (text) => controller.getHandMovementButtonFlag(),
            ),
            Gaps.getHeight(24.wh),
            ManageTitleInputWidget(
              title: "单元描述",
              hintText: '请输入单元描述',
              required: false,
              controller: controller.createDesController,
              onChanged: (text) => controller.getHandMovementButtonFlag(),
            ),
            Gaps.getHeight(24.wh),
            ManageSelectWidget(
              title: "语言",
              hintText: '请选择语言',
              value: controller.createLanguageTitle,
              readOnly: controller.createSelectLanguageIndex != -1,
              required: true,
              options: CommonUtil.languageValues,
              onChanged: (String value, int index) {
                controller.setCreateLanguage(index);
              },
            ),
            Visibility(
              visible: !hidsDifficulty,
              child: Container(
                margin: EdgeInsets.only(top: 24.wh),
                child: Row(
                  children: [
                    Flexible(
                      child: ManageSelectWidget(
                        title: "难度水平(最小)",
                        hintText: '请选择难度水平(最小)',
                        readOnly: false,
                        required: true,
                        value: controller.difficultyMinValue,
                        options: controller.difficultieList.map((e) => e.name?.text ?? "").toList(),
                        onChanged: (String value, int index) {
                          controller.setCreateMinDifficulty(index);
                        },
                      ),
                      flex: 1,
                    ),
                    Gaps.getWidth(30.ww),
                    Flexible(
                      child: ManageSelectWidget(
                        title: "难度水平(最大)",
                        hintText: '请选择难度水平(最大)',
                        readOnly: false,
                        required: true,
                        value: controller.difficultyMaxValue,
                        options: controller.difficultieList.map((e) => e.name?.text ?? "").toList(),
                        onChanged: (String value, int index) {
                          controller.setCreateMaxDifficulty(index);
                        },
                      ),
                      flex: 1,
                    ),
                  ],
                ),
              ),
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
