import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/stores/stores.dart';

import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../app/routes/routes.dart';
import '../../../utils/utils.dart';
import '../../entities/entities.dart';
import '../../https/https.dart';
import '../../public_controller/manage_sandbox_controller.dart';
import '../../public_controller/mv_player_global_float_controller.dart';
import 'guide_engine.dart';

/// 全局引导任务控制器。
///
/// 当前版本按 `pageCode -> 页面任务 -> 多分组 -> 多步骤` 的结构运行，
/// 并为每个 `pageCode` 单独维护一份运行时进度。
///
/// 它的职责主要有两类：
///
/// 1. 调度引导步骤：查找当前应该展示的目标，必要时先滚动定位，再展示浮层
/// 2. 提供页面运行态：页面容器可基于当前 `pageCode` 的运行状态决定是否锁定页面交互
///
/// 推荐接入顺序：
///
/// 1. 页面进入时先调用 `loadTasks(pageCode: ...)` 预加载任务
/// 2. 页面根部使用 `GuidePageBoxWidget(pageCode: ..., child: ...)` 包裹，主要是为了禁用页面的滚动，可以选择不包裹
/// 3. 目标组件通过 `GuideStepWidget` 注册自己的 `widgetId`
/// 4. 页面数据、布局、动画真正稳定后，再调用 `start(pageCode)`
/// 5. 在弹窗关闭、路由返回、数据刷新完成后，按需调用 `continueGuide(pageCode, widgetId)`
///
/// 推荐使用方式：
///
/// - `GuideTargetTapAction.nextStep`
///   点击高亮目标后，控制器内部自动调用 `completeAndContinue`
/// - `GuideTargetTapAction.executeTargetLogic`
///   点击高亮目标后，控制器内部先 `completeGuide`，再执行目标原始业务逻辑
/// - 页面侧通常不需要再手动调用 `completeGuide`
/// - 页面侧主要负责在“可以恢复引导”的时机调用 `start` 或 `continueGuide`
class GuideTaskController extends GetxService {
  /// 全局单例访问入口。
  ///
  /// 使用方式：
  ///
  /// ```dart
  /// GuideTaskController.to.start(pageCode);
  /// ```
  static GuideTaskController get to => Get.find<GuideTaskController>();

  /// 引导目标注册管理器。
  ///
  /// 作用：
  ///
  /// - 维护 `widgetId -> GlobalKey`
  /// - 判断目标当前是否已挂载
  /// - 保存目标点击时的原始业务回调
  ///
  /// 页面通常不直接使用它，而是通过 `GuideStepWidget` 自动注册。
  final GuideRegistryManage registry = GuideRegistryManage();

  /// 引导任务的列表数据
  final Rx<NewbieGuideEntity> newbieGuideData = NewbieGuideEntity().obs;

  /// 当前是否有引导浮层正在显示。
  ///
  /// 主要用于防止同一时间重复弹出多个引导层。
  final RxBool isShowing = false.obs;

  /// 当前正在执行或最近一次执行的页面 `pageCode`。
  ///
  /// 作用：
  ///
  /// - 标记当前引导上下文属于哪个页面
  /// - 供目标注册完成后的自动尝试逻辑使用
  final RxnString currentPageCode = RxnString();

  /// 引导任务仓库。
  ///
  /// 作用：
  ///
  /// - 按页面加载服务端返回的页面任务
  /// - 在分组完成时执行上报
  final GuideTaskRepository _repository = GuideTaskRepository();

  /// 每个页面对应的一份运行时进度缓存。
  ///
  /// key 是 `pageCode`，value 是该页面当前执行到哪一组、哪一步。
  ///
  /// 这样可以支持：
  ///
  /// - A 页面执行一半进入 B 页面
  /// - B 页面执行后返回 A 页面
  /// - A 页面再从自己原来的进度继续
  final RxMap<String, Object?> pageProgressMap = <String, Object?>{}.obs;

  /// 当前展示中的 `tutorial_coach_mark` 实例。
  ///
  /// 用于后续关闭当前浮层。
  TutorialCoachMark? _tutorialCoachMark;

  /// 是否正在执行一次启动尝试。
  ///
  /// 用于防止同一帧内重复进入 `_tryStart`。
  bool _isTryingStart = false;

  /// 当前正在展示的目标 `widgetId`。
  ///
  /// 主要用于：
  ///
  /// - 目标被销毁时判断是否需要立刻关闭当前引导
  /// - 维护当前展示状态
  String? _activeWidgetId;

  /// 当前任务的questId
  /// 
  /// 在引导列表开始的时候 需要设置当前任务的questId，
  /// 然后把questId 给页面任务列表接口[fetchPageTask]
  /// 任务结束需要设置为null
  int? _currentQuestId;

  /// 当前任务是否是“再来一次”模式。
  ///
  /// 该值会在页面任务请求时转换为仓库层的 `review` 参数。
  bool _isAgain = false;

  _GuidePageProgress? _getPageProgress(String pageCode) {
    return pageProgressMap[pageCode] as _GuidePageProgress?;
  }

