import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/activities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:video_player/video_player.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/guide_engine/guide_manager.dart';
import '../../../../common/widgets/guide_engine/guide_model.dart';
import '../../../../utils/toast_utils.dart';
import '../../../routes/routes.dart';
import '../../../routes/routes_breadcrumb_utils.dart';

class VideoTaskPlayerController extends GetxController with WidgetsBindingObserver, RoutesBreadcrumbMixin {
  final String tagText;
  VideoTaskPlayerController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.VIDEO_TASK_PLAYER;

  @override
  String get breadcrumbTitle => "视频任务";

  final RxBool isReady = false.obs;
  final RxBool isPlaying = false.obs;

  final Rx<Duration> duration = Duration.zero.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> maxPlayed = Duration.zero.obs;

  final RxDouble speed = 1.0.obs;

  final List<double> _speedOptions = const [0.5, 1.0, 1.5, 2.0];

  final VideoPlayeController videoPlayeController = VideoPlayeController();

  String? taskCode;
  String? eventType;
  String? stepCode;

  String? title;
  String? rightTopText;
  String rewardTitle = '奖励已发放';
  String rewardDesc = '恭喜你完成观看任务，奖励已到账。';

  bool _showedCompleteDialog = false;
  bool _initializedArgs = false;
  String? videoUrl;

  /// 是否显示底部进度条
  final RxBool showButtom = true.obs;

  /// 是否是重复任务
  final RxBool isRepetition = false.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    WidgetsBinding.instance.addObserver(this);

    if(Get.arguments != null){
      videoUrl = Get.arguments['videoUrl'];
      title = Get.arguments['title'];
      rightTopText = Get.arguments['desc'];
      rewardTitle = Get.arguments['rewardTitle']??"奖励已发放";
      rewardDesc = Get.arguments['rewardDesc']??"恭喜你完成观看任务，奖励已到账。";

      taskCode = Get.arguments['taskCode'];
      eventType = Get.arguments['eventType'];
      stepCode = Get.arguments['stepCode'];

    }

    _initializedArgs = true;

    UserTask? activeTask = GuideManager.instance.activeTask;
    isRepetition.value = activeTask?.currentStep?.status == ActivityConsoleTaskStepStatus.COMPLETED;
  }

  void onVideoPlayInfoChange(dynamic info) {
    final Duration allDuration = info?.allDuration ?? Duration.zero;
    final Duration positionDuration = info?.positionDuration ?? Duration.zero;
    final bool playing = info?.playing ?? false;
    final double rate = info?.rate ?? 1.0;
    final bool completed = info?.completed ?? false;

    duration.value = allDuration;
    position.value = positionDuration;
    isPlaying.value = playing;
    speed.value = rate;

    if (!isReady.value && allDuration > Duration.zero) {
      isReady.value = true;
    }

    if (positionDuration > maxPlayed.value) {
      maxPlayed.value = positionDuration;
    }

    if (!_showedCompleteDialog && completed) {
      _showedCompleteDialog = true;
      isPlaying.value = false;

      Future<void>.delayed(Duration.zero, () {
        if (Get.isDialogOpen == true) return;
        playCompleted();
      });
    }
  }

  /// 播放完成 
  Future<void> playCompleted() async{
    if(isRepetition.value) {
      GuideManager.instance.loadRemoteTasks();
      return;
    }
    bool res = await taskComplete();
    if(!res) return;

    await AskDialog.showUserAsk(
      context: Get.context!,
      title: rewardTitle,
      content: rewardDesc,
      showCancel: false,
    );
    Get.back(result: true);
    await GuideManager.instance.loadRemoteTasks();
    await GuideManager.instance.forceShowTaskListEntryGuide();
  }

  /// 上报观看完成
  Future<bool> taskComplete() async{
    

    if(taskCode == null || eventType == null || stepCode == null) return false;

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "taskCode": taskCode,
        "eventType": eventType,
        "stepCode": stepCode,
      };

      bool res = await ActivitiesRequest.referralTaskProgress(reqData: reqData);
      return res;

    } finally{
      ToastUtils.hideLoading();
    }
  }

  Future<void> togglePlay() async {
    if (!_initializedArgs) return;
    await videoPlayeController.playOrPause();
  }

  Future<void> play() async {
    if (!_initializedArgs) return;
    await videoPlayeController.play();
  }

  Future<void> pause() async {
    if (!_initializedArgs) return;
    await videoPlayeController.pause();
  }

  Future<void> setSpeed(double v) async {
    speed.value = v;
    if (!_initializedArgs) return;
    await videoPlayeController.setRate(v);
  }

  Future<void> cycleSpeed() async {
    final current = speed.value;
    final idx = _speedOptions.indexWhere((e) => (e - current).abs() < 0.001);
    final next = _speedOptions[(idx < 0 ? 0 : (idx + 1) % _speedOptions.length)];
    await setSpeed(next);
  }

  Future<void> seek(Duration d) async {
    if (!_initializedArgs) return;
    await videoPlayeController.seek(d);
  }

  void scheduleExceedToast() {
      ToastUtils.showToast(text: '无法快进', type: ToastType.warning);
  }

  /// 退出
  Future<void> backPlayPage(BuildContext context) async{
    await pause();

    if(isRepetition.value){
      Get.back();
      return;
    }

    bool resAsk = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "提前退出您将失去此次奖励，您确定要退出观看吗吗？",
      cancel: "坚持退出",
      define: "继续观看"
    );
    if(!resAsk){
      Get.back();
    }else{
      play();
    }
  }

  

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      pause();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
