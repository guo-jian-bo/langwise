import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/entities/card_public_entity.dart';
import 'package:langwise/common/entities/language_config_color_entity.dart';
import 'package:langwise/common/entities/zhendu_entity.dart';
import 'package:langwise/common/https/zhenxie.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/theme/theme_utils.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../zhenxie_exam/models/zhenxie_exam_models.dart';

/// 真题列表页控制器：直接消费后端 `meta + pages`，不再依赖首页本地假数据。
class ZhenxieExamTaskListController extends GetxController with RoutesBreadcrumbMixin {
  static const int pageSize = 30;

  final String tagText;
  final Map<String, String?> _initialParameters = <String, String?>{};

  ZhenxieExamTaskListController({
    required this.tagText,
  });

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_EXAM_TASKS;

  @override
  String get breadcrumbTitle => '真题';

  /// 搜索输入框控制器，只承载当前页面搜索关键字。
  final TextEditingController searchController = TextEditingController();

  /// 列表滚动控制器，用于下拉刷新与触底加载更多。
  final ScrollController scrollController = ScrollController();

  /// 搜索提示按接口返回轮换展示。
  final SearchHintRotator searchHintRotator = SearchHintRotator();

  /// 首屏与重置筛选时的阻塞加载态。
  final RxBool isLoading = true.obs;

  /// 空态开关，仅用于切换空数据占位。
  final RxBool isNotData = false.obs;

  /// 当前页真题列表，直接使用接口卡片 DTO。
  final RxList<ZhenxieExamTaskCardData> taskList = <ZhenxieExamTaskCardData>[].obs;

  /// 筛选/排序元数据。
  final Rxn<ZhenxieExamTaskQueryMetaData> metaData = Rxn<ZhenxieExamTaskQueryMetaData>();

  /// 当前筛选后的总题数与年份跨度。
  final RxInt total = 0.obs;
  final RxString yearRange = ''.obs;

  /// 当前底部筛选条已选中的分组值。
  final RxMap<String, List<String>> selectedFilters = <String, List<String>>{}.obs;

  /// 当前排序值，直接对应接口 `order` 参数。
  final RxString selectedOrderValue = ''.obs;

  final List<String> _hiddenTopicValues = <String>[];
  final List<String> _hiddenStageNidValues = <String>[];
  final List<ZhenxieExamTaskColorData> _milestoneColors = <ZhenxieExamTaskColorData>[];
  final List<ZhenxieExamTaskColorData> _familyColors = <ZhenxieExamTaskColorData>[];

