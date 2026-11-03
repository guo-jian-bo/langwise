import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../app/modules/management/common/commons.dart';
import '../../entities/entities.dart';
import '../../values/values.dart';
import '../widgets.dart';
import '../../../theme/theme.dart';

class PatternBlueprintItemWidget extends StatefulWidget {
  final PatternBlueprintEntity data;
  final void Function()? onTap;
  final bool isManagement;
  /// 是否 为选择模式
  final bool isSelectMode;
  /// 是否 选中
  final bool isSelected;

  /// 高亮句子释义的句子id
  final int? highlightSentenceId;

  /// 句型蓝图/金字塔 卡片
  const PatternBlueprintItemWidget({
    super.key,
    required this.data,
    this.onTap,
    this.isManagement = false,
    this.isSelectMode = false,
    this.isSelected = false,
    this.highlightSentenceId,
  });

  @override
  State<PatternBlueprintItemWidget> createState() => _PatternBlueprintItemWidgetState();
}

class _PatternBlueprintItemWidgetState extends State<PatternBlueprintItemWidget> {

  /// 是否鼠标悬浮
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    
    return TapScaleWidget(
      onTap: widget.onTap,
      sclae: 1,
      backColor: AppTheme.cZhenxieFontPrimary.color.withValues(alpha: 0.06),
      borderRadius: 16.wMin,
      child: Container(
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cZhenxieBackgroundPrimary.color,
          border: Border.all(
            color: AppTheme.cZhenxieBorderPrimary.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContentLeftWidget(),
            _buildSentenceWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildContentLeftWidget() {
    LanguageText? familyName = LearningLangUtils.getLocalLang(widget.data.family?.name);
    LanguageText? name = LearningLangUtils.getLocalLang(widget.data.name);
    LanguageText? description = LearningLangUtils.getLocalLang(widget.data.description);

    LanguageText? functionalTypeName = LearningLangUtils.getLocalLang(widget.data.functionalType?.name);
    LanguageText? basicTypeName = LearningLangUtils.getLocalLang(widget.data.basicType?.name);
    LanguageText? svocaTypeName = LearningLangUtils.getLocalLang(widget.data.primarySvoca?.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8.wMin,
              height: 8.wMin,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffD9D9D9),
              ),
            ),
            SizedBox(width: 6.wMin),
            Expanded(
              child: Text(
                familyName?.text ?? "",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontTertiary.color,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                ),
              ),
            ),
            _buildTagWidget(
              tagText: "${functionalTypeName?.text ?? ''} > ${basicTypeName?.text ?? ''} > ${svocaTypeName?.text ?? ''}",
            ),
            Visibility(
              visible: widget.isSelectMode,
              child: Container(
                margin: EdgeInsets.only(left: 12.wMin),
                child: SvgPicture.asset(
                  widget.isSelected? "assets/svg/manage/icon_check_box.svg" : "assets/svg/manage/icon_uncheck_box.svg",
                  width: 24.wMin,
                  height: 24.wMin,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.wMin),
        Wrap(
          spacing: 4.wMin,
          runSpacing: 4.wMin,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              name?.text ?? "",
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cZhenxieFontPrimary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
            CopyTagWidget(
              name: "句型",
              value: widget.data.nid ?? "",
              isShow: widget.isManagement,
            ),
          ],
        ),
        SizedBox(height: 10.wMin),
        Text(
          description?.text ?? "",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cZhenxieFontSecondary.color,
            fontFamily: AppFontValue.sourceHanSerifCN,
          ),
        ),
      ],
    );
  }

  Widget _buildSentenceWidget() {

    List<ZhenxieRealizationSetsEntity?> realizationSets = widget.data.realizationSets?? [];
    
    if(realizationSets.isEmpty){
      return Visibility(
        visible: widget.isManagement,
        child: Container(
          margin: EdgeInsets.only(top: 16.wMin),
          child: Text(
            "待教研签发代表句",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontTertiary.color,
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
        ),
      );
    }

    List<ZhenxieSentenceMemberEntity?> sentenceRealizationList = realizationSets[0]?.members?? [];
    int visibleCount = sentenceRealizationList.length > 3 ? 3 : sentenceRealizationList.length;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 16.wMin),
      padding: EdgeInsets.only(top: 16.wMin),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.cZhenxieBorderPrimary.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Column(
        spacing: 16.wMin,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(visibleCount, (index){
          return _buildItemWidget(sentenceRealizationList[index]);
        }),
      ),
    );

  }

  Widget _buildItemWidget(ZhenxieSentenceMemberEntity? sentence){
    if(sentence == null) return Container();
    bool isHighlighted = widget.highlightSentenceId == sentence.sentenceId;
    bool isNormal = sentence.sentence?.isNormal == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SentenceSlotExampleWidget(
          isManagement: widget.isManagement,
          content: sentence.sentence?.content,
          segmentList: sentence.sentence?.segmentList,
          lableFontSzie: 14.wMin,
          valueFontSize: 20.wMin,
          padding: EdgeInsets.symmetric(horizontal: 2.wMin),
        ),
        SizedBox(height: 6.wMin),

        Text.rich(TextSpan(
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontSecondary.color,
            fontFamily: AppFontValue.sourceHanSerifCN,
          ),
          children: [
            TextSpan(
              text: sentence.sentence?.definition ?? "",
              style: !isHighlighted ? null : TextStyle(
                decorationColor: AppTheme.cSurfaceWarning.color,
                decoration: TextDecoration.underline,
                decorationThickness: 2.wMin,
                color: AppTheme.cZhenxieFontTertiary.color,
              )
            ),
            if(widget.isManagement) ...[
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  margin: EdgeInsets.only(left: 4.wMin),
                  child: CopyTagWidget(
                    name: "句子",
                    value: sentence.sentenceId?.toString()??'',
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
                    bgColor: isNormal ? AppTheme.cSurfaceSuccess.withValues(alpha: 0.12) : AppTheme.cSurfaceWarning.withValues(alpha: 0.12),
                    borderColor: isNormal ? AppTheme.cSurfaceSuccess.withValues(alpha: 0.2) : AppTheme.cSurfaceWarning.withValues(alpha: 0.2),
                  ),
                ),
              ),


            ],
          ],
        )),
      ],
    );
  }





  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cZhenxieFontTertiary,
    Color bgColor = AppTheme.cZhenxieBackgroundPrimary,
    Color borderColor = AppTheme.cZhenxieBorderPrimary,
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
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
        ],
      ),
    );
  }
}
