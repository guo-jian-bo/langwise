
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../values/values.dart';
import '../../../app/modules/management/common/commons.dart';

class ZhenxieSentencePairItemWidget extends StatelessWidget {
  final SentencePairEntity data;
  final void Function()? onTap;
  final bool isManagement;
  /// 是否 为选择模式
  final bool isSelectMode;
  /// 是否 选中
  final bool isSelected;

  /// 句型配对卡片
  const ZhenxieSentencePairItemWidget({
    super.key, 
    this.onTap, 
    required this.data,
    this.isManagement = false,
    this.isSelectMode = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {

    SentencePairSentenceBriefEntity? from;
    SentencePairSentenceBriefEntity? to;
    if (data.realizationSetList != null && data.realizationSetList?.isNotEmpty == true) {
      from = data.realizationSetList?.first?.fromSentenceStruct;
      to = data.realizationSetList?.first?.toSentenceStruct;
    }
  
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1,
      backColor: AppTheme.cZhenxieFontPrimary.color.withValues(alpha: 0.08),
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
            _buildTitltTagsWidget(),
            SizedBox(height: 10.wMin),
            _buildInfoWidget(),
            Container(
              height: 1.wMin, 
              color: AppTheme.cZhenxieBorderPrimary.color,
              margin: EdgeInsets.symmetric(vertical: 16.wMin),
            ),

            _buildItemWidget(
              realization: data.fromRealization,
              sentenceBrief: from,
              isFrom: true,
            ),
            SizedBox(height: 24.wMin),
            _buildItemWidget(
              realization: data.toRealization,
              sentenceBrief: to,
              isFrom: false,
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildTitltTagsWidget(){
    LanguageText? pairTypeName = LearningLangUtils.getLocalLang(data.pairType?.name);
    int count = data.realizationSetCount??0;
    return Row(
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
        SelectableText(
          pairTypeName?.text??'',
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cZhenxieFontTertiary.color,
            fontFamily: AppFontValue.sourceHanSerifCN,
          ),
        ),
        Spacer(),
        _buildTagWidget(tagText: data.practiceModeEnum?.description??''),
        Visibility(
          visible: data.pairRacticeKindEnum != null,
          child: Container(
            margin: EdgeInsets.only(left: 4.wMin),
            child: _buildTagWidget(tagText: data.pairRacticeKindEnum?.description??''),
          ),
        ),
        Visibility(
          visible: count > 0,
          child: Container(
            margin: EdgeInsets.only(left: 4.wMin),
            child: _buildTagWidget(tagText: "$count组句对"),
          ),
        ),
        Visibility(
          visible: count <= 0,
          child: Container(
            margin: EdgeInsets.only(left: 4.wMin),
            child: _buildTagWidget(
              tagText: "待挑句",
            ),
          ),
        ),

        Visibility(
          visible: isSelectMode,
          child: Container(
            margin: EdgeInsets.only(left: 12.wMin),
            child: SvgPicture.asset(
              isSelected? "assets/svg/manage/icon_check_box.svg" : "assets/svg/manage/icon_uncheck_box.svg",
              width: 24.wMin,
              height: 24.wMin,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoWidget(){
    LanguageText? name = LearningLangUtils.getLocalLang(data.name);
    LanguageText? description = LearningLangUtils.getLocalLang(data.description);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 4.wMin,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SelectableText(
              name?.text??'',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cZhenxieFontPrimary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
            CopyTagWidget(
              name: "配对",
              value: data.nid??'',
              isShow: isManagement,
            ),
          ],
        ),
        SizedBox(height: 10.wMin),
        SelectableText(
          description?.text??'',
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cZhenxieFontSecondary.color,
            fontFamily: AppFontValue.sourceHanSerifCN,
          ),
        ),

      ],
    );
  }

  Widget _buildItemWidget({
    SentencePairRealizationInfoEntity? realization,
    SentencePairSentenceBriefEntity? sentenceBrief,
    bool isFrom = true,
  }){
    final patternName = LearningLangUtils.getLocalLang(realization?.pattern?.name);
    bool isNormal = sentenceBrief?.isNormal == true;

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
                    patternName?.text??'',
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
                      value: realization?.patternNid??'',
                      isShow: isManagement,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Visibility(
          visible: sentenceBrief != null,
          child: Container(
            margin: EdgeInsets.only(left: 20.wMin, top: 6.wMin),
            child: Text.rich(TextSpan(
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cZhenxieFontPrimary.color,
                fontFamily: AppFontValue.robotoMono,
              ),
              children: [
                TextSpan(text: sentenceBrief?.content??''),
                if(isManagement) ...[
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      margin: EdgeInsets.only(left: 4.wMin),
                      child: CopyTagWidget(
                        name: "句子",
                        value: sentenceBrief?.sentenceId?.toString()??'',
                        isShow: isManagement,
                      ),
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      margin: EdgeInsets.only(left: 4.wMin),
                      child: _buildTagWidget(
                        tagText: isNormal ? "已上架": "未上架",
                        textColor: isNormal ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceWarning.color,
                        bgColor: isNormal ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12) : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                        borderColor: isNormal ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2) : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ],
              ],
            )),
          ),
        ),
        Visibility(
          visible: sentenceBrief != null,
          child: Container(
            margin: EdgeInsets.only(left: 20.wMin, top: 6.wMin),
            child: Text(
              sentenceBrief?.definition??'',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontTertiary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
          ),
        ),
        Visibility(
          visible: sentenceBrief == null,
          child: Container(
            margin: EdgeInsets.only(left: 20.wMin, top: 6.wMin),
            child: Text(
              "暂无例句",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagWidget({
    required String tagText,
    Color? textColor = AppTheme.cZhenxieFontTertiary,
    Color? bgColor = AppTheme.cZhenxieBackgroundPrimary,
    Color? borderColor = AppTheme.cZhenxieBorderPrimary,
  }){
    return Container(
      height: 28.wMin,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: bgColor,
        border: Border.all(
          color: (borderColor??AppTheme.cSurfaceLayerBase.color).withValues(alpha: 0.2),
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
