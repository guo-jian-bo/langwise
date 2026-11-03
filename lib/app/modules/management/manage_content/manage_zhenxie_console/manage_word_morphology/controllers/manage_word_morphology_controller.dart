import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/public_controller/config_controller.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/tag_routes.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';

class ManageWordMorphologyController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageWordMorphologyController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_WORD_MORPHOLOGY;

  @override
  String get breadcrumbTitle => '词根词缀';

  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{}.obs;

  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{}.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "q": FilterSearchsData(
      title: "搜索",
      hintText: "content / nid / 词素 / 例词",
      controller: TextEditingController(),
    ),
  };

  final RxList<WordMorphologySummaryTypeEntity> summaryTypeList = <WordMorphologySummaryTypeEntity>[].obs;

  final RxList<WordMorphologyListItemEntity> morphologyList = <WordMorphologyListItemEntity>[].obs;

  final ScrollController scrollController = ScrollController();

  final Map<String, String> morphemeTypeNameMap = <String, String>{};

  final Map<String, String> formPositionNameMap = <String, String>{};

  int total = 0;

  int offset = 0;

  int limit = 30;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    listenScroll();
    initData();
  }

  Future<void> initData() async {
    try {
      isLoading.value = true;
      ToastUtils.showLoading();
      await getSummaryData();
      await getFiltersGroup();
      await getListData(showLoading: false);
    } finally {
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }

  void listenScroll() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 &&
          !scrollController.position.outOfRange) {
        if (!isLoading.value && morphologyList.length < total) {
          offset += limit;
          getListData();
        }
      }
    });
  }

  Future<void> getSummaryData() async {
    try {
      WordMorphologySummaryEntity? summary = await LanguageConsoleRequest.getWordMorphologySummary();
      summaryTypeList.value = summary?.types?.whereType<WordMorphologySummaryTypeEntity>().toList() ?? [];
    } catch (_) {}
  }

  Future<void> getFiltersGroup() async {
    try {
      FiltersGroupEntity? filtersGroup = await LanguageConsoleRequest.getWordMorphologyFilters();
      if (filtersGroup == null) return;
      filterConditions.value = FilterStripUtils.getConditionDataFrom(filtersGroup);
      filterSorts.value = FilterStripUtils.getSortDataFrom(filtersGroup);
      cacheFilterValueNames(filtersGroup);
    } catch (_) {}
  }

  Future<void> refreshList() async {
    morphologyList.clear();
    offset = 0;
    total = 0;
    getListData();
  }

  Future<void> getListData({bool showLoading = true}) async {
    try {
      isLoading.value = true;
      if (showLoading) ToastUtils.showLoading();
      Map<String, dynamic> params = {
        "offset": offset,
        "limit": limit,
      };
      Map<String, dynamic> sortParams = FilterStripUtils.getSortOrderParameter(sorts: filterSorts);
      if (sortParams["order"] != null) {
        params.addAll(sortParams);
      }

      Map<String, dynamic> reqData = {};
      Map<String, dynamic> conditionParams = FilterStripUtils.getConditionParameter(
        conditions: filterConditions,
        singleToList: true,
      );
      List<Map<String, dynamic>> filters = [];
      conditionParams.forEach((key, value) {
        filters.add({
          "code": key,
          "values": value,
        });
      });
      if (filters.isNotEmpty) {
        reqData["filters"] = filters;
      }
      Map<String, dynamic> searchParams = FilterStripUtils.getSearchParameter(searchs: filterSearchs);
      if (searchParams.isNotEmpty) {
        reqData.addAll(searchParams);
      }

      ListResponseEntity<WordMorphologyListItemEntity>? list = await LanguageConsoleRequest.queryWordMorphologyList(
        parameters: params,
        data: reqData,
      );
      if (list == null) return;
      total = list.count ?? 0;
      morphologyList.addAll(list.datas ?? []);
    } finally {
      isLoading.value = false;
      if (showLoading) ToastUtils.hideLoading();
    }
  }

  void cacheFilterValueNames(FiltersGroupEntity filtersGroup) {
    morphemeTypeNameMap.clear();
    formPositionNameMap.clear();

    List<FiltersGroupEntityFilters?> filters = filtersGroup.filters ?? [];
    for (int i = 0; i < filters.length; i++) {
      String? code = filters[i]?.code;
      List<FiltersGroupEntityValues?> values = filters[i]?.values ?? [];
      for (int j = 0; j < values.length; j++) {
        String? value = values[j]?.value;
        String? name = values[j]?.name;
        if (value == null || name == null) continue;
        if (code == "morphemeType") {
          morphemeTypeNameMap[value] = name;
        }
        if (code == "formPosition") {
          formPositionNameMap[value] = name;
        }
      }
    }
  }

  void jumpToDetailPage(WordMorphologyListItemEntity data) {
    if ((data.nid ?? '').isEmpty) {
      ToastUtils.showManageToast(text: "缺少 morpheme nid，暂时无法进入词卡页");
      return;
    }
      TagRoutes.toNamed(
      Routes.MANAGE_WORD_MORPHOLOGY_DETAILS,
      arguments: {
        "morphemeNid": data.nid,
      },
    );
  }

  String getFormPositionName(String? value) {
    if (value == null || value.isEmpty) return '';
    return formPositionNameMap[value] ?? value;
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

  Color? getTierColor(String? color) {
    if (color == null || color.isEmpty) return null;
    return ColorUtils.parseColor(color);
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

  String getLearningLang() {
    return Get.find<ConfigController>().userSetting.value.learningLang;
  }

  @override
  void onClose() {
    scrollController.dispose();
    filterSearchs.forEach((key, value) {
      value.controller.dispose();
    });
    super.onClose();
  }
}
