import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:lib_common/common.dart';
import 'package:quiz_play/models/quiz_operation_steps_model.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:quiz_play/utils/exercise_subtype.dart';
import 'package:quiz_play/utils/utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/entities/third_party_account_entity.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/values/values.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';
import '../../../home/controllers/home_controller.dart';
import '../../../study_plan/controllers/study_plan_controller.dart';
import '../../../user_center/user_evaluation_level/controllers/user_evaluation_level_controller.dart';
import '../../common/evaluation_results_dialog.dart';
import '../../common/practice_questions_number_dialog.dart';
import '../../model/quiz_info_model.dart';

class PracticeQuestionsEvalController extends GetxController with WidgetsBindingObserver, RoutesBreadcrumbMixin {
  final String tagText;
  PracticeQuestionsEvalController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.PRACTICE_QUESTIONS_EVAL;

  @override
  String get breadcrumbTitle => "评测";

  /// 传进来的参数  评测id 如果不为空调用继续评测接口
  int? assessmentId;

  /// 当前题目数据
  final RxList<QuizDataInfoModel> questionDataList = <QuizDataInfoModel>[].obs;

  /// 声通账号
  final Rx<ThirdPartyAccountEntityList> soundAccount = ThirdPartyAccountEntityList().obs;

  /// 当前题目的下标
  final RxInt currentQuizIndex = 0.obs;

  /// 上一个题目的下标
  int previousQuizIndex = 0;

  bool _shouldResumeBeforeSwitch(int? nextIndex) {
    if (nextIndex == null) return true;
    if (nextIndex == currentQuizIndex.value) return true;
    final String? currentType = questionDataList[currentQuizIndex.value].data.type;
    final String? nextType = questionDataList[nextIndex].data.type;
    if (currentType == ExerciseType.LISTEN_FIND_WORD || nextType == ExerciseType.LISTEN_FIND_WORD) {
      return false;
    }
    return true;
  }

  /// 是否是暂停状态
  final RxBool isPause = true.obs;

  /// 正计时一个周期的时间
  final countingSecondData = 60;

  /// 正计时进度
  final RxDouble countdownSecondProgress = 1.0.obs;

  /// 正计时时间
  final RxInt countUpSecond = 0.obs;

  /// 正计时
  Timer? countUpTimer;

  /// 每题开始的时间
  DateTime? quizStartTime;

  /// 暂停的时长秒
  int pauseDurationSecond = 0;

  /// 题目暂停恢复的控制器
  final StreamController<QuizStateType> quizStateController = StreamController<QuizStateType>.broadcast();

  /// 每道题都有一个推荐时长 如果超过这个时长 就显示跳过按钮 每次切换题目要重置
  Timer? skipTimer;

  /// 是否显示跳过按钮 每次切换题目就要重置
  final RxBool isShowSkipButton = false.obs;

  /// 是否显示公告
  final RxBool isShowAnnouncement = false.obs;

  /// 已经上报的题目id
  List<int> reportedQuizIds = [];

  /// 上一道题目上报的结果状态 [AssessmentStatusEnum]
  String assessmentStatus = AssessmentStatusEnum.assessing;

  /// 评测的分数
  AssessmentQuizEntityResult? assessmentQuizResult;

  /// 是否已经结束做题
  final RxBool endPractice = false.obs;

  /// 是否显示题目
  final RxBool isShowQuestion = false.obs;

  /// 暂停时候的timer
  Timer? quizPauseTimer;

