import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../common/manage_button.dart';
import '../../common/manage_title_input_widget.dart';
import 'controller.dart';

class ManageEditSingleWordManager {
  static Future<EnWordEntity?> show({
    required BuildContext context,
    required final EnWordEntity enWordEntity,
    void Function(int index)? onTap,
  }) async {
    return await showCupertinoDialog<EnWordEntity?>(
      context: context,
      builder: (context) {
        return ManageEditSingleWordView(
          enWordEntity: enWordEntity,
        );
      },
    );
  }
}

class ManageEditSingleWordView extends GetView<ManageEditSingleWordController> {
  final EnWordEntity enWordEntity;

  const ManageEditSingleWordView({super.key, required this.enWordEntity});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: ManageEditSingleWordController(enWordEntity),
        id: "manage_edit_single_word",
        builder: (_) {
          return LayoutBuilder(builder: (context, constraints) {
            return Scaffold(
              backgroundColor: const Color(0xff040712).withValues(alpha: 0.8),
              body: Center(
                child: Container(
                  width: 1080.ww,
                  height: 980.wh,
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
                        title: "单词",
                        onCloseTap: () {
                          Get.back();
                        },
                      ),
                      Gaps.getHeight(35.wh),
                      _buildContentWidget(context),
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

  /// 主视图
  Widget _buildContentWidget(BuildContext context) {
    return Container(
      height: 780.wh,
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
              title: "单词id",
              hintText: '请填写单词id',
              required: true,
              controller: controller.wordIdController,
              readOnly: true,
            ),
            Gaps.getHeight(24.wh),
            ManageTitleInputWidget(
              title: "单词",
              hintText: '请填写单词',
              required: true,
              controller: controller.wordController,
              readOnly: false,
            ),
            Gaps.getHeight(24.wh),
            ManageTitleInputWidget(
              title: "释义",
              hintText: '请填写释义',
              required: true,
              controller: controller.definitionController,
              readOnly: false,
            ),
            Gaps.getHeight(24.wh),
            ManageTitleInputWidget(
              title: "原形",
              hintText: '请填写原形',
              required: true,
              controller: controller.lemmaController,
              readOnly: false,
            ),
            Gaps.getHeight(24.wh),
            ManageSelectWidget(
              title: "词性",
              hintText: '请选择词性',
              value: controller.posTitle,
              readOnly: false,
              required: true,
              options: controller.poses.map((element) => element.title ?? '').toList(),
              onChanged: (String value, int index) {
                controller.setPos(index);
              },
            ),
            Gaps.getHeight(24.wh),
            ManageSelectWidget(
              title: "语法形式",
              hintText: '请选择语法形式',
              value: controller.formTitle,
              readOnly: false,
              required: true,
              options: controller.forms.map((element) => element.title ?? '').toList(),
              onChanged: (String value, int index) {
                controller.setForm(index);
              },
            ),
            Gaps.getHeight(24.wh),
            _buildExtraWidget(title: "选择语义"),
            _buildSemanticWidget(context),
            Gaps.getHeight(24.wh),
            Row(
              children: [
                Expanded(
                    child: ManageTitleInputWidget(
                  title: "英音",
                  hintText: '请输入英音',
                  required: true,
                  controller: controller.britishController,
                  readOnly: true,
                )),
                Gaps.getWidth(20.ww),
                Expanded(
                    child: ManageTitleInputWidget(
                  title: "美音",
                  hintText: '请输入美音',
                  required: true,
                  controller: controller.americanController,
                  readOnly: true,
                )),
              ],
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

  // 语义
  Widget _buildSemanticWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 188,
      alignment: Alignment.centerLeft,
      child: ListView.builder(
        // 缓存键
        key: const PageStorageKey<String>("semantic"),
        itemCount: controller.semantics.length + 1,
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext c, int index) {
          if (index == 0) {
            return AspectRatio(
                aspectRatio: 160 / 188,
                child: buildAddButton(context, "添加语义", () {
                  controller.toAddSemantic(context, controller.semantics);
                }));
          }
          final EnEntitySemantics entitySemantics = controller.semantics[index - 1];
          return CombinedSemanticsWidget(
            key: PageStorageKey(entitySemantics.uid),
            entitySemantics: entitySemantics,
            index: index - 1,
            onDeleteTap: (int i, EnEntitySemantics semantics) {
              controller.onRemoveSemantic(semantics);
            },
          );
        },
      ),
    );
  }

  Widget buildAddButton(BuildContext context, String title, VoidCallback onTap) {
    return TapScaleWidget(
      onTap: OptimizeUtils.noneThrottle(() {
        onTap.call();
      }, 100),
      sclae: 1.03,
      child: DottedBorder(
        radius: Radius.circular(8.wMin),
        borderType: BorderType.RRect,
        padding: EdgeInsets.zero,
        color: const Color(0xff444B5F),
        dashPattern: const [1, 2],
        strokeWidth: 1.wMin,
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildImage(Assets.managerAdd, width: 40.wMax, height: 40.wMax),
              Gaps.getHeight(10.wh),
              Text(
                title,
                style: TextStyleExtension.ts_12_w400_ACB4C0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExtraWidget({required String title}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.wh),
      alignment: Alignment.centerLeft,
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
              text: title,
              style: TextStyle(
                fontSize: 14.wMin,
                color: const Color(0xffEBEEF3),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomWidget() {
    return GetBuilder(
        init: controller,
        builder: (_) {
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
              ManageButton(
                text: "确定",
                width: 80.ww,
                height: 40.wh,
                color: !controller.uploadButtonFlag ? const Color(0xff353E5C) : const Color(0xff2388FF),
                borderColor: Colors.transparent,
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: controller.uploadButtonFlag ? const Color(0xffEBEEF3) : const Color(0xffACB4C0),
                  fontWeight: FontWeight.w400,
                ),
                onTap: !controller.uploadButtonFlag
                    ? null
                    : OptimizeUtils.noneThrottle(() {
                        controller.onCreateWord();
                      }, 100),
              ),
            ],
          );
        });
  }
}
