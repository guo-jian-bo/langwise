import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../utils/utils.dart';

class ZhenxiePhraseMatchExtrasController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxiePhraseMatchExtrasController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_PHRASE_MATCH_EXTRAS;

  @override
  String get breadcrumbTitle => "同组补充";

  bool isManagement = false;
  String? nid;

  final RxBool isLoading = false.obs;
  final RxList<KnowledgeCommonEntityList> cardList = <KnowledgeCommonEntityList>[].obs;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      isManagement = Get.arguments["isManagement"] ?? false;
      nid = Get.arguments["nid"]?.toString();
    }
    getList();
  }

  Future<void> getList({bool showLoading = true}) async {
    if ((nid ?? '').isEmpty) return;
    try {
      if (showLoading) {
        isLoading.value = true;
        ToastUtils.showLoading();
      }
      final List<KnowledgeCommonEntityList>? list = await LanguageUtil.getWritePhraseMatchExtras(
        parameters: {"nid": nid},
      );
      if (list == null) return;
      cardList.value = list;
    } finally {
      isLoading.value = false;
      if (showLoading) {
        ToastUtils.hideLoading();
      }
    }
  }
}
