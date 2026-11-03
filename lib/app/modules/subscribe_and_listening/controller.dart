import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/modules/subscribe_and_listening/notice_dialog.dart';
import 'package:langwise/app/modules/subscribe_and_listening/sub_manage_dialog.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/music.dart';
import 'package:langwise/common/https/subscribe.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/values/storage.dart';
import 'package:lib_common/utils/storage_util.dart';

import '../../../utils/utils.dart';

class SubListenController extends GetxController
    with GetTickerProviderStateMixin, RoutesBreadcrumbMixin {
  final String tagText;
  SubListenController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.APP_SUBSCRIBE_LISTENING;

  @override
  String get breadcrumbTitle => '分阶时文';

  RxInt selectedIndex = 0.obs;

  RxList<ManageSubscribeGenreEntity> themes =
      <ManageSubscribeGenreEntity>[].obs;
  RxList<UserRevealCollectionEntity> reveals =
      <UserRevealCollectionEntity>[].obs;
  final Rx<LockEntity> rights = LockEntity().obs;
  RxInt page = 0.obs; // 当前 offset
  RxInt num = 20.obs; // page size
  RxInt total = 0.obs; // 总条数
  RxString genre = "".obs;
  RxString theme = "".obs;
  RxBool hasMore = true.obs;
  RxBool isLoadingMore = false.obs;
  UserRevealPushRecordEntity? pushRecord;

  /// 搜索
  final TextEditingController searchInput = TextEditingController();

  /// 是否点击了输入框 如果点击了那么禁用页面收起键盘350毫秒 350毫秒之后再允许点击
  final RxBool isSearchClick = false.obs;

  TabController? tabController;
  final RxInt currentTabIndex = 0.obs;

  final ScrollController revealsScrollController = ScrollController();
  final ScrollController contentScrollController = ScrollController();
  final TextEditingController contentSearchController = TextEditingController();
  double _revealsLastOffset = 0;

  final RxnInt activeCollectionId = RxnInt();
  final RxString activeCollectionTitle = ''.obs;
  final RxString activeCollectionDescription = ''.obs;

  final RxList<KnowledgeCommonEntityList> contentItems =
      <KnowledgeCommonEntityList>[].obs;
  final RxBool contentIsLoading = true.obs;
  final RxBool contentIsNotData = false.obs;
  final RxInt contentTotal = 0.obs;
  final Rxn<ZhenduScriptQueryMetaGroupListEntity> contentMetaGroupList =
      Rxn<ZhenduScriptQueryMetaGroupListEntity>();
  final RxMap<String, List<String>> contentSelectedFilters =
      <String, List<String>>{}.obs;
  final RxString contentSelectedOrderGroupCode = ''.obs;
  final RxString contentSelectedOrderValue = ''.obs;
  final RxInt userDifficulty = 0.obs;
  final RxInt settingDifficulty = 0.obs;
  final SearchHintRotator contentSearchHintRotator = SearchHintRotator();

  int _contentOffset = 0;
  final int _contentLimit = 30;
  bool _contentLoadingMore = false;

  final List<String> difficultyList = <String>[
    'Pre A1',
    'A1',
    'A2',
    'B1',
    'B2',
    'C1',
    'C2',
  ];

  bool get isInCollectionDetails => activeCollectionId.value != null;
  bool get hasMoreContent => _contentOffset < contentTotal.value;

  List<ZhenduScriptQueryMetaGroupEntity> get contentFilterGroups =>
      contentMetaGroupList.value?.filters ??
      const <ZhenduScriptQueryMetaGroupEntity>[];

  List<ZhenduScriptQueryMetaGroupEntity> get contentOrderGroups =>
      contentMetaGroupList.value?.orders ??
      const <ZhenduScriptQueryMetaGroupEntity>[];

  String get currentSearchHintText {
    final String hint = contentSearchHintRotator.currentHint.value.trim();
    if (hint.isNotEmpty) return hint;
    return '搜索时文标题';
  }

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    initPage();
  }

  initPage({bool showNotice = true}) {
    page.value = 0;
    hasMore.value = true;
    if (!LockUtils.checkExperienceAppStorage()) {
      UserStore.to.getUserInfo();
    }
    getUserRevealsPage(showNotice: showNotice);
  }

  Future<void> initTab() async {
    var mRights = await MusicRequest.isBuyReveal(data: {'type': "EN_REVEAL"});
    if (mRights == null) return;
    rights.value = mRights;
  }

  /// 执行搜索
  Future<void> searchCard(String text) async {
    theme.value = text;
    refreshUserRevealsPage();
  }

  ///获取用户专栏列表（分页，参数为主题和难度）
  Future<void> getUserRevealsPage({bool showNotice = true}) async {
    // 并发保护：正在加载中时直接返回
    if (isLoadingMore.value) {
      return;
    }

    // 如果已经没有更多并且不是首次加载，直接返回
    if (!hasMore.value && page.value != 0) {
      return;
    }

    isLoadingMore.value = true;
    try {
      // 首次加载或刷新：清空数据并重置标记
      if (page.value == 0) {
        reveals.clear();
        hasMore.value = true;
        total.value = 0;
      }

      final pageData = await SubscribeRequest.getUserRevealsPage(
        genre: genre.value,
        theme: theme.value,
        offset: page.value,
        limit: num.value,
      );
      if (pageData == null) {
        hasMore.value = false;
        return;
      }

      if ((pageData.warnDialog ?? false) && total.value == 0) {
        var record = StorageUtil().getString(SUB_LISTEN_NOT_REMIND_KEY);
        bool isToday = false;

        if (record.isNotEmpty) {
          final saved = DateTime.tryParse(record);
          final now = DateTime.now();
          isToday = saved?.year == now.year &&
              saved?.month == now.month &&
              saved?.day == now.day;
        }

        bool isFree = UserStore.to.userInfo.value.isFree;
        if (!isFree) {
          if (!isToday && showNotice) {
            NoticeDialog.show(Get.context!, pageData.warnMessage ?? "");
          }
        }
      }

      // 记录总数，用于判断是否有下一页
      total.value = pageData.count ?? 0;
      rights.value = pageData.rights!;

      final List<UserRevealCollectionEntity>? list = pageData.datas;
      if (list == null || list.isEmpty) {
        hasMore.value = false;
        return;
      }

      reveals.addAll(list);

      // 使用 offset + pageSize 与 total 对比判断是否还有下一页
      page.value += num.value;
      if (page.value >= total.value) {
        hasMore.value = false;
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 下拉刷新
  Future<void> refreshUserRevealsPage() async {
    page.value = 0;
    hasMore.value = true;
    await getUserRevealsPage();
  }

  ///订阅；取消订阅
  Future<void> toggleSubscribe(
      {required int collectionId, required bool isSubscribed}) async {
    final access = isSubscribed ? 'NORMAL' : 'DELETED';
    var res = await SubscribeRequest.userToggleSubscribe(
        collectionId: collectionId, access: access);
    // 刷新列表
    if (res!.code == HttpStatus.ok) {
      Get.back(result: access);
    } else {
      Get.back(result: 'error');
    }
  }

  ///订阅管理
  Future<void> getUserSubscribeConfig() async {
    final res = await SubscribeRequest.getUserSubscribeConfig();
    if (res != null) {
      SubManageDialog.show(
        Get.context!,
        res,
        tagText: tagText,
      ).then((needRefresh) {});
    }
  }

  /// 推送 / 时文历史记录
  Future<void> loadUserRevealPushRecord() async {
    pushRecord = await SubscribeRequest.userRevealPushRecord();
  }

  Future<void> enterCollection({
    required int collectionId,
    required String title,
    required String description,
  }) async {
    if (activeCollectionId.value == collectionId && isInCollectionDetails) {
      return;
    }
    if (revealsScrollController.hasClients) {
      _revealsLastOffset = revealsScrollController.offset;
    }
    activeCollectionId.value = collectionId;
    activeCollectionTitle.value = title;
    activeCollectionDescription.value = description;

    _resetContentPagingCursor();
    _resetContentSelections();
    _scrollContentToTop();
    ToastUtils.showLoading();
    try {
      await _loadMemberDifficulty();
      await _ensureContentMetaLoaded();
      await refreshContentPage(showLoading: false);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void exitCollection() {
    if (!isInCollectionDetails) return;
    activeCollectionId.value = null;
    activeCollectionTitle.value = '';
    activeCollectionDescription.value = '';

    _resetContentPagingCursor();
    _resetContentSelections();
    contentItems.clear();
    contentIsNotData.value = false;
    _restoreRevealsOffset();
  }

  void _restoreRevealsOffset() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!revealsScrollController.hasClients) return;
      final double maxScrollExtent =
          revealsScrollController.position.maxScrollExtent;
      double target = _revealsLastOffset;
      if (target < 0) target = 0;
      if (target > maxScrollExtent) target = maxScrollExtent;
      revealsScrollController.jumpTo(target);
    });
  }

  Future<void> refreshContentPage({bool showLoading = true}) async {
    await loadContentPage(reset: true, showLoading: showLoading);
  }

  Future<void> loadContentPage({
    bool reset = false,
    bool showLoading = false,
  }) async {
    if (!isInCollectionDetails) return;
    if (!reset && _contentLoadingMore) return;
    if (!reset && !hasMoreContent) return;
    try {
      if (reset) {
        _contentOffset = 0;
        _contentLoadingMore = false;
        contentTotal.value = 0;
        contentItems.clear();
        contentIsNotData.value = false;
      } else {
        _contentLoadingMore = true;
      }
      if (_contentOffset == 0) {
        contentIsLoading.value = showLoading;
      }
      if (showLoading) {
        ToastUtils.showLoading();
      }
      final int? collectionId = activeCollectionId.value;
      if (collectionId == null) return;
      final UserRevealDetailsV2PageEntity? page =
          await SubscribeRequest.getRevealDetailsPageByQuery(
        collectionId: collectionId,
        offset: _contentOffset,
        limit: _contentLimit,
        order: contentSelectedOrderValue.value.trim().isEmpty
            ? null
            : contentSelectedOrderValue.value.trim(),
        reqData: _buildContentRequestData(),
      );
      if (page == null) {
        if (contentItems.isEmpty) {
          contentIsNotData.value = true;
        }
        return;
      }

      final List<KnowledgeCommonEntityList> list = page.datas ?? [];
      contentTotal.value = page.count ??
          (_contentOffset +
              list.length +
              (list.length >= _contentLimit ? 1 : 0));
      contentItems.addAll(list);
      _contentOffset = contentItems.length;
      contentIsNotData.value = contentItems.isEmpty;
    } finally {
      if (showLoading) {
        ToastUtils.hideLoading();
      }
      if (_contentOffset == 0) {
        contentIsLoading.value = false;
      }
      _contentLoadingMore = false;
    }
  }

  Map<String, dynamic> _buildContentRequestData() {
    final Map<String, dynamic> reqData = <String, dynamic>{};
    final String keyword = contentSearchController.text.trim();
    final String hint = contentSearchHintRotator.currentHint.value.trim();
    final String content = keyword.isNotEmpty ? keyword : hint;
    if (content.isNotEmpty) {
      reqData['content'] = content;
    }
    final List<Map<String, dynamic>>? filters = _buildContentRequestFilters();
    if (filters != null && filters.isNotEmpty) {
      reqData['filters'] = filters;
    }
    return reqData;
  }

  List<Map<String, dynamic>>? _buildContentRequestFilters() {
    if (contentSelectedFilters.isEmpty) return null;
    final List<Map<String, dynamic>> resp = <Map<String, dynamic>>[];
    contentSelectedFilters.forEach((key, values) {
      final String code = key.trim();
      final List<String> selectedValues =
          values.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (code.isEmpty || selectedValues.isEmpty) return;
      resp.add(<String, dynamic>{
        'code': code,
        'values': selectedValues,
      });
    });
    return resp.isEmpty ? null : resp;
  }

  Future<void> applyContentSortSelection({
    required String groupCode,
    required String value,
  }) async {
    if (contentSelectedOrderGroupCode.value == groupCode &&
        contentSelectedOrderValue.value == value) {
      return;
    }
    contentSelectedOrderGroupCode.value = groupCode;
    contentSelectedOrderValue.value = value;
    _resetContentPagingCursor();
    _scrollContentToTop();
    await refreshContentPage(showLoading: true);
  }

  Future<void> applyContentConditionSelections(
    Map<String, List<String>> selections,
  ) async {
    contentSelectedFilters
      ..clear()
      ..addAll(selections);
    _syncActiveCollectionFromThemeSelections(selections);
    _syncDifficultyFromSelections(selections);
    _resetContentPagingCursor();
    _scrollContentToTop();
    await refreshContentPage(showLoading: true);
  }

  Future<void> submitContentSearch() async {
    _resetContentPagingCursor();
    _scrollContentToTop();
    await refreshContentPage(showLoading: true);
  }

  void resetContentFilters() {
    contentSearchController.clear();
    contentSelectedFilters.clear();
    contentSelectedOrderGroupCode.value = '';
    contentSelectedOrderValue.value = '';
    _applyContentDefaultSelections();
    _resetContentPagingCursor();
    _scrollContentToTop();
    refreshContentPage(showLoading: true);
  }

  Future<void> setDifficultySelection(int difficulty) async {
    settingDifficulty.value = difficulty;
    final Map<String, List<String>> nextSelections =
        Map<String, List<String>>.from(contentSelectedFilters);
    nextSelections['difficulty'] = <String>[difficulty.toString()];
    contentSelectedFilters
      ..clear()
      ..addAll(nextSelections);
    _resetContentPagingCursor();
    _scrollContentToTop();
    await refreshContentPage(showLoading: true);
  }

  Future<void> _loadMemberDifficulty() async {
    final dynamic res = await SubscribeRequest.memberDifficulty();
    if (res == null || res.data == null) return;
    final dynamic data = res.data;
    if (data is int) {
      userDifficulty.value = data;
      if (settingDifficulty.value == 0 && data != 0) {
        settingDifficulty.value = data;
      } else {
        settingDifficulty.value = data;
      }
    }
  }

  Future<void> _ensureContentMetaLoaded({bool forceReload = false}) async {
    if (!forceReload && contentMetaGroupList.value != null) {
      if (contentSelectedOrderValue.value.isEmpty &&
          contentSelectedFilters.isEmpty) {
        _applyContentDefaultSelections();
      }
      return;
    }
    final ZhenduScriptQueryMetaGroupListEntity? data =
        await SubscribeRequest.getCollectionQueryMetaGroupList();
    if (data == null) return;
    contentMetaGroupList.value = data;
    contentSearchHintRotator.updateHints(data.searchHints);
    _applyContentDefaultSelections();
  }

  void _applyContentDefaultSelections() {
    if (contentSelectedOrderValue.value.isNotEmpty ||
        contentSelectedFilters.isNotEmpty) {
      return;
    }
    _applyContentDefaultFilterSelections();
    final int? collectionId = activeCollectionId.value;
    if (collectionId != null && _hasContentFilterGroup('theme')) {
      contentSelectedFilters['theme'] = <String>[collectionId.toString()];
    }
    if (_hasContentFilterGroup('difficulty')) {
      contentSelectedFilters['difficulty'] = <String>[
        settingDifficulty.value.toString()
      ];
    }
    _applyContentDefaultOrderSelection();
  }

  void _applyContentDefaultFilterSelections() {
    final Map<String, List<String>> defaults = <String, List<String>>{};
    final Map<String, String> linkedGroupSelections = <String, String>{};
    for (final ZhenduScriptQueryMetaGroupEntity group in contentFilterGroups) {
      final String groupCode = (group.groupCode ?? '').trim();
      if (groupCode.isEmpty || group.items.isEmpty) continue;
      final List<String> values = group.items
          .where((e) => e.defaultValue ?? false)
          .map((e) => (e.value ?? '').trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (values.isEmpty) continue;

      final String filterGroup = (group.filterGroup ?? '').trim();
      final bool isLinkedRadioGroup = filterGroup.isNotEmpty &&
          (group.radioGroup ?? false) &&
          values.isNotEmpty;
      if (isLinkedRadioGroup) {
        final String? previousGroupCode = linkedGroupSelections[filterGroup];
        if (previousGroupCode != null) {
          defaults.remove(previousGroupCode);
        }
        linkedGroupSelections[filterGroup] = groupCode;
        defaults[groupCode] = <String>[values.first];
        continue;
      }

      final bool isSingle = (group.component ?? '').trim() == 'radio';
      defaults[groupCode] = isSingle ? <String>[values.first] : values;
    }
    if (defaults.isNotEmpty) {
      contentSelectedFilters.addAll(defaults);
    }
  }

  void _applyContentDefaultOrderSelection() {
    for (final ZhenduScriptQueryMetaGroupEntity group in contentOrderGroups) {
      ZhenduScriptQueryMetaItemEntity? selected;
      for (final ZhenduScriptQueryMetaItemEntity item in group.items) {
        if (item.defaultValue ?? false) {
          selected = item;
          break;
        }
      }
      if (selected == null) continue;
      contentSelectedOrderGroupCode.value = (group.groupCode ?? '').trim();
      contentSelectedOrderValue.value = selected.value ?? '';
      break;
    }
  }

  void _syncDifficultyFromSelections(Map<String, List<String>> selections) {
    final List<String>? difficultyValues = selections['difficulty'];
    if (difficultyValues == null || difficultyValues.isEmpty) return;
    final int? value = int.tryParse(difficultyValues.first);
    if (value == null) return;
    settingDifficulty.value = value;
  }

  void _syncActiveCollectionFromThemeSelections(
    Map<String, List<String>> selections,
  ) {
    final List<String>? themeValues = selections['theme'];
    if (themeValues == null || themeValues.isEmpty) return;
    final int? value = int.tryParse(themeValues.first);
    if (value == null) return;
    if (activeCollectionId.value == value) return;
    activeCollectionId.value = value;

    for (final UserRevealCollectionEntity entity in reveals) {
      if (entity.collectionId == value) {
        activeCollectionTitle.value =
            entity.themeZhName ?? activeCollectionTitle.value;
        break;
      }
    }
  }

  bool _hasContentFilterGroup(String groupCode) {
    for (final ZhenduScriptQueryMetaGroupEntity group in contentFilterGroups) {
      if ((group.groupCode ?? '').trim() == groupCode) {
        return true;
      }
    }
    return false;
  }

  bool isContentFilterSelected(String groupCode, String value) {
    final List<String>? values = contentSelectedFilters[groupCode];
    if (values == null || values.isEmpty) return false;
    return values.contains(value);
  }

  bool isContentSortSelected(String groupCode, String value) {
    return contentSelectedOrderGroupCode.value == groupCode &&
        contentSelectedOrderValue.value == value;
  }

  String sortItemValueByName(String groupCode, String itemName) {
    for (final ZhenduScriptQueryMetaGroupEntity group in contentOrderGroups) {
      if ((group.groupCode ?? '') != groupCode) continue;
      for (final ZhenduScriptQueryMetaItemEntity item in group.items) {
        if ((item.name ?? '') == itemName) {
          return item.value ?? '';
        }
      }
    }
    return '';
  }

  void _resetContentPagingCursor() {
    _contentOffset = 0;
    _contentLoadingMore = false;
    contentTotal.value = 0;
  }

  void _resetContentSelections() {
    contentSearchController.clear();
    contentSelectedFilters.clear();
    contentSelectedOrderGroupCode.value = '';
    contentSelectedOrderValue.value = '';
    _applyContentDefaultSelections();
  }

  void _scrollContentToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!contentScrollController.hasClients) return;
      contentScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _scrollRevealsToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!revealsScrollController.hasClients) return;
      revealsScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void scrollRevealsToTop() {
    _scrollRevealsToTop();
  }

  @override
  void onClose() {
    contentSearchHintRotator.dispose();
    revealsScrollController.dispose();
    contentScrollController.dispose();
    contentSearchController.dispose();
    searchInput.dispose();
    super.onClose();
  }
}
