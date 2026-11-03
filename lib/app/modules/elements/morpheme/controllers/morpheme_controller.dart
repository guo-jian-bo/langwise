import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/elements/model/elements_detils_data_model.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../utils/utils.dart';

class MorphemeController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  MorphemeController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.DICTIONARY_MORPHEME;

  @override
  String get breadcrumbTitle => '词素';

  final ConfigController configController = Get.find<ConfigController>();
  Worker? _styleWatcher;
  int _loadingCount = 0;

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  final RxBool isLoading = true.obs;
  final RxBool isNotData = false.obs;
  final RxList<ElementsDetilsDataModel> datas = <ElementsDetilsDataModel>[].obs;
  final Rx<LockEntity> rights = LockEntity().obs;
  final RxList<CardDictModeEntityList> dictModeList =
      <CardDictModeEntityList>[].obs;
  final Rxn<ZhenduScriptQueryMetaGroupListEntity> metaGroupList =
      Rxn<ZhenduScriptQueryMetaGroupListEntity>();
  final SearchHintRotator searchHintRotator = SearchHintRotator();
  final RxInt total = 0.obs;
  final RxInt count = 0.obs;

  int offset = 0;
  final int limit = 40;
  bool loadingMore = false;

  bool get hasMore => datas.length < count.value;

  String get currentSearchHintText {
    final String hint = searchHintRotator.currentHint.value.trim();
    if (hint.isNotEmpty) return hint;
    return '搜索词素卡片';
  }

  String? get currentHelpVideoUrl {
    for (final CardDictModeEntityList item in dictModeList) {
      final String url = item.helpVideoUrl ?? '';
      if (url.isNotEmpty) return url;
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    _styleWatcher = debounce(configController.styleModeVersion, (_) {
      Future.microtask(() async {
        await refreshList(showLoading: true);
      });
    }, time: const Duration(milliseconds: 80));
    initPage(showLoading: true);
  }

  Future<void> initPage({bool showLoading = false}) async {
    if (LockUtils.checkExperienceAppStorage()) return;
    await _runWithLoading(() async {
      await Future.wait([
        getDictMode(),
        _ensureMetaLoaded(),
      ]);
      await refreshList(showLoading: false);
    }, enabled: showLoading);
  }

  Future<void> clearSearch() async {
    if (searchController.text.trim().isEmpty) return;
    searchController.clear();
    await refreshList(showLoading: true);
  }

  Future<void> refreshList({bool showLoading = true}) async {
    offset = 0;
    loadingMore = false;
    count.value = 0;
    datas.clear();
    isNotData.value = false;
    await initListData(showLoading: showLoading);
  }

  Future<void> initListData({bool showLoading = true}) async {
    await configController.ensureStyleReady();
    final ElementsCardEntity? cards = await _runWithLoading(
      () => getCardList(offset, limit),
      enabled: showLoading,
    );
    if (cards == null) {
      if (datas.isEmpty) isNotData.value = true;
      loadingMore = false;
      return;
    }
    rights.value = cards.rights ?? LockEntity();
    count.value = cards.count ?? 0;
    total.value = cards.total ?? 0;

    final List<ElementsDetilsDataModel> list = <ElementsDetilsDataModel>[];
    for (int i = 0; i < (cards.datas?.length ?? 0); i++) {
      final ElementsCardEntityDatas? data = cards.datas?[i];
      if (data == null) continue;
      if ((data.contentType ?? '').isEmpty) continue;
      list.add(ElementsDetilsDataModel(
        type: ElementsCardType.fromRawValue(data.contentType ?? ''),
        data: data,
      ));
    }
    datas.addAll(list);
    isNotData.value = datas.isEmpty;
    loadingMore = false;
  }

  Future<void> loadMore() async {
    if (loadingMore || !hasMore) return;
    loadingMore = true;
    offset += limit;
    await initListData(showLoading: false);
  }

  Future<ElementsCardEntity?> getCardList(
    int currentOffset,
    int currentLimit,
  ) async {
    final Map<String, dynamic> parameters = {
      'offset': currentOffset,
      'limit': currentLimit,
      'style': configController.currentStyleForRequest,
      'mediaMode': configController.currentMediaMode,
      'contentType': ElementsCardType.morpheme.value,
      'order': 'letterOrder,-in_course_cnt',
    };
    final Map<String, dynamic> reqData = {
      'studied': false,
    };
    if (searchController.text.trim().isNotEmpty) {
      reqData['content'] = searchController.text.trim();
    }
    return ElementsRequest.getCardList(parameters, reqData);
  }

  Future<void> submitSearch() async {
    await refreshList(showLoading: true);
  }

  Future<void> getDictMode() async {
    final CardDictModeEntity? data = await _runWithLoading(
      () => ElementsRequest.getDictMode(),
      enabled: false,
    );
    if (data == null) return;
    final List<CardDictModeEntityList?>? list = data.list;
    if (list == null) return;
    dictModeList.value = list.whereType<CardDictModeEntityList>().toList();
  }

  Future<void> _ensureMetaLoaded({bool forceReload = false}) async {
    if (!forceReload && metaGroupList.value != null) return;
    final ZhenduScriptQueryMetaGroupListEntity? data = await _runWithLoading(
      () => ElementsRequest.getCardQueryMetaGroupList(),
      enabled: false,
    );
    if (data == null) return;
    metaGroupList.value = data;
    searchHintRotator.updateHints(data.searchHints);
  }

  Future<T> _runWithLoading<T>(
    Future<T> Function() task, {
    required bool enabled,
  }) async {
    if (!enabled) return task();
    _loadingCount++;
    if (_loadingCount == 1) {
      ToastUtils.showLoading();
    }
    try {
      return await task();
    } finally {
      _loadingCount--;
      if (_loadingCount <= 0) {
        _loadingCount = 0;
        ToastUtils.hideLoading();
      }
    }
  }

  @override
  void onClose() {
    _styleWatcher?.dispose();
    searchHintRotator.dispose();
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
