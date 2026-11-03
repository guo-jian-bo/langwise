import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/superposition_text_widget.dart';
import '../../../../../../../common/widgets/tap_scale_widget.dart';
import '../../../../../../../common/widgets/zhenxie_widgets/sentence_slot_map_model.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';

/// “添加一组”页的 Target 形态锁数据。
class ManageSentenceBlueprintAddGroupShapeLockData {
  /// 来源 Target uid。
  final int? targetUid;

  /// 来源 Target 类型。
  final String? type;

  /// 来源 Target 标题。
  final String? targetTitle;

  /// 当前已被 Target 激活并固定纳入的可选槽。
  final List<String> activatedOptionalSlotKeys;

  /// 当前被 Target 禁止再加入的可选槽。
  final List<String> forbiddenSlotKeys;

  /// 当前是否还允许继续加入其他可选槽。
  final bool allowAdditionalOptionalSlots;

  const ManageSentenceBlueprintAddGroupShapeLockData({
    this.targetUid,
    this.type,
    this.targetTitle,
    this.activatedOptionalSlotKeys = const [],
    this.forbiddenSlotKeys = const [],
    this.allowAdditionalOptionalSlots = true,
  });

  /// 当前页面是否真的带着 Target 形态锁进入。
  bool get hasShapeLock => targetUid != null;
}

/// “添加一组”骨架区使用的槽位规则工具。
class ManageSentenceBlueprintAddGroupSlotMapHelper {
  /// 基于 Target 与蓝图编辑态信息，推导当前页面需要的形态锁数据。
  static ManageSentenceBlueprintAddGroupShapeLockData buildShapeLockData({
    required PatternBlueprintEntity? patternBlueprint,
    required ManageUnitGrammarTargetDetailEntity? target,
  }) {
    if (target == null) {
      return const ManageSentenceBlueprintAddGroupShapeLockData();
    }
    final String? type = target.grammarUnifiedInfo?.type;
    final String? targetTitle = LearningLangUtils.getLocalLang(target.title)?.text;
    final List<PatternBlueprintEditOptionSlotEntity> optionSlots = _collectEditOptionSlots(patternBlueprint);
    final Set<String> optionalOpenSlotKeySet = _optionalOpenSlotKeys(patternBlueprint ?? PatternBlueprintEntity()).toSet();
    if (optionSlots.isEmpty || optionalOpenSlotKeySet.isEmpty) {
      return ManageSentenceBlueprintAddGroupShapeLockData(
        targetUid: target.uid,
        type: type,
        targetTitle: targetTitle,
      );
    }
    final List<String> activatedOptionalSlotKeys = [];
    final List<String> forbiddenSlotKeys = [];
    bool allowAdditionalOptionalSlots = false;
    bool hasOptionalCandidate = false;
    for (final PatternBlueprintEditOptionSlotEntity slot in optionSlots) {
      final String key = (slot.slotKey ?? '').trim();
      if (key.isEmpty || slot.required == true || !optionalOpenSlotKeySet.contains(key)) {
        continue;
      }
      hasOptionalCandidate = true;
      if (slot.selected == true) {
        if (!activatedOptionalSlotKeys.contains(key)) {
          activatedOptionalSlotKeys.add(key);
        }
        continue;
      }
      if (slot.selectable == true && slot.unused != true) {
        allowAdditionalOptionalSlots = true;
        continue;
      }
      if (!forbiddenSlotKeys.contains(key)) {
        forbiddenSlotKeys.add(key);
      }
    }
    if (!hasOptionalCandidate) {
      allowAdditionalOptionalSlots = true;
    }
    return ManageSentenceBlueprintAddGroupShapeLockData(
      targetUid: target.uid,
      type: type,
      targetTitle: targetTitle,
      activatedOptionalSlotKeys: activatedOptionalSlotKeys,
      forbiddenSlotKeys: forbiddenSlotKeys,
      allowAdditionalOptionalSlots: allowAdditionalOptionalSlots,
    );
  }

  /// 当前默认固定纳入形态的槽。
  static List<String> getLockedFormSlotKeys(PatternBlueprintEntity? patternBlueprint) {
    final PatternBlueprintEntity? pattern = patternBlueprint;
    if (pattern == null) return const [];
    return _mergeSlotKeys(
      _controlledHoleKeys(pattern),
      _requiredOpenSlotKeys(pattern),
    );
  }

