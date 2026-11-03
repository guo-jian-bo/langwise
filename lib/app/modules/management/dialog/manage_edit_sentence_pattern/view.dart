import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/app/modules/management/dialog/manage_create_sentence_pattern/views/compose_widget_pattern.dart';
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

class ManageEditSentencePatternManager {
  static Future<SentencePatternEntity?> show({
    required BuildContext context,
    required SentencePatternEntity entity,
    void Function(int index)? onTap,
  }) async {
    return await showCupertinoDialog<SentencePatternEntity?>(
      context: context,
      builder: (context) {
        return ManageEditSentencePatternView(
          entity: entity,
        );
      },
    );
  }
}

class ManageEditSentencePatternView extends GetView<ManageEditSentencePatternController> {
  final SentencePatternEntity entity;

  const ManageEditSentencePatternView({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: ManageEditSentencePatternController(entity),
        id: "manage_edit_sentence_pattern",
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
                        title: "创建句型",
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
              title: "句型名称",
              hintText: '请填写句型名称',
              required: true,
              controller: controller.wordController,
              readOnly: false,
            ),
            Gaps.getHeight(24.wh),
            ManageTitleInputWidget(
              title: "句型结构",
              hintText: '请填写句型结构',
              required: true,
              controller: controller.definitionController,
              readOnly: false,
            ),
            Gaps.getHeight(24.wh),
            _buildTitleWidget("组成结构"),
            if (controller.composeCells.isNotEmpty) Gaps.getHeight(24.wh),
            _buildComposeListWidget(context),
            Gaps.getHeight(24.wh),
            _buildAddWidget(() {
              controller.addCompose(context);
            }),
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

  // title
  Widget _buildTitleWidget(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.wMin,
            color: const Color(0xffEBEEF3),
            fontWeight: FontWeight.w400,
          ),
        ),
        Gaps.getWidth(2.ww),
        Expanded(
          child: Divider(
            height: 1.wMin,
            color: const Color(0xff4B5268),
          ),
        )
      ],
    );
  }

  // 组成结构列表
  Widget _buildComposeListWidget(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.composeCells.length,
      separatorBuilder: (_, i) => SizedBox(height: 12.wh),
      itemBuilder: (_, index) => ComposeCellPatternWidget(
        key: ValueKey(controller.composeCells[index].uuid),
        // 使用UUID作为key
        index: index,
        data: controller.composeCells[index],
        onSelectKnowledgeStatus: (int i, int cellIndex) {
          controller.onSetKnowledgeStatus(i, cellIndex);
        },
        onDelete: (int i) {
          controller.removeCompose(i);
        },
        onSelectKnowledge: (i, knowledge) {
          controller.toAddKnowledge(context, i, controller.knowledgeList);
        },
        // 将 grammarList 中的语法结构转换为字符串列表传递给组件
        grammarOptions: controller.grammarList.map((grammar) => grammar.newTitle).toList(),
        onSelectGrammar: (String value, int grammarIndex, int cellIndex) {
          controller.onSelectGrammar(value, grammarIndex, cellIndex);
        },
      ),
    );
  }

  // 添加按钮
  Widget _buildAddWidget(VoidCallback onTap) {
    return TapScaleWidget(
      onTap: () {
        onTap.call();
      },
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
          height: 48.wh,
          child: SvgPicture.asset(
            "assets/svg/manage/icon_add.svg",
            height: 22.ww,
          ),
        ),
      ),
    );
  }

  // 添加知识点
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
                  controller.onEditSentencePattern();
                }, 100),
        ),
      ],
    );
  }
}
