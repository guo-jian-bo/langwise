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

class ManageCreateRelevanceModuleManager {
  static Future<List<ModuleResponseEntity?>?>? show({
    required BuildContext context,
    required final int levelUid,
    String? language,
    bool Function(ModuleResponseEntity)? dataDisableCallback,
    void Function(int index)? onTap,
  }) {
    return showCupertinoDialog<List<ModuleResponseEntity?>?>(
      context: context,
      builder: (context) {
        return ManageCreateModuleView(
          levelUid: levelUid,
          language: language,
          dataDisableCallback: dataDisableCallback,
        );
      },
    ).then((value) {
      print('---创建关联模块弹框消失---');
      return value;
    });
  }
}

class ManageCreateModuleView extends GetView<ManageCreateRelevanceModuleController> {
  final int levelUid;
  final String? language;
  final bool Function(ModuleResponseEntity)? dataDisableCallback;

  const ManageCreateModuleView(
      {super.key, required this.levelUid, this.language, this.dataDisableCallback});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: ManageCreateRelevanceModuleController(levelUid, language),
        id: "manage_create_relevance_module",
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
                        title: "添加模块",
                        onCloseTap: () {
                          Get.back();
                        },
                      ),
                      Gaps.getHeight(27.wh),
                      Row(
                        children: [
                          buildTitleWay("关联模块", "关联现有模块，快速规划内容。", 0),
                          SizedBox(width: 16.ww),
                          buildTitleWay("复制模块", "从现有模块创建，支持调整学习顺序。", 1),
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
          authCodes: const [
            ManageAuthCode.courseModuleCopy,
          ],
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ManageTitleInputWidget(
                  focusOrder: 0,
                  title: "原模块 ID",
                  hintText: '请输入原模块 ID',
                  controller: controller.copyOriginalIDController,
                  required: true,
                  onChanged: (text) => controller.getCopyButtonFlag(),
                ),
                Gaps.getHeight(24.wh),
                ManageTitleInputWidget(
                  focusOrder: 1,
                  title: "原模块名称",
                  hintText: '请输入原模块名称',
                  controller: controller.copyNameController,
                  required: true,
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
        authCodes: const [
          ManageAuthCode.courseLevelRelationModule,
        ],
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
  Widget buildHandMovement(BuildContext context ) {
    return Container(
      height: 580.wh,
      padding: EdgeInsets.symmetric(horizontal: 16.ww, vertical: 16.wh),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: const Color(0xff22293C),
      ),
      child: ManageAuthBoxWidget(
          authCodes: const [
            ManageAuthCode.courseModuleCreate,
          ],
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ManageTitleInputWidget(
                focusOrder: 1,
                title: "模块名称",
                hintText: '请输入模块名称',
                controller: controller.createNameController,
                required: true,
                onChanged: (text) => controller.getHandMovementButtonFlag(),
              ),
              Gaps.getHeight(24.wh),
              ManageTitleInputWidget(
                focusOrder: 1,
                title: "模块描述",
                hintText: '请输入模块描述',
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
              ManageAddCover(
                icon: Assets.managerAdd,
                onTap: () {
                  return controller.onAddCover(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 模块列表
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
                    authCodes: const [
                      ManageAuthCode.courseModuleCopy,
                    ],
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
                                controller.onCopyCourse();
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
                    authCodes: const [
                      ManageAuthCode.courseModuleCreate,
                    ],
                    child: Obx(() {
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
                                controller.onCreateModule();
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
                  authCodes: const [
                    ManageAuthCode.courseLevelRelationModule,
                  ],
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
                              controller.onRelevanceModule();
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
                  "添加模块",
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
