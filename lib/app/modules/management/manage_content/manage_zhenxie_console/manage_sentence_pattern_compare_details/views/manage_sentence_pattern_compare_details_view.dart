import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_sentence_pattern_compare_details_binding.dart';
import '../controllers/manage_sentence_pattern_compare_details_controller.dart';

class ManageSentencePatternCompareDetailsView extends GetView<ManageSentencePatternCompareDetailsController> {
  final String tagText;
  const ManageSentencePatternCompareDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SENTENCE_PATTERN_COMPARE_DETAILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageSentencePatternCompareDetailsView(tagText: tag),
      binding: ManageSentencePatternCompareDetailsBinding(tag: tag),
      routeName: Routes.MANAGE_SENTENCE_PATTERN_COMPARE_DETAILS,
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
            _buildSameGroupCompareTableWidget(),
            SizedBox(height: 32.wMin),
            _buildSharedSlotWidget(),
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
              "句子类型对照",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
            SizedBox(width: 16.wMin),
            CopyTagWidget(
              name: "维度",
              value: "sentence_type_contrast",
            ),
            const Spacer(),
            _buildTagWidget(
              tagText: "同一条主线可以换哪些说法",
            ),
            SizedBox(width: 6.wMin),
            _buildTagWidget(
              tagText: "3壳",
            ),
            SizedBox(width: 6.wMin),
            _buildTagWidget(
              tagText: "一组对照",
              textColor: Color(0xff22C55E),
              bgColor: Color(0xff22C55E).withValues(alpha: 0.12),
              borderColor: Color(0xff22C55E).withValues(alpha: 0.2),
            ),
            SizedBox(width: 6.wMin),
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
              text: "编辑对照组",
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
                controller.editCompareGroup(context);
              }, 1000),
            ),
          ],
        ),
        Row(
          spacing: 4.wMin,
          children: [
            Text(
              "be 句怎样陈述、确认和追问",
              style: TextStyle(
                fontSize: 28.wMin,
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
        SizedBox(height: 10.wMin),
        Text(
          "用来给人或事物下身份：它是谁、是什么角色或什么东西。",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
      ],
    );
  }

  /// 同组对照表
  Widget _buildSameGroupCompareTableWidget(){
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
      child: SameGroupCompareSentenceTableWidget(),
    );
  }

  /// 共享槽
  Widget _buildSharedSlotWidget(){
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "共享槽",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 12.wMin),
          Text(
            "切换壳时应搬运的语义位",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          SizedBox(height: 12.wMin),
          Row(
            spacing: 4.wMin,
            children: [
              _buildTagWidget(
                tagText: "主语 semantic_carry",
              ),
              _buildTagWidget(
                tagText: "性质 semantic_carry",
              ),
            ],
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
