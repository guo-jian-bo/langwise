import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../common/manage_sentence_add_widgets.dart';
import '../../manage_sentence_blueprint_add_group/views/manage_sentence_blueprint_add_group_slot_map_widget.dart';
import '../bindings/manage_sentence_pyramid_add_group_binding.dart';
import '../controllers/manage_sentence_pyramid_add_group_controller.dart';

class ManageSentencePyramidAddGroupView extends GetView<ManageSentencePyramidAddGroupController> {
  final String tagText;
  const ManageSentencePyramidAddGroupView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_SENTENCE_PYRAMID_ADD_GROUP}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageSentencePyramidAddGroupView(tagText: tag),
      binding: ManageSentencePyramidAddGroupBinding(tag: tag),
      routeName: Routes.MANAGE_SENTENCE_PYRAMID_ADD_GROUP,
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
          children: <Widget>[
            SizedBox(height: 32.wMin),
            ManageSentenceAddTitleWidget(),
            SizedBox(height: 32.wMin),
            ManageSentenceAddTableWidget(
              subTitle: "先看骨架。锁上基句后，这句占用的槽会亮起（不能改）。再点其他可选槽往上长。",
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
                children: <Widget>[
                  ManageSentenceAddBingListWidget(
                    itemCount: cardList.length,
                    itemBuilder: (int index) {
                      final ManageSentenceAddBindingCardModel model = cardList[index];
                      final String slotKey = model.cellKey ?? '';
                      final bool isBaseSentenceCard = slotKey == 'layer_0';
                      return ManageSentenceAddBingWidget(
                        index: index,
                        title: model.title,
                        centerWidget: ManageSentenceAddBingSentenceWidget(model: model),
                        hasSentence: model.sentence != null,
                        pickSentence: () {
                          if (isBaseSentenceCard) {
                            controller.lockBaseSentence();
                            return;
                          }
                          controller.pickSentence(context, slotKey);
                        },
                        inputUid: () {
                          if (isBaseSentenceCard) {
                            controller.lockBaseSentence();
                            return;
                          }
                          controller.manualInputUid(context, slotKey);
                        },
                        clearSentence: () {
                          if (isBaseSentenceCard) {
                            controller.clearBaseSentence();
                            return;
                          }
                          controller.boundSentenceMap.remove(slotKey);
                        },
                      );
                    },
                  ),
                  if (!isShapeLocked) _buildBindingHintWidget(),
                ],
              );
            }),
            SizedBox(height: 200.wMin),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() {
        return ManageSentenceAddButtonsWidget(
          bindCount: controller.bindCount,
          totalCount: controller.totalCount,
          addSentence: controller.addSentence,
          fullSentence: controller.fullSentence,
          isAddSentenceEnabled: controller.isAddSentenceEnabled,
          isFullSentenceEnabled: controller.isFullSentenceEnabled,
        );
      }),
    );
  }

  /// 金字塔骨架与基句锁定区。
  Widget _buildSlotWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (controller.shapeLockData.hasShapeLock) _buildShapeLockHintWidget(),
        Obx(() {
          return ManageSentenceBlueprintAddGroupSlotMapWidget(
            patternBlueprint: controller.patternBlueprint,
            checkedSlotKeys: controller.checkedSlotKeys,
            dialSlotKeys: controller.growthSlotKeys.toList(),
            occupiedSlotKeys: controller.baseOccupancySlotKeys.toList(),
            unusedSlotKeys: controller.disabledOptionalSlotKeys,
            showSelectControl: controller.hasLockedBaseSentence,
            onSlotTap: controller.onGrowthSlotTap,
          );
        }),
        SizedBox(height: 16.wMin),
        Row(
          children: <Widget>[
            SizedBox(
              width: 320.wMin,
              child: _buildBaseSentenceInputWidget(),
            ),
            SizedBox(width: 16.wMin),
            _buildBaseActionButton(
              text: "锁定基句",
              onTap: controller.lockBaseSentence,
            ),
            Obx(() {
              if (!controller.hasLockedBaseSentence) {
                return const SizedBox.shrink();
              }
              return Row(
                children: <Widget>[
                  SizedBox(width: 16.wMin),
                  _buildBaseActionButton(
                    text: "清空",
                    isPrimary: false,
                    onTap: controller.clearBaseSentence,
                  ),
                ],
              );
            }),
          ],
        ),
        SizedBox(height: 12.wMin),
        Obx(() {
          final PatternBlueprintSentenceBriefEntity? sentence = controller.baseSentence.value;
          if (sentence == null) {
            return Text(
              controller.shapeLockData.type == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID.rawValue
                  ? "先锁基句，增长层会按单元锁定自动生效。"
                  : "基句锁上之后，占用槽会亮起，才能点要长的槽。",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w400,
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ManageSentenceAddBingSentenceWidget(
                alignment: Alignment.centerLeft,
                model: ManageSentenceAddBindingCardModel(
                  index: 0,
                  title: "基句",
                  sentence: sentence,
                  patternBlueprint: controller.patternBlueprint,
                ),
              ),
              Obx(() {
                if (!controller.hasLockedBaseSentence) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.only(top: 10.wMin),
                  child: Text(
                    "□ 基句占用 · ○ 往上长的槽。先锁基句，再点还没亮的可选槽往上长。",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: AppTheme.cTextTertiary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  /// 基句输入框。
  Widget _buildBaseSentenceInputWidget() {
    return Container(
      height: 54.wMin,
      padding: EdgeInsets.symmetric(horizontal: 14.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 0.8.wMin,
        ),
      ),
      child: Center(
        child: TextField(
          controller: controller.pyramidBaseIdController,
          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,
            hintText: "输入基句 uid",
            hintStyle: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          onSubmitted: (_) {
            controller.lockBaseSentence();
          },
        ),
      ),
    );
  }

  /// 基句操作按钮。
  Widget _buildBaseActionButton({
    required String text,
    required VoidCallback onTap,
    bool isPrimary = true,
  }) {
    return ButtonWidget(
      text: text,
      height: 54.wMin,
      width: 130.wMin,
      color: isPrimary ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.12) : AppTheme.cSurfaceLayerBase.color,
      border: Border.all(
        width: 0.8.wMin,
        color: isPrimary ? AppTheme.cSurfaceBrand.color : AppTheme.cBorderSubtle.color,
      ),
      fontSize: 20.wMin,
      fontColor: isPrimary ? AppTheme.cSurfaceBrand.color : AppTheme.cTextSecondary.color,
      fontWeight: FontWeight.w500,
      sclae: 1.03,
      onTap: onTap,
    );
  }

  /// 绑句区还未出现时的统一提示。
  Widget _buildBindingHintWidget() {
    String text = "先锁基句，再点要长的槽。";
    if (!controller.hasLockedBaseSentence && controller.shapeLockData.type == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID.rawValue) {
      text = "先锁基句，增长层会按单元锁定自动出格。";
    } else if (controller.hasLockedBaseSentence && controller.pyramidLockConflictSlotKeys.isNotEmpty) {
      text = "当前基句占用了锁定增长槽，换一句基句后层句卡片才会出来。";
    } else if (controller.hasLockedBaseSentence && controller.growthSlotKeys.isEmpty) {
      text = controller.shapeLockData.type == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID.rawValue
          ? "当前增长层由单元锁定；基句通过后卡片会自动出现。"
          : "再点骨架上要往上长的槽，层句卡片才会出来。";
    }
    return Container(
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
        text,
        style: TextStyle(
          fontSize: 18.wMin,
          color: AppTheme.cTextSecondary.color,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  /// Target 入口下的形态锁提示。
  Widget _buildShapeLockHintWidget() {
    final List<String> activatedNames = controller.shapeLockData.activatedOptionalSlotKeys
        .map((key) => _resolveSlotDisplayName(controller.patternBlueprint, key))
        .where((item) => item.isNotEmpty)
        .toList();
    final String targetTitle = controller.shapeLockData.targetTitle?.isNotEmpty == true
        ? controller.shapeLockData.targetTitle!
        : "Target ${controller.shapeLockData.targetUid ?? ''}";
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
        children: <Widget>[
          Row(
            children: <Widget>[
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
              SizedBox(width: 8.wMin),
              Expanded(
                child: Text(
                  targetTitle,
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.wMin),
          Text(
            "增长槽按 Target 固定：${activatedNames.isNotEmpty ? activatedNames.join(' → ') : '当前层级'}；只需锁基句，再逐层绑句。",
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// 解析槽位展示名，优先走 openSlotList，其次回退 slotKey。
  String _resolveSlotDisplayName(PatternBlueprintEntity? patternBlueprint, String slotKey) {
    for (final PatternBlueprintOpenSlotListItemEntity? item
        in patternBlueprint?.openSlotList ?? const <PatternBlueprintOpenSlotListItemEntity?>[]) {
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
