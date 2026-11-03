import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../bindings/manage_pattern_blueprint_details_binding.dart';
import '../controllers/manage_pattern_blueprint_details_controller.dart';

class ManagePatternBlueprintDetailsView
    extends GetView<ManagePatternBlueprintDetailsController> {
  final String tagText;
  const ManagePatternBlueprintDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_PATTERN_BLUEPRINT_DETAILS}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManagePatternBlueprintDetailsView(tagText: tag),
      binding: ManagePatternBlueprintDetailsBinding(tag: tag),
      routeName: Routes.MANAGE_PATTERN_BLUEPRINT_DETAILS,
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
      body: SingleChildScrollView(
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
            _buildRepresentWidget(context),
            SizedBox(height: 32.wMin),
          ],
        ),
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
          tagText: "可生长",
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

  /// 代表句
  Widget _buildRepresentWidget(BuildContext context) {
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
            children: [
              Expanded(
                child: Text(
                  "代表句",
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
              ),
              ButtonWidget(
                text: "编辑代表句",
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
                onTap: () {
                  controller.editRepresent(context);
                },
              ),
            ],
          ),
          SizedBox(height: 16.wMin),
          Obx(() {
            PatternBlueprintEntity pattern = controller.patternBlueprint.value;
            List<PatternBlueprintSentenceBriefEntity?> sentenceRealizationList = pattern.sentenceRealizationList ?? [];
            bool isSentenceScope = pattern.blueprintScope == "sentence";
            if (sentenceRealizationList.isEmpty) {
              return Text(
                "待教研挑选代表句",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              );
            }

            return Column(
              spacing: 16.wMin,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(sentenceRealizationList.length, (index) {
                return _buildRepresentItemWidget(
                  context,
                  sentenceRealizationList[index],
                  index,
                  isSentenceScope,
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRepresentItemWidget(BuildContext context, PatternBlueprintSentenceBriefEntity? item, int index, bool isSentenceScope) {
    return Container(
      padding: EdgeInsets.all(8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          width: 0.8.wMin,
          color: AppTheme.cBorderThin.color,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTagWidget(
                tagText: "代表句${index + 1}",
              ),
              SizedBox(width: 4.wMin),
              CopyTagWidget(
                name: "句子",
                value: item?.sentenceId?.toString() ?? '',
              ),
              if (isSentenceScope) ...[
                SizedBox(width: 4.wMin),
                _buildTagWidget(tagText: "跨子句组合"),
              ],
              const Spacer(),
              ButtonWidget(
                text: "拓展学习",
                height: 34.wMin,
                padding: EdgeInsets.only(left: 14.wMin, right: 8.wMin),
                color: AppTheme.cSurfaceLayerBase.color,
                border: Border.all(
                  width: 0.8.wMin,
                  color: AppTheme.cBorderSubtle.color,
                ),
                fontSize: 18.wMin,
                fontColor: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w500,
                sclae: 1.03,
                rightIcon: SvgPicture.asset(
                  "assets/svg/public/icon_w_arrow_right.svg",
                  width: 24.wMin,
                  colorFilter: ColorFilter.mode(
                      AppTheme.cTextSecondary.color, BlendMode.srcIn),
                ),
                onTap: () {
                  controller.expandLearning(item);
                },
              ),
            ],
          ),
          SizedBox(height: 12.wMin),
          SentenceSlotExampleWidget(
            segmentList: item?.segmentList,
            onSlotTap: (PatternBlueprintSentenceBriefSegmentEntity segment) {
              controller.slotSentenceExample(context, segment, item);
            },
          ),
          SizedBox(height: 12.wMin),
          Text(
            item?.definition ?? '',
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
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