  @override
  void onInit() {
    WakelockPlus.enable();
    WidgetsBinding.instance.addObserver(this);
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      assessmentId = Get.arguments["assessmentId"];
    }
    getAssessmentLastStatus();
  }

  /// 获取最后一次的评测状态
  Future<void> getAssessmentLastStatus() async {
    try {
      ToastUtils.showLoading();

      AssessmentQuizEntity? assessmentQuizEntity;
      if (Get.arguments["firstQuestion"] != null) {
        assessmentQuizEntity = Get.arguments["firstQuestion"];
        await setQuestionData(assessmentQuizEntity);
        startPlayingQuiz();
        return;
      }
      if (assessmentId != null) {
        assessmentQuizEntity = await PracticeQuestionsReqest.getContinueAssessmentData(assessmentId!);
      }
      if (assessmentQuizEntity == null) {
        return;
      }

      await setQuestionData(assessmentQuizEntity);

      startPlayingQuiz();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 组装数据
  Future<void> setQuestionData(AssessmentQuizEntity? assessmentQuizEntity) async {
    if (assessmentQuizEntity == null) return;
    List<AssessmentQuizEntityExercises?> exercises = assessmentQuizEntity.exercises ?? [];

    List<QuizModel> quizList = [];
    for (var item in exercises) {
      if (item == null) continue;
      if (item.exercise == null) continue;
      quizList.add(item.exercise!);
    }

    /// 缓存资源文件
    await CacheManagerUtils.instance.cacheQuizAssets(quizList);

    List<int> quizIds = [];
    for (var item in questionDataList) {
      if (item.data.uid == null) continue;
      quizIds.add(item.data.uid!);
    }

    for (int i = 0; i < quizList.length; i++) {
      if (quizIds.contains(quizList[i].uid)) continue;
      questionDataList.add(QuizDataInfoModel(
        data: quizList[i],
        key: GlobalKey(),
      ));
    }
  }

  /// 开始做题
  Future<void> startPlayingQuiz() async {
    isPause.value = false;
    if (questionDataList.isEmpty) return;
    quizStateController.add(QuizStateType.resumeAllState);
    await getThirdPartyAccount();
    isShowQuestion.value = true;
    startCountdown();
    startSkipTimer();
    quizStartTime = DateTime.now().toUtc();
  }

  /// 开始倒计时
  void startCountdown() {
    if (countUpTimer != null && countUpTimer!.isActive) return;
    countUpTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      countUpSecond.value++;
      final remainder = countUpSecond.value % countingSecondData;
      countdownSecondProgress.value = remainder == 0 ? -1 : -remainder / countingSecondData;
    });
  }

  /// 开始推荐时长倒计时
  void startSkipTimer() {
    isShowAnnouncement.value = false;
    isShowSkipButton.value = false;
    skipTimer?.cancel();
    if (currentQuizIndex.value >= questionDataList.length) return;
    int maxDuration = max(20, (questionDataList[currentQuizIndex.value].data.estimatedTime ?? 0) * 2);
    skipTimer = Timer(Duration(seconds: maxDuration), () {
      isShowSkipButton.value = true;
    });

    if (isNeedShowOperationAnnouncementPrompt()) {
      Future.delayed(const Duration(seconds: 1), () {
        isShowAnnouncement.value = true;
      });
    }
  }

  /// 判断是否需要弹出操作公告提示
  bool isNeedShowOperationAnnouncementPrompt() {
    if (questionDataList.isEmpty) return false;
    QuizModel data = questionDataList[currentQuizIndex.value].data;
    int? configId = data.config?.uid;
    int? memberId = UserStore.to.userInfo.value.memberId;
    if (configId == null || memberId == null) return false;
    String key = "${memberId}_$configId";
    // 再判断一个提示的内容 如果没有也返回false
    List<QuizModelGloss?> guide = data.guide ?? [];
    guide.removeWhere((element) => element == null);
    if (guide.isEmpty) return false;

    List<String> localValue = StorageUtil().getList(QUIZ_OPERATION_ANNOUNCEMENT_PROMPT_KEY);

    // 超过3次不提示
    bool isShow = !localValue.contains(key);
    if (isShow) {
      // 提示过的次数增加
      localValue.add(key);
      StorageUtil().setList(QUIZ_OPERATION_ANNOUNCEMENT_PROMPT_KEY, localValue);
    }

    return isShow;
  }

  /// 每道题的回调
  Future<void> quizPlayOnResult(BuildContext context, QuizLogModel log) async {
    // 隐藏键盘
    FocusScope.of(context).requestFocus(FocusNode());
    quizStartTime ??= DateTime.now().toUtc();

    /// 获取当前做题的时长
    int quizDuration = DateTime.now().toUtc().difference(quizStartTime!).inSeconds;
    quizDuration -= pauseDurationSecond;
    pauseDurationSecond = 0;

    reportQuestion(quizDuration, currentQuizIndex.value, log);

    if (assessmentStatus == AssessmentStatusEnum.assessing) {
      // 还没有评测结束 下一题
      nextQuestion();
      return;
    }

    // 评测结束
    assessmentComplete();
  }

  /// 评测完成
  Future<void> assessmentComplete() async {
    endPractice.value = true;
    isPause.value = true;
    countUpTimer?.cancel();
    skipTimer?.cancel();
    quizStateController.add(QuizStateType.pauseAllState);

    await EvaluationResultsDialog.show(
      context: Get.context!,
      overall: assessmentQuizResult?.overall,
      tier: assessmentQuizResult?.tier,
      buttonText: "去查看",
    );

    UserStore.to.getUserInfo();

    final todayPlanControllers = TagRoutes.finds<StudyPlanController>(Routes.STUDY_PLAN);
    if (todayPlanControllers.isNotEmpty) {
      for (final c in todayPlanControllers) {
        await c.initData();
      }
    }
    final homeControllerRegistered = Get.isRegistered<HomeController>();
    if (homeControllerRegistered && Get.currentRoute == Routes.HOME) {
      Get.find<HomeController>().initHomeCardList();
    }

    UserEvaluationLevelController? userEvaluationLevelController = TagRoutes.findLast<UserEvaluationLevelController>(Routes.USER_EVALUATION_LEVEL);
    if (userEvaluationLevelController != null) {
      userEvaluationLevelController.initData(aId: assessmentId, isGuide: true);
      Get.until((route) => route.settings.name == Routes.USER_EVALUATION_LEVEL);
      return;
    }
    await TagRoutes.offAndToNamed(
      Routes.USER_EVALUATION_LEVEL,
      arguments: {
        "assessmentId": assessmentId,
      },
    );
  }

  /// 下一题
  Future<void> nextQuestion({int repeatCount = 0}) async {
    if (assessmentStatus == AssessmentStatusEnum.assessing) {
      if (currentQuizIndex.value >= questionDataList.length - 1) {
        if (repeatCount > 50) {
          ToastUtils.hideLoading();
          bool notAskRes = await AskDialog.showUserAsk(
            context: Get.context!,
            title: "温馨提示",
            content: "当前网络异常，是否重试？",
            define: "重试",
            cancel: "稍后再试",
          );
          if (!notAskRes) return backPage();
          reportedQuizIds.clear();
          getRetryNextQuiz();
          return;
        }
        // 评测没有结束 没有题目了 等待下一个题目回来
        if (repeatCount == 0) ToastUtils.showLoading();
        await Future.delayed(const Duration(milliseconds: 200));
        nextQuestion(repeatCount: repeatCount + 1);
        return;
      }
    }

    ToastUtils.hideLoading();

    if (assessmentStatus == AssessmentStatusEnum.assessed) {
      // 评测结束
      assessmentComplete();
      return;
    }

    // 记录上一题的索引
    previousQuizIndex = currentQuizIndex.value;

    currentQuizIndex.value++;
    // 重新设置开始做题时间
    quizStartTime = DateTime.now().toUtc();

    if (currentQuizIndex.value + 1 < questionDataList.length) {
      // 获取下一道题并缓存
      QuizModel nextQuiz = questionDataList[currentQuizIndex.value + 1].data;
      CacheManagerUtils.instance.cacheQuizAssets([nextQuiz]);
    }

    startSkipTimer();
    isShowSkipButton.value = false;
  }

  /// 关闭公告
  void closeAnnouncement() {
    isShowAnnouncement.value = false;
  }

  /// 如果没有下一题 点击重试 重新拉取继续评测的接口 去重题目
  Future<void> getRetryNextQuiz() async {
    if (assessmentId == null) return;
    try {
      ToastUtils.showLoading();
      if (assessmentStatus == AssessmentStatusEnum.assessed) {
        assessmentComplete();
        return;
      }
      AssessmentQuizEntity? assessmentQuizEntity = await PracticeQuestionsReqest.getContinueAssessmentData(assessmentId!);
      if (assessmentQuizEntity == null) return;
      if (assessmentStatus == AssessmentStatusEnum.assessed) {
        assessmentComplete();
        return;
      }
      await setQuestionData(assessmentQuizEntity);
    } finally {
      ToastUtils.hideLoading();
    }
    nextQuestion();
  }

  /// 判断如果是题型是用声通账号 那么判断账号是否获取到 如果没有获取到 提示用户返回重试
  Future<void> isSoundAccountValid() async {
    if (questionDataList[currentQuizIndex.value].data.type == ExerciseType.PRONUNCIATION_ASSESSMENT ||
        questionDataList[currentQuizIndex.value].data.type == ExerciseType.PRONUNCIATION_BREAKDOWN) {
      if (soundAccount.value.app?.appId == null || soundAccount.value.app?.secretKey == null) {
        await getThirdPartyAccount();
      }
    }
  }

  /// 获取声通账号
  Future<void> getThirdPartyAccount() async {
    try {
      ToastUtils.showLoading();
      ThirdPartyAccountEntityList? account = await Get.find<ConfigController>().getThirdPartyAccountByCode(ThirdPartyAccountEnum.stkouyu);
      if (account == null) {
        ToastUtils.showToast(text: "获取评测配置失败，请稍后重试");
        return;
      }
      soundAccount.value = account;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 当前题目的日志 每一个步骤都会回调
  Future<void> currentStep(QuizLogModel log) async {
    questionDataList[currentQuizIndex.value].log = log;
  }

  /// 当前题目的错误次数回调 错误一次自动跳过
  Future<bool> currentErrorCount(BuildContext context, int errorCount) async {
    questionDataList[currentQuizIndex.value].errorCount = errorCount;
    if (errorCount >= 1) {
      // isShowSkipButton.value = true;

      await Future.delayed(const Duration(milliseconds: 300));

      isShowSkipButton.value = false;
      QuizLogModel? log = questionDataList[currentQuizIndex.value].log;
      if (log == null) return false;
      log.status = QuizLogStatus.failed;
      log.endTime = DateTime.now();
      quizPlayOnResult(context, log);
    }

    return false;
  }

  /// 跳过当前题目
  Future<void> skipCurrentQuiz(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    if (viewInsets > 0) {
      await Future.delayed(const Duration(milliseconds: 300));
    }
    isShowSkipButton.value = false;
    QuizLogModel? log = questionDataList[currentQuizIndex.value].log;
    if (log == null) return;
    log.status = QuizLogStatus.skipping;
    log.endTime = DateTime.now();
    quizPlayOnResult(context, log);
  }

  /// 上报题目记录
  Future<void> reportQuestion(int quizDuration, int quizIndex, QuizLogModel log) async {
    if (endPractice.value) return;
    if (assessmentStatus == AssessmentStatusEnum.assessed) return;

    print("上报题目记录");

    try {
      QuizModel quizModel = questionDataList[quizIndex].data;

      if (reportedQuizIds.contains(quizModel.uid)) return; // 已经上报过
      if (quizModel.uid == null) return; // 题目id为空
      reportedQuizIds.add(quizModel.uid!); // 添加已上报的题目id

      quizStartTime ??= DateTime.now().toUtc();
      String startTime = quizStartTime!.toIso8601String();

      Map<String, dynamic> data = PracticeQuestionsReqest.getSubmitData(quizModel, quizDuration, log, startTime);

      AssessmentQuizEntity? assessmentQuizEntity = await PracticeQuestionsReqest.submitAssessment(data);
      if (assessmentQuizEntity == null) {
        bool askRes = await AskDialog.showUserAsk(
          context: Get.context!,
          title: "温馨提示",
          content: "评测失败，是否重试？",
          define: "重试",
          cancel: "稍后再来",
        );
        if (!askRes) {
          backPage();
          return;
        }
        reportedQuizIds.remove(quizModel.uid); // 移除已上报的题目id
        reportQuestion(quizDuration, quizIndex, log);
        return;
      }

      assessmentStatus = assessmentQuizEntity.status ?? AssessmentStatusEnum.assessed;

      assessmentQuizResult = assessmentQuizEntity.result;
      if (assessmentStatus == AssessmentStatusEnum.assessing) {
        // 还没有结束 但是返回的题目为空那么提示用户重试
        if (assessmentQuizEntity.exercises == null || (assessmentQuizEntity.exercises ?? []).isEmpty) {
          quizStateController.sink.add(QuizStateType.pauseAllState);
          bool errAskRes = await AskDialog.showUserAsk(
            context: Get.context!,
            title: "温馨提示",
            content: "当前获取题目失败，请联系客服。\n是否重新开始评测？",
            define: "重新开始",
            cancel: "退出评测",
          );
          if (errAskRes) {
            questionDataList.clear();
            currentQuizIndex.value = 0;
            previousQuizIndex = 0;
            countdownSecondProgress.value = 0;
            countUpSecond.value = 0;
            countUpTimer?.cancel();
            quizStateController.sink.add(QuizStateType.pauseAllState);
            skipTimer?.cancel();
            reportedQuizIds.clear();
            assessmentId = null;
            getAssessmentLastStatus();
          } else {
            backPage();
          }
          return;
        }
      }

      await setQuestionData(assessmentQuizEntity);
    } finally {}
  }

  /// 退出
  Future<void> backPage({bool manual = true}) async {
    endPractice.value = true;
    countUpTimer?.cancel();
    if (isPause.value) {
      isPause.value = false;
      Get.back();
    }

    quizStateController.add(QuizStateType.pauseAllState);

    Get.back();
  }

  /// 点击暂停
  Future<void> showQuizNumber(BuildContext context) async {
    // 隐藏键盘
    FocusScope.of(context).requestFocus(FocusNode());
    if (endPractice.value) return;
    isPause.value = true;
    countUpTimer?.cancel();
    quizStateController.add(QuizStateType.pauseAllState);
    DateTime currentPauseTime = DateTime.now().toUtc();
    startQuizPauseTimer();

    if (ShowBigResourceDialog.isShow) {
      Get.back();
    }

    int? indexRes = await PracticeQuestionsNumberDialog.showTestQuizList(
      context: context,
      questionDataList: <QuizDataInfoModel>[].obs,
      // questionDataList: questionDataList,
      currentQuizIndex: currentQuizIndex,
      originalQuizIndex: 0.obs,
    );

    /// 退出
    if (indexRes == -1) {
      isPause.value = false;
      ToastUtils.showLoading();
      quizStateController.add(QuizStateType.pauseAllState);
      backPage();
      return;
    }

    FocusScope.of(context).requestFocus(FocusNode());

    // 继续
    quizPauseTimer?.cancel();
    isPause.value = false;
    final bool shouldResumeBeforeSwitch = _shouldResumeBeforeSwitch(indexRes);
    if (shouldResumeBeforeSwitch) {
      quizStateController.add(QuizStateType.resumeAllState);
    }
    startCountdown();
    pauseDurationSecond = DateTime.now().toUtc().difference(currentPauseTime).inSeconds;

    if (indexRes == null) return;
    // 切题目
    currentQuizIndex.value = indexRes;
    // scrollIndicator();
    quizStartTime = DateTime.now().toUtc();
    startSkipTimer();
  }

  /// 如果是暂停的话 每隔一秒给题目发送一次暂停
  void startQuizPauseTimer() {
    quizPauseTimer?.cancel();
    quizPauseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      quizStateController.add(QuizStateType.pauseAllState);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        if (Get.context != null && !isPause.value) {
          Future.delayed(const Duration(seconds: 1), () {
            if (!isPause.value) {
              isPause.value = true;
              showQuizNumber(Get.context!);
            }
          });
        }
        print('App 处于非活动状态');
        break;
      case AppLifecycleState.paused:
        print('App 进入后台');
        break;
      case AppLifecycleState.resumed:
        print('App 返回前台');
        break;
      case AppLifecycleState.detached:
        print('App 被销毁');
        break;
      case AppLifecycleState.hidden:
        print('App 被隐藏');
        break;
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    QuizPlayResourceManager.dispose();
    WakelockPlus.disable();
    countUpTimer?.cancel();
    countUpTimer = null;
    quizStateController.close();
    skipTimer?.cancel();
    skipTimer = null;
    quizPauseTimer?.cancel();
    quizPauseTimer = null;
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
