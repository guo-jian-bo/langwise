import 'dart:io';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/tag_routes.dart';
import '../../../management/common/manage_select_knowledge_table/view.dart';
import '../../../management/utils/utils.dart';
import 'course_unit_target_controller.dart';
import 'course_unit_target_knowledge_controller.dart';

class CourseUnitTargetManageController extends GetxController {
  final String tagText;
  CourseUnitTargetManageController({required this.tagText});

  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{
    "locked": FilterConditionsData(
      title: "定稿状态",
      conditions: [
        FilterConditionsItem(
          name: "定稿",
          value: true,
        ),
        FilterConditionsItem(
          name: "未定稿",
          value: false,
        ),
      ],
    ),
    "show": FilterConditionsData(
      title: "可见状态",
      conditions: [
        FilterConditionsItem(
          name: "前端可见",
          value: true,
        ),
        FilterConditionsItem(
          name: "前端不可见",
          value: false,
        ),
      ],
    ),
  }.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "content": FilterSearchsData(
      title: "搜索",
      hintText: "搜索知识点",
      controller: TextEditingController(),
    ),
  };

  /// 搜索框控制器。
  TextEditingController get searchController => filterSearchs["content"]!.controller;

  /// 是否正在排序模式下。
  final RxBool isSortingMode = false.obs;

  /// 执行筛选操作。
  Future<void> executeFilter() async {
    _applySearchAndFilter();
  }

  /// 执行搜索操作。
  Future<void> executeSearch() async {
    _applySearchAndFilter();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// 应用搜索和筛选条件，并刷新各分类展示结果。
  void _applySearchAndFilter() {
    final CourseUnitTargetKnowledgeController knowledgeController = Get.find<CourseUnitTargetKnowledgeController>(tag: tagText);
    final CourseUnitTargetController targetController = Get.find<CourseUnitTargetController>(tag: tagText);
    final String keyword = searchController.text.trim();
    final List<KnowledgeCommonEntityList> respList = [];
    final List<CourseUnitTargetSentenceGrammarPointEntity> sentenceGrammarRespList = [];

    for (int i = 0; i < knowledgeController.allKnowledgeList.length; i++) {
      final KnowledgeCommonEntityList item = knowledgeController.allKnowledgeList[i];

      if (!_matchesSearch(item, keyword)) continue;
      if (!_matchesFilter(item)) continue;

      respList.add(item);
    }

    for (int i = 0; i < knowledgeController.allSentenceGrammarList.length; i++) {
      final CourseUnitTargetSentenceGrammarPointEntity item = knowledgeController.allSentenceGrammarList[i];
      if (!_matchesSentenceGrammarSearch(item, keyword)) continue;
      sentenceGrammarRespList.add(item);
    }

    knowledgeController.updateDisplayKnowledgeList(respList);
    knowledgeController.updateDisplaySentenceGrammarList(sentenceGrammarRespList);
    targetController.separateKnowledgeType(shouldResetKnowledgeType: false);
  }

  /// 判断当前知识点是否命中搜索关键词。
  bool _matchesSearch(KnowledgeCommonEntityList item, String keyword) {
    if (keyword.isEmpty) return true;

    final String lowerKeyword = keyword.toLowerCase();
    if (item.title?.toLowerCase().contains(lowerKeyword) == true) return true;
    if (item.subTitle?.toLowerCase().contains(lowerKeyword) == true) return true;

    final List<LanguageText?>? descriptionList = item.description;
    if (descriptionList != null) {
      for (final LanguageText? description in descriptionList) {
        if (description?.text?.toLowerCase().contains(lowerKeyword) == true) return true;
      }
    }

    final List<LanguageText?>? focusList = item.focus;
    if (focusList != null) {
      for (final LanguageText? focus in focusList) {
        if (focus?.text?.toLowerCase().contains(lowerKeyword) == true) return true;
      }
    }

    return false;
  }

  /// 判断当前语法点是否命中搜索关键词。
  bool _matchesSentenceGrammarSearch(CourseUnitTargetSentenceGrammarPointEntity item, String keyword) {
    if (keyword.isEmpty) return true;

    final String lowerKeyword = keyword.toLowerCase();
    if (item.title?.toLowerCase().contains(lowerKeyword) == true) return true;
    if (item.description?.toLowerCase().contains(lowerKeyword) == true) return true;
    if (item.objective?.toLowerCase().contains(lowerKeyword) == true) return true;

    final List<CourseUnitTargetSentenceGrammarTargetEntity?>? targets = item.targets;
    if (targets != null) {
      for (final CourseUnitTargetSentenceGrammarTargetEntity? target in targets) {
        if (target?.title?.toLowerCase().contains(lowerKeyword) == true) return true;
        if (target?.assetLabel?.toLowerCase().contains(lowerKeyword) == true) return true;
        if (target?.statusLabel?.toLowerCase().contains(lowerKeyword) == true) return true;
        if (target?.assetNid?.toLowerCase().contains(lowerKeyword) == true) return true;
      }
    }

    return false;
  }

  /// 判断当前知识点是否满足筛选条件。
  bool _matchesFilter(KnowledgeCommonEntityList item) {
    final Map<String, dynamic> conditionParameter = FilterStripUtils.getConditionParameter(conditions: filterConditions);

    final bool? locked = conditionParameter["locked"];
    final bool knowledgeLocked = item.locked == true;
    if (locked != null && locked != knowledgeLocked) return false;

    final bool? show = conditionParameter["show"];
    final bool accessIsVisible = item.accessIsVisible;
    if (show != null && show != accessIsVisible) return false;

    return true;
  }

  Future<void> adminAddKnowledgeFunction({
    required BuildContext context,
    required KnowledgeTypeEnum knowledgeType,
  }) async {
    final controller = Get.find<CourseUnitTargetController>(tag: tagText);
    final knowledgeController = Get.find<CourseUnitTargetKnowledgeController>(tag: tagText);
    bool isHideOther = controller.unitKnowledgePoints.value.specialty == SpecialtyEnum.EN_PHONICS;

    bool showWord = knowledgeType == KnowledgeTypeEnum.EN_WORD && !isHideOther;
    bool showPhrase = knowledgeType == KnowledgeTypeEnum.EN_PHRASE && !isHideOther;
    bool showSentence = knowledgeType == KnowledgeTypeEnum.EN_SENTENCE && !isHideOther;
    bool showText = knowledgeType == KnowledgeTypeEnum.EN_TEXT && !isHideOther;

    List<BaseKnowledge>? values = await ManageSelectKnowledgeTableManager.show(
      context: context,
      defaultDessert: [],
      language: "en",
      showSelectKnowledgeAddButton: true,
      hideWord: !showWord,
      hidePhrase: !showPhrase,
      hideSentence: !showSentence,
      hideText: !showText,
      currentKnowledgeType: knowledgeType,
      topic: controller.unitKnowledgePoints.value.moduleTopic,
      dataDisableCallback: (BaseKnowledge targetEntity) {
        bool isDisable = knowledgeController.allKnowledgeList.any((element) => element.contentId == targetEntity.uid);
        return isDisable;
      },
    );
    if (values == null) return;

    try {
      final List<Knowledge> newLs = <Knowledge>[];

      for (int i = 0; i < values.length; i++) {
        final entity = values[i];
        if (entity is EnWordEntity) {
          newLs.add(Knowledge(
            uid: entity.uid,
            contentType: entity.contentType,
            content: entity.content,
            contentId: entity.uid,
            definition: entity.definition,
            semanticId: entity.selectedSemantics?.uid,
            imageUrl: entity.imageUrl,
            audioUrl: entity.audioUrl,
            language: entity.language,
          ));
        } else if (entity is EnPhraseEntity) {
          newLs.add(Knowledge(
            uid: entity.uid,
            contentType: entity.contentType,
            content: entity.content,
            contentId: entity.uid,
            definition: entity.definition,
            semanticId: entity.selectedSemantics?.uid,
            imageUrl: entity.imageUrl,
            audioUrl: entity.audioUrl,
            language: entity.language,
          ));
        } else if (entity is EnSentenceEntity) {
          newLs.add(Knowledge(
            uid: entity.uid,
            contentType: entity.contentType,
            content: entity.content,
            contentId: entity.uid,
            definition: entity.definition,
            semanticId: entity.selectedSemantics?.uid,
            imageUrl: entity.imageUrl,
            audioUrl: entity.audioUrl,
            language: entity.language,
          ));
        } else if (entity is EnTextEntity) {
          newLs.add(Knowledge(
            uid: entity.uid,
            contentType: entity.contentType,
            content: entity.content,
            contentId: entity.uid,
            definition: entity.title,
            imageUrl: entity.imageUrl,
            audioUrl: entity.audioUrl,
            language: entity.language,
          ));
        }
      }

      RequestConfig requestConfig = RequestConfig(
        requireToken: true,
        parameters: {"moduleId": controller.unitKnowledgePoints.value.moduleId},
        data: newLs.map((element) => element.toJson()).toList(),
      );
      ToastUtils.showLoading();
      final response = await KnowledgeUtil.add(unitId: controller.unitKnowledgePoints.value.unitId, config: requestConfig);
      if (response.code == HttpStatus.ok) {
        ToastUtils.showManageToast(text: '添加知识点成功');
        controller.refreshUnitTarget();
      } else {
        ToastUtils.showManageToast(text: response.message ?? '添加知识点失败');
      }
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
    } catch (e) {
      ToastUtils.showManageToast(text: e.toString());
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 添加语法
  Future<void> adminAddSyntaxFunction() async {
    final controller = Get.find<CourseUnitTargetController>(tag: tagText);
    final dynamic result = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_UNIT_GRAMMAR_ADD,
      arguments: {
        "unitId": controller.unitKnowledgePoints.value.unitId,
      },
    );
    if (result != true) return;
    controller.switchSyntaxType(2);
    controller.refreshUnitTarget();
    ToastUtils.showManageToast(text: "语法追加成功");
  }

  /// 语法管线
  Future<void> adminAddPipelineFunction() async {
    final controller = Get.find<CourseUnitTargetController>(tag: tagText);
    final int? unitId = controller.unitKnowledgePoints.value.unitId;
    if (unitId == null) return;
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_UNIT_GRAMMAR_HUB,
      arguments: {
        'moduleId': controller.unitKnowledgePoints.value.moduleId,
        'unitId': unitId,
        'unitName': controller.unitKnowledgePoints.value.unitName,
      },
    );
    controller.refreshUnitTarget();
  }

  /// 添加歌曲
  Future<void> adminAddSongFunction() async {
    final controller = Get.find<CourseUnitTargetController>(tag: tagText);
    final knowledgeController = Get.find<CourseUnitTargetKnowledgeController>(tag: tagText);
    int? unitId = controller.unitKnowledgePoints.value.unitId;
    if(unitId == null) return;
    CourseUnitTargetDifficultyEntity? difficulty = controller.unitKnowledgePoints.value.difficulty;
    String? unitDescription = controller.unitKnowledgePoints.value.description;
    List<Map<String, dynamic>> contentList = [];
    for (int i = 0; i < knowledgeController.allKnowledgeList.length; i++) {
      KnowledgeCommonEntityList item = knowledgeController.allKnowledgeList[i];
      if(item.contentType != ElementsCardType.song.value) continue;
      if(item.contentId == null) continue;
      contentList.add({
        "content": {
          "type": item.contentType,
          "uid": item.contentId,
        },
      });
    }
    Map<String, List<String>> presetFilters = {
      "contentType": ["EN_SONG"],
    };
    if(difficulty != null){
      int? min = difficulty.min;
      int? max = difficulty.max;
      if(min != null && max != null){
        if(min > max){
          int t = min;
          min = max;
          max = t;
        }
        List<String> values = [];
        for(int i = min; i <= max; i++){
          values.add(i.toString());
        }
        presetFilters["difficulty"] = values;
      }else if(min != null || max != null){
        int v = (min ?? max)!;
        presetFilters["difficulty"] = [v.toString()];
      }
    }
    dynamic result = await TagRoutes.toNamed(
      Routes.INTELLIGENT_SEARCH,
      arguments: {
        "moduleId": controller.unitKnowledgePoints.value.moduleId,
        "unitId": unitId,
        "isSelectable": true,
        "presetFilters": presetFilters,
        if(contentList.isNotEmpty) "contentList": contentList,
        if((unitDescription ?? "").trim().isNotEmpty) "searchHint": unitDescription,
      },
    );
    if(result is! List || result.isEmpty) return;

    final List<Knowledge> newLs = <Knowledge>[];
    for (int i = 0; i < result.length; i++) {
      if(result[i] is! Map) continue;
      KnowledgeCommonEntityListContent content = KnowledgeCommonEntityListContent.fromJson(
        Map<String, dynamic>.from(result[i] as Map),
      );
      if(content.uid == null || content.type == null) continue;
      newLs.add(Knowledge(
        uid: content.uid ?? 0,
        contentType: content.type,
        contentId: content.uid,
      ));
    }
    if(newLs.isEmpty) return;

    try {
      RequestConfig requestConfig = RequestConfig(
        requireToken: true,
        parameters: {"moduleId": controller.unitKnowledgePoints.value.moduleId},
        data: newLs.map((element) => element.toJson()).toList(),
      );
      ToastUtils.showLoading();
      final response = await KnowledgeUtil.add(unitId: unitId, config: requestConfig);
      if (response.code == HttpStatus.ok) {
        ToastUtils.showManageToast(text: '添加歌曲成功');
        controller.refreshUnitTarget();
      } else {
        ToastUtils.showManageToast(text: response.message ?? '添加歌曲失败');
      }
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
    } catch (e) {
      ToastUtils.showManageToast(text: e.toString());
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 生成歌曲
  Future<void> generateLessonSong() async {
    final controller = Get.find<CourseUnitTargetController>(tag: tagText);
    int? unitId = controller.unitKnowledgePoints.value.unitId;
    if(unitId == null) return;
    final result = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_GENERAL_SONG_PAGE,
      arguments: {'unitId': unitId},
    );
    if (result ?? false) {
      controller.refreshUnitTarget();
    }
  }

  /// 生成文章
  Future<void> generateLessonArticle() async {
    final controller = Get.find<CourseUnitTargetController>(tag: tagText);
    int? moduleId = controller.unitKnowledgePoints.value.moduleId;
    if(moduleId == null) return;
    int? unitId = controller.unitKnowledgePoints.value.unitId;
    if(unitId == null) return;
    final result = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_MODULE_DETILS_GENERATE_ARTICLE,
      arguments: {
        'moduleId': moduleId,
        'unitId': unitId,
      },
    );
    if (result ?? false) {
      controller.refreshUnitTarget();
    }
  }

  /// 获取指定分类的上架进度文案，口径始终基于原始列表，避免被搜索筛选影响。
  String getKnowledgePublishProgressText(CourseUnitTargetEnum knowledgeType) {
    final knowledgeController = Get.find<CourseUnitTargetKnowledgeController>(tag: tagText);
    List<KnowledgeCommonEntityList> list = <KnowledgeCommonEntityList>[];
    if (knowledgeType == CourseUnitTargetEnum.listening) {
      list = knowledgeController.allListeningKnowledgeList;
    } else if (knowledgeType == CourseUnitTargetEnum.reading) {
      list = knowledgeController.allReadingKnowledgeList;
    }
    int publishedCount = 0;
    for (int i = 0; i < list.length; i++) {
      if (list[i].accessIsVisible) publishedCount++;
    }
    return "上架 $publishedCount/${list.length}";
  }

  /// 添加综合
  Future<void> addComprehensiveKnowledge() async {
    final controller = Get.find<CourseUnitTargetController>(tag: tagText);
    int? unitId = controller.unitKnowledgePoints.value.unitId;
    if(unitId == null) return;
    final result = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_CREATE_UNIT_SCRIPT,
      arguments: {'unitId': unitId},
    );
    if (result ?? false) {
      controller.refreshUnitTarget();
    }
  }

  /// 进入/退出排序模式
  void toggleSortMode() {
    final controller = Get.find<CourseUnitTargetController>(tag: tagText);
    if(controller.currentKnowledgeType.value == CourseUnitTargetEnum.syntax){
      controller.switchSyntaxType(0);
    }
    isSortingMode.value = !isSortingMode.value;
  }

  /// 知识点排序
  Future<void> onSortKnowledge(int oldIndex, int newIndex) async {
    final controller = Get.find<CourseUnitTargetController>(tag: tagText);
    final knowledgeController = Get.find<CourseUnitTargetKnowledgeController>(tag: tagText);
    CourseUnitTargetEnum knowledgeType = controller.currentKnowledgeType.value;
    int? unitId = controller.unitKnowledgePoints.value.unitId;
    if (unitId == null) return;

    List<KnowledgeCommonEntityList> list = <KnowledgeCommonEntityList>[];
    if (knowledgeType == CourseUnitTargetEnum.vocabulary) {
      list = knowledgeController.allVocabularyKnowledgeList;
    } else if (knowledgeType == CourseUnitTargetEnum.syntax) {
      list = knowledgeController.allSyntaxKnowledgeList;
    } else if (knowledgeType == CourseUnitTargetEnum.listening) {
      list = knowledgeController.allListeningKnowledgeList;
    } else if (knowledgeType == CourseUnitTargetEnum.reading) {
      list = knowledgeController.allReadingKnowledgeList;
    } else if (knowledgeType == CourseUnitTargetEnum.writing) {
      list = knowledgeController.allWritingKnowledgeList;
    } else if (knowledgeType == CourseUnitTargetEnum.comprehensive) {
      list = knowledgeController.allComprehensiveKnowledgeList;
    }
    if (list.isEmpty) return;
    if (oldIndex < 0 || oldIndex >= list.length) return;
    if (newIndex < 0 || newIndex >= list.length) return;
    if (oldIndex == newIndex) return;

    final KnowledgeCommonEntityList movedLesson = list.removeAt(oldIndex);
    list.insert(newIndex, movedLesson);
    _applySortedListToAllKnowledgeByType(knowledgeType, list, knowledgeController);
    _applySearchAndFilter();
    try {
      ToastUtils.showLoading();

      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: {
          "index": newIndex + 1,
          "type": movedLesson.contentType,
        },
      );

      final response = await KnowledgeUtil.order(
        unitId: unitId.toString(),
        knowledgeId: movedLesson.contentId,
        config: config,
      );
      if (response.code == HttpStatus.ok) {
        ToastUtils.showToast(text: "排序成功", type: ToastType.success);
      } else {
        ToastUtils.showToast(text: response.message ?? "排序失败");
        controller.refreshUnitTarget();
      }
    } catch (_) {
      controller.refreshUnitTarget();
      ToastUtils.showToast(text: "排序失败");
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 将分类排序结果同步回完整原始知识点列表中，保持其他分类顺序不变。
  void _applySortedListToAllKnowledgeByType(
    CourseUnitTargetEnum knowledgeType,
    List<KnowledgeCommonEntityList> sortedList,
    CourseUnitTargetKnowledgeController knowledgeController,
  ) {
    final List<KnowledgeCommonEntityList> allList = knowledgeController.allKnowledgeList.toList();
    int sortedIndex = 0;
    for (int i = 0; i < allList.length; i++) {
      final KnowledgeCommonEntityList item = allList[i];
      final CourseUnitTargetEnum itemType = knowledgeController.getSeparatedKnowledgeType(item.contentTypeEnum);
      if (itemType == knowledgeType && sortedIndex < sortedList.length) {
        allList[i] = sortedList[sortedIndex];
        sortedIndex++;
      }
    }
    knowledgeController.allKnowledgeList.assignAll(allList);
  }
}
