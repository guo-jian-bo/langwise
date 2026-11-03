import 'package:flutter/material.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../app/modules/management/common/commons.dart';
import '../../entities/entities.dart';
import '../widgets.dart';
import '../../../theme/theme.dart';

class PatternBlueprintItemWidget extends StatelessWidget {
  final PatternBlueprintEntity data;
  final void Function()? onTap;
  const PatternBlueprintItemWidget({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    LanguageText? description = LearningLangUtils.getLocalLang(data.description);

    return TapScaleWidget(
      onTap: onTap,
      sclae: 1,
      child: Container(
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: AppTheme.cBorderThin.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildContentLeftWidget(),
                ),
                _buildContentRightWidget(),
              ],
            ),
            SizedBox(height: 4.wMin),
            Text(
              description?.text ?? "",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
            SizedBox(height: 10.wMin),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: AppTheme.cSurfaceLayerBase.color,
                border: Border.all(
                  color: AppTheme.cBorderThin.color,
                  width: 0.8.wMin,
                ),
              ),
              child: SentenceSlotMapWidget(
                data: SentenceSlotMapUtils.buildFromPatternBlueprint(data),
              ),
            ),
            SizedBox(height: 10.wMin),
            Container(
              height: 1.wMin,
              width: double.infinity,
              color: AppTheme.cBorderSubtle.color,
            ),
            SizedBox(height: 10.wMin),
            _buildSentenceWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildContentLeftWidget() {
    LanguageText? familyName = LearningLangUtils.getLocalLang(data.family?.name);
    LanguageText? name = LearningLangUtils.getLocalLang(data.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          familyName?.text ?? "",
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
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
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            CopyTagWidget(
              name: "句型",
              value: data.nid ?? "",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentRightWidget() {
    LanguageText? functionalTypeName = LearningLangUtils.getLocalLang(data.functionalType?.name);
    LanguageText? basicTypeName = LearningLangUtils.getLocalLang(data.basicType?.name);
    LanguageText? svocaTypeName = LearningLangUtils.getLocalLang(data.primarySvoca?.name);

    List<Widget> tags = [];
    if (data.supportsPyramid = true) {
      tags.add(_buildTagWidget(
        tagText: "可生长",
        textColor: Color(0xff22C55E),
        bgColor: Color(0xff22C55E).withValues(alpha: 0.12),
        borderColor: Color(0xff22C55E).withValues(alpha: 0.2),
      ));
    }
    if (data.patternTier != null) {
      tags.add(_buildTagWidget(tagText: data.patternTier ?? ""));
    }
    if (data.difficulty?.min != null && data.difficulty?.max != null) {
      tags.add(_buildTagWidget(tagText: "L${data.difficulty?.min}-L${data.difficulty?.max}"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildTagWidget(
          tagText: "${functionalTypeName?.text ?? ''} > ${basicTypeName?.text ?? ''} > ${svocaTypeName?.text ?? ''}",
        ),
        SizedBox(height: 4.wMin),
        Row(
          spacing: 4.wMin,
          children: tags,
        ),
      ],
    );
  }

  Widget _buildSentenceWidget() {
    List<PatternBlueprintSentenceBriefEntity?> sentenceRealizationList = data.sentenceRealizationList?? [];
    if(sentenceRealizationList.isEmpty){
      return Text(
        "待教研挑选代表句",
        style: TextStyle(
          fontSize: 18.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cTextTertiary.color,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6.wMin,
      children: List.generate(sentenceRealizationList.length, (index) {
        return Row(
          children: [
            CopyTagWidget(
              name: "句子",
              value: sentenceRealizationList[index]?.order?.toString() ?? "",
            ),
            SizedBox(width: 4.wMin),
            Text(
              sentenceRealizationList[index]?.content ?? "",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
          ],
        );
      }),
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
