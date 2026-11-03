import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_sentence_pair_details_binding.dart';
import '../controllers/manage_sentence_pair_details_controller.dart';

class ManageSentencePairDetailsView extends GetView<ManageSentencePairDetailsController> {
  final String tagText;
  const ManageSentencePairDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SENTENCE_PAIR_DETAILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageSentencePairDetailsView(tagText: tag),
      binding: ManageSentencePairDetailsBinding(tag: tag),
      routeName: Routes.MANAGE_SENTENCE_PAIR_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 90.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32.wMin),
            _buildInfoWidget(context),
            SizedBox(height: 32.wMin),
            _buildPairChainTableWidget(),
            _buildForkChainWidget(),
            _buildWhyMatchWidget(),
            SizedBox(height: 32.wMin),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoWidget(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "对照配对",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
            const Spacer(),
            ButtonWidget(
              text: "编辑名称说明",
              height: 34.wMin,
              padding: EdgeInsets.symmetric(horizontal: 10.wMin),
              color: AppTheme.cSurfaceLayerBase.color,
              border: Border.all(
                width: 0.8.wMin,
                color: AppTheme.cBorderSubtle.color,
              ),
              fontSize: 18.wMin,
              fontColor: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
              sclae: 1.03,
              leftIcon: Container(
                margin: EdgeInsets.only(right: 6.wMin),
                child: SvgPicture.asset(
                  "assets/svg/manage/icon_edit.svg",
                  width: 16.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                ),
              ),
              onTap: OptimizeUtils.noneThrottle(() {
                controller.editNameDesc(context);
              }, 1000),
            ),
            SizedBox(width: 6.wMin),
            ButtonWidget(
              text: "编辑句对",
              height: 34.wMin,
              padding: EdgeInsets.symmetric(horizontal: 10.wMin),
              color: AppTheme.cSurfaceLayerBase.color,
              border: Border.all(
                width: 0.8.wMin,
                color: AppTheme.cBorderSubtle.color,
              ),
              fontSize: 18.wMin,
              fontColor: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
              sclae: 1.03,
              leftIcon: Container(
                margin: EdgeInsets.only(right: 6.wMin),
                child: SvgPicture.asset(
                  "assets/svg/manage/icon_edit.svg",
                  width: 16.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                ),
              ),
              onTap: OptimizeUtils.noneThrottle(() {
                controller.editPairSentence(context);
              }, 1000),
            ),
          ],
        ),
        Row(
          spacing: 4.wMin,
          children: [
            Text(
              "一般疑问与完整肯定答句",
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            CopyTagWidget(
              name: "配对",
              value: "ask_be_yes_no_to_affirmative_Clause",
            ),
          ],
        ),
        SizedBox(height: 10.wMin),
        Text(
          "先回答”是”，再把完整肯定句补出来，让回应更自然、更完整。",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
        SizedBox(height: 10.wMin),
        Row(
          children: [
            _buildTagWidget(
              tagText: "对称",
            ),
            SizedBox(width: 6.wMin),
            _buildTagWidget(
              tagText: "可配对也可分叉",
            ),
            SizedBox(width: 6.wMin),
            _buildTagWidget(
              tagText: "默认配对",
            ),
            SizedBox(width: 6.wMin),
            _buildTagWidget(
              tagText: "待挑句",
            ),
          ],
        ),

      ],
    );
  }

  /// 配对链路表
  Widget _buildPairChainTableWidget(){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 0.8.wMin,
        ),
      ),
      child: SentencePairingLinkDetailTableWidget(),
    );
  }

  /// 出现在那些分叉链路
  Widget _buildForkChainWidget(){
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 32.wMin),
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 0.8.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            "出现在那些分叉链路",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 10.wMin),
          SelectableText(
            "同一条配对可以同时出现在肯否对照和换种答法里。点进去看怎么分叉。",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          SizedBox(height: 10.wMin),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10.wMin,
            children: List.generate(2, (index){
              return _buildForkChainItemWidget();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildForkChainItemWidget(){
    return Container(
      padding: EdgeInsets.all(8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 0.8.wMin,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText.rich(TextSpan(
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        margin: EdgeInsets.only(right: 4.wMin),
                        child: _buildTagWidget(
                          tagText: "肯否对照",
                          textColor: Color(0xffEAB308),
                          bgColor: Color(0xffEAB308).withValues(alpha: 0.12),
                          borderColor: Color(0xffEAB308).withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    TextSpan(text: "Is...？：用 Yes,.../No,...对照肯否"),
                  ],
                )),
                SelectableText(
                  "必须整组分叉出题",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
                  ),
                ),
              ],
            ),
          ),
          ButtonWidget(
            text: "打开棋盘",
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
              controller.toForkDetails();
            }, 1000),
          ),
        ],
      ),
    );
  }

  /// 为何能配
  Widget _buildWhyMatchWidget(){
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 32.wMin),
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 0.8.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            "为何能配",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 10.wMin),
          Wrap(
            spacing: 10.wMin,
            runSpacing: 6.wMin,
            children: List.generate(4, (index){
              return _buildTagWidget(
                tagText: "问句里的补充内容 → 回应内容",
                bgColor: AppTheme.cSurfaceLayerBase2.color,
                borderColor: AppTheme.cBorderThin.color,
              );
            }),
          ),
        ],
      ),
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
