import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_data.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_beat_utils.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/mixins/mixins.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/common/widgets/filter_widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../routes/routes.dart';
import '../../../../zhenxie/zhenxie_composition_stages/models/zhenxie_composition_stages_models.dart';

class ManageUnitWritingStagePickController extends GetxController with DualBreadcrumbMixin {
  static const int _pageSize = 30;

  final String tagText;
  ManageUnitWritingStagePickController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.MANAGE_UNIT_WRITING_STAGE_PICK;

  @override
  String get breadcrumbTitle => '更换单元写作阶梯';

  int? unitId;
  bool isManagement = true;
  StageCardData? currentStageData;
  String currentStageNid = '';
  String currentStageName = '';
  int taskCount = 0;
  int compositionTaskCount = 0;

  final RxBool isLoading = false.obs;
  final RxBool isPaging = false.obs;
  final RxBool hasMoreStageData = true.obs;
  final RxInt stageTotalCount = 0.obs;
  final RxString selectedStageNid = ''.obs;
  final RxList<CompositionStageModel> stageList = <CompositionStageModel>[].obs;
  final RxList<StageCardData> stageCardList = <StageCardData>[].obs;
  final RxList<CompositionGenreModel> genreList = <CompositionGenreModel>[].obs;
  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{}.obs;
  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{}.obs;
  final RxList<String> beatNidOrderList = <String>[].obs;
  final Map<String, ParagraphRhetoricalEntityList> beatMap = <String, ParagraphRhetoricalEntityList>{};
  final Map<String, CompositionGenreModel> genreMap = <String, CompositionGenreModel>{};
  final Map<String, String> sortCodeMap = <String, String>{};
  final Map<String, FilterSearchsData> filterSearchs = <String, FilterSearchsData>{
    'content': FilterSearchsData(
      title: '搜索',
      hintText: '名字 / 蓝图 / 家族 / 文类 / 考试',
      controller: TextEditingController(),
    ),
  };
  final ScrollController listScrollController = ScrollController();

