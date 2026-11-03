
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
  final List<SentencePatternCompareSentenceRealizationSetEntity?>? sentenceRealizationSetList;
  final bool isManagement;
  final Widget? sentenceWidget;

  /// 同组对照表
  const SameGroupCompareTableWidget({
    super.key,
    this.memberList,
    this.sentenceRealizationSetList,
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
    final sentenceRealizationSet = SameGroupCompareHighlightTextUtils.findBestRealizationSet(sentenceRealizationSetList);
    final binding = SameGroupCompareHighlightTextUtils.findBindingByValueNidInSet(
      sentenceRealizationSet: sentenceRealizationSet,
      valueNid: data?.valueNid,
    );
    final focusMember = SameGroupCompareHighlightTextUtils.findMemberByValueNidInSet(
      sentenceRealizationSet: sentenceRealizationSet,
      valueNid: data?.valueNid,
    );
    final name = LearningLangUtils.getLocalLang(data?.realizationInfo?.pattern?.name);
    bool isNormal = binding?.sentenceStruct?.isNormal ?? false;

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
          sentenceStruct: binding?.sentenceStruct,
          sentenceId: binding?.sentenceId,
          contrastFocus: data?.contrastFocus,
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
