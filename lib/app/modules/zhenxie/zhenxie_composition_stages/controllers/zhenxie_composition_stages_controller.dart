import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/https/zhenxie.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/theme/theme_utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../models/zhenxie_composition_discourse_models.dart';
import '../models/zhenxie_composition_stages_models.dart';

class ZhenxieCompositionStagesController extends GetxController with DualBreadcrumbMixin {
  static const int _mapPageSize = 30;

  final String tagText;

  ZhenxieCompositionStagesController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_COMPOSITION_STAGES;

  @override
  String get breadcrumbTitle => "章法";

  bool isManagement = false;
  String? autoOpenDoorCode;
  bool hasAutoOpenedDoor = false;

  final Map<String, FilterSearchsData> filterSearchs = {
    "content": FilterSearchsData(
      title: "搜索",
      hintText: "名字 / 蓝图 / 家族 / 文类 / 考试",
      controller: TextEditingController(),
    ),
  };

  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{}.obs;
  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString currentView = 'map'.obs;
  final RxList<CompositionStageModel> stageList = <CompositionStageModel>[].obs;
  final RxList<CompositionStageModel> filteredStageList = <CompositionStageModel>[].obs;
  final RxList<CompositionStageMapColumnModel> mapColumns = <CompositionStageMapColumnModel>[].obs;
  final RxList<CompositionStageMilestoneGroupModel> mapMilestoneGroups = <CompositionStageMilestoneGroupModel>[].obs;
  final RxList<CompositionGenreModel> genreList = <CompositionGenreModel>[].obs;
  final RxList<String> laneGenreNidList = <String>[].obs;
  final RxList<String> beatNidOrderList = <String>[].obs;
  final RxBool isMapPaging = false.obs;
  final RxBool hasMoreMapStageData = true.obs;
  final RxInt stageTotalCount = 0.obs;
  final Rxn<CompositionDiscourseHomeModel> discourseHome = Rxn<CompositionDiscourseHomeModel>();
  final RxList<CompositionShelfBlueprintModel> shelfBlueprintList = <CompositionShelfBlueprintModel>[].obs;
  final RxList<CompositionShelfGateModel> shelfGateList = <CompositionShelfGateModel>[].obs;
  final ScrollController mapScrollController = ScrollController();
  final ScrollController listScrollController = ScrollController();

  final Map<String, CompositionGenreModel> genreMap = <String, CompositionGenreModel>{};
  final Map<String, ParagraphRhetoricalEntityList> beatMap = <String, ParagraphRhetoricalEntityList>{};
  final Map<String, String> sortCodeMap = <String, String>{};