  /// 请求引导任务数据
  Future<void> loadNewbieGuideTaskList() async{
    if(!UserStore.to.isLogin) return;
    /// 管理端模拟 不允许访问 引导接口
    if(ManageSandboxController.to.isSimulate) return;
    try {
      Map<String, dynamic> parameters = {
        "groupCode": "newbie",
      };
      NewbieGuideEntity? entity = await ActivitiesRequest.getGuideTaskList(parameters: parameters);
      if(entity == null) {
        newbieGuideData.value = NewbieGuideEntity();
        return;
      }
      newbieGuideData.value = entity;
    } catch (_) {}
  }

  /// 查询是否有引导任务
  bool hasGuideTask(){
    return newbieGuideData.value.quests?.isNotEmpty ?? false;
  }

  /// 查询未完成的任务数量
  int getUncompletedQuestCount(){
    if(newbieGuideData.value.quests == null) return 0;
    List<NewbieGuideEntityQuests?> quests = newbieGuideData.value.quests??[];
    int uncompletedCount = quests.where((element) => element?.status != 1).length;
    return uncompletedCount;
  }

  /// 查询有可执行的任务数量
  int getExecutableQuestCount(){
    if(newbieGuideData.value.quests == null) return 0;
    List<NewbieGuideEntityQuests?> quests = newbieGuideData.value.quests??[];
    int executableCount = quests.where((element) => element?.status != 1 && element?.rights?.allLock == false).length;
    return executableCount;
  }

  /// 按页面加载引导任务，并初始化该页面的运行时进度。并且返回第一组的第一步
  ///
  /// 什么时候调用：
  ///
  /// - 页面初始化时
  /// - 页面重新进入时
  /// - 业务需要重新拉取该页面引导任务时
  ///
  /// 注意：
  ///
  /// - 这个方法只负责加载任务，不会立刻开始展示
  /// - 真正开始引导，需要后续显式调用 `start(pageCode)`
  Future<void> loadTasks({
    required String pageCode,
  }) async {
    if(!UserStore.to.isLogin) return;
    /// 管理端模拟 不允许访问 引导接口
    if(ManageSandboxController.to.isSimulate) return;

    currentPageCode.value = pageCode;
    final GuidePageTask? task = await _repository.fetchPageTask(
      pageCode: pageCode,
      questId: _currentQuestId,
      review: _isAgain ? 1 : null,
    );
    if (task == null) {
      pageProgressMap.remove(pageCode);
      return;
    }

    pageProgressMap[pageCode] = _GuidePageProgress(task: task);

  }

  /// 启动指定页面的引导流程。
  ///
  /// 正确使用方式：
  ///
  /// 1. 先 `loadTasks(pageCode: xxx)`
  /// 2. 页面数据和视图稳定后再 `start(pageCode)`
  ///
  /// 这个方法会把该页面标记为“允许开始”，然后尝试展示当前进度下的第一个可见步骤。
  Future<void> start(String pageCode) async {
    if(!UserStore.to.isLogin) return;
    currentPageCode.value = pageCode;
    _GuidePageProgress? progress = _getPageProgress(pageCode);
    if (progress == null) return;
    progress.isInterrupted = false;
    progress.isReadyToStart = true;
    pageProgressMap.refresh();
    await _waitForLayoutStabilized();
    await _tryStart(pageCode); 
  }

  /// 获取步骤数据并且开始引导
  Future<void> loadTasksAndStart({required String pageCode, bool showLoading = true}) async{
    
    try {
      if(showLoading) ToastUtils.showLoading();
      await loadTasks(pageCode: pageCode);
    } finally{
      if(showLoading) ToastUtils.hideLoading();
    }
    await start(pageCode);
  }

  /// 获取当前步骤组的第一步
  GuideTaskGuide? getFirstGuide(String pageCode){
    _GuidePageProgress? progress = _getPageProgress(pageCode);
    if (progress == null) return null;
    List<GuideTaskGroup> guideGroups = progress.task.guideGroups??[];
    if(guideGroups.isEmpty) return null;
    List<GuideTaskGuide> guides = guideGroups.first.guides??[];
    if(guides.isEmpty) return null;
    return guides.first;
  }

  /// 注册一个引导目标，并返回稳定的 `GlobalKey`。
  ///
  /// 通常由 `GuideStepWidget` 在内部自动调用，业务层一般不需要手动触发。
  ///
  /// [id] 是目标组件的 `widgetId`。
  /// [onTargetTap] 是目标被高亮点击时，原始业务逻辑的回调。
  GlobalKey registerTarget(
    String id, {
    GuideTargetTapHandler? onTargetTap,
    double? ensureVisibleAlignment,
  }) {
    final GlobalKey targetKey = registry.register(
      id,
      onTargetTap: onTargetTap,
      ensureVisibleAlignment: ensureVisibleAlignment,
    );
    _scheduleStartAttempt();
    return targetKey;
  }

  /// 更新已注册目标的点击回调。
  ///
  /// 使用场景：
  ///
  /// - 组件没有换 `widgetId`
  /// - 但点击后的业务回调因为状态变化而变化
  ///
  /// 这个方法通常也是由 `GuideStepWidget` 内部自动调用。
  void updateTargetTapHandler(
    String id, {
    GuideTargetTapHandler? onTargetTap,
    double? ensureVisibleAlignment,
  }) {
    registry.updateTargetTapHandler(id, onTargetTap, ensureVisibleAlignment);
  }

