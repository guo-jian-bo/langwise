import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../bindings/manage_unit_grammar_add_binding.dart';
import '../controllers/manage_unit_grammar_add_controller.dart';

class ManageUnitGrammarAddView extends GetView<ManageUnitGrammarAddController> {
  final String tagText;
  const ManageUnitGrammarAddView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static const List<Map<String, String>> _steps = [
    {
      "id": "1",
      "label": "选材料",
      "hint": "句 KP / 句组",
    },
    {
      "id": "2",
      "label": "召回",
      "hint": "代码列资产",
    },
    {
      "id": "3",
      "label": "勾资产",
      "hint": "人勾 kind+nid",
    },
    {
      "id": "4",
      "label": "追加",
      "hint": "异步任务",
    },
  ];

  static Future<T?> to<T>({
    dynamic arguments,
  }) async {
    final tag = '${Routes.MANAGE_UNIT_GRAMMAR_ADD}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageUnitGrammarAddView(tagText: tag),
      binding: ManageUnitGrammarAddBinding(tag: tag),
      routeName: Routes.MANAGE_UNIT_GRAMMAR_ADD,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Obx(() {
        if (controller.isLoading.value && controller.sentenceList.isEmpty && controller.groupList.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: EdgeInsets.fromLTRB(
            90.wMin,
            24.wMin,
            90.wMin,
            24.wMin + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleWidget(),
              SizedBox(height: 20.wMin),
              _buildStepsWidget(),
              SizedBox(height: 24.wMin),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildMaterialsPanel()),
                    SizedBox(width: 24.wMin),
                    Expanded(child: _buildRecallPanel()),
                  ],
                ),
              ),
              SizedBox(height: 24.wMin),
              _buildBottomActionsWidget(),
            ],
          ),
        );
      }),
    );
  }

  /// 页面标题区。
  Widget _buildTitleWidget() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "从本单元句子追加语法点",
                style: TextStyle(
                  fontSize: 34.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              SizedBox(height: 6.wMin),
              Text(
                "不是 Hub 全单元 analyze。代码召回，人勾资产，再追加 candidate。",
                style: TextStyle(
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
            ],
          ),
        ),
        if (controller.unitName.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18.wMin, vertical: 10.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              color: AppTheme.cSurfaceLayerElevated.color,
              border: Border.all(
                width: 1.wMin,
                color: AppTheme.cBorderPrimary.color,
              ),
            ),
            child: Text(
              controller.unitName,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ),
      ],
    );
  }

  /// 步骤条。
  Widget _buildStepsWidget() {
    return Row(
      children: List.generate(_steps.length, (index) {
        final Map<String, String> step = _steps[index];
        final int stepId = int.parse(step["id"]!);
        final String state = controller.buildStepStateLabel(stepId);
        final bool isActive = state == "active";
        final bool isDone = state == "done";
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.wMin,
                    vertical: 14.wMin,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: _buildStepBackgroundColor(isActive, isDone),
                    border: Border.all(
                      width: 1.wMin,
                      color: _buildStepBorderColor(isActive, isDone),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        step["id"]!,
                        style: TextStyle(
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w600,
                          color: _buildStepAccentColor(isActive, isDone),
                        ),
                      ),
                      SizedBox(width: 10.wMin),
                      Expanded(
                        child: Text(
                          step["label"]!,
                          style: TextStyle(
                            fontSize: 18.wMin,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.cTextPrimary.color,
                          ),
                        ),
                      ),
                      Text(
                        step["hint"]!,
                        style: TextStyle(
                          fontSize: 14.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextTertiary.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (index != _steps.length - 1)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                  child: Text(
                    "→",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: AppTheme.cTextTertiary.color,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  /// 左侧材料区。
  Widget _buildMaterialsPanel() {
    return _buildPanelShell(
      child: Column(
        children: [
          _buildPanelHeader(
            title: "① 材料",
            desc: "knowledgeUids = 句 KP uid · setUids = 签发组 uid（成员会展开进召回）",
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextAction(
                  text: "全选句子",
                  onTap: controller.selectAllSentences,
                  isPrimary: true,
                ),
                SizedBox(width: 18.wMin),
                _buildTextAction(
                  text: "清空",
                  onTap: controller.clearMaterials,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.wMin, 20.wMin, 20.wMin, 20.wMin),
              children: [
                _buildPanelCaption("本单元句子 ${controller.sentenceList.length}"),
                ...controller.sentenceList.map(_buildSentenceItemWidget),
                SizedBox(height: 20.wMin),
                _buildPanelCaption("句组 ${controller.groupList.length} · 可选，召回会带上 assetType+assetNid"),
                if (controller.groupList.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 10.wMin),
                    child: Text(
                      "本单元句子还没有签发组。句组不是必选。",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextTertiary.color,
                      ),
                    ),
                  ),
                ...controller.groupList.map(_buildGroupItemWidget),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceItemWidget(CourseUnitTargetSentenceGrammarSentenceEntity item) {
    final int uid = item.unitKnowledgeId ?? 0;
    final bool isSelected = controller.selectedKnowledgeUids.contains(uid);
    return Padding(
      padding: EdgeInsets.only(top: 10.wMin),
      child: TapScaleWidget(
        onTap: uid > 0 ? () => controller.toggleSentence(uid) : null,
        sclae: 1.01,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 14.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.wMin),
            color: isSelected ? AppTheme.cSurfaceInfo.color.withValues(alpha: 0.18) : AppTheme.cSurfaceLayerElevated.color,
            border: Border.all(
              width: 1.wMin,
              color: isSelected ? AppTheme.cSurfaceInfo.color.withValues(alpha: 0.5) : AppTheme.cBorderPrimary.color,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckWidget(isSelected),
              SizedBox(width: 14.wMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.content ?? "",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                    SizedBox(height: 6.wMin),
                    Text(
                      controller.buildSentenceLineText(item),
                      style: TextStyle(
                        fontSize: 15.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextTertiary.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupItemWidget(CourseUnitTargetSentenceGrammarGroupEntity item) {
    final int uid = item.uid ?? 0;
    final bool isSelected = controller.selectedSetUids.contains(uid);
    final String? assetType = controller.buildGroupAssetType(item);
    final String? assetNid = controller.buildGroupAssetNid(item);
    final int memberCount = controller.buildGroupMemberCount(item);
    return Padding(
      padding: EdgeInsets.only(top: 10.wMin),
      child: TapScaleWidget(
        onTap: uid > 0 ? () => controller.toggleGroup(uid) : null,
        sclae: 1.01,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 14.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.wMin),
            color: isSelected ? AppTheme.cSurfaceInfo.color.withValues(alpha: 0.18) : AppTheme.cSurfaceLayerElevated.color,
            border: Border.all(
              width: 1.wMin,
              color: isSelected ? AppTheme.cSurfaceInfo.color.withValues(alpha: 0.5) : AppTheme.cBorderPrimary.color,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckWidget(isSelected),
              SizedBox(width: 14.wMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.buildGroupTitle(item),
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                    SizedBox(height: 6.wMin),
                    Text(
                      "set $uid · ${assetType ?? '--'}/${assetNid ?? '--'} · $memberCount 句",
                      style: TextStyle(
                        fontSize: 15.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextTertiary.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 右侧召回区。
  Widget _buildRecallPanel() {
    final List<CourseUnitTargetAddGrammarRecallAssetEntity> checkedAssets = controller.buildCheckedAppendAssets();
    final Map<String, List<CourseUnitTargetAddGrammarRecallAssetEntity>> recallGroupMap = controller.buildRecallAssetGroupMap();
    return _buildPanelShell(
      child: Column(
        children: [
          _buildPanelHeader(
            title: "②③ 召回结果",
            desc: "同步口；alreadyPresent = 本单元已有同 kind+nid 的 candidate/approved。空名单仍 200。",
            trailing: controller.hasRecallResult() && controller.recalledAssets.isNotEmpty
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextAction(
                        text: "全选",
                        onTap: controller.selectAllRecallAssets,
                        isPrimary: true,
                      ),
                      SizedBox(width: 18.wMin),
                      _buildTextAction(
                        text: "全不选",
                        onTap: controller.clearAllRecallAssets,
                      ),
                    ],
                  )
                : null,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.wMin, 20.wMin, 20.wMin, 20.wMin),
              children: [
                if (controller.hasRecallStale())
                  _buildNoticeWidget(
                    text: "材料已改，请重新召回。",
                    color: AppTheme.cSurfaceWarning.color,
                    backgroundOpacity: 0.12,
                    borderOpacity: 0.24,
                  ),
                if (controller.errorText.value.isNotEmpty)
                  _buildNoticeWidget(
                    text: controller.errorText.value,
                    color: AppTheme.cSurfaceError.color,
                    backgroundOpacity: 0.12,
                    borderOpacity: 0.24,
                  ),
                if (controller.taskStart.value != null)
                  _buildNoticeWidget(
                    text:
                        "Task ${controller.taskStart.value?.status ?? ''} · ${controller.taskStart.value?.taskName ?? ''}${controller.taskStart.value?.taskId != null ? ' · ${controller.taskStart.value!.taskId}' : ''}",
                    color: AppTheme.cTextSecondary.color,
                    backgroundOpacity: 0.05,
                    borderOpacity: 0.14,
                  ),
                if (controller.doneText.value.isNotEmpty)
                  _buildNoticeWidget(
                    text: controller.doneText.value,
                    color: AppTheme.cSurfaceSuccess.color,
                    backgroundOpacity: 0.12,
                    borderOpacity: 0.24,
                  ),
                if (!controller.hasRecallResult())
                  Padding(
                    padding: EdgeInsets.only(top: 18.wMin),
                    child: Text(
                      "点底栏「召回可教点」。名单来自句 patternNid，以及句组的 assetType+assetNid；配链 / 对照 / 分叉 / 全景只要成员句型撞上也会出现。",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        height: 1.6,
                        color: AppTheme.cTextSecondary.color,
                      ),
                    ),
                  ),
                if (controller.hasRecallResult() && controller.recalledAssets.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 18.wMin),
                    child: Text(
                      "召回空名单。这些句没有 patternNid，也没有可展开的组资产。",
                      style: TextStyle(
                        fontSize: 16.wMin,
                        height: 1.6,
                        color: AppTheme.cTextSecondary.color,
                      ),
                    ),
                  ),
                ...recallGroupMap.entries.expand((entry) {
                  return [
                    _buildRecallGroupHeaderWidget(
                      kind: entry.key,
                      count: entry.value.length,
                    ),
                    ...entry.value.map(_buildAssetItemWidget),
                  ];
                }),
                if (controller.recalledSentenceIds.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 16.wMin),
                    child: Text(
                      "展开后的 sentenceIds：${controller.recalledSentenceIds.join(', ')}",
                      style: TextStyle(
                        fontSize: 14.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextTertiary.color,
                      ),
                    ),
                  ),
                if (controller.recalledAssets.length > 1 && checkedAssets.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 16.wMin),
                    child: Text(
                      "召回多条资产，请勾选后再追加。",
                      style: TextStyle(
                        fontSize: 15.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cSurfaceWarning.color,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecallGroupHeaderWidget({
    required String kind,
    required int count,
  }) {
    final Color accentColor = _buildAssetAccentColor(kind);
    final String label = kind.isNotEmpty ? _buildKindLabel(kind) : "未分类";
    return Padding(
      padding: EdgeInsets.only(top: 16.wMin),
      child: Row(
        children: [
          Container(
            width: 4.wMin,
            height: 18.wMin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: accentColor,
            ),
          ),
          SizedBox(width: 10.wMin),
          Text(
            "$label $count",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetItemWidget(CourseUnitTargetAddGrammarRecallAssetEntity item) {
    final String kind = item.kind ?? "";
    final String nid = item.nid ?? "";
    final bool alreadyPresent = item.alreadyPresent == true;
    final bool isChecked = controller.isAssetChecked(kind, nid);
    final Color accentColor = _buildAssetAccentColor(kind);
    return Padding(
      padding: EdgeInsets.only(top: 12.wMin),
      child: TapScaleWidget(
        onTap: (kind.isNotEmpty && nid.isNotEmpty)
            ? () => controller.toggleAsset(
                  kind,
                  nid,
                  alreadyPresent: alreadyPresent,
                )
            : null,
        sclae: 1.01,
        child: Opacity(
          opacity: alreadyPresent ? 0.6 : 1,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 14.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.wMin),
              color:
                  isChecked && !alreadyPresent ? AppTheme.cSurfaceInfo.color.withValues(alpha: 0.18) : AppTheme.cSurfaceLayerElevated.color,
              border: Border.all(
                width: 1.wMin,
                color: isChecked && !alreadyPresent ? AppTheme.cSurfaceInfo.color.withValues(alpha: 0.5) : AppTheme.cBorderPrimary.color,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCheckWidget(isChecked && !alreadyPresent),
                SizedBox(width: 14.wMin),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8.wMin,
                        runSpacing: 8.wMin,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.wMin,
                              vertical: 6.wMin,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(99),
                              color: accentColor.withValues(alpha: 0.12),
                              border: Border.all(
                                width: 1.wMin,
                                color: accentColor.withValues(alpha: 0.24),
                              ),
                            ),
                            child: Text(
                              _buildKindLabel(kind),
                              style: TextStyle(
                                fontSize: 14.wMin,
                                fontWeight: FontWeight.w600,
                                color: accentColor,
                              ),
                            ),
                          ),
                          Text(
                            item.name ?? item.nid ?? "",
                            style: TextStyle(
                              fontSize: 18.wMin,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.cTextPrimary.color,
                            ),
                          ),
                          if (alreadyPresent)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.wMin,
                                vertical: 6.wMin,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(99),
                                color: AppTheme.cSurfaceLayerElevated.color,
                              ),
                              child: Text(
                                "已在本单元",
                                style: TextStyle(
                                  fontSize: 13.wMin,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.cTextTertiary.color,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8.wMin),
                      Text(
                        "$kind/$nid · 命中 ${(item.hitSentenceIds ?? const <int?>[]).whereType<int>().length} 句${_buildHitSentenceSuffix(item)}",
                        style: TextStyle(
                          fontSize: 15.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextTertiary.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 底部操作区。
  Widget _buildBottomActionsWidget() {
    final bool canRecall = !controller.isRecalling.value &&
        !controller.isAppending.value &&
        (controller.selectedKnowledgeUids.isNotEmpty || controller.selectedSetUids.isNotEmpty);
    final bool canAppend = controller.canRunAppend();
    return Align(
      alignment: Alignment.centerRight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.all(8.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: AppTheme.cBgPrimary.color.withValues(alpha: 0.8),
              border: Border.all(
                width: 1.wMin,
                color: AppTheme.cBorderPrimary.color,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionButton(
                  text: controller.isRecalling.value ? "召回中" : "召回可教点",
                  onTap: canRecall
                      ? () {
                          controller.runRecall();
                        }
                      : null,
                ),
                SizedBox(width: 10.wMin),
                _buildActionButton(
                  text: controller.isAppending.value ? "追加中" : "追加到本单元",
                  onTap: canAppend
                      ? () {
                          controller.runAppend();
                        }
                      : null,
                  isPrimary: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback? onTap,
    bool isPrimary = false,
  }) {
    final Color color = isPrimary ? AppTheme.cSurfaceInfo.color : AppTheme.cSurfaceLayerElevated.color;
    final Color fontColor = isPrimary ? AppTheme.cInverseTextLight.color : AppTheme.cTextPrimary.color;
    return Opacity(
      opacity: onTap == null ? 0.45 : 1,
      child: TapScaleWidget(
        onTap: onTap,
        sclae: 1.02,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: color,
            border: Border.all(
              width: 1.wMin,
              color: isPrimary ? AppTheme.cSurfaceInfo.color : AppTheme.cBorderPrimary.color,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w600,
              color: fontColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanelShell({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.wMin),
        color: AppTheme.cBgSecondary.color,
        border: Border.all(
          width: 1.wMin,
          color: AppTheme.cBorderPrimary.color,
        ),
      ),
      child: child,
    );
  }

  Widget _buildPanelHeader({
    required String title,
    required String desc,
    Widget? trailing,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 18.wMin),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1.wMin,
            color: AppTheme.cBorderPrimary.color,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
                SizedBox(height: 6.wMin),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 15.wMin,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary.color,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: 16.wMin),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _buildPanelCaption(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.wMin,
        fontWeight: FontWeight.w600,
        color: AppTheme.cTextTertiary.color,
      ),
    );
  }

  Widget _buildTextAction({
    required String text,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.02,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w500,
          color: isPrimary ? AppTheme.cTextBrand.color : AppTheme.cTextSecondary.color,
        ),
      ),
    );
  }

  Widget _buildCheckWidget(bool isSelected) {
    return Padding(
      padding: EdgeInsets.only(top: 2.wMin),
      child: SizedBox(
        width: 24.wMin,
        height: 24.wMin,
        child: SvgPicture.asset(
          isSelected ? "assets/svg/public/icon_check_box.svg" : "assets/svg/public/icon_uncheck_box.svg",
          width: 24.wMin,
          height: 24.wMin,
        ),
      ),
    );
  }

  Widget _buildNoticeWidget({
    required String text,
    required Color color,
    required double backgroundOpacity,
    required double borderOpacity,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 14.wMin),
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: color.withValues(alpha: backgroundOpacity),
        border: Border.all(
          width: 1.wMin,
          color: color.withValues(alpha: borderOpacity),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15.wMin,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  String _buildKindLabel(String kind) {
    if (kind == "pattern") return "句型蓝图";
    if (kind == "pyramid") return "句子金字塔";
    if (kind == "paradigm") return "句型对照";
    if (kind == "pair") return "句间配链";
    if (kind == "pair_fork") return "配句分叉";
    if (kind == "grid") return "语法全景";
    return kind;
  }

  Color _buildAssetAccentColor(String kind) {
    if (kind == "pattern") return AppTheme.cTextBrand.color;
    if (kind == "pyramid") return const Color(0xFF9B5DE5);
    if (kind == "paradigm") return const Color(0xFFEC4899);
    if (kind == "pair") return const Color(0xFFFB7185);
    if (kind == "pair_fork") return const Color(0xFFF59E0B);
    if (kind == "grid") return const Color(0xFF8B5CF6);
    return AppTheme.cTextSecondary.color;
  }

  String _buildHitSentenceSuffix(CourseUnitTargetAddGrammarRecallAssetEntity item) {
    final List<int> ids = [];
    for (final value in item.hitSentenceIds ?? <int?>[]) {
      if (value == null || value <= 0) continue;
      ids.add(value);
    }
    if (ids.isEmpty) return "";
    return " ${ids.take(4).join(', ')}";
  }

  Color _buildStepBackgroundColor(bool isActive, bool isDone) {
    if (isActive) return AppTheme.cSurfaceInfo.color.withValues(alpha: 0.12);
    if (isDone) return AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.10);
    return AppTheme.cSurfaceLayerElevated.color;
  }

  Color _buildStepBorderColor(bool isActive, bool isDone) {
    if (isActive) return AppTheme.cSurfaceInfo.color.withValues(alpha: 0.24);
    if (isDone) return AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2);
    return AppTheme.cBorderPrimary.color;
  }

  Color _buildStepAccentColor(bool isActive, bool isDone) {
    if (isActive) return AppTheme.cSurfaceInfo.color;
    if (isDone) return AppTheme.cSurfaceSuccess.color;
    return AppTheme.cTextTertiary.color;
  }
}
