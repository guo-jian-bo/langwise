import '../../app/modules/management/enums/enums.dart';
import '../enum/enum.dart';
import 'card_public_entity.dart';
import 'zhenxie_realization_sets_entity.dart';

/// 语法全景实体，对齐 manage_grammar_panorama.json 结构。
class ManageGrammarPanoramaEntity {
  String? nid;
  String? gridKind;
  ManageGrammarPanoramaDifficultyEntity? difficulty;
  double? order;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  bool? system;
  bool? enabled;
  List<ManageGrammarPanoramaAxisEntity?>? axes;
  int? cellCount;
  List<ManageGrammarPanoramaCellEntity?>? cells;
  List<ManageGrammarPanoramaContrastFocusEntity?>? contrastFoci;
  ManageGrammarPanoramaSentenceEligibilityEntity? sentenceEligibility;
  ManageGrammarPanoramaAxisValuesEntity? teachingEntryAxisValues;
  List<ManageGrammarPanoramaMinimalSubGridEntity?>? minimalSubGrids;
  int? minimalSubGridCount;
  List<ZhenxieRealizationSetsEntity?>? realizationSets;
  String? created;
  String? updated;

  GridKindEnum? get gridKindEnum => GridKindEnum.fromValue(gridKind);

  ManageGrammarPanoramaEntity({
    this.nid,
    this.gridKind,
    this.difficulty,
    this.order,
    this.name,
    this.description,
    this.system,
    this.enabled,
    this.axes,
    this.cellCount,
    this.cells,
    this.contrastFoci,
    this.sentenceEligibility,
    this.teachingEntryAxisValues,
    this.minimalSubGrids,
    this.minimalSubGridCount,
    this.realizationSets,
    this.created,
    this.updated,
  });

  ManageGrammarPanoramaEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    gridKind = json['gridKind']?.toString();
    difficulty = _parseObject(json['difficulty'], ManageGrammarPanoramaDifficultyEntity.fromJson);
    order = _parseDouble(json['order']);
    name = _parseLanguageTextList(json['name']);
    description = _parseLanguageTextList(json['description']);
    system = json['system'];
    enabled = json['enabled'];
    axes = _parseObjectList(json['axes'], ManageGrammarPanoramaAxisEntity.fromJson);
    cellCount = json['cellCount']?.toInt();
    cells = _parseObjectList(json['cells'], ManageGrammarPanoramaCellEntity.fromJson);
    contrastFoci = _parseObjectList(json['contrastFoci'], ManageGrammarPanoramaContrastFocusEntity.fromJson);
    sentenceEligibility = _parseObject(json['sentenceEligibility'], ManageGrammarPanoramaSentenceEligibilityEntity.fromJson);
    teachingEntryAxisValues = _parseObject(json['teachingEntryAxisValues'], ManageGrammarPanoramaAxisValuesEntity.fromJson);
    minimalSubGrids = _parseObjectList(json['minimalSubGrids'], ManageGrammarPanoramaMinimalSubGridEntity.fromJson);
    minimalSubGridCount = json['minimalSubGridCount']?.toInt();
    realizationSets = _parseObjectList(json['realizationSets'], ZhenxieRealizationSetsEntity.fromJson);
    created = json['created']?.toString();
    updated = json['updated']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['gridKind'] = gridKind;
    data['difficulty'] = difficulty?.toJson();
    data['order'] = order;
    data['name'] = name?.map((v) => v?.toJson()).toList();
    data['description'] = description?.map((v) => v?.toJson()).toList();
    data['system'] = system;
    data['enabled'] = enabled;
    data['axes'] = axes?.map((v) => v?.toJson()).toList();
    data['cellCount'] = cellCount;
    data['cells'] = cells?.map((v) => v?.toJson()).toList();
    data['contrastFoci'] = contrastFoci?.map((v) => v?.toJson()).toList();
    data['sentenceEligibility'] = sentenceEligibility?.toJson();
    data['teachingEntryAxisValues'] = teachingEntryAxisValues;
    data['minimalSubGrids'] = minimalSubGrids?.map((v) => v?.toJson()).toList();
    data['minimalSubGridCount'] = minimalSubGridCount;
    data['realizationSets'] = realizationSets?.map((v) => v?.toJson()).toList();
    data['created'] = created;
    data['updated'] = updated;
    return data;
  }
}

/// 难度范围信息。
class ManageGrammarPanoramaDifficultyEntity {
  int? max;
  int? min;

  ManageGrammarPanoramaDifficultyEntity({
    this.max,
    this.min,
  });

  ManageGrammarPanoramaDifficultyEntity.fromJson(Map<String, dynamic> json) {
    max = json['max']?.toInt();
    min = json['min']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['max'] = max;
    data['min'] = min;
    return data;
  }
}

