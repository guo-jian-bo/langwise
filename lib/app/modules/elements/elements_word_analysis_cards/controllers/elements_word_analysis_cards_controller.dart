import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';

class ElementsWordAnalysisCardsController extends GetxController
    with RoutesBreadcrumbMixin, PageRefreshAwareMixin {
  final String tagText;

  ElementsWordAnalysisCardsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.EN_WORD_ANALYSIS_CARDS;

  @override
  String get breadcrumbTitle => '关联词典卡片';

  final ConfigController configController = Get.find<ConfigController>();

  String analysisType = '';
  String pageTitle = '';
  String contentType = '';
  int? contentId;
  int? semanticId;

  final ScrollController scrollController = ScrollController();
  final RxBool isLoading = true.obs;
  final RxList<KnowledgeCommonEntityList> datas = <KnowledgeCommonEntityList>[].obs;
  final Rx<LockEntity> rights = LockEntity().obs;
  final RxInt count = 0.obs;

  int offset = 0;
  final int limit = 30;
  bool loadingMore = false;

  String? pagePos;
  List<String> previewForms = <String>[];

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      analysisType = (Get.arguments['type'] ?? '').toString();
      pageTitle = (Get.arguments['title'] ?? '').toString();
      contentType = (Get.arguments['contentType'] ?? '').toString();
      contentId = Get.arguments['contentId'];
      semanticId = Get.arguments['semanticId'];
    }
    initBreadcrumb(tagText, title: _resolvePageTitle());
    initPage();
  }

  @override
  Future<void> onReturnPageRefresh(String? key) async {
    await refreshList(showLoading: true);
  }

  Future<void> initPage() async {
    try {
      ToastUtils.showLoading();
      isLoading.value = true;
      await configController.ensureStyleReady();
      await refreshList(showLoading: false);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> refreshList({bool showLoading = true}) async {
    offset = 0;
    count.value = 0;
    loadingMore = false;
    datas.clear();
    rights.value = LockEntity();
    pagePos = null;
    previewForms = <String>[];
    isLoading.value = true;
    await _loadListData(showLoading: showLoading);
  }

  Future<void> loadMore() async {
    if (loadingMore || !hasMoreData()) return;
    loadingMore = true;
    offset = datas.length;
    await _loadListData(showLoading: false);
  }

  bool hasMoreData() {
    return datas.length < count.value;
  }

  bool shouldEnableTextHighlight() {
    return previewForms.isNotEmpty && resolveHighlightColor() != null;
  }

  Color? resolveHighlightColor() {
    final String pos = (pagePos ?? '').trim();
    if (pos.isEmpty) return null;
    final List<LanguageConfigColorEntityInfo?>? posConfigs =
        configController.colorConfigs.value.pos;
    final LanguageConfigColorModel? colorConfig =
        StatusUtils.getConfigColor(posConfigs, pos) ??
            StatusUtils.getConfigColorForAbbr(posConfigs, pos);
    return colorConfig?.color?.borderColor ?? colorConfig?.color?.textColor;
  }

  Future<void> _loadListData({bool showLoading = true}) async {
    if (contentId == null || semanticId == null) {
      isLoading.value = false;
      return;
    }
    if (analysisType == 'synonym' && contentType.trim().isEmpty) {
      isLoading.value = false;
      return;
    }
    if (showLoading) {
      ToastUtils.showLoading();
    }
    try {
      final CardWordAnalysisCardsPageEntity? pageData =
          await _requestPageData();
      if (pageData == null) {
        isLoading.value = false;
        loadingMore = false;
        return;
      }
      rights.value = pageData.rights ?? LockEntity();
      count.value = pageData.count ?? 0;
      pagePos = (pageData.pos ?? '').trim().isEmpty ? null : pageData.pos;
      previewForms = pageData.previewForms
              ?.whereType<String>()
              .where((String item) => item.trim().isNotEmpty)
              .toList() ??
          <String>[];
      final List<KnowledgeCommonEntityList> items =
          (pageData.datas ?? <KnowledgeCommonEntityList?>[])
              .whereType<KnowledgeCommonEntityList>()
              .toList();
      datas.addAll(items);
      if (count.value < datas.length) {
        count.value = datas.length;
      }
    } finally {
      isLoading.value = false;
      loadingMore = false;
      if (showLoading) {
        ToastUtils.hideLoading();
      }
    }
  }

  Future<CardWordAnalysisCardsPageEntity?> _requestPageData() async {
    switch (analysisType) {
      case 'sentence':
      case 'sentences':
        return ElementsRequest.getWordSentenceCardsPage(
          contentId!,
          semanticId: semanticId!,
          offset: offset,
          limit: limit,
          style: configController.currentStyleForRequest,
          mediaMode: configController.currentMediaMode,
        );
      case 'phrase':
      case 'phrases':
        return ElementsRequest.getWordPhraseCardsPage(
          contentId!,
          semanticId: semanticId!,
          offset: offset,
          limit: limit,
          style: configController.currentStyleForRequest,
          mediaMode: configController.currentMediaMode,
        );
      case 'synonym':
      case 'synonyms':
        return ElementsRequest.getWordSynonymCardsPage(
          semanticId: semanticId!,
          contentType: contentType,
          offset: offset,
          limit: limit,
          style: configController.currentStyleForRequest,
          mediaMode: configController.currentMediaMode,
        );
    }
    return null;
  }

  String _resolvePageTitle() {
    if (pageTitle.trim().isNotEmpty) return pageTitle.trim();
    switch (analysisType) {
      case 'sentence':
      case 'sentences':
        return '例句';
      case 'phrase':
      case 'phrases':
        return '短语';
      case 'synonym':
      case 'synonyms':
        return '同义词';
      default:
        return breadcrumbTitle;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
