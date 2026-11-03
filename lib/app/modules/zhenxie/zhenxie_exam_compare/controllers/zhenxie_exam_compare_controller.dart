import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/common/entities/card_public_entity.dart';
import 'package:langwise/common/entities/language_config_color_entity.dart';
import 'package:langwise/common/https/zhenxie.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/theme/theme_utils.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../zhenxie_exam/models/zhenxie_exam_models.dart';

/// 对比页模块 id。
enum ExamCompareModule {
  genres,
  topics,
  goals,
  ladder,
}

extension ExamCompareModuleExt on ExamCompareModule {
  String get id => name;

  String get title {
    switch (this) {
      case ExamCompareModule.genres:
        return '文章';
      case ExamCompareModule.topics:
        return '主题';
      case ExamCompareModule.goals:
        return '能力';
      case ExamCompareModule.ladder:
        return '阶梯';
    }
  }
}

class LadderCompareNodeData {
  final String stageNid;
  final String examStage;
  final String stageName;
  final String blueprintNid;
  final String genreNid;
  final int order;
  final int count;
  final int colorValue;
  final String skinNid;
  final String coverUrl;
  final String? coverAsset;

  const LadderCompareNodeData({
    required this.stageNid,
    required this.examStage,
    required this.stageName,
    required this.blueprintNid,
    required this.genreNid,
    required this.order,
    required this.count,
    required this.colorValue,
    required this.skinNid,
    required this.coverUrl,
    required this.coverAsset,
  });
}

class LadderCompareLaneData {
  final String genreNid;
  final String label;
  final String sub;
  final int colorValue;

  const LadderCompareLaneData({
    required this.genreNid,
    required this.label,
    required this.sub,
    required this.colorValue,
  });
}

class LadderCompareCoverageData {
  final String stage;
  final String label;
  final int hit;
  final int total;

  const LadderCompareCoverageData({
    required this.stage,
    required this.label,
    required this.hit,
    required this.total,
  });
}

class LadderCompareData {
  final List<LadderCompareLaneData> lanes;
  final List<LadderCompareNodeData> nodes;
  final List<LadderCompareCoverageData> covered;
  final Map<String, List<String>> stageTags;

  const LadderCompareData({
    required this.lanes,
    required this.nodes,
    required this.covered,
    required this.stageTags,
  });
}

class ExamRegionFilterOption {
  final String value;
  final String label;
  final List<String> regionNids;
  final bool active;
  final bool showAllTag;

  const ExamRegionFilterOption({
    required this.value,
    required this.label,
    required this.regionNids,
    required this.active,
    required this.showAllTag,
  });
}

class ExamRegionFilterItem {
  final String nid;
  final String name;
  final String fixedValue;

  const ExamRegionFilterItem({
    required this.nid,
    required this.name,
    required this.fixedValue,
  });
}

class ExamRegionFilterSection {
  final String paperName;
  final List<String> regionNids;
  final List<ExamRegionFilterItem> provinces;
  final bool allowProvinceSelection;

  const ExamRegionFilterSection({
    required this.paperName,
    required this.regionNids,
    required this.provinces,
    required this.allowProvinceSelection,
  });
}

