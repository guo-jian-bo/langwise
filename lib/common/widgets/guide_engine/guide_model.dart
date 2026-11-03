import 'package:langwise/common/entities/activity_console_task_entities.dart';

import '../../entities/prize.dart';


class TaskReward {
  String? description;
  int? amount;
  String? values;
  bool? isSend;
  String? type;

  bool get isCoupon => type == PrizeType.COUPON.value;

  TaskReward({
    this.description,
    this.amount,
    this.values,
    this.isSend,
    this.type,
  });
}

class GuideModel{
  bool isStrongHint;
  String status;
  List <GuideStep> steps;

  GuideModel({
    required this.isStrongHint,
    required this.status,
    required this.steps,
  });
}

class GuideStep {
  final String stepId;
  final String pagePath;   // 路由路径
  final String widgetId;   // 控件唯一标识
  final String tipTitle;   // 引导标题
  final String guideText;    // 引导提示语
  final String? stepMode; 
  final String roleKey;
  final bool autoAdvance;
  final bool autoComplete;
  final bool deferComplete;
  final bool canSkip;
  final bool tipOnly;
  ActivityConsoleTaskStepStatus status;
  Map<String, dynamic>? pathParams;

  GuideStep({
    required this.stepId,
    required this.pagePath,
    required this.widgetId,
    required this.tipTitle,
    required this.guideText,
    required this.stepMode,
    required this.roleKey,
    this.autoAdvance = true,
    this.autoComplete = false,
    this.deferComplete = false,
    this.canSkip = false,
    this.tipOnly = false,
    this.status = ActivityConsoleTaskStepStatus.unknown,
    this.pathParams,
  });
}

class UserTask {
  final String taskId;
  final String title;
  final String subTitle;
  final String description;
  final String? stepMode;
  final int priority;
  final bool isStrongHint;
  final List<GuideStep> steps;
  int currentStepIndex;
  ActivityConsoleTaskStatus status;
  final TaskReward? finishReward;
  bool isRepeatMode;
  bool canRepeat;
  final String banTxt;

  UserTask({
    required this.taskId,
    required this.title,
    this.subTitle = '',
    this.description = '',
    this.stepMode,
    this.priority = 0,
    this.isStrongHint = false,
    required this.steps,
    this.currentStepIndex = 0,
    this.status = ActivityConsoleTaskStatus.NOT_STARTED,
    this.finishReward,
    this.isRepeatMode = false,
    this.canRepeat = false,
    this.banTxt = '',
  });

  GuideStep? get currentStep => 
      currentStepIndex < steps.length ? steps[currentStepIndex] : null;

  bool get isDone =>
      status == ActivityConsoleTaskStatus.COMPLETED || status == ActivityConsoleTaskStatus.EXPIRED;

}