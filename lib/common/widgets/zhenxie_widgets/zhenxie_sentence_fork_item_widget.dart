

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../values/values.dart';
import '../../../app/modules/management/common/commons.dart';

class ZhenxieSentenceForkItemWidget extends StatelessWidget {
  final SentenceForkEntity data;
  final void Function()? onTap;
  final bool isManagement;
  /// 是否 为选择模式
  final bool isSelectMode;
  /// 是否 选中
  final bool isSelected;

  /// 句型分叉卡片
  const ZhenxieSentenceForkItemWidget({
    super.key,
    required this.data,
    this.onTap,
    this.isManagement = false,
    this.isSelectMode = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleTagsWidget(),
                _buildInfoWidget(),
              ],
            ),
            Container(
              height: 1.wMin,
              color: AppTheme.cZhenxieBorderPrimary.color,
              margin: EdgeInsets.symmetric(vertical: 16.wMin),
            ),
            SentencePairingLinkForkTableWidget(
              realizationSetList: data.realizationSetList,
              isManagement: isManagement,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleTagsWidget(){
    LanguageText? pairTypeName = LearningLangUtils.getLocalLang(data.pairType?.name);
    LanguageText? contrastDimensionName = LearningLangUtils.getLocalLang(data.contrastDimension?.name);

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
        Text(
          "${pairTypeName?.text??''} · ${contrastDimensionName?.text??''}",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cZhenxieFontTertiary.color,
            fontFamily: AppFontValue.sourceHanSerifCN,
          ),
        ),
        Spacer(),
        Visibility(
          visible: data.kindEnum != null,
          child: _buildTagWidget(tagText: data.kindEnum?.description??''),
        ),
        // SizedBox(width: 4.wMin),
        // _buildTagWidget(tagText: "${data.members?.length??0} 种接法"),
        SizedBox(width: 4.wMin),
        _buildTagWidget(tagText: data.soloPairPracticeEnum?.description??''),
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
          runSpacing: 4.wMin,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              name?.text??'',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cZhenxieFontPrimary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
            CopyTagWidget(
              name: "分叉",
              value: data.nid??'',
              isShow: isManagement,
            ),
          ],
        ),
        SizedBox(height: 6.wMin),
        Text(
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
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
        ],
      ),
    );
  }
  
}
