import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_scaffold.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/values/app_font_value.dart';
import 'package:langwise/common/widgets/app_markdown_widget.dart';
import 'package:langwise/common/widgets/not_data_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../zhenxie_exam/models/zhenxie_exam_models.dart';
import '../../zhenxie_exam_tasks/views/zhenxie_exam_task_card_widget.dart';
import '../bindings/zhenxie_exam_task_detail_binding.dart';
import '../controllers/zhenxie_exam_task_detail_controller.dart';

class ZhenxieExamTaskDetailView extends GetView<ZhenxieExamTaskDetailController> {
  final String tagText;

  const ZhenxieExamTaskDetailView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieExamTaskDetailView(tagText: tag),
      binding: ZhenxieExamTaskDetailBinding(tagText: tag),
      routeName: Routes.ZHENXIE_EXAM_TASK_DETAIL,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    controller;
    return Obx(() {
      return ManageScaffold(
        backgroundColor: AppTheme.cBgPrimary.color,
        body: Column(
          children: <Widget>[
            BreadcrumbWidget(actionWidget: _buildBreadcrumbActionWidget()),
            Expanded(
              child: _buildBodyWidget(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBreadcrumbActionWidget() {
    final ZhenxieExamTaskDetailData? detail = controller.detailData.value;
    if (detail == null) return const SizedBox.shrink();
    final String yearText = detail.year?.toString() ?? '';
    final String regionText = controller.buildRegionText(detail.regions);
    final String familyText = controller.buildZhText(detail.family.name);
    final Color familyColor = controller.findFamilyThemeColors(detail.family.code)?.colorC ??
        controller.findFamilyThemeColors(detail.family.code)?.textColorC ??
        AppTheme.cZhenxieColorPrimary.color;
    if (yearText.isEmpty && regionText.isEmpty && detail.section.isEmpty && familyText.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6.wMin,
      runSpacing: 6.wMin,
      children: <Widget>[
        if (yearText.isNotEmpty || regionText.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (yearText.isNotEmpty)
                Text(
                  yearText,
                  style: TextStyle(
                    fontSize: 15.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieColorPrimary.color,
                    fontFamily: AppFontValue.robotoMono,
                  ),
                ),
              if (yearText.isNotEmpty && regionText.isNotEmpty) SizedBox(width: 8.wMin),
              if (regionText.isNotEmpty)
                Text(
                  regionText,
                  style: TextStyle(
                    fontSize: 15.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cZhenxieFontSecondary.color,
                    fontFamily: AppFontValue.robotoMono,
                  ),
                ),
            ],
          ),
        if ((yearText.isNotEmpty || regionText.isNotEmpty) && (detail.section.isNotEmpty || familyText.isNotEmpty))
          SizedBox(width: 6.wMin),
        if (detail.section.isNotEmpty)
          Text(
            detail.section,
            style: TextStyle(
              fontSize: 12.5.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontSecondary.color.withValues(alpha: 0.72),
            ),
          ),
        if (detail.section.isNotEmpty && familyText.isNotEmpty)
          Text(
            '›',
            style: TextStyle(
              fontSize: 12.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontSecondary.color.withValues(alpha: 0.4),
            ),
          ),
        if (familyText.isNotEmpty)
          ZhenxieExamTaskChip(
            text: familyText,
            textColor: familyColor,
            backgroundColor: familyColor.withValues(alpha: 0.12),
            borderColor: familyColor.withValues(alpha: 0.2),
            dotColor: familyColor,
          ),
      ],
    );
  }

  Widget _buildBodyWidget() {
    if (controller.isLoading.value && controller.detailData.value == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.isNotData.value || controller.detailData.value == null) {
      return NotDataWidget(
        other: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '没有找到真题详情',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cZhenxieFontPrimary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
          ],
        ),
      );
    }
    final ZhenxieExamTaskDetailData detail = controller.detailData.value!;
    return Padding(
      padding: EdgeInsets.fromLTRB(90.wMin, 0, 90.wMin, 24.wMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 5,
            child: _buildMainCard(detail),
          ),
          SizedBox(width: 12.wMin),
                   Expanded(
            flex: 3,
            child: _buildAsideWidget(detail),
          ),
          
        ],
      ),
    );
  }

  Widget _buildMainCard(ZhenxieExamTaskDetailData detail) {
    final String wordLimitText = detail.wordLimit;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cZhenxieBackgroundPrimary.color,
        borderRadius: BorderRadius.circular(14.wMin),
        border: Border.all(
          color: AppTheme.cZhenxieBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(20.wMin, 14.wMin, 20.wMin, 14.wMin),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.cZhenxieBorderPrimary.color,
                  width: 1.wMin,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        detail.topic,
                        style: TextStyle(
                          fontSize: 20.wMin,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          color: AppTheme.cZhenxieFontPrimary.color,
                          fontFamily: AppFontValue.sourceHanSerifCN,
                        ),
                      ),
                    ),
                    if (wordLimitText.isNotEmpty) ...<Widget>[
                      SizedBox(width: 12.wMin),
                      _OutlineChip(
                        text: wordLimitText,
                        textColor: AppTheme.cZhenxieFontSecondary.color,
                        borderColor: AppTheme.cZhenxieBorderPrimary.color,
                        backgroundColor: AppTheme.cZhenxieFontPrimary.color.withValues(alpha: 0.03),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.wMin, 16.wMin, 20.wMin, 16.wMin),
              child: AppMarkdownWidget(
        data: detail.fullText ,
      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsideWidget(ZhenxieExamTaskDetailData detail) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _buildGoalsSection(detail),
          if (detail.topics.isNotEmpty) SizedBox(height: 12.wMin),
          if (detail.topics.isNotEmpty) _buildTopicsSection(detail),
          if (_hasWritingSection(detail)) SizedBox(height: 12.wMin),
          if (_hasWritingSection(detail)) _buildWritingSection(detail),
          if (detail.relatedTaskGroups.isNotEmpty) SizedBox(height: 12.wMin),
          if (detail.relatedTaskGroups.isNotEmpty) _buildRelatedTasksSection(detail),
        ],
      ),
    );
  }

