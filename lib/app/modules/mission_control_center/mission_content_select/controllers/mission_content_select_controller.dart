import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../utils/utils.dart';
import '../models/mission_content_select_model.dart';

class MissionContentSelectController extends GetxController with RoutesBreadcrumbMixin {
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
  final RxList<String> selectedKeys = <String>[].obs;
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

  bool get isCurrentCourseSource => contentSource == "current_course_unit";

  @override
  void onInit() {
    super.onInit();
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
          : await MissionRequest.getMissionContentDetailList(sourceKnowledgeList);
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
      selectedKeys.assignAll(mergedList.map((item) => item.key));
      loadStatus.value = mergedList.isEmpty ? 1 : 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncCurrentAnchorTypeByScroll();
      });
    } finally {
      ToastUtils.hideLoading();
    }
  }

  List<MissionContentSelectItemModel> get visibleItems {
    return contentItems.where((item) {
      switch (selectedFilter.value) {
        case MissionContentSelectFilter.oldKnowledge:
          return item.isOld;
        case MissionContentSelectFilter.newKnowledge:
          return item.isNew;
        case MissionContentSelectFilter.all:
          return true;
      }
    }).toList();
  }

  List<MissionContentSelectItemModel> itemsForType(String contentType) {
    return visibleItems.where((item) => item.contentType == contentType).toList();
  }

  bool hasItemsForType(String contentType) {
    return itemsForType(contentType).isNotEmpty;
  }

  int selectedCountForType(String contentType) {
    return itemsForType(contentType).where((item) => selectedKeys.contains(item.key)).length;
  }

  int totalCountForType(String contentType) {
    return itemsForType(contentType).length;
  }

  int get visibleSelectedCount {
    return visibleItems.where((item) => selectedKeys.contains(item.key)).length;
  }

  bool isSelected(MissionContentSelectItemModel item) => selectedKeys.contains(item.key);

  void updateFilter(MissionContentSelectFilter filter) {
    selectedFilter.value = filter;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncCurrentAnchorTypeByScroll();
    });
  }

  void toggleSelect(MissionContentSelectItemModel item) {
    if (isSelected(item)) {
      selectedKeys.remove(item.key);
    } else {
      selectedKeys.add(item.key);
    }
  }

  bool isSectionAllSelected(String contentType) {
    final items = itemsForType(contentType);
    if (items.isEmpty) return false;
    return items.every((item) => selectedKeys.contains(item.key));
  }

  void toggleSectionSelect(String contentType) {
    final items = itemsForType(contentType);
    if (items.isEmpty) return;
    final isAllSelected = items.every((item) => selectedKeys.contains(item.key));
    if (isAllSelected) {
      selectedKeys.removeWhere((key) => items.any((item) => item.key == key));
      return;
    }
    for (final item in items) {
      if (!selectedKeys.contains(item.key)) {
        selectedKeys.add(item.key);
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
    final selectedItems = contentItems.where((item) => selectedKeys.contains(item.key)).toList();
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
        speakingPayload = await MissionRequest.getSpeakingSoundBlockQuizByKnowledgeList(selectedKnowledgeList);
      } else {
        speakingPayload = await MissionRequest.getSpeakingPronunciationQuizByKnowledgeList(selectedKnowledgeList);
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
          "reportContextList": speakingPayload.contextByExerciseId.entries
              .map((entry) => {
                    "exerciseId": entry.key,
                    "context": entry.value,
                  })
              .toList(),
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
    final entity = await OfficialCourseDetailsRequest.getUnitTarget(courseId!, moduleId!, unitId!);
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

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
