import 'package:get/get.dart';
import 'package:langwise/app/modules/mission_control_center/controllers/mission_control_center_controller.dart';
import 'package:langwise/app/routes/tag_routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';
import '../../mission_content_select/models/mission_content_select_model.dart';

class MissionSpecialController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  MissionSpecialController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.MISSION_SPECIAL;

  @override
  String get breadcrumbTitle => "专项训练";

  String? taskType;

  final Rx<MissionSpecialV3Entity> taskSpecial = MissionSpecialV3Entity().obs;

  final RxList<KnowledgeCommonEntityList> taskSpecialList = <KnowledgeCommonEntityList>[].obs;

  List<TaskMissionEntityMissionKnowledgeItem> get specialKnowledgeList =>
      taskSpecial.value.knowledgeList?.whereType<TaskMissionEntityMissionKnowledgeItem>().toList() ?? [];

  /// 数据拉取状态 -1=还未请求 0=有数据 1=无数据
  final RxInt dataStatus = 0.obs;

  int get totalTaskCount => taskSpecial.value.allCount ?? taskSpecialList.length;

  int get unlockTaskCount => taskSpecial.value.unlockCount ?? 0;

  int get specialDiamondCount => taskSpecial.value.diamondCount ?? 0;

  int get specialDiamondMax => taskSpecial.value.diamondMax ?? 0;

  int get nextDiamondNeedSec => taskSpecial.value.nextDiamondNeedSec ?? 0;

  bool get isSpeakingTask => taskType == LSRWEnum.speaking;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if(Get.arguments != null){
      taskType = Get.arguments['taskType'];
      getTaskSpecialList();
    }
  }

  bool get _hasDisplayContent {
    final hasKnowledge = specialKnowledgeList.isNotEmpty;
    final hasExpansion = taskSpecialList.isNotEmpty;
    return hasKnowledge || hasExpansion;
  }

  Future<void> getTaskSpecialList({
    bool showLoading = true,
    bool preserveVisibleContent = false,
  }) async {
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.studyTaskMissionListV3)) return;

    final shouldPreserveVisibleContent =
        preserveVisibleContent && !showLoading && _hasDisplayContent;
    if (!shouldPreserveVisibleContent) {
      dataStatus.value = -1;
    }
    if (taskType == null) {
      dataStatus.value = 1;
      return;
    }
    try {
      if (showLoading) ToastUtils.showLoading();
      final res = await MissionRequest.getTaskMissionGroup(taskType!);
      if (res == null) {
        if (!shouldPreserveVisibleContent) {
          dataStatus.value = 1;
        }
        return;
      }
      taskSpecial.value = res;
      updateBreadcrumbTitle(taskSpecial.value.title ?? breadcrumbTitle);
      taskSpecialList.assignAll(
        (res.list ?? const <KnowledgeCommonEntityList?>[]).whereType<KnowledgeCommonEntityList>(),
      );
      final hasKnowledge = specialKnowledgeList.isNotEmpty;
      final hasExpansion = taskSpecialList.isNotEmpty;
      dataStatus.value = (!hasKnowledge && !hasExpansion) ? 1 : 0;
      updateBreadcrumbTitle(taskSpecial.value.title ?? breadcrumbTitle);
    } finally {
      if (showLoading) ToastUtils.hideLoading();
    }
  }

  Future<void> onTapSelectContent() async {
    await _toContentSelectPage(_resolveStartActionByTaskType());
  }

  Future<void> onTapSelectSpeakingSoundBlock() async {
    await _toContentSelectPage(MissionContentSelectAction.speakingSoundBlock);
  }

  Future<void> onTapSelectSpeakingPronunciation() async {
    await _toContentSelectPage(MissionContentSelectAction.speakingPronunciation);
  }

  Future<void> refreshPageData({bool showLoading = false, bool syncDailyTask = false}) async {
    await getTaskSpecialList(
      showLoading: showLoading,
      preserveVisibleContent: true,
    );
    if (syncDailyTask) {
      await _refreshDailyTaskPage();
    }
  }

  Future<void> _toContentSelectPage(String startAction) async {
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseContentDetailList)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }

    final knowledgeList = _buildContentSelectKnowledgeList(startAction);
    if (knowledgeList.isEmpty) {
      ToastUtils.showToast(text: "暂无内容");
      return;
    }
    await TagRoutes.toNamed(
      Routes.MISSION_CONTENT_SELECT,
      arguments: {
        "missionTitle": (taskSpecial.value.title?.isNotEmpty ?? false) ? taskSpecial.value.title : "今日知识概览",
        "missionSubtitle": "专项训练",
        "knowledgeList": knowledgeList,
        "startAction": startAction,
        "learnUploadType": _resolveLearnUploadType(),
      },
    );
    await refreshPageData(syncDailyTask: true);
  }

  Future<void> _refreshDailyTaskPage() async {
    final missionController =
        TagRoutes.findLast<MissionControlCenterController>(Routes.MISSION_CONTROL_CENTER);
    if (missionController == null) return;
    await missionController.getTaskMission(showLoading: false, scrollToCurrent: false);
  }

  List<TaskMissionEntityMissionKnowledgeItem> _buildContentSelectKnowledgeList(String startAction) {
    if (startAction == MissionContentSelectAction.speakingSoundBlock) {
      return specialKnowledgeList.where((item) => item.isWord).toList();
    }
    return specialKnowledgeList;
  }

  String _resolveStartActionByTaskType() {
    switch (taskType) {
      case LSRWEnum.reading:
        return MissionContentSelectAction.flashNotes;
      case LSRWEnum.writing:
        return MissionContentSelectAction.dictation;
      case LSRWEnum.listening:
      case LSRWEnum.overall:
      default:
        return MissionContentSelectAction.preview;
    }
  }

  String? _resolveLearnUploadType() {
    switch (taskType) {
      case LSRWEnum.listening:
        return LSRWEnum.listening;
      case LSRWEnum.reading:
        return LSRWEnum.reading;
      case LSRWEnum.writing:
        return LSRWEnum.writing;
      default:
        return null;
    }
  }
}
