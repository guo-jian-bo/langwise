import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../common/values/values.dart';
import '../../../management/common/commons.dart';
import '../bindings/zhenxie_pattern_blueprint_details_binding.dart';
import '../controllers/zhenxie_pattern_blueprint_details_controller.dart';
import 'zenxie_pattern_blueprint_represent_widget.dart';

class ZhenxiePatternBlueprintDetailsView extends GetView<ZhenxiePatternBlueprintDetailsController> {
  final String tagText;
  const ZhenxiePatternBlueprintDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 管理端入口跳转方法（生成唯一 tag，支持多实例）。
  static Future<T?> toManage<T>({dynamic arguments}) async {
    final tag = '${Routes.ZHENXIE_PATTERN_BLUEPRINT_DETAILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ZhenxiePatternBlueprintDetailsView(tagText: tag),
      binding: ZhenxiePatternBlueprintDetailsBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PATTERN_BLUEPRINT_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  /// 标签路由跳转方法（外部传入 tag，支持实例隔离）。
  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxiePatternBlueprintDetailsView(tagText: tag),
      binding: ZhenxiePatternBlueprintDetailsBinding(tagText: tag),
      routeName: Routes.ZHENXIE_PATTERN_BLUEPRINT_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () async {
        await controller.getDetatils();
      },      
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
                  SizedBox(height: 32.wMin),
                  _buildInfoWidget(context),
                  SizedBox(height: 32.wMin),
                  ZenxiePatternBlueprintRepresentWidget(
                    controller: controller,
                    onRefresh: (data) {
                      controller.getExampleForUid(data);
                    },
                  ),
                  SizedBox(height: 200.wMin),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFilterWidget(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 筛选的按钮
  Widget _buildFilterWidget(BuildContext context){
    if(!controller.isManagement) return Container();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 90.wMin),
      child: Obx((){
        return FilterStripWidget(
          sorts: {...controller.filterSorts},
          conditions: {...controller.filterConditions},
          searchs: controller.filterSearchs,
          searchSingleWidth: 480.wMin,
          onSorts: (sorts) {
            controller.filterSorts.value = sorts;
            controller.refreshExampleList();
          },
          onConditions: (conditions) {
            controller.filterConditions.value = conditions;
            controller.refreshExampleList();
          },
          onReset: (sorts, conditions) {
            controller.filterSorts.value = sorts;
            controller.filterConditions.value = conditions;
            controller.refreshExampleList();
          },
          onSearch: () {
            controller.refreshExampleList();
          },
        );
      }),
    );
  }

