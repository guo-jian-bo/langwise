

import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../management/common/commons.dart';

class ZhenxieSentenceForkItemWidget extends StatelessWidget {
  final SentenceForkEntity data;
  final void Function()? onTap;
  final bool isManagement;
  const ZhenxieSentenceForkItemWidget({super.key, required this.data, this.onTap, this.isManagement = false});

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
            SentencePairingLinkForkTableWidget(
              realizationSetList: data.realizationSetList,
              isManagement: isManagement,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoLeftWidget(){
    LanguageText? pairTypeName = LearningLangUtils.getLocalLang(data.pairType?.name);
    LanguageText? contrastDimensionName = LearningLangUtils.getLocalLang(data.contrastDimension?.name);
    LanguageText? name = LearningLangUtils.getLocalLang(data.name);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          "${pairTypeName?.text??''} · ${contrastDimensionName?.text??''}",
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
              name: "分叉",
              value: data.nid??'',
              isShow: isManagement,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRightWidget(){

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Visibility(
          visible: data.kindEnum != null,
          child: _buildTagWidget(
            tagText: data.kindEnum?.description??'',
            textColor: data.kindEnum?.color,
            bgColor: data.kindEnum?.color.withValues(alpha: 0.12),
            borderColor: data.kindEnum?.color.withValues(alpha: 0.2),
          ),
        ),
        SizedBox(height: 6.wMin),
        Row(
          spacing: 4.wMin,
          children: [
            _buildTagWidget(
              tagText: "${data.members?.length??0} 种接法",
            ),
            _buildTagWidget(
              tagText: data.soloPairPracticeEnum?.description??'',
              textColor: data.soloPairPracticeEnum?.color,
              bgColor: data.soloPairPracticeEnum?.color.withValues(alpha: 0.12),
              borderColor: data.soloPairPracticeEnum?.color.withValues(alpha: 0.2),
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
          color: (borderColor??AppTheme.cBorderThin).withValues(alpha: 0.2),
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
