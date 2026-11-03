import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_grammar_panorama_details_binding.dart';
import '../controllers/manage_grammar_panorama_details_controller.dart';

class ManageGrammarPanoramaDetailsView extends GetView<ManageGrammarPanoramaDetailsController> {
  final String tagText;
  const ManageGrammarPanoramaDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_GRAMMAR_PANORAMA_DETAILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageGrammarPanoramaDetailsView(tagText: tag),
      binding: ManageGrammarPanoramaDetailsBinding(tag: tag),
      routeName: Routes.MANAGE_GRAMMAR_PANORAMA_DETAILS,
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
            SizedBox(height: 16.wMin),
            _buildInfoWidget(context),
            _buildContentTableWidget(),
            _buildSuitableGridSentenceWidget(),
            SizedBox(height: 24.wMin),
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
              "时×体 · 过去 / 现在 / 将来视角 × 同一件事的体貌怎么看",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
            SizedBox(width: 4.wMin),
            CopyTagWidget(
              name: "宫格",
              value: "basic_action_time_aspect_grid",
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
          ],
        ),
        Text(
          "同一动作放进不同时体里",
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SizedBox(height: 10.wMin),
        Text(
          "把同一个动作放到过去、现在、将来，以及一般、进行、完成、完成进行里对照。",
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
              tagText: "12格",
            ),
            SizedBox(width: 6.wMin),
            _buildTagWidget(
              tagText: "CEFR 1-3",
            ),
          ],
        ),

      ],
    );
  }

  /// 表格
  Widget _buildContentTableWidget(){
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 24.wMin),
      child: GrammarPanoramaTableWidget(),
    );
  }


  /// 适合入格句型
  Widget _buildSuitableGridSentenceWidget(){
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 24.wMin),
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
            "适合入格句型",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 10.wMin),
          SelectableText(
            "肯否对照另走 polarity 家族，不要把 Yes./No. 和短答/整句混成肯否题。出题抽本家族 2–4 个 member。From 共用「Is he your brother?」；To 换壳：「Yes.」 / 「Yes, he is.」 / 「He is my brother.」。单条 pair 仍可按多场景练这一种推进。",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          SizedBox(height: 10.wMin),
          Wrap(
            spacing: 10.wMin,
            runSpacing: 6.wMin,
            children: List.generate(4, (index){
              return _buildSuitableGridSentenceItemWidget();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSuitableGridSentenceItemWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: AppTheme.cSurfaceLayerBase2.color,
        border: Border.all(
          color: AppTheme.cBorderThin.color,
          width: 0.5.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4.wMin,
        children: [
          Text(
            "说明做什么",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
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
          CopyTagWidget(
            name: "句型",
            value: "entity_pred",
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
