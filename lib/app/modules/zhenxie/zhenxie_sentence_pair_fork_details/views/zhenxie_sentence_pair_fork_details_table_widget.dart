import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/values/values.dart';
import '../../../../../common/widgets/zhenxie_widgets/set_expansion_buttons_widget.dart';

class ZhenxieSentencePairForkDetailsTableWidget extends StatelessWidget {
  final List<SentenceForkSentenceRealizationEntity?>? realizationSetList;
  final bool isManagement;
  final void Function(SentenceForkSentenceRealizationEntity? group)? onShelfChange;
  final void Function(SentenceForkSentenceRealizationEntity? group)? onDelete;
  final void Function(SentenceForkSentenceBriefEntity? sentence)? onSentenceShelfChange;
  final VoidCallback? onRefresh;

  /// 分叉详情卡片表，负责组级操作与句子级扩展按钮编排。
  const ZhenxieSentencePairForkDetailsTableWidget({
    super.key,
    this.realizationSetList,
    this.isManagement = false,
    this.onShelfChange,
    this.onDelete,
    this.onSentenceShelfChange,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final List<SentenceForkSentenceRealizationEntity?> setList = List<SentenceForkSentenceRealizationEntity?>.from(realizationSetList ?? [])
      ..sort((a, b) => (a?.order ?? 0).compareTo(b?.order ?? 0));
    if (setList.isEmpty) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildGroupCardWidget(
              context: context,
              index: 0,
            ),
          ),
          Expanded(child: SizedBox()),
        ],
      );
    }

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
                  child: _buildGroupCardWidget(
                    context: context,
                    group: setList[leftIndex],
                    index: leftIndex,
                  ),
                ),
                Expanded(
                  child: rightIndex < setList.length
                      ? _buildGroupCardWidget(
                          context: context,
                          group: setList[rightIndex],
                          index: rightIndex,
                        )
                      : SizedBox.shrink(),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// 单个分叉组卡片。
  Widget _buildGroupCardWidget({
    required BuildContext context,
    SentenceForkSentenceRealizationEntity? group,
    int index = 0,
  }) {
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
            group: group,
            index: index,
          ),
          Container(
            height: 1.wMin,
            color: AppTheme.cZhenxieBorderPrimary.color,
          ),
          Padding(
            padding: EdgeInsets.all(24.wMin),
            child: group == null ? _buildEmptyWidget() : _buildForkTableWidget(group),
          ),
        ],
      ),
    );
  }

  /// 标题区，承接分叉组状态与管理操作。
  Widget _buildTitleWidget({
    required BuildContext context,
    SentenceForkSentenceRealizationEntity? group,
    int index = 0,
  }) {
    final bool isNormal = group?.isNormal ?? false;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
      child: Row(
        children: [
          Text(
            "分叉 ${index + 1}",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cZhenxieFontPrimary.color,
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
          SizedBox(width: 12.wMin),
          Visibility(
            visible: isManagement && group != null,
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
            visible: isManagement && group != null,
            child: ManageIpDownEditDelWidget(
              isNormal: isNormal,
              onShelf: () {
                onShelfChange?.call(group);
              },
              onDelete: () {
                onDelete?.call(group);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 分叉链路主体，复用公共 fork 表格，只扩展句子操作区。
  Widget _buildForkTableWidget(SentenceForkSentenceRealizationEntity group) {
    return SentencePairingLinkForkTableWidget(
      realizationSetList: [group],
      isManagement: isManagement,
      sentenceWidgetBuilder: (sentence) {
        if (sentence == null) return const SizedBox.shrink();
        return Container(
          margin: EdgeInsets.only(top: 8.wMin),
          child: SetExpansionButtonsWidget(
            isManagement: isManagement,
            contentId: sentence.sentenceId,
            contentType: KnowledgeTypeEnum.EN_SENTENCE.value,
            content: sentence.content ?? '',
            isNormal: sentence.isNormal,
            onShelf: () {
              onSentenceShelfChange?.call(sentence);
            },
            onRefresh: onRefresh,
          ),
        );
      },
    );
  }

  /// 空数据占位。
  Widget _buildEmptyWidget() {
    return Text(
      "暂无例句",
      style: TextStyle(
        fontSize: 18.wMin,
        fontWeight: FontWeight.w400,
        color: AppTheme.cTextTertiary.color,
        fontFamily: AppFontValue.sourceHanSerifCN,
      ),
    );
  }

  /// 页面内统一标签样式。
  Widget _buildTagWidget({
    required String tagText,
    Color? textColor = AppTheme.cZhenxieFontTertiary,
    Color? bgColor = AppTheme.cZhenxieBackgroundPrimary,
    Color? borderColor = AppTheme.cZhenxieBorderPrimary,
  }) {
    return Container(
      height: 28.wMin,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: bgColor,
        border: Border.all(
          color: (borderColor ?? AppTheme.cZhenxieBorderPrimary.color).withValues(alpha: 0.2),
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
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
        ],
      ),
    );
  }
}
