# 任务中心解锁弹窗接入说明

## 背景

任务中心每日任务页的“当前学习单元”面板，展示的数据来自：

- `MissionRequest.getCurrentCoursePlanInfoList()`
- 接口：`/studies/member/course/plan/current/course/info/list`

这份数据适合做状态展示，比如：

- `isNotStarted`
- `isNormalLearning`
- `isCompleted`
- `isAutoUnlock`
- `isPaused`

但 `StudyPlanUnlockDialog.showUnlock(...)` 不是只靠课程状态就能弹出。它还依赖学习计划接口中的阶段数据：

- `planPathCourses[].steps`
- `planPathCourses[].canShowIndex`
- `assessmentId`

因此，解锁弹窗的真实触发源仍然是学习计划接口 `StudyPlanRequest.getPlanData()`。

## 触发规则

任务中心接入后，弹窗遵循和学习计划页一致的规则：

1. 拉取当前学习单元列表，得到当前页面展示的课程。
2. 在每日任务页可见时，再拉取 `StudyPlanRequest.getPlanData()`。
3. 遍历 `planPathCourses`，只处理当前学习单元中存在的课程。
4. 找到第一个 `canShowIndex > 0` 的课程。
5. 用 `steps[canShowIndex - 1]` 取出对应阶段，调用 `StudyPlanUnlockDialog.showUnlock(...)`。
6. 本地将该课程的 `canShowIndex` 置为 `0`，并记录本次已处理 key，避免当前控制器生命周期内重复弹出。
7. 关闭后继续检查下一个可弹课程。

## 为什么不能只看 execute

`currentCoursePlanList` 中的 `execute` 只表示课程当前状态，不表示“本次进入页面需要弹一次解锁弹窗”。

例如：

- `execute == 10` 只能说明当前课程处于自动解锁/暂停类状态。
- 真正控制是否应该弹窗的是学习计划接口中的 `canShowIndex`。

如果只按 `execute` 弹窗，用户重复进入任务中心时可能会反复弹出。

## 接入点

本次接入放在 `MissionControlCenterController` 中，核心位置如下：

- `getTaskMission()`
  - 每日任务与当前学习单元数据加载完成后，调度一次解锁弹窗检测。
- `_changeBottomTab()`
  - 当用户切换到“每日任务”tab 时，再次调度检测，解决首页默认停留在其它 tab、每日任务被后台预加载时的漏弹问题。
- `_showCurrentCourseUnlockDialogsIfNeeded()`
  - 统一处理拉取学习计划数据、筛选当前学习单元、顺序弹窗和防重逻辑。

## 防重策略

为了避免重复弹出，控制器增加了两层保护：

1. `_isShowingCurrentCourseUnlockDialog`
   - 防止同一时刻并发进入弹窗流程。
2. `_handledCurrentCourseUnlockKeys`
   - 记录 `courseId_canShowIndex`，避免同一控制器生命周期内重复处理同一个解锁事件。

此外，弹窗组件内部仍会调用：

- `StudyPlanRequest.updateUnlockPlanShowStatus(...)`

用于通知服务端该解锁弹窗已经展示过。

## 涉及文件

- `lib/app/modules/mission_control_center/controllers/mission_control_center_controller.dart`
- `lib/app/modules/study_plan/controllers/study_plan_controller.dart`
- `lib/common/widgets/study_plan_widgets/study_plan_unlock_dialog.dart`

## 后续建议

如果后面学习计划页和任务中心都要继续复用这套逻辑，建议再把“查找下一个可弹解锁项”的逻辑抽成公共 helper，避免两边规则出现漂移。