  /// 注销一个引导目标。
  ///
  /// 通常由 `GuideStepWidget` 在组件销毁时自动调用。
  ///
  /// 如果被销毁的正好是当前展示目标，会顺手关闭当前浮层，
  /// 避免高亮继续指向一个已经不存在的组件。
  void unregisterTarget(String id) {
    final bool isCurrentTarget = _activeWidgetId == id;
    registry.unregister(id);

    if (isCurrentTarget && !registry.isMounted(id)) {
      _dismissCurrentGuide();
    }
  }

  /// 完成指定页面中的某个步骤，但不自动继续下一步。
  ///
  /// 使用方式：
  ///
  /// ```dart
  /// await GuideTaskController.to.completeGuide(pageCode, widgetId);
  /// ```
  ///
  /// 典型场景：
  ///
  /// - 控制器在 `_handleTargetTap` 中为 `executeTargetLogic` 步骤自动调用
  /// - 页面需要手动提前标记“当前步骤已完成”
  /// - 后续是否继续，由业务在合适时机自行决定
  ///
  /// 行为说明：
  ///
  /// - 如果当前步骤不是所在分组的最后一步，只推进组内索引
  /// - 如果当前步骤是该分组最后一步，会静默上报该分组的 `stepCode`
  /// - 完成后会先关闭当前浮层
  ///
  /// 注意：
  ///
  /// - 当前版本里，页面通常不需要在目标点击前手动调用这个方法
  /// - 更常见的写法是让控制器在 `_handleTargetTap` 中统一完成当前步骤
  Future<bool> completeGuide(String pageCode, String? widgetId) async {
    final _GuidePageProgress? progress = _getPageProgress(pageCode);
    if (progress == null) return false;

    final _GuidePosition? position = _findGuidePosition(progress.task, widgetId);
    if (position == null) return false;

    currentPageCode.value = pageCode;
    progress.groupIndex = position.groupIndex;
    progress.guideIndex = position.guideIndex;
    progress.lastCompletedWidgetId = widgetId;
    progress.hasGuidedWidgetInCurrentGroup = true;

    _dismissCurrentGuide();
    final int groupIndex = position.groupIndex;
    final int guideIndex = position.guideIndex;
    final GuideTaskGroup? group = progress.task.guideGroups?[groupIndex];
    if (group == null) return false;
    final GuideTaskGuide? guide = group.guides?[guideIndex];
    if (position.guideIndex >= (group.guides?.length ?? 0) - 1) {
      if (progress.hasGuidedWidgetInCurrentGroup) {
        await _reportGroupOnce(progress, group);
      }
    
      progress.groupIndex = groupIndex + 1;
      progress.guideIndex = 0;
      progress.hasGuidedWidgetInCurrentGroup = false;
      pageProgressMap.refresh();
      if (progress.isFinished) {
        _finishPage(pageCode);
      }
      // 完成后需要根据 resumeAction 来判断是否 执行相应的事件 
      String? resumeAction = guide?.resumeAction;
      if(resumeAction != null){
        GuideResumeActionCode.executeAction(resumeAction);
      }
      return true;
    }
    progress.guideIndex = guideIndex + 1;
    pageProgressMap.refresh();

    // 完成后需要根据 resumeAction 来判断是否 执行相应的事件 
    String? resumeAction = guide?.resumeAction;
    if(resumeAction != null){
      GuideResumeActionCode.executeAction(resumeAction);
    }

    return true;
  }

  /// 从指定页面的某个步骤之后继续执行引导。
  ///
  /// 使用方式：
  ///
  /// ```dart
  /// await GuideTaskController.to.continueGuide(pageCode, widgetId);
  /// ```
  ///
  /// 典型场景：
  ///
  /// - 从下一个页面返回后恢复原页面引导
  /// - 弹窗关闭后继续原来的步骤
  /// - 数据刷新完成后，从某一步之后继续往后找可展示目标
  ///
  /// 行为说明：
  ///
  /// - 先根据 `widgetId` 定位当前步骤
  /// - 再从它的后一步开始寻找可展示步骤
  /// - 当前目标不存在时，会继续找后面的步骤
  ///
  /// 当前版本里，这个方法是页面侧最常用的恢复入口。
  Future<bool> continueGuide(String pageCode, String? widgetId) async {
    if(!UserStore.to.isLogin) return false;
    try {
      final _GuidePageProgress? progress = _getPageProgress(pageCode);
      if (progress == null) return false;
      if (progress.isInterrupted) return false;

      currentPageCode.value = pageCode;
      progress.isReadyToStart = true;
      pageProgressMap.refresh();

      final _GuidePosition? position = _findGuidePosition(progress.task, widgetId);
      if (position != null) {
        final _GuidePosition? nextPosition = _nextPosition(
          progress.task,
          position.groupIndex,
          position.guideIndex,
        );
        if (nextPosition != null) {
          final int comparePosition = _comparePosition(
            nextPosition.groupIndex,
            nextPosition.guideIndex,
            progress.groupIndex,
            progress.guideIndex,
          );
          if (comparePosition >= 0) {
            progress.groupIndex = nextPosition.groupIndex;
            progress.guideIndex = nextPosition.guideIndex;
          }
        }
      }

      _dismissCurrentGuide();
      await _waitForLayoutStabilized();
      if (progress.isInterrupted || !progress.isReadyToStart) return false;

      // 在这里 防止在播放音乐 需要关掉音乐
      if(Get.isRegistered<MvPlayerGlobalFloatController>()){
        Get.find<MvPlayerGlobalFloatController>().stop();
      }

      return _tryStart(pageCode);
    } finally {}
  }

