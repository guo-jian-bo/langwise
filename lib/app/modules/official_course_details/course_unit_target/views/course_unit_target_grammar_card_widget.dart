
import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/values/values.dart';

class CourseUnitTargetGrammarCardWidget extends StatelessWidget {
  final CourseUnitTargetSentenceGrammarPointEntity data;
  final void Function(CourseUnitTargetSentenceGrammarTargetEntity? target)? onTap;
  const CourseUnitTargetGrammarCardWidget({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 50.wMin,
              height: 50.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                  width: 1.wMin,
                ),
              ),
              child: Text(
                data.pointOrder?.toString()??'',
                style: TextStyle(
                  color: AppTheme.cZhenxieFontPrimary.color,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                ),
              ),
            ),
            SizedBox(width: 16.wMin),
            Expanded(
              child: Text(
                data.title??"",
                style: TextStyle(
                  color: AppTheme.cZhenxieFontPrimary.color,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                ),
              ),
            ),

          ],
        ),
        Container(
          margin: EdgeInsets.only(left: 66.wMin),
          child: Text(
            data.description??"",
            style: TextStyle(
              color: AppTheme.cZhenxieFontSecondary.color,
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
        ),
        SizedBox(height: 10.wMin),
        _buildListWidget(),
      ],
    );
  }

  Widget _buildListWidget(){
    final list = data.targets??[];
    if(list.isEmpty) return Container();
    final int rowCount = (list.length / 2).ceil();

    return Column(
      spacing: 16.wMin,
      children: List.generate(rowCount, (rowIndex){
        final int leftIndex = rowIndex * 2;
        final int rightIndex = leftIndex + 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16.wMin,
            children: [
              Expanded(child: _buildTargetItemWidget(list[leftIndex])),
              Expanded(
                child: rightIndex < list.length ? _buildTargetItemWidget(list[rightIndex]) : SizedBox.shrink(),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTargetItemWidget(CourseUnitTargetSentenceGrammarTargetEntity? item){
    return TapScaleWidget(
      onTap: onTap == null ? null : () => onTap?.call(item),
      sclae: 1,
      borderRadius: 16.wMin,
      backColor: AppTheme.cZhenxieFontPrimary.color.withValues(alpha: 0.08),
      child: Container(
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cZhenxieBackgroundPrimary.color,
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(
            color: AppTheme.cZhenxieBorderPrimary.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTagWidget(tagText: item?.assetLabel??""),
                SizedBox(width: 8.wMin),
                Text(
                  "${item?.setCount??0} 组",
                  style: TextStyle(
                    color: AppTheme.cZhenxieFontTertiary.color,
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    fontFamily: AppFontValue.sourceHanSerifCN,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.wMin),
            Text(
              item?.title??"",
              style: TextStyle(
                color: AppTheme.cZhenxieFontPrimary.color,
                fontSize: 20.wMin,
                fontWeight: FontWeight.w500,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
            Visibility(
              visible: item?.assetLabel != null,
              child: Container(
                margin: EdgeInsets.only(top: 8.wMin),
                child: Text(
                  "从句子追加 · ${item?.assetLabel??""}",
                  style: TextStyle(
                    color: AppTheme.cZhenxieFontSecondary.color,
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    fontFamily: AppFontValue.sourceHanSerifCN,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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