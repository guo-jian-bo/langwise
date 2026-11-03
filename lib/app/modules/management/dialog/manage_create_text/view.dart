import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/app/modules/management/common/manage_content_input_widget.dart';
import 'package:langwise/app/modules/management/common/manage_select_option_widget.dart';
import 'package:langwise/app/modules/management/common/manage_title_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/mixins/mixins.dart';
import 'package:langwise/common/static/static_data.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../common/manage_button.dart';
import '../../common/manage_title_input_widget.dart';
import 'controller.dart';

class ManageCreateTextManager {
  static Future<EnKnowledgeEntity?> show({
    required BuildContext context,
    bool showSelectKnowledgeAddButton = false,
    void Function(int index)? onTap,
  }) async {
    return await showCupertinoDialog<EnKnowledgeEntity?>(
      context: context,
      builder: (context) {
        return ManageCreateTextView(
          showSelectKnowledgeAddButton: showSelectKnowledgeAddButton,
        );
      },
    );
  }
}

class ManageCreateTextView extends GetView<ManageCreateTextController> with GetViewMixin {
  final bool showSelectKnowledgeAddButton;

  const ManageCreateTextView({super.key, this.showSelectKnowledgeAddButton = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManageCreateTextController>(
        init: ManageCreateTextController(showSelectKnowledgeAddButton),
        id: "manage_create_text",
        builder: (controller) {
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
                        title: "创建文章",
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
              title: "标题",
              hintText: '请填写文章标题',
              required: true,
              controller: controller.titleController,
              readOnly: false,
            ),
            Gaps.getHeight(24.wh),
            ManageContentInputWidget(
              title: "内容",
              hintText: '请填写文章内容',
              required: true,
              controller: controller.contentController,
              height: 100.wh,
              maxLines: 500,
              padding: EdgeInsets.symmetric(horizontal: 12.ww, vertical: 12.ww),
            ),
            Gaps.getHeight(24.wh),
            buildTitleWidget("关联知识点"),
            Gaps.getHeight(24.wh),
            _buildKnowledgeWidget(context),
            Gaps.getHeight(24.wh),
            buildTitleWidget("学习核心"),
            if (controller.learnCoreCells.isNotEmpty) Gaps.getHeight(24.wh),
            _buildLearnCoreListWidget(context),
            Gaps.getHeight(24.wh),
            _buildAddWidget(() {
              controller.addLearnCore(context);
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

  // 关联知识点
  Widget _buildKnowledgeWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 245,
      alignment: Alignment.centerLeft,
      child: GridView.builder(
        // 缓存键
        key: const PageStorageKey<String>("knowledge"),
        itemCount: controller.relevanceKnowledgeList.length + 1,
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 12.wMin,
          crossAxisSpacing: 0,
          childAspectRatio: 245 / 180,
        ),
        itemBuilder: (BuildContext c, int index) {
          if (index == 0) {
            return buildAddButton(context, "添加知识点", () {
              controller.toRelevanceKnowledge(context, controller.relevanceKnowledgeList);
            });
          }
          final Knowledge knowledge = controller.relevanceKnowledgeList[index - 1];
          return KnowledgeItemWidget(
            key: PageStorageKey(knowledge.uid),
            index: index - 1,
            knowledge: knowledge,
            showDelIcon: true,
            onTap: (int i, Knowledge k) {
              if (k.audioUrl != null && k.audioUrl!.isNotEmpty) {
                PlayAudioUtils.instance.playSingle(k.audioUrl!);
              }
            },
            onDeleteTap: (int i, Knowledge k) {
              controller.removeRelevanceKnowledge(i);
            },
          );
        },
      ),
    );
  }

  // 学习核心列表
  Widget _buildLearnCoreListWidget(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.learnCoreCells.length,
      separatorBuilder: (_, i) => SizedBox(height: 12.wh),
      itemBuilder: (_, index) => LearnCoreCellWidget(
        key: ValueKey(controller.learnCoreCells[index].uuid),
        // 使用UUID作为key
        index: index,
        data: controller.learnCoreCells[index],
        onDelete: (int i) {
          controller.removeLearnCore(i);
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
                  controller.onCreateText();
                }, 100),
        ),
      ],
    );
  }
}
