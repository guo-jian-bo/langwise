import 'package:flutter/material.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../common/values/values.dart';
import '../../../management/common/commons.dart';
import '../../../../../common/widgets/zhenxie_widgets/set_expansion_buttons_widget.dart';

class ZhenxieSentencePairDetailsTableWidget extends StatelessWidget {
  final SentencePairRealizationInfoEntity? fromRealization;
  final SentencePairRealizationInfoEntity? toRealization;
  final List<SentencePairSentenceRealizationEntity?>? realizationSetList;
  final bool isManagement;
  final void Function(SentencePairSentenceRealizationEntity? sentenceRealizationSet)? onShelfChange;
  final void Function(SentencePairSentenceRealizationEntity? sentenceRealizationSet)? onDelete;
  final void Function(SentencePairSentenceBriefEntity? sentenceBinding)? onSentenceShelfChange;
  final VoidCallback? onRefresh;

  /// 句对详情卡片表，仅承接详情页 UI 展示与事件透传。
  const ZhenxieSentencePairDetailsTableWidget({
    super.key,
    this.fromRealization,
    this.toRealization,
    this.realizationSetList,
    this.isManagement = false,
    this.onShelfChange,
    this.onDelete,
    this.onSentenceShelfChange,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final List<SentencePairSentenceRealizationEntity?> setList = List<SentencePairSentenceRealizationEntity?>.from(realizationSetList ?? [])
      ..sort((a, b) => (a?.order ?? 0).compareTo(b?.order ?? 0));
    if (setList.isEmpty) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildSetCardWidget(
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
                  child: _buildSetCardWidget(
                    context: context,
                    sentenceRealization: setList[leftIndex],
                    index: leftIndex,
                  ),
                ),
                Expanded(
                  child: rightIndex < setList.length
                      ? _buildSetCardWidget(
                          context: context,
                          sentenceRealization: setList[rightIndex],
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

  /// 单个句对卡片，结构参考句型对照详情页的卡片布局。
  Widget _buildSetCardWidget({
    required BuildContext context,
    SentencePairSentenceRealizationEntity? sentenceRealization,
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
            sentenceRealization: sentenceRealization,
            index: index,
          ),
          Container(
            height: 1.wMin,
            color: AppTheme.cZhenxieBorderPrimary.color,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSentenceItemWidget(
                  realization: fromRealization,
                  sentenceBrief: sentenceRealization?.fromSentenceStruct,
                  isFrom: true,
                ),
                Container(
                  height: 1.wMin,
                  margin: EdgeInsets.symmetric(vertical: 16.wMin),
                  color: AppTheme.cZhenxieBorderPrimary.color,
                ),
                _buildSentenceItemWidget(
                  realization: toRealization,
                  sentenceBrief: sentenceRealization?.toSentenceStruct,
                  isFrom: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 卡片标题区，复用对照详情页的管理操作排布。
  Widget _buildTitleWidget({
    required BuildContext context,
    SentencePairSentenceRealizationEntity? sentenceRealization,
    int index = 0,
  }) {
    final bool isNormal = sentenceRealization?.isNormal ?? false;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
      child: Row(
        children: [
          Text(
            "配对 ${index + 1}",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cZhenxieFontPrimary.color,
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
          SizedBox(width: 12.wMin),
          Visibility(
            visible: isManagement && sentenceRealization != null,
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
            visible: isManagement && sentenceRealization != null,
            child: ManageIpDownEditDelWidget(
              isNormal: isNormal,
              onShelf: () {
                onShelfChange?.call(sentenceRealization);
              },
              onDelete: () {
                onDelete?.call(sentenceRealization);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 单侧句子块，沿用句对列表项的视觉语言。
  Widget _buildSentenceItemWidget({
    required SentencePairRealizationInfoEntity? realization,
    required SentencePairSentenceBriefEntity? sentenceBrief,
    required bool isFrom,
  }) {
    final LanguageText? patternName = LearningLangUtils.getLocalLang(realization?.pattern?.name);
    final bool isNormal = sentenceBrief?.isNormal ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12.wMin,
              height: 12.wMin,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: !isFrom ? AppTheme.cZhenxieFontPrimary.color : Colors.transparent,
                border: Border.all(
                  color: AppTheme.cZhenxieFontPrimary.color,
                  width: 2.wMin,
                ),
              ),
            ),
            SizedBox(width: 8.wMin),
            Expanded(
              child: Wrap(
                spacing: 4.wMin,
                runSpacing: 4.wMin,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    patternName?.text ?? '',
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cZhenxieFontSecondary.color,
                      fontFamily: AppFontValue.sourceHanSerifCN,
                    ),
                  ),
                  Visibility(
                    visible: isManagement,
                    child: CopyTagWidget(
                      name: "句型",
                      value: realization?.patternNid ?? '',
                      isShow: isManagement,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (sentenceBrief != null) ...[
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(left: 20.wMin, top: 6.wMin),
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cZhenxieFontPrimary.color,
                  fontFamily: AppFontValue.robotoMono,
                ),
                children: [
                  TextSpan(text: sentenceBrief.content ?? ''),
                  if (isManagement) ...[
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        margin: EdgeInsets.only(left: 4.wMin),
                        child: CopyTagWidget(
                          name: "句子",
                          value: sentenceBrief.sentenceId?.toString() ?? '',
                          isShow: isManagement,
                        ),
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        margin: EdgeInsets.only(left: 4.wMin),
                        child: _buildTagWidget(
                          tagText: isNormal ? "已上架" : "未上架",
                          textColor: isNormal ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceWarning.color,
                          bgColor: isNormal
                              ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12)
                              : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                          borderColor: isNormal
                              ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2)
                              : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(left: 20.wMin, top: 6.wMin),
            child: Text(
              sentenceBrief.definition ?? '',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontTertiary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 20.wMin, top: 8.wMin),
            child: SetExpansionButtonsWidget(
              isManagement: isManagement,
              sentenceId: sentenceBrief.sentenceId,
              content: sentenceBrief.content,
              isNormal: isNormal,
              onShelf: () {
                onSentenceShelfChange?.call(sentenceBrief);
              },
              onRefresh: onRefresh,
            ),
          ),
        ] else ...[
          Container(
            margin: EdgeInsets.only(left: 20.wMin, top: 6.wMin),
            child: Text(
              "暂无例句",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 页面内统一的小标签样式。
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
