import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../theme/theme.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';
import '../../../../routes/tag_routes.dart';

class ElementsPhraseRelationsController extends GetxController
    with RoutesBreadcrumbMixin {
  final String tagText;

  ElementsPhraseRelationsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.EN_PHRASE_RELATIONS;

  @override
  String get breadcrumbTitle => '关联';

  int? contentId;
  String pageTitle = '';

  final RxBool isLoading = true.obs;
  final Rx<CardPhraseRelationDetailEntity> relationDetils =
      CardPhraseRelationDetailEntity().obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      contentId = Get.arguments['contentId'];
      pageTitle = (Get.arguments['title'] ?? '').toString();
    }
    initBreadcrumb(tagText, title: _resolvePageTitle());
    initPage();
  }

  Future<void> initPage() async {
    try {
      ToastUtils.showLoading();
      isLoading.value = true;
      await getDetils();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> getDetils() async {
    if (contentId == null) {
      isLoading.value = false;
      return;
    }
    final CardPhraseRelationDetailEntity? detils =
        await ElementsRequest.getPhraseRelationDetils(contentId!);
    if (detils != null) {
      relationDetils.value = detils;
    }
    isLoading.value = false;
  }

  List<CardPhraseRelationGroup> relationGroups() {
    return relationDetils.value.relations
            ?.whereType<CardPhraseRelationGroup>()
            .toList() ??
        <CardPhraseRelationGroup>[];
  }

  Color resolveGroupColor(CardPhraseRelationGroup group) {
    return ColorUtils.parseColor(group.color) ?? AppTheme.cTextBrand.color;
  }

  PhraseParadigmEntity? buildParadigmEntity(CardPhraseRelationItem item) {
    final Map<String, dynamic>? payload = item.payload;
    if (payload == null) return null;
    return PhraseParadigmEntity.fromJson(payload);
  }

  PhrasePairEntity? buildPairEntity(CardPhraseRelationItem item) {
    final Map<String, dynamic>? payload = item.payload;
    if (payload == null) return null;
    return PhrasePairEntity.fromJson(payload);
  }

  PhraseMatchEntity? buildMatchEntity(CardPhraseRelationItem item) {
    final Map<String, dynamic>? payload = item.payload;
    if (payload == null) return null;
    return PhraseMatchEntity.fromJson(payload);
  }

  Future<void> openRelationItem(
    CardPhraseRelationGroup group,
    CardPhraseRelationItem item,
  ) async {
    final String code = (group.code ?? '').trim();
    final String? nid = item.nid;
    if (nid == null || nid.trim().isEmpty) {
      ToastUtils.showToast(text: '缺少跳转参数');
      return;
    }
    if (code == 'paradigm') {
      await TagRoutes.toNamed(
        Routes.ZHENXIE_PHRASE_CONTRAST_DETAILS,
        tagText: '${tagText}_paradigm_$nid',
        arguments: <String, dynamic>{
          'nid': nid,
          'isManagement': false,
        },
      );
      return;
    }
    if (code == 'pair') {
      await TagRoutes.toNamed(
        Routes.ZHENXIE_PHRASE_PAIR_DETAILS,
        tagText: '${tagText}_pair_$nid',
        arguments: <String, dynamic>{
          'nid': nid,
          'isManagement': false,
        },
      );
      return;
    }
    if (code == 'cluster') {
      await TagRoutes.toNamed(
        Routes.ZHENXIE_PHRASE_MATCH_DETAILS,
        tagText: '${tagText}_cluster_$nid',
        arguments: <String, dynamic>{
          'nid': nid,
          'isManagement': false,
        },
      );
      return;
    }
    ToastUtils.showToast(text: '暂不支持该关联类型');
  }

  String _resolvePageTitle() {
    if (pageTitle.trim().isNotEmpty) return pageTitle.trim();
    return breadcrumbTitle;
  }
}
