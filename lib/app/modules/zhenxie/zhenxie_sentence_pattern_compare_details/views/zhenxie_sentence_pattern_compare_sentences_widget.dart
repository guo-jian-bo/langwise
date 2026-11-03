import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/values/values.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../common/widgets/zhenxie_widgets/same_group_compare_highlight_text_utils.dart';
import '../../../../../common/widgets/zhenxie_widgets/set_expansion_buttons_widget.dart';
import '../../../../../theme/theme.dart';
import '../controllers/zhenxie_sentence_pattern_compare_details_controller.dart';

class ZhenxieSentencePatternCompareSentencesWidget extends StatelessWidget {
  final ZhenxieSentencePatternCompareDetailsController controller;
  const ZhenxieSentencePatternCompareSentencesWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final setList = SameGroupCompareHighlightTextUtils.getSortedCommonRealizationSetList(
        controller.exampleList.toList(),
      );
      if (setList.isEmpty) return Container();

      final int rowCount = (setList.length / 2).ceil();

      return SizedBox(
        width: double.infinity,
        child: Column(
          spacing: 16.wMin,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(rowCount, (rowIndex) {
            final int leftIndex = rowIndex * 2;
            final int rightIndex = leftIndex + 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16.wMin,
                children: [
                  Expanded(
                    child: _buildListItemWidget(
                      context: context,
                      sentenceRealizationSet: setList[leftIndex],
                      index: leftIndex,
                      total: setList.length,
                    ),
                  ),
                  Expanded(
                    child: rightIndex < setList.length
                        ? _buildListItemWidget(
                            context: context,
                            sentenceRealizationSet: setList[rightIndex],
                            index: rightIndex,
                            total: setList.length,
                          )
                        : SizedBox.shrink(),
                  ),
                ],
              ),
            );
          }),
        ),
      );
    });
  }

  Widget _buildListItemWidget({
    required BuildContext context,
    required ZhenxieRealizationSetsEntity sentenceRealizationSet,
    required int index,
    required int total,
  }) {
    return _buildSetWidget(
      context: context,
      sentenceRealizationSet: sentenceRealizationSet,
      index: index,
      total: total,
    );
  }

  Widget _buildSetWidget({
    required BuildContext context,
    ZhenxieRealizationSetsEntity? sentenceRealizationSet,
    int index = 0,
    int total = 1,
  }) {
    final memberList = sentenceRealizationSet?.members ?? [];
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cZhenxieBackgroundPrimary.color,
        borderRadius: BorderRadius.circular(16.wMin),
        border: Border.all(
          color: AppTheme.cZhenxieBorderPrimary.color,
          width: 0.8.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget(
            context: context,
            sentenceRealizationSet: sentenceRealizationSet,
            index: index,
            total: total,
          ),
          Container(
            height: 1.wMin,
            color: AppTheme.cZhenxieBorderPrimary.color,
          ),
          SizedBox(height: 16.wMin),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 24.wMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(memberList.length, (itemIndex) {
                return Column(
                  children: [
                    Visibility(
                      visible: itemIndex != 0,
                      child: Container(
                        height: 1.wMin,
                        color: AppTheme.cZhenxieBorderPrimary.color,
                        margin: EdgeInsets.symmetric(vertical: 16.wMin),
                      ),
                    ),
                    _buildItemWidget(
                      memberList[itemIndex],
                      sentenceRealizationSet: sentenceRealizationSet,
                    ),
                  ],
                );
              }),
            ),
          ),
          SizedBox(height: 16.wMin),
        ],
      ),
    );
  }

  Widget _buildTitleWidget({
    required BuildContext context,
    ZhenxieRealizationSetsEntity? sentenceRealizationSet,
    int index = 0,
    int total = 1,
  }) {
    bool isNormal = sentenceRealizationSet?.isNormal ?? false;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
      child: Row(
        children: [
          Text(
            "对照 ${index + 1}",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cZhenxieFontPrimary.color,
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
          SizedBox(width: 12.wMin),
          Visibility(
            visible: controller.isManagement,
            child: _buildTagWidget(
              tagText: isNormal ? "已上架" : "未上架",
              textColor: isNormal ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceWarning.color,
              bgColor: isNormal
                  ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12)
                  : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
              borderColor:
                  isNormal ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2) : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
            ),
          ),
          Spacer(),
          Visibility(
            visible: controller.isManagement && sentenceRealizationSet != null,
            child: ManageIpDownEditDelWidget(
              isNormal: sentenceRealizationSet?.isNormal ?? false,
              onShelf: () {
                controller.exampleSentenceGroupShelf(sentenceRealizationSet);
              },
              onDelete: () {
                controller.exampleSentenceGroupDelete(context, sentenceRealizationSet);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemWidget(
    ZhenxieSentenceMemberEntity? data, {
    ZhenxieRealizationSetsEntity? sentenceRealizationSet,
  }) {
    final compareMember = _buildCompareMember(data);
    final binding = SameGroupCompareHighlightTextUtils.findBindingByValueNidInRealizationSet(
      realizationSet: sentenceRealizationSet,
      valueNid: compareMember?.valueNid,
    );
    bool isNormal = binding?.sentenceStruct?.isNormal ?? false;
    return SizedBox(
      width: double.infinity,
      child: SameGroupCompareTableWidget(
        isManagement: controller.isManagement,
        memberList: compareMember == null ? null : [compareMember],
        realizationSets: sentenceRealizationSet == null ? null : [sentenceRealizationSet],
        sentenceWidget: Visibility(
          visible: sentenceRealizationSet != null,
          child: Container(
            margin: EdgeInsets.only(top: 8.wMin),
            child: SetExpansionButtonsWidget(
              isManagement: controller.isManagement,
              sentenceId: binding?.sentenceId,
              content: binding?.sentenceStruct?.content ?? '',
              isNormal: isNormal,
              onShelf: () {
                controller.exampleSentenceShelf(binding);
              },
              onRefresh: () {
                // controller.getDetailData();
              },
            ),
          ),
        ),
      ),
    );
  }

  /// 将详情页成员适配成同组对照表展示所需的轻量成员结构。
  SentencePatternCompareMemberEntity? _buildCompareMember(ZhenxieSentenceMemberEntity? data) {
    if (data == null) return null;

    final pattern = data.toPattern;
    return SentencePatternCompareMemberEntity(
      valueNid: data.valueNid,
      order: data.order,
      foci: SameGroupCompareHighlightTextUtils.buildCompareFocusList(data.foci),
      realizationInfo: pattern == null
          ? null
          : SentencePatternCompareTeachingEntryInfoEntity(
              patternNid: pattern.nid,
              pattern: SentencePatternComparePatternInfoEntity(
                nid: pattern.nid,
                name: pattern.name,
                description: pattern.description,
                template: pattern.template,
              ),
            ),
    );
  }

  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cTextSecondary,
    Color bgColor = AppTheme.cSurfaceLayerBase,
    Color borderColor = AppTheme.cBorderThin,
  }) {
    return Container(
      height: 28.wMin,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: bgColor,
        border: Border.all(
          color: borderColor.withValues(alpha: 0.2),
          width: 0.5.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tagText,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