  /// 完成当前步骤并立即继续后续引导。
  ///
  /// 这是最常用的快捷方法，适合同页内的普通顺序引导。
  ///
  /// 使用方式：
  ///
  /// ```dart
  /// await GuideTaskController.to.completeAndContinue(pageCode, widgetId);
  /// ```
  ///
  /// 当前主要由控制器内部在 `GuideTargetTapAction.nextStep` 场景下调用。
  Future<bool> completeAndContinue(String pageCode, String? widgetId) async {
    final bool completed = await completeGuide(pageCode, widgetId);
    if (!completed) return false;
    if (!pageProgressMap.containsKey(pageCode)) return true;
    return continueGuide(pageCode, widgetId);
  }

  /// 判断某个分组当前是否正处于“最后一个引导已完成”的时刻。
  ///
  /// 这里必须在 `reportStep` 发起异步请求前完成判断，
  /// 避免调用方在未 `await` 的情况下已经推进到了下一组，导致状态失真。
  bool _isLastGuideCompletedInCurrentGroup(GuideTaskGroup group) {
    for (final Object? item in pageProgressMap.values) {
      if (item is! _GuidePageProgress) continue;

      final GuideTaskGroup? currentGroup = item.currentGroup;
      if (!_isSameGuideGroup(currentGroup, group)) continue;

      final int guideCount = currentGroup?.guides?.length ?? 0;
      if (guideCount <= 0) return true;

      return item.guideIndex >= guideCount - 1;
    }
    return false;
  }

  /// 判断两个分组是否表示同一个服务端任务分组。
  ///
  /// 这里不能只比较对象引用，运行时场景里可能拿到的是不同实例，
  /// 需要基于分组的业务主键字段做等价判断。
  bool _isSameGuideGroup(GuideTaskGroup? left, GuideTaskGroup? right) {
    if (identical(left, right)) return true;
    if (left == null || right == null) return false;
    return left.questId == right.questId &&
        left.stepCode == right.stepCode &&
        left.order == right.order;
  }

  /// 找到当前分组运行时所在的当前步骤。
  ///
  /// 只有当前步骤明确配置 `submittable == false` 时才不上报，
  /// 其余情况都保持原有上报逻辑。
  GuideTaskGuide? _findReportGuide(GuideTaskGroup group) {
    for (final item in pageProgressMap.values) {
      if (item is! _GuidePageProgress) continue;

      final GuideTaskGroup? currentGroup = item.currentGroup;
      if (!_isSameGuideGroup(currentGroup, group)) continue;

      final List<GuideTaskGuide>? guides = currentGroup?.guides;
      if (guides == null || guides.isEmpty) return null;
      if (item.guideIndex < 0 || item.guideIndex >= guides.length) return null;
      return guides[item.guideIndex];
    }
    return null;
  }

  /// 为分组生成运行时唯一 key。
  ///
  /// 用于在一次页面引导流程里识别“同一个服务端分组”，
  /// 避免 `completeGuide` 和 `_completeCurrentGroup` 在相邻链路中
  /// 对同一分组重复触发 `reportStep`。
  String _buildGuideGroupKey(GuideTaskGroup group) {
    return '${group.questId}_${group.stepCode}_${group.order}';
  }

  /// 保证同一个分组在当前页面流程里只会上报一次。
  ///
  /// 触发场景主要有两类：
  ///
  /// - 页面手动调用 `completeGuide`，并且当前步骤正好是组内最后一步
  /// - 后续恢复流程进入 `_completeCurrentGroup`，再次判定该组已完成
  ///
  /// 这两个入口理论上可能前后连续命中同一个分组，因此这里用
  /// `reportingGroupKey` 和 `lastReportedGroupKey` 做幂等保护。
  Future<void> _reportGroupOnce(
    _GuidePageProgress progress,
    GuideTaskGroup group,
  ) async {
    final String groupKey = _buildGuideGroupKey(group);
    if (progress.reportingGroupKey == groupKey) return;
    if (progress.lastReportedGroupKey == groupKey) return;

    progress.reportingGroupKey = groupKey;
    try {
      await reportStep(group);
      progress.lastReportedGroupKey = groupKey;
    } finally {
      if (progress.reportingGroupKey == groupKey) {
        progress.reportingGroupKey = null;
      }
    }
  }

