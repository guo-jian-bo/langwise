
import 'package:flutter/material.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../app/modules/management/common/commons.dart';
import '../../../theme/theme.dart';
import '../../entities/entities.dart';
import 'same_group_compare_highlight_text_widget.dart';
import 'same_group_compare_highlight_text_utils.dart';

class SameGroupCompareTableWidget extends StatelessWidget {
  final List<SentencePatternCompareMemberEntity?>? memberList;
  final List<SentencePatternCompareSentenceRealizationSetEntity?>? sentenceRealizationSetList;
  final bool showCopyTags;
  final bool isManagement;

  /// 同组对照表
  const SameGroupCompareTableWidget({
    super.key,
    this.memberList,
    this.sentenceRealizationSetList,
    this.showCopyTags = true,
    this.isManagement = false,
  });

  @override
  Widget build(BuildContext context) {
    if(memberList == null || memberList!.isEmpty) return Container();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        children: [
          _buildTitleWidget(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(memberList!.length, (index){
              return _buildItemRowWidget(memberList![index]);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Row(
        children: [
          Text(
            "同组对照",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          Text(
            " · 焦点着色=本壳要搓的槽",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildItemRowWidget(SentencePatternCompareMemberEntity? data){
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: _buildItemRowLeftWidget(data)),
            Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
            Expanded(child: _buildItemRowRightWidget(data)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRowLeftWidget(SentencePatternCompareMemberEntity? data){
    final name = LearningLangUtils.getLocalLang(data?.realizationInfo?.pattern?.name);
    final valueLabelName = LearningLangUtils.getLocalLang(data?.valueLabel?.name);
    
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                valueLabelName?.text ?? (data?.valueLabel?.nid??''),
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
              SizedBox(width: 16.wMin),
              if (showCopyTags)
                CopyTagWidget(
                  name: "轨值",
                  value: data?.valueNid??'',
                  isShow: isManagement,
                ),
            ],
          ),
          SizedBox(height: 8.wMin),
          Wrap(
            spacing: 4.wMin,
            runSpacing: 4.wMin,
            children: [
              Text(
                name?.text??'',
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              if (showCopyTags)
                CopyTagWidget(
                  name: "对照",
                  value: data?.realizationInfo?.patternNid??'',
                  isShow: isManagement,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemRowRightWidget(SentencePatternCompareMemberEntity? data){
    final binding = SameGroupCompareHighlightTextUtils.findBindingByValueNid(
      sentenceRealizationSetList: sentenceRealizationSetList,
      valueNid: data?.valueNid,
    );
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: SameGroupCompareHighlightTextWidget(
        isManagement: isManagement,
        sentenceStruct: binding?.sentenceStruct,
        sentenceId: binding?.sentenceId,
        contrastFocus: data?.contrastFocus,
        emptyLabel: "（尚无例句）",
        showCopyTags: showCopyTags,
      ),
    );
  }


}
