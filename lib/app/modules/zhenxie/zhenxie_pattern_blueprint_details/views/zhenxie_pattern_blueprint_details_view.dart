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
import '../../../management/common/commons.dart';
import '../bindings/zhenxie_pattern_blueprint_details_binding.dart';
import '../controllers/zhenxie_pattern_blueprint_details_controller.dart';
import 'zenxie_pattern_blueprint_represent_widget.dart';

class ZhenxiePatternBlueprintDetailsView extends GetView<ZhenxiePatternBlueprintDetailsController> {
  final String tagText;
  const ZhenxiePatternBlueprintDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

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
              padding: EdgeInsets.symmetric(horizontal: 90.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 32.wMin),
                  _buildInfoWidget(context),
                  Obx(() {
                    return SentenceSkeletonWidget(
                      data: controller.patternBlueprint.value,
                      onTap: (SentenceSlotMapItemEntity item) {
                        controller.slotDetails(context, item);
                      },
                    );
                  }),
                  // _buildRepresentWidget(context),
                  SizedBox(height: 32.wMin),
                  ZenxiePatternBlueprintRepresentWidget(
                    controller: controller,
                    onRefresh: (data) {
                      controller.getExampleForUid(data);
                    },
                  ),
                  SizedBox(height: 32.wMin),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoWidget(BuildContext context) {
    return Obx(() {
      PatternBlueprintEntity data = controller.patternBlueprint.value;
      LanguageText? name = LearningLangUtils.getLocalLang(data.name);
      LanguageText? description =
          LearningLangUtils.getLocalLang(data.description);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text.rich(TextSpan(
                  style: TextStyle(
                    fontSize: 32.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                  children: [
                    TextSpan(text: name?.text ?? ''),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        margin: EdgeInsets.only(left: 4.wMin),
                        child: CopyTagWidget(
                          name: "句型",
                          value: data.nid ?? "",
                          isShow: controller.isManagement,
                        ),
                      ),
                    ),
                  ],
                )),
              ),
              _buildInfoRightTagsWidget(),
              SizedBox(width: 24.wMin),
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
            ],
          ),
          SizedBox(height: 10.wMin),
          Text(
            description?.text ?? "",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          SizedBox(height: 10.wMin),
          _buildInfoBottomTagsWidget(),
        ],
      );
    });
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