  /// 当前允许作为可选槽参与切换的开放槽。
  static List<String> getOptionalOpenSlotKeys(
    PatternBlueprintEntity? patternBlueprint, {
    ManageSentenceBlueprintAddGroupShapeLockData? shapeLockData,
  }) {
    final PatternBlueprintEntity? pattern = patternBlueprint;
    if (pattern == null) return const [];
    final List<String> optionalOpenSlotKeys = _optionalOpenSlotKeys(pattern);
    if (shapeLockData == null || !shapeLockData.hasShapeLock) {
      return optionalOpenSlotKeys;
    }
    final Set<String> activatedOptionalSlotKeySet = shapeLockData.activatedOptionalSlotKeys.toSet();
    final Set<String> forbiddenSlotKeySet = shapeLockData.forbiddenSlotKeys.toSet();
    return optionalOpenSlotKeys.where((key) {
      if (activatedOptionalSlotKeySet.contains(key)) {
        return true;
      }
      if (forbiddenSlotKeySet.contains(key)) {
        return false;
      }
      return shapeLockData.allowAdditionalOptionalSlots;
    }).toList();
  }

  /// 当前要按 unused 态显示并禁止点击的可选槽。
  static List<String> getDisabledOptionalSlotKeys(
    PatternBlueprintEntity? patternBlueprint, {
    ManageSentenceBlueprintAddGroupShapeLockData? shapeLockData,
  }) {
    final PatternBlueprintEntity? pattern = patternBlueprint;
    if (pattern == null || shapeLockData == null || !shapeLockData.hasShapeLock) {
      return const [];
    }
    final Set<String> availableOptionalSlotKeySet = getOptionalOpenSlotKeys(
      patternBlueprint,
      shapeLockData: shapeLockData,
    ).toSet();
    return _optionalOpenSlotKeys(pattern).where((key) => !availableOptionalSlotKeySet.contains(key)).toList();
  }

  /// 当前已纳入形态的所有槽。
  static List<String> getBaseSlotKeys({
    required PatternBlueprintEntity? patternBlueprint,
    required List<String> optionalBaseSlotKeys,
    ManageSentenceBlueprintAddGroupShapeLockData? shapeLockData,
  }) {
    return _mergeSlotKeys(
      getLockedFormSlotKeys(patternBlueprint),
      _mergeSlotKeys(
        shapeLockData?.activatedOptionalSlotKeys ?? const [],
        optionalBaseSlotKeys,
      ),
    );
  }

  /// 从句子结构里提取当前实际占用到的骨架槽，保持原始出现顺序。
  static List<String> collectOccupiedSlotKeys({
    required PatternBlueprintEntity? patternBlueprint,
    required List<PatternBlueprintSentenceBriefEntity?> sentences,
  }) {
    final List<String> resp = <String>[];
    final Set<String> seen = <String>{};
    void collect(List<PatternBlueprintSentenceBriefSegmentEntity?>? segmentList) {
      if (segmentList == null || segmentList.isEmpty) {
        return;
      }
      for (final PatternBlueprintSentenceBriefSegmentEntity? segment in segmentList) {
        if (segment == null) {
          continue;
        }
        final List<PatternBlueprintSentenceBriefSegmentEntity?>? childList = segment.childStruct?.segmentList;
        if (childList != null && childList.isNotEmpty) {
          collect(childList);
          continue;
        }
        final String key = _resolvePatternHoleKey(
          patternBlueprint,
          segment.renderSlotKey ?? segment.sourceSlotKey ?? segment.slotKey,
        );
        if (key.isEmpty || seen.contains(key)) {
          continue;
        }
        seen.add(key);
        resp.add(key);
      }
    }

    for (final PatternBlueprintSentenceBriefEntity? sentence in sentences) {
      collect(sentence?.segmentList);
    }
    return resp;
  }