  int _offset = 0;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    final Map args = Get.arguments is Map ? Get.arguments : <String, dynamic>{};
    unitId = _parseInt(args['unitId']);
    final dynamic isManagementValue = args['isManagement'];
    if (isManagementValue != null) {
      isManagement = isManagementValue == true || isManagementValue.toString() == 'true';
    }
    final Map<String, dynamic>? currentStageJson = args['currentStage'] is Map
        ? Map<String, dynamic>.from(args['currentStage'] as Map)
        : null;
    if (currentStageJson != null) {
      currentStageData = StageCardData.fromJson(
        currentStageJson,
        coverUrl: _getStageCoverUrlFromJson(currentStageJson),
      );
    }
    currentStageNid = args['currentStageNid']?.toString() ?? currentStageData?.nid ?? '';
    currentStageName = args['currentStageName']?.toString() ?? getLangText(currentStageData?.name, 'zh');
    taskCount = _parseInt(args['taskCount']) ?? 0;
    compositionTaskCount = _parseInt(args['compositionTaskCount']) ?? 0;
    listScrollController.addListener(_handleListScroll);
    initData();
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  Future<void> initData() async {
    try {
      isLoading.value = true;
      ToastUtils.showLoading();
      await ensureZhenxieBeatData();
      final FiltersGroupEntity? metaGroup = await LanguageConsoleRequest.getWriteCompositionStageQueryMetaGroupList();
      final List<Map<String, dynamic>>? genreResponse = await LanguageConsoleRequest.getWriteCompositionGenreList();
      genreList.assignAll(
        (genreResponse ?? <Map<String, dynamic>>[])
            .map(CompositionGenreModel.fromJson)
            .where((item) => (item.nid ?? '').isNotEmpty)
            .toList(),
      );
      genreMap
        ..clear()
        ..addEntries(
          genreList
              .where((item) => (item.nid ?? '').isNotEmpty)
              .map((item) => MapEntry(item.nid!, item)),
        );
      if (metaGroup != null) {
        filterConditions.value = _buildFilterConditions(metaGroup);
        filterSorts.value = _buildFilterSorts(metaGroup);
      }
      await _fetchStagePageData(reset: true, showLoading: false);
    } finally {
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }

  Future<void> fetchData({bool showLoading = true}) async {
    await _fetchStagePageData(reset: true, showLoading: showLoading);
  }

  Future<void> _fetchStagePageData({required bool reset, required bool showLoading}) async {
    final int requestOffset = reset ? 0 : _offset;
    if (!reset && (!hasMoreStageData.value || isPaging.value)) return;
    if (reset) {
      isLoading.value = true;
      if (showLoading) {
        ToastUtils.showLoading();
      }
    } else {
      isPaging.value = true;
    }
    try {
      final Map<String, dynamic>? response = await LanguageConsoleRequest.getWriteCompositionStagePages(
        parameters: _buildPageParameters(offset: requestOffset, limit: _pageSize),
        data: _buildPageBody(),
      );
      if (response == null) {
        if (reset) {
          stageList.clear();
          stageCardList.clear();
          stageTotalCount.value = 0;
          hasMoreStageData.value = false;
          _offset = 0;
        }
        return;
      }
      final ListResponseEntity<CompositionStageModel> page = ListResponseEntity<CompositionStageModel>.fromJson(
        response,
        fromJson: CompositionStageModel.fromJson,
      );
      final List<StageCardData> cards = _removeCurrentStageCardDuplicate(_buildStageCardDataList(response['datas']));
      final List<CompositionStageModel> stages = _removeCurrentStageDuplicate(
        (page.datas ?? <CompositionStageModel>[])
            .where((item) => item.enabled != false)
            .toList(),
      );
      final List<CompositionStageModel> nextStages = reset
          ? _prependCurrentStage(stages)
          : <CompositionStageModel>[
              ...stageList,
              ...stages,
            ];
      final List<StageCardData> nextCards = reset
          ? _prependCurrentStageCard(cards)
          : <StageCardData>[
              ...stageCardList,
              ...cards,
            ];
      stageList.assignAll(nextStages);
      stageCardList.assignAll(nextCards);
      stageTotalCount.value = page.count ?? nextStages.length;
      _offset = requestOffset + (page.datas ?? <CompositionStageModel>[]).where((item) => item.enabled != false).length;
      hasMoreStageData.value = _offset < stageTotalCount.value;
      if (reset) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (listScrollController.hasClients) {
            listScrollController.jumpTo(0);
          }
        });
      }
    } finally {
      if (reset) {
        isLoading.value = false;
        if (showLoading) {
          ToastUtils.hideLoading();
        }
      } else {
        isPaging.value = false;
      }
    }
  }

  List<StageCardData> _buildStageCardDataList(dynamic values) {
    return (values as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map((item) => StageCardData.fromJson(item, coverUrl: _getStageCoverUrlFromJson(item)))
        .where((item) => item.enabled != false)
        .toList();
  }

  List<CompositionStageModel> _removeCurrentStageDuplicate(List<CompositionStageModel> values) {
    if (currentStageNid.isEmpty) return values;
    return values.where((item) => item.nid != currentStageNid).toList();
  }

  List<StageCardData> _removeCurrentStageCardDuplicate(List<StageCardData> values) {
    if (currentStageNid.isEmpty) return values;
    return values.where((item) => item.nid != currentStageNid).toList();
  }

  List<CompositionStageModel> _prependCurrentStage(List<CompositionStageModel> values) {
    if (currentStageData == null || currentStageNid.isEmpty) return values;
    return <CompositionStageModel>[
      currentStageData!.toCompositionStageModel(),
      ...values,
    ];
  }

  List<StageCardData> _prependCurrentStageCard(List<StageCardData> values) {
    if (currentStageData == null || currentStageNid.isEmpty) return values;
    return <StageCardData>[
      currentStageData!,
      ...values,
    ];
  }

  Map<String, dynamic> _buildPageParameters({required int offset, required int limit}) {
    return <String, dynamic>{
      'offset': offset,
      'limit': limit,
      'order': _currentOrderValue(),
    };
  }

  Map<String, dynamic> _buildPageBody() {
    final String content = filterSearchs['content']?.controller.text.trim() ?? '';
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

  String _getStageCoverUrlFromJson(Map<String, dynamic> json) {
    if ((json['coverUrl'] ?? '').toString().isNotEmpty) return json['coverUrl'].toString();
    final Map<String, dynamic>? blueprint = json['compositionBlueprint'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['compositionBlueprint'] as Map<String, dynamic>)
        : null;
    if ((blueprint?['coverUrl'] ?? '').toString().isNotEmpty) return blueprint!['coverUrl'].toString();
    return '';
  }

  Future<void> onConditionsChanged(Map<String, FilterConditionsData> conditions) async {
    filterConditions.value = conditions;
    await fetchData(showLoading: true);
  }

  Future<void> onSortsChanged(Map<String, FilterSortsData> sorts) async {
    filterSorts.value = sorts;
    await fetchData(showLoading: true);
  }

  Future<void> onResetFilters(
    Map<String, FilterSortsData> sorts,
    Map<String, FilterConditionsData> conditions,
  ) async {
    filterSorts.value = sorts;
    filterConditions.value = conditions;
    filterSearchs['content']?.controller.clear();
    await fetchData(showLoading: true);
  }

  Future<void> onSearch() async {
    await fetchData(showLoading: true);
  }

  void _handleListScroll() {
    if (!listScrollController.hasClients) return;
    if (isPaging.value || !hasMoreStageData.value) return;
    final ScrollPosition position = listScrollController.position;
    if (position.maxScrollExtent - position.pixels <= 360) {
      _fetchStagePageData(reset: false, showLoading: false);
    }
  }

  void selectStage(String stageNid) {
    selectedStageNid.value = stageNid;
  }

  bool isStageHighlighted(String stageNid) {
    final String selectedNid = selectedStageNid.value.isNotEmpty ? selectedStageNid.value : currentStageNid;
    return selectedNid.isNotEmpty && selectedNid == stageNid;
  }

  bool get canConfirm {
    final String targetStageNid = selectedStageNid.value.isNotEmpty ? selectedStageNid.value : currentStageNid;
    return targetStageNid.isNotEmpty;
  }

  Future<void> confirmSelection(BuildContext context) async {
    final String targetStageNid = selectedStageNid.value.isNotEmpty ? selectedStageNid.value : currentStageNid;
    if (targetStageNid.isEmpty) {
      ToastUtils.showManageToast(text: '请选择一个阶梯');
      return;
    }
    if (targetStageNid == currentStageNid) {
      Get.back<String>(result: targetStageNid);
      return;
    }
    if (currentStageNid.isNotEmpty && (taskCount > 0 || compositionTaskCount > 0)) {
      final String targetStageName = getStageName(targetStageNid);
      final bool askRes = await AskDialog.showUserAsk(
        context: context,
        title: '更换阶梯',
        content: '确定更换为「$targetStageName」吗？当前单元的 $taskCount 个任务和 $compositionTaskCount 篇范文都会解除挂载。',
        titleColor: AppTheme.cSurfaceError.color,
        defineColor: AppTheme.cSurfaceError.color,
      );
      if (!askRes) return;
    }
    Get.back<String>(result: targetStageNid);
  }

  String getStageName(String stageNid) {
    for (final CompositionStageModel item in stageList) {
      if (item.nid == stageNid) {
        return getLangText(item.name, 'zh');
      }
    }
    if (stageNid == currentStageNid && currentStageName.isNotEmpty) {
      return currentStageName;
    }
    return stageNid;
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

  String getDifficultyLabel(CardContentDifficulty? difficulty) {
    final String minDifficultyLabel = DifficultieUtils.getLanguageDifficultieLevel1('en', difficulty?.min)?.name?.text ?? '';
    final String maxDifficultyLabel = DifficultieUtils.getLanguageDifficultieLevel1('en', difficulty?.max)?.name?.text ?? '';
    if (minDifficultyLabel.isEmpty || maxDifficultyLabel.isEmpty) return '';
    return minDifficultyLabel == maxDifficultyLabel ? minDifficultyLabel : '$minDifficultyLabel-$maxDifficultyLabel';
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

  String getGenreLabel(String? genreNid) {
    return getLangText(findGenre(genreNid)?.name, 'zh');
  }

  Color getGenreColor(String? genreNid) {
    if (genreNid == 'narrative') return AppTheme.cSurfaceWarning.color;
    if (genreNid == 'expository') return AppTheme.cSurfaceSuccess.color;
    if (genreNid == 'argumentative') return AppTheme.cSurfaceInfo.color;
    if (genreNid == 'practical') return AppTheme.cTextBrand.color;
    return AppTheme.cTextSecondary.color;
  }

  String getBeatName(String? beatNid) {
    if (beatNid == 'head') return '文首';
    if (beatNid == 'tail') return '文末';
    final ParagraphRhetoricalEntityList? beat = beatMap[beatNid];
    return getLangText((beat?.name ?? const <LanguageText?>[]).whereType<LanguageText>().toList(), 'zh');
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

  String getAnswerTypeText(String? answerKind) {
    if (answerKind == 'text') return '文字';
    if (answerKind == 'image') return '图片';
    if (answerKind == 'audio') return '音频';
    if (answerKind == 'video') return '视频';
    return '';
  }

  String getAnswerDetailText(CompositionStageModel stage) {
    if (stage.answerKind == null || stage.answerKind == 'text') return '';
    final int? answerMinCount = stage.answerMinCount;
    final int? answerMaxCount = stage.answerMaxCount;
    if (answerMinCount != null && answerMaxCount != null) {
      if (answerMinCount == answerMaxCount) return '$answerMinCount份';
      return '$answerMinCount-$answerMaxCount份';
    }
    if (answerMinCount != null) return '$answerMinCount份';
    if (answerMaxCount != null) return '$answerMaxCount份';
    return '';
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
    listScrollController.dispose();
    filterSearchs['content']?.controller.dispose();
    super.onClose();
  }
}
