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
import '../../../../routes/tag_routes.dart';
import '../bindings/zhenxie_grammar_panorama_details_binding.dart';
import '../controllers/zhenxie_grammar_panorama_details_controller.dart';

class ZhenxieGrammarPanoramaDetailsView extends GetView<ZhenxieGrammarPanoramaDetailsController> {
  final String tagText;
  const ZhenxieGrammarPanoramaDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 标签路由跳转方法（外部传入 tag，支持实例隔离）。
  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieGrammarPanoramaDetailsView(tagText: tag),
      binding: ZhenxieGrammarPanoramaDetailsBinding(tagText: tag),
      routeName: Routes.ZHENXIE_GRAMMAR_PANORAMA_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () {
        controller.getDatailsData();
      },
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Column(
        children: [
          BreadcrumbWidget(isCompatibleManage: controller.isManagement),
          Expanded(
            child: SingleChildScrollView(
              controller: controller.scrollController,
              padding: EdgeInsets.symmetric(horizontal: 90.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.wMin),
                  _buildInfoWidget(context),
                  _buildSuitableGridSentenceWidget(),
                  _buildContentTableWidget(context),
                  SizedBox(height: 200.wMin),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatWidget(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFloatWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSwitchWidget(context),
      ],
    );
  }

  Widget _buildInfoWidget(BuildContext context) {
    return Obx(() {
      final data = controller.grammarPanorama.value;

      final name = LearningLangUtils.getLocalLang(data.name);
      final description = LearningLangUtils.getLocalLang(data.description);
      int subCount = data.minimalSubGridCount ?? 0;

      List<String> axesTexts = [];
      final axes = data.axes ?? [];
      for (var element in axes) {
        if (element == null) continue;
        final dimensionName = LearningLangUtils.getLocalLang(element.dimension?.name);
        if (dimensionName?.text == null) continue;
        axesTexts.add(dimensionName?.text ?? '');
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "${data.gridKindEnum?.name ?? ''} · ${axesTexts.join(' × ')}",
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
              SizedBox(width: 4.wMin),
              CopyTagWidget(
                name: "宫格",
                value: data.nid ?? '',
                isShow: controller.isManagement,
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
            name?.text ?? '',
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 8.wMin),
          Text(
            description?.text ?? '',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          SizedBox(height: 10.wMin),
          Row(
            spacing: 8.wMin,
            children: [
              _buildTagWidget(
                tagText: "${data.cellCount ?? 0}格",
              ),
              _buildTagWidget(
                tagText: subCount > 0 ? "$subCount裁剪" : "无裁剪",
              ),
              _buildTagWidget(
                tagText: "CEFR ${data.difficulty?.min ?? ''}-${data.difficulty?.max ?? ''}",
              ),
            ],
          ),
        ],
      );
    });
  }

  /// 表格
  Widget _buildContentTableWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 24.wMin),
      child: Obx(() {
        return GrammarPanoramaTableWidget(
          isManagement: controller.isManagement,
          focusKey: controller.selectedFocusKey.value,
          cells: controller.visibleCells,
          axes: controller.visibleAxes,
          exampleList: controller.exampleList.toList(),
          onShelfChange: (group) {
            controller.exampleSentenceGroupShelf(group);
          },
          onDelete: (group) {
            controller.exampleSentenceGroupDelete(context, group);
          },
        );
      }),
    );
  }

  /// 适合入格句型
  Widget _buildSuitableGridSentenceWidget() {
    //state_entity_be_adj
    return Obx(() {
      final sentenceEligibility = controller.grammarPanorama.value.sentenceEligibility;
      List<ManageGrammarPanoramaPatternInfoEntity?> suggestedPatterns = sentenceEligibility?.suggestedPatterns ?? [];

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
            Visibility(
              visible: suggestedPatterns.isEmpty,
              child: SelectableText(
                "未声明 suggestedPatternNids",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
            ),
            Visibility(
              visible: suggestedPatterns.isNotEmpty,
              child: Wrap(
                spacing: 10.wMin,
                runSpacing: 6.wMin,
                children: List.generate(suggestedPatterns.length, (index) {
                  return _buildSuitableGridSentenceItemWidget(suggestedPatterns[index]);
                }),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSuitableGridSentenceItemWidget(ManageGrammarPanoramaPatternInfoEntity? data) {
    final name = LearningLangUtils.getLocalLang(data?.name)?.text;
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
            name ?? '',
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
              if (data?.nid == null) return;
              TagRoutes.toNamed(
                Routes.ZHENXIE_PATTERN_BLUEPRINT_DETAILS,
                arguments: {
                  "nid": data?.nid ?? '',
                  "isManagement": controller.isManagement,
                },
              );
            }, 1000),
          ),
          CopyTagWidget(
            name: "句型",
            value: data?.nid ?? '',
            isShow: controller.isManagement,
          ),
        ],
      ),
    );
  }

  /// 底部切换
  Widget _buildSwitchWidget(BuildContext context) {
    return Obx(() {
      if (controller.axesList.isEmpty && controller.focusKeyList.isEmpty) return Container();
      return PlatformBackdropFilterWidget(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 90.wMin),
        padding: EdgeInsets.only(left: 8.wMin, top: 8.wMin, bottom: 8.wMin, right: 24.wMin),
        borderRadius: BorderRadius.circular(99),
        backgroundColor: AppTheme.cSurfaceSearchBackground.color,
        fallbackColor: AppTheme.cSurfaceSearchBackground.color,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.wMin,
        ),
        child: Row(
          children: [
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: false, // 隐藏滚动条
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 16.wMin,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(controller.axesList.length, (index) {
                      final axis = controller.axesList[index];
                      final dimensionName = LearningLangUtils.getLocalLang(axis.dimension?.name)?.text;
                      final valuesLabels = axis.valuesLabels ?? [];

                      return Container(
                        padding: EdgeInsets.only(left: 16.wMin, top: 8.wMin, bottom: 8.wMin, right: 8.wMin),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          color: AppTheme.cSurfaceLayerBase2.color,
                        ),
                        child: Row(
                          spacing: 8.wMin,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              dimensionName ?? "",
                              style: TextStyle(
                                fontSize: 18.wMin,
                                color: AppTheme.cTextSecondary.color,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            ...List.generate(valuesLabels.length, (index1) {
                              final lableName = LearningLangUtils.getLocalLang(valuesLabels[index1]?.name)?.text;
                              return _buildButtonWidget(
                                text: lableName ?? "",
                                selected: controller.isAxisValueSelected(axis.axisKey, valuesLabels[index1]?.nid),
                                onTap: () {
                                  controller.toggleAxisValue(axis.axisKey, valuesLabels[index1]?.nid);
                                },
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
            Row(
              spacing: 8.wMin,
              children: List.generate(controller.focusKeyList.length, (index) {
                return _buildButtonWidget(
                  text: controller.focusKeyList[index].label,
                  selected: controller.selectedFocusKey.value == controller.focusKeyList[index],
                  onTap: () {
                    controller.selectFocusKey(controller.focusKeyList[index]);
                  },
                );
              }),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildButtonWidget({
    required String text,
    void Function()? onTap,
    bool selected = false,
  }) {
    Color textColor = AppTheme.cTextTertiary.color;
    Color bgColor = AppTheme.cSurfaceLayerBase.color;
    Color borderColor = AppTheme.cBorderSubtle.color;
    if (selected) {
      textColor = AppTheme.cTextPrimary.color;
      bgColor = AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.3);
      borderColor = AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.5);
    }
    return ButtonWidget(
      text: text,
      height: 48.wMin,
      width: 116.wMin,
      borderRadius: 99,
      color: bgColor,
      border: Border.all(
        color: borderColor,
        width: 1.wMin,
      ),
      fontColor: textColor,
      fontSize: 20.wMin,
      fontWeight: FontWeight.w500,
      sclae: 1,
      onTap: onTap,
    );
  }

  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cTextSecondary,
    Color bgColor = AppTheme.cSurfaceLayerBase,
    Color borderColor = AppTheme.cBorderThin,
  }) {
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