  int _offset = 0;
  bool _loadingMore = false;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText, title: '真题');
    final dynamic arguments = Get.arguments;
    if (arguments is Map<String, dynamic>) {
      _initialParameters.addAll(arguments.map((key, value) => MapEntry(key.toString(), value?.toString())));
    } else if (arguments is Map) {
      _initialParameters.addAll(arguments.map((key, value) => MapEntry(key.toString(), value?.toString())));
    }
    _bindScrollListener();
    initPage();
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    searchHintRotator.dispose();
    super.onClose();
  }

  /// 初始化页面：先拿筛选元数据，再拉第一页真题。
  Future<void> initPage() async {
    isLoading.value = true;
    ToastUtils.showLoading();
    try {
      await _loadMetaData();
      await refreshList(showLoading: false);
    } finally {
      ToastUtils.hideLoading();
      isLoading.value = false;
    }
  }

  /// 下拉刷新当前筛选结果，不额外弹全局 loading。
  Future<void> refreshList({bool showLoading = true}) async {
    _offset = 0;
    _loadingMore = false;
    if (showLoading) {
      ToastUtils.showLoading();
    }
    try {
      await _loadTaskPage(reset: true);
    } finally {
      if (showLoading) {
        ToastUtils.hideLoading();
      }
    }
  }

  /// 触底加载下一页，保持现有筛选和排序不变。
  Future<void> loadMore() async {
    if (_loadingMore || !_hasMoreData()) return;
    _loadingMore = true;
    _offset = taskList.length;
    try {
      await _loadTaskPage(reset: false);
    } finally {
      _loadingMore = false;
    }
  }

  /// 应用筛选选择后回到第一页重拉。
  Future<void> applyConditionSelections(Map<String, List<String>> selections) async {
    selectedFilters
      ..clear()
      ..addAll(selections);
    await refreshList(showLoading: true);
  }

  /// 应用排序后回到第一页重拉。
  Future<void> applySortSelection(String value) async {
    if (value.isEmpty || value == selectedOrderValue.value) return;
    selectedOrderValue.value = value;
    await refreshList(showLoading: true);
  }

  /// 提交搜索关键字后回到第一页重拉。
  Future<void> submitSearch() async {
    final String keyword = searchController.text.trim();
    if (searchController.text != keyword) {
      searchController.text = keyword;
      searchController.selection = TextSelection.fromPosition(TextPosition(offset: keyword.length));
    }
    await refreshList(showLoading: true);
  }

  /// 重置当前页搜索、筛选和排序。
  Future<void> resetAll() async {
    searchController.clear();
    selectedFilters.clear();
    _hiddenTopicValues.clear();
    _hiddenStageNidValues.clear();
    _applyDefaultSort();
    await refreshList(showLoading: true);
  }

  /// 当前筛选分组，直接用于底部通用筛选组件。
  List<ZhenxieExamTaskQueryMetaGroupData> buildFilterGroups() {
    return metaData.value?.filters ?? const <ZhenxieExamTaskQueryMetaGroupData>[];
  }

  /// 当前排序分组，view 会拍平成单一排序列表。
  List<ZhenxieExamTaskQueryMetaGroupData> buildOrderGroups() {
    return metaData.value?.orders ?? const <ZhenxieExamTaskQueryMetaGroupData>[];
  }

  /// 当前搜索提示文案。
  String buildCurrentSearchHintText() {
    return searchHintRotator.currentHint.value.trim();
  }

  /// 面包屑右侧摘要文案。
  String buildBreadcrumbMetaText() {
    if (yearRange.value.isEmpty && total.value == 0) return '';
    if (yearRange.value.isEmpty) return '${total.value} 题';
    return '${yearRange.value} · ${total.value} 题';
  }

  /// 底部筛选条左侧摘要文案。
  String buildFilterSummaryText() {
    if (total.value <= 0) return '真题';
    return '${total.value}题';
  }

  /// 判断当前筛选项是否选中。
  bool isFilterSelected(String groupCode, String value) {
    return selectedFilters[groupCode]?.contains(value) == true;
  }

  /// 判断当前排序项是否选中。
  bool isSortSelected(String value) {
    return selectedOrderValue.value == value;
  }

  /// 取固定中文文案；无中文时退回首条非空文本。
  String buildZhText(List<LanguageText> texts) {
    return pickLocalizedText(texts.map((item) => item.toJson()).toList());
  }

  /// 真题卡片顶部地区文案。
  String buildRegionText(ZhenxieExamTaskCardData task) {
    return task.regions.map((item) => buildZhText(item.name)).where((item) => item.isNotEmpty).join(' / ');
  }

  /// 真题卡片右上角家族文案。
  String buildFamilyText(ZhenxieExamTaskCardData task) {
    return buildZhText(task.family.name);
  }

  /// 真题卡片底部写作阶梯文案。
  String buildStageText(ZhenxieExamTaskCardData task) {
    return buildZhText(task.stage.name);
  }

  /// 真题卡片右下角覆盖状态文案。
  String buildCoverageText(ZhenxieExamTaskCardData task) {
    return buildZhText(task.coverage.name);
  }

  /// 真题卡片顶部考段文案。
  String buildMilestoneText(ZhenxieExamTaskCardData task) {
    return buildZhText(task.milestoneName);
  }

  /// 真题卡片主题标签文案。
  List<String> buildTopicTexts(ZhenxieExamTaskCardData task) {
    return task.topics.map((item) => buildZhText(item.name)).where((item) => item.isNotEmpty).toList();
  }

  /// 真题卡片要点列表，最多展示前三条。
  List<String> buildVisibleRequiredPoints(ZhenxieExamTaskCardData task) {
    return task.requiredPoints.take(3).toList();
  }

  /// 取考段业务色。
  LanguageConfigColorEntityThemeColors? findMilestoneThemeColors(String code) {
    final ZhenxieExamTaskColorData? colorData = _milestoneColors.firstWhereOrNull((item) => item.code == code);
    if (colorData == null) return null;
    return findCurrentThemeColors(colorData.colors);
  }

  /// 取家族业务色。
  LanguageConfigColorEntityThemeColors? findFamilyThemeColors(String code) {
    final ZhenxieExamTaskColorData? colorData = _familyColors.firstWhereOrNull((item) => item.code == code);
    if (colorData == null) return null;
    return findCurrentThemeColors(colorData.colors);
  }

  /// 按项目当前 light/dark 主题取对应颜色块。
  LanguageConfigColorEntityThemeColors? findCurrentThemeColors(List<LanguageConfigColorEntityThemeColors> colors) {
    for (final LanguageConfigColorEntityThemeColors item in colors) {
      if (ThemeUtils.isCurrentTheme(item.theme ?? '')) return item;
    }
    final String themeKey = ThemeUtils.isCurrentTheme(AppThemeKey.light.value) ? AppThemeKey.light.value : AppThemeKey.dark.value;
    return colors.firstWhereOrNull((item) => (item.theme ?? '').toUpperCase() == themeKey);
  }

  void _bindScrollListener() {
    scrollController.addListener(() {
      if (!scrollController.hasClients) return;
      if (scrollController.position.pixels < scrollController.position.maxScrollExtent - 800.0.wMin) return;
      loadMore();
    });
  }

  Future<void> _loadMetaData() async {
    final Map<String, dynamic>? response = await ZhenxieRequest.getExamTaskQueryMetaGroupList();
    if (response == null) return;
    metaData.value = ZhenxieExamTaskQueryMetaData.fromJson(response);
    _restoreInitialQuery(_initialParameters);
    _applyDefaultSort();
    _updateSearchHints();
  }

  Future<void> _loadTaskPage({required bool reset}) async {
    final Map<String, dynamic>? response = await ZhenxieRequest.getExamTaskPages(
      data: _buildPageRequestData(),
      parameters: _buildPageRequestParameters(),
    );
    if (response == null) {
      if (reset) {
        taskList.clear();
        total.value = 0;
        yearRange.value = '';
        _milestoneColors.clear();
        _familyColors.clear();
        isNotData.value = true;
      }
      return;
    }

    final ZhenxieExamTaskPageData pageData = ZhenxieExamTaskPageData.fromJson(response);
    total.value = pageData.count;
    yearRange.value = pageData.yearRange;
    _milestoneColors
      ..clear()
      ..addAll(pageData.milestoneColors);
    _familyColors
      ..clear()
      ..addAll(pageData.familyColors);

    if (reset) {
      taskList.assignAll(pageData.datas);
    } else {
      taskList.addAll(pageData.datas);
    }
    isNotData.value = taskList.isEmpty;
  }

  Map<String, dynamic> _buildPageRequestData() {
    final List<Map<String, dynamic>> filters = <Map<String, dynamic>>[];

    for (final MapEntry<String, List<String>> entry in selectedFilters.entries) {
      final List<String> values = entry.value.where((item) => item.isNotEmpty).toList();
      if (values.isEmpty) continue;
      filters.add(<String, dynamic>{
        'code': entry.key,
        'values': values,
      });
    }

    if (_hiddenTopicValues.isNotEmpty) {
      filters.add(<String, dynamic>{
        'code': 'topicNids',
        'values': _hiddenTopicValues,
      });
    }
    if (_hiddenStageNidValues.isNotEmpty) {
      filters.add(<String, dynamic>{
        'code': 'stageNid',
        'values': _hiddenStageNidValues,
      });
    }

    final Map<String, dynamic> data = <String, dynamic>{};
    if (filters.isNotEmpty) {
      data['filters'] = filters;
    }
    final String keyword = searchController.text.trim();
    if (keyword.isNotEmpty) {
      data['content'] = keyword;
    }
    return data;
  }

  Map<String, dynamic> _buildPageRequestParameters() {
    final Map<String, dynamic> parameters = <String, dynamic>{
      'offset': _offset,
      'limit': pageSize,
    };
    if (selectedOrderValue.value.isNotEmpty) {
      parameters['order'] = selectedOrderValue.value;
    }
    return parameters;
  }

  bool _hasMoreData() {
    return total.value > taskList.length;
  }

  void _restoreInitialQuery(Map<String, String?> parameters) {
    selectedFilters.clear();
    _restoreInitialFilter('regionNids', parameters['regionNids']);
    _restoreInitialFilter('milestone', parameters['milestone']);
    _restoreInitialFilter('familyNid', parameters['familyNid']);
    _restoreInitialFilter('parentNid', parameters['parentNid']);
    _restoreInitialFilter('goalNids', parameters['goalNids']);
    _restoreInitialFilter('genreNid', parameters['genreNid']);
    _hiddenTopicValues.clear();
    _hiddenStageNidValues.clear();
  }

  void _restoreInitialFilter(String groupCode, String? rawValue) {
    List<String> values = _splitValues(rawValue);
    if (values.isEmpty) return;
    final Set<String> validValues = buildFilterGroups()
        .firstWhereOrNull((item) => item.groupCode == groupCode)
        ?.items
        .map((item) => item.value)
        .where((item) => item.isNotEmpty)
        .toSet() ??
        const <String>{};
    if (validValues.isNotEmpty) {
      values = values.where(validValues.contains).toList();
    }
    if (values.isEmpty) return;
    selectedFilters[groupCode] = values;
  }

  void _applyDefaultSort() {
    if (selectedOrderValue.value.isNotEmpty) return;
    for (final ZhenxieExamTaskQueryMetaGroupData group in buildOrderGroups()) {
      final ZhenxieExamTaskQueryMetaItemData? item = group.items.firstWhereOrNull((entry) => entry.defaultValue);
      if (item == null || item.value.isEmpty) continue;
      selectedOrderValue.value = item.value;
      return;
    }
  }

  void _updateSearchHints() {
    final List<ZhenduScriptQuerySearchHintEntity> hints = metaData.value?.searchHints
            .where((item) => item.text.isNotEmpty)
            .map((item) => ZhenduScriptQuerySearchHintEntity(text: item.text, weight: item.weight))
            .toList() ??
        const <ZhenduScriptQuerySearchHintEntity>[];
    searchHintRotator.updateHints(hints);
  }

  List<String> _splitValues(String? value) {
    return value?.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toList() ?? const <String>[];
  }

  Future<void> openTaskDetail(int uid) async {
    await TagRoutes.toNamed(
      Routes.ZHENXIE_EXAM_TASK_DETAIL,
      arguments: <String, dynamic>{'uid': uid},
    );
  }
}
