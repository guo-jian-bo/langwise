
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../app/modules/management/common/commons.dart';
import '../../../app/modules/management/enums/enums.dart';
import '../../../theme/theme.dart';
import '../../entities/entities.dart';
import '../widgets.dart';

class SentencePairingLinkTableWidget extends StatelessWidget {
  final SentencePairEntity data;
  /// 配对链路
  const SentencePairingLinkTableWidget({super.key, required this.data});

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
          IntrinsicHeight(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppTheme.cBorderSubtle.color,
                    width: 1.wMin,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildContentWidget()),
                  Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
                  SizedBox(
                    width: 100.wMin,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          data.orderConstraintEnum == PairOrderConstraintEnum.to_before_from ? "assets/svg/public/icon_arrow_back.svg" : "assets/svg/public/icon_arrow_right.svg",
                          width: 24.wMin,
                        ),
                        Text(
                          data.orderConstraintEnum?.label??'',
                          style: TextStyle(
                            fontSize: 14.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextTertiary.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
                  Expanded(child: _buildContentWidget()),
                ],
              ),
            ),
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
            "配对链路",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          Text(
            " · ${data.orderConstraintEnum?.label??''}",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          const Spacer(),
          // Text(
          //   "库内句对",
          //   style: TextStyle(
          //     fontSize: 16.wMin,
          //     fontWeight: FontWeight.w400,
          //     color: AppTheme.cTextTertiary.color,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildContentWidget(){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "FROM",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          SizedBox(height: 10.wMin),

          SelectableText.rich(TextSpan(
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
            ],
          )),

          SizedBox(height: 10.wMin),

          SelectableText.rich(TextSpan(
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
            children: [
              TextSpan(text: "Is he your brother?"),
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

          SizedBox(height: 10.wMin),

          SelectableText(
            "他是你哥哥吗？",
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

}

class SentencePairingLinkDetailTableWidget extends StatelessWidget {
  /// 配对链路-详细表
  const SentencePairingLinkDetailTableWidget({super.key});

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
          _buildBluePrintHeaderWidget(),
          _buildSentenceWidget(),
          
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
            "配对链路",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          Text(
            " · 先左后右",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          const Spacer(),
          Text(
            "库内句对",
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

  /// 蓝图表头
  Widget _buildBluePrintHeaderWidget(){
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceLayerBase.color,
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
            Expanded(child: _buildBluePrintHeaderContentWidget()),
            Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
            SizedBox(
              width: 100.wMin,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/svg/public/icon_arrow_right.svg",
                    width: 24.wMin,
                  ),
                  Text(
                    "先左后右",
                    style: TextStyle(
                      fontSize: 14.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextTertiary.color,
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
            Expanded(child: _buildBluePrintHeaderContentWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildBluePrintHeaderContentWidget(){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "FROM · 蓝图表头",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          SizedBox(height: 8.wMin),

          SelectableText.rich(TextSpan(
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
                  child: ButtonWidget(
                    text: "打开蓝图",
                    height: 34.wMin,
                    width: 120.wMin,
                    padding: EdgeInsets.only(left: 10.wMin),
                    color: AppTheme.cSurfaceLayerElevated.color,
                    fontSize: 18.wMin,
                    fontColor: AppTheme.cTextSecondary.color,
                    fontWeight: FontWeight.w500,
                    sclae: 1.03,
                    rightIcon: SvgPicture.asset(
                      "assets/svg/public/icon_w_arrow_right.svg",
                      width: 20.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
                    ),
                    onTap: OptimizeUtils.noneThrottle(() {
                      
                    }, 1000),
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildSentenceWidget(){
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
            Expanded(child: _buildSentenceContentWidget()),
            Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
            SizedBox(
              width: 100.wMin,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/svg/public/icon_arrow_right.svg",
                    width: 24.wMin,
                  ),
                  Text(
                    "#1",
                    style: TextStyle(
                      fontSize: 14.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextTertiary.color,
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
            Expanded(child: _buildSentenceContentWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildSentenceContentWidget(){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText.rich(TextSpan(
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
            children: [
              TextSpan(text: "Is he your brother?"),
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

          SizedBox(height: 8.wMin),

          SelectableText(
            "他是你哥哥吗？",
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

}











class SentencePairingLinkForkTableWidget extends StatelessWidget {
  /// 配对链路-分叉
  const SentencePairingLinkForkTableWidget({super.key});

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
      child: Container(
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
              Expanded(
                flex: 4,
                child: _buildContentFromWidget(),
              ),
              Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
              Expanded(
                flex: 6,
                child: _buildContentToWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentFromWidget(){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "FROM",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          SizedBox(height: 6.wMin),
          SelectableText(
            "说明是什么状态",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SelectableText(
            "Is he your brother?",
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentToWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(3, (index){
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.wMin),
          decoration: index == 0 ? null : BoxDecoration(
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
              SelectableText(
                "YES./NO.",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
              SelectableText(
                "Is he your brother?",
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }



}


class SentencePairingLinkForkDetailsTableWidget extends StatelessWidget {
  final void Function()? onTap;
  /// 配对链路-分叉详细
  const SentencePairingLinkForkDetailsTableWidget({super.key, this.onTap});

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
      child: Container(
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
              Expanded(
                flex: 4,
                child: _buildContentFromWidget(),
              ),
              Container(width: 1.wMin, color: AppTheme.cBorderSubtle.color),
              Expanded(
                flex: 6,
                child: _buildContentToWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentFromWidget(){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            spacing: 4.wMin,
            children: [
              Text(
                "FROM",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
              CopyTagWidget(
                name: "句型",
                value: "ask_be_yes_no",
              ),
            ],
          ),
          SizedBox(height: 6.wMin),
          SelectableText(
            "说明是什么状态",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SelectableText(
            "Is he your brother?",
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          SizedBox(height: 6.wMin),
          _buildTagWidget(
            tagText: "affirmative",
            textColor: AppTheme.cSurfaceWarning.color,
            bgColor: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
            borderColor: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
          ),
          SizedBox(height: 6.wMin),
          Row(
            children: [
              ButtonWidget(
                text: "打开蓝图",
                height: 34.wMin,
                padding: EdgeInsets.only(left: 12.wMin, right: 4.wMin),
                color: AppTheme.cSurfaceLayerElevated.color,
                fontSize: 18.wMin,
                fontColor: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w500,
                sclae: 1.03,
                rightIcon: SvgPicture.asset(
                  "assets/svg/public/icon_w_arrow_right.svg",
                  width: 20.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
                ),
                onTap: OptimizeUtils.noneThrottle(() {
                  
                }, 1000),
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildContentToWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(3, (index){
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.wMin),
          decoration: index == 0 ? null : BoxDecoration(
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
              Row(
                spacing: 4.wMin,
                children: [
                  SelectableText(
                    "YES./NO.",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextTertiary.color,
                    ),
                  ),
                  CopyTagWidget(
                    name: "配对",
                    value: "ask_be_yes_no_to_affirmative_word",
                  ),
                  const Spacer(),
                  ButtonWidget(
                    text: "打开这条配对",
                    height: 34.wMin,
                    padding: EdgeInsets.only(left: 12.wMin, right: 4.wMin),
                    color: AppTheme.cSurfaceLayerElevated.color,
                    fontSize: 18.wMin,
                    fontColor: AppTheme.cTextSecondary.color,
                    fontWeight: FontWeight.w500,
                    sclae: 1.03,
                    rightIcon: SvgPicture.asset(
                      "assets/svg/public/icon_w_arrow_right.svg",
                      width: 20.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
                    ),
                    onTap: OptimizeUtils.noneThrottle(() {
                      onTap?.call();
                    }, 1000),
                  ),
                ],
              ),
              SelectableText(
                "用 so that 从句说明目的",
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              SelectableText(
                "He called Harry so that he could say sorry.",
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
            ],
          ),
        );
      }),
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