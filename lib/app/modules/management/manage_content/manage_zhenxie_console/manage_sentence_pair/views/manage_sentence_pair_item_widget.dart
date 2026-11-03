
import 'package:flutter/material.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../common/commons.dart';

class ManageSentencePairItemWidget extends StatelessWidget {
  final SentencePairEntity data;
  final void Function()? onTap;
  const ManageSentencePairItemWidget({super.key, this.onTap, required this.data});

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
                Expanded(child: _buildInfoLeftWidget()),
                _buildInfoRightWidget(),
              ],
            ),
            SizedBox(height: 10.wMin),
            SelectableText(
              description?.text??'',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
            SizedBox(height: 10.wMin),
            SentencePairingLinkTableWidget(data: data),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoLeftWidget(){
    LanguageText? pairTypeName = LearningLangUtils.getLocalLang(data.pairType?.name);
    LanguageText? name = LearningLangUtils.getLocalLang(data.name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          pairTypeName?.text??'',
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        SizedBox(height: 10.wMin),
        Wrap(
          spacing: 4.wMin,
          children: [
            SelectableText(
              name?.text??'',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            CopyTagWidget(
              name: "配对",
              value: data.nid??'',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRightWidget(){
    int count = data.sentenceRealizations?.length??0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildTagWidget(
          tagText: data.relationDirectionText,
        ),
        SizedBox(height: 6.wMin),
        Row(
          spacing: 4.wMin,
          children: [
            _buildTagWidget(
              tagText: data.practiceModeEnum?.description??'',
              textColor: data.practiceModeEnum?.color,
              bgColor: data.practiceModeEnum?.color.withValues(alpha: 0.12),
              borderColor: data.practiceModeEnum?.color.withValues(alpha: 0.2),
            ),
            Visibility(
              visible: data.pairRacticeKindEnum != null,
              child: _buildTagWidget(
                tagText: data.pairRacticeKindEnum?.description??'',
                textColor: data.pairRacticeKindEnum?.color,
                bgColor: data.pairRacticeKindEnum?.color.withValues(alpha: 0.12),
                borderColor: data.pairRacticeKindEnum?.color.withValues(alpha: 0.2),
              ),
            ),
            Visibility(
              visible: count > 0,
              child: _buildTagWidget(
                tagText: "$count组句对",
                textColor: Color(0xff22C55E),
                bgColor: Color(0xff22C55E).withValues(alpha: 0.12),
                borderColor: Color(0xff22C55E).withValues(alpha: 0.2),
              ),
            ),
            Visibility(
              visible: count <= 0,
              child: _buildTagWidget(
                tagText: "待挑句",
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildTagWidget({
    required String tagText,
    Color? textColor = AppTheme.cTextSecondary,
    Color? bgColor = AppTheme.cSurfaceLayerBase,
    Color? borderColor = AppTheme.cBorderThin,
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
            ),
          ),
        ],
      ),
    );
  }

}