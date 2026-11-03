import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/values/values.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../common/widgets/zhenxie_widgets/zhenxie_paragraph_blueprint_table_widget.dart';
import '../../../../../common/widgets/zhenxie_widgets/zhenxie_paragraph_step_details_widget.dart';
import '../../../../../utils/utils.dart';
import '../../../management/common/commons.dart';
import '../bindings/zhenxie_paragraph_writing_goal_binding.dart';
import '../controllers/zhenxie_paragraph_writing_goal_controller.dart';
import 'zhenxie_paragraph_writing_goal_stop_widget.dart';

class ZhenxieParagraphWritingGoalView extends GetView<ZhenxieParagraphWritingGoalController> {
  final String tagText;
  const ZhenxieParagraphWritingGoalView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieParagraphWritingGoalView(tagText: tag),
      binding: ZhenxieParagraphWritingGoalBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PARAGRAPH_WRITING_GOAL,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () {
        controller.initData();
      },
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Column(
        children: [
          BreadcrumbWidget(isCompatibleManage: controller.isManagement),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildWritingBoardWidget(context)),
                Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
                _buildInfoWidget(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 写字板
  Widget _buildWritingBoardWidget(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    double leftPadding = padding.left > 90.wMin ? (padding.left + 16.wMin) : 90.wMin;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 86.wMin,
          margin: EdgeInsets.only(left: leftPadding),
          alignment: Alignment.centerLeft,
          child: Obx(() {
            final data = controller.detailData.value;
            final name = LearningLangUtils.getLocalLang(data.name);
            return Text(
              name?.text ?? '',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            );
          }),
        ),
        Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(left: leftPadding),
            color: Color(0xffFFF7ED),
            child: Obx(() {
              List<ParagraphWritingGoalEntityBeatSpan?> beatSpanList = controller.detailData.value.beatSpanList?.toList() ?? [];
              String content = controller.detailData.value.content ?? '';
              return ZhenxieParagraphStepDetailsContentWidget(
                content: content,
                selectBeatNid: controller.selectBeatNid.value,
                paragraphRhetoricalList: controller.paragraphRhetoricalList.toList(),
                beatSpanList: beatSpanList,
                anchors: controller.detailData.value.anchors,
                onTapText: (beatNid) {
                  controller.selectBeatNid.value = beatNid;
                },
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoWidget(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    double rightPadding = padding.right;
    return Container(
      width: 750.wMin,
      padding: EdgeInsets.only(right: rightPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 86.wMin,
            padding: EdgeInsets.symmetric(horizontal: 24.wMin),
            child: Obx(() {
              final data = controller.detailData.value;
              final name = LearningLangUtils.getLocalLang(data.blueprint?.name);
              return Row(
                children: [
                  Text(
                    "写作目标",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w500,
                      color: Color(0xffFB923C),
                    ),
                  ),
                  Text(
                    "：${name?.text ?? ''}",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ),
                ],
              );
            }),
          ),
          Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoBlueprintWidget(),
                  SizedBox(height: 16.wMin),
                  Obx(() {
                    return ZhenxieParagraphWritingGoalStopWidget(
                      paragraphRhetoricalList: controller.paragraphRhetoricalList.toList(),
                      selectNid: controller.selectBeatNid.value,
                      beatSpanList: controller.detailData.value.beatSpanList ?? [],
                      onTap: (beatSpan) {
                        controller.switchBeat(beatSpan);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          _buildInfoBottomWidget(),
        ],
      ),
    );
  }

  Widget _buildInfoBlueprintWidget() {
    return Container(
      padding: EdgeInsets.all(4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(color: AppTheme.cBorderSubtle.color, width: 0.8.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 12.wMin),
              Expanded(
                child: Obx(() {
                  final data = controller.detailData.value;
                  final description = LearningLangUtils.getLocalLang(data.blueprint?.description);
                  return Text(
                    description?.text ?? '',
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  );
                }),
              ),
              TapScaleWidget(
                onTap: () {
                  controller.jumpToParagraphDetail();
                },
                sclae: 1.05,
                child: Container(
                  padding: EdgeInsets.all(12.wMin),
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Text(
                        "蓝图详情",
                        style: TextStyle(
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w500,
                          color: Color(0xffFB923C),
                        ),
                      ),
                      SvgPicture.asset(
                        "assets/svg/public/icon_w_arrow_right.svg",
                        width: 20.wMin,
                        colorFilter: ColorFilter.mode(Color(0xffFB923C), BlendMode.srcIn),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(16.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              color: AppTheme.cSurfaceBg.color,
              border: Border.all(color: AppTheme.cBorderDefault.color, width: 1.wMin),
            ),
            child: Obx(() {
              return ZhenxieParagraphBlueprintOverviewTableWidget(
                paragraphRhetoricalList: controller.paragraphRhetoricalList.toList(),
                slotList: controller.detailData.value.blueprint?.slotList ?? [],
                beatSpanList: controller.detailData.value.beatSpanList ?? [],
                selectNid: controller.selectBeatNid.value,
                onTap: (nid) {
                  controller.selectBeatNid.value = nid;
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBottomWidget() {
    return Obx(() {
      final data = controller.detailData.value;
      final usedInCompositions = data.usedInCompositions ?? [];
      if (usedInCompositions.isEmpty) return Container();

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),
            SizedBox(height: 24.wMin),
            Text(
              "用于这篇",
              style: TextStyle(
                fontSize: 14.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(usedInCompositions.length, (index) {
                final title = LearningLangUtils.getLocalLang(usedInCompositions[index]?.title);
                return TapScaleWidget(
                  onTap: () {
                    controller.jumpToTaskDetail(usedInCompositions[index]);
                  },
                  sclae: 1,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.wMin),
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Text(
                          title?.text ?? '',
                          style: TextStyle(
                            fontSize: 16.wMin,
                            fontWeight: FontWeight.w500,
                            color: Color(0xffFB923C),
                          ),
                        ),
                        SvgPicture.asset(
                          "assets/svg/public/icon_w_arrow_right.svg",
                          width: 20.wMin,
                          colorFilter: ColorFilter.mode(Color(0xffFB923C), BlendMode.srcIn),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 56.wMin),
          ],
        ),
      );
    });
  }
}
