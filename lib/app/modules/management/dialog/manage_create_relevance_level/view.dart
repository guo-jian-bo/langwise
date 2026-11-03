import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import '../../common/commons.dart';
import '../../common/manage_button.dart';
import '../../common/manage_public_widget.dart';
import '../../common/manage_title_input_widget.dart';
import '../../utils/utils.dart';
import 'controller.dart';

class ManageCreateRelevanceLevelManager {
  /// disableAssociationLevel 是否禁用关联级别
  /// disableCopyLevel 是否禁用复制级别
  static Future<List<LevelResponseEntity?>?>? show({
    required BuildContext context,
    required final int courseId,
    String? language,
    bool disableAssociationLevel = false,
    bool disableCopyLevel = false,
    int initCreateWay = 0,
    bool Function(LevelResponseEntity)? dataDisableCallback,
    void Function(int index)? onTap,
  }) {
    return showCupertinoDialog<List<LevelResponseEntity?>?>(
      context: context,
      builder: (context) {
        return ManageCreateLevelView(
          courseId: courseId,
          language: language,
          initCreateWay: initCreateWay,
          dataDisableCallback: dataDisableCallback,
          disableAssociationLevel: disableAssociationLevel,
          disableCopyLevel: disableCopyLevel,
        );
      },
    ).then((value) {
      print('---创建关联模块弹框消失---');
      return value;
    });
  }
}

class ManageCreateLevelView extends GetView<ManageCreateRelevanceLevelController> {
  final int courseId;
  final String? language;
  final bool disableAssociationLevel;
  final bool disableCopyLevel;
  final int initCreateWay;
  final bool Function(LevelResponseEntity)? dataDisableCallback;

