import 'dart:async';
import 'package:api/entities/response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/activity_console_task.dart';
import 'package:langwise/common/entities/activity_console_task_complete_entity.dart';
import 'package:langwise/common/entities/activity_console_task_entities.dart';
import 'package:langwise/common/widgets/guide_engine/guide_model.dart';
import 'package:langwise/common/widgets/guide_engine/guide_overlay.dart';
import 'package:langwise/common/widgets/task_reward_dialog.dart';

class GuideManager {
  static final GuideManager instance = GuideManager._internal();
  static const String taskListEntryAnchorId = 'task_list_entry';
  GuideManager._internal() {
    tasks.addAll([]);
  }

  /// 检查指定的锚点控件是否可见
  /// 验证条件：context存在、RenderObject已附加、有尺寸、透明度大于0.001
  // bool _isAnchorVisible(GlobalKey key) {
  //   final ctx = key.currentContext;
  //   if (ctx == null) return false;

  //   final ro = ctx.findRenderObject();
  //   if (ro == null || !ro.attached) return false;
  //   if (ro is RenderBox) {
  //     if (!ro.hasSize) return false;
  //     if (ro.size.isEmpty) return false;
  //   }

  //   final opacity = ctx.findAncestorRenderObjectOfType<RenderOpacity>();
  //   if (opacity != null && opacity.opacity <= 0.001) return false;

  //   return true;
  // }

  /// 调试日志输出，仅在debug模式下打印
  void _log(String message) {
    if (!kDebugMode) return;
    debugPrint('[GuideManager] $message');
  }

  String? _taskGroupName;
  String? _taskGroupDescription;

  String? get taskGroupName => _taskGroupName;
  String? get taskGroupDescription => _taskGroupDescription;

  ///黑名单页面，在这些页面不会主动进行下一步任务
  final Set<String> _blockedAutoStartRoutes = <String>{
    Routes.PRACTICE_QUESTIONS_EVAL,
    Routes.PRACTICE_QUESTIONS,
    Routes.OFFICIAL_COURSE_DETAILS_PREVIEW,
    // Routes.MISSION_COMPLETE,
    Routes.MISSION_SPECIAL,
    Routes.SONG_MV,
    Routes.LISTEN_AND_READ
  };

  bool _pendingPushPrompt = false;

  final List<String> _pendingStartTaskIds = <String>[];
  String? _lastRoute;

  final RxInt refreshTick = 0.obs;

  final RxnString taskListPromptTaskId = RxnString();
  String? _lastPromptTaskId;

  bool _taskListPromptScheduled = false;
  String? _scheduledPromptTaskId;

  String? _pendingEntryHighlightTaskId;
  String? get pendingEntryHighlightTaskId => _pendingEntryHighlightTaskId;

  /// 清除所有任务状态，重置锁定任务ID并清空任务列表
  void clearTask() {
    _lockedTaskId = null;
    tasks.clear();
    _notifyChanged();
  }

  /// 通知状态变更，触发UI刷新
  void _notifyChanged() {
    refreshTick.value++;
  }

  /// 发送任务列表提示事件
  /// [taskId] 任务ID
  /// [force] 是否强制发送（忽略重复检查）
  void emitTaskListPrompt(String taskId, {bool force = false}) {
    if (taskId.trim().isEmpty) return;
    if (!force && _lastPromptTaskId == taskId) return;
    _lastPromptTaskId = taskId;
    _log('emitTaskListPrompt taskId=$taskId force=$force route=${Get.currentRoute}');
    taskListPromptTaskId.value = null;
    taskListPromptTaskId.value = taskId;
  }

  /// 消费（清除）任务列表提示
  void consumeTaskListPrompt(String taskId) {
    if (taskListPromptTaskId.value != taskId) return;
    _log('consumeTaskListPrompt taskId=$taskId route=${Get.currentRoute}');
    taskListPromptTaskId.value = null;
  }

  /// 尝试调度任务列表提示，防止重复调度
  /// 返回true表示调度成功，false表示已有相同任务在调度中
  bool tryScheduleTaskListPrompt(String taskId) {
    if (taskId.trim().isEmpty) return false;
    if (_taskListPromptScheduled && _scheduledPromptTaskId == taskId) return false;
    _taskListPromptScheduled = true;
    _scheduledPromptTaskId = taskId;
    return true;
  }

  /// 完成任务列表提示调度，清除调度状态
  void finishScheduleTaskListPrompt(String taskId) {
    if (_scheduledPromptTaskId != taskId) return;
    _taskListPromptScheduled = false;
    _scheduledPromptTaskId = null;
  }

