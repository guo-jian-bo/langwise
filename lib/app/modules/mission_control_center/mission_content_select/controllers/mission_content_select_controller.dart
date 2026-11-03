import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../utils/utils.dart';
import '../models/mission_content_select_model.dart';

class MissionContentSelectController extends GetxController with RoutesBreadcrumbMixin, PageRefreshAwareMixin{
  static final List<String> sectionTypeOrder = [
    ElementsCardType.word.value,
    ElementsCardType.phrase.value,
    ElementsCardType.sentence.value,
  ];

  final String tagText;
  MissionContentSelectController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.MISSION_CONTENT_SELECT;

  @override
  String get breadcrumbTitle => "内容选择";

  final RxInt loadStatus = (-1).obs;
  final Rx<MissionContentSelectFilter> selectedFilter = MissionContentSelectFilter.all.obs;
  final RxList<MissionContentSelectItemModel> contentItems = <MissionContentSelectItemModel>[].obs;
  final RxMap<String, bool> selectedKeyMap = <String, bool>{}.obs;
  final RxList<MissionContentSelectItemModel> visibleWordItems = <MissionContentSelectItemModel>[].obs;
  final RxList<MissionContentSelectItemModel> visiblePhraseItems = <MissionContentSelectItemModel>[].obs;
  final RxList<MissionContentSelectItemModel> visibleSentenceItems = <MissionContentSelectItemModel>[].obs;
  final RxInt visibleItemCount = 0.obs;
  final RxString currentAnchorType = ''.obs;
  final ScrollController scrollController = ScrollController();
  final Map<String, GlobalKey> sectionKeys = {
    ElementsCardType.word.value: GlobalKey(),
    ElementsCardType.phrase.value: GlobalKey(),
    ElementsCardType.sentence.value: GlobalKey(),
  };

  String missionTitle = "";
  String missionSubtitle = "";
  String startAction = MissionContentSelectAction.preview;
  String? learnUploadType;
  String? contentSource;
  int? courseId;
  int? moduleId;
  int? unitId;
  List<TaskMissionEntityMissionKnowledgeItem> sourceKnowledgeList = [];
  late final ConfigController _configController;

  bool get isCurrentCourseSource => contentSource == "current_course_unit";

  @override
  void onInit() {
    super.onInit();
    _configController = Get.find<ConfigController>();
    initBreadcrumb(tagText);
    scrollController.addListener(_syncCurrentAnchorTypeByScroll);
    if (Get.arguments != null) {
      missionTitle = (Get.arguments["missionTitle"] ?? "").toString();
      missionSubtitle = (Get.arguments["missionSubtitle"] ?? "").toString();
      startAction = (Get.arguments["startAction"] ?? MissionContentSelectAction.preview).toString();
      learnUploadType = Get.arguments["learnUploadType"]?.toString();
      contentSource = Get.arguments["contentSource"]?.toString();
      courseId = Get.arguments["courseId"];
      moduleId = Get.arguments["moduleId"];
      unitId = Get.arguments["unitId"];
      final rawList = Get.arguments["knowledgeList"];
      if (rawList is List) {
        sourceKnowledgeList = rawList.whereType<TaskMissionEntityMissionKnowledgeItem>().toList();
      }
    }
    _loadContentDetailList();
  }

  @override
  Future<void> onReturnPageRefresh(String? key) async{
    selectedKeyMap.clear();
    scrollController.jumpTo(0);
    currentAnchorType.value = '';
    await _loadContentDetailList();
  }

