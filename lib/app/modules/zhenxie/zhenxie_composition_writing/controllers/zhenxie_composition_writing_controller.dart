import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/mixins/mixins.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/common/widgets/zhenxie_widgets/writing_boards/model/writing_board_data.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';

import '../../zhenxie_composition_stages/models/zhenxie_composition_stages_models.dart';
import '../models/zhenxie_composition_writing_models.dart';

class ZhenxieCompositionWritingController extends GetxController with DualBreadcrumbMixin {
  static const int _pageSize = 30;

  final String tagText;

  ZhenxieCompositionWritingController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_COMPOSITION_WRITING;

  @override
  String get breadcrumbTitle => "写作任务";

  bool isManagement = false;
  String stageNid = '';

  final Map<String, FilterSearchsData> filterSearchs = {
    "content": FilterSearchsData(
      title: "搜索",
      hintText: "任务名 / 题干 / 蓝图 / 家族 / 文类",
      controller: TextEditingController(),
    ),
  };

  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{}.obs;
  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPaging = false.obs;
  final RxBool hasMoreTaskData = true.obs;
  final RxInt taskTotalCount = 0.obs;
  final RxList<CompositionTaskModel> taskList = <CompositionTaskModel>[].obs;
  final RxList<CompositionGenreModel> genreList = <CompositionGenreModel>[].obs;
  final RxList<String> beatNidOrderList = <String>[].obs;
  final ScrollController listScrollController = ScrollController();