/// 轴定义，描述 grammar panorama 的维度与候选值。
class ManageGrammarPanoramaAxisEntity {
  String? axisKey;
  String? dimensionNid;
  ManageGrammarPanoramaNamedInfoEntity? dimension;
  List<String?>? values;
  List<ManageGrammarPanoramaAxisValueLabelEntity?>? valuesLabels;

  ManageGrammarPanoramaAxisEntity({
    this.axisKey,
    this.dimensionNid,
    this.dimension,
    this.values,
    this.valuesLabels,
  });

  ManageGrammarPanoramaAxisEntity.fromJson(Map<String, dynamic> json) {
    axisKey = json['axisKey']?.toString();
    dimensionNid = json['dimensionNid']?.toString();
    dimension = _parseObject(json['dimension'], ManageGrammarPanoramaNamedInfoEntity.fromJson);
    values = _parseStringList(json['values']);
    valuesLabels = _parseObjectList(json['valuesLabels'], ManageGrammarPanoramaAxisValueLabelEntity.fromJson);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['axisKey'] = axisKey;
    data['dimensionNid'] = dimensionNid;
    data['dimension'] = dimension?.toJson();
    data['values'] = values;
    data['valuesLabels'] = valuesLabels?.map((v) => v?.toJson()).toList();
    return data;
  }
}

/// 轴候选值标签定义。
class ManageGrammarPanoramaAxisValueLabelEntity {
  String? nid;
  List<LanguageText?>? name;

  ManageGrammarPanoramaAxisValueLabelEntity({
    this.nid,
    this.name,
  });

  ManageGrammarPanoramaAxisValueLabelEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    name = _parseLanguageTextList(json['name']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['name'] = name?.map((v) => v?.toJson()).toList();
    return data;
  }
}

/// 通用命名信息，用于 dimension、pattern slot 等轻量对象。
class ManageGrammarPanoramaNamedInfoEntity {
  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  String? categoryNid;
  String? color;

  ManageGrammarPanoramaNamedInfoEntity({
    this.nid,
    this.name,
    this.description,
    this.categoryNid,
    this.color,
  });

  ManageGrammarPanoramaNamedInfoEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    name = _parseLanguageTextList(json['name']);
    description = _parseLanguageTextList(json['description']);
    categoryNid = json['categoryNid']?.toString();
    color = json['color']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['name'] = name?.map((v) => v?.toJson()).toList();
    data['description'] = description?.map((v) => v?.toJson()).toList();
    data['categoryNid'] = categoryNid;
    data['color'] = color;
    return data;
  }
}

/// 宫格 cell 定义，描述每个格子的行列值与轴值组合。
class ManageGrammarPanoramaCellEntity {
  String? rowValue;
  String? colValue;
  String? key;
  List<LanguageText?>? label;
  ManageGrammarPanoramaAxisValuesEntity? axisValues;

  ManageGrammarPanoramaCellEntity({
    this.rowValue,
    this.colValue,
    this.key,
    this.label,
    this.axisValues,
  });

  ManageGrammarPanoramaCellEntity.fromJson(Map<String, dynamic> json) {
    rowValue = json['rowValue']?.toString();
    colValue = json['colValue']?.toString();
    key = json['key']?.toString();
    label = _parseLanguageTextList(json['label']);
    axisValues = _parseObject(json['axisValues'], ManageGrammarPanoramaAxisValuesEntity.fromJson);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['rowValue'] = rowValue;
    data['colValue'] = colValue;
    data['key'] = key;
    data['label'] = label?.map((v) => v?.toJson()).toList();
    data['axisValues'] = axisValues;
    return data;
  }
}

/// 轴值组合，承接当前 grammar panorama 里的 time / polarity 选择。
class ManageGrammarPanoramaAxisValuesEntity {
  String? time;
  String? polarity;

  ManageGrammarPanoramaAxisValuesEntity({
    this.time,
    this.polarity,
  });

  ManageGrammarPanoramaAxisValuesEntity.fromJson(Map<String, dynamic> json) {
    time = json['time']?.toString();
    polarity = json['polarity']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['time'] = time;
    data['polarity'] = polarity;
    return data;
  }
}

/// 对照焦点定义。
class ManageGrammarPanoramaContrastFocusEntity {
  String? focusKey;
  List<ManageGrammarPanoramaContrastBindingEntity?>? bindings;

  FocusKeyEnum? get focusKeyEnum => FocusKeyEnum.fromValue(focusKey);

  ManageGrammarPanoramaContrastFocusEntity({
    this.focusKey,
    this.bindings,
  });

  ManageGrammarPanoramaContrastFocusEntity.fromJson(Map<String, dynamic> json) {
    focusKey = json['focusKey']?.toString();
    bindings = _parseObjectList(json['bindings'], ManageGrammarPanoramaContrastBindingEntity.fromJson);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['focusKey'] = focusKey;
    data['bindings'] = bindings?.map((v) => v?.toJson()).toList();
    return data;
  }
}