  Future<void> _loadContentDetailList() async {
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseContentDetailList)) {
      return;
    }
    final useCurrentCourseSource = contentSource == "current_course_unit";
    if (sourceKnowledgeList.isEmpty && !useCurrentCourseSource) {
      loadStatus.value = 1;
      return;
    }
    loadStatus.value = -1;
    try {
      ToastUtils.showLoading();
      final detailList = useCurrentCourseSource
          ? await _loadCurrentCourseDetailList()
          : await MissionRequest.getMissionContentDetailList(
              sourceKnowledgeList,
              style: _configController.currentStyleForRequest,
              mediaMode: _configController.currentMediaMode,
            );
      if (detailList.isEmpty) {
        loadStatus.value = 1;
        return;
      }
      if (useCurrentCourseSource) {
        sourceKnowledgeList = detailList.map(_buildSourceKnowledgeFromDetail).toList();
      }

      final sourceMap = <String, TaskMissionEntityMissionKnowledgeItem>{};
      for (final item in sourceKnowledgeList) {
        sourceMap[item.uniqueKey] = item;
      }

      final mergedList = <MissionContentSelectItemModel>[];
      for (final detail in detailList) {
        final key = _buildContentKey(
          contentId: detail.contentId,
          semanticId: detail.semanticId,
          contentType: detail.contentType,
        );
        final source = sourceMap[key] ?? _buildSourceKnowledgeFromDetail(detail);
        mergedList.add(MissionContentSelectItemModel(source: source, detail: detail));
      }

      contentItems.assignAll(mergedList);
      selectedKeyMap.clear();
      selectedKeyMap.addAll({
        for (final item in mergedList) item.key: true,
      });
      _updateVisibleItems();
      loadStatus.value = mergedList.isEmpty ? 1 : 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncCurrentAnchorTypeByScroll();
      });
    } finally {
      ToastUtils.hideLoading();
    }
  }

  List<MissionContentSelectItemModel> itemsForType(String contentType) {
    if (contentType == ElementsCardType.word.value) return visibleWordItems;
    if (contentType == ElementsCardType.phrase.value) return visiblePhraseItems;
    if (contentType == ElementsCardType.sentence.value) return visibleSentenceItems;
    return const <MissionContentSelectItemModel>[];
  }

  bool hasItemsForType(String contentType) {
    return itemsForType(contentType).isNotEmpty;
  }

  int selectedCountForType(String contentType) {
    return itemsForType(contentType).where((item) => selectedKeyMap[item.key] == true).length;
  }

  int totalCountForType(String contentType) {
    return itemsForType(contentType).length;
  }

  int get visibleSelectedCount {
    return visibleWordItems.where((item) => selectedKeyMap[item.key] == true).length +
        visiblePhraseItems.where((item) => selectedKeyMap[item.key] == true).length +
        visibleSentenceItems.where((item) => selectedKeyMap[item.key] == true).length;
  }

  bool isSelected(MissionContentSelectItemModel item) => selectedKeyMap[item.key] == true;

  void updateFilter(MissionContentSelectFilter filter) {
    selectedFilter.value = filter;
    _updateVisibleItems();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncCurrentAnchorTypeByScroll();
    });
  }

  void toggleSelect(MissionContentSelectItemModel item) {
    if (isSelected(item)) {
      selectedKeyMap.remove(item.key);
      return;
    }
    selectedKeyMap[item.key] = true;
  }

  bool isSectionAllSelected(String contentType) {
    final items = itemsForType(contentType);
    if (items.isEmpty) return false;
    return items.every((item) => selectedKeyMap[item.key] == true);
  }

  void toggleSectionSelect(String contentType) {
    final items = itemsForType(contentType);
    if (items.isEmpty) return;
    final isAllSelected = items.every((item) => selectedKeyMap[item.key] == true);
    if (isAllSelected) {
      for (final item in items) {
        selectedKeyMap.remove(item.key);
      }
      return;
    }
    for (final item in items) {
      if (selectedKeyMap[item.key] != true) {
        selectedKeyMap[item.key] = true;
      }
    }
  }

  String sectionActionLabel(String contentType) {
    return isSectionAllSelected(contentType) ? "取消全选" : "全选";
  }

  String typeCountLabel(String contentType) {
    final type = ElementsCardType.fromRawValue(contentType);
    return "${type.name} ${selectedCountForType(contentType)} / ${totalCountForType(contentType)}";
  }

  String typeSummaryLabel(String contentType) {
    final type = ElementsCardType.fromRawValue(contentType);
    return "${type.name} ${selectedCountForType(contentType)}";
  }

  Future<void> scrollToType(String contentType) async {
    currentAnchorType.value = contentType;
    final key = sectionKeys[contentType];
    final context = key?.currentContext;
    if (context == null) return;
    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: 0.0,
    );
  }

  void _syncCurrentAnchorTypeByScroll() {
    final sectionTypes = sectionTypeOrder.where((type) => sectionKeys[type]?.currentContext != null).toList();
    if (sectionTypes.isEmpty) {
      currentAnchorType.value = '';
      return;
    }

    const anchorTop = 110.0;
    String nextType = sectionTypes.first;
    var hasSectionAboveAnchor = false;
    for (final type in sectionTypes) {
      final context = sectionKeys[type]?.currentContext;
      if (context == null) continue;
      final renderBox = context.findRenderObject();
      if (renderBox is! RenderBox) continue;
      final dy = renderBox.localToGlobal(Offset.zero).dy;
      if (dy <= anchorTop) {
        nextType = type;
        hasSectionAboveAnchor = true;
        continue;
      }
      if (!hasSectionAboveAnchor) {
        nextType = type;
      }
      break;
    }
    if (currentAnchorType.value != nextType) {
      currentAnchorType.value = nextType;
    }
  }

  Future<void> onTapStartPreview() async {
    final selectedItems = contentItems.where((item) => selectedKeyMap[item.key] == true).toList();
    if (selectedItems.isEmpty) {
      ToastUtils.showToast(text: "请先选择内容");
      return;
    }
    if (startAction == MissionContentSelectAction.flashNotes) {
      await TagRoutes.toNamed(
        Routes.OFFICIAL_COURSE_DETAILS_FLASH_NOTES,
        arguments: {
          "unitName": missionSubtitle.isEmpty ? breadcrumbTitle : missionSubtitle,
          "knowledgeList": selectedItems.map((item) => item.previewKnowledge).toList(),
          "enableLearnUpload": true,
          "learnUploadType": learnUploadType,
        },
      );
      return;
    }
    if (startAction == MissionContentSelectAction.dictation) {
      await TagRoutes.toNamed(
        Routes.OFFICIAL_COURSE_DETAILS_DICTATION,
        arguments: {
          "unitName": missionSubtitle.isEmpty ? breadcrumbTitle : missionSubtitle,
          "knowledgeList": selectedItems.map((item) => item.previewKnowledge).toList(),
          "enableLearnUpload": true,
          "learnUploadType": learnUploadType,
        },
      );
      return;
    }
    if (startAction == MissionContentSelectAction.speakingSoundBlock ||
        startAction == MissionContentSelectAction.speakingPronunciation) {
      await _startSpeakingPractice(selectedItems);
      return;
    }
    await TagRoutes.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS_PREVIEW,
      arguments: {
        "moduleName": missionTitle.isEmpty ? "内容预习" : missionTitle,
        "unitName": missionSubtitle.isEmpty ? breadcrumbTitle : missionSubtitle,
        "knowledgeList": selectedItems.map((item) => item.previewKnowledge).toList(),
        "enableLearnUpload": true,
        "learnUploadType": learnUploadType,
      },
    );
  }

  Future<void> _startSpeakingPractice(List<MissionContentSelectItemModel> selectedItems) async {
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseTodayContentSpeakingExerciseSoundBlockList)){
      ToastUtils.showToast(text: "无权限");
      return;
    }
    try {
      ToastUtils.showLoading();
      final selectedKnowledgeList = selectedItems.map((item) => item.source).toList();
      SpeakingQuizPayloadEntity? speakingPayload;
      if (startAction == MissionContentSelectAction.speakingSoundBlock) {
        speakingPayload = await MissionRequest.getSpeakingSoundBlockQuizByKnowledgeList(
          selectedKnowledgeList,
          style: _configController.currentStyleForRequest,
          mediaMode: _configController.currentMediaMode,
        );
      } else {
        speakingPayload = await MissionRequest.getSpeakingPronunciationQuizByKnowledgeList(
          selectedKnowledgeList,
          style: _configController.currentStyleForRequest,
          mediaMode: _configController.currentMediaMode,
        );
      }
      if (speakingPayload == null || speakingPayload.quizList.isEmpty) {
        ToastUtils.showToast(text: "暂无题目");
        return;
      }
      final quizList = speakingPayload.quizList;
      if (quizList.isEmpty) {
        ToastUtils.showToast(text: "暂无题目");
        return;
      }
      
      await TagRoutes.toNamed(
        Routes.PRACTICE_QUESTIONS,
        arguments: {
          "quizDatas": quizList,
          "questionIsReport": true,
          "isCollectCard": true,
          "isShowPercentageProgress": true,
        },
      );
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<List<UnitKnowledgePointsEntityKnowledgeList>> _loadCurrentCourseDetailList() async {
    if (courseId == null || moduleId == null || unitId == null) {
      return <UnitKnowledgePointsEntityKnowledgeList>[];
    }
    final entity = await OfficialCourseDetailsRequest.getUnitTarget(
      courseId!,
      moduleId!,
      unitId!,
      styleCode: _configController.currentStyleForRequest,
      mediaMode: _configController.currentMediaMode,
    );
    if (entity == null) return <UnitKnowledgePointsEntityKnowledgeList>[];
    final detailList = entity.knowledgeList?.whereType<UnitKnowledgePointsEntityKnowledgeList>().toList() ?? [];
    final visibleList = detailList.where((item) => item.isWord || item.isPhrase || item.isSentence).toList();
    if (startAction == MissionContentSelectAction.speakingSoundBlock ||
        startAction == MissionContentSelectAction.speakingPronunciation) {
      return visibleList.where((item) => item.isWord).toList();
    }
    return visibleList;
  }

  TaskMissionEntityMissionKnowledgeItem _buildSourceKnowledgeFromDetail(
    UnitKnowledgePointsEntityKnowledgeList detail,
  ) {
    return TaskMissionEntityMissionKnowledgeItem(
      isNew: false,
      contentType: detail.contentType,
      contentId: detail.contentId,
      semanticId: detail.semanticId,
    );
  }

  String _buildContentKey({
    required int? contentId,
    required int? semanticId,
    required String? contentType,
  }) {
    return "${contentId ?? 0}_${semanticId ?? 0}_${contentType ?? ""}";
  }

  void _updateVisibleItems() {
    final wordItems = <MissionContentSelectItemModel>[];
    final phraseItems = <MissionContentSelectItemModel>[];
    final sentenceItems = <MissionContentSelectItemModel>[];
    for (final item in contentItems) {
      if (!_matchesSelectedFilter(item)) continue;
      if (item.contentType == ElementsCardType.word.value) {
        wordItems.add(item);
        continue;
      }
      if (item.contentType == ElementsCardType.phrase.value) {
        phraseItems.add(item);
        continue;
      }
      if (item.contentType == ElementsCardType.sentence.value) {
        sentenceItems.add(item);
      }
    }
    visibleWordItems.assignAll(wordItems);
    visiblePhraseItems.assignAll(phraseItems);
    visibleSentenceItems.assignAll(sentenceItems);
    visibleItemCount.value = wordItems.length + phraseItems.length + sentenceItems.length;
  }

  bool _matchesSelectedFilter(MissionContentSelectItemModel item) {
    switch (selectedFilter.value) {
      case MissionContentSelectFilter.oldKnowledge:
        return item.isOld;
      case MissionContentSelectFilter.newKnowledge:
        return item.isNew;
      case MissionContentSelectFilter.all:
        return true;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