  /// 新增可选槽时，把它依赖的其他可选槽一并带上。
  static List<String> addOptionalWithDeps({
    required PatternBlueprintEntity pattern,
    required List<String> selected,
    required String key,
  }) {
    if (selected.contains(key)) {
      return selected;
    }
    final Map<String, PatternBlueprintOpenSlotEntity?> openByKey = {
      for (final PatternBlueprintOpenSlotEntity? slot in pattern.openSlots ?? const [])
        if ((slot?.slotKey ?? '').trim().isNotEmpty) (slot!.slotKey!).trim(): slot,
    };
    final Set<String> optional = _optionalOpenSlotKeys(pattern).toSet();
    final List<String> deps = (openByKey[key]?.dependsOn ?? const [])
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty && optional.contains(item) && !selected.contains(item))
        .toList();
    return [
      ...selected,
      ...deps,
      key,
    ];
  }

  /// 取消可选槽时，顺带移除所有依赖它的可选槽。
  static List<String> removeOptionalWithDependents({
    required PatternBlueprintEntity pattern,
    required List<String> selected,
    required String key,
    List<String> protectedKeys = const [],
  }) {
    final Map<String, PatternBlueprintOpenSlotEntity?> openByKey = {
      for (final PatternBlueprintOpenSlotEntity? slot in pattern.openSlots ?? const [])
        if ((slot?.slotKey ?? '').trim().isNotEmpty) (slot!.slotKey!).trim(): slot,
    };
    return selected.where((item) {
      if (item == key) {
        return false;
      }
      if (protectedKeys.contains(item)) {
        return true;
      }
      final List<String> dependsOn =
          (openByKey[item]?.dependsOn ?? const []).whereType<String>().map((dep) => dep.trim()).where((dep) => dep.isNotEmpty).toList();
      return !dependsOn.contains(key);
    }).toList();
  }

  /// 拉平蓝图编辑态里的 optionSlots，方便外层复用。
  static List<PatternBlueprintEditOptionSlotEntity> _collectEditOptionSlots(PatternBlueprintEntity? patternBlueprint) {
    final List<PatternBlueprintEditOptionSlotEntity> resp = [];
    for (final PatternBlueprintEditSlotEntity? editSlot in patternBlueprint?.editSlots ?? const []) {
      for (final PatternBlueprintEditOptionSlotEntity? optionSlot in editSlot?.optionSlots ?? const []) {
        if (optionSlot == null) {
          continue;
        }
        resp.add(optionSlot);
      }
    }
    return resp;
  }

  /// 收口去重后的槽位 key 列表，保持原始顺序。
  static List<String> _mergeSlotKeys(
    Iterable<String> first,
    Iterable<String> second,
  ) {
    final List<String> resp = [];
    final Set<String> seen = <String>{};
    for (final String raw in [...first, ...second]) {
      final String key = raw.trim();
      if (key.isEmpty || seen.contains(key)) continue;
      seen.add(key);
      resp.add(key);
    }
    return resp;
  }

  /// 受控槽按 rendersAs 合并成一个骨架孔位。
  static List<String> _controlledHoleKeys(PatternBlueprintEntity pattern) {
    final List<String> resp = [];
    final Set<String> seen = <String>{};
    for (final PatternBlueprintControlledGrammarSlotEntity? slot in pattern.controlledGrammarSlots ?? const []) {
      final String key = (slot?.rendersAs ?? slot?.slotKey ?? '').trim();
      if (key.isEmpty || seen.contains(key)) continue;
      seen.add(key);
      resp.add(key);
    }
    return resp;
  }

  /// 蓝图里默认必含的开放槽。
  static List<String> _requiredOpenSlotKeys(PatternBlueprintEntity pattern) {
    final List<String> resp = [];
    for (final PatternBlueprintOpenSlotEntity? slot in pattern.openSlots ?? const []) {
      final String key = (slot?.slotKey ?? '').trim();
      if (key.isEmpty || slot?.required == false) continue;
      resp.add(key);
    }
    return resp;
  }

  /// 蓝图里允许按形态开关的可选开放槽。
  static List<String> _optionalOpenSlotKeys(PatternBlueprintEntity pattern) {
    final List<String> resp = [];
    for (final PatternBlueprintOpenSlotEntity? slot in pattern.openSlots ?? const []) {
      final String key = (slot?.slotKey ?? '').trim();
      if (key.isEmpty || slot?.required != false) continue;
      resp.add(key);
    }
    return resp;
  }

  /// 把受控槽的源 key / rendersAs key 统一折成同一个骨架孔位 key。
  static String _resolvePatternHoleKey(PatternBlueprintEntity? patternBlueprint, String? rawKey) {
    final String key = rawKey?.trim() ?? '';
    if (key.isEmpty || patternBlueprint == null) {
      return key;
    }
    for (final PatternBlueprintControlledGrammarSlotEntity? slot in patternBlueprint.controlledGrammarSlots ?? const []) {
      final String slotKey = slot?.slotKey?.trim() ?? '';
      final String rendersAs = slot?.rendersAs?.trim() ?? '';
      if (slotKey == key || rendersAs == key) {
        return rendersAs.isNotEmpty ? rendersAs : slotKey;
      }
    }
    return key;
  }
}

