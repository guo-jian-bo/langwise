import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/mixins/mixins.dart';
import '../../../../../../../common/public_controller/config_controller.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/tag_routes.dart';
import '../../../../../../routes/routes.dart';

class ManageWordMorphologyDetailsController extends GetxController with DualBreadcrumbMixin {
  final String tag;
  ManageWordMorphologyDetailsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_WORD_MORPHOLOGY_DETAILS;

  @override
  String get breadcrumbTitle => '词根词缀词卡页';

  String? morphemeNid;
  String? key;
  bool isUserSide = false;

  final Rx<WordMorphologyWordsPageEntity> detail = WordMorphologyWordsPageEntity().obs;

  final RxList<CardMorphemeWordEntityDatas> wordList = <CardMorphemeWordEntityDatas>[].obs;

  final ScrollController scrollController = ScrollController();

  final Map<String, String> formPositionNameMap = <String, String>{};

  int offset = 0;

  int limit = 30;

  int total = 0;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      morphemeNid = Get.arguments["morphemeNid"];
      key = Get.arguments["key"]?.toString();
      final dynamic isUserSideValue = Get.arguments["isUserSide"];
      isUserSide = isUserSideValue == true || isUserSideValue?.toString() == 'true';
    }
    initBreadcrumb(tag);
    if (!isUserSide) {
      getFiltersGroup();
    }
    listenScroll();
    getDetails();
  }

  Future<void> getFiltersGroup() async {
    try {
      FiltersGroupEntity? filtersGroup = await LanguageConsoleRequest.getWordMorphologyFilters();
      if (filtersGroup == null) return;
      List<FiltersGroupEntityFilters?> filters = filtersGroup.filters ?? [];
      for (int i = 0; i < filters.length; i++) {
        if (filters[i]?.code != "formPosition") continue;
        List<FiltersGroupEntityValues?> values = filters[i]?.values ?? [];
        for (int j = 0; j < values.length; j++) {
          String? value = values[j]?.value;
          String? name = values[j]?.name;
          if (value == null || name == null) continue;
          formPositionNameMap[value] = name;
        }
      }
    } catch (_) {}
  }

  void listenScroll() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 400 &&
          !scrollController.position.outOfRange) {
        if (!isLoading.value && wordList.length < total) {
          offset += limit;
          getDetails(refreshHeader: false);
        }
      }
    });
  }

  Future<void> refreshPage() async {
    offset = 0;
    total = 0;
    wordList.clear();
    await getDetails();
  }

  Future<void> getDetails({bool refreshHeader = true}) async {
    if ((morphemeNid ?? '').isEmpty && (key ?? '').isEmpty) return;
    try {
      isLoading.value = true;
      ToastUtils.showLoading();
      WordMorphologyWordsPageEntity? res;
      if ((key ?? '').isNotEmpty) {
        if (isUserSide) {
          res = await ElementsRequest.getWordMorphologyRootMemberPage(
            key: key!,
            parameters: {
              "offset": offset,
              "limit": limit,
            },
          );
        } else {
          res = await LanguageConsoleRequest.queryWordMorphologyRootMemberPage(
            key: key!,
            parameters: {
              "offset": offset,
              "limit": limit,
            },
          );
        }
      } else {
        if (isUserSide) {
          res = await ElementsRequest.getWordMorphologyMorphemeMemberPage(
            morphemeNid: morphemeNid!,
            parameters: {
              "offset": offset,
              "limit": limit,
            },
          );
        } else {
          res = await LanguageConsoleRequest.queryWordMorphologyWordsPage(
            morphemeNid: morphemeNid!,
            parameters: {
              "offset": offset,
              "limit": limit,
            },
          );
        }
      }
      if (res == null) return;
      if (refreshHeader || !hasDetailData()) {
        detail.value = res;
        updateBreadcrumbTitle("${res.content ?? ''} · ${isRootKeyMode() ? '共享词根' : '词根词缀'}");
      }
      ListResponseEntity<CardMorphemeWordEntityDatas>? pageData = res.data;
      total = pageData?.count ?? total;
      wordList.addAll(pageData?.datas ?? []);
    } finally {
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }

  String getLangText(List<LanguageText?>? values, String lang) {
    if (values == null || values.isEmpty) return '';
    for (int i = 0; i < values.length; i++) {
      if (values[i]?.lang == lang) {
        return values[i]?.text ?? '';
      }
    }
    return '';
  }

  String getHeaderDescription() {
    String semanticHint = getLangText(detail.value.semanticHint, "zh");
    if (semanticHint.isNotEmpty) return semanticHint;
    String description = getLangText(detail.value.descriptions, "zh");
    if (description.isNotEmpty) return description;
    return getLangText(detail.value.translate, "zh");
  }

  LanguageConfigColorEntityInfo? getMorphemeTypeConfig(String? code) {
    if (code == null || code.isEmpty) return null;
    List<LanguageConfigColorEntityInfo?> morphemeTypes = Get.find<ConfigController>().colorConfigs.value.morphemeTypes ?? [];
    for (int i = 0; i < morphemeTypes.length; i++) {
      if (morphemeTypes[i]?.code?.toLowerCase() == code.toLowerCase()) {
        return morphemeTypes[i];
      }
    }
    return null;
  }

  String getMorphemeTypeTitle(String? code) {
    return getMorphemeTypeConfig(code)?.title ?? '';
  }

  Color? getMorphemeTypeTextColor(String? code) {
    return ColorUtils.parseColor(getMorphemeTypeConfig(code)?.color?.textColor);
  }

  LanguageConfigColorModel? getPosConfig(String? code) {
    if (code == null || code.isEmpty) return null;
    return StatusUtils.getConfigColor(Get.find<ConfigController>().colorConfigs.value.pos, code);
  }

  String getPosTitle(String? code) {
    return getPosConfig(code)?.title ?? '';
  }

  Color? getPosTextColor(String? code) {
    return getPosConfig(code)?.color?.borderColor;
  }

  String getFormPositionName(String? code) {
    if (code == null || code.isEmpty) return '';
    return formPositionNameMap[code] ?? '';
  }

  String getLearningLang() {
    return Get.find<ConfigController>().userSetting.value.learningLang;
  }

  bool isRootKeyMode() {
    return (key ?? '').isNotEmpty;
  }

  bool hasDetailData() {
    if (isRootKeyMode()) {
      return (detail.value.key ?? '').isNotEmpty || detail.value.contentId != null;
    }
    return (detail.value.nid ?? '').isNotEmpty;
  }

  String getEmptyIdentifier() {
    if (isRootKeyMode()) return key ?? '';
    return morphemeNid ?? '';
  }

  void jumpToTreePage(CardMorphemeWordEntityDatas data) {
    if (data.contentId == null) return;
    if (isUserSide) {
      TagRoutes.toNamed(
        Routes.MANAGE_WORD_MORPHOLOGY_TREE,
        arguments: {
          'key': data.contentId,
          'isUserSide': true,
        },
      );
      return;
    }
    String treeMorphemeNid = isRootKeyMode() ? (key ?? '') : (morphemeNid ?? '');
    if (treeMorphemeNid.isEmpty) return;
    TagRoutes.toNamed(
      Routes.MANAGE_WORD_MORPHOLOGY_TREE,
      arguments: {
        'morphemeNid': treeMorphemeNid,
        'wordId': data.contentId,
      },
    );
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