  /// 显示任务列表入口引导
  /// 在APPLICATION页面高亮任务列表入口按钮，引导用户点击
  Future<void> showTaskListEntryGuide(String taskId) async {
    if (taskId.trim().isEmpty) return;
    if (_lockedTask() != null) return;
    final context = Get.overlayContext;
    if (context == null) return;
    if (Get.currentRoute != Routes.APPLICATION) return;

    _pendingEntryHighlightTaskId = taskId;
    _log('showTaskListEntryGuide taskId=$taskId anchor=$taskListEntryAnchorId overlayShowing=$_overlayShowing');

    if (_overlayShowing) {
      GuideOverlay.hide();
      _overlayShowing = false;
      _notifyChanged();
    }

    await _waitForAnchor(taskListEntryAnchorId);
    final key = get(taskListEntryAnchorId);
    if (key == null || key.currentContext == null) return;
    await _ensureTargetVisible(key);
    if (key.currentContext == null) return;

    _overlayShowing = true;
    _notifyChanged();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GuideOverlay.showGuide(
        context,
        key,
        title: '新手任务',
        tip: '点击打开任务列表，继续完成任务',
        canSkip: false,
        homeGuide: true,
        allowPenetration: false,
        lockTargetInViewport: true,
        onTargetTap: () {
          _log('showTaskListEntryGuide onTargetTap taskId=$taskId');
          GuideOverlay.hide();
          _overlayShowing = false;
          _notifyChanged();
          final action = getAction(taskListEntryAnchorId);
          if (action != null) {
            action();
          }
          consumeTaskListPrompt(taskId);
          if (_pendingEntryHighlightTaskId == taskId) {
            _pendingEntryHighlightTaskId = null;
          }
        },
      );
    });
  }

  /// 强制显示任务列表入口引导（简化版）
  /// 只判断是否有未完成任务，不检查 lockedTask、路由等前置条件
  /// 适用于完成某个步骤后手动调起首页遮罩
  Future<void> forceShowTaskListEntryGuide() async {
    final uncompleted = tasks.where((t) => !t.isDone);
    if (uncompleted.isEmpty) return;

    final nextTaskId = uncompleted.first.taskId;
    final context = Get.overlayContext;
    if (context == null) return;

    _pendingEntryHighlightTaskId = nextTaskId;
    _log('forceShowTaskListEntryGuide nextTaskId=$nextTaskId');

    if (_overlayShowing) {
      GuideOverlay.hide();
      _overlayShowing = false;
      _notifyChanged();
    }

    await _waitForAnchor(taskListEntryAnchorId);
    final key = get(taskListEntryAnchorId);
    if (key == null || key.currentContext == null) return;
    await _ensureTargetVisible(key);
    if (key.currentContext == null) return;

    _overlayShowing = true;
    _notifyChanged();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GuideOverlay.showGuide(
        context,
        key,
        title: '新手任务',
        tip: '点击打开任务列表，继续完成任务',
        canSkip: false,
        homeGuide: true,
        allowPenetration: false,
        lockTargetInViewport: true,
        onTargetTap: () {
          _log('forceShowTaskListEntryGuide onTargetTap taskId=$nextTaskId');
          GuideOverlay.hide();
          _overlayShowing = false;
          _notifyChanged();
          final action = getAction(taskListEntryAnchorId);
          if (action != null) {
            action();
          }
          consumeTaskListPrompt(nextTaskId);
          if (_pendingEntryHighlightTaskId == nextTaskId) {
            _pendingEntryHighlightTaskId = null;
          }
        },
      );
    });
  }

  // 记录所有带 ID 的控件 Key
  final Map<String, GlobalKey> _registeredWidgets = {};

  final Map<String, ({Object token, VoidCallback action})> _registeredActions = {};

  /// 注册引导锚点控件
  /// [id] 控件唯一标识
  /// [key] 控件的GlobalKey
  void register(String id, GlobalKey key) {
    _registeredWidgets[id] = key;
  }

  /// 注销引导锚点控件
  /// 仅当传入的key与已注册的key相同时才移除
  void unregister(String id, GlobalKey key) {
    final existing = _registeredWidgets[id];
    if (existing == null) return;
    if (!identical(existing, key)) return;
    _registeredWidgets.remove(id);
  }

  /// 注册锚点关联的动作回调
  /// [token] 用于标识注册者，确保只有注册者才能注销
  void registerAction(String id, VoidCallback action, {required Object token}) {
    _registeredActions[id] = (token: token, action: action);
  }

  /// 注销锚点关联的动作回调
  /// 仅当token匹配时才移除
  void unregisterAction(String id, {required Object token}) {
    final existing = _registeredActions[id];
    if (existing == null) return;
    if (!identical(existing.token, token)) return;
    _registeredActions.remove(id);
  }

  /// 获取已注册的锚点GlobalKey
  /// 同时验证context和RenderObject是否有效，无效则自动清理
  GlobalKey? get(String id) {
    final key = _registeredWidgets[id];
    if (key == null) return null;
    final ctx = key.currentContext;
    if (ctx == null) {
      _registeredWidgets.remove(id);
      return null;
    }
    final renderObject = ctx.findRenderObject();
    if (renderObject is RenderBox && !renderObject.attached) {
      _registeredWidgets.remove(id);
      return null;
    }
    return key;
  }

  /// 获取锚点关联的动作回调
  VoidCallback? getAction(String id) => _registeredActions[id]?.action;

  bool _overlayShowing = false;
  bool _showing = false;

  String? _pendingManualTaskId;
  String? _pendingManualStepId;

  bool get overlayShowing => _overlayShowing;

  bool get isGuiding => _overlayShowing || _showing;

  String? _activeTaskId;

  String? _lockedTaskId;

  final Map<String, ({int stepIndex, ActivityConsoleTaskStatus status, List<GuideStep> steps})> _repeatSnapshots =
      <String, ({int stepIndex, ActivityConsoleTaskStatus status, List<GuideStep> steps})>{};

  /// 确保任务列表已加载
  Future<void> _ensureTasksLoaded() async {
    await loadRemoteTasks();
  }

  String get currentTaskId => _lockedTaskId ?? _activeTaskId ?? '';

  /// 从服务端获取任务列表
  /// 支持分组和平铺两种数据结构，按order排序后映射为本地UserTask
  Future<void> loadRemoteTasks() async {
    try {
      _log('loadRemoteTasks begin');
      final res = await ActivityConsoleTaskRequest.userTaskList();
      final data = res?.data;
      if (data == null) {
        _log('loadRemoteTasks data=null');
        return;
      }

      final groups = data.groups;
      if (groups != null && groups.isNotEmpty) {
        final nonEmpty = groups.where((g) => (g.userTasks?.isNotEmpty ?? false)).toList();
        if (nonEmpty.isEmpty) return;

        nonEmpty.sort((a, b) {
          final ao = a.order ?? 0;
          final bo = b.order ?? 0;
          return ao.compareTo(bo);
        });
        final firstGroup = nonEmpty.first;
        _taskGroupName = firstGroup.name;
        _taskGroupDescription = firstGroup.description;

        final flat = <ActivityConsoleTaskItem>[];
        for (final g in nonEmpty) {
          final items = g.userTasks;
          if (items == null || items.isEmpty) continue;
          flat.addAll(items);
        }

        final mapped = flat.map(_mapRemoteTask).whereType<UserTask>().toList();
        if (mapped.isEmpty) {
          _log('loadRemoteTasks mapped empty (groups)');
          return;
        }

        tasks
          ..clear()
          ..addAll(mapped);
        _log('loadRemoteTasks done (groups) count=${tasks.length}');
        _notifyChanged();
        return;
      }

      final list = data.list;
      if (list == null || list.isEmpty) return;
      _taskGroupName = null;
      _taskGroupDescription = null;

      final mapped = list.map(_mapRemoteTask).whereType<UserTask>().toList();
      if (mapped.isEmpty) {
        _log('loadRemoteTasks mapped empty (list)');
        return;
      }

      tasks
        ..clear()
        ..addAll(mapped);
      _log('loadRemoteTasks done (list) count=${tasks.length}');
      _notifyChanged();
    } catch (e) {
      _log('loadRemoteTasks error=$e');
      return;
    }
  }

  /// 验证远程任务步骤的有效性
  /// 检查路由和锚点是否在本地manifest中定义
  // List<_InvalidGuideStep> _validateRemoteTaskSteps(List<ActivityConsoleTaskItem> list) {
  //   final validRoutes = GuideManifest.routes.toSet();
  //   const anchorsByRoute = GuideManifest.anchorsByRoute;
  //   final invalid = <_InvalidGuideStep>[];

  //   for (final task in list) {
  //     final taskCode = (task.taskCode ?? '').trim();
  //     final rawSteps = task.steps ?? const <ActivityConsoleTaskStep>[];
  //     for (final s in rawSteps) {
  //       final stepCode = (s.stepCode ?? '').trim();
  //       final path = (s.path ?? '').trim();
  //       final widgetId = (s.widgetId ?? '').trim();

  //       if (path.isEmpty || widgetId.isEmpty) {
  //         invalid.add(
  //           _InvalidGuideStep(
  //             taskCode: taskCode,
  //             stepCode: stepCode,
  //             path: path,
  //             widgetId: widgetId,
  //             reason: 'missing_required',
  //           ),
  //         );
  //         continue;
  //       }

  //       if (!validRoutes.contains(path)) {
  //         invalid.add(
  //           _InvalidGuideStep(
  //             taskCode: taskCode,
  //             stepCode: stepCode,
  //             path: path,
  //             widgetId: widgetId,
  //             reason: 'invalid_route',
  //           ),
  //         );
  //         continue;
  //       }

  //       final validAnchors = anchorsByRoute[path] ?? const <String>[];
  //       if (!validAnchors.contains(widgetId)) {
  //         invalid.add(
  //           _InvalidGuideStep(
  //             taskCode: taskCode,
  //             stepCode: stepCode,
  //             path: path,
  //             widgetId: widgetId,
  //             reason: 'invalid_anchor',
  //           ),
  //         );
  //         continue;
  //       }
  //     }
  //   }
  //   return invalid;
  // }

  /// UI就绪后的初始化回调
  /// 加载任务并在APPLICATION页面触发任务提示
  Future<void> onUiReady() async {
    await _ensureTasksLoaded();

    if (_isApplicationRoute(Get.currentRoute) && _lockedTask() == null) {
      final next = _pickNextTaskByStrongAndPriority();
      if (next != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          emitTaskListPrompt(next.taskId);
        });
      }
    }
  }

  /// 判断是否为应用主页面路由（APPLICATION/SPLASH/SIGN_IN_UP）
  bool _isApplicationRoute(String routeName) {
    return _normalizeRouteName(routeName) == _normalizeRouteName(Routes.APPLICATION) ||
        _normalizeRouteName(routeName) == _normalizeRouteName(Routes.SPLASH) ||
        _normalizeRouteName(routeName) == _normalizeRouteName(Routes.SIGN_IN_UP);
  }

  /// 推送触发的任务启动方法
  /// 检查是否需要延迟启动，否则导航到APPLICATION并触发任务提示
  Future<void> pushMethod() async {
    await _ensureTasksLoaded();

    final route = Get.currentRoute;
    if (_shouldDelayAutoStartForRoute(route)) {
      _pendingPushPrompt = true;
      return;
    }

    final next = _pickNextTaskByStrongAndPriority();
    final locked = _lockedTask();
    if (locked != null && next != null && locked.taskId != next.taskId) {
      _pendingPushPrompt = true;
      return;
    }
    if (next != null) {
      if (Get.currentRoute != Routes.APPLICATION) {
        final hasLevel = AppPages.history.contains(Routes.APPLICATION);
        _log("路由历史:${AppPages.history}");
        if (hasLevel) {
          Get.until((route) => route.settings.name == Routes.APPLICATION);
        } else {
          Get.offAllNamed(Routes.APPLICATION);
        }
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        emitTaskListPrompt(next.taskId, force: true);
      });
    }
  }

  /// 刷新待处理的推送提示（如果有）
  Future<void> _flushPendingPushPromptIfAny() async {
    if (!_pendingPushPrompt) return;
    _pendingPushPrompt = false;
    await pushMethod();
  }

  /// 将远程任务数据映射为本地UserTask对象
  /// 解析步骤、状态、奖励等信息
  UserTask? _mapRemoteTask(ActivityConsoleTaskItem item) {
    final taskCode = item.taskCode;
    if (taskCode == null || taskCode.isEmpty) return null;

    final taskName = (item.name ?? '').trim();
    final taskDescription = '';

    // if (!item.shouldTrigger) return null;

    final rawSteps = item.steps ?? <ActivityConsoleTaskStep>[];
    if (rawSteps.isEmpty) return null;
    rawSteps.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    final steps = <GuideStep>[];
    for (int i = 0; i < rawSteps.length; i++) {
      final s = rawSteps[i];
      final path = s.path;
      final widgetId = s.widgetId;
      final name = s.name;
      if (path == null || path.isEmpty) continue;
      // if (widgetId == null || widgetId.isEmpty) continue;
      if (name == null || name.isEmpty) continue;

      steps.add(
        GuideStep(
          stepId: (s.stepCode?.isNotEmpty == true) ? s.stepCode! : '${s.order ?? (i + 1)}',
          pagePath: path,
          pathParams: s.pathParams,
          widgetId: widgetId??"",
          tipTitle: name,
          guideText: s.guideText ?? '',
          stepMode: item.stepMode,
          roleKey: s.ruleKey ?? '',
          autoAdvance: true,
          autoComplete: s.autoComplete ?? false,
          deferComplete: s.deferComplete ?? false,
          canSkip: false,
          tipOnly: s.tipOnly ?? false,
          status: s.statusEnum,
        ),
      );
    }

    if (steps.isEmpty) return null;

    final remoteStatus = item.statusEnum;
    int initialStepIndex = 0;
    if (remoteStatus == ActivityConsoleTaskStatus.IN_PROGRESS) {
      final idx = rawSteps.indexWhere((e) {
        final s = e.statusEnum;
        return s != ActivityConsoleTaskStepStatus.COMPLETED && s != ActivityConsoleTaskStepStatus.EXPIRED;
      });
      initialStepIndex = (idx == -1) ? 0 : idx;
    }

    final isStrong = item.isStrongHint == true;
    final priority = (item.priority ?? 0);

    return UserTask(
        taskId: taskCode,
        title: taskName.isEmpty ? taskCode : taskName,
        description: taskDescription,
        stepMode: item.stepMode,
        priority: priority,
        isStrongHint: isStrong,
        banTxt: item.banTitle ?? '',
        steps: steps,
        finishReward: item.taskPrizes == null
            ? null
            : TaskReward(
                amount: item.taskPrizes!.first.value ?? 0,
                description: item.taskPrizes!.first.priceName!,
                values: item.taskPrizes!.first.values?.join(','),
                isSend: item.taskPrizes!.first.isSend,
                type: item.taskPrizes!.first.type),
        currentStepIndex: initialStepIndex.clamp(0, steps.length - 1),
        status: remoteStatus,
        canRepeat: true);
  }

  /// 根据任务ID获取任务对象
  UserTask? _getTaskById(String? taskId) {
    if (taskId == null) return null;
    for (final t in tasks) {
      if (t.taskId == taskId) return t;
    }
    return null;
  }

  /// 为指定路由选择最合适的任务
  /// 筛选当前步骤页面匹配的未完成非禁用任务，按优先级排序
  // UserTask? _pickTaskForRoute(String routeName) {
  //   final candidates = tasks.where((t) => !t.isDone).where((t) => t.status != ActivityConsoleTaskStatus.BAN).where((t) => t.currentStep?.pagePath == routeName).toList();
  //   if (candidates.isEmpty) return null;
  //   candidates.sort(_compareTask);
  //   return candidates.first;
  // }

  /// 设置当前活动任务
  void _setActiveTask(UserTask? task) {
    _activeTaskId = task?.taskId;
  }

  UserTask? get activeTask => _getTaskById(_activeTaskId);

  bool get hasLockedTask => _lockedTask() != null;

  /// 获取当前锁定的任务（用户正在执行的任务）
  /// 如果任务已完成则返回null
  UserTask? _lockedTask() {
    final locked = _lockedTaskId;
    if (locked == null || locked.isEmpty) return null;
    final t = _getTaskById(locked);
    if (t == null) return null;
    if (t.isDone) return null;
    return t;
  }

  /// 任务比较器，用于排序
  /// 优先级：强提示 > priority > 当前步骤索引 > taskId
  int _compareTask(UserTask a, UserTask b) {
    final sa = a.isStrongHint ? 0 : 1;
    final sb = b.isStrongHint ? 0 : 1;
    final s = sa.compareTo(sb);
    if (s != 0) return s;
    final p = a.priority.compareTo(b.priority);
    if (p != 0) return p;
    final si = a.currentStepIndex.compareTo(b.currentStepIndex);
    if (si != 0) return si;
    return a.taskId.compareTo(b.taskId);
  }

  /// 按强提示和优先级选择下一个任务
  /// [onlyRoute] 可选，仅筛选指定路由的任务
  UserTask? _pickNextTaskByStrongAndPriority({String? onlyRoute}) {
    Iterable<UserTask> candidates = tasks.where((t) => !t.isDone).where((t) => t.status != ActivityConsoleTaskStatus.BAN);
    if (onlyRoute != null) {
      candidates = candidates.where((t) => t.currentStep?.pagePath == onlyRoute);
    }
    final list = candidates.toList();
    if (list.isEmpty) return null;
    list.sort(_compareTask);
    return list.first;
  }

  /// 选择第一个待处理的非禁用任务
  UserTask? _pickFirstPendingNonBanTask() {
    final candidates = tasks.where((t) => !t.isDone).where((t) => t.status != ActivityConsoleTaskStatus.BAN).toList();
    if (candidates.isEmpty) return null;
    candidates.sort(_compareTask);
    return candidates.first;
  }

  /// 判断任务是否被禁用
  bool _isTaskBanned(UserTask task) {
    return task.status == ActivityConsoleTaskStatus.BAN;
  }

  /// 判断指定路由是否应延迟自动启动任务
  /// 黑名单路由（如练习题、歌曲MV等）不会自动启动任务
  bool _shouldDelayAutoStartForRoute(String routeName) {
    if (routeName.isEmpty) return false;
    final normalized = _normalizeRouteName(routeName);
    for (final blocked in _blockedAutoStartRoutes) {
      final blockedNormalized = _normalizeRouteName(blocked);
      if (normalized == blockedNormalized) return true;
      if (normalized.startsWith('$blockedNormalized/')) return true;
    }
    return false;
  }

  /// 标准化路由名称
  /// 移除查询参数、hash、尾部斜杠和开头斜杠
  String _normalizeRouteName(String routeName) {
    var v = routeName.trim();
    final q = v.indexOf('?');
    if (q != -1) v = v.substring(0, q);
    final hash = v.indexOf('#');
    if (hash != -1) v = v.substring(0, hash);
    if (v.length > 1 && v.endsWith('/')) v = v.substring(0, v.length - 1);
    if (v.startsWith('/')) v = v.substring(1);
    return v;
  }

  /// 暂存待启动的任务ID（用于延迟启动场景）
  void _stashPendingStartTask(String taskId) {
    if (_pendingStartTaskIds.contains(taskId)) return;
    _pendingStartTaskIds.add(taskId);
  }

  /// 调度启动任务
  /// 检查锁定状态和路由黑名单，决定立即启动或暂存
  Future<void> scheduleStartTask(String taskId) async {
    _log('scheduleStartTask taskId=$taskId route=${Get.currentRoute} locked=${_lockedTaskId ?? ''}');
    final locked = _lockedTask();
    if (locked != null && locked.taskId != taskId) {
      _log('scheduleStartTask stashed (locked=${locked.taskId}) taskId=$taskId');
      _stashPendingStartTask(taskId);
      return;
    }
    final route = Get.currentRoute;
    if (_shouldDelayAutoStartForRoute(route)) {
      _log('scheduleStartTask stashed (blockedRoute=$route) taskId=$taskId');
      _stashPendingStartTask(taskId);
      return;
    }
    _log('scheduleStartTask startTask taskId=$taskId');
    await startTask(taskId);
  }

  /// 刷新所有待启动的任务
  /// 在离开黑名单路由后调用
  Future<void> _flushPendingStartTasksIfAny() async {
    if (_pendingStartTaskIds.isEmpty) return;
    final route = Get.currentRoute;
    if (_shouldDelayAutoStartForRoute(route)) return;

    final toStart = List<String>.from(_pendingStartTaskIds);
    _pendingStartTaskIds.clear();
    _log('flushPendingStartTasks count=${toStart.length} route=$route');
    for (final id in toStart) {
      await scheduleStartTask(id);
    }
  }

  /// 完成当前步骤
  /// 隐藏引导遮罩并标记步骤完成
  Future<void> completeCurrentStep() async {
    final task = activeTask;
    if (task == null) return;

    _log(
        'completeCurrentStep taskId=${task.taskId} stepId=${task.currentStep?.stepId} hasOverlay=$_overlayShowing pendingManualTaskId=${_pendingManualTaskId ?? ''} pendingManualStepId=${_pendingManualStepId ?? ''}');

    final hasOverlay = _overlayShowing;
    final pendingMatches = _pendingManualTaskId == task.taskId && _pendingManualStepId == task.currentStep?.stepId;
    if (!hasOverlay && !pendingMatches) return;

    if (hasOverlay) {
      GuideOverlay.hide();
      _overlayShowing = false;
      _notifyChanged();
    }

    _pendingManualTaskId = null;
    _pendingManualStepId = null;

    await Future<void>.delayed(const Duration(milliseconds: 1));
    await markCurrentStepDone(taskId: task.taskId);
  }

  /// 延迟完成步骤
  /// 由业务代码在弹窗/动画结束后手动调用，用于deferComplete类型的步骤
  Future<void> completeDeferredStep() async {
    final task = activeTask;
    if (task == null) return;
    final step = task.currentStep;
    if (step == null) return;

    _log('completeDeferredStep taskId=${task.taskId} stepId=${step.stepId} deferComplete=${step.deferComplete}');
    if (!step.deferComplete) return;

    if (_overlayShowing) {
      GuideOverlay.hide();
      _overlayShowing = false;
    }

    await markCurrentStepDone(taskId: task.taskId);
  }

  /// 锚点被点击时的回调
  /// 根据步骤配置决定是自动推进还是等待手动完成
  Future<void> onAnchorTapped(String widgetId) async {
    final task = activeTask;
    if (task == null) return;
    final step = task.currentStep;
    if (step == null) return;
    if (step.widgetId != widgetId) return;
    if (!_overlayShowing) return;

    _log('onAnchorTapped taskId=${task.taskId} stepId=${step.stepId} widgetId=$widgetId autoAdvance=${step.autoAdvance} deferComplete=${step.deferComplete}');

    if (!step.autoAdvance) {
      GuideOverlay.hide();
      _overlayShowing = false;
      _notifyChanged();

      _pendingManualTaskId = task.taskId;
      _pendingManualStepId = step.stepId;
      return;
    }

    if (step.deferComplete) {
      GuideOverlay.hide();
      _overlayShowing = false;
      _notifyChanged();
      return;
    }

    await completeCurrentStep();
  }

  /// 启动指定任务
  /// [fromList] 是否从任务列表点击启动
  /// 导航到任务当前步骤的页面并显示引导
  Future<void> startTask(String taskId, {bool fromList = false, int? stepIndex}) async {
    final task = _getTaskById(taskId);
    if (task == null) return;
    if(stepIndex != null){
      task.currentStepIndex = stepIndex;
    }

    _log('startTask taskId=$taskId fromList=$fromList route=${Get.currentRoute}');

    if (_isTaskBanned(task)) {
      return;
    }

    _lockedTaskId = task.taskId;
    _setActiveTask(task);
    _notifyChanged();

    final step = task.currentStep;
    if (step == null) return;

    if (fromList) {
      if (step.autoComplete) {
        await markCurrentStepDone(taskId: _lockedTaskId!);
        if (!task.isDone) {
          await startTask(taskId);
        }
        return;
      }
    }

    if (Get.currentRoute != step.pagePath) {
      _log('startTask navigate from=${Get.currentRoute} to=${step.pagePath}');
      if (step.pagePath == Routes.APPLICATION) {
        Get.until((route) => route.settings.name == Routes.APPLICATION);
      } else {

        // task.finishReward?.

        await Get.toNamed( //OOTD
          step.pagePath,
          arguments: step.pathParams,
        );
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 16));
    _log('startTask tryShowCurrentStep taskId=$taskId');
    await tryShowCurrentStep(ignoreRoute: true, fromList: fromList);
  }

  /// 重新开始任务（重复模式）
  /// 保存当前状态快照，从第一步重新开始
  Future<void> restartTaskRepeat(String taskId, {int index = 0}) async {
    final task = _getTaskById(taskId);
    if (task == null) return;

    if (_isTaskBanned(task)) {
      return;
    }
    if (!task.isDone || !task.canRepeat) return;

    _repeatSnapshots.putIfAbsent(
      taskId,
      () => (stepIndex: task.currentStepIndex, status: task.status, steps: List<GuideStep>.from(task.steps)),
    );
    _lockedTaskId = taskId;
    task.isRepeatMode = true;
    task.steps.removeWhere((s) => s.deferComplete);
    if (task.steps.isEmpty) {
      await stopRepeatTask(taskId);
      return;
    }
    
    if(task.currentStep?.stepMode != "PARALLEL"){
      task.currentStepIndex = 0;
      task.status = ActivityConsoleTaskStatus.IN_PROGRESS;
    }else{
      task.currentStepIndex = index;
    }
    
    _notifyChanged();

    await scheduleStartTask(taskId);
  }

  /// 停止任务重复模式
  /// 恢复之前保存的状态快照
  Future<void> stopRepeatTask(String taskId) async {
    final task = _getTaskById(taskId);
    if (task == null) return;
    if (!task.isRepeatMode) return;

    final snap = _repeatSnapshots.remove(taskId);
    if (snap != null) {
      task.steps
        ..clear()
        ..addAll(snap.steps);
      task.currentStepIndex = snap.stepIndex;
      task.status = snap.status;
    }
    task.isRepeatMode = false;
    _lockedTaskId = null;

    GuideOverlay.hide();
    _overlayShowing = false;
    _activeTaskId = null;
    _notifyChanged();
  }

  final List<UserTask> tasks = <UserTask>[];

  /// 路由变化回调
  /// 处理黑名单路由、锁定任务的引导显示、任务提示触发等
  Future<void> onRouteChanged(String routeName, {bool showGuide = true}) async {
    final prevRoute = _lastRoute;
    _lastRoute = routeName;

    _log('onRouteChanged prev=$prevRoute now=$routeName showGuide=$showGuide locked=${_lockedTaskId ?? ''} overlayShowing=$_overlayShowing showing=$_showing');

    if (_shouldDelayAutoStartForRoute(routeName)) {
      _log('onRouteChanged blockedRoute=$routeName');
      if (_overlayShowing) {
        GuideOverlay.hide();
        _overlayShowing = false;
      }
      _notifyChanged();
      return;
    }

    final leftBlocked = prevRoute != null && _shouldDelayAutoStartForRoute(prevRoute) && !_shouldDelayAutoStartForRoute(routeName);
    if (leftBlocked) {
      _log('onRouteChanged leftBlocked prev=$prevRoute now=$routeName');
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (_shouldDelayAutoStartForRoute(Get.currentRoute)) return;
        await _flushPendingStartTasksIfAny();
        await _flushPendingPushPromptIfAny();

        final locked = _lockedTask();
        if (locked != null) {
          await tryShowCurrentStep(ignoreRoute: true);
        }
      });
    }

    _notifyChanged();

    if (!showGuide) return;

    final locked = _lockedTask();
    if (locked != null) {
      _log('onRouteChanged hasLockedTask taskId=${locked.taskId} stepPage=${locked.currentStep?.pagePath}');
      _setActiveTask(locked);
      _notifyChanged();
      final step = locked.currentStep;
      if (step == null) return;
      if (step.pagePath != routeName) return;
      if (_overlayShowing || _showing) return;
      _log('onRouteChanged showCurrentStep taskId=${locked.taskId} stepId=${step.stepId}');
      await _showCurrentStep();
      return;
    }

    if (routeName == Routes.APPLICATION) {
      final next = _pickFirstPendingNonBanTask();
      if (next != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          emitTaskListPrompt(next.taskId);
        });
      }
    }
  }

  /// 标记当前步骤完成
  /// [skipped] 是否跳过
  /// [isTrouble] 是否遇到问题（强制完成）
  /// 上报服务端、处理奖励弹窗、刷新任务列表
  Future<void> markCurrentStepDone({required String taskId, bool skipped = false, bool isTrouble = false}) async {
    final task = _getTaskById(taskId);
    if (task == null) return;

    final prevStep = task.currentStep;
    if (prevStep == null) return;

    _log('markCurrentStepDone taskId=$taskId stepId=${prevStep.stepId} skipped=$skipped isTrouble=$isTrouble repeat=${task.isRepeatMode} route=${Get.currentRoute}');

    final ruleKey = prevStep.roleKey;
    if (ruleKey.isEmpty) return;

    if (task.isRepeatMode) {
      if (isTrouble) {
        stopRepeatTask(taskId);
        return;
      }
      if (task.currentStepIndex >= task.steps.length - 1) {
        stopRepeatTask(taskId);
        return;
      }
      task.currentStepIndex += 1;
      task.status = ActivityConsoleTaskStatus.IN_PROGRESS;
      if (task.currentStep?.pagePath != Get.currentRoute) {
        await Get.toNamed(task.currentStep!.pagePath);
      }
      _notifyChanged();
    } else {
      late ResponseEntity<ActivityConsoleTaskCompleteDataEntity?>? ok;
      if (isTrouble) {
        ok = await ActivityConsoleTaskRequest.forceCompleteStep(
          taskCode: task.taskId,
        );
      } else {
        ok = await ActivityConsoleTaskRequest.completeStep(
          taskCode: task.taskId,
          eventType: ruleKey,
          stepCode: prevStep.stepId,
        );
      }
      if (ok == null) {
        _log('markCurrentStepDone apiReturn=null taskId=$taskId stepId=${prevStep.stepId}');
        return;
      }
      _log('markCurrentStepDone apiOK taskId=$taskId rewarded=${ok.data?.rewarded == true}');
      prevStep.status = ActivityConsoleTaskStepStatus.IN_PROGRESS;
      final data = ok.data;
      if (data?.rewarded == true && data != null && data.operation.isNotEmpty) {
        ActivityConsoleTaskCompleteOperationEntity op = data.operation.first;
        for (final o in data.operation) { 
          if (o.priceType == 'COUPON') {
            op = o;
            break;
          }
        }

        final copyText = op.values.isNotEmpty ? op.values.first : null;
        final autoCopy = op.priceType == 'COUPON' && copyText != null && copyText.trim().isNotEmpty;

        await TaskRewardDialog.show(
          title: op.title ?? '奖励已发放',
          subtitle: op.description,
          rewardTitle: (op.prizeName?.trim().isNotEmpty == true) ? op.prizeName! : '奖励',
          rewardSubtitle: op.prizeDescription,
          buttonText: '立即领取',
          autoCopy: autoCopy,
          copyText: copyText,
        );
      }

      await loadRemoteTasks();
      final refreshedTask = _getTaskById(taskId);
      if (refreshedTask == null) return;
      _setActiveTask(refreshedTask);
      _notifyChanged();

      _log('markCurrentStepDone refreshed taskId=$taskId status=${refreshedTask.status} stepIndex=${refreshedTask.currentStepIndex} isDone=${refreshedTask.isDone}');

      if (refreshedTask.isDone) {
        _log('markCurrentStepDone taskDone taskId=$taskId locked=${_lockedTaskId ?? ''}');
        if (_lockedTaskId == refreshedTask.taskId) {
          _lockedTaskId = null;
        }

        final next = _pickFirstPendingNonBanTask();
        if (next != null) {
          _log('markCurrentStepDone pickNext taskId=${next.taskId} route=${Get.currentRoute}');
          if (Get.currentRoute != Routes.APPLICATION) {
            Get.until((route) => route.settings.name == Routes.APPLICATION);
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            emitTaskListPrompt(next.taskId, force: true);
          });
        }
        return;
      }
    }

    // final startedStrongHint = await _retriggerStrongHintAfterSubmit();
    // if (startedStrongHint) return;

    final currentRoute = Get.currentRoute;

    final locked = _lockedTask();
    if (locked != null) {
      if (locked.taskId != taskId) return;
      final nextStep = locked.currentStep;
      if (nextStep == null) return;
      if(nextStep.status == ActivityConsoleTaskStepStatus.IN_PROGRESS){
        _lockedTaskId = null;
        _activeTaskId = null;
        _notifyChanged();
      }
      if (nextStep.pagePath == currentRoute && nextStep.status != ActivityConsoleTaskStepStatus.IN_PROGRESS) {
        await _showCurrentStep();
      }
      return;
    }
  }

  /// 重置内存中的任务状态
  /// 将所有任务重置为未开始状态
  Future<void> resetInMemoryState() async {
    for (final t in tasks) {
      t.currentStepIndex = 0;
      t.status = ActivityConsoleTaskStatus.NOT_STARTED;
    }
    GuideOverlay.hide();
    _overlayShowing = false;
    _activeTaskId = null;
    _lockedTaskId = null;
    _notifyChanged();
  }

  /// 尝试显示当前步骤的引导
  /// [ignoreRoute] 是否忽略路由检查
  /// [fromList] 是否从任务列表触发
  Future<void> tryShowCurrentStep({bool ignoreRoute = false, bool fromList = false}) async {
    final routeName = Get.currentRoute;

    _log('tryShowCurrentStep route=$routeName ignoreRoute=$ignoreRoute fromList=$fromList locked=${_lockedTaskId ?? ''}');

    final pendingPrompt = taskListPromptTaskId.value;
    final pendingEntry = _pendingEntryHighlightTaskId;
    if (!fromList && ((pendingPrompt != null && pendingPrompt.trim().isNotEmpty) || (pendingEntry != null && pendingEntry.trim().isNotEmpty))) {
      _log('tryShowCurrentStep suppressed due to pendingTaskListPrompt prompt=${pendingPrompt ?? ''} pendingEntry=${pendingEntry ?? ''}');
      return;
    }

    final locked = _lockedTask();
    if (locked != null) {
      _setActiveTask(locked);
      final step = locked.currentStep;
      if (step == null) return;
      if (step.pagePath != routeName) return;
      if (step.status == ActivityConsoleTaskStepStatus.IN_PROGRESS && !fromList) return;
      _log('tryShowCurrentStep show locked taskId=${locked.taskId} stepId=${step.stepId} widgetId=${step.widgetId}');
      await _showCurrentStep();
    }
    return;

    // final task = _pickNextTaskByStrongAndPriority(onlyRoute: routeName);
    // if (task == null) return;
    // _setActiveTask(task);
    // final step = task.currentStep;
    // if (step == null) return;
    // if (!ignoreRoute && step.pagePath != routeName) return;
    // _log('tryShowCurrentStep show picked taskId=${task.taskId} stepId=${step.stepId} widgetId=${step.widgetId}');
    // await _showCurrentStep();
  }

  /// 显示当前步骤的引导遮罩
  /// 等待锚点出现、滚动到可见区域、显示GuideOverlay
  Future<void> _showCurrentStep() async {
    if (_showing) return;
    final context = Get.overlayContext;
    if (context == null) return;

    final task = activeTask;
    final step = task?.currentStep;
    if (task == null || step == null || step.widgetId.isEmpty) return;

    _log('_showCurrentStep begin taskId=${task.taskId} stepId=${step.stepId} widgetId=${step.widgetId} route=${Get.currentRoute}');

    _showing = true;
    // 插入透明触摸屏障，阻止用户在 showGuide 之前的交互（翻页、点击按钮等）
    final barrier = OverlayEntry(
      builder: (_) => const ModalBarrier(dismissible: false, color: Color(0x00000000)),
    );
    Overlay.of(context).insert(barrier);
    bool barrierScheduledForCallback = false;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 16));
      await _waitForAnchor(step.widgetId);

      final key = get(step.widgetId);
      if (key == null) {
        _log('_showCurrentStep anchorNotFound widgetId=${step.widgetId} taskId=${task.taskId}');
        if (barrier.mounted) barrier.remove();
        if (task.isRepeatMode) {
          await stopRepeatTask(task.taskId);
        } else {
          _activeTaskId = null;
          _lockedTaskId = null;
        }
        return;
      }
      if (key.currentContext == null) return;

      await _ensureTargetVisible(key);
      if (key.currentContext == null) return;

      if (_overlayShowing) {
        GuideOverlay.hide();
        _overlayShowing = false;
        _notifyChanged();
      }

      _overlayShowing = true;
      _notifyChanged();
      barrierScheduledForCallback = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (barrier.mounted) barrier.remove();
        _log('_showCurrentStep showGuide taskId=${task.taskId} stepId=${step.stepId} widgetId=${step.widgetId}');
        final canSkip = task.isRepeatMode ? true : step.canSkip;
        final tipOnly = task.isRepeatMode ? true : step.tipOnly;
        GuideOverlay.showGuide(
          context,
          key,
          title: step.tipTitle,
          tip: step.guideText,
          progressText: '${task.currentStepIndex + 1}/${task.steps.length}',
          canSkip: canSkip,
          onSkip: canSkip
              ? () async {
                  await skipCurrentStep();
                }
              : null,
          allowPenetration: !tipOnly,
          lockTargetInViewport: true,
          onTargetTap: tipOnly
              ? () {
                  onAnchorTapped(step.widgetId);
                }
              : null,
        );
      });
    } finally {
      _showing = false;
      // 仅在提前返回或异常时移除屏障；正常路径由 postFrameCallback 移除
      if (!barrierScheduledForCallback && barrier.mounted) barrier.remove();
      _log('_showCurrentStep end taskId=${task.taskId} stepId=${step.stepId} overlayShowing=$_overlayShowing');
    }
  }

  /// 跳过当前步骤
  /// 重复模式下直接停止，否则标记为跳过完成
  Future<void> skipCurrentStep() async {
    final task = activeTask;
    if (task == null) return;

    _log('skipCurrentStep taskId=${task.taskId} stepId=${task.currentStep?.stepId} repeat=${task.isRepeatMode}');

    if (task.isRepeatMode) {
      await stopRepeatTask(task.taskId);
      return;
    }

    if (_overlayShowing) {
      GuideOverlay.hide();
      _overlayShowing = false;
      _notifyChanged();
    }

    await Future<void>.delayed(const Duration(milliseconds: 1));
    await markCurrentStepDone(taskId: task.taskId, skipped: true);
  }

  /// 确保目标控件在可视区域内
  /// 使用Scrollable.ensureVisible滚动到目标位置
  Future<void> _ensureTargetVisible(GlobalKey key) async {
    final targetContext = key.currentContext;
    if (targetContext == null) return;

    try {
      await Future<void>.delayed(const Duration(milliseconds: 16));
      await Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.2,
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await WidgetsBinding.instance.endOfFrame;
    } catch (_) {
      return;
    }
  }

  /// 等待锚点控件出现
  /// 最多等待约2秒，在轮询过程中持续检查action是否已注册（解决时序问题）
  Future<void> _waitForAnchor(String widgetId) async {
    _log('_waitForAnchor begin widgetId=$widgetId');
    // 首先快速检查锚点是否已存在
    final existingKey = get(widgetId);
    if (existingKey != null && existingKey.currentContext != null) {
      _log('_waitForAnchor anchor already exists widgetId=$widgetId');
      return;
    }

    bool actionExecuted = false;
    
    // 轮询等待锚点出现，最多40次 × 50ms = 2秒
    // 在轮询过程中持续检查action，因为widget可能在_waitForAnchor开始后才挂载
    for (int i = 0; i < 40; i++) {
      // 检查锚点是否已存在
      final key = get(widgetId);
      if (key != null && key.currentContext != null) {
        _log('_waitForAnchor anchor found after polling i=$i widgetId=$widgetId');
        return;
      }
      
      // 如果action还没执行过，尝试获取并执行
      if (!actionExecuted) {
        final action = getAction(widgetId);
        if (action != null) {
          _log('_waitForAnchor action found at i=$i, executing widgetId=$widgetId');
          try {
            action();
            _log('_waitForAnchor action executed widgetId=$widgetId');
          } catch (e) {
            _log('_waitForAnchor action error=$e widgetId=$widgetId');
          }
          actionExecuted = true;
          // action执行后等待UI更新
          await WidgetsBinding.instance.endOfFrame;
          await Future<void>.delayed(const Duration(milliseconds: 100));
          
          // action执行后再次检查
          final keyAfterAction = get(widgetId);
          if (keyAfterAction != null && keyAfterAction.currentContext != null) {
            _log('_waitForAnchor anchor found after action widgetId=$widgetId');
            return;
          }
          continue;
        }
      }
      
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    _log('_waitForAnchor timeout widgetId=$widgetId');
  }
}

// class _InvalidGuideStep {
//   final String taskCode;
//   final String stepCode;
//   final String path;
//   final String widgetId;
//   final String reason;

//   const _InvalidGuideStep({
//     required this.taskCode,
//     required this.stepCode,
//     required this.path,
//     required this.widgetId,
//     required this.reason,
//   });

//   Map<String, dynamic> toJson() {
//     return <String, dynamic>{
//       'taskCode': taskCode,
//       'stepCode': stepCode,
//       'path': path,
//       'widgetId': widgetId,
//       'reason': reason,
//     };
//   }
// }