  /// 用户端文类色：接口 colors[] 里按当前项目主题取到的色，管理端不走这里
  final Map<String, Color> genreThemeColorMap = <String, Color>{};
  int _mapOffset = 0;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      isManagement = Get.arguments["isManagement"] == true;
      autoOpenDoorCode = Get.arguments["autoOpenDoorCode"]?.toString();
      final String? initialView = Get.arguments["initialView"]?.toString();
      if (initialView == 'map' || initialView == 'shelf' || initialView == 'list') {
        currentView.value = initialView!;
      }
    }
    // 用户端先看书架，管理端维持地图
    if (Get.arguments == null || Get.arguments["initialView"] == null) {
      currentView.value = isManagement ? 'map' : 'shelf';
    }
    mapScrollController.addListener(_handleMapScroll);
    listScrollController.addListener(_handleListScroll);
    initData();
  }

  Future<void> initData() async {
    final bool needBlockingLoading = stageList.isEmpty;
    try {
      isLoading.value = true;
      if (needBlockingLoading) {
        ToastUtils.showLoading();
        if (isManagement) {
          await _initManagementBaseData();
        } else {
          await _initUserBaseData();
        }
      }
      await fetchStagePageData(reset: true);
    } finally {
      isLoading.value = false;
      if (needBlockingLoading) {
        ToastUtils.hideLoading();
      }
    }
    _tryAutoOpenDoor();
  }

  /// 管理端基础数据：筛选项 + 文类 + 起承转合，走管理端控制台接口。
  Future<void> _initManagementBaseData() async {
    final List<dynamic> responses = await Future.wait<dynamic>([
      LanguageConsoleRequest.getWriteCompositionStageQueryMetaGroupList(),
      LanguageConsoleRequest.getWriteCompositionGenreList(),
      LanguageUtil.getParagraphRhetoricalList(),
    ]);

    final FiltersGroupEntity? metaGroup = responses[0] as FiltersGroupEntity?;
    final List<Map<String, dynamic>>? genreResponse = responses[1] as List<Map<String, dynamic>>?;
    final ParagraphRhetoricalEntity? beatResponse = responses[2] as ParagraphRhetoricalEntity?;

    genreList.assignAll(
      (genreResponse ?? <Map<String, dynamic>>[])
          .map(CompositionGenreModel.fromJson)
          .where((item) => (item.nid ?? '').isNotEmpty)
          .toList(),
    );
    laneGenreNidList.assignAll(genreList.map((item) => item.nid ?? '').where((item) => item.isNotEmpty));
    _rebuildGenreMap();
    _rebuildBeatMap(beatResponse);

    if (metaGroup != null) {
      filterConditions.value = _buildFilterConditions(metaGroup);
      filterSorts.value = _buildFilterSorts(metaGroup);
    }
  }

  /// 用户端基础数据：章法壳数据 + 蓝图书架 + 起承转合，走用户端接口。
  Future<void> _initUserBaseData() async {
    final List<dynamic> responses = await Future.wait<dynamic>([
      ZhenxieRequest.getCompositionDiscourseHome(),
      ZhenxieRequest.getCompositionBlueprintList(),
      LanguageUtil.getParagraphRhetoricalList(),
    ]);

    final Map<String, dynamic>? homeResponse = responses[0] as Map<String, dynamic>?;
    final Map<String, dynamic>? blueprintResponse = responses[1] as Map<String, dynamic>?;
    final ParagraphRhetoricalEntity? beatResponse = responses[2] as ParagraphRhetoricalEntity?;

    final CompositionDiscourseHomeModel? home = homeResponse == null
        ? null
        : CompositionDiscourseHomeModel.fromJson(homeResponse);
    discourseHome.value = home;
    genreList.assignAll(
      (home?.genres ?? <CompositionGenreSummaryModel>[])
          .map((item) => item.genre)
          .whereType<CompositionGenreModel>()
          .toList(),
    );
    laneGenreNidList.assignAll(genreList.map((item) => item.nid ?? '').where((item) => item.isNotEmpty));
    _rebuildGenreMap();
    _rebuildGenreThemeColorMap(home);
    shelfGateList.assignAll(_buildShelfGates(home));
    shelfBlueprintList.assignAll(_parseShelfBlueprints(blueprintResponse));
    _rebuildBeatMap(beatResponse);
  }

  void switchView(String view) {
    if (currentView.value == view) return;
    currentView.value = view;
  }

  Future<void> onConditionsChanged(Map<String, FilterConditionsData> conditions) async {
    filterConditions.value = conditions;
    await fetchStagePageData(reset: true);
  }

  Future<void> onSortsChanged(Map<String, FilterSortsData> sorts) async {
    filterSorts.value = sorts;
    await fetchStagePageData(reset: true);
  }

  Future<void> onResetFilters(
    Map<String, FilterSortsData> sorts,
    Map<String, FilterConditionsData> conditions,
  ) async {
    filterSorts.value = sorts;
    filterConditions.value = conditions;
    filterSearchs["content"]?.controller.clear();
    await fetchStagePageData(reset: true);
  }

  Future<void> onSearch() async {
    await fetchStagePageData(reset: true);
  }

  int? getLaneIndex(CompositionStageModel stage) {
    final String genreNid = stage.genreNid ?? '';
    if (genreNid.isEmpty) return null;
    final int index = laneGenreNidList.indexOf(genreNid);
    return index == -1 ? null : index;
  }

  CompositionGenreModel? getLaneGenre(int laneIndex) {
    if (laneIndex < 0 || laneIndex >= laneGenreNidList.length) return null;
    return findGenre(laneGenreNidList[laneIndex]);
  }

  Color? getLaneGenreColor(int laneIndex) {
    final CompositionGenreModel? genre = getLaneGenre(laneIndex);
    if (genre == null) return null;
    final Color? themeColor = genreThemeColorMap[genre.nid ?? ''];
    if (themeColor != null) return themeColor;
    return ColorUtils.parseColor(genre.color);
  }

  String getLaneTitle(int laneIndex) {
    return getLangText(getLaneGenre(laneIndex)?.name, 'zh');
  }

  String getLaneSubtitle(int laneIndex) {
    return getLangText(getLaneGenre(laneIndex)?.name, 'en');
  }

  String getLangText(List<LanguageText>? values, String lang) {
    if (values == null || values.isEmpty) return '';
    for (int i = 0; i < values.length; i++) {
      if ((values[i].lang ?? '').toLowerCase() == lang.toLowerCase()) {
        return values[i].text ?? '';
      }
    }
    return '';
  }

  String getMilestoneLabel(CompositionStageModel stage) {
    final List<String> labels = stage.milestoneList
        .map((item) => getLangText(item.name, 'zh'))
        .where((text) => text.isNotEmpty)
        .toList();
    return labels.join(' / ');
  }

  String getStageCoverUrl(CompositionStageModel stage) {
    if ((stage.coverUrl ?? '').isNotEmpty) return stage.coverUrl!;
    if ((stage.compositionBlueprint?.coverUrl ?? '').isNotEmpty) return stage.compositionBlueprint!.coverUrl!;
    return '';
  }

  CompositionGenreModel? findGenre(String? nid) {
    if (nid == null || nid.isEmpty) return null;
    return genreMap[nid];
  }

  ParagraphRhetoricalEntityList? findBeat(String? nid) {
    if (nid == null || nid.isEmpty) return null;
    return beatMap[nid];
  }

  String getBeatName(String? beatNid) {
    if (beatNid == 'head') return '文首';
    if (beatNid == 'tail') return '文末';
    final ParagraphRhetoricalEntityList? beat = findBeat(beatNid);
    return getLangText((beat?.name ?? const <LanguageText?>[]).whereType<LanguageText>().toList(), 'zh');
  }

  Color getBeatColor(String? beatNid) {
    final ParagraphRhetoricalEntityList? beat = findBeat(beatNid);
    final Color? color = beat?.currentThemeColor?.colorValue;
    if (color != null) return color;
    return AppTheme.cBorderThin.color;
  }

  String getGenreLabel(String? genreNid) {
    return getLangText(findGenre(genreNid)?.name, 'zh');
  }

  Color getGenreColor(String? genreNid) {
    final Color? themeColor = genreThemeColorMap[genreNid ?? ''];
    if (themeColor != null) return themeColor;
    final Color? mappedColor = ColorUtils.parseColor(findGenre(genreNid)?.color);
    if (mappedColor != null) return mappedColor;
    if (genreNid == 'narrative') return AppTheme.cSurfaceWarning.color;
    if (genreNid == 'expository') return AppTheme.cSurfaceSuccess.color;
    if (genreNid == 'argumentative') return AppTheme.cSurfaceInfo.color;
    if (genreNid == 'practical') return AppTheme.cTextBrand.color;
    return AppTheme.cTextSecondary.color;
  }

  bool hasHead(CompositionStageModel stage) {
    return stage.compositionBlueprint?.frame?.hasHead == true;
  }

  bool hasTail(CompositionStageModel stage) {
    return stage.compositionBlueprint?.frame?.hasTail == true;
  }

  String getHeadLabel(CompositionStageModel stage) {
    final List<LanguageText> names = stage.compositionBlueprint?.frame?.headName ?? const <LanguageText>[];
    return getLangText(names, 'zh');
  }

  String getTailLabel(CompositionStageModel stage) {
    final List<LanguageText> names = stage.compositionBlueprint?.frame?.tailName ?? const <LanguageText>[];
    return getLangText(names, 'zh');
  }

  String getFillLabel(String? fill) {
    if (fill == 'write') return '写';
    if (fill == 'given') return '给';
    if (fill == 'hidden') return '无';
    return '无';
  }

  List<String> buildStageBeatNidList(CompositionStageModel stage) {
    final List<String> beatNids = <String>[
      if (hasHead(stage)) 'head',
      ...beatNidOrderList,
      if (hasTail(stage)) 'tail',
    ];
    return beatNids;
  }

  List<CompositionStageMilestoneGroupModel> buildMilestoneGroups() {
    return mapMilestoneGroups.toList();
  }

  /// 底栏文类计数：书架数蓝图，地图直接取接口给的全量阶梯数，不按当前已加载列表算。
  Map<String, int> buildGenreCountMap() {
    final Map<String, int> counts = <String, int>{};
    if (currentView.value == 'shelf') {
      for (final CompositionShelfBlueprintModel blueprint in shelfBlueprintList) {
        final String genreNid = blueprint.genreNid ?? '';
        if (genreNid.isEmpty) continue;
        counts[genreNid] = (counts[genreNid] ?? 0) + 1;
      }
      return counts;
    }
    for (final CompositionGenreSummaryModel item in discourseHome.value?.genres ?? const <CompositionGenreSummaryModel>[]) {
      final String genreNid = item.genre?.nid ?? '';
      if (genreNid.isEmpty) continue;
      counts[genreNid] = item.compositionStageCount ?? 0;
    }
    return counts;
  }

  /// 底栏文类计数的单位，跟着视图走。
  String getGenreCountUnit() {
    return currentView.value == 'shelf' ? '张蓝图' : '个阶梯';
  }

  /// 面包屑右侧的汇总文案：数字 + 接口后缀，如「45 张蓝图 · 六道大关」。
  String getSummaryText() {
    final CompositionDiscourseHomeModel? home = discourseHome.value;
    if (home == null) return '';
    final bool isShelf = currentView.value == 'shelf';
    final String suffix = (isShelf ? home.shelfSummaryText : home.mapSummaryText) ?? '';
    if (suffix.isEmpty) return '';
    final int count = isShelf ? shelfBlueprintList.length : stageTotalCount.value;
    if (count == 0) return '';
    return '$count $suffix';
  }

  void showPlaceholderAction(String actionText) {
    ToastUtils.showManageToast(text: '$actionText 暂未接入，本期先完成 UI。');
  }

  Future<void> openEditPage(CompositionStageModel stage) async {
    final String nid = stage.nid ?? '';
    if (nid.isEmpty) return;
    final dynamic result = await TagRoutes.toNamed(
      Routes.ZHENXIE_COMPOSITION_STAGE_EDIT,
      arguments: <String, dynamic>{
        'stageNid': nid,
        'isManagement': isManagement,
      },
    );
    if (result == true) {
      await fetchStagePageData(reset: true);
    }
  }

  Future<void> openBlueprintPage(CompositionStageModel stage) async {
    final String familyNid = stage.compositionBlueprint?.compositionFamilyNid ?? '';
    final String blueprintNid = stage.compositionBlueprint?.nid ?? '';
    if (familyNid.isEmpty || blueprintNid.isEmpty) return;
    await TagRoutes.toNamed(
      Routes.ZHENXIE_ARTICLE_BLUEPRINT_DETAILS,
      arguments: <String, dynamic>{
        'nid': familyNid,
        'blueprintNid': blueprintNid,
        'isManagement': isManagement,
      },
    );
  }

  Future<void> openTaskPage(CompositionStageModel stage) async {
    final String nid = stage.nid ?? '';
    await TagRoutes.toNamed(
      Routes.ZHENXIE_COMPOSITION_WRITING,
      arguments: <String, dynamic>{
        'stageNid': nid,
        'isManagement': isManagement,
      },
    );
  }

  Future<void> openExemplarPage(CompositionStageModel stage) async {
    final String nid = stage.nid ?? '';
    await TagRoutes.toNamed(
      Routes.ZHENXIE_COMPOSITION_INSTANCES,
      arguments: <String, dynamic>{
        'stageNid': nid,
        'isManagement': isManagement,
      },
    );
  }

  /// 书架瓦片点开：按家族维度打开这张蓝图的详情。
  Future<void> openShelfBlueprintPage(CompositionShelfBlueprintModel blueprint) async {
    final String familyNid = blueprint.compositionFamilyNid ?? '';
    final String blueprintNid = blueprint.nid ?? '';
    if (familyNid.isEmpty || blueprintNid.isEmpty) return;
    await TagRoutes.toNamed(
      Routes.ZHENXIE_ARTICLE_BLUEPRINT_DETAILS,
      arguments: <String, dynamic>{
        'nid': familyNid,
        'blueprintNid': blueprintNid,
        'isManagement': isManagement,
      },
    );
  }

  /// 底栏段型点开：打开这个段型的段蓝图详情。
  Future<void> openShelfParagraphType(String typeNid) async {
    if (typeNid.isEmpty) return;
    await TagRoutes.toNamed(
      Routes.ZHENXIE_PARAGRAPH_BLUEPRINT_DETAILS,
      arguments: <String, dynamic>{
        'nid': typeNid,
        'isManagement': isManagement,
      },
    );
  }

  void _tryAutoOpenDoor() {
    if (hasAutoOpenedDoor) return;
    if (autoOpenDoorCode == null || autoOpenDoorCode!.isEmpty) return;
    hasAutoOpenedDoor = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (autoOpenDoorCode) {
        case 'articleBlueprint':
          TagRoutes.toNamed(
            Routes.ZHENXIE_ARTICLE_BLUEPRINT,
            arguments: <String, dynamic>{'isManagement': isManagement},
          );
          return;
        case 'paragraphBlueprint':
          TagRoutes.toNamed(
            Routes.ZHENXIE_PARAGRAPH_BLUEPRINT,
            arguments: <String, dynamic>{'isManagement': isManagement},
          );
          return;
        case 'compositionStage':
          currentView.value = 'map';
          return;
      }
    });
  }

  Future<void> fetchStagePageData({required bool reset}) async {
    final int requestOffset = reset ? 0 : _mapOffset;
    if (!reset && (!hasMoreMapStageData.value || isMapPaging.value)) return;
    if (!reset) {
      isMapPaging.value = true;
    }
    ToastUtils.showLoading();
    try {
      final Map<String, dynamic>? stagePageData = isManagement
          ? await LanguageConsoleRequest.getWriteCompositionStagePages(
              parameters: _buildPageParameters(offset: requestOffset, limit: _mapPageSize),
              data: _buildPageBody(),
            )
          : await ZhenxieRequest.getCompositionStagePages(
              parameters: _buildPageParameters(offset: requestOffset, limit: _mapPageSize),
            );
      if (stagePageData == null) {
        if (reset) {
          stageList.clear();
          filteredStageList.clear();
          mapColumns.clear();
          mapMilestoneGroups.clear();
          stageTotalCount.value = 0;
          hasMoreMapStageData.value = false;
          _mapOffset = 0;
        }
        return;
      }

      final ListResponseEntity<CompositionStageModel> page = ListResponseEntity<CompositionStageModel>.fromJson(
        stagePageData,
        fromJson: CompositionStageModel.fromJson,
      );
      final List<CompositionStageModel> stages = (page.datas ?? <CompositionStageModel>[])
          .where((item) => item.enabled != false)
          .toList();
      final List<CompositionStageModel> nextStages = reset
          ? stages
          : <CompositionStageModel>[
              ...stageList,
              ...stages,
            ];
      stageList.assignAll(nextStages);
      filteredStageList.assignAll(nextStages);
      stageTotalCount.value = page.count ?? nextStages.length;
      _mapOffset = nextStages.length;
      hasMoreMapStageData.value = nextStages.length < stageTotalCount.value;
      _rebuildMapData();
      if (reset) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mapScrollController.hasClients) {
            mapScrollController.jumpTo(0);
          }
          if (listScrollController.hasClients) {
            listScrollController.jumpTo(0);
          }
        });
      }
    } finally {
      ToastUtils.hideLoading();
      isMapPaging.value = false;
    }
  }

  Map<String, dynamic> _buildPageBody() {
    final String content = filterSearchs["content"]?.controller.text.trim() ?? '';
    final List<Map<String, dynamic>> filters = filterConditions.entries
        .map((entry) {
          final List<String> values = entry.value.conditions
              .where((item) => item.selected)
              .map((item) => item.value?.toString() ?? '')
              .where((item) => item.isNotEmpty)
              .toList();
          if (values.isEmpty) return null;
          return <String, dynamic>{
            'code': entry.key,
            'values': values,
          };
        })
        .whereType<Map<String, dynamic>>()
        .toList();
    return <String, dynamic>{
      'content': content,
      if (filters.isNotEmpty) 'filters': filters,
    };
  }

  Future<void> loadMoreMapStageData() async {
    if (currentView.value != 'map') return;
    await fetchStagePageData(reset: false);
  }

  Future<void> loadMoreListStageData() async {
    if (currentView.value != 'list') return;
    await fetchStagePageData(reset: false);
  }

  /// 分页参数：用户端只要 offset / limit，排序只有管理端有。
  Map<String, dynamic> _buildPageParameters({required int offset, required int limit}) {
    return <String, dynamic>{
      'offset': offset,
      'limit': limit,
      if (isManagement) 'order': currentView.value == 'list' ? _currentOrderValue() : 'order',
    };
  }

  String _currentOrderValue() {
    final FilterSortsData? sortData = filterSorts['sortBy'];
    FilterSortsItem? selected;
    for (final FilterSortsItem item in sortData?.sorts ?? <FilterSortsItem>[]) {
      if (item.selected) {
        selected = item;
        break;
      }
    }
    if (selected == null) return 'order';
    final String code = sortCodeMap[selected.name] ?? 'order';
    return selected.direction == FilterSortDirection.down ? '-$code' : code;
  }

  String _milestoneKey(CompositionStageModel stage) {
    final List<String> ids = stage.milestoneList
        .map((item) => item.nid ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
    if (ids.isNotEmpty) return ids.join('|');
    return stage.milestones.where((item) => item.isNotEmpty).join('|');
  }

  void _handleMapScroll() {
    if (currentView.value != 'map' || !mapScrollController.hasClients) return;
    if (isMapPaging.value || !hasMoreMapStageData.value) return;
    final ScrollPosition position = mapScrollController.position;
    if (position.maxScrollExtent - position.pixels <= 360) {
      loadMoreMapStageData();
    }
  }

  void _handleListScroll() {
    if (currentView.value != 'list' || !listScrollController.hasClients) return;
    if (isMapPaging.value || !hasMoreMapStageData.value) return;
    final ScrollPosition position = listScrollController.position;
    if (position.maxScrollExtent - position.pixels <= 360) {
      loadMoreListStageData();
    }
  }

  void _rebuildMapData() {
    final List<CompositionStageModel> stages = filteredStageList.toList();
    final List<CompositionStageMapColumnModel> nextColumns = <CompositionStageMapColumnModel>[];
    final List<CompositionStageMilestoneGroupModel> nextGroups = <CompositionStageMilestoneGroupModel>[];
    for (int index = 0; index < stages.length; index++) {
      final CompositionStageModel stage = stages[index];
      final String key = _milestoneKey(stage);
      final String previousKey = index > 0 ? _milestoneKey(stages[index - 1]) : '';
      final String nextKey = index + 1 < stages.length ? _milestoneKey(stages[index + 1]) : '';
      final CompositionStageMilestoneSegmentType segment = _resolveMilestoneSegment(
        key: key,
        previousKey: previousKey,
        nextKey: nextKey,
      );
      nextColumns.add(
        CompositionStageMapColumnModel(
          columnIndex: index,
          stage: stage,
          laneIndex: getLaneIndex(stage),
          milestoneKey: key,
          milestoneLabel: getMilestoneLabel(stage),
          milestoneSegment: segment,
        ),
      );
    }

    int index = 0;
    while (index < nextColumns.length) {
      final CompositionStageMapColumnModel column = nextColumns[index];
      if (column.milestoneKey.isEmpty) {
        index += 1;
        continue;
      }
      int endIndex = index;
      while (endIndex + 1 < nextColumns.length && nextColumns[endIndex + 1].milestoneKey == column.milestoneKey) {
        endIndex += 1;
      }
      nextGroups.add(
        CompositionStageMilestoneGroupModel(
          startIndex: index,
          endIndex: endIndex,
          key: column.milestoneKey,
          label: column.milestoneLabel,
            milestoneList: column.stage.milestoneList,
        ),
      );
      index = endIndex + 1;
    }

    mapColumns.assignAll(nextColumns);
    mapMilestoneGroups.assignAll(nextGroups);
  }

  CompositionStageMilestoneSegmentType _resolveMilestoneSegment({
    required String key,
    required String previousKey,
    required String nextKey,
  }) {
    if (key.isEmpty) return CompositionStageMilestoneSegmentType.none;
    final bool hasPrevious = previousKey == key;
    final bool hasNext = nextKey == key;
    if (!hasPrevious && !hasNext) return CompositionStageMilestoneSegmentType.single;
    if (!hasPrevious) return CompositionStageMilestoneSegmentType.start;
    if (!hasNext) return CompositionStageMilestoneSegmentType.end;
    return CompositionStageMilestoneSegmentType.middle;
  }

  void _rebuildGenreMap() {
    genreMap
      ..clear()
      ..addEntries(
        genreList
            .where((item) => (item.nid ?? '').isNotEmpty)
            .map((item) => MapEntry(item.nid!, item)),
      );
  }

  /// 按当前项目主题取文类色：LIGHT / DARK 各一套，直接读接口 colors[]。
  void _rebuildGenreThemeColorMap(CompositionDiscourseHomeModel? home) {
    genreThemeColorMap.clear();
    if (home == null) return;
    final String themeName = ThemeUtils.isCurrentTheme('DARK') ? 'DARK' : 'LIGHT';
    for (final CompositionGenreSummaryModel item in home.genres) {
      final String nid = item.genre?.nid ?? '';
      if (nid.isEmpty) continue;
      final Color? color = ColorUtils.parseColor(item.themeColorCode(themeName));
      if (color != null) genreThemeColorMap[nid] = color;
    }
  }

  /// 书架大关：接口 milestones 已按难度分组排好，学段 / 雅思当抬头，其余进别名。
  List<CompositionShelfGateModel> _buildShelfGates(CompositionDiscourseHomeModel? home) {
    final List<CompositionShelfGateModel> gates = <CompositionShelfGateModel>[];
    for (final CompositionMilestoneGateModel group in home?.milestones ?? <CompositionMilestoneGateModel>[]) {
      final List<CompositionMilestoneModel> items = group.items;
      CompositionMilestoneModel? head;
      for (final CompositionMilestoneModel item in items) {
        if (item.kind == 'school') {
          head = item;
          break;
        }
      }
      if (head == null) {
        for (final CompositionMilestoneModel item in items) {
          if (item.kind == 'ielts') {
            head = item;
            break;
          }
        }
      }
      gates.add(
        CompositionShelfGateModel(
          difficulty: group.difficulty ?? 0,
          title: head == null ? '入门' : _shelfGateShortName(head),
          alias: items.where((item) => item != head).map(_shelfGateShortName).join(' · '),
        ),
      );
    }
    return gates;
  }

  /// 大关抬头 / 别名用的短名：剥掉「剑桥 」前缀，没文案时退回 nid。
  String _shelfGateShortName(CompositionMilestoneModel item) {
    final String name = getLangText(item.name, 'zh');
    final String text = name.isEmpty ? (item.nid ?? '') : name;
    return text.replaceFirst(RegExp(r'^剑桥\s*'), '');
  }

  List<CompositionShelfBlueprintModel> _parseShelfBlueprints(Map<String, dynamic>? response) {
    return (response?['list'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(CompositionShelfBlueprintModel.fromJson)
        .toList();
  }

  void _rebuildBeatMap(ParagraphRhetoricalEntity? beatEntity) {
    beatNidOrderList.assignAll(
      (beatEntity?.list ?? <ParagraphRhetoricalEntityList?>[])
          .whereType<ParagraphRhetoricalEntityList>()
          .map((item) => item.nid ?? '')
          .where((item) => item.isNotEmpty),
    );
    beatMap
      ..clear()
      ..addEntries(
        (beatEntity?.list ?? <ParagraphRhetoricalEntityList?>[])
            .whereType<ParagraphRhetoricalEntityList>()
            .where((item) => (item.nid ?? '').isNotEmpty)
            .map((item) => MapEntry(item.nid!, item)),
      );
  }

  Map<String, FilterConditionsData> _buildFilterConditions(FiltersGroupEntity metaGroup) {
    final Map<String, FilterConditionsData> next = <String, FilterConditionsData>{};
    for (final FiltersGroupEntityFilters? group in metaGroup.filters ?? <FiltersGroupEntityFilters?>[]) {
      if (group == null || (group.groupCode ?? '').isEmpty) continue;
      next[group.groupCode!] = FilterConditionsData(
        title: group.groupName ?? '',
        isSingle: group.radioGroup == true,
        component: group.component,
        radioGroup: group.radioGroup == true,
        conditions: (group.items ?? <FiltersGroupEntityValues?>[])
            .whereType<FiltersGroupEntityValues>()
            .map(
              (item) => FilterConditionsItem(
                name: item.name ?? '',
                value: item.value,
                selected: item.defaultValue == true,
              ),
            )
            .toList(),
      );
    }
    return next;
  }

  Map<String, FilterSortsData> _buildFilterSorts(FiltersGroupEntity metaGroup) {
    final List<FilterSortsItem> sorts = <FilterSortsItem>[];
    sortCodeMap.clear();
    for (final FiltersGroupEntityFilters? group in metaGroup.orders ?? <FiltersGroupEntityFilters?>[]) {
      if (group == null || (group.groupCode ?? '').isEmpty) continue;
      FiltersGroupEntityValues? defaultItem;
      for (final FiltersGroupEntityValues item in (group.items ?? <FiltersGroupEntityValues?>[]).whereType<FiltersGroupEntityValues>()) {
        if (item.defaultValue == true) {
          defaultItem = item;
          break;
        }
      }
      final FiltersGroupEntityValues? firstItem = (group.items ?? <FiltersGroupEntityValues?>[])
          .whereType<FiltersGroupEntityValues>()
          .cast<FiltersGroupEntityValues?>()
          .isNotEmpty
          ? (group.items ?? <FiltersGroupEntityValues?>[]).whereType<FiltersGroupEntityValues>().first
          : null;
      final String defaultValue = defaultItem?.value ?? firstItem?.value ?? group.groupCode!;
      final FilterSortDirection defaultDirection = defaultValue.startsWith('-')
          ? FilterSortDirection.down
          : FilterSortDirection.up;
      final String title = group.groupName ?? group.groupCode!;
      sortCodeMap[title] = group.groupCode!;
      sorts.add(
        FilterSortsItem(
          name: title,
          selected: group.groupCode == 'order',
          isDefault: group.groupCode == 'order',
          direction: defaultDirection,
        ),
      );
    }
    return <String, FilterSortsData>{
      'sortBy': FilterSortsData(
        title: '排序',
        sorts: sorts,
      ),
    };
  }

  @override
  void onClose() {
    mapScrollController.dispose();
    listScrollController.dispose();
    filterSearchs["content"]?.controller.dispose();
    super.onClose();
  }
}