  Widget _buildInfoWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cZhenxieBackgroundPrimary.color,
        border: Border.all(
          color: AppTheme.cZhenxieBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: Obx(() {
        PatternBlueprintEntity data = controller.patternBlueprint.value;
        LanguageText? name = LearningLangUtils.getLocalLang(data.name);
        LanguageText? description = LearningLangUtils.getLocalLang(data.description);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text.rich(TextSpan(
                    style: TextStyle(
                      fontSize: 32.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cZhenxieFontPrimary.color,
                      fontFamily: AppFontValue.sourceHanSerifCN,
                    ),
                    children: [
                      TextSpan(text: name?.text ?? ''),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Visibility(
                          visible: controller.isManagement,
                          child: Container(
                            margin: EdgeInsets.only(left: 4.wMin),
                            child: CopyTagWidget(
                              name: "句型",
                              value: data.nid ?? "",
                              isShow: controller.isManagement,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
                ),
                _buildInfoRightTagsWidget(),
                SizedBox(width: 24.wMin),
                if(controller.isManagement) ...[
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
                        colorFilter: ColorFilter.mode(
                            AppTheme.cTextPrimary.color, BlendMode.srcIn),
                      ),
                    ),
                    onTap: OptimizeUtils.noneThrottle(() {
                      controller.editNameDesc(context);
                    }, 1000),
                  ),
                  SizedBox(width: 12.wMin),
                  ButtonWidget(
                    text: "添加一组",
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
                        "assets/svg/manage/icon_add.svg",
                        width: 16.wMin,
                        colorFilter: ColorFilter.mode(
                            AppTheme.cTextPrimary.color, BlendMode.srcIn),
                      ),
                    ),
                    onTap: OptimizeUtils.noneThrottle(() {
                      controller.addGroup();
                    }, 1000),
                  ),
                ],
              ],
            ),
            SizedBox(height: 10.wMin),
            Visibility(
              visible: description != null,
              child: Text(
                description?.text ?? "",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontTertiary.color,
                  fontFamily: AppFontValue.sourceHanSerifCN,
                ),
              ),
            ),
            SizedBox(height: 10.wMin),
            _buildInfoBottomTagsWidget(),
            SizedBox(height: 16.wMin),
            SentenceSlotMapWidget(
              data: SentenceSlotMapUtils.buildFromPatternBlueprint(data),
              showDepend: true,
              onSlotTap: (item) {
                controller.slotDetails(context, item);
              },
            )
          ],
        );
      }),
    );
  }

  Widget _buildInfoRightTagsWidget() {
    return Obx(() {
      PatternBlueprintEntity data = controller.patternBlueprint.value;
      List<Widget> tags = [];
      if (data.supportsPyramid = true) {
        tags.add(_buildTagWidget(
          tagText: "支持金字塔",
          textColor: Color(0xff22C55E),
          bgColor: Color(0xff22C55E).withValues(alpha: 0.12),
          borderColor: Color(0xff22C55E).withValues(alpha: 0.2),
        ));
      }
      if (data.patternTier != null) {
        tags.add(_buildTagWidget(tagText: data.patternTier ?? ""));
      }
      if (data.difficulty?.min != null && data.difficulty?.max != null) {
        tags.add(_buildTagWidget(
          tagText: "L${data.difficulty?.min}-L${data.difficulty?.max}"),
        );
      }

      return Row(
        spacing: 6.wMin,
        children: tags,
      );
    });
  }

  Widget _buildInfoBottomTagsWidget() {
    return Obx(() {
      PatternBlueprintEntity data = controller.patternBlueprint.value;
      LanguageText? familyName = LearningLangUtils.getLocalLang(data.family?.name);
      LanguageText? functionalTypeName = LearningLangUtils.getLocalLang(data.functionalType?.name);
      LanguageText? basicTypeName = LearningLangUtils.getLocalLang(data.basicType?.name);
      LanguageText? svocaTypeName = LearningLangUtils.getLocalLang(data.primarySvoca?.name);
      String? blueprintScope = data.blueprintScope;

      List<Widget> tags = [];
      if (familyName != null) {
        tags.add(_buildTagWidget(tagText: familyName.text ?? ""));
      }
      if (functionalTypeName != null) {
        tags.add(_buildTagWidget(tagText: functionalTypeName.text ?? ""));
      }
      if (basicTypeName != null) {
        tags.add(_buildTagWidget(tagText: basicTypeName.text ?? ""));
      }
      if (svocaTypeName != null) {
        tags.add(_buildTagWidget(tagText: svocaTypeName.text ?? ""));
      }
      if (blueprintScope != null) {
        tags.add(_buildTagWidget(
          tagText: blueprintScope == "sentence" ? "跨子句组合" : "子句内装配",
        ));
      }
      return Wrap(
        spacing: 6.wMin,
        runSpacing: 4.wMin,
        children: tags,
      );
    });
  }

  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cZhenxieFontTertiary,
    Color bgColor = AppTheme.cZhenxieBackgroundPrimary,
    Color borderColor = AppTheme.cZhenxieBorderPrimary,
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
              fontFamily: AppFontValue.sourceHanSerifCN,
            ),
          ),
        ],
      ),
    );
  }
}