/// 焦点绑定，描述特定轴值组合下启用的 pattern slot。
class ManageGrammarPanoramaContrastBindingEntity {
  Map<String, String?>? axisValues;
  List<String?>? patternSlotKeys;
  List<ManageGrammarPanoramaNamedInfoEntity?>? patternSlots;

  ManageGrammarPanoramaContrastBindingEntity({
    this.axisValues,
    this.patternSlotKeys,
    this.patternSlots,
  });

  ManageGrammarPanoramaContrastBindingEntity.fromJson(Map<String, dynamic> json) {
    axisValues = _parseStringMap(json['axisValues']);
    patternSlotKeys = _parseStringList(json['patternSlotKeys']);
    patternSlots = _parseObjectList(json['patternSlots'], ManageGrammarPanoramaNamedInfoEntity.fromJson);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['axisValues'] = axisValues;
    data['patternSlotKeys'] = patternSlotKeys;
    data['patternSlots'] = patternSlots?.map((v) => v?.toJson()).toList();
    return data;
  }
}

/// 句子可用性建议。
class ManageGrammarPanoramaSentenceEligibilityEntity {
  List<String?>? suggestedPatternNids;
  List<ManageGrammarPanoramaPatternInfoEntity?>? suggestedPatterns;

  ManageGrammarPanoramaSentenceEligibilityEntity({
    this.suggestedPatternNids,
    this.suggestedPatterns,
  });

  ManageGrammarPanoramaSentenceEligibilityEntity.fromJson(Map<String, dynamic> json) {
    suggestedPatternNids = _parseStringList(json['suggestedPatternNids']);
    suggestedPatterns = _parseObjectList(json['suggestedPatterns'], ManageGrammarPanoramaPatternInfoEntity.fromJson);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['suggestedPatternNids'] = suggestedPatternNids;
    data['suggestedPatterns'] = suggestedPatterns?.map((v) => v?.toJson()).toList();
    return data;
  }
}

/// 轻量句型信息。
class ManageGrammarPanoramaPatternInfoEntity {
  String? nid;
  List<LanguageText?>? name;
  List<LanguageText?>? description;
  String? template;

  ManageGrammarPanoramaPatternInfoEntity({
    this.nid,
    this.name,
    this.description,
    this.template,
  });

  ManageGrammarPanoramaPatternInfoEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    name = _parseLanguageTextList(json['name']);
    description = _parseLanguageTextList(json['description']);
    template = json['template']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['name'] = name?.map((v) => v?.toJson()).toList();
    data['description'] = description?.map((v) => v?.toJson()).toList();
    data['template'] = template;
    return data;
  }
}

/// 最小教学子宫格定义。
class ManageGrammarPanoramaMinimalSubGridEntity {
  String? nid;
  Map<String, List<String?>?>? axisSubsets;
  int? cellCount;

  ManageGrammarPanoramaMinimalSubGridEntity({
    this.nid,
    this.axisSubsets,
    this.cellCount,
  });

  ManageGrammarPanoramaMinimalSubGridEntity.fromJson(Map<String, dynamic> json) {
    nid = json['nid']?.toString();
    axisSubsets = _parseStringListMap(json['axisSubsets']);
    cellCount = json['cellCount']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nid'] = nid;
    data['axisSubsets'] = axisSubsets;
    data['cellCount'] = cellCount;
    return data;
  }
}

List<LanguageText?>? _parseLanguageTextList(dynamic value) {
  if (value is! List) return null;
  return value.map((item) {
    if (item == null || item is! Map) return null;
    return LanguageText.fromJson(Map<String, dynamic>.from(item));
  }).toList();
}

List<String?>? _parseStringList(dynamic value) {
  if (value is! List) return null;
  return value.map((item) => item?.toString()).toList();
}

Map<String, String?>? _parseStringMap(dynamic value) {
  if (value is! Map) return null;
  return Map<String, String?>.fromEntries(value.entries.map((entry) => MapEntry(entry.key.toString(), entry.value?.toString())));
}

Map<String, List<String?>?>? _parseStringListMap(dynamic value) {
  if (value is! Map) return null;
  return Map<String, List<String?>?>.fromEntries(
      value.entries.map((entry) => MapEntry(entry.key.toString(), _parseStringList(entry.value))));
}

T? _parseObject<T>(dynamic value, T Function(Map<String, dynamic> json) parser) {
  if (value is! Map) return null;
  return parser(Map<String, dynamic>.from(value));
}

List<T?>? _parseObjectList<T>(dynamic value, T Function(Map<String, dynamic> json) parser) {
  if (value is! List) return null;
  return value.map((item) {
    if (item == null || item is! Map) return null;
    return parser(Map<String, dynamic>.from(item));
  }).toList();
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
