
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../app/modules/management/common/commons.dart';
import '../../../theme/theme.dart';

class SameGroupCompareTableWidget extends StatelessWidget {

  /// 同组对照表
  const SameGroupCompareTableWidget({super.key});

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
        children: [
          _buildTitleWidget(),
          _buildItemRowWidget(),
          _buildItemRowWidget(),
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

  Widget _buildItemRowWidget(){
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
            Expanded(child: _buildItemRowLeftWidget()),
            Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
            Expanded(child: _buildItemRowRightWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRowLeftWidget(){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "陈述句",
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
              SizedBox(width: 16.wMin),
              CopyTagWidget(
                name: "轨值",
                value: "declarative",
              ),
            ],
          ),
          SizedBox(height: 8.wMin),
          Wrap(
            spacing: 4.wMin,
            runSpacing: 4.wMin,
            children: [
              Text(
                "be 句怎样陈述、确认和追问",
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              CopyTagWidget(
                name: "对照",
                value: "state_sentence_type_contrast",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemRowRightWidget(){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Wrap(
        spacing: 4.wMin,
        children: [
          Text.rich(TextSpan(
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
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
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cSurfaceWarning.color,
                    ),
                  ),
                ),
              ),
              TextSpan(text: " green."),
            ]
          )),
          CopyTagWidget(
            name: "句子",
            value: "13241245",
          ),
        ],
      ),
    );
  }


}