
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../entities/entities.dart';
import '../../values/values.dart';
import '../widgets.dart';
import '../../../theme/theme.dart';
import '../../../utils/utils.dart';
import '../../../app/modules/management/common/commons.dart';

class ZhenxieSentencePatternCompareCardWidget extends StatefulWidget {
  final SentencePatternCompareEntity data;
  final bool isManagement;
  final void Function(SentencePatternCompareEntity data)? onTap;
  /// 是否 为选择模式
  final bool isSelectMode;
  /// 是否 选中
  final bool isSelected;

  /// 句型对照卡片
  const ZhenxieSentencePatternCompareCardWidget({
    super.key, 
    required this.data, 
    this.isManagement = false, 
    this.onTap,
    this.isSelectMode = false,
    this.isSelected = false,
  });

  @override
  State<ZhenxieSentencePatternCompareCardWidget> createState() => _ZhenxieSentencePatternCompareCardWidgetState();
}

class _ZhenxieSentencePatternCompareCardWidgetState extends State<ZhenxieSentencePatternCompareCardWidget> {
  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: (){
        widget.onTap?.call(widget.data);
      },
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
            _buildItemContentWidget(widget.data),
            Container(
              height: 1.wMin,
              color: AppTheme.cZhenxieBorderPrimary.color,
              margin: EdgeInsets.symmetric(vertical: 16.wMin),
            ),
            SameGroupCompareTableWidget(
              isManagement: widget.isManagement,
              memberList: widget.data.memberList,
              realizationSets: widget.data.realizationSets,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemContentWidget(SentencePatternCompareEntity data){
    LanguageText? dimensionName = LearningLangUtils.getLocalLang(data.dimension?.name);
    LanguageText? name = LearningLangUtils.getLocalLang(data.name);
    LanguageText? description = LearningLangUtils.getLocalLang(data.description);

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
            Text(
              dimensionName?.text??'',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cZhenxieFontTertiary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
            SizedBox(width: 16.wMin),
            CopyTagWidget(
              name: "维度",
              value: data.dimensionNid??'',
              isShow: widget.isManagement,
            ),
            Spacer(),
            // Text(
            //   "${widget.data.realizationSetList?.length??0}组对照",
            //   style: TextStyle(
            //     fontSize: 18.wMin,
            //     fontWeight: FontWeight.w500,
            //     color: AppTheme.cZhenxieFontSecondary.color,
            //     fontFamily: AppFontValue.sourceHanSerifCN,
            //   ),
            // ),

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
              name?.text??'',
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cZhenxieFontPrimary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
            CopyTagWidget(
              name: "对照", 
              value: data.nid??'',
              isShow: widget.isManagement,
            ),
          ],
        ),
        SizedBox(height: 4.wMin),
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

  
}
