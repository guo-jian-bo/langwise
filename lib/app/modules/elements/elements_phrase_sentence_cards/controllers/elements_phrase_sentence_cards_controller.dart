import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/elements_card_type.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';
import '../../model/elements_detils_data_model.dart';

class ElementsPhraseSentenceCardsController extends GetxController
    with RoutesBreadcrumbMixin {
  final String tagText;

  ElementsPhraseSentenceCardsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.EN_PHRASE_SENTENCE_CARDS;

  @override
  String get breadcrumbTitle => '句子';

  final ConfigController configController = Get.find<ConfigController>();

  int? contentId;
  int? semanticId;
  String pageTitle = '';
  int? highlightColorValue;

  final ScrollController scrollController = ScrollController();
  final RxBool isLoading = true.obs;
  final RxList<CardPhraseSentenceCardsData> sentenceCards =
      <CardPhraseSentenceCardsData>[].obs;
  final RxInt count = 0.obs;

  int offset = 0;
  final int limit = 30;
  bool loadingMore = false;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      contentId = Get.arguments['contentId'];
      semanticId = Get.arguments['semanticId'];
      pageTitle = (Get.arguments['title'] ?? '').toString();
      highlightColorValue = Get.arguments['highlightColorValue'];
    }
    initBreadcrumb(tagText, title: _resolvePageTitle());
    initPage();
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
    sentenceCards.clear();
    isLoading.value = true;
    await _loadListData(showLoading: showLoading);
  }

  Future<void> loadMore() async {
    if (loadingMore || !hasMoreData()) return;
    loadingMore = true;
    offset = sentenceCards.length;
    await _loadListData(showLoading: false);
  }

  bool hasMoreData() {
    return sentenceCards.length < count.value;
  }

  Color resolveHighlightColor() {
    if (highlightColorValue != null) {
      return Color(highlightColorValue!);
    }
    return AppTheme.cTextBrand.color;
  }

  ElementsDetilsDataModel? buildCardData(CardPhraseSentenceCardsData item) {
    final ElementsCardEntityDatas? contentCard = item.contentCard;
    if (contentCard == null) return null;
    final ElementsCardType type =
        ElementsCardType.fromRawValue(contentCard.contentType ?? '');
    if (type == ElementsCardType.none) return null;
    return ElementsDetilsDataModel(
      type: type,
      data: contentCard,
    );
  }

  Future<void> _loadListData({bool showLoading = true}) async {
    if (contentId == null || semanticId == null) {
      isLoading.value = false;
      loadingMore = false;
      return;
    }
    if (showLoading) {
      ToastUtils.showLoading();
    }
    try {
      final CardPhraseSentenceCardsPageEntity? pageData =
          await ElementsRequest.getPhraseSentenceCardsPage(
        contentId!,
        semanticId: semanticId!,
        offset: offset,
        limit: limit,
        style: configController.currentStyleForRequest,
        mediaMode: configController.currentMediaMode,
      );
      if (pageData == null) {
        isLoading.value = false;
        loadingMore = false;
        return;
      }
      count.value = pageData.count ?? 0;
      sentenceCards.addAll(
        pageData.datas
                ?.whereType<CardPhraseSentenceCardsData>()
                .toList() ??
            <CardPhraseSentenceCardsData>[],
      );
      if (count.value < sentenceCards.length) {
        count.value = sentenceCards.length;
      }
    } finally {
      isLoading.value = false;
      loadingMore = false;
      if (showLoading) {
        ToastUtils.hideLoading();
      }
    }
  }

  String _resolvePageTitle() {
    if (pageTitle.trim().isNotEmpty) return pageTitle.trim();
    return breadcrumbTitle;
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
