import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../utils/utils.dart';
import '../models/mission_content_select_model.dart';

class MissionContentSelectController extends GetxController with RoutesBreadcrumbMixin {
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

  String missionTitle = "";
  String missionSubtitle = "";
  String startAction = MissionContentSelectAction.preview;
  String? learnUploadType;
  List<TaskMissionEntityMissionKnowledgeItem> sourceKnowledgeList = [];

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      missionTitle = (Get.arguments["missionTitle"] ?? "").toString();
      missionSubtitle = (Get.arguments["missionSubtitle"] ?? "").toString();
      startAction = (Get.arguments["startAction"] ?? MissionContentSelectAction.preview).toString();
      learnUploadType = Get.arguments["learnUploadType"]?.toString();
      final rawList = Get.arguments["knowledgeList"];
      if (rawList is List) {
        sourceKnowledgeList = rawList.whereType<TaskMissionEntityMissionKnowledgeItem>().toList();
      }
    }
    _loadContentDetailList();
  }

  Future<void> _loadContentDetailList() async {
    if (sourceKnowledgeList.isEmpty) {
      loadStatus.value = 1;
      return;
    }
    loadStatus.value = -1;
    final detailList = await MissionRequest.getMissionContentDetailList(sourceKnowledgeList);
    if (detailList.isEmpty) {
      loadStatus.value = 1;
      return;
    }

    final detailMap = <String, UnitKnowledgePointsEntityKnowledgeList>{};
    for (final item in detailList) {
      final key = _buildContentKey(
        contentId: item.contentId,
        semanticId: item.semanticId,
        contentType: item.contentType,
      );
      detailMap[key] = item;
    }

    final mergedList = <MissionContentSelectItemModel>[];
    for (final source in sourceKnowledgeList) {
      final detail = detailMap[source.uniqueKey] ?? _buildFallbackDetail(source);
      mergedList.add(MissionContentSelectItemModel(source: source, detail: detail));
    }

    contentItems.assignAll(mergedList);
    loadStatus.value = mergedList.isEmpty ? 1 : 0;
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
    return "${type.name} ${totalCountForType(contentType)}";
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

  UnitKnowledgePointsEntityKnowledgeList _buildFallbackDetail(TaskMissionEntityMissionKnowledgeItem source) {
    return UnitKnowledgePointsEntityKnowledgeList(
      uid: source.contentId,
      contentId: source.contentId,
      semanticId: source.semanticId,
      contentType: source.contentType,
      contentTypeTitle: ElementsCardType.fromRawValue(source.contentType ?? "").name,
      content: "",
      definition: "",
    );
  }

  String _buildContentKey({
    required int? contentId,
    required int? semanticId,
    required String? contentType,
  }) {
    return "${contentId ?? 0}_${semanticId ?? 0}_${contentType ?? ""}";
  }
}