/// “添加一组”页的蓝图骨架区域。
///
/// 这份实现沿用 `SentenceSlotMapWidget` 的卡片视觉，只在左上角额外叠加
/// 形态选择控件（□ 纳入、○ 要拧），避免和公共槽位图出现两套风格。
class ManageSentenceBlueprintAddGroupSlotMapWidget extends StatefulWidget {
  /// 当前待操作的句型蓝图。
  final PatternBlueprintEntity? patternBlueprint;

  /// 当前已纳入形态的槽。
  final List<String> checkedSlotKeys;

  /// 当前要拧的槽。
  final List<String> dialSlotKeys;

  /// 当前要按 unused 态处理的槽。
  final List<String> unusedSlotKeys;

  /// 当前句子实际占用到、需要恢复成正常态的槽。
  final List<String> occupiedSlotKeys;

  /// 槽位点击回调。
  final void Function(SentenceSlotMapItemEntity item)? onSlotTap;

  /// 当前是否显示左上角选择控件。
  final bool showSelectControl;

  const ManageSentenceBlueprintAddGroupSlotMapWidget({
    super.key,
    this.patternBlueprint,
    this.checkedSlotKeys = const [],
    this.dialSlotKeys = const [],
    this.unusedSlotKeys = const [],
    this.occupiedSlotKeys = const [],
    this.onSlotTap,
    this.showSelectControl = true,
  });

  @override
  State<ManageSentenceBlueprintAddGroupSlotMapWidget> createState() =>
      _ManageSentenceBlueprintAddGroupSlotMapWidgetState();
}

