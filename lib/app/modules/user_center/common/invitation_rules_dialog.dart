
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:markdown_widget/config/all.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/utils.dart';

/// 邀请奖励规则
class InvitationRulesDialog{

  static Future<void> show({
    required BuildContext context,
  }) async{

    await showCupertinoDialog(
      context: context, 
      builder: (context) {
        return const InvitationRulesDialogWidget();
      },
    );

  }

}


class InvitationRulesDialogWidget extends StatefulWidget {
  const InvitationRulesDialogWidget({super.key});

  @override
  State<InvitationRulesDialogWidget> createState() => _InvitationRulesDialogWidgetState();
}

class _InvitationRulesDialogWidgetState extends State<InvitationRulesDialogWidget> {


  bool _isLoading = true;

  String referralRuleText = "";
  ReferralRulesEntity? referralRulesEntity;

  @override
  void initState() {
    super.initState();
    getInfoDatas();
  }

  Future<void> getInfoDatas() async{
    try {
      referralRulesEntity = await ActivitiesRequest.getReferralRules();
      if(referralRulesEntity == null) return;
      referralRuleText = referralRulesEntity?.content??"";  
    } finally{
      _isLoading = false;    
      if(mounted) setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Center(
        child: Container(
          width: 1000.wMin,
          decoration: BoxDecoration(
            color: AppTheme.cSurfacePrimary.color,
            borderRadius: BorderRadius.circular(24.wMin),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeaderWidget(),
              SizedBox(height: 16.wMin),

              Container(
                constraints: BoxConstraints(
                  maxHeight: 900.wMin,
                  minHeight: 810.wMin,
                ),
                child: _buildContentWidget(),
              ),

            ],
          ),
        ),
      ),
    );
  }
  


  Widget _buildHeaderWidget() {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 24.wMin),
          padding: EdgeInsets.only(left: 40.wMin, right: 16.wMin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "邀请奖励规则",
                style: TextStyle(
                  fontSize: 32.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 16.wMin,
          top: 16.wMin,
          child: TapScaleWidget(
            sclae: 1.05,
            onTap: () => Get.back(),
            child: Container(
              width: 42.wMin,
              height: 42.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cSurfaceTertiary.color,
              ),
              child: SvgPicture.asset(
                "assets/svg/public/x.svg",
                width: 24.wMin,
                height: 24.wMin,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentWidget(){
    if(_isLoading){
      return  Container(
        height: 810.wMin,
        alignment: Alignment.center,
        child: SpinKitFadingCircle(
          color: AppTheme.cBgBrand.color,
          size: 100.wMin,
        ),
      );
    }


    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 40.wMin),
      child: MarkdownWidget(
        data: referralRuleText,
        shrinkWrap: true, // 使 Widget 高度随内容自适应
        physics: const NeverScrollableScrollPhysics(), // 禁止内部滚动
        config: MarkdownConfig(
          configs: [
            // 段落样式
            PConfig(
              textStyle: StyleUtils.getMarkdownStyle(
                referralRulesEntity?.markdownStyle?.p,
                defaultSize: 24,
                defaultColor: AppTheme.cTextSecondary.color,
              ),
            ),
            // H1 标题
            H1Config(
              style: StyleUtils.getMarkdownStyle(
                referralRulesEntity?.markdownStyle?.h1,
                defaultSize: 36,
                defaultColor: AppTheme.cTextPrimary.color,
              ),
            ),
            // H2 标题
            H2Config(
              style: StyleUtils.getMarkdownStyle(
                referralRulesEntity?.markdownStyle?.h2,
                defaultSize: 32,
                defaultColor: AppTheme.cTextPrimary.color,
              ),
            ),
            // H3 标题
            H3Config(
              style: StyleUtils.getMarkdownStyle(
                referralRulesEntity?.markdownStyle?.h3,
                defaultSize: 28,
                defaultColor: AppTheme.cTextPrimary.color,
              ),
            ),
            // H4 标题
            H4Config(
              style: StyleUtils.getMarkdownStyle(
                referralRulesEntity?.markdownStyle?.h4,
                defaultSize: 26,
                defaultColor: AppTheme.cTextPrimary.color,
              ),
            ),
            // H5 标题
            H5Config(
              style: StyleUtils.getMarkdownStyle(
                referralRulesEntity?.markdownStyle?.h5,
                defaultSize: 24,
                defaultColor: AppTheme.cTextPrimary.color,
              ),
            ),
            // H6 标题
            H6Config(
              style: StyleUtils.getMarkdownStyle(
                referralRulesEntity?.markdownStyle?.h6,
                defaultSize: 22,
                defaultColor: AppTheme.cTextPrimary.color,
              ),
            ),
            // 链接样式
            LinkConfig(
              style: StyleUtils.getMarkdownStyle(
                referralRulesEntity?.markdownStyle?.link,
                defaultSize: 24,
                defaultColor: AppTheme.cTextBrand.color,
              ),
            ),
            // 代码块样式
            PreConfig(
              textStyle: StyleUtils.getMarkdownStyle(
                referralRulesEntity?.markdownStyle?.pre,
                defaultSize: 20,
                defaultColor: AppTheme.cTextSecondary.color,
                textBackgroundColor: false,
              ),
              decoration: BoxDecoration(
                color: ColorUtils.parseColor(StyleUtils.getCurrentThemeText(referralRulesEntity?.markdownStyle?.pre)?.backgroundColor),
                borderRadius: BorderRadius.circular((StyleUtils.getCurrentThemeText(referralRulesEntity?.markdownStyle?.pre)?.borderRadius??0).wMin),
                border: Border.all(
                  color: ColorUtils.parseColor(StyleUtils.getCurrentThemeText(referralRulesEntity?.markdownStyle?.pre)?.borderColor)??AppTheme.cBorderPrimary.color,
                  width: 1.wMin,
                ),
              ),
              padding: EdgeInsets.all((StyleUtils.getCurrentThemeText(referralRulesEntity?.markdownStyle?.pre)?.padding??0).wMin),
              margin: EdgeInsets.all((StyleUtils.getCurrentThemeText(referralRulesEntity?.markdownStyle?.pre)?.margin??0).wMin),
            ),
            // 行内代码样式
            CodeConfig(
              style: StyleUtils.getMarkdownStyle(
                referralRulesEntity?.markdownStyle?.code,
                defaultSize: 22,
                defaultColor: AppTheme.cTextSecondary.color,
              ),
            ),
            // 引用块样式
            BlockquoteConfig(
              sideColor: ColorUtils.parseColor(StyleUtils.getCurrentThemeText(referralRulesEntity?.markdownStyle?.blockquote)?.backgroundColor)??AppTheme.cBgBrand.color,
              textColor: ColorUtils.parseColor(StyleUtils.getCurrentThemeText(referralRulesEntity?.markdownStyle?.blockquote)?.color)??AppTheme.cTextSecondary.color,
            ),
            // 分割线样式
            HrConfig(
              color: ColorUtils.parseColor(StyleUtils.getCurrentThemeText(referralRulesEntity?.markdownStyle?.hr)?.borderColor)??AppTheme.cBorderPrimary.color,
              height: 1.wMin,
            ),
            // 列表样式
            ListConfig(
              marker: (isOrdered, depth, index) {
                return Container(
                  width: 4.wMin,
                  height: 4.wMin,
                  margin: EdgeInsets.only(top: ((StyleUtils.getCurrentThemeText(referralRulesEntity?.markdownStyle?.blockquote)?.fontsize?.toDouble()??24) / 1.5).wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cTextPrimary.color,
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


 


}