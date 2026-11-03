
import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../theme/theme.dart';

class GrammarPanoramaMinTableWidget extends StatelessWidget {
  /// 语法全景表 - 小
  const GrammarPanoramaMinTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget(),
          _buildTableWidget(),
        ],
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Text(
        "过去/现在/将来视角×同一件事的体貌怎么看",
        style: TextStyle(
          fontSize: 20.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cTextSecondary.color,
        ),
      ),
    );
  }

  Widget _buildTableWidget(){
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                _buildTableLeftUnitWidget(""),
                _buildTableTitleUnitWidget("一般"),
                _buildTableTitleUnitWidget("进行"),
                _buildTableTitleUnitWidget("完成"),
                _buildTableTitleUnitWidget("完成进行", isLast: true),
              ],
            ),
          ),

          Column(
            children: List.generate(3, (index){
              return _buildTableRowItemWidget();
            }),
          ),

        ],
      ),
    );
  }


  Widget _buildTableRowItemWidget(){
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
            _buildTableLeftUnitWidget("过去"),
            _buildTableItemUnitWidget("一般过去时"),
            _buildTableItemUnitWidget("过去进行时"),
            _buildTableItemUnitWidget("过去完成时"),
            _buildTableItemUnitWidget("过去完成进行时", isLast: true),
          ],
        ),
      ),
    );
  }


  Widget _buildTableLeftUnitWidget(String text){
    return Container(
      width: 120.wMin,
      padding: EdgeInsets.all(16.wMin),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border(
          right: BorderSide(
            color: AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cTextPrimary.color,
        ),
      ),
    );
  }

  Widget _buildTableTitleUnitWidget(String text, {bool isLast = false}){
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.wMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceLayerBase.color,
          border: isLast ? null : Border(
            right: BorderSide(
              color: AppTheme.cBorderSubtle.color,
              width: 1.wMin,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
      ),
    );
  }

  Widget _buildTableItemUnitWidget(String text, {bool isLast = false}){
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.wMin),
        alignment: Alignment.center,
        decoration: isLast ? null : BoxDecoration(
          border: Border(
            right: BorderSide(
              color: AppTheme.cBorderSubtle.color,
              width: 1.wMin,
            ),
          ),
        ),
        child: SelectableText(
          text,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
      ),
    );
  }

}



class GrammarPanoramaTableWidget extends StatefulWidget {
  /// 语法全景表格
  const GrammarPanoramaTableWidget({super.key});

  @override
  State<GrammarPanoramaTableWidget> createState() => _GrammarPanoramaTableWidgetState();
}

class _GrammarPanoramaTableWidgetState extends State<GrammarPanoramaTableWidget> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHighlightFocusWidget(),
        _buildClipGridWidget(),
        _buildTableWidget(),
      ],
    );
  }

  /// 高亮焦点
  Widget _buildHighlightFocusWidget(){
    return Container(
      margin: EdgeInsets.only(bottom: 12.wMin),
      child: Row(
        spacing: 10.wMin,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(
            "高亮焦点",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextTertiary.color,
            ),
          ),

          _buildHighlightFocusItemWidget("默认"),
          _buildHighlightFocusItemWidget("时体标记"),
          _buildHighlightFocusItemWidget("时间状语"),

        ],
      ),
    );
  }

  Widget _buildHighlightFocusItemWidget(String text){
    return ButtonWidget(
      text: text,
      width: 130.wMin,
      height: 56.wMin,
      color: AppTheme.cSurfaceLayerBase.color,
      border: Border.all(
        color: AppTheme.cBorderSubtle.color,
        width: 0.8.wMin,
      ),
      fontColor: AppTheme.cTextSecondary.color,
      fontSize: 24.wMin,
      fontWeight: FontWeight.w500,
      sclae: 1.03,
      onTap: () {
        
      },
    );
  }

  /// 点击亮灭以裁剪宫格
  Widget _buildClipGridWidget(){
    return Container(
      margin: EdgeInsets.only(bottom: 12.wMin),
      child: Row(
        spacing: 10.wMin,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "点击亮灭以裁剪宫格",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: AppTheme.cSurfaceLayerBase2.color,
            ),
            child: Row(
              spacing: 8.wMin,
              children: [
                Text(
                  "过去 / 现在 / 将来视角",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary.color,
                  ),
                ),
                _buildClipGridItemWidget("过去"),
                _buildClipGridItemWidget("现在"),
                _buildClipGridItemWidget("将来"),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: AppTheme.cSurfaceLayerBase2.color,
            ),
            child: Row(
              spacing: 8.wMin,
              children: [
                Text(
                  "同一件事的体貌怎么看",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary.color,
                  ),
                ),
                _buildClipGridItemWidget("一般"),
                _buildClipGridItemWidget("进行"),
                _buildClipGridItemWidget("完成"),
                _buildClipGridItemWidget("完成进行"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClipGridItemWidget(String text){
    return ButtonWidget(
      text: text,
      width: 130.wMin,
      height: 56.wMin,
      color: AppTheme.cSurfaceLayerBase.color,
      borderRadius: 8.wMin,
      border: Border.all(
        color: AppTheme.cBorderSubtle.color,
        width: 0.8.wMin,
      ),
      fontColor: AppTheme.cTextSecondary.color,
      fontSize: 24.wMin,
      fontWeight: FontWeight.w500,
      sclae: 1.03,
      onTap: () {
        
      },
    );
  }


  Widget _buildTableWidget(){
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
          IntrinsicHeight(
            child: Row(
              children: [
                _buildTableLeftUnitWidget("", ""),
                _buildTableTitleUnitWidget("一般", "simple"),
                _buildTableTitleUnitWidget("进行", "continuous"),
                _buildTableTitleUnitWidget("完成", "perfect"),
                _buildTableTitleUnitWidget("完成进行", "perfect_continuous", isLast: true),
              ],
            ),
          ),

          Column(
            children: List.generate(3, (index){
              return _buildTableRowItemWidget();
            }),
          ),

        ],
      ),
    );
  }


  Widget _buildTableLeftUnitWidget(String text, String sub){
    return Container(
      width: 120.wMin,
      padding: EdgeInsets.all(10.wMin),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border(
          right: BorderSide(
            color: AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableTitleUnitWidget(String text, String sub, {bool isLast = false}){
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10.wMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceLayerBase.color,
          border: isLast ? null : Border(
            right: BorderSide(
              color: AppTheme.cBorderSubtle.color,
              width: 1.wMin,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            Text(
              sub,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRowItemWidget(){
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
            _buildTableLeftUnitWidget("过去", "past"),
            _buildTableItemUnitWidget(),
            _buildTableItemUnitWidget(),
            _buildTableItemUnitWidget(),
            _buildTableItemUnitWidget(isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTableItemUnitWidget({bool isLast = false}){
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.wMin),
        alignment: Alignment.center,
        decoration: isLast ? null : BoxDecoration(
          border: Border(
            right: BorderSide(
              color: AppTheme.cBorderSubtle.color,
              width: 1.wMin,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SelectableText(
              "一般过去时",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
            SizedBox(height: 6.wMin),
            SelectableText.rich(TextSpan(
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
              children: [
                TextSpan(text: "She "),
                TextSpan(
                  text: " wrote ",
                  style: TextStyle(
                    color: AppTheme.cSurfaceWarning.color,
                    height: 1.4,
                    backgroundColor: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                  ),
                ),
                TextSpan(text: " a letter."),
              ],
            )),
            SizedBox(height: 6.wMin),
            SelectableText(
              "她写了一封信。",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ],
        ),
      ),
    );
  }





}