  const ManageCreateLevelView({
    super.key,
    required this.courseId,
    this.language,
    this.disableAssociationLevel = false,
    this.disableCopyLevel = false,
    this.dataDisableCallback,
    this.initCreateWay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: ManageCreateRelevanceLevelController(courseId, language, initCreateWay),
        id: "manage_create_relevance_level",
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
                        title: "添加级别",
                        onCloseTap: () {
                          Get.back();
                        },
                      ),
                      Gaps.getHeight(27.wh),
                      Row(
                        children: [
                          buildTitleWay("关联级别", "关联现有级别，快速规划内容。", 0, disableAssociationLevel),
                          SizedBox(width: 16.ww),
                          buildTitleWay("复制级别", "从现有级别创建，支持调整学习顺序。", 1, disableCopyLevel),
                          SizedBox(width: 16.ww),
                          buildTitleWay("手动创建", "完全手动输入。", 2, false),
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
                                  return buildCopy();
                                } else if (controller.createWay.value == 2) {
                                  return buildHandMovement(context);
                                }
                                return buildImport();
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
        child: ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.courseLevelCopy],
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ManageTitleInputWidget(
                  focusOrder: 0,
                  title: "原级别 ID",
                  hintText: '请输入原级别 ID',
                  required: true,
                  controller: controller.copyOriginalIDController,
                  onChanged: (text) => controller.getCopyButtonFlag(),
                ),
                Gaps.getHeight(24.wh),
                ManageTitleInputWidget(
                  focusOrder: 1,
                  title: "原级别名称",
                  hintText: '请输入原级别名称',
                  required: true,
                  controller: controller.copyNameController,
                  onChanged: (text) => controller.getCopyButtonFlag(),
                ),
              ],
            ),
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
      child: ManageAuthBoxWidget(
        authCodes: const [ManageAuthCode.courseRelationLevel],
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildModuleListWidget(),
              Gaps.getHeight(16.wh),
              _buildAddModuleWidget(),
            ],
          ),
        ),
      ),
    );
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
      child: ManageAuthBoxWidget(
        authCodes: const [ManageAuthCode.courseLevelCreate],
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ManageTitleInputWidget(
                focusOrder: 1,
                title: "级别名称",
                hintText: '请输入级别名称',
                controller: controller.createNameController,
                required: true,
                onChanged: (text) => controller.getHandMovementButtonFlag(),
              ),
              Gaps.getHeight(24.wh),
              ManageTitleInputWidget(
                focusOrder: 1,
                title: "级别描述",
                hintText: '请输入级别描述',
                controller: controller.createDesController,
                required: true,
                onChanged: (text) => controller.getHandMovementButtonFlag(),
              ),
              Gaps.getHeight(24.wh),
              ManageSelectWidget(
                title: "语言",
                hintText: '请选择语言',
                value: controller.createLanguageTitle,
                readOnly: controller.createLanguageReadOnly,
                required: true,
                options: CommonUtil.languageValues,
                onChanged: (String value, int index) {
                  controller.setCreateLanguage(index);
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
                            child: GetBuilder<ManageCreateRelevanceLevelController>(
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
      ),
    );
  }

  // 级别列表
  Widget _buildModuleListWidget() {
    return Obx(() {
      return Column(
        children: controller.selectedRows.mapIndexed((index, element) {
          return ManageBox(
            padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 16.wMin),
            margin: EdgeInsets.only(bottom: 10.wMin),
            borderRadius: 8.wMin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                      child: Text(
                        element.name ?? '',
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xffEBEEF3),
                        ),
                      ),
                    ),
                    TapScaleWidget(
                      onTap: () {
                        controller.removeModule(index);
                      },
                      child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.all(5.wMin),
                        child: Icon(Icons.clear, color: const Color(0xffBAC0CC), size: 20.wMin),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.wMin),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                  child: Text(
                    element.description ?? '',
                    style: TextStyle(
                      fontSize: 14.wMin,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xffACB4C0),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
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
                    onTap: () {
                      Get.back();
                    },
                  ),
                  SizedBox(width: 11.ww),
                  ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.courseLevelCopy],
                    child: Obx(() {
                      return ManageButton(
                        text: "确认",
                        width: 80.ww,
                        height: 40.wh,
                        color: !controller.copyButtonFlag.value ? const Color(0xff353E5C) : const Color(0xff2388FF),
                        borderColor: Colors.transparent,
                        style: TextStyle(
                          fontSize: 14.wMin,
                          color: controller.copyButtonFlag.value ? const Color(0xffEBEEF3) : const Color(0xffACB4C0),
                          fontWeight: FontWeight.w400,
                        ),
                        onTap: !controller.copyButtonFlag.value
                            ? null
                            : OptimizeUtils.noneThrottle(() {
                                controller.onCopyLevel();
                              }, 100),
                      );
                    }),
                  ),
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
                  ManageAuthBoxWidget(
                    authCodes: const [ManageAuthCode.courseLevelCreate],
                    child: Obx(() {
                      return ManageButton(
                        text: "创建",
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
                                controller.onCreateLevel();
                              }, 100)
                            : null,
                      );
                    }),
                  ),
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
                  onTap: () => Get.back(),
                ),
                SizedBox(width: 11.ww),
                ManageAuthBoxWidget(
                  authCodes: const [ManageAuthCode.courseRelationLevel],
                  child: Obx(() {
                    return ManageButton(
                      text: "确认",
                      width: 80.ww,
                      height: 40.wh,
                      style: TextStyle(
                        fontSize: 14.wMin,
                        color: controller.selectedRows.isNotEmpty ? const Color(0xffEBEEF3) : const Color(0xffACB4C0),
                        fontWeight: FontWeight.w400,
                      ),
                      color: controller.selectedRows.isEmpty ? const Color(0xff353E5C) : const Color(0xff2388FF),
                      borderColor: Colors.transparent,
                      onTap: controller.selectedRows.isNotEmpty
                          ? OptimizeUtils.noneThrottle(() {
                              controller.onRelevanceLevel();
                            }, 100)
                          : null,
                    );
                  }),
                ),
              ],
            );
          },
        ),
      );
    });
  }

  Widget buildTitleWay(String name, String info, int index, bool disable) {
    return Obx(() {
      return ManageTitleWay(
        name: name,
        info: info,
        disable: disable,
        selected: controller.createWay.value == index,
        onTap: () {
          if (disable) return;
          controller.createWay(index);
        },
      );
    });
  }

  // 关联模块
  Widget _buildAddModuleWidget() {
    return Builder(builder: (BuildContext context) {
      return TapScaleWidget(
        onTap: OptimizeUtils.noneThrottle(() async {
          controller.addModule(context, dataDisableCallback: dataDisableCallback);
        }, 100),
        sclae: 1.03,
        child: DottedBorder(
          radius: Radius.circular(10.wMin),
          borderType: BorderType.RRect,
          padding: EdgeInsets.zero,
          color: const Color(0xff4B5268),
          dashPattern: const [4, 2],
          child: SizedBox(
            width: double.infinity,
            height: 56.wh,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildImage(Assets.managerFilterAdd, width: 18.wMax, height: 18.wMax),
                Gaps.getWidth(7.ww),
                Text(
                  "添加级别",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: const Color(0xffEAECFF),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
