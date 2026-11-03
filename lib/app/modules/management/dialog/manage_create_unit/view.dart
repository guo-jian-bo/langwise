import 'package:flutter/material.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_public_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'controller.dart';

class ManageCreateUnitManager {
  static Future<bool?>? show({
    required BuildContext context,
    void Function(int index)? onTap,
  }) {
    return Get.dialog<bool?>(
      const ManageCreateUnitView(),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    ).then((value) {
      return value;
    });
  }
}

class ManageCreateUnitView extends GetView<ManageCreateUnitController> {
  const ManageCreateUnitView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: ManageCreateUnitController(),
        id: "manage_create_unit",
        builder: (_) {
          return LayoutBuilder(builder: (context, constraints) {
            return Scaffold(
              backgroundColor: const Color(0xff040712).withValues(alpha: 0.8),
              body: Center(
                child: Container(
                  width: 1080.ww,
                  height: 880.wh,
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
                        title: "创建单元",
                        onCloseTap: () {
                          Get.back();
                        },
                      ),
                      Gaps.getHeight(27.wh),
                      Row(
                        children: [
                          buildTitleWay("复制单元", "从现有单元创建，支持调整学习顺序。", 0),
                          SizedBox(width: 16.ww),
                          buildTitleWay("导入单元", "一键导入单元，快速规划阶段内容。", 1),
                          SizedBox(width: 16.ww),
                          buildTitleWay("手动创建", "完全手动输入。", 2),
                        ],
                      ),
                      Gaps.getHeight(16.wh),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        child: Obx(() {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Builder(
                              key: ValueKey(controller.createWay.value),
                              builder: (context) {
                                if (controller.createWay.value == 1) {
                                  return buildImport();
                                } else if (controller.createWay.value == 2) {
                                  return buildHandMovement();
                                }
                                return buildCopy();
                              },
                            ),
                          );
                        }),
                      ),
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

  Widget buildTitleWay(String name, String info, int index) {
    return Obx(() {
      return ManageTitleWay(
        name: name,
        info: info,
        selected: controller.createWay.value == index,
        onTap: () {
          controller.createWay(index);
        },
      );
    });
  }

  /// 复制
  Widget buildCopy() {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Container(
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
                focusOrder: 0,
                title: "原单元 ID",
                hintText: '请输入原单元 ID',
                required: true,
                controller: controller.copyOriginalIDController,
                onChanged: (text) => controller.getCopyButtonFlag(),
              ),
              Gaps.getHeight(24.wh),
              ManageTitleInputWidget(
                focusOrder: 1,
                title: "单元名",
                hintText: '请输入原单元名',
                required: true,
                controller: controller.copyNameController,
                onChanged: (text) => controller.getCopyButtonFlag(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 导入
  Widget buildImport() {
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
              title: "单元名",
              hintText: '请输入单元名',
              controller: controller.importNameController,
              required: true,
              onChanged: (text) => controller.getImportButtonFlag(),
            ),
            Gaps.getHeight(24.wh),
            ManageSelectWidget(
              title: "语言",
              hintText: '请选择语言',
              value: controller.importLanguageTitle,
              readOnly: false,
              options: CommonUtil.languageValues,
              required: true,
              onChanged: (String value, int index) {
                controller.setImportLanguage(index);
              },
            ),
            Gaps.getHeight(24.wh),
            ManageImportWidget(
              onClose: () {},
              onSelect: (file) {
                print('---😆😆文件结果file:$file😆😆---');
                controller.importFilePath.value = file;
                controller.getImportButtonFlag();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 手动
  Widget buildHandMovement() {
    return GetBuilder(
        init: controller,
        id: "buildHandMovement",
        builder: (_) {
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
                    controller: controller.createDesController,
                    required: true,
                    onChanged: (text) => controller.getHandMovementButtonFlag(),
                  ),
                  Gaps.getHeight(24.wh),
                  ManageSelectWidget(
                    title: "语言",
                    hintText: '请选择语言',
                    value: controller.createLanguageTitle,
                    readOnly: false,
                    options: CommonUtil.languageValues,
                    required: true,
                    onChanged: (String value, int index) {
                      controller.setCreateLanguage(index);
                    },
                  ),
                  Gaps.getHeight(24.wh),
                  ManageSelectWidget(
                    title: "难度水平",
                    hintText: '请选择难度水平',
                    readOnly: false,
                    required: true,
                    options: controller.difficultieList.map((e) => e.name?.text ?? "").toList(),
                    onChanged: (String value, int index) {
                      controller.setCreateDifficulty(index);
                    },
                  ),
                  Gaps.getHeight(24.wh),
                  ManageSelectWidget(
                    title: "上架状态",
                    hintText: '请选择上架状态',
                    value: controller.newAccessName,
                    readOnly: true,
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
        });
  }

  Widget _buildBottomWidget() {
    return Obx(() {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Builder(
          key: ValueKey(controller.createWay.value),
          builder: (context) {
            if (controller.createWay.value == 1) {
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
                      text: "导入",
                      width: 80.ww,
                      height: 40.wh,
                      style: TextStyle(
                        fontSize: 14.wMin,
                        color: const Color(0xffACB4C0),
                        fontWeight: FontWeight.w400,
                      ),
                      color: !controller.importButtonFlag.value ? const Color(0xff353E5C) : const Color(0xff2388FF),
                      borderColor: Colors.transparent,
                      onTap: () {
                        
                      },
                    );
                  }),
                ],
              );
            } else if (controller.createWay.value == 2) {
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
                      text: "创建",
                      width: 80.ww,
                      height: 40.wh,
                      color: !controller.createButtonFlag.value ? const Color(0xff353E5C) : const Color(0xff2388FF),
                      style: TextStyle(
                        fontSize: 14.wMin,
                        color:
                            controller.createButtonFlag.value ? const Color(0xffEBEEF3) : const Color(0xffACB4C0),
                        fontWeight: FontWeight.w400,
                      ),
                      borderColor: Colors.transparent,
                      onTap: controller.createButtonFlag.value
                          ? OptimizeUtils.noneThrottle(() {
                              controller.onCreateUnit();
                            }, 100)
                          : null,
                    );
                  }),
                ],
              );
            }
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
                  onTap: () {
                    Get.back();
                  },
                ),
                SizedBox(width: 11.ww),
                Obx(() {
                  return ManageButton(
                    text: "下一步",
                    width: 80.ww,
                    height: 40.wh,
                    color: !controller.copyButtonFlag.value ? const Color(0xff353E5C) : const Color(0xff2388FF),
                    borderColor: Colors.transparent,
                    style: TextStyle(
                      fontSize: 14.wMin,
                      color: const Color(0xffACB4C0),
                      fontWeight: FontWeight.w400,
                    ),
                    onTap: !controller.copyButtonFlag.value
                        ? null
                        : OptimizeUtils.noneThrottle(() {
                            controller.onCopyUnit();
                          }, 100),
                  );
                }),
              ],
            );
          },
        ),
      );
    });
  }
}
