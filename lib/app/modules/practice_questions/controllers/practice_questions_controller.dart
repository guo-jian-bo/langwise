import 'dart:async';
import 'dart:math';
import 'package:langwise/app/modules/elements/dialog/elements_collect_result_dialog.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:lib_common/common.dart';
import 'package:quiz_play/models/quiz_operation_steps_model.dart';
import 'package:quiz_play/utils/exercise_subtype.dart';
import 'package:quiz_play/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../common/entities/entities.dart';
import '../../../../common/entities/third_party_account_entity.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/values/values.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../routes/routes.dart';
import '../../../routes/routes_breadcrumb_utils.dart';
import '../model/quiz_info_model.dart';
import '../common/practice_questions_number_dialog.dart';

/// 练习题目
/// 页面返回结果 如果是手动暂停退出 则返回false 全部做完返回true
class PracticeQuestionsController extends GetxController
    with WidgetsBindingObserver, RoutesBreadcrumbMixin {
  final String tagText;
  PracticeQuestionsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.PRACTICE_QUESTIONS;

  @override
  String get breadcrumbTitle => "学习";

  /// 传进来的参数-当前做到的题目ID
  int? currentQuizId;

  /// 传进来的参数-是否上报(可以理解为是否不是演示,如果是演示的话则是false)
  bool questionIsReport = false;

  /// 是否收集卡牌
  bool isCollectCard = false;

  /// 设置的总时长 如果没有则把所有题目的时长加起来
  int? settingTotalDurationSecond;

  ///是否显示百分比进度
  bool isShowPercentageProgress = false;

  /// 是否是管理端页面
  bool isAdminPage = false;

  /// 是否显示上下架状态
  bool isShowUpDownStatus = false;

  /// 可以错误的次数 如果[isAutoSkip]为true 则为显示跳过题目按钮
  int maxErrorCount = 3;

  /// 错误次数达到[maxErrorCount] 是否自动跳过
  bool isAutoSkip = false;

  /// 是否可以通过题目编号切换题目
  bool isCanSwitchByNumber = true;

  /// 是否显示图片释义
  bool isShowImageGloss = true;

  /// Android 低版本设备关闭切题预加载，降低内存与解码压力。
  bool reduceAndroidQuizPreload = false;

  /// 指定英音美音 如果为null 根据设置的来
  String? national;

  // =================== 以上是参数 ====================

  /// 当前题目数据
  final RxList<QuizDataInfoModel> questionDataList = <QuizDataInfoModel>[].obs;

  /// 声通账号
  final Rx<ThirdPartyAccountEntityList> soundAccount = ThirdPartyAccountEntityList().obs;

  /// 当前题目的下标
  final RxInt currentQuizIndex = 0.obs;

  /// 原来题目的下标 用来记录实际做到的题目
  final RxInt originalQuizIndex = 0.obs;

  /// 上一个题目的下标
  int previousQuizIndex = 0;

  /// 是否是暂停状态
  final RxBool isPause = true.obs;

  /// 倒计时总时间
  int allCountdownSecondDate = 0;

  /// 正计时一个周期的时间
  final countingSecondData = 60;

  /// 倒计时时间
  final RxInt countdownSecond = 0.obs;

  /// 倒计时进度
  final RxDouble countdownSecondProgress = 1.0.obs;

  /// 是否是倒计时
  final RxBool isCountdown = true.obs;

  /// 正计时时间
  final RxInt countingSecond = 0.obs;

  /// 倒计时
  Timer? countdownTimer;

  /// 每题开始的时间
  DateTime? quizStartTime;

  /// 暂停的时长秒
  int pauseDurationSecond = 0;

  final ScrollController indicatorScrollController = ScrollController();

  /// 题目暂停恢复的控制器
  final StreamController<QuizStateType> quizStateController = StreamController<QuizStateType>.broadcast();

  /// 每道题都有一个推荐时长 如果超过这个时长 就显示跳过按钮 每次切换题目要重置
  Timer? skipTimer;

  /// 是否显示跳过按钮 每次切换题目就要重置
  final RxBool isShowSkipButton = false.obs;

  /// 是否显示公告
  final RxBool isShowAnnouncement = false.obs;

  /// 是否已经结束做题
  final RxBool endPractice = false.obs;

  /// 是否开始上报
  bool reportStart = false;

  final RxBool isFinishingLastQuiz = false.obs;

  /// 是否显示题目
  final RxBool isShowQuestion = false.obs;

  Future<void> _closeOverlaysSafely(BuildContext context) async {
    try {
      Navigator.of(context, rootNavigator: true).popUntil((route) {
        return route.settings.name == breadcrumbRoute;
      });
      return;
    } catch (_) {}
  }
  
  /// 网络音频资源播放失败类型
  final Rx<AudioErrorEvent?> audioErrorEvent = Rx(null);
  /// 资源播放失败重试token
  final RxInt audioPlayErrRetryToken = 0.obs;

  /// 暂停时候的timer
  Timer? quizPauseTimer;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    ErrorLogUtils.to.logInfo("练习 ----- PracticeQuestionsController 初始化开始");
    ToastUtils.hideLoading();
    WakelockPlus.enable();
    WidgetsBinding.instance.addObserver(this);
    if (Get.arguments != null) {
      Map argumentsMap = Get.arguments;
      currentQuizId = argumentsMap['currentQuizId'];
      questionIsReport = argumentsMap['questionIsReport'] ?? false;
      isCollectCard = argumentsMap['isCollectCard'] ?? true;
      settingTotalDurationSecond = argumentsMap['settingTotalDurationSecond'];
      isShowPercentageProgress = argumentsMap['isShowPercentageProgress'] ?? false;
      isAdminPage = argumentsMap['isAdminPage'] ?? false;
      isShowUpDownStatus = argumentsMap['isShowUpDownStatus'] ?? false;
      maxErrorCount = argumentsMap['maxErrorCount'] ?? 3;
      isAutoSkip = argumentsMap['isAutoSkip'] ?? false;
      isCanSwitchByNumber = argumentsMap['isCanSwitchByNumber'] ?? true;
      isShowImageGloss = argumentsMap['isShowImageGloss'] ?? true;
      national = argumentsMap['national'];

      List<QuizModel?>? quizDatas = argumentsMap['quizDatas'];
      List<QuizModel> argQuizList = [];
      if (quizDatas != null) {
        for (int i = 0; i < quizDatas.length; i++) {
          if (quizDatas[i] == null) continue;
          argQuizList.add(quizDatas[i]!);
        }
      }
      ErrorLogUtils.to.logInfo("练习 ----- 处理题目数据完成，共 ${argQuizList.length} 道题");

      setGroupData(argQuizList);
      setCurrentQuizGroupAndIndex();

      

      initSetting();
    } else {
      ErrorLogUtils.to.logError("练习 ----- 未接收到参数，初始化失败", StackTrace.current);
    }
    ErrorLogUtils.to.logInfo("练习 ----- PracticeQuestionsController 初始化完成");
  }

  /// 把数据分组
  void setGroupData(List<QuizModel> argQuizList) {
    for (int i = 0; i < argQuizList.length; i++) {
      questionDataList.add(QuizDataInfoModel(
        data: argQuizList[i],
        key: GlobalKey(),
      ));
    }
  }

  /// 获取做到的题目的当前分组下标 和 题目在分组中的下标
  void setCurrentQuizGroupAndIndex() {
    if (currentQuizId == null) {
      // 如果没有当前做到题目的id 那么证明从头开始 默认从0开始
      currentQuizIndex.value = 0;
      originalQuizIndex.value = 0;
      return;
    }

    currentQuizIndex.value = questionDataList.indexWhere((element) => element.data.uid == currentQuizId);
    if (currentQuizIndex.value <= 0) {
      currentQuizIndex.value = 0;
    }
    originalQuizIndex.value = currentQuizIndex.value;
  }

  Future<void> initSetting() async {
    ErrorLogUtils.to.logInfo("练习 ----- 初始化设置开始");
    if (questionDataList.isEmpty) {
      ErrorLogUtils.to.logError("练习 ----- 题目数据为空，加载错误", StackTrace.current);
      loadingError();
      return;
    }

    reduceAndroidQuizPreload = await PlatformUtils.shouldReduceAndroidQuizPreload();
    ErrorLogUtils.to.logInfo("练习 ----- 低版本Android预加载降级开关: $reduceAndroidQuizPreload");

    await getThirdPartyAccount();

    cacheQuizAssets();

    setCountdownSecondData();
    await Future.delayed(const Duration(milliseconds: 400));
    isShowQuestion.value = true;
    startPlayingQuiz();
    ErrorLogUtils.to.logInfo("练习 ----- 初始化设置完成");
  }

  /// 开始做题
  Future<void> startPlayingQuiz() async {
    ErrorLogUtils.to.logInfo("练习 ----- 开始做题，当前题目索引: ${currentQuizIndex.value}, 题目数据: ${ErrorLogUtils.to.toSingleLineJsonSafe(questionDataList[currentQuizIndex.value].data.toJson())}");
    isPause.value = false;
    startCountdown();
    startSkipTimer();

    // 初始化当前题目本轮计时数据
    questionDataList[currentQuizIndex.value].quizStartTime = DateTime.now().toUtc();
    questionDataList[currentQuizIndex.value].quizEndTime = null;
    questionDataList[currentQuizIndex.value].pauseDurationSecond = 0;

    // 兼容现有全局字段，保持当前题目的实时状态
    quizStartTime = DateTime.now().toUtc();
    pauseDurationSecond = 0;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollIndicator();
    });
  }

  /// 开始推荐时长倒计时
  void startSkipTimer() {
    isShowAnnouncement.value = false;
    isShowSkipButton.value = false;
    skipTimer?.cancel();
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

  /// 题目播放网络音频错误
  void audioNetworkPlayErr(AudioErrorEvent? errorEvent){
    if(errorEvent == null) return;
    if(errorEvent.sourceType != AudioSourceType.url) return;
    audioErrorEvent.value = errorEvent;
  }

  /// 音频播放失败重试
  Future<void> audioNetworkPlayErrRetry() async{
    try {
      ToastUtils.showLoading();
      // 缓存当前题目
      if(currentQuizIndex.value >= questionDataList.length) return;
      QuizModel currentQuiz = questionDataList[currentQuizIndex.value].data;
      int? exerciseCurrentId = questionDataList[currentQuizIndex.value].data.uid;
      await CacheManagerUtils.instance.cacheQuizAssets([currentQuiz], exerciseCurrentId: exerciseCurrentId);
      audioPlayErrRetryToken.value++;
      audioNetworkPlayErrClear();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 清除错误状态
  void audioNetworkPlayErrClear(){
    if(audioErrorEvent.value == null) return;
    if(audioErrorEvent.value?.sourceType != AudioSourceType.url) return;
    audioErrorEvent.value = null;
  }

  /// 缓存上一题、当前题和后3道题目的资源
  Future<void> cacheQuizAssets() async{
    try {

      if(!reduceAndroidQuizPreload){
        List<QuizModel> cacheQuizLists = [];
        if(currentQuizIndex.value >= questionDataList.length) return;
        int startIndex = max(0, currentQuizIndex.value - 1);
        int endIndex = min(questionDataList.length - 1, currentQuizIndex.value + 3);
        for(int i = startIndex; i <= endIndex; i++){
          cacheQuizLists.add(questionDataList[i].data);
        }

        int? exerciseCurrentId = questionDataList[currentQuizIndex.value].data.uid;
        unawaited(CacheManagerUtils.instance.cacheQuizAssets(cacheQuizLists, exerciseCurrentId: exerciseCurrentId));

      }else{
        // 低版本Android预加载降级开关 只缓存当前题和下一题 并且需要排队
        if(currentQuizIndex.value >= questionDataList.length) return;
        List<QuizModel> cacheQuizLists = [];
        int endIndex = min(questionDataList.length - 1, currentQuizIndex.value + 1);
        for(int i = currentQuizIndex.value; i <= endIndex; i++){
          cacheQuizLists.add(questionDataList[i].data);
        }
        int? exerciseCurrentId = questionDataList[currentQuizIndex.value].data.uid;
        await CacheManagerUtils.instance.cacheQuizAssets(
          cacheQuizLists, 
          exerciseCurrentId: exerciseCurrentId,
          isQueue: true,
        );

      }

    } catch (e) {
      ErrorLogUtils.to.logError("练习 ----- 缓存当前题目资源失败: ${e.toString()}", null);
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

  /// 设置题目分组的总时间
  void setCountdownSecondData() {
    if (settingTotalDurationSecond == null) {
      allCountdownSecondDate = 0;
      for (int i = currentQuizIndex.value; i < questionDataList.length; i++) {
        allCountdownSecondDate += questionDataList[i].data.estimatedTime ?? 0;
      }
      countdownSecond.value = allCountdownSecondDate;
    } else {
      /// 有设置总时长 那么就用设置的总时长 减去 已经用的时长 就是剩余的时长
      allCountdownSecondDate = settingTotalDurationSecond!;
      int useDurationSecond = 0;
      for (int i = 0; i < currentQuizIndex.value; i++) {
        if (questionDataList[i].data.duration == null) continue;
        useDurationSecond += (questionDataList[i].data.duration ?? 0).toInt();
      }
      allCountdownSecondDate = allCountdownSecondDate - useDurationSecond;
      countdownSecond.value = allCountdownSecondDate;
      if (countdownSecond.value < 0) {
        isCountdown.value = false;
      }
    }
  }

  /// 开始倒计时
  void startCountdown() {
    if (countdownTimer != null && countdownTimer!.isActive) return;
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (isCountdown.value) {
        if (countdownSecond.value > 0) {
          countdownSecond.value--;
          countdownSecondProgress.value = countdownSecond.value / allCountdownSecondDate;
          // 还有一分钟的时候提示用户
        } else {
          // 倒计时结束，开始正计时
          isCountdown.value = false;
          countingSecond.value++;
          countdownSecondProgress.value = -countingSecond.value / countingSecondData;
        }
      } else {
        countingSecond.value++;
        final remainder = countingSecond.value % countingSecondData;
        countdownSecondProgress.value = remainder == 0 ? -1 : -remainder / countingSecondData;
      }
    });
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
        ErrorLogUtils.to.logError("获取评测配置失败", null);
        ToastUtils.showToast(text: "获取评测配置失败，请稍后重试");
        return;
      }
      soundAccount.value = account;
    } catch (e) {
      ErrorLogUtils.to.logError("获取评测配置失败!", null);
      ToastUtils.showToast(text: "获取评测配置失败，请稍后重试");
      return;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 当前题目的日志 每一个步骤都会回调
  Future<void> currentStep(QuizLogModel log) async {
    questionDataList[currentQuizIndex.value].log = log;
  }

  /// 当前题目的错误次数回调 错误三次显示跳过按钮
  Future<bool> currentErrorCount(BuildContext context, int errorCount) async {
    ErrorLogUtils.to.logInfo("练习 ----- 题目错误次数回调，当前错误次数: $errorCount，最大允许错误: $maxErrorCount");
    // 固定本次错误回调对应的题目索引，避免异步后串到其他题目
    final int quizIndex = currentQuizIndex.value;
    questionDataList[quizIndex].errorCount = errorCount;

    if (!isAutoSkip) {
      if (errorCount >= maxErrorCount) {
        ErrorLogUtils.to.logInfo("练习 ----- 错误次数达到上限，显示跳过按钮");
        isShowSkipButton.value = true;
      }
      return true;
    }

    if (errorCount >= maxErrorCount) {
      ErrorLogUtils.to.logInfo("练习 ----- 错误次数达到上限，自动跳过题目");
      await Future.delayed(const Duration(milliseconds: 300));

      isShowSkipButton.value = false;
      QuizLogModel? log = questionDataList[quizIndex].log;
      if (log == null) return false;
      log.status = QuizLogStatus.failed;
      log.endTime = DateTime.now();
      quizPlayOnResult(context, log, quizIndex);
    }
    return false;
  }

  /// 跳过当前题目
  Future<void> skipCurrentQuiz(BuildContext context) async {
    // 固定本次跳过操作对应的题目索引，避免异步后串到其他题目
    final int quizIndex = currentQuizIndex.value;
    ErrorLogUtils.to.logInfo("练习 ----- 用户跳过当前题目，索引: $quizIndex");

    FocusScope.of(context).requestFocus(FocusNode());
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    if (viewInsets > 0) {
      await Future.delayed(const Duration(milliseconds: 300));
    }
    isShowSkipButton.value = false;
    QuizLogModel? log = questionDataList[quizIndex].log;
    if (log == null) return;
    log.status = QuizLogStatus.skipping;
    log.endTime = DateTime.now();
    quizPlayOnResult(context, log, quizIndex);
  }

  /// 每道题的回调
  Future<void> quizPlayOnResult(BuildContext context, QuizLogModel log, int quizIndex) async {
    audioNetworkPlayErrClear();
    if (questionDataList.length > quizIndex) {
      ErrorLogUtils.to.logInfo("练习 ----- 题目做完回调开始 ${ErrorLogUtils.to.toSingleLineJsonSafe(questionDataList[quizIndex].data.toJson())}");
    }

    // 隐藏键盘
    FocusScope.of(context).requestFocus(FocusNode());

    // 记录当前题目的开始、结束和暂停时长快照
    questionDataList[quizIndex].quizStartTime ??= DateTime.now().toUtc();
    questionDataList[quizIndex].quizEndTime = DateTime.now().toUtc();
    quizStartTime = questionDataList[quizIndex].quizStartTime;

    // 获取当前做题的时长
    int quizDuration = questionDataList[quizIndex].quizEndTime!.difference(questionDataList[quizIndex].quizStartTime!).inSeconds;

    // 减去暂停的时长
    quizDuration -= questionDataList[quizIndex].pauseDurationSecond;
    if (quizDuration < 0) {
      quizDuration = 0;
    }

    // 使用固定题目索引判断题目状态，避免切题后串到当前题
    bool isLastQuiz = quizIndex >= questionDataList.length - 1;
    if (isLastQuiz) {
      isFinishingLastQuiz.value = true;
      // quizStateController.add(QuizStateType.pauseAllState);
      await _closeOverlaysSafely(context);
      // unawaited(QuizPlayResourceManager.dispose());
      ErrorLogUtils.to.logInfo("练习 ----- 当前列表最后一道题目 ${ErrorLogUtils.to.toSingleLineJsonSafe(questionDataList[quizIndex].data.toJson())}");
      ToastUtils.showLoading();
      if (log.isReport) {
        // 最后一道题需要等待
        ErrorLogUtils.to.logInfo("练习 ----- 等待最后一道题目准备上报 ${ErrorLogUtils.to.toSingleLineJsonSafe(questionDataList[quizIndex].data.toJson())}");
        await reportQuestion(quizDuration, quizIndex, log);
      }

      // 只有当前题仍然是这道题时，才执行最后一题的返回逻辑
      if (quizIndex == currentQuizIndex.value) {
        backPage(context);
      }
      return;
    }

    if (log.isReport) {
      reportQuestion(quizDuration, quizIndex, log);
    }

    // 只有当前题仍然是这道题时，才继续自动切到下一题
    if (quizIndex == currentQuizIndex.value) {
      nextQuestion();
    }
  }

  /// 中途上报
  void onLogMidwayReport(QuizLogModel log, int quizIndex) {
    // 记录当前题目的开始、结束和暂停时长快照
    questionDataList[quizIndex].quizStartTime ??= DateTime.now().toUtc();
    questionDataList[quizIndex].quizEndTime = DateTime.now().toUtc();
    quizStartTime = questionDataList[quizIndex].quizStartTime;

    // 获取当前做题的时长
    int quizDuration = questionDataList[quizIndex].quizEndTime!.difference(questionDataList[quizIndex].quizStartTime!).inSeconds;

    // 减去暂停的时长
    quizDuration -= questionDataList[quizIndex].pauseDurationSecond;
    if (quizDuration < 0) {
      quizDuration = 0;
    }
    reportQuestion(quizDuration, quizIndex, log);
  }

  /// 下一题
  void nextQuestion() {
    ErrorLogUtils.to.logInfo("练习 ----- 准备切换到下一题，当前索引: ${currentQuizIndex.value} -> ${currentQuizIndex.value + 1}");
    // 记录上一题的索引
    previousQuizIndex = currentQuizIndex.value;

    currentQuizIndex.value++;
    originalQuizIndex.value = currentQuizIndex.value;

    // 初始化新题目本轮计时数据
    questionDataList[currentQuizIndex.value].quizStartTime = DateTime.now().toUtc();
    questionDataList[currentQuizIndex.value].quizEndTime = null;
    questionDataList[currentQuizIndex.value].pauseDurationSecond = 0;

    // 重新设置当前题目的全局计时状态
    quizStartTime = questionDataList[currentQuizIndex.value].quizStartTime;
    pauseDurationSecond = 0;

    startSkipTimer();
    isShowSkipButton.value = false;

    isSoundAccountValid();

    cacheQuizAssets();

    scrollIndicator();

    ErrorLogUtils.to.logInfo("练习 ----- 切换到下一题完成，新题目索引: ${currentQuizIndex.value}");
  }

  /// 关闭公告
  void closeAnnouncement() {
    isShowAnnouncement.value = false;
  }

  /// 判断是不是最后一题 如果是最后一题返回true
  bool isLastQuizInGroup() {
    if (currentQuizIndex.value >= questionDataList.length - 1) {
      return true;
    }
    return false;
  }

  /// 滚动指示器
  void scrollIndicator() {
    // 在UI更新后执行滚动操作
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 检查ScrollController是否已经初始化且有内容
      if (!indicatorScrollController.hasClients || indicatorScrollController.position.maxScrollExtent <= 0) {
        return; // 如果没有滚动内容或滚动范围不够，直接返回
      }

      // 计算当前指示器的位置（假设每个指示器宽度约为60像素）
      double indicatorWidth = 60.wMin;
      double currentIndicatorPosition = currentQuizIndex.value * indicatorWidth;

      // 获取视口宽度
      double viewportWidth = indicatorScrollController.position.viewportDimension;

      // 计算目标滚动位置：让当前指示器居中显示
      double targetScrollPosition = currentIndicatorPosition - (viewportWidth / 2) + (indicatorWidth / 2);

      // 确保滚动位置在有效范围内
      targetScrollPosition = targetScrollPosition.clamp(0.0, indicatorScrollController.position.maxScrollExtent);

      // 检查是否需要滚动（如果目标位置与当前位置相同，则不需要滚动）
      if ((targetScrollPosition - indicatorScrollController.offset).abs() < 1.0) {
        return; // 位置差异很小，不需要滚动
      }

      // 执行滚动动画
      indicatorScrollController.animateTo(
        targetScrollPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  /// 全部题目做完的处理
  Future<void> backPage(BuildContext context, {bool manual = false, bool editQuiz = false}) async {
    quizStateController.add(QuizStateType.pauseAllState);
    endPractice.value = true;
    countdownTimer?.cancel();

    ErrorLogUtils.to.logInfo("练习 ----- 开始退出练习页面");

    if (editQuiz && isAdminPage) {
      // 如果是编辑那么带上编辑标识替换掉当前路由到编辑页面
      editQuizPageRoute();
      return;
    }

    if (isPause.value) {
      ErrorLogUtils.to.logInfo("练习 ----- 退出练习页面 - 暂停状态");
      quizStateController.add(QuizStateType.pauseAllState);
      isPause.value = false;
      if (Get.isOverlaysOpen == true) {
        Get.back();
      }
      // Get.delete<PracticeQuestionsController>();
    }

    if (!questionIsReport) {
      ToastUtils.hideLoading();
      quizStateController.add(QuizStateType.pauseAllState);
      Get.back(result: {
        "manual": manual,
      });
      // Get.delete<PracticeQuestionsController>();
      return;
    }

    if (reportStart) {
      while (reportStart) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      await Future.delayed(const Duration(milliseconds: 1000));
    }
    quizStateController.add(QuizStateType.pauseAllState);
    if (manual) {
      /// 显示收集卡片 所有的刷新在这里面做 手动退出显示手机卡片
      await ElementsCollectResultDialog.checkNewCard(context: context);
    } else {
      /// 显示收集卡片 所有的刷新在这里面做
      await ElementsCollectResultDialog.checkNewCard(context: context, isCollectCard: isCollectCard);
    }

    ErrorLogUtils.to.logInfo("练习 ----- 退出练习页面 - 完成所有操作 $manual");
    Get.back(result: {
      "manual": manual,
    });
  }

  /// 跳转至编辑题目页面 管理端
  void editQuizPageRoute() {
    if (!isAdminPage) return;
    if (currentQuizIndex.value >= questionDataList.length) return;
    String? type = questionDataList[currentQuizIndex.value].data.type;
    int? uid = questionDataList[currentQuizIndex.value].data.uid;
    if (type == null || type == "") return;
    String? manageRoute = QuizRoutesUtils.getEditQuizRouteNameByContentType(type);
    if (manageRoute == null || manageRoute == "") return;
    Get.back(result: {"isEdit": true, "quizId": uid, "manageRoute": manageRoute});
  }

  /// 获取升级卡片的列表
  Future<void> getUpdateCardList() async {
    ElementsRequest.getUpdateCardList();
  }

  void loadingError() {
    ToastUtils.showToast(text: "题目加载失败！");
    Future.delayed(const Duration(milliseconds: 1000), () {
      Get.back();
    });
  }

  /// 上报题目记录
  Future<void> reportQuestion(int quizDuration, int quizIndex, QuizLogModel log) async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.exerciseRecordSubmit)) return;
    if (!questionIsReport) {
      ErrorLogUtils.to.logInfo("练习 ----- 跳过上报，questionIsReport: false");
      return;
    }
    if (endPractice.value) {
      ErrorLogUtils.to.logInfo("练习 ----- 跳过上报，练习已结束");
      return;
    }

    reportStart = true;
    ErrorLogUtils.to.logInfo("练习 ----- 开始上报题目记录");

    try {
      QuizModel quizModel = questionDataList[quizIndex].data;

      // 上报时统一取题目级开始时间
      questionDataList[quizIndex].quizStartTime ??= DateTime.now().toUtc();
      String startTime = questionDataList[quizIndex].quizStartTime!.toIso8601String();

      Map<String, dynamic> data = PracticeQuestionsReqest.getSubmitData(
        quizModel,
        quizDuration,
        log,
        startTime,
      );
      ErrorLogUtils.to.logInfo("练习 ----- 上报数据准备完成: ${ErrorLogUtils.to.toSingleLineJsonSafe(data)}");

      List<QuestionReportResultEntity>? list = await PracticeQuestionsReqest.reportQuestion(data);
      if (list == null) {
        ErrorLogUtils.to.logError("练习 ----- 上报失败，返回数据为空", StackTrace.current);
        return;
      }
      if (list.isEmpty) {
        ErrorLogUtils.to.logError("练习 ----- 上报失败，返回数据列表为空", StackTrace.current);
        return;
      }
      QuestionReportResultEntity result = list.first;
      for (var element in questionDataList) {
        if (element.data.uid != result.exerciseId) continue;
        element.data.score = result.score;
        element.data.correct = result.correct;
        element.data.result = result.result;
      }
      questionDataList.refresh();
      ErrorLogUtils.to.logInfo("练习 ----- 上报题目记录完成，得分: ${list.first.score}，正确性: ${list.first.correct}");
    } catch (e, stackTrace) {
      ErrorLogUtils.to.logError("练习 ----- 上报题目记录发生错误: $e", stackTrace);
    } finally {
      reportStart = false;
      ErrorLogUtils.to.logInfo("练习 ----- 上报流程结束，reportStart: false");
    }
  }

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

  /// 点击暂停
  void showQuizNumber(BuildContext context) async {
    if (isClosed) return;
    ErrorLogUtils.to.logInfo("练习 ----- 用户点击暂停，当前题目索引: ${currentQuizIndex.value}");
    // 隐藏键盘
    FocusScope.of(context).requestFocus(FocusNode());
    if (endPractice.value) {
      return;
    }
    if (isFinishingLastQuiz.value) {
      return;
    }
    isPause.value = true;
    countdownTimer?.cancel();
    quizStateController.add(QuizStateType.pauseAllState);
    DateTime currentPauseTime = DateTime.now().toUtc();
    startQuizPauseTimer();

    if (ShowBigResourceDialog.isShow) {
      Get.back();
    }

    ErrorLogUtils.to.logInfo("练习 ----- 暂停弹窗弹出，当前题目索引: ${currentQuizIndex.value}");
    int? indexRes = await PracticeQuestionsNumberDialog.showTestQuizList(
      context: context,
      questionDataList: questionDataList,
      currentQuizIndex: currentQuizIndex,
      originalQuizIndex: originalQuizIndex,
      isCanSwitchByNumber: isCanSwitchByNumber,
    );

    /// 退出
    if (indexRes == -1) {
      ErrorLogUtils.to.logInfo("练习 ----- 用户选择退出练习");
      isPause.value = false;
      ToastUtils.showLoading();
      quizStateController.add(QuizStateType.pauseAllState);
      backPage(context, manual: true);
      return;
    }
    FocusScope.of(context).requestFocus(FocusNode());

    // 继续
    ErrorLogUtils.to.logInfo("练习 ----- 用户继续练习");
    quizPauseTimer?.cancel();
    isPause.value = false;
    final bool shouldResumeBeforeSwitch = _shouldResumeBeforeSwitch(indexRes);
    if (shouldResumeBeforeSwitch) {
      quizStateController.add(QuizStateType.resumeAllState);
    }
    startCountdown();

    // 只有继续当前题目时，才累计本轮暂停时长
    if (indexRes == null || indexRes == currentQuizIndex.value) {
      questionDataList[currentQuizIndex.value].pauseDurationSecond += DateTime.now().toUtc().difference(currentPauseTime).inSeconds;
      pauseDurationSecond = questionDataList[currentQuizIndex.value].pauseDurationSecond;
    }

    if (indexRes == null || indexRes == currentQuizIndex.value) return;
    FocusScope.of(context).requestFocus(FocusNode());
    // 切题目
    ErrorLogUtils.to.logInfo("练习 ----- 用户切换题目，从索引 ${currentQuizIndex.value} 切换到 $indexRes");
    currentQuizIndex.value = indexRes;
    if (!shouldResumeBeforeSwitch) {
      ErrorLogUtils.to.logInfo("练习 ----- LISTEN_FIND_WORD 切题时跳过旧题 resume，交给新题自行初始化播放");
    }
    scrollIndicator();

    // 切换到新题后，重新初始化该题的本轮计时数据
    questionDataList[currentQuizIndex.value].quizStartTime = DateTime.now().toUtc();
    questionDataList[currentQuizIndex.value].quizEndTime = null;
    questionDataList[currentQuizIndex.value].pauseDurationSecond = 0;

    // 同步当前题目的全局计时状态
    quizStartTime = questionDataList[currentQuizIndex.value].quizStartTime;
    pauseDurationSecond = 0;
    startSkipTimer();
    cacheQuizAssets();
    audioNetworkPlayErrClear();
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

  /// 测试 直接完成任务
  Future<void> completeTask(BuildContext context) async {
    try {
      isPause.value = true;
      ToastUtils.showLoading();
      for (int i = 0; i < questionDataList.length; i++) {
        await reportQuestion(1, i, QuizLogModel());
      }
    } finally {
      isPause.value = false;
      ToastUtils.hideLoading();
      backPage(context);
    }
  }

  @override
  void onClose() {
    ErrorLogUtils.to.logInfo("练习 ----- PracticeQuestionsController 销毁开始");
    try {
      QuizPlayResourceManager.dispose();
      WakelockPlus.disable();
      quizStateController.close();
      indicatorScrollController.dispose();
      countdownTimer?.cancel();
      skipTimer?.cancel();
      quizPauseTimer?.cancel();
      WidgetsBinding.instance.removeObserver(this);
      ErrorLogUtils.to.logInfo("练习 ----- PracticeQuestionsController 资源清理完成");
    } catch (e, stackTrace) {
      ErrorLogUtils.to.logError(
          "练习 ----- PracticeQuestionsController 销毁时发生错误: $e", stackTrace);
    }
    super.onClose();
    ErrorLogUtils.to.logInfo("练习 ----- PracticeQuestionsController 销毁完成");
  }
}