  /// 上报某个分组完成。
  ///
  /// 当前对外保留该方法，主要供控制器内部和调试场景使用。
  ///
  /// 正常业务流程下，一般不需要页面直接调用它，
  /// 因为分组完成时 `completeGuide` / `_completeCurrentGroup` 会自动处理。
  Future<void> reportStep(GuideTaskGroup group) async {
    if(!group.isReportClick) return;
    // 只有明确配置为 false 才不上报，null / true 都保持原来的可上报行为。
    if(_findReportGuide(group)?.submittable == false) return;
    final bool isLastGuideCompletedInCurrentGroup = _isLastGuideCompletedInCurrentGroup(group);
    NewbieGuideEntityQuests? res;

    try {
      ToastUtils.showLoading();
      res = await _repository.reportStepComplete(group); // 需要上报后回的奖励 弹出来
      if(res == null) return;
      // 刷新新手任务列表
      await loadNewbieGuideTaskList();
    } finally{
      ToastUtils.hideLoading();
    }

    if(Get.context == null) return;

    if(res.status != 1) return;
    if(res.rewardStatus == 1){
      // 如果有奖励 弹出奖励弹窗
      await GuideRewardDialog.showClaimRewardDialog(
        context: Get.context!,
        rewards: res.rewards ?? [],
      );
    }
    
    // 判断是否是最后一个分组的最后一个引导
    if(!isLastGuideCompletedInCurrentGroup) return;
    _clearCurrentTaskContext();
    // 最后一步完成后 判断还有没有未完成的新手引导 如果有 回到首页继续引导
    int uncompletedQuestCount = getExecutableQuestCount();
    if(uncompletedQuestCount <= 0) return;
    Get.until((route) => route.settings.name == Routes.APPLICATION);
    await _waitForLayoutStabilized();
    showHomeGuide();

  }

  /// 判断某个目标当前是否已挂载到组件树中。
  ///
  /// 适合页面在调试或做额外防守判断时使用。
  bool isTargetMounted(String id) {
    return registry.isMounted(id);
  }

  /// 当前页面是否应该处于“引导锁定”状态。
  ///
  /// 返回 `true` 的含义是：
  ///
  /// - 当前页面已经开始引导或正等待继续
  /// - 当前页面还没有被用户手动中断
  /// - 当前页面任务也还没有执行完成
  ///
  /// 这个判断故意不依赖 `isShowing`，这样在“旧步骤刚关闭、新步骤还未弹出”
  /// 的过渡空窗期里，页面仍然可以继续保持锁定。
  bool shouldLockPage(String pageCode) {
    final _GuidePageProgress? progress = _getPageProgress(pageCode);
    if (progress == null) return false;
    if (!progress.isReadyToStart) return false;
    if (progress.isInterrupted) return false;
    return true;
  }

  /// 暂停指定页面的引导，但保留当前进度。
  ///
  /// 使用场景：
  ///
  /// - 当前页面跳转到了下层路由
  /// - 页面临时离开前台，等待后续显式 `continueGuide`
  ///
  /// 行为说明：
  ///
  /// - 仅解除当前页面的锁定态
  /// - 关闭当前浮层，避免返回后残留遮罩
  /// - 保留组内进度，后续还能从当前位置继续
  void pausePage(String pageCode) {
    final _GuidePageProgress? progress = _getPageProgress(pageCode);
    if (progress == null) return;

    if (currentPageCode.value == pageCode) {
      _dismissCurrentGuide();
    }

    if (!progress.isReadyToStart) return;
    progress.isReadyToStart = false;
    pageProgressMap.refresh();
  }

  /// 停止当前页面的引导，并重置该页面进度。
  ///
  /// 使用场景：
  ///
  /// - 用户点击右上角关闭按钮
  /// - 页面想主动中断当前引导
  ///
  /// 行为说明：
  ///
  /// - 关闭当前浮层
  /// - 当前页面进度回到第 0 组第 0 步
  /// - 下次重新 `start(pageCode)` 时会从头开始
  void stop() {
    final String? pageCode = currentPageCode.value;
    if (pageCode != null) {
      _getPageProgress(pageCode)
        ?..reset()
        ..isReadyToStart = false
        ..isInterrupted = true;
      pageProgressMap.refresh();
    }
    _clearCurrentTaskContext();
    _dismissCurrentGuide();
  }

  /// 重置整个控制器状态。
  ///
  /// 这个方法会：
  ///
  /// - 关闭当前浮层
  /// - 清空所有页面进度缓存
  /// - 清空当前页面标记
  /// - 清空已注册目标
  ///
  /// 一般只在全局重置引导系统时调用。
  void reset() {
    _dismissCurrentGuide();
    pageProgressMap.clear();
    currentPageCode.value = null;
    _clearCurrentTaskContext();
    registry.clear();
  }

  /// 按当前页面进度尝试展示下一个可执行步骤。
  ///
  /// 这是控制器内部真正的调度入口。
  ///
  /// 工作流程：
  ///
  /// 1. 读取当前页面进度
  /// 2. 找到当前分组和当前步骤
  /// 3. 如果目标存在，则滚动并展示
  /// 4. 如果目标不存在，则继续往后找
  /// 5. 如果当前分组走完，则先上报该分组，再切换到下一分组
  Future<bool> _tryStart(String pageCode) async {
    if (_isTryingStart || isShowing.value) return false;
    final _GuidePageProgress? progress = _getPageProgress(pageCode);
    if (progress == null) return false;
    if (!progress.isReadyToStart) return false;

    // 开始引导的时候 需要判断页面有没有挂载这个widgetid 去掉不存在的widgetid对应的widget，否则会导致滚动异常
    progress.currentGroup?.guides?.removeWhere((element) => !isTargetMounted(element.widgetId??""));

    currentPageCode.value = pageCode;
    _isTryingStart = true;
    try {
      while (true) {
        if (progress.isFinished) {
          _finishPage(pageCode);
          return false;
        }

        final GuideTaskGroup? group = progress.currentGroup;
        if (group == null) {
          _finishPage(pageCode);
          return false;
        }

        if (progress.guideIndex >= (group.guides?.length ?? 0)) {
          final bool hasNext = await _completeCurrentGroup(pageCode, progress);
          if (!hasNext) return false;
          continue;
        }

        final GuideTaskGuide? guide = group.guides?[progress.guideIndex];
        if (guide == null) {
          progress.guideIndex++;
          continue;
        }

        final GlobalKey? targetKey = registry.findKey(guide.widgetId);
        if (targetKey == null || targetKey.currentContext == null) {
          progress.guideIndex++;
          continue;
        }

        await _ensureTargetVisible(targetKey, guide.widgetId);
        if (targetKey.currentContext == null) {
          progress.guideIndex++;
          continue;
        }

        _showStep(
          pageCode: pageCode,
          group: group,
          guide: guide,
          targetKey: targetKey,
          progressText: _buildProgressText(progress),
        );
        progress.hasGuidedWidgetInCurrentGroup = true;
        return true;
      }
    } finally {
      _isTryingStart = false;
    }
  }

