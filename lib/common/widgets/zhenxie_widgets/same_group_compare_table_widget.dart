
import 'package:flutter/material.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../app/modules/management/common/commons.dart';
import '../../../theme/theme.dart';
import '../../entities/entities.dart';
import '../../values/values.dart';
import 'same_group_compare_highlight_text_widget.dart';
import 'same_group_compare_highlight_text_utils.dart';

class SameGroupCompareTableWidget extends StatelessWidget {
  final List<SentencePatternCompareMemberEntity?>? memberList;
  final List<ZhenxieRealizationSetsEntity?>? realizationSets;
  final bool isManagement;
  final Widget? sentenceWidget;

  /// 同组对照表
  const SameGroupCompareTableWidget({
    super.key,
    this.memberList,
    this.realizationSets,
    this.isManagement = false,
    this.sentenceWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (memberList == null || memberList!.isEmpty) return Container();

    return Column(
      spacing: 24.wMin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(memberList!.length, (index) {
        return _buildItemWidget(memberList![index]);
      }),
    );
  }

  /// 渲染单个对照成员及其对应例句。
  Widget _buildItemWidget(SentencePatternCompareMemberEntity? data) {
    final realizationSet = SameGroupCompareHighlightTextUtils.findBestCommonRealizationSet(realizationSets);
    final focusMember = SameGroupCompareHighlightTextUtils.findSentenceMemberByValueNidInRealizationSet(
      realizationSet: realizationSet,
      valueNid: data?.valueNid,
    );
    final name = LearningLangUtils.getLocalLang(data?.realizationInfo?.pattern?.name);
    bool isNormal = focusMember?.sentence?.isNormal ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 4.wMin,
          runSpacing: 4.wMin,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              name?.text ?? '',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cZhenxieFontSecondary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
            if (isManagement) ...[
              CopyTagWidget(
                name: "句型",
                value: data?.realizationInfo?.patternNid ?? '',
                isShow: isManagement,
              ),
              CopyTagWidget(
                name: "轨值",
                value: data?.valueNid ?? '',
                isShow: isManagement,
              ),
            ],
          ],
        ),
        SizedBox(height: 6.wMin),
        SameGroupCompareHighlightTextWidget(
          isManagement: isManagement,
          sentenceStruct: focusMember?.sentence,
          sentenceId: focusMember?.sentence?.sentenceId,
          foci: focusMember?.foci,
          emptyLabel: "（尚无例句）",
          isNormal: isNormal,
          showSentenceDefinition: true,
          contentFontFamily: AppFontValue.robotoMono,
          definitionFontFamily: AppFontValue.sourceHanSerifCN,
          fontColor: AppTheme.cZhenxieFontPrimary.color,
          highlightBackgroundColor: Color(0xffEAB308),
        ),
        SizedBox(child: sentenceWidget),
      ],
    );
  }
}
