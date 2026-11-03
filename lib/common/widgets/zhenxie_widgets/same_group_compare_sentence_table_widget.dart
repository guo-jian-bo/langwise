
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lib_common/utils/optimize_utils.dart' show OptimizeUtils;
import 'package:ui_essentials/ui_essentials.dart';

import '../../../app/modules/management/common/commons.dart';
import '../../../app/modules/management/utils/utils.dart';
import '../../../app/routes/routes.dart';
import '../../../theme/theme.dart';
import '../../../utils/utils.dart';
import '../../entities/entities.dart';
import '../widgets.dart';
import 'same_group_compare_highlight_text_utils.dart';
import 'same_group_compare_highlight_text_widget.dart';

class SameGroupCompareSentenceTableWidget extends StatelessWidget {
  final List<SentencePatternCompareMemberEntity?>? memberList;
  final List<SentencePatternCompareSentenceRealizationSetEntity?>? sentenceRealizationSetList;
  /// 同组对照 句子列表
  const SameGroupCompareSentenceTableWidget({super.key, this.memberList, this.sentenceRealizationSetList});

  @override
  Widget build(BuildContext context) {
    if(memberList == null || memberList!.isEmpty) return const SizedBox.shrink();

    final setList = SameGroupCompareHighlightTextUtils.getSortedRealizationSetList(sentenceRealizationSetList);
    if (setList.isEmpty) {
      return _buildSetWidget();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(setList.length, (index) {
        return Container(
          margin: EdgeInsets.only(bottom: index == setList.length - 1 ? 0 : 16.wMin),
          child: _buildSetWidget(
            sentenceRealizationSet: setList[index],
            index: index,
            total: setList.length,
          ),
        );
      }),
    );
  }

  Widget _buildSetWidget({
    SentencePatternCompareSentenceRealizationSetEntity? sentenceRealizationSet,
    int index = 0,
    int total = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget(
            sentenceRealizationSet: sentenceRealizationSet,
            index: index,
            total: total,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(memberList!.length, (memberIndex) {
              return _buildItemWidget(
                memberList![memberIndex],
                sentenceRealizationSet: sentenceRealizationSet,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleWidget({
    SentencePatternCompareSentenceRealizationSetEntity? sentenceRealizationSet,
    int index = 0,
    int total = 1,
  }) {
    final previewFromSets = sentenceRealizationSet == null
        ? SameGroupCompareHighlightTextUtils.isPreviewFromSets(sentenceRealizationSetList)
        : SameGroupCompareHighlightTextUtils.isPreviewFromSet(sentenceRealizationSet);
    final titleText = total > 1 ? "同组对照 ${index + 1}" : "同组对照";
    final subtitleText = total > 1 && sentenceRealizationSet?.order != null
        ? " · order ${sentenceRealizationSet?.order} · 焦点着色=本壳要搓的槽"
        : " · 焦点着色=本壳要搓的槽";
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              children: [
                Text(
                  titleText,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextSecondary.color,
                  ),
                ),
                Text(
                  subtitleText,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary.color,
                  ),
                ),
              ],
            ),
          ),
          Text(
            previewFromSets ? "库内句 · 结构槽" : "未通过严格 match · 草稿不着色",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemWidget(
    SentencePatternCompareMemberEntity? data, {
    SentencePatternCompareSentenceRealizationSetEntity? sentenceRealizationSet,
  }){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemTitleWidget(data),
          SizedBox(height: 12.wMin),
          _buildItemContentWidget(
            data,
            sentenceRealizationSet: sentenceRealizationSet,
          ),
        ],
      ),
    );
  }

  Widget _buildItemTitleWidget(SentencePatternCompareMemberEntity? data){
    final name = LearningLangUtils.getLocalLang(data?.realizationInfo?.pattern?.name);
    return Text.rich(TextSpan(
      style: TextStyle(
        fontSize: 24.wMin,
        fontWeight: FontWeight.w500,
        color: AppTheme.cTextPrimary.color,
      ),
      children: [
        TextSpan(text: name?.text??''),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: EdgeInsets.only(left: 4.wMin),
            child: CopyTagWidget(
              name: "对照",
              value: data?.realizationInfo?.patternNid??'',
            ),
          ),
        ),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: EdgeInsets.only(left: 4.wMin),
            child: CopyTagWidget(
              name: "轨值",
              value: data?.valueNid??'',
            ),
          ),
        ),
      ],
    ));
  }

  Widget _buildItemContentWidget(
    SentencePatternCompareMemberEntity? data, {
    SentencePatternCompareSentenceRealizationSetEntity? sentenceRealizationSet,
  }){
    final binding = SameGroupCompareHighlightTextUtils.findBindingByValueNidInSet(
      sentenceRealizationSet: sentenceRealizationSet,
      valueNid: data?.valueNid,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SameGroupCompareHighlightTextWidget(
          sentenceStruct: binding?.sentenceStruct,
          sentenceId: binding?.sentenceId,
          contrastFocus: data?.contrastFocus,
          emptyLabel: "（尚无例句）",
          fontSize: 28.wMin,
          fontColor: AppTheme.cTextTertiary.color,
          showSentenceDefinition: true,
        ),
        Visibility(
          visible: binding?.sentenceStruct?.segmentList?.isNotEmpty ?? false,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 12.wMin),
            padding: EdgeInsets.all(8.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: AppTheme.cSurfaceLayerBase.color,
              border: Border.all(
                width: 0.8.wMin,
                color: AppTheme.cBorderThin.color,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SentenceSlotExampleWidget(
                    segmentList: binding?.sentenceStruct?.segmentList,
                  ),
                ),
                ButtonWidget(
                  text: "打开蓝图",
                  height: 34.wMin,
                  padding: EdgeInsets.only(left: 12.wMin, right: 4.wMin),
                  color: AppTheme.cSurfaceLayerElevated.color,
                  fontSize: 18.wMin,
                  fontColor: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w500,
                  sclae: 1.03,
                  rightIcon: SvgPicture.asset(
                    "assets/svg/public/icon_w_arrow_right.svg",
                    width: 20.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
                  ),
                  onTap: OptimizeUtils.noneThrottle(() {
                    if(binding?.sentenceStruct?.patternNid == null) return;
                    ManagePageRegistry.jumpTo(
                      Routes.MANAGE_PATTERN_BLUEPRINT_DETAILS,
                      arguments: {
                        "nid": binding?.sentenceStruct?.patternNid,
                      },
                    );
                  }, 1000),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

}