class _ManageSentenceBlueprintAddGroupSlotMapWidgetState extends State<ManageSentenceBlueprintAddGroupSlotMapWidget> {
  @override
  Widget build(BuildContext context) {
    final PatternBlueprintEntity? pattern = widget.patternBlueprint;
    if (pattern == null) {
      return _buildEmptyWidget();
    }

    final SentenceSlotMapEntity slotMap = SentenceSlotMapUtils.buildFromPatternBlueprint(pattern);
    if (slotMap.items.isEmpty) {
      return _buildEmptyWidget();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cZhenxieBackgroundPrimary.color,
        border: Border.all(
          color: AppTheme.cZhenxieBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: slotMap.items.map(_buildItemWidget).toList(),
          ),
        ),
      ),
    );
  }

  /// 蓝图未就绪时的占位提示。
  Widget _buildEmptyWidget() {
    return Container();
  }

  /// 渲染模板中的单个槽位卡片。
  Widget _buildItemWidget(SentenceSlotMapItemEntity item) {
    final SentenceSlotMapItemEntity displayItem = _buildDisplayItem(item);
    final Color primaryColor = _resolvePrimaryColor(displayItem);
    final bool optionalOpen = displayItem.role == SentenceSlotMapRole.optionalOpen;
    final bool unused = _isUnusedItem(displayItem);
    Widget child = Container(
      margin: EdgeInsets.only(right: 6.wMin),
      padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        color: unused ? Colors.black.withValues(alpha: 0.2) : primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.wMin),
        border: optionalOpen
            ? null
            : Border.all(
                color: primaryColor.withValues(alpha: 0.2),
                width: 0.8.wMin,
              ),
      ),
      child: _buildItemContentWidget(item: displayItem, primaryColor: primaryColor),
    );

    if (unused) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(10.wMin),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ManageSentenceBlueprintAddUnusedHatchPainter(),
                ),
              ),
            ),
            child,
          ],
        ),
      );
      child = DottedBorder(
        color: Colors.white.withValues(alpha: 0.12),
        strokeWidth: 0.8.wMin,
        dashPattern: [3.wMin, 1.5.wMin],
        borderType: BorderType.RRect,
        radius: Radius.circular(10.wMin),
        padding: EdgeInsets.zero,
        child: child,
      );
    } else if (optionalOpen) {
      child = DottedBorder(
        color: primaryColor.withValues(alpha: 0.45),
        strokeWidth: 0.8.wMin,
        dashPattern: [3.wMin, 1.5.wMin],
        borderType: BorderType.RRect,
        radius: Radius.circular(10.wMin),
        padding: EdgeInsets.zero,
        child: child,
      );
    }

    return _buildTapWidget(item: displayItem, child: child);
  }

  /// 选择态只在“添加一组”页生效，视觉仍然贴着公共槽位图的排版。
  Widget _buildItemContentWidget({
    required SentenceSlotMapItemEntity item,
    required Color primaryColor,
  }) {
    final bool unused = _isUnusedItem(item);
    final bool checked = widget.checkedSlotKeys.contains(item.slotKey);
    final bool dialMarked = widget.dialSlotKeys.contains(item.slotKey);
    final Color labelColor = unused ? Colors.transparent : primaryColor.withValues(alpha: 0.45);
    final Color textColor = unused ? Colors.transparent : primaryColor.withValues(alpha: 0.3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!item.isLiteral && widget.showSelectControl)
              _buildSelectControlWidget(
                checked: checked,
                dialMarked: dialMarked,
              ),
            _buildGrowthBadgeWidget(item: item, primaryColor: primaryColor),
            SuperpositionTextWidget(
              text: item.label,
              foregroundColor: labelColor,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextSecondary.color.withValues(
                  alpha: unused ? 0.4 : 1,
                ),
              ),
            ),
            _buildCtrlTagWidget(item: item, primaryColor: primaryColor),
          ],
        ),
        SizedBox(height: 4.wMin),
        SuperpositionTextWidget(
          text: item.text,
          foregroundColor: textColor,
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color.withValues(
              alpha: unused ? 0.4 : 1,
            ),
            decoration: unused ? TextDecoration.lineThrough : null,
            decorationColor: AppTheme.cTextPrimary.color.withValues(
              alpha: unused ? 0.4 : 1,
            ),
          ),
        ),
      ],
    );
  }

  /// 左上角选择控件：□ 表示纳入形态，○ 表示要拧。
  ///
  /// 图标统一使用 `AppTheme.cTextPrimary.color`，适配黑白两版主题。
  Widget _buildSelectControlWidget({
    required bool checked,
    required bool dialMarked,
  }) {
    final Color iconColor = AppTheme.cTextPrimary.color;
    final Color inactiveBorder = iconColor.withValues(alpha: 0.28);
    final Color activeBorder = iconColor.withValues(alpha: 0.9);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16.wMin,
          height: 16.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3.wMin),
            border: Border.all(
              color: checked ? activeBorder : inactiveBorder,
              width: 1.wMin,
            ),
            color: checked ? iconColor.withValues(alpha: 0.14) : Colors.transparent,
          ),
          alignment: Alignment.center,
          child: checked
              ? Icon(
                  Icons.check_rounded,
                  size: 12.wMin,
                  color: iconColor,
                )
              : null,
        ),
        SizedBox(width: 4.wMin),
        Container(
          width: 16.wMin,
          height: 16.wMin,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: dialMarked ? activeBorder : inactiveBorder,
              width: 1.wMin,
            ),
          ),
          alignment: Alignment.center,
          child: dialMarked
              ? Container(
                  width: 8.wMin,
                  height: 8.wMin,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor,
                  ),
                )
              : null,
        ),
        SizedBox(width: 4.wMin),
      ],
    );
  }

  /// 优先读取槽位配置颜色，字面量保持主文字色。
  Color _resolvePrimaryColor(SentenceSlotMapItemEntity item) {
    if (item.isLiteral) {
      return AppTheme.cTextPrimary.color;
    }
    return ColorUtils.parseColor(item.color) ?? AppTheme.cSurfaceBrand.color;
  }

  /// 把“被句子占槽恢复”的 item 修正成正常展示态。
  SentenceSlotMapItemEntity _buildDisplayItem(SentenceSlotMapItemEntity item) {
    if (!widget.occupiedSlotKeys.contains(item.slotKey) || !item.unused) {
      return item;
    }
    return SentenceSlotMapItemEntity(
      key: item.key,
      slotKey: item.slotKey,
      label: item.details?.blueprint?.roleLabel ?? _resolveRoleLabel(item.role),
      text: item.text,
      title: item.details?.blueprint?.displayName ?? item.text,
      role: item.role,
      color: item.color,
      showCtrl: item.showCtrl,
      unused: false,
      growthIndex: item.details?.blueprint?.growthIndex ?? item.growthIndex,
      isRenderAlias: item.isRenderAlias,
      sourceControlledKeys: item.sourceControlledKeys,
      dependsOnSlotKeys: item.dependsOnSlotKeys,
      details: item.details,
    );
  }

  /// 包装槽位点击交互。
  Widget _buildTapWidget({
    required SentenceSlotMapItemEntity item,
    required Widget child,
  }) {
    if (item.isLiteral || _isUnusedItem(item) || widget.onSlotTap == null) {
      return child;
    }

    return TapScaleWidget(
      sclae: 1,
      onTap: () {
        widget.onSlotTap?.call(_buildInteractiveItem(item));
      },
      child: child,
    );
  }

  /// 点击回调前统一把“被句子占槽恢复”的 item 修正成正常态。
  SentenceSlotMapItemEntity _buildInteractiveItem(SentenceSlotMapItemEntity item) {
    return _buildDisplayItem(item);
  }

  /// 统一判断当前槽位是否需要按 unused 态展示。
  bool _isUnusedItem(SentenceSlotMapItemEntity item) {
    if (!item.isLiteral && widget.occupiedSlotKeys.contains(item.slotKey)) {
      return false;
    }
    return !item.isLiteral && (item.unused || widget.unusedSlotKeys.contains(item.slotKey));
  }

  /// 将槽位角色映射为顶部标签文案。
  String _resolveRoleLabel(SentenceSlotMapRole role) {
    switch (role) {
      case SentenceSlotMapRole.controlled:
        return '受控';
      case SentenceSlotMapRole.requiredOpen:
        return '必填';
      case SentenceSlotMapRole.optionalOpen:
        return '可选';
      case SentenceSlotMapRole.literal:
        return '固定';
    }
  }

  /// 增长槽沿用公共槽位图的数字徽标。
  Widget _buildGrowthBadgeWidget({
    required SentenceSlotMapItemEntity item,
    required Color primaryColor,
  }) {
    if (item.growthIndex == null) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(
            minWidth: 18.wMin,
            minHeight: 18.wMin,
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.wMin),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(99),
          ),
          alignment: Alignment.center,
          child: Stack(
            children: [
              Text(
                "${item.growthIndex}",
                style: TextStyle(
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
              Text(
                "${item.growthIndex}",
                style: TextStyle(
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w500,
                  color: primaryColor.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 4.wMin),
      ],
    );
  }

  /// 受控槽保留 C 标记。
  Widget _buildCtrlTagWidget({
    required SentenceSlotMapItemEntity item,
    required Color primaryColor,
  }) {
    if (!item.showCtrl) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 4.wMin),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 1.wMin),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(4.wMin),
          ),
          child: Stack(
            children: [
              Text(
                "C",
                style: TextStyle(
                  fontSize: 12.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
              Text(
                "C",
                style: TextStyle(
                  fontSize: 12.wMin,
                  fontWeight: FontWeight.w500,
                  color: primaryColor.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 为 unused 槽位绘制原型中的斜线遮罩。
class _ManageSentenceBlueprintAddUnusedHatchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final RRect clip = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(10.wMin),
    );
    canvas.save();
    canvas.clipRRect(clip);
    final Paint paint = Paint()
      ..color = AppTheme.cTextPrimary.color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.wMin;
    final double spacing = 10.wMin;
    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(
    covariant _ManageSentenceBlueprintAddUnusedHatchPainter oldDelegate,
  ) {
    return false;
  }
}