  /// 当当前分组已经走到末尾时，静默上报该分组并切换到下一分组。
  ///
  /// 返回值含义：
  ///
  /// - `true`：还有后续分组，可以继续尝试展示
  /// - `false`：当前页面任务已结束，或上报失败
  Future<bool> _completeCurrentGroup(
    String pageCode,
    _GuidePageProgress progress,
  ) async {
    final GuideTaskGroup? group = progress.currentGroup;
    if (group == null) {
      _finishPage(pageCode);
      return false;
    }

    if (progress.hasGuidedWidgetInCurrentGroup) {
      await _reportGroupOnce(progress, group);
    }

    progress.groupIndex++;
    progress.guideIndex = 0;
    progress.hasGuidedWidgetInCurrentGroup = false;
    if (progress.isFinished) {
      _finishPage(pageCode);
      return false;
    }

    return true;
  }

  /// 结束某个页面的引导任务，并移除该页面运行时进度。
  ///
  /// 当一个页面的所有分组都执行完成后，会调用这里做最终收尾。
  void _finishPage(String pageCode) {
    if (currentPageCode.value == pageCode) {
      _dismissCurrentGuide();
    }
    pageProgressMap.remove(pageCode);
  }

  /// 展示前尽量把目标滚动到可视区域内。
  ///
  /// 当前只支持“目标已经挂载，但位于屏幕外”的场景。
  ///
  /// 使用策略：
  ///
  /// - 已可见：只等待一帧让布局稳定
  /// - 不可见：尝试 `Scrollable.ensureVisible`
  /// - 不支持滚动或上下文丢失：静默返回
  Future<void> _ensureTargetVisible(GlobalKey targetKey, String? widgetId) async {
    final BuildContext? targetContext = targetKey.currentContext;
    if (targetContext == null) return;

    try {
      final double? ensureVisibleAlignment = registry.findEnsureVisibleAlignment(widgetId);
      await Scrollable.ensureVisible(
        targetContext,
        alignment: ensureVisibleAlignment ?? 0.5,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    } catch (_) {
      return;
    }

    await _waitNextFrame();
  }

  /// 设置当前任务的questId
  void setCurrentQuestId(int? questId) {
    _currentQuestId = questId;
  }

  /// 设置当前任务是否为“再来一次”。
  void setIsAgain(bool isAgain) {
    _isAgain = isAgain;
  }

  /// 清空当前任务上下文，避免影响后续页面任务请求。
  void _clearCurrentTaskContext() {
    _currentQuestId = null;
    _isAgain = false;
  }

  /// 等待下一帧，避免滚动后立刻展示导致高亮位置抖动。
  Future<void> _waitNextFrame() {
    final WidgetsBinding binding = WidgetsBinding.instance;
    final Future<void> future = binding.endOfFrame;
    binding.scheduleFrame();
    return future;
  }

  /// 等待页面布局稳定后再尝试启动引导。
  ///
  /// 设计原因：
  ///
  /// - `start()` 往往发生在页面数据刚更新完成的时刻
  /// - 此时依赖 `Obx` / `setState` 的目标组件可能还没真正挂载
  /// - 如果立刻 `_tryStart()`，控制器会把这些暂未挂载的步骤直接跳过
  ///
  /// 当前采用“等待两帧”的保守策略：
  ///
  /// - 第一帧让状态更新触发 rebuild
  /// - 第二帧让目标组件完成挂载与布局
  Future<void> _waitForLayoutStabilized() async {
    await _waitNextFrame();
    await _waitNextFrame();
  }

  /// 在下一帧尝试重新启动当前页面引导。
  ///
  /// 主要用于：
  ///
  /// - 新目标组件刚注册完成
  /// - 页面 rebuild 后希望重新尝试展示
  void _scheduleStartAttempt() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? pageCode = currentPageCode.value;
      if (pageCode == null) return;
      _tryStart(pageCode);
    });
  }

  /// 展示单个引导浮层。
  ///
  /// 参数说明：
  ///
  /// - [pageCode]：当前页面标识
  /// - [group]：当前步骤所在分组
  /// - [guide]：当前具体步骤
  /// - [targetKey]：当前目标组件 key
  /// - [progressText]：顶部进度文本，例如 `2/5`
  void _showStep({
    required String pageCode,
    required GuideTaskGroup group,
    required GuideTaskGuide guide,
    required GlobalKey targetKey,
    required String progressText,
  }) {
    final BuildContext? targetContext = targetKey.currentContext;
    if (targetContext == null) return;
    bool didTapTarget = false;

    _tutorialCoachMark = GuideStepOverlayDialog.show(
      identify: '${pageCode}_${group.stepCode}_${guide.widgetId}',
      guide: guide,
      context: targetContext,
      targetKey: targetKey,
      progressText: progressText,
      onCloseTap: stop,
      onActionTap: stop,
      onFinish: () {
        _dismissCurrentGuide();
        if (!didTapTarget) return;
        Future<void>.delayed(Duration.zero, () async {
          try {
            await _handleTargetTap(pageCode, guide);
          } finally {
          }
        });
      },
      onSkip: () => true,
      onClickTarget: (_) {
        didTapTarget = true;
      },
    );

    _activeWidgetId = guide.widgetId;
    isShowing.value = true;
  }

  /// 清理当前浮层展示状态。
  ///
  /// 只清理展示层变量，不修改任何页面进度。
  void _resetPresentationState() {
    _tutorialCoachMark = null;
    _activeWidgetId = null;
    if (isShowing.value) {
      isShowing.value = false;
    }
  }

  /// 关闭当前引导浮层。
  ///
  /// 该方法只负责“隐藏展示层”，不负责推进步骤或重置进度。
  void _dismissCurrentGuide() {
    final TutorialCoachMark? tutorial = _tutorialCoachMark;
    if (tutorial != null) {
      GuideStepOverlayDialog.close(tutorial);
    }
    _resetPresentationState();
  }

  /// 展示首页新手任务引导浮窗
  void showHomeGuide() {
    final GlobalKey? targetKey = registry.findKey(GuideWidgetIds.homeGuideDialogButton);
    if (targetKey == null) return;
    final BuildContext? targetContext = targetKey.currentContext;
    if (targetContext == null) return;

    GuideTaskGuide guide = GuideTaskGuide(
      widgetId: GuideWidgetIds.homeGuideDialogButton,
      title: "新手任务",
      desc: "点击打开任务列表，继续完成任务。",
      handle: 1,
      close: true,
    );

    currentPageCode.value = AppRoutesCode.home;

    _showStep(
      pageCode: AppRoutesCode.home,
      group: GuideTaskGroup(
        stepCode: "steps1",
        order: 1,
        isReportClick: false,
      ),
      guide: guide,
      targetKey: targetKey,
      progressText: "",
    );
    
  }


  /// 处理用户点击高亮目标区域后的行为。
  ///
  /// 规则由步骤配置里的 `targetTapAction` 决定：
  ///
  /// - `executeTargetLogic`：先完成当前步骤，再执行目标原始业务回调
  /// - `nextStep`：直接调用 `completeAndContinue`
  ///
  /// 这也是当前“完成步骤逻辑下沉”的核心入口：
  ///
  /// - 页面不再需要在目标点击前手动调用 `completeGuide`
  /// - 控制器会根据步骤配置统一处理完成逻辑
  /// - 页面只需要在后续合适时机调用 `continueGuide`
  Future<void> _handleTargetTap(String pageCode, GuideTaskGuide guide) async {
    if (guide.targetTapAction == GuideTargetTapAction.executeTargetLogic) {
      final GuideTargetTapHandler? targetTapHandler = registry.findTargetTapHandler(guide.widgetId);
      if (targetTapHandler == null) {
        await completeAndContinue(pageCode, guide.widgetId);
        return;
      }
      await completeGuide(pageCode, guide.widgetId);
      await targetTapHandler();
      return;
    }

    await completeAndContinue(pageCode, guide.widgetId);
  }

  /// 在页面任务中查找某个 `widgetId` 对应的分组位置和步骤位置。
  ///
  /// 返回值用于：
  ///
  /// - `completeGuide` 精确推进当前进度
  /// - `continueGuide` 从当前步骤之后继续
  _GuidePosition? _findGuidePosition(GuidePageTask task, String? widgetId) {
    if(task.guideGroups == null) return null;
    if (widgetId == null) return null;
    for (int groupIndex = 0; groupIndex < (task.guideGroups?.length??0); groupIndex++) {
      final List<GuideTaskGuide>? guides = task.guideGroups?[groupIndex].guides;
      if(guides == null) continue;
      for (int guideIndex = 0; guideIndex < guides.length; guideIndex++) {
        if (guides[guideIndex].widgetId == widgetId) {
          return _GuidePosition(
            groupIndex: groupIndex,
            guideIndex: guideIndex,
          );
        }
      }
    }
    return null;
  }

  /// 根据当前位置，计算逻辑上的“下一步”位置。
  ///
  /// 规则：
  ///
  /// - 当前分组还有下一步时，优先返回组内下一步
  /// - 当前分组已结束时，返回下一分组的第 0 步
  /// - 所有分组都结束时，返回 `null`
  _GuidePosition? _nextPosition(
    GuidePageTask task,
    int groupIndex,
    int guideIndex,
  ) {
    if (groupIndex >= (task.guideGroups?.length??0)) return null;

    final GuideTaskGroup? currentGroup = task.guideGroups?[groupIndex];
    if(currentGroup == null) return null;

    if (guideIndex + 1 < (currentGroup.guides?.length??0)) {
      return _GuidePosition(
        groupIndex: groupIndex,
        guideIndex: guideIndex + 1,
      );
    }

    if (groupIndex + 1 < (task.guideGroups?.length??0)) {
      return _GuidePosition(
        groupIndex: groupIndex + 1,
        guideIndex: 0,
      );
    }

    return null;
  }

  /// 比较两个位置的先后顺序。
  ///
  /// 返回值规则与 `compareTo` 一致：
  ///
  /// - 小于 0：左边更靠前
  /// - 等于 0：两者相同
  /// - 大于 0：左边更靠后
  int _comparePosition(
    int leftGroupIndex,
    int leftGuideIndex,
    int rightGroupIndex,
    int rightGuideIndex,
  ) {
    final int groupCompare = leftGroupIndex.compareTo(rightGroupIndex);
    if (groupCompare != 0) return groupCompare;
    return leftGuideIndex.compareTo(rightGuideIndex);
  }

  /// 生成当前页面任务的进度文案，例如 `2/5`。
  ///
  /// 展示层会把这个文本显示在当前引导浮层中。
  String _buildProgressText(_GuidePageProgress progress) {
    int current = 0;
    int total = 0;
    for (int groupIndex = 0; groupIndex < (progress.task.guideGroups?.length??0); groupIndex++) {
      final List<GuideTaskGuide>? guides = progress.task.guideGroups?[groupIndex].guides;
      if(guides == null) continue;
      total += guides.length;
      if (groupIndex < progress.groupIndex) {
        current += guides.length;
        continue;
      }
      if (groupIndex == progress.groupIndex) {
        current += progress.guideIndex + 1;
      }
    }
    if (total <= 0) return '';
    return '$current/$total';
  }

  /// 控制器销毁时做最终清理。
  ///
  /// 这里会关闭当前浮层并释放注册管理器资源。
  @override
  void onClose() {
    _dismissCurrentGuide();
    _clearCurrentTaskContext();
    registry.dispose();
    super.onClose();
  }
}

