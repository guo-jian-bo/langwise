import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../manage_zhendu_console/common/manage_zhendu_widgets.dart';
import '../../common/manage_sentence_add_widgets.dart';
import '../bindings/manage_sentence_blueprint_add_group_binding.dart';
import '../controllers/manage_sentence_blueprint_add_group_controller.dart';
import 'manage_sentence_blueprint_add_group_slot_map_widget.dart';

class ManageSentenceBlueprintAddGroupView extends GetView<ManageSentenceBlueprintAddGroupController> {
  final String tagText;
  const ManageSentenceBlueprintAddGroupView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SENTENCE_BLUEPRINT_ADD_GROUP}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageSentenceBlueprintAddGroupView(tagText: tag),
      binding: ManageSentenceBlueprintAddGroupBinding(tag: tag),
      routeName: Routes.MANAGE_SENTENCE_BLUEPRINT_ADD_GROUP,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? subTitle = controller.patternBlueprint == null
        ? null
        : controller.shapeLockData.hasShapeLock && (controller.shapeLockData.targetTitle?.isNotEmpty == true)
            ? "已带入「${controller.shapeLockData.targetTitle}」形态锁：固定槽不能点；必含和受控默认勾上。□ 纳入这套形态，○ 要拧的槽。"
            : "点骨架选形态：固定槽不能点；必含和受控默认勾上。□ 纳入这套形态，○ 要拧的槽。";
    return ManageScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 90.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32.wMin),
            ManageSentenceAddTitleWidget(),
            SizedBox(height: 32.wMin),
            ManageSentenceAddTableWidget(
              subTitle: subTitle,
              asset: controller.patternBlueprint?.nid,
              child: _buildSlotWidget(),
            ),
            SizedBox(height: 24.wMin),
            Container(
              width: double.infinity,
              height: 1.wMin,
              color: AppTheme.cBorderDefault.color,
            ),
            SizedBox(height: 24.wMin),
            Obx(() {
              final bool isShapeLocked = controller.isShapeLocked();
              final List<ManageSentenceAddBindingCardModel> cardList = controller.buildBindingCardList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ManageSentenceAddBingListWidget(
                    itemCount: cardList.length,
                    itemBuilder: (index) {
                      final ManageSentenceAddBindingCardModel model = cardList[index];
                      return ManageSentenceAddBingWidget(
                        index: index,
                        title: model.title,
                        centerWidget: ManageSentenceAddBingSentenceWidget(model: model),
                        hasSentence: model.sentence != null,
                        pickSentence: () {
                          controller.pickSentence(context, index);
                        },
                        inputUid: () {
                          controller.manualInputUid(context, index);
                        },
                        clearSentence: () {
                          controller.boundSentenceMap.remove(index);
                        },
                      );
                    },
                  ),
                  if (!isShapeLocked)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 14.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.wMin),
                        color: AppTheme.cSurfaceLayerBase.color,
                        border: Border.all(
                          color: AppTheme.cBorderSubtle.color,
                          width: 0.8.wMin,
                        ),
                      ),
                      child: Text(
                        "先把表画完：至少先定下这套形态要纳入哪些槽，并点出要拧的槽，再开始逐句绑句。",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: AppTheme.cTextSecondary.color,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                ],
              );
            }),
            SizedBox(height: 200.wMin),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() {
        final bool isShapeLocked = controller.isShapeLocked();
        final int bindCount = isShapeLocked ? controller.boundSentenceMap.length : 0;
        final int totalCount = isShapeLocked ? controller.sentenceCountValue.value : 0;
        final bool isAddSentenceEnabled = isShapeLocked && bindCount > 0;
        return ManageSentenceAddButtonsWidget(
          bindCount: bindCount,
          totalCount: totalCount,
          addSentence: controller.addSentence,
          fullSentence: controller.fullSentence,
          isAddSentenceEnabled: isAddSentenceEnabled,
          isFullSentenceEnabled: isShapeLocked && totalCount > 0 && bindCount == totalCount,
        );
      }),
    );
  }

  /// 蓝图/金字塔骨架
  Widget _buildSlotWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.shapeLockData.hasShapeLock) _buildShapeLockHintWidget(),
        Obx(() {
          final List<String> checkedSlotKeys = ManageSentenceBlueprintAddGroupSlotMapHelper.getBaseSlotKeys(
            patternBlueprint: controller.patternBlueprint,
            optionalBaseSlotKeys: controller.optionalBaseSlotKeys,
            shapeLockData: controller.shapeLockData,
          );
          return ManageSentenceBlueprintAddGroupSlotMapWidget(
            patternBlueprint: controller.patternBlueprint,
            checkedSlotKeys: checkedSlotKeys,
            dialSlotKeys: controller.dialSlotKeys.toList(),
            occupiedSlotKeys: controller.presetOccupiedSlotKeys,
            unusedSlotKeys: ManageSentenceBlueprintAddGroupSlotMapHelper.getDisabledOptionalSlotKeys(
              controller.patternBlueprint,
              shapeLockData: controller.shapeLockData,
            ),
            onSlotTap: controller.onPatternSlotTap,
          );
        }),
        Visibility(
          visible: controller.patternBlueprint != null &&
              (ManageSentenceBlueprintAddGroupSlotMapHelper.getLockedFormSlotKeys(controller.patternBlueprint).isNotEmpty ||
                  ManageSentenceBlueprintAddGroupSlotMapHelper.getOptionalOpenSlotKeys(
                    controller.patternBlueprint,
                    shapeLockData: controller.shapeLockData,
                  ).isNotEmpty),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.wMin),
              Text(
                "□ 纳入这套形态 · ○ 要拧的槽。点未勾的可选槽加入；再点已勾的槽拧上；再点一次可取消。",
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.wMin),
        Text(
          "要钉几句（至少 2）",
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(
          width: 200.wMin,
          child: ManageZhenduNumberInputWidget(
            controller: controller.sentenceNumberController,
            isInt: true,
            minValue: 2,
            maxValue: 8,
            onChanged: (value) {
              controller.onSentenceNumberChanged(value);
            },
            onSubmitted: (value) {
              controller.onSentenceNumberChanged(value);
            },
            onTapOutside: (_) {
              controller.onSentenceNumberChanged();
            },
            stepChangedDebounceDuration: Duration.zero,
            onStepChanged: (value) {
              controller.onSentenceNumberChanged(value);
            },
          ),
        ),
      ],
    );
  }

  /// Target 入口下的形态锁提示。
  Widget _buildShapeLockHintWidget() {
    final PatternBlueprintEntity? patternBlueprint = controller.patternBlueprint;
    final ManageSentenceBlueprintAddGroupShapeLockData shapeLockData = controller.shapeLockData;
    final List<String> activatedNames = shapeLockData.activatedOptionalSlotKeys
        .map((key) => _resolveSlotDisplayName(patternBlueprint, key))
        .where((item) => item.isNotEmpty)
        .toList();
    final String targetTitle =
        shapeLockData.targetTitle?.isNotEmpty == true ? shapeLockData.targetTitle! : "Target ${shapeLockData.targetUid ?? ''}";
    final String descText = shapeLockData.type == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID.rawValue
        ? "增长槽按 Target 固定：${activatedNames.isNotEmpty ? activatedNames.join(' → ') : '当前层级'}；只需锁基句、绑每层的句。"
        : "${activatedNames.isNotEmpty ? "激活槽 ${activatedNames.join('、')} 固定纳入" : "形态按句型默认"}${shapeLockData.allowAdditionalOptionalSlots ? '' : '，不允许再加其他可选槽'}；只选要拧的槽和句数。";
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 10.wMin, bottom: 10.wMin),
      padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
        border: Border.all(
          color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.25),
          width: 0.8.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 2.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999.wMin),
                  color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.14),
                  border: Border.all(
                    color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.4),
                    width: 0.8.wMin,
                  ),
                ),
                child: Text(
                  "单元形态锁",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: AppTheme.cSurfaceWarning.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 10.wMin),
              Text(
                targetTitle,
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 10.wMin),
              Text(
                descText,
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          
        ],
      ),
    );
  }

  /// 解析槽位展示名，优先走 openSlotList，其次回退 slotKey。
  String _resolveSlotDisplayName(PatternBlueprintEntity? patternBlueprint, String slotKey) {
    for (final PatternBlueprintOpenSlotListItemEntity? item in patternBlueprint?.openSlotList ?? const []) {
      if (item?.slotKey != slotKey) {
        continue;
      }
      final String? text = LearningLangUtils.getLocalLang(item?.slot?.name)?.text;
      if (text?.isNotEmpty == true) {
        return text!;
      }
    }
    return slotKey;
  }
}
