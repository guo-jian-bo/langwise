import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/app/modules/management/dialog/manage_create_semantic/views/associate_semantic_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/mixins/mixins.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'controller.dart';

class ManageEditSemanticManager {
  static Future<EnEntitySemantics?> show({
    required BuildContext context,
    required EnEntitySemantics semanticEntity,
  }) async {
    return await showCupertinoDialog<EnEntitySemantics?>(
      context: context,
      builder: (context) {
        return ManageEditSemanticView(semanticEntity: semanticEntity);
      },
    );
  }
}

class ManageEditSemanticView extends GetView<ManageEditSemanticController> with GetViewMixin {
  final EnEntitySemantics semanticEntity;

  const ManageEditSemanticView({super.key, required this.semanticEntity});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: ManageEditSemanticController(semanticEntity),
        id: "manage_edit_semantic",
        builder: (_) {
          return LayoutBuilder(builder: (context, constraints) {
            return Scaffold(
              backgroundColor: const Color(0xff040712).withValues(alpha: 0.8),
              body: Center(
                child: Container(
                  width: 1080.ww,
                  height: 780.wh,
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
                        title: "编辑语义",
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
      height: 580.wh,
      padding: EdgeInsets.symmetric(horizontal: 16.ww, vertical: 16.wh),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: const Color(0xff22293C),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget("语义描述"),
            Gaps.getHeight(24.wh),
            _buildDescriptionListWidget(context),
            Gaps.getHeight(24.wh),
            buildAddWidget(() {
              controller.addDescriptionCell(context);
            }),
            // Gaps.getHeight(24.wh),
            // ManageTitleInputWidget(
            //   title: "分类",
            //   hintText: '请填写分类',
            //   required: false,
            //   controller: controller.descriptionController,
            //   readOnly: false,
            // ),
            Gaps.getHeight(24.wh),
            _buildTitleWidget("标签"),
            Gaps.getHeight(24.wh),
            _buildTopicWidget(context),
            Gaps.getHeight(24.wh),
            ManageSelectWidget(
              title: "难度水平",
              hintText: '请选择难度水平',
              readOnly: false,
              required: true,
              value: controller.selectDifficultyIndex.toString(),
              options: CommonUtil.cefr.map((e) => e.toString()).toList(),
              onChanged: (String value, int index) {
                controller.setCreateDifficulty(index);
              },
            ),
            Gaps.getHeight(24.wh),
            _buildTitleWidget("关联语义"),
            Gaps.getHeight(24.wh),
            _buildAssociateSemanticListWidget(context),
            if (controller.associateSemanticCells.isNotEmpty) Gaps.getHeight(24.wh),
            buildAddWidget(() {
              controller.associatedSemantics(context, controller.getAllAssociatedSemantics());
            }),
            Gaps.getHeight(24.wh),
          ],
        ),
      ),
    );
  }

  // title
  Widget _buildTitleWidget(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.wMin,
        color: const Color(0xffEBEEF3),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // 描述列表
  Widget _buildDescriptionListWidget(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.descriptionCells.length,
      separatorBuilder: (_, i) => SizedBox(height: 12.wh),
      itemBuilder: (_, index) => DescriptionCellWidget(
        // 使用UUID作为key
        key: ValueKey(controller.descriptionCells[index].uuid),
        index: index,
        data: controller.descriptionCells[index],
        onDelete: (int i) {
          controller.removeDescription(i);
        },
        // 将 languageValues 中的语法结构转换为字符串列表传递给组件
        languageOptions: CommonUtil.languageValues,
        onSelectLanguage: (String value, int languageIndex, int cellIndex) {
          controller.onDescriptionSelectLanguage(value, languageIndex, cellIndex);
        },
      ),
    );
  }

  // 关联语义列表
  Widget _buildAssociateSemanticListWidget(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.associateSemanticCells.length,
      separatorBuilder: (_, i) => Column(
        children: [
          SizedBox(height: 20.wh),
          Divider(
            height: 1.wMin,
            thickness: 1.wMin,
            color: const Color(0xff4B5268),
          ),
          SizedBox(height: 20.wh),
        ],
      ),
      itemBuilder: (_, index) => AssociateSemanticWidget(
        // 使用UUID作为key
        key: ValueKey(controller.associateSemanticCells[index].uuid),
        index: index,
        data: controller.associateSemanticCells[index],
        onDelete: (int i) {
          controller.removeAssociatedSemantic(i);
        },
        // 语言和口音选项
        languageOptions: CommonUtil.languageValues,
        // 口音也使用语言列表
        accentOptions: CommonUtil.nationalIpaValues,
        // 类型选项
        typeOptions: CommonUtil.semanticTypeValues,
        // 语言选择回调
        onSelectLanguage: (String value, int languageIndex, int cellIndex) {
          controller.onSelectAssociateLanguage(value, languageIndex, cellIndex);
        },
        // 口音选择回调
        onSelectNationals: (List<int> indexes, int cellIndex) {
          controller.onSelectAssociateAccents(indexes, cellIndex);
        },
        // 关联类型选择回调
        onSelectRelationShipType: (String value, int typeIndex, int cellIndex) {
          controller.onSelectAssociateType(value, typeIndex, cellIndex);
        },
        // 备注变化回调
        onRemarkChanged: (String value, int cellIndex) {
          controller.onAssociateRemarkChanged(value, cellIndex);
        },
      ),
    );
  }

  // 主题选择组件
  Widget _buildTopicWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Obx(() {
        return Wrap(
          // 水平方向排列
          direction: Axis.horizontal,
          // 子元素水平间距
          spacing: 10.ww,
          // 行间距设为0（单行模式）
          runSpacing: 10.wh,
          children: [
            // 原有数据项
            ...controller.topicList.map((oldEntity) => TopicCard(
                  key: ValueKey(oldEntity.uniqueId),
                  topic: oldEntity,
                  onDelTap: (EnEntityTopic entity) {
                    controller.onRemoveTopic(entity);
                  },
                )),
            // 添加按钮项
            TapScaleWidget(
              onTap: () => controller.toAddTopic(context, controller.topicList),
              child: Container(
                key: const ValueKey('topic_add'),
                width: 120.ww,
                height: 50.wh,
                // 右侧间距
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.wMin),
                  border: Border.all(
                    color: const Color(0xff4B5268),
                    width: 1.wMin,
                  ),
                  color: const Color(0xff353E5C),
                ),
                alignment: Alignment.center,
                child: Text(
                  "选择标签",
                  style: TextStyleExtension.ts_14_w400_BAC0CC,
                ),
              ),
            )
          ],
        );
      }),
    );
  }

  // 底部按钮
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
                  controller.onEditSemantic();
                }, 100),
        ),
      ],
    );
  }
}
