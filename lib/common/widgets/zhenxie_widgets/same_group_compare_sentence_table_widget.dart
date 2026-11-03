
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../app/modules/management/common/commons.dart';
import '../../../theme/theme.dart';
import '../../../utils/utils.dart';
import '../../entities/entities.dart';
import '../widgets.dart';
import 'same_group_compare_highlight_text_utils.dart';
import 'same_group_compare_highlight_text_widget.dart';
import 'set_expansion_buttons_widget.dart';

class SameGroupCompareSentenceTableWidget extends StatelessWidget {
  final List<SentencePatternCompareMemberEntity?>? memberList;
  final List<SentencePatternCompareSentenceRealizationSetEntity?>? sentenceRealizationSetList;
  final bool isManagement;

  /// 组上下架回调
  final void Function(SentencePatternCompareSentenceRealizationSetEntity? sentenceRealizationSet)? onShelfChange;
  /// 组删除回调
  final void Function(SentencePatternCompareSentenceRealizationSetEntity? sentenceRealizationSet)? onDelete;
  /// 句子上下架回调
  final void Function(SentencePatternCompareSentenceBindingEntity? sentenceBinding)? onSentenceShelfChange;
  /// 刷新单独的数据
  final void Function(SentencePatternCompareSentenceBindingEntity? data)? onRefresh;