/// 单个页面的运行时引导进度。
///
/// 这个类不对外暴露，只在控制器内部使用。
///
/// 它负责记录：
///
/// - 当前页面对应的页面任务
/// - 当前执行到第几组
/// - 当前执行到组内第几步
/// - 页面当前是否允许开始展示
class _GuidePageProgress {
  /// 创建一份页面运行时进度。
  ///
  /// [task] 是该页面完整的服务端任务结构。
  _GuidePageProgress({
    required this.task,
  });

  /// 当前页面完整的引导任务结构。
  final GuidePageTask task;

  /// 当前执行到的分组索引。
  int groupIndex = 0;

  /// 当前执行到的组内步骤索引。
  int guideIndex = 0;

  /// 最近一次完成的 `widgetId`。
  ///
  /// 当前主要用于调试和辅助理解运行时状态。
  String? lastCompletedWidgetId;

  /// 当前分组是否至少成功引导过一个可用目标。
  ///
  /// 只有命中过真实挂载的组件并成功进入展示流程后，才允许在分组结束时上报。
  bool hasGuidedWidgetInCurrentGroup = false;

  /// 当前页面是否允许开始展示引导。
  ///
  /// 只有页面显式调用 `start(pageCode)` 或 `continueGuide(pageCode, widgetId)`
  /// 后，才会被置为 `true`。
  bool isReadyToStart = false;

