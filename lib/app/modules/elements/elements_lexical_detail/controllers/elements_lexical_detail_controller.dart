import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/mixins/mixins.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../routes/routes_breadcrumb_utils.dart';

class ElementsLexicalDetailController extends GetxController
    with RoutesBreadcrumbMixin, PageRefreshAwareMixin {
  final String tagText;

  ElementsLexicalDetailController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.EN_LEXICAL_DETAIL;

  @override
  String get breadcrumbTitle => '同义反义';

  String? contentType;
  int? contentId;
  int? semanticId;

  final Rx<LexicalDetailEntity> detailData = LexicalDetailEntity().obs;
  final RxList<LexicalDetailSemanticItem> semanticItems =
      <LexicalDetailSemanticItem>[].obs;
  final RxInt currentSemanticId = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool isSemanticSwitching = false.obs;

  final Map<String, LexicalDetailEntity> cachedDetails =
      <String, LexicalDetailEntity>{};

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      contentType = Get.arguments['contentType']?.toString();
      contentId = Get.arguments['contentId'];
      semanticId = Get.arguments['semanticId'];
    }
    initData();
  }

  @override
  Future<void> onReturnPageRefresh(String? key) async {
    await getDetail();
  }

  Future<void> initData() async {
    final String requestContentType = (contentType ?? '').trim();
    if (requestContentType.isEmpty || contentId == null) {
      isLoading.value = false;
      ToastUtils.showToast(text: '缺少同义反义参数');
      return;
    }
    try {
      ToastUtils.showLoading();
      isLoading.value = true;
      await getDetail();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> getDetail() async {
    final String requestContentType = (contentType ?? '').trim();
    if (requestContentType.isEmpty || contentId == null) return;
    final LexicalDetailEntity? detail = await ElementsRequest.getLexicalDetail(
      contentType: requestContentType,
      contentId: contentId!,
      semanticId: semanticId,
    );
    if (detail == null) {
      isLoading.value = false;
      return;
    }
    if (detail.contentId != null && detail.semanticId != null) {
      cachedDetails[_buildDetailCacheKey(detail.contentId!, detail.semanticId!)] =
          detail;
    }
    _applyDetail(detail);
    isLoading.value = false;
  }

  Future<void> switchSemantic(int newSemanticId) async {
    if (newSemanticId <= 0) return;
    if (isSemanticSwitching.value) return;
    if (newSemanticId == currentSemanticId.value) return;
    final LexicalDetailSemanticItem? targetItem = findSemanticItem(newSemanticId);
    final int targetContentId = targetItem?.contentId ?? contentId ?? 0;
    if (targetContentId <= 0) return;
    try {
      isSemanticSwitching.value = true;
      LexicalDetailEntity? detail =
          cachedDetails[_buildDetailCacheKey(targetContentId, newSemanticId)];
      if (detail == null) {
        detail = await ElementsRequest.getLexicalDetail(
          contentType: (contentType ?? '').trim(),
          contentId: targetContentId,
          semanticId: newSemanticId,
        );
        if (detail != null &&
            detail.contentId != null &&
            detail.semanticId != null) {
          cachedDetails[_buildDetailCacheKey(detail.contentId!, detail.semanticId!)] =
              detail;
        }
      }
      if (detail == null) return;
      _applyDetail(detail);
    } finally {
      isSemanticSwitching.value = false;
    }
  }

  LexicalDetailSemanticItem? findCurrentSemanticItem() {
    return findSemanticItem(currentSemanticId.value);
  }

  LexicalDetailSemanticItem? findSemanticItem(int semanticId) {
    for (final LexicalDetailSemanticItem item in semanticItems) {
      if (item.semanticId == semanticId) return item;
    }
    return null;
  }

  void _applyDetail(LexicalDetailEntity detail) {
    contentType = detail.contentType ?? contentType;
    contentId = detail.contentId ?? contentId;
    semanticId = detail.semanticId ?? semanticId;
    detailData.value = detail;
    semanticItems.value = detail.semanticItems
            ?.whereType<LexicalDetailSemanticItem>()
            .toList() ??
        <LexicalDetailSemanticItem>[];
    currentSemanticId.value = detail.semanticId ?? 0;
  }

  String _buildDetailCacheKey(int contentId, int semanticId) {
    return '${contentId}_$semanticId';
  }
}
