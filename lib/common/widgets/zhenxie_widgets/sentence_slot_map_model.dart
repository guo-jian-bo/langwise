import 'package:langwise/common/entities/entities.dart';

import '../../../utils/utils.dart';

part 'sentence_slot_map_utils.dart';

/// 槽位图中的槽位角色。
enum SentenceSlotMapRole {
  controlled,
  requiredOpen,
  optionalOpen,
  literal,
}

/// 槽位详情中的 category 信息。
class SentenceSlotMapCategoryDetailsEntity {
  final String? nid;
  final List<LanguageText?>? categoryName;
  final List<LanguageText?>? categoryDescription;

  const SentenceSlotMapCategoryDetailsEntity({
    this.nid,
    this.categoryName,
    this.categoryDescription,
  });

  List<LanguageText?>? get name => categoryName;

  List<LanguageText?>? get description => categoryDescription;
}

/// 受控槽详情中的单个可选项。
class SentenceSlotMapControlledOptionEntity {
  final String? value;
  final List<LanguageText?>? label;
  final List<LanguageText?>? description;
  final int? order;

  const SentenceSlotMapControlledOptionEntity({
    this.value,
    this.label,
    this.description,
    this.order,
  });
}

/// 受控槽详情卡片数据。
class SentenceSlotMapControlledVariantEntity {
  final String? slotKey;
  final String? rendersAs;
  final PatternBlueprintNamedInfoEntity? slot;
  final List<PatternBlueprintNamedInfoEntity?>? activationFeatures;
  final List<SentenceSlotMapControlledOptionEntity> options;

  const SentenceSlotMapControlledVariantEntity({
    this.slotKey,
    this.rendersAs,
    this.slot,
    this.activationFeatures,
    this.options = const [],
  });
}

/// 蓝图槽位弹窗所需详情。
class SentenceSlotMapBlueprintDetailsEntity {
  final String? patternNid;
  final String? slotKey;
  final PatternBlueprintNamedInfoEntity? slot;
  final String? displayName;
  final String? roleLabel;
  final int? growthIndex;
  final bool isRenderAlias;
  final List<String> sourceControlledKeys;
  final List<PatternBlueprintNamedInfoEntity?> sourceControlledSlots;
  final List<PatternBlueprintNamedInfoEntity?> dependsOnSlots;
  final PatternBlueprintOpenSlotListItemEntity? openSlot;
  final List<SentenceSlotMapControlledVariantEntity> controlledVariants;
  final SentenceSlotMapCategoryDetailsEntity? category;

  const SentenceSlotMapBlueprintDetailsEntity({
    this.patternNid,
    this.slotKey,
    this.slot,
    this.displayName,
    this.roleLabel,
    this.growthIndex,
    this.isRenderAlias = false,
    this.sourceControlledKeys = const [],
    this.sourceControlledSlots = const [],
    this.dependsOnSlots = const [],
    this.openSlot,
    this.controlledVariants = const [],
    this.category,
  });
}

/// 单个槽位项附带的详情数据。
class SentenceSlotMapItemDetailsEntity {
  final SentenceSlotMapBlueprintDetailsEntity? blueprint;

  const SentenceSlotMapItemDetailsEntity({
    this.blueprint,
  });
}

/// 槽位图中的单个展示单元，供组件直接渲染。
class SentenceSlotMapItemEntity {
  final String key;
  final String slotKey;
  final String label;
  final String text;
  final String title;
  final SentenceSlotMapRole role;
  final String? color;
  final bool showCtrl;
  final bool unused;
  final int? growthIndex;
  final bool isRenderAlias;
  final List<String> sourceControlledKeys;
  final List<String> dependsOnSlotKeys;
  final SentenceSlotMapItemDetailsEntity? details;

  const SentenceSlotMapItemEntity({
    required this.key,
    required this.slotKey,
    required this.label,
    required this.text,
    required this.title,
    required this.role,
    this.color,
    this.showCtrl = false,
    this.unused = false,
    this.growthIndex,
    this.isRenderAlias = false,
    this.sourceControlledKeys = const [],
    this.dependsOnSlotKeys = const [],
    this.details,
  });

  /// 是否为模板中的固定字面量。
  bool get isLiteral => role == SentenceSlotMapRole.literal;
}

/// 槽位之间的 dependsOn 关系。
class SentenceSlotMapDependEdgeEntity {
  final String fromSlotKey;
  final String toSlotKey;
  final String fromLabel;
  final String toLabel;

  const SentenceSlotMapDependEdgeEntity({
    required this.fromSlotKey,
    required this.toSlotKey,
    required this.fromLabel,
    required this.toLabel,
  });
}

/// 通用句型槽位图实体。
///
/// 组件本身只依赖这个实体；上游可自行组装，也可复用
class SentenceSlotMapEntity {
  final List<SentenceSlotMapItemEntity> items;
  final List<SentenceSlotMapDependEdgeEntity> dependEdges;

  const SentenceSlotMapEntity({
    required this.items,
    this.dependEdges = const [],
  });
}