  final Map<String, CompositionGenreModel> genreMap = <String, CompositionGenreModel>{};
  final Map<String, ParagraphRhetoricalEntityList> beatMap = <String, ParagraphRhetoricalEntityList>{};
  int _offset = 0;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    final dynamic arguments = Get.arguments;
    if (arguments is Map<String, dynamic>) {
      isManagement = arguments['isManagement'] == true;
      stageNid = arguments['stageNid']?.toString() ?? '';
    }
    listScrollController.addListener(_handleListScroll);
    initData();
  }

  Future<void> initData() async {
    final bool needBlockingLoading = taskList.isEmpty;
    try {
      isLoading.value = true;
      if (needBlockingLoading) {
        ToastUtils.showLoading();
      }
      if (needBlockingLoading) {
        final List<dynamic> responses = await Future.wait<dynamic>([
          LanguageConsoleRequest.getWriteCompositionTaskQueryMetaGroupList(),
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
        _rebuildGenreMap();
        _rebuildBeatMap(beatResponse);

        if (metaGroup != null) {
          filterConditions.value = FilterStripUtils.getConditionDataFrom(metaGroup);
          filterSorts.value = FilterStripUtils.getSortDataFrom(metaGroup);
        }
      }
      await fetchTaskPageData(reset: true);
    } finally {
      isLoading.value = false;
      if (needBlockingLoading) {
        ToastUtils.hideLoading();
      }
    }
  }

  Future<void> onConditionsChanged(Map<String, FilterConditionsData> conditions) async {
    filterConditions.value = conditions;
    await fetchTaskPageData(reset: true);
  }

  Future<void> onSortsChanged(Map<String, FilterSortsData> sorts) async {
    filterSorts.value = sorts;
    await fetchTaskPageData(reset: true);
  }

  Future<void> onResetFilters(
    Map<String, FilterSortsData> sorts,
    Map<String, FilterConditionsData> conditions,
  ) async {
    filterSorts.value = sorts;
    filterConditions.value = conditions;
    filterSearchs["content"]?.controller.clear();
    await fetchTaskPageData(reset: true);
  }

  Future<void> onSearch() async {
    await fetchTaskPageData(reset: true);
  }

  Future<void> fetchTaskPageData({required bool reset}) async {
    final int requestOffset = reset ? 0 : _offset;
    if (!reset && (!hasMoreTaskData.value || isPaging.value)) return;
    if (!reset) {
      isPaging.value = true;
    }
    ToastUtils.showLoading();
    try {
      final Map<String, dynamic>? taskPageData = await LanguageConsoleRequest.getWriteCompositionTaskPages(
        parameters: _buildPageParameters(offset: requestOffset, limit: _pageSize),
        data: _buildPageBody(),
      );
      if (taskPageData == null) {
        if (reset) {
          taskList.clear();
          taskTotalCount.value = 0;
          hasMoreTaskData.value = false;
          _offset = 0;
        }
        return;
      }

      final ListResponseEntity<CompositionTaskModel> page = ListResponseEntity<CompositionTaskModel>.fromJson(
        taskPageData,
        fromJson: CompositionTaskModel.fromJson,
      );
      final List<CompositionTaskModel> tasks = page.datas ?? <CompositionTaskModel>[];
      final List<CompositionTaskModel> nextTasks = reset
          ? tasks
          : <CompositionTaskModel>[
              ...taskList,
              ...tasks,
            ];
      taskList.assignAll(nextTasks);
      taskTotalCount.value = page.count ?? nextTasks.length;
      _offset = nextTasks.length;
      hasMoreTaskData.value = nextTasks.length < taskTotalCount.value;
      if (reset) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (listScrollController.hasClients) {
            listScrollController.jumpTo(0);
          }
        });
      }
    } finally {
      ToastUtils.hideLoading();
      isPaging.value = false;
    }
  }

  Map<String, dynamic> _buildPageParameters({required int offset, required int limit}) {
    final String order = _currentOrderValue();
    return <String, dynamic>{
      'offset': offset,
      'limit': limit,
      if (order.isNotEmpty) 'order': order,
    };
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
    if (stageNid.isNotEmpty) {
      filters.add(<String, dynamic>{
        'code': 'stageNid',
        'values': <String>[stageNid],
      });
    }
    return <String, dynamic>{
      'content': content,
      if (filters.isNotEmpty) 'filters': filters,
    };
  }

  String _currentOrderValue() {
    return FilterStripUtils.getSortOrderParameter(sorts: filterSorts)['order']?.toString() ?? '';
  }

  void _handleListScroll() {
    if (!listScrollController.hasClients) return;
    if (isPaging.value || !hasMoreTaskData.value) return;
    final ScrollPosition position = listScrollController.position;
    if (position.maxScrollExtent - position.pixels <= 360) {
      fetchTaskPageData(reset: false);
    }
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

  String getLangText(List<LanguageText>? values, String lang) {
    if (values == null || values.isEmpty) return '';
    for (int i = 0; i < values.length; i++) {
      if ((values[i].lang ?? '').toLowerCase() == lang.toLowerCase()) {
        return values[i].text ?? '';
      }
    }
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
    final Color? mappedColor = ColorUtils.parseColor(findGenre(genreNid)?.color);
    if (mappedColor != null) return mappedColor;
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
    return getLangText(stage.compositionBlueprint?.frame?.headName, 'zh');
  }

  String getTailLabel(CompositionStageModel stage) {
    return getLangText(stage.compositionBlueprint?.frame?.tailName, 'zh');
  }

  String getTaskCoverUrl(CompositionTaskModel task) {
    if ((task.coverUrl ?? '').isNotEmpty) return task.coverUrl!;
    if ((task.stage?.coverUrl ?? '').isNotEmpty) return task.stage!.coverUrl!;
    if ((task.blueprint?.coverUrl ?? '').isNotEmpty) return task.blueprint!.coverUrl!;
    if ((task.stage?.compositionBlueprint?.coverUrl ?? '').isNotEmpty) {
      return task.stage!.compositionBlueprint!.coverUrl!;
    }
    return '';
  }

  String getDifficultyLabel(CompositionTaskModel task) {
    final CardContentDifficulty? difficulty = task.stage?.difficulty;
    final String minDifficultyLabel = DifficultieUtils.getLanguageDifficultieLevel1('en', difficulty?.min)?.name?.text ?? '';
    final String maxDifficultyLabel = DifficultieUtils.getLanguageDifficultieLevel1('en', difficulty?.max)?.name?.text ?? '';
    if (minDifficultyLabel.isEmpty || maxDifficultyLabel.isEmpty) return '';
    return minDifficultyLabel == maxDifficultyLabel ? minDifficultyLabel : '$minDifficultyLabel-$maxDifficultyLabel';
  }

  String getResultText() {
    if (stageNid.isEmpty) return '当前 ${taskTotalCount.value} 道任务';
    return '当前 ${taskTotalCount.value} 道任务 · 阶梯 $stageNid';
  }

  void openTaskDetail(CompositionTaskModel task) {
    if (task.uid == null) {
      ToastUtils.showManageToast(text: '当前任务缺少 uid，暂时无法查看详情');
      return;
    }
    TagRoutes.toNamed(
      Routes.ZHENXIE_TASK_DETAILS,
      arguments: <String, dynamic>{
        'isManagement': isManagement,
        'taskUid': task.uid,
        'contentSource': WritingBoardContentSourceMacro.task.value,
        'editPolicy': WritingBoardEditPolicyMacro.stageRule.value,
      },
    );
  }

  @override
  void onClose() {
    listScrollController.dispose();
    filterSearchs["content"]?.controller.dispose();
    super.onClose();
  }
}
