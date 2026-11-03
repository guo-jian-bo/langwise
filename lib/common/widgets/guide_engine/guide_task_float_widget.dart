import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/activity_console_task.dart';
import 'package:langwise/common/entities/activity_console_task_prize_detail_entity.dart';
import 'package:langwise/common/entities/activity_console_task_entities.dart';
import 'package:langwise/common/enum/referral_award_enum.dart';
import 'package:langwise/common/widgets/guide_engine/guide_manager.dart';
import 'package:langwise/common/widgets/guide_engine/guide_model.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/common/widgets/task_prize_reward_dialog.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/common.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../stores/stores.dart';
import '../../values/values.dart';

class GuideTaskFloatWidget extends StatefulWidget {
  const GuideTaskFloatWidget({super.key, this.text, this.showRepeat = false});

  final String? text;
  final bool showRepeat;

  static void showTaskListSheet({String? highlightTaskId, bool showRepeat = false}) {
    Get.dialog(
      _GuideTaskListSheet(highlightTaskId: highlightTaskId, showRepeat: showRepeat),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
    );
  }

  @override
  State<GuideTaskFloatWidget> createState() => _GuideTaskFloatWidgetState();
}

class _GuideTaskFloatWidgetState extends State<GuideTaskFloatWidget> {
  bool _appReadyTriggered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_appReadyTriggered) return;
    _appReadyTriggered = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final guideManager = GuideManager.instance;

    return Obx(() {
      guideManager.refreshTick.value;
      return Material(
          color: Colors.transparent,
          child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () {
                GuideTaskFloatWidget.showTaskListSheet(showRepeat: widget.showRepeat);
              },
              child: Container(
                  width: 162.wMin,
                  height: 66.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF93C5FD),
                        Color(0xFF60A5FA),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16.wMin),
                  ),
                  child: Text(
                    widget.text ?? '新手任务',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.wMin,
                      fontWeight: FontWeight.w600,
                    ),
                  ))));
    });
  }
}

class _GuideTaskListSheet extends StatefulWidget {
  final String? highlightTaskId;
  final bool showRepeat;

  const _GuideTaskListSheet({this.highlightTaskId, this.showRepeat = false});

  @override
  State<_GuideTaskListSheet> createState() => __GuideTaskListSheetState();
}

class __GuideTaskListSheetState extends State<_GuideTaskListSheet> {
  bool isChecked = true;

  @override
  void initState() {
    super.initState();

    int? userId = UserStore.to.userInfo.value.userId;
    if(userId != null){
      isChecked = StorageUtil().getBoolNull("${NOVICE_TASK_REMINDER_KEY}_$userId")??true;
    }

    
    
  }

