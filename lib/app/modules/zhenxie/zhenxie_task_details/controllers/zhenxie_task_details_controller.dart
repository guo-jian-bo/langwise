import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../common/widgets/ask_dialog.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/model/writing_board_data.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/model/writing_board_frame_section_type.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/model/writing_board_submit_data.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/utils/writing_board_controller_bundle.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/utils/writing_board_mapper.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/utils/writing_board_runtime_state.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/utils/writing_board_submit_mapper.dart';
import '../../../../../common/widgets/zhenxie_widgets/zhenxie_paragraph_step_details_widget.dart';
import '../../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../../../../../utils/utils.dart';
import '../views/zhenxie_task_view_sample_lock_dialog.dart';

class ZhenxieTaskDetailsController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxieTaskDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_TASK_DETAILS;

  @override
  String get breadcrumbTitle => "任务详情";

  // 传进来的参数
  /// 是否是管理端
  bool isManagement = false;

  /// 任务id
  int? taskUid;

  /// 范文id
  int? compositionUid;

  /// 路由传入的内容来源宏，用于标记这个页面最初是按哪种内容模式进入的。
  WritingBoardContentSourceMacro routeContentSourceMacro = WritingBoardContentSourceMacro.task;

  /// 路由传入的编辑策略宏，用于标记这个页面最初是按哪种编辑模式进入的。
  WritingBoardEditPolicyMacro routeEditPolicyMacro = WritingBoardEditPolicyMacro.stageRule;

  /// tab类型 0=资料 1=蓝图
  final RxInt tabType = 0.obs;

  /// 当前写作板内容来源宏。
  final Rx<WritingBoardContentSourceMacro> contentSourceMacro = WritingBoardContentSourceMacro.task.obs;

  /// 当前写作板编辑策略宏。
  final Rx<WritingBoardEditPolicyMacro> editPolicyMacro = WritingBoardEditPolicyMacro.stageRule.obs;

  /// 段落/文章的步骤
  final RxList<ParagraphRhetoricalEntityList> paragraphRhetoricalList = <ParagraphRhetoricalEntityList>[].obs;

  /// 详情数据
  final Rx<ZhenxieTaskDetailsEntity> detailsData = ZhenxieTaskDetailsEntity().obs;

  /// 知识点列表
  final RxList<ElementsCardEntityDatas> knowledgePointsList = <ElementsCardEntityDatas>[].obs;

  /// 任务详情缓存，只承载任务作答态需要的稳定数据。
  ZhenxieTaskDetailsEntity? _taskDetailsData;

  /// 任务详情对应的知识点缓存。
  List<ElementsCardEntityDatas> _taskKnowledgePointsList = <ElementsCardEntityDatas>[];

  /// 范文详情缓存，只承载范文预览/编辑态需要的稳定数据。
  ZhenxieTaskDetailsEntity? _exemplarDetailsData;

  /// 范文详情对应的知识点缓存。
  List<ElementsCardEntityDatas> _exemplarKnowledgePointsList = <ElementsCardEntityDatas>[];

  /// 写作板统一渲染数据
  final Rxn<WritingBoardData> writingBoardData = Rxn<WritingBoardData>();

  /// 写作板运行时状态
  final Rxn<WritingBoardRuntimeState> writingBoardRuntimeState = Rxn<WritingBoardRuntimeState>();

  /// 写作板页面层提交占位快照
  final Rxn<WritingBoardSubmitData> writingBoardSubmitData = Rxn<WritingBoardSubmitData>();

  /// 写作板草稿态运行时状态
  WritingBoardRuntimeState? _draftWritingBoardRuntimeState;

  /// 范文编辑态运行时状态。
  WritingBoardRuntimeState? _sampleEditWritingBoardRuntimeState;

  /// 任务写作态最近一次已加载或已保存的对比基线，用于退出前判断是否有未保存修改。
  WritingBoardRuntimeState? _taskExitCompareBaselineRuntimeState;

  /// 范文编辑态最近一次已加载或已保存的对比基线，用于退出前判断是否有未保存修改。
  WritingBoardRuntimeState? _sampleEditExitCompareBaselineRuntimeState;

  /// 选择的beatNid
  final RxString selectBeatNid = "".obs;

  /// 当前高亮的首尾结构区域。
  final Rxn<WritingBoardFrameSectionType> highlightedFrameSection = Rxn<WritingBoardFrameSectionType>();

  /// 写作板输入控制器集合
  WritingBoardControllers? writingBoardControllers;

  /// 首尾结构联动高亮的恢复计时器。
  Timer? _frameSectionHighlightTimer;

  /// 页面初始化完成后的学习时长计时器，直到提交成功结束。
  final Stopwatch _studyDurationStopwatch = Stopwatch();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      isManagement = Get.arguments["isManagement"] ?? false;
      taskUid = Get.arguments["taskUid"];
      compositionUid = Get.arguments["compositionUid"];
      routeContentSourceMacro = WritingBoardContentSourceMacro.fromValue(
        Get.arguments["contentSource"]?.toString(),
      );
      routeEditPolicyMacro = WritingBoardEditPolicyMacro.fromValue(
        Get.arguments["editPolicy"]?.toString(),
      );
      // taskUid = 9038;
    }
    _initPageMode();
    initData();

    initBreadcrumb(
      tagText,
      title: contentSourceMacro.value == WritingBoardContentSourceMacro.task ? "任务详情" : "范文详情",
    );
  }

  /// 初始化页面模式，直接根据路由传入的稳定值解析宏对象。
  void _initPageMode() {
    contentSourceMacro.value = routeContentSourceMacro;
    editPolicyMacro.value = routeEditPolicyMacro;
    if (contentSourceMacro.value == WritingBoardContentSourceMacro.exemplar) {
      tabType.value = 1;
    }
  }

  Future<void> initData() async {
    try {
      ToastUtils.showLoading();
      await getParagraphRhetoricalList();
      if (contentSourceMacro.value == WritingBoardContentSourceMacro.task) {
        await getTaskDetailsData();
      } else {
        await getExemplarDetailsData();
      }
    } finally {
      ToastUtils.hideLoading();
      _startStudyDuration();
    }
  }

  /// 页面初始化完成后开始累计学习时长。
  void _startStudyDuration() {
    if (_studyDurationStopwatch.isRunning || _studyDurationStopwatch.elapsedMilliseconds > 0) return;
    _studyDurationStopwatch.start();
  }

  /// 段落/文章的步骤
  Future<void> getParagraphRhetoricalList() async {
    try {
      ParagraphRhetoricalEntity? entity = await LanguageUtil.getParagraphRhetoricalList();
      if (entity == null) return;
      List<ParagraphRhetoricalEntityList?> list = entity.list ?? [];
      paragraphRhetoricalList.clear();
      for (ParagraphRhetoricalEntityList? item in list) {
        if (item == null) continue;
        paragraphRhetoricalList.add(item);
      }
    } catch (_) {}
  }

  /// 获取任务详情
  Future<bool> getTaskDetailsData() async {
    if (taskUid == null) return false;
    try {
      Map<String, dynamic> parameters = {
        "taskId": taskUid,
      };
      ZhenxieTaskDetailsEntity? entity;
      if(isManagement){
        entity = await LanguageConsoleRequest.getZhenxieTaskDetails(parameters: parameters);
      }else{
        entity = await LanguageUtil.getZhenxieTaskDetails(parameters: parameters);
      }
      if (entity == null) return false;
      final knowledgePoints = await _getKnowledgePointsList(details: entity);
      _taskDetailsData = entity;
      _taskKnowledgePointsList = knowledgePoints;
      _syncTaskExitCompareBaseline();
      if (!isExemplarContentMode()) {
        _syncDisplayDataByMode();
      }

      _initSelectedBeatNid();
      _rebuildWritingBoardState();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 查询范文详情
  Future<bool> getExemplarDetailsData({
    /// 可选的目标范文 id，任务页内点击“查看范文”时优先使用这个值。
    int? targetCompositionUid,

    /// 是否在查询成功后立即同步当前页面展示态。
    /// 任务页里预加载范文时会传 `false`，避免还没切模式就覆盖当前写作态 UI。
    bool syncCurrentView = true,
  }) async {
    /// 范文详情 id 的解析优先级：
    /// 1. 显式传入的目标范文 id
    /// 2. 路由直接携带的 compositionUid
    /// 3. 任务详情里返回的 exemplarCompositionId
    int? exemplarCompositionId;
    if (targetCompositionUid != null) {
      exemplarCompositionId = targetCompositionUid;
    } else if (compositionUid != null) {
      exemplarCompositionId = compositionUid;
    } else {
      exemplarCompositionId = _taskDetailsData?.exemplarCompositionId;
    }
    if (exemplarCompositionId == null) return false;
    try {
      Map<String, dynamic> parameters = {
        "compositionId": exemplarCompositionId,
      };
      ZhenxieTaskDetailsEntity? entity;
      if(isManagement){
        entity = await LanguageConsoleRequest.getZhenxieInstanceDetails(parameters: parameters);
      }else{
        entity = await LanguageUtil.getZhenxieInstanceDetails(parameters: parameters);
      }
      if (entity == null) return false;
      final knowledgePoints = await _getKnowledgePointsList(details: entity);
      _exemplarDetailsData = entity;
      _exemplarKnowledgePointsList = knowledgePoints;
      _syncSampleEditExitCompareBaseline();
      // 只有当前页面本来就在范文链路里，或者已经切到范文展示态时，才同步刷新页面。
      // 这样可以避免任务页内预加载范文数据时，误把当前写作态页面直接替换掉。
      if (syncCurrentView && (isExemplarContentMode() || routeContentSourceMacro == WritingBoardContentSourceMacro.exemplar)) {
        _syncDisplayDataByMode();
        _initSelectedBeatNid();
        _rebuildWritingBoardState();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 查询指定详情数据对应的知识点列表。
  Future<List<ElementsCardEntityDatas>> _getKnowledgePointsList({
    required ZhenxieTaskDetailsEntity details,
  }) async {
    List<ZhenxieTaskDetailsEntityKnowledgePoint?> knowledgePoints = details.knowledgePoints ?? [];
    if (knowledgePoints.isEmpty) return <ElementsCardEntityDatas>[];
    List<Map<String, dynamic>> reqData = [];
    for (final item in knowledgePoints) {
      if (item == null) continue;
      reqData.add({
        "type": item.contentType,
        "uid": item.uid,
        "semanticId": item.semanticId,
      });
    }
    final list = await LanguageUtil.getKnowledgeList(data: reqData);
    if (list == null) return <ElementsCardEntityDatas>[];
    return list;
  }

  /// 初始化默认选中的拍位
  void _initSelectedBeatNid() {
    if (selectBeatNid.value.isNotEmpty) return;
    final details = _currentDisplayDetailsData;
    if (details == null) return;
    final slots = details.stage?.slots ?? [];
    // 范文态默认选中第一个可见拍位，便于直接查看首个范文段落。
    if (isExemplarContentMode()) {
      for (final slot in slots) {
        if (slot?.fill == 'hidden' || slot?.beatNid?.isEmpty != false) continue;
        selectBeatNid.value = slot!.beatNid!;
        return;
      }
    }
    // 默认优先命中当前任务里第一个需要填写的拍位。
    for (final slot in slots) {
      if (slot?.fill != 'write' || slot?.beatNid?.isEmpty != false) continue;
      selectBeatNid.value = slot!.beatNid!;
      return;
    }
    // 如果当前没有可写拍位，再退回到第一个可见拍位。
    for (final slot in slots) {
      if (slot?.fill == 'hidden' || slot?.beatNid?.isEmpty != false) continue;
      selectBeatNid.value = slot!.beatNid!;
      return;
    }
  }

  /// 当前是否处于任务作答态。
  bool isTaskDraftMode() {
    return contentSourceMacro.value == WritingBoardContentSourceMacro.task &&
        editPolicyMacro.value == WritingBoardEditPolicyMacro.stageRule;
  }

  /// 当前是否处于范文查看态。
  bool isExemplarReadOnlyMode() {
    return contentSourceMacro.value == WritingBoardContentSourceMacro.exemplar &&
        editPolicyMacro.value == WritingBoardEditPolicyMacro.readOnly;
  }

  /// 当前是否处于范文编辑态。
  bool isExemplarEditMode() {
    return contentSourceMacro.value == WritingBoardContentSourceMacro.exemplar &&
        editPolicyMacro.value == WritingBoardEditPolicyMacro.forceEditable;
  }

  /// 当前是否正在展示范文内容。
  bool isExemplarContentMode() {
    return contentSourceMacro.value == WritingBoardContentSourceMacro.exemplar;
  }

  /// 仅在“初始进入就是范文只读态”且当前仍处于范文只读态时展示知识点下划线。
  bool get _shouldShowKnowledgeAnchors {
    return routeContentSourceMacro == WritingBoardContentSourceMacro.exemplar &&
        routeEditPolicyMacro == WritingBoardEditPolicyMacro.readOnly &&
        contentSourceMacro.value == WritingBoardContentSourceMacro.exemplar &&
        editPolicyMacro.value == WritingBoardEditPolicyMacro.readOnly;
  }

  /// 切换当前写作板页面模式，并同步兼容旧逻辑的范文只读标记。
  void _updateBoardMode({
    required WritingBoardContentSourceMacro contentSource,
    required WritingBoardEditPolicyMacro editPolicy,
  }) {
    contentSourceMacro.value = contentSource;
    editPolicyMacro.value = editPolicy;
    _syncDisplayDataByMode();
  }

  /// 获取当前页面模式下应该展示的详情实体。
  ZhenxieTaskDetailsEntity? get _currentDisplayDetailsData {
    if (isExemplarContentMode()) return _exemplarDetailsData;
    return _taskDetailsData;
  }

  /// 获取当前任务作答态对应的稳定详情实体。
  ZhenxieTaskDetailsEntity? get _taskDraftDetailsData {
    return _taskDetailsData;
  }

  /// 按当前模式同步 View 消费的展示数据和知识点列表。
  void _syncDisplayDataByMode() {
    final details = _currentDisplayDetailsData;
    if (details == null) return;
    detailsData.value = details;
    knowledgePointsList.value = isExemplarContentMode()
        ? List<ElementsCardEntityDatas>.from(_exemplarKnowledgePointsList)
        : List<ElementsCardEntityDatas>.from(_taskKnowledgePointsList);
  }

  /// 以当前任务详情稳定数据重建“退出未保存判断”基线。
  void _syncTaskExitCompareBaseline() {
    _taskExitCompareBaselineRuntimeState = _buildExitCompareBaselineRuntimeState(
      details: _taskDetailsData,
      contentSource: WritingBoardContentSourceMacro.task,
      editPolicy: WritingBoardEditPolicyMacro.stageRule,
    );
  }

  /// 以当前范文详情稳定数据重建“退出未保存判断”基线。
  void _syncSampleEditExitCompareBaseline() {
    _sampleEditExitCompareBaselineRuntimeState = _buildExitCompareBaselineRuntimeState(
      details: _exemplarDetailsData,
      contentSource: WritingBoardContentSourceMacro.exemplar,
      editPolicy: WritingBoardEditPolicyMacro.forceEditable,
    );
  }

  /// 用指定详情和模式构建退出前对比用的运行时基线。
  WritingBoardRuntimeState? _buildExitCompareBaselineRuntimeState({
    required ZhenxieTaskDetailsEntity? details,
    required WritingBoardContentSourceMacro contentSource,
    required WritingBoardEditPolicyMacro editPolicy,
  }) {
    if (details == null) return null;
    final data = mapTaskDetailsToWritingBoardData(
      details: details,
      paragraphRhetoricalList: paragraphRhetoricalList.toList(),
      selectBeatNid: selectBeatNid.value,
      contentSource: contentSource,
      editPolicy: editPolicy,
      showKnowledgeAnchors: false,
      isManagement: isManagement,
    );
    return buildWritingBoardRuntimeState(data: data);
  }

  /// 将当前运行时状态持久化到对应模式的本地快照。
  void _persistCurrentEditableRuntimeState() {
    final runtimeState = writingBoardRuntimeState.value;
    if (runtimeState == null) return;
    final snapshot = runtimeState.copyWith(
      contentSource: contentSourceMacro.value,
      editPolicy: editPolicyMacro.value,
    );
    if (isTaskDraftMode()) {
      _draftWritingBoardRuntimeState = snapshot;
      return;
    }
    if (isExemplarEditMode()) {
      _sampleEditWritingBoardRuntimeState = snapshot;
    }
  }

  /// 重建写作板数据与运行时控制器
  void _rebuildWritingBoardState() {
    final details = _currentDisplayDetailsData;
    if (details == null) return;
    WritingBoardData data = mapTaskDetailsToWritingBoardData(
      details: details,
      paragraphRhetoricalList: paragraphRhetoricalList.toList(),
      selectBeatNid: selectBeatNid.value,
      contentSource: contentSourceMacro.value,
      editPolicy: editPolicyMacro.value,
      showKnowledgeAnchors: _shouldShowKnowledgeAnchors,
      isManagement: isManagement,
    );
    WritingBoardRuntimeState runtimeState;

    if (isTaskDraftMode() && _draftWritingBoardRuntimeState != null) {
      runtimeState = _draftWritingBoardRuntimeState!.copyWith(
        contentSource: contentSourceMacro.value,
        editPolicy: editPolicyMacro.value,
        focusedBeatNid: selectBeatNid.value.isNotEmpty ? selectBeatNid.value : _draftWritingBoardRuntimeState!.focusedBeatNid,
      );
      data = _applyRuntimeStateToWritingBoardData(data: data, runtimeState: runtimeState);
    } else if (isExemplarEditMode() && _sampleEditWritingBoardRuntimeState != null) {
      runtimeState = _sampleEditWritingBoardRuntimeState!.copyWith(
        contentSource: contentSourceMacro.value,
        editPolicy: editPolicyMacro.value,
        focusedBeatNid: selectBeatNid.value.isNotEmpty ? selectBeatNid.value : _sampleEditWritingBoardRuntimeState!.focusedBeatNid,
      );
      data = _applyRuntimeStateToWritingBoardData(data: data, runtimeState: runtimeState);
    } else if (isExemplarReadOnlyMode() && _sampleEditWritingBoardRuntimeState != null) {
      runtimeState = _sampleEditWritingBoardRuntimeState!.copyWith(
        contentSource: contentSourceMacro.value,
        editPolicy: editPolicyMacro.value,
        focusedBeatNid: selectBeatNid.value.isNotEmpty ? selectBeatNid.value : _sampleEditWritingBoardRuntimeState!.focusedBeatNid,
      );
      data = _applyRuntimeStateToWritingBoardData(data: data, runtimeState: runtimeState);
    } else {
      runtimeState = buildWritingBoardRuntimeState(data: data);
      if (isTaskDraftMode()) {
        _draftWritingBoardRuntimeState = runtimeState.copyWith();
      } else if (isExemplarEditMode()) {
        _sampleEditWritingBoardRuntimeState = runtimeState.copyWith();
      }
    }

    writingBoardData.value = data;
    writingBoardRuntimeState.value = runtimeState;
    _syncWritingBoardSubmitData();
    _disposeWritingBoardControllers();
    writingBoardControllers = buildWritingBoardControllers(
      data: data,
      runtimeState: runtimeState,
    );
    _bindWritingBoardFocusNodes();
  }

  /// 更新当前选中的拍位
  void updateSelectedBeatNid(String beatNid) {
    if (beatNid.isEmpty) return;
    selectBeatNid.value = beatNid;
    final runtimeState = writingBoardRuntimeState.value;
    if (runtimeState != null) {
      runtimeState.focusedBeatNid = beatNid;
      writingBoardRuntimeState.value = runtimeState.copyWith();
      _persistCurrentEditableRuntimeState();
    }
    _syncWritingBoardDataFromRuntimeState();
  }

  /// 更新当前拍位正文输入值
  void updateStepText(String beatNid, String text) {
    final runtimeState = writingBoardRuntimeState.value;
    if (runtimeState == null) return;
    runtimeState.stepTextMap[beatNid] = text;
    writingBoardRuntimeState.value = runtimeState.copyWith(
      stepTextMap: Map<String, String>.from(runtimeState.stepTextMap),
    );
    _persistCurrentEditableRuntimeState();
    _syncWritingBoardDataFromRuntimeState();
  }

  /// 更新文首输入值
  void updateHeadText(String text) {
    final runtimeState = writingBoardRuntimeState.value;
    if (runtimeState == null) return;
    runtimeState.headText = text;
    writingBoardRuntimeState.value = runtimeState.copyWith();
    _persistCurrentEditableRuntimeState();
    _syncWritingBoardDataFromRuntimeState();
  }

  /// 更新文尾输入值
  void updateTailText(String text) {
    final runtimeState = writingBoardRuntimeState.value;
    if (runtimeState == null) return;
    runtimeState.tailText = text;
    writingBoardRuntimeState.value = runtimeState.copyWith();
    _persistCurrentEditableRuntimeState();
    _syncWritingBoardDataFromRuntimeState();
  }

  /// 更新图片作答列表
  void updateAnswerImages(List<WritingBoardMediaItemData> items) {
    final runtimeState = writingBoardRuntimeState.value;
    if (runtimeState == null) return;
    runtimeState.answerImages = List<WritingBoardMediaItemData>.from(items);
    writingBoardRuntimeState.value = runtimeState.copyWith(
      answerImages: List<WritingBoardMediaItemData>.from(items),
    );
    _persistCurrentEditableRuntimeState();
    _syncWritingBoardDataFromRuntimeState();
  }

  /// 更新视频作答列表
  void updateAnswerVideos(List<WritingBoardMediaItemData> items) {
    final runtimeState = writingBoardRuntimeState.value;
    if (runtimeState == null) return;
    runtimeState.answerVideos = List<WritingBoardMediaItemData>.from(items);
    writingBoardRuntimeState.value = runtimeState.copyWith(
      answerVideos: List<WritingBoardMediaItemData>.from(items),
    );
    _persistCurrentEditableRuntimeState();
    _syncWritingBoardDataFromRuntimeState();
  }

  /// 更新音频作答列表
  void updateAnswerAudios(List<WritingBoardMediaItemData> items) {
    final runtimeState = writingBoardRuntimeState.value;
    if (runtimeState == null) return;
    runtimeState.answerAudios = List<WritingBoardMediaItemData>.from(items);
    writingBoardRuntimeState.value = runtimeState.copyWith(
      answerAudios: List<WritingBoardMediaItemData>.from(items),
    );
    _persistCurrentEditableRuntimeState();
    _syncWritingBoardDataFromRuntimeState();
  }

  /// 请求聚焦某个拍位输入框
  void requestStepFocus(String beatNid) {
    updateSelectedBeatNid(beatNid);
    writingBoardControllers?.stepFocusNodes[beatNid]?.requestFocus();
  }

  /// 点击某个拍位圆章
  void onTapStepStamp(BuildContext context, String beatNid) {
    updateSelectedBeatNid(beatNid);
    final step = writingBoardData.value?.steps.firstWhereOrNull((item) => item.beatNid == beatNid);
    if (step == null) return;

    final shouldOpenDialog = isExemplarReadOnlyMode() || !step.editable;
    if (!shouldOpenDialog) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      ZhenxieParagraphStepDetailsDialog.show(
        context: context,
        isManagement: isManagement,
        detailsData: detailsData.value,
        paragraphRhetoricalList: paragraphRhetoricalList.toList(),
        initBeatNid: beatNid,
      );
    });
  }

  /// 切换右侧 tab，蓝图锁定时先弹锁弹窗。
  Future<void> updateTabType(BuildContext context, int type) async {
    if (type == tabType.value) return;
    if (type != 1) {
      tabType.value = type;
      return;
    }
    if (isExemplarContentMode() || detailsData.value.stage?.lockBlueprintTab != true) {
      tabType.value = type;
      return;
    }

    bool res = await ZhenxieTaskViewSampleLockDialog.show(
      context: context,
      isManagement: isManagement,
      title: "蓝图先收着",
      content: "这一关要看你自己能不能写出来。写完并提交之后，蓝图才会打开。",
    );
    if (!res) return;
    tabType.value = type;
  }

  /// 触发首尾结构联动高亮，2 秒后自动恢复。
  void highlightFrameSection(WritingBoardFrameSectionType type) {
    if (!isExemplarReadOnlyMode()) return;
    _frameSectionHighlightTimer?.cancel();
    highlightedFrameSection.value = type;
    _frameSectionHighlightTimer = Timer(const Duration(seconds: 2), () {
      highlightedFrameSection.value = null;
    });
  }

  /// 清理当前首尾结构高亮状态。
  void clearFrameSectionHighlight() {
    _frameSectionHighlightTimer?.cancel();
    _frameSectionHighlightTimer = null;
    highlightedFrameSection.value = null;
  }

  /// 释放写作板输入控制器
  void _disposeWritingBoardControllers() {
    writingBoardControllers?.dispose();
    writingBoardControllers = null;
  }

  /// 绑定输入框焦点变化，保证键盘切换时选中态同步。
  void _bindWritingBoardFocusNodes() {
    final stepFocusNodes = writingBoardControllers?.stepFocusNodes ?? {};
    stepFocusNodes.forEach((beatNid, focusNode) {
      focusNode.addListener(() {
        if (!focusNode.hasFocus) return;
        if (selectBeatNid.value == beatNid && writingBoardRuntimeState.value?.focusedBeatNid == beatNid) return;
        selectBeatNid.value = beatNid;
        final runtimeState = writingBoardRuntimeState.value;
        if (runtimeState == null) return;
        runtimeState.focusedBeatNid = beatNid;
        writingBoardRuntimeState.value = runtimeState.copyWith();
        _persistCurrentEditableRuntimeState();
        _syncWritingBoardDataFromRuntimeState();
      });
    });
  }

  /// 用运行时状态覆盖写作板渲染数据。
  WritingBoardData _applyRuntimeStateToWritingBoardData({
    required WritingBoardData data,
    required WritingBoardRuntimeState runtimeState,
  }) {
    final useExemplarContent = data.contentSource == WritingBoardContentSourceMacro.exemplar;
    final mediaItems = data.answerKind == 'image'
        ? runtimeState.answerImages
        : data.answerKind == 'video'
            ? runtimeState.answerVideos
            : data.answerKind == 'audio'
                ? runtimeState.answerAudios
                : const <WritingBoardMediaItemData>[];
    return data.copyWith(
      headText: (data.headEditable || useExemplarContent) ? runtimeState.headText : data.headText,
      tailText: (data.tailEditable || useExemplarContent) ? runtimeState.tailText : data.tailText,
      steps: data.steps.map((step) {
        final stepText = (step.editable || useExemplarContent) ? runtimeState.stepTextMap[step.beatNid] ?? '' : step.text;
        return step.copyWith(
          selected: step.beatNid == selectBeatNid.value,
          focused: runtimeState.focusedBeatNid == step.beatNid,
          text: stepText,
        );
      }).toList(),
      mediaAnswer:
          useExemplarContent ? data.mediaAnswer : data.mediaAnswer?.copyWith(items: List<WritingBoardMediaItemData>.from(mediaItems)),
      exemplarMediaAnswer: useExemplarContent
          ? data.exemplarMediaAnswer?.copyWith(items: List<WritingBoardMediaItemData>.from(mediaItems))
          : data.exemplarMediaAnswer,
    );
  }

  /// 同步当前运行时状态到写作板渲染数据。
  void _syncWritingBoardDataFromRuntimeState() {
    final data = writingBoardData.value;
    final runtimeState = writingBoardRuntimeState.value;
    if (data == null || runtimeState == null) return;
    writingBoardData.value = _applyRuntimeStateToWritingBoardData(
      data: data,
      runtimeState: runtimeState,
    );
    _syncWritingBoardSubmitData();
  }

  /// 同步当前运行时状态到页面层提交占位快照。
  void _syncWritingBoardSubmitData() {
    writingBoardSubmitData.value = _buildWritingBoardSubmitData();
  }

  /// 判断当前退出是否需要提示未保存修改。
  bool hasPendingExitChanges() {
    final data = writingBoardData.value;
    final runtimeState = writingBoardRuntimeState.value;
    if (data == null || runtimeState == null) return false;
    if (!isTaskDraftMode() && !isExemplarEditMode()) return false;

    final baselineRuntimeState = isTaskDraftMode() ? _taskExitCompareBaselineRuntimeState : _sampleEditExitCompareBaselineRuntimeState;
    if (baselineRuntimeState == null) return false;

    final currentPayload = _buildExitComparePayload(
      data: data,
      runtimeState: runtimeState,
    );
    final baselinePayload = _buildExitComparePayload(
      data: data,
      runtimeState: baselineRuntimeState,
    );
    return jsonEncode(currentPayload) != jsonEncode(baselinePayload);
  }

  /// 构建退出前未保存判断所需的稳定对比结构。
  Map<String, dynamic> _buildExitComparePayload({
    required WritingBoardData data,
    required WritingBoardRuntimeState runtimeState,
  }) {
    return {
      'answerKind': data.answerKind,
      'headText': data.showHead ? runtimeState.headText : null,
      'tailText': data.showTail ? runtimeState.tailText : null,
      'steps': data.steps
          .map((item) => {
                'beatNid': item.beatNid,
                'text': runtimeState.stepTextMap[item.beatNid] ?? '',
              })
          .toList(),
      'answerImages': _buildExitCompareMediaPayload(runtimeState.answerImages),
      'answerVideos': _buildExitCompareMediaPayload(runtimeState.answerVideos),
      'answerAudios': _buildExitCompareMediaPayload(runtimeState.answerAudios),
    };
  }

  /// 把媒体结果转成可稳定比较的轻量结构。
  List<Map<String, dynamic>> _buildExitCompareMediaPayload(List<WritingBoardMediaItemData> items) {
    return items
        .map((item) => {
              'key': item.key ?? '',
              'url': item.url ?? '',
              'localPath': item.localPath ?? '',
            })
        .toList();
  }

  /// 处理页面返回：有未保存修改时先弹确认框，否则直接退出。
  Future<bool> handlePageBack(BuildContext context) async {
    final shouldExit = await _confirmExitIfNeeded(context);
    if (!shouldExit) return false;
    Get.back();
    return true;
  }

  /// 退出前判断当前模式是否需要弹出未保存确认框。
  Future<bool> _confirmExitIfNeeded(BuildContext context) async {
    if (!hasPendingExitChanges()) return true;
    final bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: '温馨提示',
      content: '还有未保存的更改，确定要退出吗',
      cancel: '继续退出',
      define: '继续写作',
    );
    if (askRes) return false;
    return true;
  }

  /// 构建当前用于暂存 / 提交的写作板结果。
  WritingBoardSubmitData? _buildWritingBoardSubmitData() {
    final runtimeState = _effectiveDraftRuntimeState;
    final data = _buildDraftWritingBoardData();
    if (runtimeState == null || data == null) return null;
    return buildWritingBoardSubmitData(
      details: _taskDraftDetailsData ?? detailsData.value,
      data: data,
      runtimeState: runtimeState,
      selectBeatNid: selectBeatNid.value,
    );
  }

  /// 获取当前有效的草稿态运行时状态。
  WritingBoardRuntimeState? get _effectiveDraftRuntimeState {
    if (_draftWritingBoardRuntimeState != null) {
      return _draftWritingBoardRuntimeState!.copyWith();
    }
    if (isTaskDraftMode()) {
      return writingBoardRuntimeState.value?.copyWith();
    }
    return null;
  }

  /// 构建当前有效的草稿态写作板数据。
  WritingBoardData? _buildDraftWritingBoardData() {
    final runtimeState = _effectiveDraftRuntimeState;
    final details = _taskDraftDetailsData;
    if (runtimeState == null) return null;
    if (details == null) return null;
    final data = mapTaskDetailsToWritingBoardData(
      details: details,
      paragraphRhetoricalList: paragraphRhetoricalList.toList(),
      selectBeatNid: selectBeatNid.value,
      contentSource: WritingBoardContentSourceMacro.task,
      editPolicy: WritingBoardEditPolicyMacro.stageRule,
      showKnowledgeAnchors: false,
      isManagement: isManagement,
    );
    return _applyRuntimeStateToWritingBoardData(
      data: data,
      runtimeState: runtimeState,
    );
  }

  /// 校验当前提交内容是否满足作答要求。
  String? _validateSubmitContent({
    required WritingBoardData data,
    required WritingBoardSubmitData submitData,
  }) {
    final mediaAnswer = data.mediaAnswer;
    if (mediaAnswer != null) {
      final currentItems = mediaAnswer.kind == 'image'
          ? submitData.answerImages
          : mediaAnswer.kind == 'video'
              ? submitData.answerVideos
              : submitData.answerAudios;
      final minCount = mediaAnswer.minCount;
      if (currentItems.length < minCount) {
        return "请先完成$minCount个${_mediaAnswerKindLabel(mediaAnswer.kind)}作答";
      }
      if (minCount <= 0 && currentItems.isEmpty) {
        return "请先填写作答内容";
      }
      return null;
    }

    if (data.showHead && data.headEditable && (submitData.headText ?? '').isEmpty) {
      return "请先填写文首";
    }
    if (data.showTail && data.tailEditable && (submitData.tailText ?? '').isEmpty) {
      return "请先填写文尾";
    }

    for (final step in data.steps) {
      if (!step.editable || !_isRequiredBeat(step.beatNid)) continue;
      final submitStep = _findSubmitStep(submitData.steps, step.beatNid);
      if ((submitStep?.text ?? '').isEmpty) {
        return "请先完成 ${step.beatLabel} 的内容";
      }
    }

    if ((submitData.headText ?? '').isNotEmpty) return null;
    if ((submitData.tailText ?? '').isNotEmpty) return null;
    if (submitData.steps.any((item) => item.text.isNotEmpty)) return null;
    if (_hasAnyMediaItems(submitData.answerImages)) return null;
    if (_hasAnyMediaItems(submitData.answerVideos)) return null;
    if (_hasAnyMediaItems(submitData.answerAudios)) return null;
    return "请先填写作答内容";
  }

  /// 判断媒体列表里是否已经存在有效结果。
  bool _hasAnyMediaItems(List<WritingBoardSubmitMediaItemData> items) {
    return items.any((item) {
      return item.localPath?.isNotEmpty == true || item.url?.isNotEmpty == true || item.key?.isNotEmpty == true;
    });
  }

  /// 判断当前拍位在蓝图里是否属于必写项。
  bool _isRequiredBeat(String beatNid) {
    final blueprintSlots = _taskDraftDetailsData?.blueprint?.slots ?? const <ArticleBlueprintEntityBlueprintsSlots?>[];
    for (final slot in blueprintSlots) {
      if (slot?.beatNid != beatNid) continue;
      return slot?.required == true;
    }
    return false;
  }

  /// 查找当前拍位对应的提交结果。
  WritingBoardSubmitStepData? _findSubmitStep(List<WritingBoardSubmitStepData> steps, String beatNid) {
    for (final step in steps) {
      if (step.beatNid == beatNid) return step;
    }
    return null;
  }

  /// 将页面层提交数据映射成甄写提交接口需要的请求体。
  Map<String, dynamic> _buildSubmitRequestData({
    required WritingBoardSubmitData submitData,
    required String status,
    required List<String> answerImageKeys,
    required List<String> answerVideoKeys,
    required List<String> answerAudioKeys,
  }) {
    final taskDetails = _taskDraftDetailsData;
    return {
      if (taskDetails?.compositionWritingId != null) "compositionWritingId": taskDetails!.compositionWritingId,
      "taskId": submitData.taskId,
      "stageNid": submitData.stageNid,
      "answerKind": submitData.answerKind,
      "status": status,
      "headText": submitData.headText,
      "tailText": submitData.tailText,
      "parts": submitData.steps.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return {
          "beatNid": item.beatNid,
          "index": index,
          "text": item.text,
        };
      }).toList(),
      "answerImageKeys": answerImageKeys,
      "answerVideoKeys": answerVideoKeys,
      "answerAudioKeys": answerAudioKeys,
      "duration": _studyDurationStopwatch.elapsedMilliseconds / 1000,
    };
  }

  /// 将当前媒体类型转换成用户端上传资源类型。
  OssUploadUserType _buildUploadFileType(String kind) {
    if (kind == 'video') return OssUploadUserType.video;
    if (kind == 'audio') return OssUploadUserType.voice;
    return OssUploadUserType.image;
  }

  /// 上传本地媒体并产出提交所需的 key 列表。
  Future<List<String>?> _buildSubmitMediaKeys({
    required List<WritingBoardSubmitMediaItemData> items,
    required String kind,
  }) async {
    if (items.isEmpty) return <String>[];

    final uploadFileType = _buildUploadFileType(kind);
    final nextKeys = <String>[];
    final nextRuntimeItems = items.asMap().entries.map((entry) {
      final item = entry.value;
      return WritingBoardMediaItemData(
        key: item.key,
        url: item.url,
        localPath: item.localPath,
      );
    }).toList();

    for (final entry in items.asMap().entries) {
      final index = entry.key;
      final item = entry.value;
      if (item.key?.isNotEmpty == true) {
        nextKeys.add(item.key!);
        continue;
      }
      if (item.localPath?.isNotEmpty != true) {
        ToastUtils.showToast(text: "存在未完成上传的资源，请重新选择后再试");
        return null;
      }
      final record = await OssUploadFileUtils.uploadUserFile(
        filePath: item.localPath!,
        fileType: uploadFileType,
      );
      if (record == null || record.key == null) return null;
      nextKeys.add(record.key!);
      nextRuntimeItems[index] = nextRuntimeItems[index].copyWith(
        key: record.key,
        url: record.url,
      );
    }
    _syncUploadedRuntimeMediaItems(
      kind: kind,
      items: nextRuntimeItems,
    );
    return nextKeys;
  }

  /// 将刚上传完成的资源 key 回写到运行时状态，避免重复上传。
  void _syncUploadedRuntimeMediaItems({
    required String kind,
    required List<WritingBoardMediaItemData> items,
  }) {
    final runtimeState = writingBoardRuntimeState.value;
    if (runtimeState == null) return;
    if (kind == 'image') {
      runtimeState.answerImages = List<WritingBoardMediaItemData>.from(items);
      writingBoardRuntimeState.value = runtimeState.copyWith(
        answerImages: List<WritingBoardMediaItemData>.from(items),
      );
    } else if (kind == 'video') {
      runtimeState.answerVideos = List<WritingBoardMediaItemData>.from(items);
      writingBoardRuntimeState.value = runtimeState.copyWith(
        answerVideos: List<WritingBoardMediaItemData>.from(items),
      );
    } else if (kind == 'audio') {
      runtimeState.answerAudios = List<WritingBoardMediaItemData>.from(items);
      writingBoardRuntimeState.value = runtimeState.copyWith(
        answerAudios: List<WritingBoardMediaItemData>.from(items),
      );
    }
    _persistCurrentEditableRuntimeState();
    _syncWritingBoardDataFromRuntimeState();
  }

  /// 提交甄写状态，草稿和正式提交共用同一个接口。
  Future<bool> _submitWritingStatus({
    required WritingBoardSubmitData submitData,
    required String status,
    required String successText,
    bool shouldCloseAfterSuccess = false,
  }) async {
    try {
      ToastUtils.showLoading();
      writingBoardSubmitData.value = submitData;

      final answerImageKeys = await _buildSubmitMediaKeys(
        items: submitData.answerImages,
        kind: 'image',
      );
      if (answerImageKeys == null) return false;
      final answerVideoKeys = await _buildSubmitMediaKeys(
        items: submitData.answerVideos,
        kind: 'video',
      );
      if (answerVideoKeys == null) return false;
      final answerAudioKeys = await _buildSubmitMediaKeys(
        items: submitData.answerAudios,
        kind: 'audio',
      );
      if (answerAudioKeys == null) return false;

      final reqData = _buildSubmitRequestData(
        submitData: submitData,
        status: status,
        answerImageKeys: answerImageKeys,
        answerVideoKeys: answerVideoKeys,
        answerAudioKeys: answerAudioKeys,
      );
      debugPrint('WritingBoardSubmitPayload: ${jsonEncode(reqData)}');

      final bool res = await StudyAppRequest.submitWritingTask(data: reqData);
      if (!res) return false;

      if (status == 'submitted') {
        _studyDurationStopwatch.stop();
      }
      ToastUtils.showToast(text: successText, type: ToastType.success);
      if (shouldCloseAfterSuccess) {
        Get.back(result: true);
      }
      return true;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 将媒体类型转换成用户可读文案。
  String _mediaAnswerKindLabel(String kind) {
    if (kind == 'image') return "图片";
    if (kind == 'video') return "视频";
    if (kind == 'audio') return "音频";
    return "媒体";
  }

  /// 查看范文
  Future<void> viewSample(BuildContext context) async {
    if (isExemplarContentMode()) {
      _updateBoardMode(
        contentSource: WritingBoardContentSourceMacro.task,
        editPolicy: WritingBoardEditPolicyMacro.stageRule,
      );
      clearFrameSectionHighlight();
      _rebuildWritingBoardState();
      return;
    }

    if (_taskDetailsData?.stage?.lockExemplarView == true) {
      bool res = await ZhenxieTaskViewSampleLockDialog.show(
        context: context,
        isManagement: isManagement,
        title: "范文先收着",
        content: "这一关要看你自己能不能写出来。写完并提交之后，范文才会打开，用来对照。",
      );
      if (!res) return;
    }

    final bool hasLoadedExemplar = _exemplarDetailsData != null;
    if (!hasLoadedExemplar) {
      try {
        ToastUtils.showLoading();
        final bool res = await getExemplarDetailsData(
          targetCompositionUid: _taskDetailsData?.exemplarCompositionId,
          syncCurrentView: false,
        );
        if (!res) {
          ToastUtils.showToast(text: "范文详情获取失败");
          return;
        }
      } finally {
        ToastUtils.hideLoading();
      }
    }

    _updateBoardMode(
      contentSource: WritingBoardContentSourceMacro.exemplar,
      editPolicy: WritingBoardEditPolicyMacro.readOnly,
    );
    _rebuildWritingBoardState();
  }

  /// 保存草稿。
  Future<void> saveDraft() async {
    final submitData = _buildWritingBoardSubmitData();
    if (submitData == null) {
      ToastUtils.showToast(text: "当前还没有可暂存的写作数据");
      return;
    }
    final bool res = await _submitWritingStatus(
      submitData: submitData,
      status: 'draft',
      successText: "保存草稿成功",
    );
    if (!res) return;
    _taskExitCompareBaselineRuntimeState = writingBoardRuntimeState.value?.copyWith();
  }

  /// 提交任务。
  Future<void> submitTask() async {
    final submitData = _buildWritingBoardSubmitData();
    final data = writingBoardData.value;
    if (submitData == null) {
      ToastUtils.showToast(text: "当前还没有可提交的写作数据");
      return;
    }
    if (data == null) {
      ToastUtils.showToast(text: "当前还没有可提交的写作数据");
      return;
    }
    final validationMessage = _validateSubmitContent(
      data: data,
      submitData: submitData,
    );
    if (validationMessage != null) {
      ToastUtils.showToast(text: validationMessage);
      return;
    }
    await _submitWritingStatus(
      submitData: submitData,
      status: 'submitted',
      successText: "提交成功",
      shouldCloseAfterSuccess: true,
    );
  }

  // ================== 管理端方法 ======================

  /// 跳转至编辑页面
  void navigateToEditPage() {
    if (!isExemplarContentMode()) {
      // 如果是写作任务页面 则跳转至编辑模版页面
    } else {
      // 当前正在查看范文内容时，切换到范文编辑态。
      _updateBoardMode(
        contentSource: WritingBoardContentSourceMacro.exemplar,
        editPolicy: WritingBoardEditPolicyMacro.forceEditable,
      );
      _rebuildWritingBoardState();
    }
  }

  /// 管理端编辑保存范文方法
  Future<void> saveSample() async {
    final runtimeState = writingBoardRuntimeState.value;
    if (runtimeState == null) return;
    _persistCurrentEditableRuntimeState();
    _writeSampleRuntimeStateBackToDetails(runtimeState);
    _sampleEditExitCompareBaselineRuntimeState = runtimeState.copyWith();
    _updateBoardMode(
      contentSource: WritingBoardContentSourceMacro.exemplar,
      editPolicy: WritingBoardEditPolicyMacro.readOnly,
    );
    _rebuildWritingBoardState();
    ToastUtils.showToast(text: "范文保存占位已接线", type: ToastType.success);
  }

  /// 将当前范文编辑态输入结果回写到详情实体，保证切回查看态时内容保持一致。
  void _writeSampleRuntimeStateBackToDetails(WritingBoardRuntimeState runtimeState) {
    final exemplarDetails = _exemplarDetailsData;
    if (exemplarDetails == null) return;
    exemplarDetails.headText = _upsertLearningLangText(
      source: exemplarDetails.headText,
      text: runtimeState.headText,
    );
    exemplarDetails.tailText = _upsertLearningLangText(
      source: exemplarDetails.tailText,
      text: runtimeState.tailText,
    );
    final paragraphs = exemplarDetails.memberList ?? <ZhenxieTaskDetailsEntityParagraphInstance?>[];
    for (final step in writingBoardData.value?.steps ?? const <WritingBoardStepData>[]) {
      final nextText = runtimeState.stepTextMap[step.beatNid];
      if (nextText == null) continue;
      final paragraph = paragraphs.firstWhereOrNull((item) {
        return item?.paragraphId == step.paragraphId || item?.uid == step.paragraphId || item?.beatNid == step.beatNid;
      });
      if (paragraph != null) {
        paragraph.content = nextText;
      }
    }
    if (exemplarDetails.stage?.answerKind == 'image') {
      exemplarDetails.answerImageUrls =
          runtimeState.answerImages.map((item) => item.url ?? item.localPath ?? '').where((item) => item.isNotEmpty).toList();
    } else if (exemplarDetails.stage?.answerKind == 'video') {
      exemplarDetails.answerVideoUrls =
          runtimeState.answerVideos.map((item) => item.url ?? item.localPath ?? '').where((item) => item.isNotEmpty).toList();
    } else if (exemplarDetails.stage?.answerKind == 'audio') {
      exemplarDetails.answerAudioUrls =
          runtimeState.answerAudios.map((item) => item.url ?? item.localPath ?? '').where((item) => item.isNotEmpty).toList();
    }
    if (isExemplarContentMode()) {
      detailsData.refresh();
    }
  }

  /// 按学习语言主键更新或补充一条 `LanguageText`。
  List<LanguageText?> _upsertLearningLangText({
    required List<LanguageText?>? source,
    required String text,
  }) {
    final nextList = source != null ? List<LanguageText?>.from(source) : <LanguageText?>[];
    final learningLang = LearningLangUtils.getLearningLang(nextList)?.lang ??
        nextList.firstWhereOrNull((item) => item?.lang?.isNotEmpty == true)?.lang ??
        'en';
    final target = nextList.firstWhereOrNull((item) => item?.lang == learningLang);
    if (target != null) {
      target.text = text;
      return nextList;
    }
    nextList.add(LanguageText(lang: learningLang, text: text));
    return nextList;
  }

  @override
  void onClose() {
    clearFrameSectionHighlight();
    _disposeWritingBoardControllers();
    super.onClose();
  }
}
