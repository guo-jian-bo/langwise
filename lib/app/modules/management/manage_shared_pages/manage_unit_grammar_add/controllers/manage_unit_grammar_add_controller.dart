import 'dart:async';
import 'package:get/get.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../routes/routes.dart';
import '../../../utils/manage_breadcrumb_utils.dart';

class ManageUnitGrammarAddController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageUnitGrammarAddController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_UNIT_GRAMMAR_ADD;

  @override
  String get breadcrumbTitle => "添加语法";

  /// 当前单元 id，所有请求都基于它发起。
  int? unitId;

  /// 页面标题里展示的单元名。
  String unitName = "";

  /// 左侧句子材料。
  final RxList<CourseUnitTargetSentenceGrammarSentenceEntity> sentenceList = <CourseUnitTargetSentenceGrammarSentenceEntity>[].obs;

  /// 左侧可选句组材料。
  final RxList<CourseUnitTargetSentenceGrammarGroupEntity> groupList = <CourseUnitTargetSentenceGrammarGroupEntity>[].obs;

  /// 默认全选句子，因此这里直接存当前勾选的句 KP uid。
  final RxList<int> selectedKnowledgeUids = <int>[].obs;

  /// 当前勾选的句组 uid。
  final RxList<int> selectedSetUids = <int>[].obs;

  /// recall 返回的资产列表。
  final RxList<CourseUnitTargetAddGrammarRecallAssetEntity> recalledAssets = <CourseUnitTargetAddGrammarRecallAssetEntity>[].obs;

  /// recall 返回的展开 sentenceIds。
  final RxList<int> recalledSentenceIds = <int>[].obs;

  /// 当前勾选的资产 key，格式为 `kind::nid`。
  final RxList<String> checkedAssetKeys = <String>[].obs;

  /// 当前页是否还在首包加载中。
  final RxBool isLoading = true.obs;

  /// recall 请求进行中。
  final RxBool isRecalling = false.obs;

  /// append + 轮询进行中。
  final RxBool isAppending = false.obs;

  /// 面板内展示的错误文案。
  final RxString errorText = "".obs;

  /// append 启动后的任务信息。
  final Rx<CourseUnitTargetAddGrammarTaskStartEntity?> taskStart = Rx<CourseUnitTargetAddGrammarTaskStartEntity?>(null);

  /// append 成功后的过渡提示。
  final RxString doneText = "".obs;

  /// recall 时的材料指纹，材料改了就需要重新召回。
  final RxString recalledFingerprint = "".obs;

  bool _disposed = false;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    final Map args = Get.arguments is Map ? Get.arguments as Map : const {};
    unitId = args["unitId"] is int ? args["unitId"] : int.tryParse(args["unitId"]?.toString() ?? "");
    if (unitId == null || unitId! <= 0) {
      isLoading.value = false;
      errorText.value = "单元信息缺失";
      return;
    }
    loadPage();
  }

  @override
  void onClose() {
    _disposed = true;
    super.onClose();
  }

  /// 首次进入页面时读取句法主包，左侧句子默认全选。
  Future<void> loadPage() async {
    if (unitId == null) {
      isLoading.value = false;
      errorText.value = "单元信息缺失";
      return;
    }
    try {
      ToastUtils.showLoading();
      final CourseUnitTargetSentenceGrammarEntity? entity = await CourseConsoleRequest.getCourseUnitTargetGrammarAddPage(
        unitId: unitId!,
      );
      final List<CourseUnitTargetSentenceGrammarSentenceEntity> sentenceRespList = [];
      final List<CourseUnitTargetSentenceGrammarGroupEntity> groupRespList = [];
      for (final item in entity?.sentence ?? <CourseUnitTargetSentenceGrammarSentenceEntity?>[]) {
        if (item == null) continue;
        sentenceRespList.add(item);
      }
      for (final item in entity?.groups ?? <CourseUnitTargetSentenceGrammarGroupEntity?>[]) {
        if (item == null) continue;
        if (item.uid == null || item.uid! <= 0) continue;
        groupRespList.add(item);
      }
      sentenceList.assignAll(sentenceRespList);
      groupList.assignAll(groupRespList);
      selectedKnowledgeUids.assignAll(_buildAllSentenceKnowledgeUids());
    } finally {
      ToastUtils.hideLoading();
      isLoading.value = false;
    }
  }

  List<int> _buildAllSentenceKnowledgeUids() {
    final List<int> uids = [];
    for (final item in sentenceList) {
      final int? unitKnowledgeId = item.unitKnowledgeId;
      if (unitKnowledgeId == null || unitKnowledgeId <= 0) continue;
      uids.add(unitKnowledgeId);
    }
    return uids;
  }

  List<int> buildSelectedKnowledgeUids() {
    return List<int>.from(selectedKnowledgeUids);
  }

  List<int> buildSelectedSetUids() {
    return List<int>.from(selectedSetUids);
  }

  List<CourseUnitTargetAddGrammarRecallAssetEntity> buildCheckedAppendAssets() {
    final List<CourseUnitTargetAddGrammarRecallAssetEntity> assets = [];
    for (final item in recalledAssets) {
      final String? kind = item.kind;
      final String? nid = item.nid;
      if (kind == null || nid == null) continue;
      if (!checkedAssetKeys.contains(buildAssetKey(kind, nid))) continue;
      if (item.alreadyPresent == true) continue;
      assets.add(item);
    }
    return assets;
  }

  List<Map<String, String>> buildAppendAssetRefs() {
    final List<Map<String, String>> refs = [];
    for (final item in buildCheckedAppendAssets()) {
      final String? kind = item.kind;
      final String? nid = item.nid;
      if (kind == null || nid == null) continue;
      refs.add({
        "kind": kind,
        "nid": nid,
      });
    }
    return refs;
  }

  Map<String, List<CourseUnitTargetAddGrammarRecallAssetEntity>> buildRecallAssetGroupMap() {
    final Map<String, List<CourseUnitTargetAddGrammarRecallAssetEntity>> groupMap = {};
    for (final item in recalledAssets) {
      final String kind = item.kind ?? "";
      groupMap.putIfAbsent(kind, () => <CourseUnitTargetAddGrammarRecallAssetEntity>[]).add(item);
    }
    return groupMap;
  }

  bool hasRecallResult() {
    return recalledFingerprint.value.isNotEmpty;
  }

  bool hasRecallStale() {
    if (!hasRecallResult()) return false;
    return recalledFingerprint.value != buildMaterialsFingerprint();
  }

  bool canRunAppend() {
    if (isAppending.value || isRecalling.value) return false;
    if (!hasRecallResult() || hasRecallStale()) return false;
    return buildCheckedAppendAssets().isNotEmpty;
  }

  String buildMaterialsFingerprint() {
    final List<int> knowledgeUids = buildSelectedKnowledgeUids()..sort();
    final List<int> setUids = buildSelectedSetUids()..sort();
    return "${knowledgeUids.join(',')}|${setUids.join(',')}";
  }

  String buildAssetKey(String kind, String nid) {
    return "$kind::$nid";
  }

  bool isAssetChecked(String kind, String nid) {
    return checkedAssetKeys.contains(buildAssetKey(kind, nid));
  }

  void toggleSentence(int uid) {
    if (selectedKnowledgeUids.contains(uid)) {
      selectedKnowledgeUids.remove(uid);
    } else {
      selectedKnowledgeUids.add(uid);
    }
    _clearTransientMessages();
  }

  void toggleGroup(int uid) {
    if (selectedSetUids.contains(uid)) {
      selectedSetUids.remove(uid);
    } else {
      selectedSetUids.add(uid);
    }
    _clearTransientMessages();
  }

  void toggleAsset(String kind, String nid, {required bool alreadyPresent}) {
    if (alreadyPresent) return;
    final String key = buildAssetKey(kind, nid);
    if (checkedAssetKeys.contains(key)) {
      checkedAssetKeys.remove(key);
    } else {
      checkedAssetKeys.add(key);
    }
  }

  void selectAllRecallAssets() {
    checkedAssetKeys.assignAll(_buildSelectableAssetKeys(recalledAssets));
  }

  void clearAllRecallAssets() {
    checkedAssetKeys.clear();
  }

  void selectAllSentences() {
    selectedKnowledgeUids.assignAll(_buildAllSentenceKnowledgeUids());
    _clearTransientMessages();
  }

  void clearMaterials() {
    selectedKnowledgeUids.clear();
    selectedSetUids.clear();
    _clearTransientMessages();
  }

  void _clearTransientMessages() {
    errorText.value = "";
    doneText.value = "";
  }

  String buildSentenceLineText(CourseUnitTargetSentenceGrammarSentenceEntity item) {
    final List<String> lines = [];
    final int? unitKnowledgeId = item.unitKnowledgeId;
    if (unitKnowledgeId != null && unitKnowledgeId > 0) {
      lines.add("KP $unitKnowledgeId");
    }
    final int? contentId = item.contentId;
    if (contentId != null && contentId > 0) {
      lines.add("句 $contentId");
    }
    if ((item.patternNid ?? "").isNotEmpty) {
      lines.add(item.patternNid!);
    } else {
      lines.add("无 patternNid");
    }
    return lines.join(" · ");
  }

  String buildGroupTitle(CourseUnitTargetSentenceGrammarGroupEntity item) {
    for (final text in item.name ?? <LanguageText?>[]) {
      if (text?.lang == "zh" && (text?.text ?? "").isNotEmpty) {
        return text!.text!;
      }
    }
    for (final text in item.name ?? <LanguageText?>[]) {
      if ((text?.text ?? "").isNotEmpty) return text!.text!;
    }
    return item.assetNid ?? item.nid ?? "未命名句组";
  }

  String? buildGroupAssetType(CourseUnitTargetSentenceGrammarGroupEntity item) {
    if ((item.assetType ?? "").isNotEmpty) return item.assetType;
    final ZhenxieEnSentenceType? typeEnum = item.typeEnum;
    if (typeEnum == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN) {
      return "pattern";
    }
    if(typeEnum == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID){
      return "pyramid";
    }
    if (typeEnum == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR) {
      return "pair";
    }
    if (typeEnum == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR_FORK) {
      return "pair_fork";
    }
    if (typeEnum == ZhenxieEnSentenceType.EN_SENTENCE_PARADIGM) {
      return "paradigm";
    }
    if (typeEnum == ZhenxieEnSentenceType.EN_SENTENCE_GRAMMAR_GRID) {
      return "grid";
    }
    return null;
  }

  String? buildGroupAssetNid(CourseUnitTargetSentenceGrammarGroupEntity item) {
    if ((item.assetNid ?? "").isNotEmpty) return item.assetNid;
    if ((item.nid ?? "").isNotEmpty) return item.nid;
    return null;
  }

  int buildGroupMemberCount(CourseUnitTargetSentenceGrammarGroupEntity item) {
    int count = 0;
    for (final member in item.members ?? <CourseUnitTargetSentenceGrammarGroupMemberEntity?>[]) {
      if ((member?.sentenceId ?? 0) > 0) count++;
    }
    return count;
  }

  Future<void> runRecall() async {
    final List<int> knowledgeUids = buildSelectedKnowledgeUids();
    final List<int> setUids = buildSelectedSetUids();
    if (knowledgeUids.isEmpty && setUids.isEmpty) {
      errorText.value = "knowledgeUids 与 setUids 不能都为空";
      return;
    }
    if (unitId == null) {
      errorText.value = "单元信息缺失";
      return;
    }
    isRecalling.value = true;
    errorText.value = "";
    doneText.value = "";
    taskStart.value = null;
    try {
      final CourseUnitTargetAddGrammarRecallEntity? entity = await CourseConsoleRequest.recallCourseUnitTargetGrammarFromMaterials(
        unitId: unitId!,
        knowledgeUids: knowledgeUids,
        setUids: setUids,
      );
      if (entity == null) {
        errorText.value = "召回失败，请稍后重试";
        recalledAssets.clear();
        recalledSentenceIds.clear();
        checkedAssetKeys.clear();
        recalledFingerprint.value = "";
        return;
      }
      final List<CourseUnitTargetAddGrammarRecallAssetEntity> respAssets = [];
      final List<int> respSentenceIds = [];
      for (final item in entity.assets ?? <CourseUnitTargetAddGrammarRecallAssetEntity?>[]) {
        if (item == null) continue;
        respAssets.add(item);
      }
      for (final item in entity.sentenceIds ?? <int?>[]) {
        if (item == null || item <= 0) continue;
        respSentenceIds.add(item);
      }
      recalledAssets.assignAll(respAssets);
      recalledSentenceIds.assignAll(respSentenceIds);
      recalledFingerprint.value = buildMaterialsFingerprint();
      checkedAssetKeys.assignAll(_buildSelectableAssetKeys(respAssets));
    } finally {
      isRecalling.value = false;
    }
  }

  List<String> _buildSelectableAssetKeys(
    List<CourseUnitTargetAddGrammarRecallAssetEntity> assets,
  ) {
    final List<String> keys = [];
    for (final item in assets) {
      if (item.alreadyPresent == true) continue;
      final String? kind = item.kind;
      final String? nid = item.nid;
      if (kind == null || nid == null) continue;
      keys.add(buildAssetKey(kind, nid));
    }
    return keys;
  }

  Future<void> runAppend() async {
    if (!canRunAppend()) return;
    if (unitId == null) {
      errorText.value = "单元信息缺失";
      return;
    }
    isAppending.value = true;
    errorText.value = "";
    doneText.value = "";
    try {
      final CourseUnitTargetAddGrammarTaskStartEntity? started = await CourseConsoleRequest.appendCourseUnitTargetGrammarFromMaterials(
        unitId: unitId!,
        knowledgeUids: buildSelectedKnowledgeUids(),
        setUids: buildSelectedSetUids(),
        assetRefs: buildAppendAssetRefs(),
      );
      taskStart.value = started;
      if (started == null) {
        errorText.value = "追加失败，请稍后重试";
        return;
      }
      final int? taskId = started.taskId;
      if (taskId == null || taskId <= 0) {
        if ((started.status ?? "") == "duplicate") {
          ToastUtils.showManageToast(text: started.message ?? "任务已存在，跳过执行");
          return;
        }
        errorText.value = started.message ?? "未返回 taskId";
        return;
      }
      final bool success = await _pollAppendTask(taskId);
      if (!success || _disposed) return;
      doneText.value = "已追加到本单元，正在返回语法页";
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (_disposed) return;
      Get.back(result: true);
    } finally {
      isAppending.value = false;
    }
  }

  Future<bool> _pollAppendTask(int taskId) async {
    final DateTime startTime = DateTime.now();
    int waitSeconds = 1;
    while (!_disposed) {
      await Future<void>.delayed(Duration(seconds: waitSeconds));
      if (_disposed) return false;
      final CourseUnitTargetAddGrammarTaskStatusEntity? statusEntity = await CourseConsoleRequest.getAlgorithmTaskStatus(taskId: taskId);
      if (statusEntity == null) {
        errorText.value = "任务状态查询失败";
        return false;
      }
      final String status = statusEntity.status ?? "";
      if (status == "finished") {
        return true;
      }
      if (status != "started" && status != "running") {
        errorText.value = statusEntity.errorMessage ?? "追加任务失败";
        return false;
      }
      if (DateTime.now().difference(startTime).inSeconds >= 60) {
        errorText.value = "追加任务超时，请稍后到句法页查看";
        return false;
      }
      waitSeconds = 2;
    }
    return false;
  }

  String buildStepStateLabel(int stepId) {
    if (doneText.value.isNotEmpty || isAppending.value) {
      return stepId == 4 ? "active" : "done";
    }
    if (hasRecallResult() && !hasRecallStale()) {
      if (stepId <= 2) return "done";
      if (stepId == 3) return "active";
      return "idle";
    }
    if (isRecalling.value) {
      if (stepId == 1) return "done";
      if (stepId == 2) return "active";
    }
    if (stepId == 1) return "active";
    return "idle";
  }
}
