import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../management/common/commons.dart';
import '../bindings/zhenxie_sentence_pattern_compare_details_binding.dart';
import '../controllers/zhenxie_sentence_pattern_compare_details_controller.dart';

class ZhenxieSentencePatternCompareDetailsView extends GetView<ZhenxieSentencePatternCompareDetailsController> {
  final String tagText;
  const ZhenxieSentencePatternCompareDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 标签路由跳转方法（外部传入 tag，支持实例隔离）。
  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieSentencePatternCompareDetailsView(tagText: tag),
      binding: ZhenxieSentencePatternCompareDetailsBinding(tagText: tag),
      routeName: Routes.ZHENXIE_SENTENCE_PATTERN_COMPARE_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () {
        controller.getDetailData();
      },
      body: Column(
        children: [
          BreadcrumbWidget(isCompatibleManage: controller.isManagement),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 90.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 32.wMin),
                  _buildInfoWidget(context),
                  SizedBox(height: 32.wMin),
                  _buildSameGroupCompareTableWidget(context),
                  SizedBox(height: 32.wMin),
                  _buildSharedSlotWidget(),
                  SizedBox(height: 32.wMin),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoWidget(BuildContext context){
    return Obx((){
      SentencePatternCompareEntity data = controller.detailData.value;
      LanguageText? dimensionName = LearningLangUtils.getLocalLang(data.dimension?.name);
      LanguageText? name = LearningLangUtils.getLocalLang(data.name);
      LanguageText? description = LearningLangUtils.getLocalLang(data.description);
      LanguageText? transformationKindName = LearningLangUtils.getLocalLang(data.transformationKind?.name);
      int memberCount = data.memberList?.length ?? 0;
      int sentenceRealizationSetCount = data.realizationSetList?.length ?? 0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                dimensionName?.text??'',
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
              SizedBox(width: 16.wMin),
              CopyTagWidget(
                name: "维度",
                value: data.dimensionNid??'',
                isShow: controller.isManagement,
              ),
              const Spacer(),
              if ((transformationKindName?.text ?? '').isNotEmpty) ...[
                _buildTagWidget(
                  tagText: transformationKindName?.text ?? '',
                ),
                SizedBox(width: 6.wMin),
              ],
              _buildTagWidget(
                tagText: "$memberCount壳",
              ),
              SizedBox(width: 6.wMin),
              _buildTagWidget(
                tagText: sentenceRealizationSetCount > 0 ? "$sentenceRealizationSetCount组对照" : "待挑句",
                textColor: sentenceRealizationSetCount > 0 ? Color(0xff22C55E) : AppTheme.cTextQuaternary.color,
                bgColor: sentenceRealizationSetCount > 0 ? Color(0xff22C55E).withValues(alpha: 0.12) : AppTheme.cSurfaceLayerBase.color,
                borderColor: sentenceRealizationSetCount > 0 ? Color(0xff22C55E).withValues(alpha: 0.2) : AppTheme.cBorderThin.color,
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
                name?.text??'',
                style: TextStyle(
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              CopyTagWidget(
                name: "对照",
                value: data.nid??'',
                isShow: controller.isManagement,
              ),
            ],
          ),
          SizedBox(height: 10.wMin),
          Text(
            description?.text??'',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ],
      );
    });
  }

  /// 同组对照表
  Widget _buildSameGroupCompareTableWidget(BuildContext context){
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
        children: [
          Obx((){
            SentencePatternCompareEntity data = controller.detailData.value;
            return SameGroupCompareSentenceTableWidget(
              memberList: data.memberList,
              sentenceRealizationSetList: data.realizationSetList,
              isManagement: controller.isManagement,
              onShelfChange: (sentenceRealizationSet) {
                controller.exampleSentenceGroupShelf(sentenceRealizationSet);
              },
              onDelete: (sentenceRealizationSet) {
                controller.exampleSentenceGroupDelete(context, sentenceRealizationSet);
              },
              onSentenceShelfChange: (sentenceBinding) {
                controller.exampleSentenceShelf(sentenceBinding);
              },
            );
          }),
        ],
      ),
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
          Obx((){
            SentencePatternCompareEntity data = controller.detailData.value;
            List<SentencePatternCompareParadigmSlotEntity?> paradigmSlots = data.paradigmSlots??[];
            return Row(
              spacing: 4.wMin,
              children: List.generate(paradigmSlots.length, (index){
                return _buildTagWidget(
                  tagText: paradigmSlots[index]?.slotKey??'',
                );
              }),
            );
          }),
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