  Widget _buildGoalsSection(ZhenxieExamTaskDetailData detail) {
    return _DetailSection(
      title: '考什么能力',
      titleFontSize: 16.wMin,
      child: Column(
        children: detail.goals
            .map((item) => Padding(
                  padding: EdgeInsets.only(top: 8.wMin),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.current ? '主' : '兼',
                        style: TextStyle(
                          fontSize: 14.wMin,
                          fontWeight: FontWeight.w500,
                          color: item.current
                              ? AppTheme.cZhenxieColorPrimary.color
                              : AppTheme.cZhenxieFontTertiary.color,
                          fontFamily: AppFontValue.robotoMono,
                        ),
                      ),
                      SizedBox(width: 8.wMin),
                      Expanded(
                        child: Text(
                          controller.buildZhText(item.name),
                          style: TextStyle(
                            fontSize: 16.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cZhenxieFontPrimary.color.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                      if (item.count > 0)
                        Text(
                          '${item.count} 题',
                          style: TextStyle(
                            fontSize: 14.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cZhenxieFontTertiary.color,
                            fontFamily: AppFontValue.robotoMono,
                          ),
                        ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildTopicsSection(ZhenxieExamTaskDetailData detail) {
    return _DetailSection(
      title: '写什么主题',
      titleFontSize: 16.wMin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: detail.topics
            .map((item) => Padding(
                  padding: EdgeInsets.only(top: 8.wMin),
                  child: Text(
                    controller.buildZhText(item.name),
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cZhenxieFontPrimary.color.withValues(alpha: 0.85),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildWritingSection(ZhenxieExamTaskDetailData detail) {
    final String writingStageText = detail.writingStage == null ? '' : controller.buildZhText(detail.writingStage!.name);
    final String writingTaskText = detail.writingTask == null ? '' : controller.buildZhText(detail.writingTask!.name);
    final String coverageText = detail.coverage == null ? '' : controller.buildZhText(detail.coverage!.name);
    return _DetailSection(
      title: '写作课怎么练',
      titleFontSize: 16.wMin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (writingStageText.isNotEmpty)
            Text(
              writingStageText,
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cZhenxieFontPrimary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
          if (detail.section.isNotEmpty) ...<Widget>[
            SizedBox(height: 6.wMin),
            Text(
              detail.section,
              style: TextStyle(
                fontSize: 14.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontTertiary.color,
              ),
            ),
          ],
          if (writingTaskText.isNotEmpty || coverageText.isNotEmpty) ...<Widget>[
            SizedBox(height: 10.wMin),
            Wrap(
              spacing: 6.wMin,
              runSpacing: 6.wMin,
              children: <Widget>[
                if (writingTaskText.isNotEmpty)
                  _OutlineChip(
                    text: writingTaskText,
                    fontSize: 14.wMin,
                    textColor: AppTheme.cZhenxieFontSecondary.color,
                    borderColor: AppTheme.cZhenxieBorderPrimary.color,
                    backgroundColor: AppTheme.cZhenxieFontPrimary.color.withValues(alpha: 0.03),
                  ),
                if (coverageText.isNotEmpty)
                  _OutlineChip(
                    text: coverageText,
                    fontSize: 14.wMin,
                    textColor: AppTheme.cZhenxieFontSecondary.color,
                    borderColor: AppTheme.cZhenxieBorderPrimary.color,
                    backgroundColor: AppTheme.cZhenxieFontPrimary.color.withValues(alpha: 0.03),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRelatedTasksSection(ZhenxieExamTaskDetailData detail) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.wMin, 14.wMin, 16.wMin, 14.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cZhenxieBackgroundPrimary.color,
        borderRadius: BorderRadius.circular(14.wMin),
        border: Border.all(
          color: AppTheme.cZhenxieBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '同类真题',
                style: TextStyle(
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cZhenxieFontPrimary.color,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                ),
              ),
              const Spacer(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: controller.openTaskList,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.wMin),
                  child: Text(
                    '看全部 →',
                    style: TextStyle(
                      fontSize: 12.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cZhenxieFontSecondary.color.withValues(alpha: 0.38),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.wMin),
          ...detail.relatedTaskGroups.asMap().entries.map((entry) {
            final ZhenxieExamRelatedTaskGroupData group = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: entry.key == detail.relatedTaskGroups.length - 1 ? 0 : 16.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    controller.buildZhText(group.title),
                    style: TextStyle(
                      fontSize: 14.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cZhenxieFontPrimary.color,
                      fontFamily: AppFontValue.sourceHanSerifCN,
                    ),
                  ),
                  SizedBox(height: 8.wMin),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 12.wMin,
                      mainAxisSpacing: 8.wMin,
                      mainAxisExtent: 230.wMin,
                    ),
                    itemCount: group.items.length,
                    itemBuilder: (_, index) {
                      final ZhenxieExamTaskCardData item = group.items[index];
                      return ZhenxieExamTaskCardWidget(
                        task: item,
                        milestoneColors: controller.findMilestoneThemeColors(item.milestone),
                        familyColors: controller.findFamilyThemeColors(item.family.code),
                        regionText: controller.buildRegionTextByTask(item),
                        familyText: controller.buildFamilyText(item),
                        milestoneText: controller.buildMilestoneText(item),
                        stageText: controller.buildStageText(item),
                        topicTexts: controller.buildTopicTexts(item).take(2).toList(),
                        requiredPoints: controller.buildVisibleRequiredPoints(item),
                        topicFontSize: 20.wMin,
                        onTap: () {
                          controller.openTaskDetail(item.uid);
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  bool _hasWritingSection(ZhenxieExamTaskDetailData detail) {
    return detail.writingStage != null || detail.writingTask != null || detail.coverage != null || detail.section.isNotEmpty;
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Widget child;
  final double? titleFontSize;

  const _DetailSection({
    required this.title,
    required this.child,
    this.titleFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.wMin, 14.wMin, 16.wMin, 14.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cZhenxieBackgroundPrimary.color,
        borderRadius: BorderRadius.circular(14.wMin),
        border: Border.all(
          color: AppTheme.cZhenxieBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize ?? 14.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cZhenxieFontPrimary.color,
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
          SizedBox(height: 4.wMin),
          child,
        ],
      ),
    );
  }
}

class _OutlineChip extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color textColor;
  final Color borderColor;
  final Color backgroundColor;

  const _OutlineChip({
    required this.text,
    this.fontSize,
    required this.textColor,
    required this.borderColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: borderColor,
          width: 1.wMin,
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fontSize ?? 11.wMin,
          fontWeight: FontWeight.w400,
          color: textColor,
          fontFamily: AppFontValue.robotoMono,
        ),
      ),
    );
  }
}
