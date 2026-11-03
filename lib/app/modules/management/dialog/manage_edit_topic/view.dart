import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_button.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_input_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/mixins/mixins.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'controller.dart';

class ManageEditTopicManager {
  static Future<EnEntityTopic?> show({
    required BuildContext context,
    required EnEntityTopic topic,
  }) async {
    return await showCupertinoDialog<EnEntityTopic?>(
      context: context,
      builder: (context) {
        return ManageEditTopicView(
          topic: topic,
        );
      },
    );
  }
}

class ManageEditTopicView extends GetView<ManageEditTopicController> with GetViewMixin {
  final EnEntityTopic topic;

  const ManageEditTopicView({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: ManageEditTopicController(topic),
        id: "manage_edit_topic",
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
                      width: 1.wMin,
                    ),
                    color: const Color(0xff181B25),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ManageTitleWidget(
                        title: "编辑语义标签",
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
          children: [
            ManageTitleInputWidget(
              title: "语义标签",
              hintText: '请填写语义标签',
              required: true,
              controller: controller.wordController,
              readOnly: false,
            ),
            Gaps.getHeight(24.wh),
            buildTitleWidget("主题描述"),
            Gaps.getHeight(24.wh),
            _buildDescriptionListWidget(context),
            Gaps.getHeight(24.wh),
            buildAddWidget(() {
              controller.addDescriptionCell(context);
            }),
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

  // 描述列表
  Widget _buildDescriptionListWidget(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.descriptionCells.length,
      separatorBuilder: (_, i) => Column(
        children: [
          SizedBox(height: 20.wh),
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xff4B5268),
          ),
          SizedBox(height: 20.wh),
        ],
      ),
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

  // 底部操作栏
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
                  controller.onEditTopic();
                }, 100),
        ),
      ],
    );
  }
}
