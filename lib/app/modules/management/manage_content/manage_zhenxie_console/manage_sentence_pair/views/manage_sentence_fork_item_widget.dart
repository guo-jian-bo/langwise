

import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../common/commons.dart';

class ManageSentenceForkItemWidget extends StatelessWidget {
  final void Function()? onTap;
  const ManageSentenceForkItemWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
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
              "先回答“是”，再把完整肯定句补出来，让回应更自然、更完整。",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
            SizedBox(height: 10.wMin),
            SentencePairingLinkForkTableWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoLeftWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          "对照配对 · 同一问句，答法怎么包装",
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
              "一般疑问与完整肯定答句",
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            CopyTagWidget(
              name: "配对",
              value: "ask_be_yes_no_to_affirmative_CLause",
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
        _buildTagWidget(tagText: "换种答法"),
        SizedBox(height: 6.wMin),
        Row(
          spacing: 4.wMin,
          children: [
            _buildTagWidget(
              tagText: "3种接法",
            ),
            _buildTagWidget(
              tagText: "可分叉也可抽一条",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cTextSecondary,
    Color bgColor = AppTheme.cSurfaceLayerBase,
    Color borderColor = AppTheme.cBorderThin,
  }){
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