/// 对比页控制器：改为直接读取 compare 接口，不再依赖首页 mock 数据。
class ZhenxieExamCompareController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  final Rx<ExamCompareModule> module = ExamCompareModule.genres.obs;
  String? stage;

  ZhenxieExamCompareController({
    required this.tagText,
  });

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_EXAM_COMPARE;

  @override
  String get breadcrumbTitle => '考点详情';

  final RxBool isLoading = false.obs;
  final Rxn<ZhenxieExamCompareMetaData> metaData = Rxn<ZhenxieExamCompareMetaData>();
  final RxMap<String, ZhenxieExamCompareData> compareDataMap = <String, ZhenxieExamCompareData>{}.obs;
  final Rxn<ZhenxieExamGoalSankeyApiData> goalSankeyData = Rxn<ZhenxieExamGoalSankeyApiData>();
  final RxnString selectedId = RxnString();
  final RxnString hoveredId = RxnString();
  final RxList<String> selectedRegionNids = <String>[].obs;
  final RxBool regionSheetVisible = false.obs;
  final ScrollController ladderMapScrollController = ScrollController();

  String? get activeId => selectedId.value ?? hoveredId.value;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText, title: '考点详情');
    final String? moduleId = Get.arguments?['module']?.toString();
    if ((moduleId ?? '').isNotEmpty) {
      module.value = _parseModule(moduleId!);
    }
    final String? currentStage = Get.arguments?['stage']?.toString();
    if ((currentStage ?? '').isNotEmpty) {
      stage = currentStage;
    }
    final String? highlightId = Get.arguments?['highlight']?.toString();
    if (highlightId != null && highlightId.isNotEmpty) {
      selectedId.value = highlightId;
    }
    loadInitialData();
  }

  @override
  void onClose() {
    ladderMapScrollController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    ToastUtils.showLoading();
    try {
      final Map<String, dynamic>? metaResponse = await ZhenxieRequest.getExamCompareMetaData();
      if (metaResponse != null) {
        metaData.value = ZhenxieExamCompareMetaData.fromJson(metaResponse);
        selectedRegionNids.assignAll(buildAllRegionNids());
      }
      await _loadModuleData(module.value, force: true);
    } finally {
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }

  Future<void> _loadModuleData(ExamCompareModule targetModule, {bool force = false}) async {
    if (!force) {
      if (targetModule == ExamCompareModule.goals && goalSankeyData.value != null) return;
      if (targetModule != ExamCompareModule.goals && compareDataMap[targetModule.id] != null) return;
    }

    final Map<String, dynamic> requestData = _buildFilterRequestData();
    if (targetModule == ExamCompareModule.goals) {
      final Map<String, dynamic>? response = await ZhenxieRequest.getExamGoalSankeyData(data: requestData);
      if (response != null) {
        goalSankeyData.value = ZhenxieExamGoalSankeyApiData.fromJson(response);
      }
      return;
    }

    final Map<String, dynamic>? response = await ZhenxieRequest.getExamCompareData(
      module: targetModule.id,
      data: requestData,
    );
    if (response != null) {
      compareDataMap[targetModule.id] = ZhenxieExamCompareData.fromJson(response);
    }
  }

  Map<String, dynamic> _buildFilterRequestData() {
    final ZhenxieExamCompareMetaData? currentMeta = metaData.value;
    final List<String> allNids = buildAllRegionNids();
    if (currentMeta == null || selectedRegionNids.isEmpty || allNids.isEmpty || _containsSameValues(selectedRegionNids, allNids)) {
      return const <String, dynamic>{'filters': <Map<String, dynamic>>[]};
    }
    if (selectedRegionNids.isEmpty) {
      return const <String, dynamic>{'filters': <Map<String, dynamic>>[]};
    }
    return <String, dynamic>{
      'filters': <Map<String, dynamic>>[
        <String, dynamic>{
          'code': 'regionNids',
          'values': selectedRegionNids.toList(),
        },
      ],
    };
  }

  List<ExamRegionFilterOption> buildRegionFilterOptions() {
    final ZhenxieExamCompareMetaData? currentMeta = metaData.value;
    if (currentMeta == null) return const <ExamRegionFilterOption>[];
    final Set<String> selectedSet = selectedRegionNids.toSet();
    return currentMeta.fixedOptions
        .map((item) => ExamRegionFilterOption(
              value: item.value,
              label: item.name,
              regionNids: item.regionNids,
              active: item.regionNids.any(selectedSet.contains),
              showAllTag: item.regionNids.length > 1 && item.regionNids.every(selectedSet.contains),
            ))
        .toList();
  }

  List<String> buildAllRegionNids() {
    final List<String> all = <String>[];
    for (final ExamRegionFilterOption item in buildRegionFilterOptions()) {
      for (final String nid in item.regionNids) {
        if (all.contains(nid)) continue;
        all.add(nid);
      }
    }
    return all;
  }

  bool isAllRegionsSelected(List<String> regionNids) {
    return regionNids.isNotEmpty && regionNids.every(selectedRegionNids.contains);
  }

  bool hasSelectedRegions(List<String> regionNids) {
    return regionNids.any(selectedRegionNids.contains);
  }

  List<ExamRegionFilterSection> buildRegionFilterSections() {
    final ZhenxieExamCompareMetaData? currentMeta = metaData.value;
    if (currentMeta == null) return const <ExamRegionFilterSection>[];
    final List<ExamRegionFilterSection> sections = <ExamRegionFilterSection>[];
    for (final ZhenxieExamCompareRegionGroupData group in currentMeta.groups) {
      final List<ZhenxieExamCompareRegionData> regions = <ZhenxieExamCompareRegionData>[...group.regions]
        ..sort((a, b) => a.sortWeight.compareTo(b.sortWeight));
      final List<ExamRegionFilterItem> items = regions
          .map((item) => ExamRegionFilterItem(
                nid: item.nid,
                name: _textOf(item.name),
                fixedValue: item.fixedValue,
              ))
          .toList();
      if (items.isEmpty) continue;
      sections.add(ExamRegionFilterSection(
        paperName: group.name,
        regionNids: items.map((item) => item.nid).toList(),
        provinces: items,
          allowProvinceSelection: items.any((item) => item.fixedValue != group.name),
      ));
    }
    return sections;
  }

  Future<void> toggleRegionValue(String value) async {
    final ExamRegionFilterOption? option = buildRegionFilterOptions().firstWhereOrNull((item) => item.value == value);
    if (option == null) return;
    await _toggleRegionNids(option.regionNids);
  }

  Future<void> toggleRegionItem(String nid) async {
    await _toggleRegionNids(<String>[nid]);
  }

  Future<void> toggleSectionRegions(List<String> regionNids) async {
    await _toggleRegionNids(regionNids);
  }

  Future<void> applyRegionSelection(Iterable<String> regionNids) async {
    final Set<String> nextSet = regionNids.toSet();
    final List<String> ordered = buildAllRegionNids().where(nextSet.contains).toList();
    if (ordered.isEmpty) {
      ToastUtils.showToast(text: '请至少保留一个筛选项');
      return;
    }
    if (_containsSameValues(selectedRegionNids, ordered)) return;
    await _applyRegionSelection(ordered);
  }

  Future<void> _toggleRegionNids(List<String> regionNids) async {
    final Set<String> currentSet = selectedRegionNids.toSet();
    final bool allSelected = regionNids.isNotEmpty && regionNids.every(currentSet.contains);
    if (allSelected) {
      currentSet.removeAll(regionNids);
    } else {
      currentSet.addAll(regionNids);
    }
    if (currentSet.isEmpty) {
      ToastUtils.showToast(text: '请至少保留一个筛选项');
      return;
    }
    final List<String> ordered = buildAllRegionNids().where(currentSet.contains).toList();
    await _applyRegionSelection(ordered);
  }

  Future<void> _applyRegionSelection(List<String> values) async {
    selectedRegionNids.assignAll(values);
    selectedId.value = null;
    hoveredId.value = null;
    compareDataMap.clear();
    goalSankeyData.value = null;
    isLoading.value = true;
    ToastUtils.showLoading();
    try {
      await _loadModuleData(module.value, force: true);
    } finally {
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }

  ZhenxieExamCompareData? findCurrentCompareData() {
    return compareDataMap[module.value.id];
  }

  List<LanguageText> buildCurrentTitleTexts() {
    if (module.value == ExamCompareModule.goals) {
      return goalSankeyData.value?.title ?? const <LanguageText>[];
    }
    return findCurrentCompareData()?.title ?? const <LanguageText>[];
  }

  List<LanguageText> buildCurrentDescriptionTexts() {
    if (module.value == ExamCompareModule.goals) {
      return goalSankeyData.value?.description ?? const <LanguageText>[];
    }
    return findCurrentCompareData()?.description ?? const <LanguageText>[];
  }

  String buildCurrentTitle() {
    return _zhTextOf(buildCurrentTitleTexts());
  }

  String buildCurrentDescription() {
    return _zhTextOf(buildCurrentDescriptionTexts());
  }

  String buildZhText(List<LanguageText> texts) {
    return _zhTextOf(texts);
  }

  LanguageConfigColorEntityThemeColors? findCurrentThemeColors(List<LanguageConfigColorEntityThemeColors> colors) {
    for (final LanguageConfigColorEntityThemeColors item in colors) {
      if (ThemeUtils.isCurrentTheme(item.theme ?? '')) return item;
    }
    final String themeKey = ThemeUtils.isCurrentTheme(AppThemeKey.light.value) ? AppThemeKey.light.value : AppThemeKey.dark.value;
    return colors.firstWhereOrNull((item) => (item.theme ?? '').toUpperCase() == themeKey);
  }

  Color buildLegendPrimaryColor(ZhenxieExamCompareLegendData legend) {
    final LanguageConfigColorEntityThemeColors? themeColors = findCurrentThemeColors(legend.colors);
    return themeColors?.colorC ??
        themeColors?.textColorC ??
        themeColors?.backgroundColorC ??
        themeColors?.borderColorC ??
        const Color(0x00000000);
  }

  Color buildGenreColorPrimaryColor(ZhenxieExamCompareGenreColorData item) {
    final LanguageConfigColorEntityThemeColors? themeColors = findCurrentThemeColors(item.colors);
    return themeColors?.colorC ??
        themeColors?.textColorC ??
        themeColors?.backgroundColorC ??
        themeColors?.borderColorC ??
        const Color(0x00000000);
  }

  bool _containsSameValues(List<String> current, List<String> target) {
    if (current.length != target.length) return false;
    final Set<String> currentSet = current.toSet();
    return target.every(currentSet.contains);
  }

  void setRegionSheetVisible(bool visible) {
    regionSheetVisible.value = visible;
  }

  Future<void> switchModule(ExamCompareModule newModule) async {
    if (module.value == newModule) return;
    module.value = newModule;
    selectedId.value = null;
    hoveredId.value = null;
    isLoading.value = true;
    ToastUtils.showLoading();
    try {
      await _loadModuleData(newModule);
    } finally {
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }

  List<ZhenxieExamGoalSankeyNodeApiData> buildGoalLineage(
    String nodeId,
    ZhenxieExamGoalSankeyApiData data,
  ) {
    final ZhenxieExamGoalSankeyNodeApiData? node = _findGoalNode(data, nodeId);
    if (node == null) return const <ZhenxieExamGoalSankeyNodeApiData>[];
    if (node.basic) {
      return data.columns
          .expand((item) => item.nodes)
          .where((item) => item.basic)
          .toList();
    }
    final Set<String> ids = <String>{node.code};
    List<String> frontier = <String>[node.code];
    for (int step = 0; step < 2; step++) {
      final List<String> next = <String>[];
      for (final String current in frontier) {
        for (final ZhenxieExamGoalSankeyLinkApiData link in data.links) {
          if (link.source == current && ids.add(link.target)) next.add(link.target);
          if (link.target == current && ids.add(link.source)) next.add(link.source);
        }
      }
      frontier = next;
    }
    return data.columns
        .expand((item) => item.nodes)
        .where((item) => ids.contains(item.code) && !item.basic)
        .toList();
  }

  LadderCompareData buildLadderCompareData() {
    final ZhenxieExamCompareData? data = compareDataMap[ExamCompareModule.ladder.id];
    if (data == null) {
      return const LadderCompareData(
        lanes: <LadderCompareLaneData>[],
        nodes: <LadderCompareNodeData>[],
        covered: <LadderCompareCoverageData>[],
        stageTags: <String, List<String>>{},
      );
    }
    final List<LadderCompareLaneData> lanes = <LadderCompareLaneData>[];
    final Set<String> laneIds = <String>{};
    for (final ZhenxieExamCompareGenreColorData item in data.genreColors) {
      final String genreNid = item.code.isNotEmpty ? item.code : otherId;
      if (!laneIds.add(genreNid)) continue;
      lanes.add(
        LadderCompareLaneData(
          genreNid: genreNid,
          label: item.name.isNotEmpty ? _textOf(item.name) : '其他',
          sub: _enTextOf(item.name),
          colorValue: buildGenreColorPrimaryColor(item).toARGB32(),
        ),
      );
    }
    for (final ZhenxieExamCompareLegendData legend in data.legends) {
      final String genreNid = legend.groupCode.isNotEmpty ? legend.groupCode : otherId;
      if (!laneIds.add(genreNid)) continue;
      lanes.add(
        LadderCompareLaneData(
          genreNid: genreNid,
          label: legend.groupName.isNotEmpty ? _textOf(legend.groupName) : '其他',
          sub: _enTextOf(legend.groupName),
          colorValue: genreColorValue(genreNid),
        ),
      );
    }
    final Map<String, int> laneColorMap = <String, int>{
      for (final LadderCompareLaneData item in lanes) item.genreNid: item.colorValue,
    };
    final List<LadderCompareNodeData> nodes = <LadderCompareNodeData>[];
    for (final ZhenxieExamCompareColumnData column in data.columns) {
      for (final ZhenxieExamCompareLegendData legend in data.legends) {
        final ZhenxieExamCompareNodeData? node = column.nodes.firstWhereOrNull((item) => item.code == legend.code);
        if (node == null) continue;
        final String genreNid = legend.groupCode.isNotEmpty ? legend.groupCode : otherId;
        nodes.add(LadderCompareNodeData(
          stageNid: legend.code,
          examStage: column.stage,
          stageName: _textOf(legend.name),
          blueprintNid: legend.code,
          genreNid: genreNid,
          order: node.order,
          count: node.value,
          colorValue: laneColorMap[genreNid] ?? genreColorValue(genreNid),
          skinNid: '',
          coverUrl: legend.coverUrl,
          coverAsset: null,
        ));
      }
    }
    final List<LadderCompareCoverageData> covered = data.columns.map((column) {
      final int hit = column.nodes.fold<int>(0, (sum, item) => sum + item.value);
      return LadderCompareCoverageData(
        stage: column.stage,
        label: _textOf(column.name),
        hit: hit,
        total: column.taskCount,
      );
    }).toList();
    final Map<String, List<String>> stageTags = <String, List<String>>{
      for (final ZhenxieExamCompareColumnData column in data.columns) column.stage: column.tags,
    };
    return LadderCompareData(
      lanes: lanes,
      nodes: nodes,
      covered: covered,
      stageTags: stageTags,
    );
  }

  int buildGoalAnchorCount() {
    final ZhenxieExamGoalSankeyApiData? data = goalSankeyData.value;
    if (data == null) return 0;
    final ZhenxieExamGoalSankeyColumnApiData? gaokaoColumn = data.columns.firstWhereOrNull((item) => item.stage == ZhenxieExamStage.gaokao.code);
    if (gaokaoColumn == null) return 0;
    return gaokaoColumn.nodes.where((item) => !item.basic).length;
  }

  String buildGoalExplainNote(ZhenxieExamGoalSankeyNodeApiData node) {
    return node.members
        .map((item) => _zhTextOf(item.name))
        .where((item) => item.isNotEmpty)
        .join(' · ');
  }

  Color buildGoalLegendColor(String legendCode) {
    final ZhenxieExamCompareLegendData? legend = goalSankeyData.value?.legends.firstWhereOrNull((item) => item.code == legendCode);
    if (legend == null) return const Color(0x00000000);
    return buildLegendPrimaryColor(legend);
  }

  Color buildGoalNodeColor(ZhenxieExamGoalSankeyColumnApiData column, ZhenxieExamGoalSankeyNodeApiData node) {
    if (node.basic) {
      return buildGoalLegendColor('basic');
    }
    if (column.stage == ZhenxieExamStage.gaokao.code) {
      return buildGoalLegendColor('gaokao_12_abilities');
    }
    return buildGoalLegendColor('ladder');
  }

  String buildGoalNodeName(ZhenxieExamGoalSankeyNodeApiData node) {
    return _zhTextOf(node.name);
  }

  int goalNodeColumnIndex(ZhenxieExamGoalSankeyApiData data, String nodeCode) {
    for (int i = 0; i < data.columns.length; i++) {
      if (data.columns[i].nodes.any((item) => item.code == nodeCode)) return i;
    }
    return -1;
  }

  ZhenxieExamGoalSankeyColumnApiData? findGoalColumnByNodeCode(
    ZhenxieExamGoalSankeyApiData data,
    String nodeCode,
  ) {
    return data.columns.firstWhereOrNull((item) => item.nodes.any((node) => node.code == nodeCode));
  }

  ZhenxieExamGoalSankeyNodeApiData? findGoalNodeByCode(
    ZhenxieExamGoalSankeyApiData data,
    String nodeCode,
  ) {
    return _findGoalNode(data, nodeCode);
  }

  ZhenxieExamTaskQuery buildFlowTaskQuery(ZhenxieExamCompareLegendData legend) {
    if (module.value == ExamCompareModule.topics) {
      final bool hasParent = legend.groupCode.isNotEmpty && legend.groupCode != legend.code;
      return ZhenxieExamTaskQuery(
        domain: hasParent ? legend.groupCode : legend.code,
        topic: hasParent ? legend.code : null,
      );
    }
    return ZhenxieExamTaskQuery(
      genre: legend.groupCode.isNotEmpty && legend.groupCode != legend.code ? legend.groupCode : legend.code,
      family: legend.groupCode.isNotEmpty && legend.groupCode != legend.code ? legend.code : null,
    );
  }

  ZhenxieExamTaskQuery buildGoalTaskQuery(ZhenxieExamGoalSankeyNodeApiData node) {
    final List<String> goalCodes = node.goalCodes.where((item) => item.isNotEmpty).toList();
    return ZhenxieExamTaskQuery(goal: (goalCodes.isNotEmpty ? goalCodes : <String>[node.code]).join(','));
  }

  Future<void> openTasks(ZhenxieExamTaskQuery query, {String? currentStage}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};
    final List<String> regionFilterValues = buildTaskRegionFilterValues();
    if (regionFilterValues.isNotEmpty) {
      arguments['regionNids'] = regionFilterValues;
    }
    if ((query.family ?? '').isNotEmpty) {
      arguments['familyNid'] = query.family!;
    } else if ((query.domain ?? '').isNotEmpty) {
      arguments['parentNid'] = query.domain!;
    } else if ((query.goal ?? '').isNotEmpty) {
      arguments['goalNids'] = query.goal!;
    } else if ((query.stageNid ?? '').isNotEmpty) {
      arguments['stageNid'] = query.stageNid!;
    } else if ((query.genre ?? '').isNotEmpty) {
      arguments['genreNid'] = query.genre!;
    }
    if ((query.topic ?? '').isNotEmpty) {
      arguments['topicNids'] = query.topic!;
    }
    await TagRoutes.toNamed(
      Routes.ZHENXIE_EXAM_TASKS,
      arguments: arguments,
    );
  }

  List<String> buildTaskRegionFilterValues() {
    final List<String> allRegionNids = buildAllRegionNids();
    if (selectedRegionNids.isEmpty || allRegionNids.isEmpty || _containsSameValues(selectedRegionNids, allRegionNids)) {
      return const <String>[];
    }

    final List<String> values = <String>[];
    for (final ExamRegionFilterSection section in buildRegionFilterSections()) {
      final int selectedCount = section.regionNids.where(selectedRegionNids.contains).length;
      if (selectedCount <= 0) continue;
      if (!section.allowProvinceSelection) {
        if (selectedCount == section.regionNids.length) {
          final String fixedValue = section.provinces.firstWhereOrNull((item) => item.fixedValue.isNotEmpty)?.fixedValue ?? section.paperName;
          if (fixedValue.isNotEmpty && !values.contains(fixedValue)) {
            values.add(fixedValue);
          }
        }
        continue;
      }
      for (final ExamRegionFilterItem item in section.provinces) {
        if (!selectedRegionNids.contains(item.nid) || values.contains(item.nid)) continue;
        values.add(item.nid);
      }
    }
    return values;
  }

  void highlightSeries(String? id) {
    if (id == null || id.isEmpty) return;
    selectedId.value = id;
  }

  void select(String? id) {
    selectedId.value = selectedId.value == id ? null : id;
  }

  void hover(String? id) {
    hoveredId.value = id;
  }

  ZhenxieExamGoalSankeyNodeApiData? _findGoalNode(
    ZhenxieExamGoalSankeyApiData data,
    String nodeCode,
  ) {
    for (final ZhenxieExamGoalSankeyColumnApiData column in data.columns) {
      final ZhenxieExamGoalSankeyNodeApiData? node = column.nodes.firstWhereOrNull((item) => item.code == nodeCode);
      if (node != null) return node;
    }
    return null;
  }

  String _textOf(List<LanguageText> texts) {
    return pickLocalizedText(texts.map((item) => item.toJson()).toList());
  }

  String _enTextOf(List<LanguageText> texts) {
    return texts.firstWhereOrNull((item) => item.lang == 'en')?.text ?? '';
  }

  String _zhTextOf(List<LanguageText> texts) {
    return texts.firstWhereOrNull((item) => item.lang == 'zh')?.text ?? '';
  }

  ExamCompareModule _parseModule(String id) {
    switch (id) {
      case 'genres':
        return ExamCompareModule.genres;
      case 'topics':
        return ExamCompareModule.topics;
      case 'goals':
        return ExamCompareModule.goals;
      case 'ladder':
        return ExamCompareModule.ladder;
      default:
        return ExamCompareModule.genres;
    }
  }
}