  @override
  Widget build(BuildContext context) {
    final guideManager = GuideManager.instance;
    final groupDescription = (guideManager.taskGroupDescription ?? '').trim();
    final groupName = (guideManager.taskGroupName ?? '').trim();

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        int? userId = UserStore.to.userInfo.value.userId;
        if(userId != null){
           StorageUtil().setBool("${NOVICE_TASK_REMINDER_KEY}_$userId", isChecked);
        }
      },
      child: Center(
        child: Obx(() {
          guideManager.refreshTick.value;
          final tasks = guideManager.tasks;
          final displayTasks = tasks;
      
          return Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 1160.wMin,
                maxHeight: 900.wMin,
              ),
              decoration: BoxDecoration(color: AppTheme.cBgSecondary.color, borderRadius: BorderRadius.circular(40.wMin)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40.wMin),
                  color: AppTheme.cBgSecondary.color,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.cBgBrand.color.withValues(alpha: 0.3),
                      AppTheme.cBgBrand.color.withValues(alpha: 0),
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 24.wMin),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          groupDescription.isNotEmpty ? groupDescription : '免费领取7天 Max会员，10000学点',
                          style: TextStyle(color: AppTheme.cTextBrand, fontSize: 36.wMin, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () async {
                            await GuideManager.instance.loadRemoteTasks();
                          },
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                          ),
                        ),
                        InkWell(onTap: Get.back, child: const Icon(Icons.keyboard_arrow_down, color: Colors.white)),
                      ]),
                      SizedBox(height: 16.wMin),
                      Row(
                        children: [
                          Text(
                            groupName.isNotEmpty ? groupName : '新手指南',
                            style: TextStyle(color: AppTheme.cTextBrand, fontSize: 28.wMin, fontWeight: FontWeight.w400),
                          ),
                          const Spacer(),
                          Text(
                            '${displayTasks.where((t) => t.isDone).length}/${displayTasks.length}',
                            style: TextStyle(color: AppTheme.cTextPrimary.color, fontSize: 24.wMin, fontWeight: FontWeight.w400),
                          )
                        ],
                      ),
                      SizedBox(height: 4.wMin),
                      Row(
                        spacing: 4.wMin,
                        children: List.generate(displayTasks.length, (e) {
                          var t = displayTasks[e];
                          return Expanded(
                            child: Container(
                              height: 12.wMin,
                              decoration: BoxDecoration(
                                  color: t.isDone ? AppTheme.cStaticWhite : AppTheme.cInverseTextLight.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(50.wMin)),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 24.wMin),
                      Expanded(
                        child: _TaskList(
                          tasks: displayTasks,
                          highlightTaskId: widget.highlightTaskId,
                          showRepeat: widget.showRepeat,
                          onStart: (taskId, step) async {
                            Get.back();
                            await guideManager.startTask(taskId, fromList: true, stepIndex: step);
                          },
                          onRepeat: (taskId, step) async {
                            Get.back();
                            await guideManager.restartTaskRepeat(taskId, index: step ?? 0);
                          },
                          onStop: (taskId) async {
                            Get.back();
                            await guideManager.stopRepeatTask(taskId);
                          },
                        ),
                      ),
      
                      SizedBox(height: 24.wMin),
      
                      _buildDoNotRemindAgain(),
      
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }


  Widget _buildDoNotRemindAgain(){
    return Container(
      alignment: Alignment.centerLeft,
      child: TapScaleWidget(
        onTap: () {
          isChecked = !isChecked;
          StorageUtil().setBool(NOVICE_TASK_REMINDER_KEY, isChecked);
          if(mounted) setState(() {});
        },
        sclae: 1,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isChecked ? "assets/svg/public/icon_check_box.svg" : "assets/svg/public/icon_uncheck_box.svg",
              width: 24.wMin,
              height: 24.wMin,
            ),
            SizedBox(width: 8.wMin),
            Text(
              "不再提醒",
              style: TextStyle(
                color: AppTheme.cTextSecondary,
                fontSize: 22.wMin,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }



}

class _TaskList extends StatefulWidget {
  final List<UserTask> tasks;
  final String? highlightTaskId;
  final bool showRepeat;
  final Future<void> Function(String taskId, int? step) onStart;
  final Future<void> Function(String taskId, int? step) onRepeat;
  final Future<void> Function(String taskId) onStop;

  const _TaskList({
    required this.tasks,
    this.highlightTaskId,
    this.showRepeat = false,
    required this.onStart,
    required this.onRepeat,
    required this.onStop,
  });

  @override
  State<_TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<_TaskList> {
  String? _expandedTaskId;
  final Map<String, GlobalKey> _taskItemKeys = <String, GlobalKey>{};
  String? _lastScrolledHighlightTaskId;

  @override
  void didUpdateWidget(covariant _TaskList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureDefaultExpanded();
    _maybeScrollToHighlight();
  }

  @override
  void initState() {
    super.initState();
    _ensureDefaultExpanded();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeScrollToHighlight();
    });
  }

  void _maybeScrollToHighlight() {
    final highlight = (widget.highlightTaskId ?? '').trim();
    if (highlight.isEmpty) return;
    if (_lastScrolledHighlightTaskId == highlight) return;

    final key = _taskItemKeys[highlight];
    final ctx = key?.currentContext;
    if (ctx == null) return;

    _lastScrolledHighlightTaskId = highlight;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contextNow = key?.currentContext;
      if (contextNow == null) return;
      Scrollable.ensureVisible(
        contextNow,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
    });
  }

  GlobalKey _keyForTask(String taskId) {
    return _taskItemKeys.putIfAbsent(taskId, () => GlobalKey());
  }

  void _ensureDefaultExpanded() {
    if (_expandedTaskId != null) return;

    final highlight = widget.highlightTaskId;
    if (highlight != null && highlight.trim().isNotEmpty) {
      for (final t in widget.tasks) {
        if (t.taskId == highlight && !t.isDone && t.status != ActivityConsoleTaskStatus.BAN) {
          _expandedTaskId = t.taskId;
          return;
        }
      }
    }

    for (final t in widget.tasks) {
      if (!t.isDone && t.status != ActivityConsoleTaskStatus.BAN) {
        _expandedTaskId = t.taskId;
        return;
      }
    }
  }

  //todo:任务奖励信息弹窗
  void showPrizeDetail(String taskId) {
    final ctx = context;
    ActivityConsoleTaskRequest.loadUserTaskPrize(taskCode: taskId).then((res) async {
      final list = res?.data?.list ?? const <TaskItem>[];
      if (list.isEmpty) return;
      await TaskPrizeRewardDialog.show(context: ctx, items: list);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasks = widget.tasks;
    return ListView.separated(
      shrinkWrap: true,
      itemCount: tasks.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.wMin),
      itemBuilder: (context, index) {
        final task = tasks[index];

        TaskReward? reward = task.finishReward;
        if (reward == null) {}

        final banned = task.status == ActivityConsoleTaskStatus.BAN;

        final taskId = task.taskId;
        final expanded = _expandedTaskId == taskId;
        final done = task.isDone;
        final canRepeat = task.canRepeat;

        final highlighted = (widget.highlightTaskId ?? '').trim().isNotEmpty && widget.highlightTaskId == taskId && !done && !banned;

        final title = task.title.isNotEmpty ? task.title : taskId;
        final description = task.description;
        final subTitle = task.subTitle;

        // VoidCallback? onAction;
        // if (banned) {
        //   onAction = null;
        // } else if (done && canRepeat && widget.showRepeat) {
        //   onAction = () => widget.onRepeat(taskId, index);
        // } else if (highlighted) {
        //   onAction = () => widget.onStart(taskId);
        // } else {
        //   onAction = () => widget.onStart(taskId);
        // }

        final badgeText = '${index + 1}';

        String image = "";
        if (task.finishReward?.type == ReferralAwardTypeEnum.POINTS.value) {
          image = "assets/images/public/icon_learn_point.png";
        } else if (task.finishReward?.type == ReferralAwardTypeEnum.CREDIT.value) {
          image = "assets/images/public/icon_nai_coin.png";
        } else if (task.finishReward?.type == ReferralAwardTypeEnum.PLUS_VIP.value) {
          image = "assets/images/public/icon_plus_s.png";
        } else if (task.finishReward?.type == ReferralAwardTypeEnum.PRO_VIP.value) {
          image = "assets/images/public/icon_pro_s.png";
        } else if (task.finishReward?.type == ReferralAwardTypeEnum.MAX_VIP.value) {
          image = "assets/images/public/icon_max_s.png";
        }

        return GestureDetector(
            onTap: banned
                ? () {
                    ToastUtils.showToast(text: "任务未解锁,解锁条件:${task.banTxt}");
                  }
                : () {
                    setState(() {
                      _expandedTaskId = expanded ? null : taskId;
                    });
                  },
            child: Container(
                key: _keyForTask(taskId),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.wMin),
                  border: Border.all(color: expanded ? const Color(0x660EA5E9) : Colors.transparent, width: 2.wMin),
                  color: expanded ? AppTheme.cSurfaceSecondary : const Color(0x26FFFFFF),
                ),
                padding: EdgeInsets.all(22.wMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 38.wMin,
                          height: 38.wMin,
                          decoration: BoxDecoration(
                            color: expanded ? AppTheme.cSurfaceInfo : Colors.transparent,
                            border: expanded
                                ? Border.all(width: 4.wMin, strokeAlign: BorderSide.strokeAlignOutside, color: const Color(0x3338BDF8))
                                : Border.all(color: AppTheme.cTextPrimary, width: 2.wMin, strokeAlign: BorderSide.strokeAlignOutside),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          alignment: Alignment.center,
                          child: AutoSizeText(
                            badgeText,
                            minFontSize: 6,
                            style: TextStyle(
                              color: expanded ? AppTheme.cInverseTextLight : AppTheme.cTextPrimary,
                              fontSize: 22.wMin,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 24.wMin),
                        Expanded(
                          flex: 2,
                          child: Text(
                            title,
                            style: TextStyle(color: expanded ? AppTheme.cTextBrand : AppTheme.cTextPrimary, fontSize: 28.wMin, fontWeight: FontWeight.w500),
                          ),
                        ),
                        if (task.finishReward != null)
                          Expanded(
                              flex: 3,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 24.wMin),
                                  if (image.isNotEmpty)
                                    Row(
                                      children: [
                                        Image.asset(image, width: 36.wMin, height: 36.wMin),
                                        SizedBox(width: 8.wMin),
                                        Text(
                                          "+${task.finishReward?.amount}",
                                          style: TextStyle(color: AppTheme.cTextSecondary, fontSize: 28.wMin, fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(width: 8.wMin),
                                      ],
                                    ),
                                  TapScaleWidget(
                                    onTap: () {
                                      if (!(task.finishReward?.isSend ?? false)) return;
                                      showPrizeDetail(taskId);
                                    },
                                    sclae: 1.03,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                                      height: 44.wMin,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: (task.finishReward?.isSend ?? false) ? AppTheme.cBgBrand.color : AppTheme.cSurfaceQuaternary.color,
                                        borderRadius: BorderRadius.circular(8.wMin),
                                      ),
                                      child: Text(
                                        (task.finishReward?.isSend ?? false) ? (task.finishReward?.isCoupon??false ? '查看兑换码' : '发放详情') : '未完成',
                                        style: TextStyle(
                                          color: (task.finishReward?.isSend ?? false) ? AppTheme.cInverseTextLight : AppTheme.cTextPrimary,
                                          fontSize: 24.wMin,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (widget.showRepeat && done && canRepeat && !banned && task.stepMode != "PARALLEL")
                                GestureDetector(
                                  onTap: () {
                                    widget.onRepeat(taskId, 0);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.wMin), border: Border.all(color: Color(0x66FFFFFF))),
                                    padding: EdgeInsets.symmetric(vertical: 6.wMin, horizontal: 16.wMin),
                                    child: Text('再做一遍', style: TextStyle(color: AppTheme.cTextPrimary, fontSize: 22.wMin)),
                                  ),
                                ),
                              SizedBox(width: 8.wMin),
                              SvgPicture.asset(
                                expanded ? 'assets/svg/manage/icon_chevron_up.svg' : 'assets/svg/manage/icon_chevron_down.svg',
                                colorFilter: ColorFilter.mode(
                                  banned ? AppTheme.cInverseTextLight.withValues(alpha: 0.4) : (expanded ? AppTheme.cTextPrimary : AppTheme.cInverseTextLight),
                                  BlendMode.srcIn,
                                ),
                                width: 24.wMin,
                                height: 24.wMin,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (expanded)
                      Padding(
                        padding: EdgeInsets.only(left: 56.wMin),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const SizedBox(height: 8),
                          if (subTitle.trim().isNotEmpty)
                            Text(
                              subTitle,
                              style: TextStyle(color: AppTheme.cTextPrimary, fontSize: 22.wMin, fontWeight: FontWeight.w400),
                            ),
                          if (description.trim().isNotEmpty)
                            Text(
                              description,
                              style: TextStyle(color: AppTheme.cTextSecondary, fontSize: 22.wMin, fontWeight: FontWeight.w400),
                            ),
                          const SizedBox(height: 12),
                          _buildStepPanel(
                            task,
                            onPrimaryAction: (stop) {
                              if (banned) {
                                return;
                              } else if (done && canRepeat && widget.showRepeat) {
                                widget.onRepeat(taskId, stop);
                              } else if (highlighted) {
                                widget.onStart(taskId, stop);
                              } else {
                                widget.onStart(taskId, stop);
                              }
                            },
                          ),
                          SizedBox(height: 18.wMin),
                        ]),
                      ),
                  ],
                )));
      },
    );
  }

  Widget _buildStepPanel(
    UserTask task, {
    required Function(int? step) onPrimaryAction,
  }) {
    final steps = task.steps;
    if (steps.isEmpty) return const SizedBox.shrink();
    final currentIdx = task.currentStepIndex.clamp(0, steps.length - 1);
    final hasInProgress = steps.any((s) => s.status == ActivityConsoleTaskStepStatus.IN_PROGRESS);
    final firstNotStartedIdx = steps.indexWhere((s) => s.status == ActivityConsoleTaskStepStatus.NOT_STARTED);
    List<StepProgressData> stepDatas = [];
    for (int i = 0; i < steps.length; i++) {
      String buttonText = "";
      if (steps[i].status == ActivityConsoleTaskStepStatus.COMPLETED) {
        if (steps[i].stepMode == "PARALLEL") {
          buttonText = '再来一遍';
        } else {
          buttonText = '已完成';
        }
      } else if (steps[i].status == ActivityConsoleTaskStepStatus.NOT_STARTED) {
        if ((!hasInProgress && firstNotStartedIdx != -1 && i == firstNotStartedIdx)) {
          buttonText = '去完成';
        } else {
          buttonText = '未解锁';
        }
      } else {
        buttonText = '去完成';
      }

      stepDatas.add(StepProgressData(
        step: i + 1,
        name: steps[i].tipTitle,
        current: i == currentIdx,
        stepMode: steps[i].stepMode,
        buttonText: buttonText,
        // buttonText: steps[i].status == ActivityConsoleTaskStepStatus.COMPLETED
        //     ? '已完成'
        //     : steps[i].status == ActivityConsoleTaskStepStatus.NOT_STARTED
        //         ? (!hasInProgress && firstNotStartedIdx != -1 && i == firstNotStartedIdx)
        //             ? '去完成'
        //             : '未解锁'
        //         : '去完成',
        complete: steps[i].status == ActivityConsoleTaskStepStatus.COMPLETED,
      ));
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTertiary,
        borderRadius: BorderRadius.circular(12.wMin),
        border: Border.all(color: AppTheme.cBorderSecondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepProgressWidget(
            steps: stepDatas,
            isTask: true,
            onTap: (data) {
              if (data.complete && data.stepMode != "PARALLEL") return;
              if (!data.current && data.stepMode != "PARALLEL") return;
              if (data.stepMode == "PARALLEL") {
                onPrimaryAction.call(data.step - 1);
                return;
              }
              onPrimaryAction.call(null);
            },
          ),
        ],
      ),
    );
  }
}