  /// 当前是否正在上报某个分组。
  ///
  /// 用于拦截同一时刻的重复进入，避免并发调用同一个分组的上报逻辑。
  String? reportingGroupKey;

  /// 当前页面任务里最近一次已完成上报的分组 key。
  ///
  /// 用于拦截串行链路里的重复上报，例如某个分组刚在 `completeGuide`
  /// 中上报完，后续流程又进入 `_completeCurrentGroup`。
  String? lastReportedGroupKey;

  /// 当前页面引导是否被用户手动中断。
  ///
  /// 只要用户调用 `stop()` 关闭了引导，后续异步回调里的 `continueGuide`
  /// 都应该直接失效，直到页面再次显式 `start(pageCode)`。
  bool isInterrupted = false;

  /// 当前页面任务是否已经全部执行完成。
  bool get isFinished => groupIndex >= (task.guideGroups?.length??0);

  /// 当前正在执行的分组。
  ///
  /// 如果页面已经全部结束，则返回 `null`。
  GuideTaskGroup? get currentGroup {
    if (isFinished) return null;
    return task.guideGroups?[groupIndex];
  }

  /// 将当前页面进度重置回起点。
  ///
  /// 用于用户主动关闭引导后，下次重新从头开始。
  void reset() {
    groupIndex = 0;
    guideIndex = 0;
    lastCompletedWidgetId = null;
    hasGuidedWidgetInCurrentGroup = false;
  }
}

/// 页面任务中的一个逻辑位置。
///
/// 用来表示“某个 `widgetId` 在第几组、第几步”。
class _GuidePosition {
  /// 创建一个逻辑位置对象。
  const _GuidePosition({
    required this.groupIndex,
    required this.guideIndex,
  });

  /// 所在分组索引。
  final int groupIndex;

  /// 所在步骤索引。
  final int guideIndex;
}
