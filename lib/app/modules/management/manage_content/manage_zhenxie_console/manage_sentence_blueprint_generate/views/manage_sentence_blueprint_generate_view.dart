import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/values/values.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../manage_zhendu_console/common/manage_zhendu_widgets.dart';
import '../bindings/manage_sentence_blueprint_generate_binding.dart';
import '../controllers/manage_sentence_blueprint_generate_controller.dart';

class ManageSentenceBlueprintGenerateView extends GetView<ManageSentenceBlueprintGenerateController> {
  final String tagText;
  const ManageSentenceBlueprintGenerateView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SENTENCE_BLUEPRINT_GENERATE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageSentenceBlueprintGenerateView(tagText: tag),
      binding: ManageSentenceBlueprintGenerateBinding(tag: tag),
      routeName: Routes.MANAGE_SENTENCE_BLUEPRINT_GENERATE,
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
          children: [
            Obx(() {
              return SentenceSkeletonWidget(
                data: controller.patternBlueprint.value,
                desc: "亮的是本单元用到的槽；标「不用」的是句型有、这个单元用不上的可选槽",
              );
            }),
            _buildExistingSentencesList(),
            _buildUnitVocabulary(),
            _buildFormWidget(),
            SizedBox(height: 100.wMin),
          ],
        ),
      ),
      bottomNavigationBar: _buildButtonsWidget(context),
    );
  }

  /// 已有句子列表
  Widget _buildExistingSentencesList() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 24.wMin),
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          width: 1.wMin,
          color: AppTheme.cBorderThin.color,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "已有句子列表",
            style: TextStyle(
              fontSize: 22.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cZhenxieFontPrimary.color,
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
          Text(
            "这个句型下已经挂上的句子。",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontSecondary.color,
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
          SizedBox(height: 10.wMin),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Obx(() {
              return Column(
                spacing: 16.wMin,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(controller.existingSentenceList.length, (index) {
                  return SentenceSlotAnnotatedExampleWidget(
                    pattern: controller.patternBlueprint.value,
                    sentence: controller.existingSentenceList[index],
                    isManagement: true,
                    padding: EdgeInsets.symmetric(horizontal: 2.wMin),
                    valueFontSize: 20.wMin,
                    lableFontSzie: 18.wMin,
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 选择单元词汇
  Widget _buildUnitVocabulary() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 24.wMin),
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          width: 1.wMin,
          color: AppTheme.cBorderThin.color,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "指定词汇",
                      style: TextStyle(
                        fontSize: 22.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cZhenxieFontPrimary.color,
                        fontFamily: AppFontValue.sourceHanSerifCN,
                      ),
                    ),
                    Text(
                      "不指定就用本单元全部单词和短语。",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cZhenxieFontSecondary.color,
                        fontFamily: AppFontValue.sourceHanSerifCN,
                      ),
                    ),
                  ],
                ),
              ),
              ButtonWidget(
                text: "选择词汇",
                width: 120.wMin,
                height: 48.wMin,
                color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12),
                border: Border.all(
                  width: 1.wMin,
                  color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2),
                ),
                sclae: 1.01,
                fontColor: AppTheme.cZhenxieFontPrimary.color,
                fontSize: 18.wMin,
                onTap: () {
                  controller.selectVocabulary();
                },
              ),
            ],
          ),
          SizedBox(height: 10.wMin),
          Obx(() {
            return Wrap(
              spacing: 10.wMin,
              runSpacing: 8.wMin,
              children: List.generate(controller.selectedVocabularyList.length, (index) {
                final item = controller.selectedVocabularyList[index];
                return TapScaleWidget(
                  onTap: () {
                    controller.deleteSelectedVocabulary(item);
                  },
                  sclae: 1,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2),
                      border: Border.all(
                        width: 1.wMin,
                        color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      item.title ?? '',
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cZhenxieFontPrimary.color,
                        fontFamily: AppFontValue.robotoMono,
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  /// 这次写哪些形态
  Widget _buildFormWidget() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 24.wMin),
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          width: 1.wMin,
          color: AppTheme.cBorderThin.color,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "这次写哪些形态",
            style: TextStyle(
              fontSize: 22.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cZhenxieFontPrimary.color,
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
          Text(
            "先写第一行基句，后面的层从这批基句里挑一句接着长。句数只能从基句连续往下，不能跳层。",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cZhenxieFontSecondary.color,
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
          SizedBox(height: 10.wMin),
          Obx(() {
            return Column(
              spacing: 16.wMin,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...List.generate(controller.shapeRowList.length, (index) {
                  return _buildFormItemWidget(controller.shapeRowList[index]);
                }),
                Visibility(
                  visible: controller.shapeCountErrorText.value.isNotEmpty,
                  child: Text(
                    controller.shapeCountErrorText.value,
                    style: TextStyle(
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cSurfaceWarning.color,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFormItemWidget(ManageSentenceBlueprintGenerateShapeRowEntity shapeRow) {
    return Row(
      children: [
        Expanded(
          child: SentenceSlotShapeMapWidget(
            pattern: controller.patternBlueprint.value,
            highlightSlotKeys: shapeRow.highlightSlotKeys,
            unusedSlotKeys: shapeRow.unusedSlotKeys,
            valueFontSize: 20.wMin,
            lableFontSzie: 18.wMin,
          ),
        ),
        // 输入框
        SizedBox(
          width: 160.wMin,
          child: ManageZhenduNumberInputWidget(
            controller: shapeRow.countController,
            isInt: true,
            minValue: 0,
            maxValue: 6,
            onChanged: (_) {
              controller.refreshShapeCountError();
            },
            onSubmitted: (_) {
              controller.normalizeShapeCountInput(shapeRow);
            },
            onTapOutside: (_) {
              controller.normalizeShapeCountInput(shapeRow);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildButtonsWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 90.wMin,
        right: 90.wMin,
        bottom: 24.wMin,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 24.wMin,
        children: [
          ButtonWidget(
            text: "取消",
            height: 52.wMin,
            width: 100.wMin,
            color: AppTheme.cSurfaceLayerBase.color,
            border: Border.all(
              width: 0.8.wMin,
              color: AppTheme.cBorderSubtle.color,
            ),
            fontSize: 20.wMin,
            fontColor: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            onTap: OptimizeUtils.noneThrottle(() {
              Get.back();
            }, 1000),
          ),
          ButtonWidget(
            text: "生成",
            height: 52.wMin,
            width: 120.wMin,
            color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12),
            border: Border.all(
              width: 0.8.wMin,
              color: AppTheme.cSurfaceSuccess.color,
            ),
            fontSize: 20.wMin,
            fontColor: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            onTap: OptimizeUtils.noneThrottle(() {
              controller.generateSentenceBlueprint(context);
            }, 1000),
          ),
        ],
      ),
    );
  }
}