  /// 同组对照 句子列表
  const SameGroupCompareSentenceTableWidget({
    super.key,
    this.memberList,
    this.sentenceRealizationSetList,
    this.isManagement = false,
    this.onShelfChange,
    this.onDelete,
    this.onSentenceShelfChange,
    this.onRefresh,
  });

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
        return _buildSetWidget(
          sentenceRealizationSet: setList[index],
          index: index,
          total: setList.length,
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
      padding: EdgeInsets.all(4.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceLayerElevated.color,
        borderRadius: BorderRadius.circular(20.wMin),
        border: Border.all(
          color: AppTheme.cBorderBrand.color.withValues(alpha: 0.2),
          width: 0.8.wMin,
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
          Container(
            padding: EdgeInsets.all(16.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              color: AppTheme.cBgPrimary.color,
              border: Border.all(
                color: AppTheme.cBorderDefault.color,
                width: 1.wMin,
              ),
            ),
            child: ListView.separated(
              itemCount: memberList!.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) {
                return Container(
                  height: 1.wMin,
                  color: AppTheme.cBorderDark.color,
                  margin: EdgeInsets.symmetric(vertical: 24.wMin),
                );
              },
              itemBuilder: (context, memberIndex) {
                return _buildItemWidget(
                  memberList![memberIndex],
                  sentenceRealizationSet: sentenceRealizationSet,
                );
              },
            ),
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
    bool isNormal = sentenceRealizationSet?.isNormal ?? false;  
    return Container(
      padding: EdgeInsets.all(12.wMin),
      child: Row(
        children: [
          Text(
            "对照 ${index + 1}",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(width: 12.wMin),
          Visibility(
            visible: isManagement,
            child: _buildTagWidget(
              tagText: isNormal ? "已上架": "未上架",
              textColor: isNormal ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceWarning.color,
              bgColor: isNormal ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12) : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
              borderColor: isNormal ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2) : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
            ),
          ),
          Spacer(),

          Visibility(
            visible: isManagement && (onShelfChange != null || onDelete != null) && sentenceRealizationSet != null,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cSurfaceTertiary.color,
                borderRadius: BorderRadius.circular(6.wMin),
              ),
              child: Row(
                children: [
                  Visibility(
                    visible: onShelfChange != null,
                    child: ListingAndDelistingWidget(
                      value: sentenceRealizationSet?.isNormal ?? false,
                      showBorder: onDelete != null,
                      onChange: () {
                        onShelfChange?.call(sentenceRealizationSet);
                      },
                    ),
                  ),
                  Visibility(
                    visible: onDelete != null,
                    child: Container(
                      margin: EdgeInsets.only(left: onDelete != null ? 8.wMin : 0),
                      child: TapScaleWidget(
                        onTap: () async {
                          onDelete?.call(sentenceRealizationSet);
                        },
                        sclae: 1,
                        borderRadius: 8.wMin,
                        backColor: AppTheme.cSurfaceTertiary.color,
                        child: Container(
                          width: 50.wMin,
                          height: 40.wMin,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            "assets/svg/public/icon_delete.svg",
                            width: 24.wMin,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
    final binding = SameGroupCompareHighlightTextUtils.findBindingByValueNidInSet(
      sentenceRealizationSet: sentenceRealizationSet,
      valueNid: data?.valueNid,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildItemTitleWidget(data)),
            Visibility(
              visible: isManagement && onSentenceShelfChange != null && binding != null,
              child: ListingAndDelistingWidget(
                value: binding?.sentenceStruct?.isNormal ?? false,
                showBorder: false,
                onChange: () {
                  onSentenceShelfChange?.call(binding);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 12.wMin),
        _buildItemContentWidget(
          data,
          sentenceRealizationSet: sentenceRealizationSet,
        ),
      ],
    );
  }

  Widget _buildItemTitleWidget(SentencePatternCompareMemberEntity? data){
    final name = LearningLangUtils.getLocalLang(data?.realizationInfo?.pattern?.name);

    return Wrap(
      spacing: 8.wMin,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SuperpositionContainerWidget(
          width: 8.wMin,
          height: 8.wMin,
          shape: BoxShape.circle,
          color: AppTheme.cTextPrimary.color,
          foregroundColor: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.55),
        ),
        SuperpositionTextWidget(
          text: name?.text??'',
          foregroundColor: Color(0xffD946EF).withValues(alpha: 0.55),
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        Visibility(
          visible: isManagement,
          child: Container(
            margin: EdgeInsets.only(left: 4.wMin),
            child: CopyTagWidget(
              name: "对照",
              value: data?.realizationInfo?.patternNid??'',
              isShow: isManagement,
            ),
          ),
        ),
        Visibility(
          visible: isManagement,
          child: Container(
            margin: EdgeInsets.only(left: 4.wMin),
            child: CopyTagWidget(
              name: "轨值",
              value: data?.valueNid??'',
              isShow: isManagement,
            ),
          ),
        ),
      ],
    );

  }

  Widget _buildItemContentWidget(
    SentencePatternCompareMemberEntity? data, {
    SentencePatternCompareSentenceRealizationSetEntity? sentenceRealizationSet,
  }){
    final binding = SameGroupCompareHighlightTextUtils.findBindingByValueNidInSet(
      sentenceRealizationSet: sentenceRealizationSet,
      valueNid: data?.valueNid,
    );
    final focusMember = SameGroupCompareHighlightTextUtils.findMemberByValueNidInSet(
      sentenceRealizationSet: sentenceRealizationSet,
      valueNid: data?.valueNid,
    );
    bool isNormal = binding?.sentenceStruct?.isNormal ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SameGroupCompareHighlightTextWidget(
          isManagement: isManagement,
          sentenceStruct: binding?.sentenceStruct,
          sentenceId: binding?.sentenceId,
          contrastFocus: data?.contrastFocus,
          foci: focusMember?.foci,
          emptyLabel: "（尚无例句）",
          fontSize: 28.wMin,
          fontColor: AppTheme.cTextSecondary.color,
          showSentenceDefinition: true,
          isNormal: isNormal,
        ),
        SizedBox(height: 10.wMin),
        Container(
          alignment: Alignment.centerRight,
          child: Visibility(
            visible: binding?.sentenceId != null,
            child: SetExpansionButtonsWidget(
              isManagement: isManagement,
              contentId: binding?.sentenceId,
              contentType: binding?.sentenceStruct?.contentType,
              content: binding?.sentenceStruct?.content,
              onRefresh: () {
                onRefresh?.call(binding);
              },
            ),
          ),
        ),
        
      ],
    );
  }

  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cTextSecondary,
    Color bgColor = AppTheme.cSurfaceLayerBase,
    Color borderColor = AppTheme.cBorderThin,
  }){
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
