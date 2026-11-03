import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../../../../common/entities/entities.dart';
import '../../../../../../../../common/https/https.dart';
import '../../../../../../routes/routes.dart';
import '../../../../dialog/dialogs.dart';
import '../../../../utils/manage_breadcrumb_utils.dart';

class ManageModuleDetilsGenerateArticleController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageModuleDetilsGenerateArticleController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_MODULE_DETILS_GENERATE_ARTICLE;

  @override
  String get breadcrumbTitle => '生成文章';

  int? moduleId;
  int? unitId;

  final RxList<TextSubjectThemeEntityThemes> themeList = <TextSubjectThemeEntityThemes>[].obs;
  final RxList<TextSubjectThemeEntityThemes> genreList = <TextSubjectThemeEntityThemes>[].obs;

  /// 选择的主题
  final Rx<TextSubjectThemeEntityThemes?> selectedTheme = Rx(null);

  /// 选择的题材
  final Rx<TextSubjectThemeEntityThemes?> selectedGenre = Rx(null);

  final String themeKey = "theme";
  final String genreKey = "genre";

  /// 已经添加的组合
  final RxList<Map<String, TextSubjectThemeEntityThemes>> combinationList = <Map<String, TextSubjectThemeEntityThemes>>[].obs;

  /// 已选择的知识点列表
  final RxList<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = <UnitKnowledgePointsEntityKnowledgeList>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    if (Get.arguments != null) {
      moduleId = Get.arguments?["moduleId"];
      unitId = Get.arguments?["unitId"];
    }

    getThemeList();
  }

  /// 获取主题题材列表
  Future<void> getThemeList() async {
    try {
      ToastUtils.showLoading();

      TextSubjectThemeEntity? entity = await LanguageConsoleRequest.getThemeList();
      if (entity == null) return;
      themeList.clear();
      genreList.clear();
      List<TextSubjectThemeEntityThemes?> themes = entity.themes ?? [];
      for (TextSubjectThemeEntityThemes? theme in themes) {
        if (theme == null) continue;
        themeList.add(theme);
      }
      if (themeList.isNotEmpty) {
        selectedTheme.value = themeList.first;
      }

      List<TextSubjectThemeEntityThemes?> genres = entity.genres ?? [];
      for (TextSubjectThemeEntityThemes? genre in genres) {
        if (genre == null) continue;
        genreList.add(genre);
      }
      if (genreList.isNotEmpty) {
        selectedGenre.value = genreList.first;
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 选择主题
  void selectTheme(TextSubjectThemeEntityThemes theme) {
    selectedTheme.value = theme;
  }

  /// 选择题材
  void selectGenre(TextSubjectThemeEntityThemes genre) {
    selectedGenre.value = genre;
  }

  /// 添加组合
  void addCombination() {
    if (selectedTheme.value == null || selectedGenre.value == null) return;

    bool isExist = combinationList.any((elements) {
      bool isExist = elements[themeKey]?.id == selectedTheme.value!.id && elements[genreKey]?.id == selectedGenre.value!.id;
      return isExist;
    });
    if (isExist) {
      ToastUtils.showToast(text: "该主题-题材组合已存在");
      return;
    }

    combinationList.add({themeKey: selectedTheme.value!, genreKey: selectedGenre.value!});
  }

  /// 删除组合
  void removeCombination(int index) {
    combinationList.removeAt(index);
  }

  /// 添加知识点
  Future<void> showSelectKnowledgeDialog(BuildContext context) async {
    if(unitId == null) return;

    List<UnitKnowledgePointsEntityKnowledgeList>? values = await ManageSelectUnitKnowledgeDialog.show(
      context: context,
      unitId: unitId!,
      initSelect: knowledgeList.toList(),
    );
    if(values == null) return;
    knowledgeList.value = values;
  }

  /// 删除知识点
  void removeSelectedKnowledge(UnitKnowledgePointsEntityKnowledgeList knowledge, int index) {
    knowledgeList.removeAt(index);
  }

  /// 确定生成文章
  Future<void> generateArticle(BuildContext context) async {
    if (unitId == null) return;

    List<Map<String, dynamic>> remix = [];
    for (int i = 0; i < combinationList.length; i++) {
      remix.add({
        "theme": combinationList[i][themeKey]?.name?.firstWhereOrNull((e) => e?.lang == "en")?.text,
        "genre": combinationList[i][genreKey]?.name?.firstWhereOrNull((e) => e?.lang == "en")?.text,
      });
    }

    List<Map<String, dynamic>> knowledgePoints = [];

    for (int i = 0; i < knowledgeList.length; i++) {
      knowledgePoints.add({
        "content": knowledgeList[i].content,
        "contentType": knowledgeList[i].contentType,
        "contentId": knowledgeList[i].uid,
        "semanticId": knowledgeList[i].semanticId,
      });
    }

    Map<String, dynamic> reqData = {
      "moduleId": moduleId,
      "remix": remix,
    };

    if (knowledgePoints.isNotEmpty) {
      reqData["knowledgePoints"] = knowledgePoints;
    }

    try {
      ToastUtils.showLoading();
      String? res = await CourseConsoleRequest.generateRemixArticle(unitId!, reqData);
      if (res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);

      await Future.delayed(const Duration(milliseconds: 500));

      Get.back(result: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }
}
