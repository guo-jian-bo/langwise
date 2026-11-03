
import 'package:flutter/cupertino.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../app/modules/management/common/commons.dart';
import '../../../theme/theme.dart';
import '../widgets.dart';

class SameGroupCompareSentenceTableWidget extends StatelessWidget {
  /// 同组对照 句子列表
  const SameGroupCompareSentenceTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(2, (index){
              return _buildItemWidget();
            }),
          ),

        ],
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Row(
        children: [
          Text(
            "同组对照",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          Text(
            " · 焦点着色=本壳要搓的槽",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          const Spacer(),
          Text(
            "库内句 · 结构槽",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemWidget(){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemTitleWidget(),
          SizedBox(height: 12.wMin),
          _buildItemContentWidget(),
          SizedBox(height: 12.wMin),
          SentenceSlotExampleWidget(),
        ],
      ),
    );
  }

  Widget _buildItemTitleWidget(){
    return Text.rich(TextSpan(
      style: TextStyle(
        fontSize: 24.wMin,
        fontWeight: FontWeight.w500,
        color: AppTheme.cTextPrimary.color,
      ),
      children: [
        TextSpan(text: "说明是什么状态"),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: EdgeInsets.only(left: 4.wMin),
            child: CopyTagWidget(
              name: "对照",
              value: "state_sentence_type_contrast",
            ),
          ),
        ),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: EdgeInsets.only(left: 4.wMin),
            child: CopyTagWidget(
              name: "轨值",
              value: "declarative",
            ),
          ),
        ),
      ],
    ));
  }

  Widget _buildItemContentWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextTertiary.color,
          ),
          children: [
            TextSpan(text: "The apple "),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.wMin),
                  color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.08),
                ),
                child: Text(
                  "is",
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cSurfaceWarning.color,
                  ),
                ),
              ),
            ),
            TextSpan(text: " green."),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                margin: EdgeInsets.only(left: 4.wMin),
                child: CopyTagWidget(
                  name: "句子",
                  value: "13241245",
                ),
              ),
            ),
          ],
        )),
        SizedBox(height: 12.wMin),
        Text(
          "这个苹果是绿色的。",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
      ],
    );
  }

}