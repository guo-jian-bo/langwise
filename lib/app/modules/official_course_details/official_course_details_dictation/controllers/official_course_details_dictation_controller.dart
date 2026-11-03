import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/widgets/http_error_dialog.dart';
import 'package:langwise/common/widgets/icon_dropdown_widget.dart';
import 'package:langwise/utils/preview_audio_utils.dart';
import 'package:lib_common/common.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:video_player/video_player.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/public_controller/model/user_setting_model.dart';
import '../../../../../common/values/values.dart';
import '../../../../../utils/utils.dart';
import '../views/official_course_details_dictation_setting_dialog.dart';

class OfficialCourseDetailsDictationController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  OfficialCourseDetailsDictationController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.OFFICIAL_COURSE_DETAILS_DICTATION;

  @override
  String get breadcrumbTitle => "听写";

  String? moduleName; //书名称
  String? unitName; //单元名称
  bool enableLearnUpload = false;
  String? learnUploadType;
  bool _hasStartedLearnUpload = false;
  bool _hasStoppedLearnUpload = false;
  bool _isHandlingExit = false;
  static const String _learnRecordSource = 'official_course_details_dictation';

  /// 知识点列表参数
  List<UnitKnowledgePointsEntityKnowledgeList>? knowledgeListArgs = [];

  /// 知识点列表
  final RxList<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = <UnitKnowledgePointsEntityKnowledgeList>[].obs;

  /// 当前选中的知识点类型
  final RxList<ElementsCardType> selectedKnowledgeTypes = <ElementsCardType>[].obs;

  /// 播放次数
  final Rx<int> playNum = 1.obs;

  /// 当前播放次数
  final Rx<int> currentPlayNum = 0.obs;

  /// 停顿间隔
  final Rx<double> pauseInterval = 10.0.obs;

  /// 播放速度
  final Rx<double> playSpeed = 1.0.obs;

  /// 播放模式
  final Rx<PlayerModeEnum> playMode = PlayerModeEnum.order.obs;

  // 播放进度
  RxInt progress = 0.obs;

  /// 播放状态
  RxBool playStatus = false.obs;

  /// 默写是否完成
  RxBool isDictationComplete = false.obs;

  /// 再听一遍
  RxBool isListenAgain = false.obs;

  /// 英音、美音
  final Rx<LanguageServiceCodeEnum> national = LanguageServiceCodeEnum.US.obs;

  late PreviewAudioUtils audioPlaybackUtils;

  StreamSubscription? _playerCompleteSubscription; //音频播放完成的流订阅

  /// 播放完成后延时切换用的定时器
  Timer? _playCompleteTimer;

  final Random _random = Random();
  final List<int> _randomPlaybackOrder = <int>[];
  int _randomPlaybackCursor = -1;

  RxInt totalDurationTime = 0.obs; //总时长

  /// 是否正在切换音频，防止并发 prepare 导致 just_audio 崩溃
  bool _isSwitchingAudio = false;

  /// 等待中的下一首（在频繁点击时只保留最后一次请求）
  UnitKnowledgePointsEntityKnowledgeList? _pendingAudioModel;
  final Map<String, String> _cachedImagePathMap = <String, String>{};
  final Map<String, String> _cachedAudioPathMap = <String, String>{};
  final Map<String, String> _cachedVideoPathMap = <String, String>{};
  final Set<String> _cachingMediaKeys = <String>{};
  bool _hasShownCacheNetworkErrorToast = false;

  /// * 语言显示设置菜单
  final List<IconDropdownCheckData<String>> learLangShowSettingMenu = [
    IconDropdownCheckData<String>(value: "US", title: "美音"),
    IconDropdownCheckData<String>(value: "UK", title: "英音"),
  ];

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    HardwareKeyboard.instance.addHandler(_handleGlobalKeyEvent);
    initUserSetting();
    audioPlaybackUtils = PreviewAudioUtils();



    if (Get.arguments != null) {  
      moduleName = Get.arguments["moduleName"];
      unitName = Get.arguments["unitName"];
      enableLearnUpload = Get.arguments["enableLearnUpload"] == true;
      learnUploadType = Get.arguments["learnUploadType"]?.toString();
      knowledgeListArgs = List<UnitKnowledgePointsEntityKnowledgeList>.from(Get.arguments["knowledgeList"]);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) {
        playSetting(isFirst: true);
      }
    });
  }

    /// 获取本地储存的设置
  Future<void> initUserSetting() async{
    AudioControlSettingModel? setting = AudioControlUtils.getSetting();
    if(Get.isRegistered<ConfigController>()){
      UserSettingModel userSetting = Get.find<ConfigController>().userSetting.value;
      playSpeed.value = userSetting.expandAudioSpeed;
      national.value = LanguageServiceCodeEnum.fromValue(userSetting.expandPronunciationCode);
      final List<double> intervalList = (userSetting.intervalMenu ?? const [])
          .map((e) => e.value!)
          .toList();
      pauseInterval.value = _resolveSharedInterval(
        intervalList: intervalList,
        sharedInterval: userSetting.expandInterval,
        fallback: intervalList.isNotEmpty ? intervalList.first : 5,
      );
      playMode.value = _resolveDictationPlayMode(
        userSetting.expandPlayOrder.isNotEmpty
            ? userSetting.expandPlayOrder
            : setting?.playOrder?.value,
      );
      playNum.value = _resolveSharedLoopCount(
        userSetting.expandPlayOrderLoopCount > 0
            ? userSetting.expandPlayOrderLoopCount
            : setting?.playOrderLoopCount,
        max: 3,
      );
    }
  }

  @override
  void onClose() {
    if (enableLearnUpload && !_hasStoppedLearnUpload) {
      unawaited(LearnRecordManager.instance.stopTracking(source: _learnRecordSource));
    }
    super.onClose();
    HardwareKeyboard.instance.removeHandler(_handleGlobalKeyEvent);
    audioPlaybackUtils.stop();
    audioPlaybackUtils.setNavigationHandlers(onNext: null, onPrevious: null);
    _playerCompleteSubscription?.cancel();
    _playCompleteTimer?.cancel();
    _playCompleteTimer = null;
    ToastUtils.hideLoading();
  }

  Future<void> handleExit() async {
    if (_isHandlingExit) return;
    _isHandlingExit = true;
    try {
      if (enableLearnUpload && !_hasStoppedLearnUpload) {
        ToastUtils.showLoading();
        await LearnRecordManager.instance.stopTracking(source: _learnRecordSource);
        _hasStoppedLearnUpload = true;
      }
      if (!isClosed) {
        Get.back(result: const {'learnUploadFinished': true});
      }
    } finally {
      ToastUtils.hideLoading();
      _isHandlingExit = false;
    }
  }

  /// 初始化音频播放器
  void audioPlayerInit() {
    audioPlaybackUtils.setNavigationHandlers(
      onNext: () => nextProgress(),
      onPrevious: () => preProgress(),
    );
    audioPlaybackUtils.setPlaybackRate(playSpeed.value);
    _playerCompleteSubscription?.cancel();
    _playCompleteTimer?.cancel();
    _playerCompleteSubscription = audioPlaybackUtils.playCompleteStream.listen((state) {
      if (audioPlaybackUtils.isPlaying) return;
      // 播放完成沿用你已有的逻辑
      int durationTime;
      if (currentPlayNum.value < playNum.value - 1) {
        // 同一个知识点内部的重复，一律 1s 间隔
        durationTime = 1000;
      } else {
        // 最后一次播放完，切到下一个知识点，用设置里的停顿间隔
        durationTime = (totalDurationTime.value * pauseInterval.value).toInt();
      }
      int oldProgress = progress.value;
      _playCompleteTimer?.cancel();
      _playCompleteTimer = Timer(Duration(milliseconds: durationTime), () async {
        if (isClosed) {
          return;
        }

        if (isListenAgain.value) {
          isListenAgain.value = false;
        }

        currentPlayNum.value++;
        if (playStatus.value && oldProgress == progress.value) {
          if (currentPlayNum.value >= playNum.value) {
            if (_moveToPlaybackStep(forward: true)) {
              currentPlayNum.value = 0;
              _markKnowledgeViewed(_currentKnowledge);
              newAudioPlayer(_currentKnowledge);
            } else {
              await _enterDictationComplete();
            }
          } else {
            newAudioPlayer(knowledgeList[progress.value]);
          }
        }
      });
    });
  }

  /// 设置新的音频
  Future<void> newAudioPlayer(UnitKnowledgePointsEntityKnowledgeList? model) async {
    if (model == null || isClosed || isDictationComplete.value) return;
    // 如果当前正在切换音频，则只记录最新的一次请求，等当前切换完成再处理
    if (_isSwitchingAudio) {
      _pendingAudioModel = model;
      return;
    }

    _isSwitchingAudio = true;
    _pendingAudioModel = null;

    unawaited(_cacheDictationAssets());

    final PronunciationsEntity? pronunciationModel =
        _resolvePlayablePronunciation(model);

    String urlString = pronunciationModel?.audioUrl ?? '';
    if (urlString.isEmpty) {
      _isSwitchingAudio = false;
      nextProgress();
      return;
    }

    try {
      //获取音频总时长
      totalDurationTime.value = pronunciationModel?.duration != null ? (pronunciationModel!.duration! * 1000).toInt() : 0;

      // 串行化 stop + prepare，避免在还没处理完前再次 prepare
      await audioPlaybackUtils.stop();

      // 提供锁屏信息（可按需丰富）
      await audioPlaybackUtils.prepare(
        url: urlString,
        title: '听写模式',
        artist: moduleName ?? '',
        album: unitName ?? '',
        playSpeed: playSpeed.value,
        duration: Duration(milliseconds: totalDurationTime.value),
        image: _resolveAudioArtworkUri(model),
        androidCompactActionIndices: const [0, 1, 2],
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (!isClosed && !isDictationComplete.value) {
        await audioPlaybackUtils.resume();
        playStatus.value = true;
      }
    } catch (e) {
      debugPrint('dictation newAudioPlayer error: $e');
    } finally {
      _isSwitchingAudio = false;

      final nextModel = _pendingAudioModel;
      if (nextModel != null && !isClosed && !isDictationComplete.value) {
        _pendingAudioModel = null;
        unawaited(newAudioPlayer(nextModel));
      }
    }
  }

  //播放 暂停
  void audioPlayAndPause(bool status) async {
    if (status) {
      await audioPlaybackUtils.resume();
      playStatus.value = true;
    } else {
      await audioPlaybackUtils.pause();
      playStatus.value = false;
    }
  }

  // knowledgeListArgs 原参
  // knowledgeList 当前筛选后的原始顺序列表
  // progress 当前播放下标
  void changePlayMode(PlayerModeEnum mode) {
    if (knowledgeListArgs == null || knowledgeListArgs!.isEmpty) return;
    final UnitKnowledgePointsEntityKnowledgeList? currentKnowledge = _currentKnowledge;
    final int previousProgress = progress.value;
    playMode.value = mode;
    final List<UnitKnowledgePointsEntityKnowledgeList> filteredList =
        _buildFilteredKnowledgeListBySelectedTypes(knowledgeListArgs!);
    _applyPlaybackModeToKnowledgeList(
      filteredList: filteredList,
      currentKnowledge: currentKnowledge,
      previousProgress: previousProgress,
      restartFromBoundary:
          playMode.value == PlayerModeEnum.reverse && currentKnowledge == null,
    );
    currentPlayNum.value = 0;
    isDictationComplete.value = false;
    isListenAgain.value = false;
    audioPlayerInit();
    if (knowledgeList.isNotEmpty) {
      _markKnowledgeViewed(_currentKnowledge);
      unawaited(newAudioPlayer(_currentKnowledge));
    }
    Get.find<ConfigController>().setUserSetting(
      expandPlayOrder: playMode.value.value,
    );
    AudioControlUtils.saveSetting(AudioControlSettingModel(playOrder: playMode.value));
  }

  Future<void> changePlayNum(int loopCount) async {
    if (playNum.value > loopCount) {
      playNum.value = loopCount;
    } else {
      playNum.value = loopCount;
      currentPlayNum.value = 0;
      await audioPlaybackUtils.stop();
      audioPlayerInit();
      newAudioPlayer(knowledgeList[progress.value]);
    }
    Get.find<ConfigController>().setUserSetting(
      expandPlayOrderLoopCount: playNum.value,
    );
    AudioControlUtils.saveSetting(AudioControlSettingModel(playOrderLoopCount: playNum.value));
  }

  void changePlaySpeed(double speed) {
    playSpeed.value = speed;
    audioPlaybackUtils.setPlaybackRate(speed);
    ConfigController configController = Get.find<ConfigController>();
    configController.setUserSetting(expandAudioSpeed: speed);
  }

  void setLanguageSetting(String nationalCode) {
    national.value = LanguageServiceCodeEnum.fromValue(nationalCode);
  }

  /// 播放设置
  void playSetting({bool isFirst = false}) async {
    if (knowledgeListArgs == null) return;

    final bool wasPlaying = playStatus.value;
    final UnitKnowledgePointsEntityKnowledgeList? currentKnowledge =
        _currentKnowledge;
    final int previousProgress = progress.value;
    await _pausePlaybackForSetting();

    List<UnitKnowledgePointsEntityKnowledgeList> words = [];
    List<UnitKnowledgePointsEntityKnowledgeList> phrases = [];
    List<UnitKnowledgePointsEntityKnowledgeList> sentences = [];

    for (int i = 0; i < knowledgeListArgs!.length; i++) {
      if(knowledgeListArgs![i].pronunciations == null) continue;
      if (knowledgeListArgs![i].isWord) {
        words.add(knowledgeListArgs![i]);
      } else if (knowledgeListArgs![i].isPhrase) {
        phrases.add(knowledgeListArgs![i]);
      } else if (knowledgeListArgs![i].isSentence) {
        sentences.add(knowledgeListArgs![i]);
      }
    }

    List<DictationSettingKnowledgeTypeItemModel> knowledgePoints = [];
    if (words.isNotEmpty) {
      knowledgePoints.add(DictationSettingKnowledgeTypeItemModel(
        type: ElementsCardType.word,
        typeText: '单词',
        count: words.length,
      ));
    }
    if (phrases.isNotEmpty) {
      knowledgePoints.add(DictationSettingKnowledgeTypeItemModel(
        type: ElementsCardType.phrase,
        typeText: '短语',
        count: phrases.length,
      ));
    }
    if (sentences.isNotEmpty) {
      knowledgePoints.add(DictationSettingKnowledgeTypeItemModel(
        type: ElementsCardType.sentence,
        typeText: '句子',
        count: sentences.length,
      ));
    }

    DictationSettingModel? newGraph = await OfficialCourseDetailsDictationSettingDialog.show(
      context: Get.context!,
      initSetting: DictationSettingModel(
        knowledgePoints: knowledgePoints,
        selectedKnowledgePoints: selectedKnowledgeTypes.isEmpty
            ? knowledgePoints.map((e) => e.type).toList()
            : knowledgePoints
                .where((e) => selectedKnowledgeTypes.contains(e.type))
                .map((e) => e.type)
                .toList(),
        playNum: playNum.value,
        pauseInterval: pauseInterval.value,
        playOrder: playMode.value,
        national: national.value,
        playSpeed: playSpeed.value,
      ),
    );

    if (isFirst) {
      if (newGraph == null) {
        Get.back();
        return;
      } else {
        audioPlayerInit();
      }
    } else {
      if (newGraph == null) {
        if (wasPlaying && currentKnowledge != null) {
          newAudioPlayer(currentKnowledge);
        }
        return;
      }
    }

    playStatus.value = false;
    await audioPlaybackUtils.stop();
    currentPlayNum.value = 0;
    isDictationComplete.value = false;

    playNum.value = newGraph.playNum;
    pauseInterval.value = newGraph.pauseInterval;
    StorageUtil().setDouble(INTERVAL_SPEED_KEY, pauseInterval.value);
    playMode.value = newGraph.playOrder;
    national.value = newGraph.national;
    playSpeed.value = newGraph.playSpeed;
    selectedKnowledgeTypes.value = newGraph.selectedKnowledgePoints.toList();
    await audioPlaybackUtils.setPlaybackRate(playSpeed.value);
    Get.find<ConfigController>().setUserSetting(
      expandAudioSpeed: newGraph.playSpeed,
      expandPronunciationCode: national.value.value,
      expandInterval: pauseInterval.value,
      expandPlayOrder: playMode.value.value,
      expandPlayOrderLoopCount: playNum.value,
    );
    AudioControlUtils.saveSetting(
      AudioControlSettingModel(
        playbackRate: playSpeed.value,
        playOrder: playMode.value,
        playOrderLoopCount: playNum.value,
      ),
    );

    final List<UnitKnowledgePointsEntityKnowledgeList> filteredList =
        _buildFilteredKnowledgeListBySelectedTypes(knowledgeListArgs!);
    _applyPlaybackModeToKnowledgeList(
      filteredList: filteredList,
      currentKnowledge: currentKnowledge,
      previousProgress: previousProgress,
      restartFromBoundary:
          playMode.value == PlayerModeEnum.reverse && currentKnowledge == null,
    );
    if (knowledgeList.isEmpty) {
      return;
    }
    unawaited(_cacheDictationAssets());
    await _startLearnUploadIfNeeded();
    _markKnowledgeViewed(_currentKnowledge);
    newAudioPlayer(_currentKnowledge);
  }

  Future<void> _startLearnUploadIfNeeded() async {
    if (!enableLearnUpload || _hasStartedLearnUpload || knowledgeList.isEmpty) return;
    _hasStartedLearnUpload = true;
    await LearnRecordManager.instance.startTracking(
      source: _learnRecordSource,
      type: learnUploadType,
    );
  }

  /// 上一个
  Future<void> preProgress() async {
    debugPrint('上一个被点击');
    if (_moveToPlaybackStep(forward: false)) {
      isListenAgain.value = true;
      currentPlayNum.value = 0;
      _markKnowledgeViewed(_currentKnowledge);
      newAudioPlayer(_currentKnowledge);
    } else {
      ToastUtils.showToast(text: '当前已是第一个');
    }
  }

  /// 下一个
  Future<void> nextProgress() async {
    if (_moveToPlaybackStep(forward: true)) {
      isListenAgain.value = true;
      currentPlayNum.value = 0;
      _markKnowledgeViewed(_currentKnowledge);
      await newAudioPlayer(_currentKnowledge);
      isListenAgain.value = false;
    } else {
      await _enterDictationComplete();
    }
  }

  /// 再听一遍
  void reListen() async {
    await audioPlaybackUtils.stop();
    currentPlayNum.value = 0;
    isListenAgain.value = true;
    newAudioPlayer(knowledgeList[progress.value]);
  }

  /// 重新听写
  void redictation() {
    if (knowledgeList.isEmpty) return;
    currentPlayNum.value = 0;
    isDictationComplete.value = false;
    isListenAgain.value = false;
    if (playMode.value == PlayerModeEnum.reverse) {
      _clearRandomPlaybackState();
      progress.value = knowledgeList.length - 1;
    } else if (playMode.value == PlayerModeEnum.random) {
      progress.value = 0;
      _resetRandomPlaybackState(currentIndex: progress.value);
    } else {
      _clearRandomPlaybackState();
      progress.value = 0;
    }
    _markKnowledgeViewed(_currentKnowledge);
    newAudioPlayer(_currentKnowledge);
    isListenAgain.value = false;
  }

  /// 开始核验
  void beginCheck() {
    TagRoutes.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS_DICTATION_CHECK,
      arguments: {
        "knowledgeList": _buildKnowledgeListForCheck(),
      },
    );
  }

  /// 键盘事件处理
  bool _handleGlobalKeyEvent(KeyEvent event) {
    if (knowledgeList.isEmpty || isDictationComplete.value) return true;
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        audioPlayAndPause(!playStatus.value);
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        preProgress();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        nextProgress();
        return true;
      }
    }
    return true;
  }

  String get currentPronunciationLabel => national.value.text;

  String get currentPauseLabel {
    final List<UserPreferenceIntervalSpeedOption> menu =
        Get.find<ConfigController>().userSetting.value.intervalMenu ?? [];
    for (final item in menu) {
      if (item.value == pauseInterval.value) {
        return '节奏${item.title ?? pauseInterval.value}';
      }
    }
    return '节奏${pauseInterval.value}';
  }

  String get currentPlayModeLabel => playMode.value.title;

  String get currentRepeatLabel => '循环次数 ${playNum.value}次';

  String get currentSpeedLabel => '倍速 ${playSpeed.value.toStringAsFixed(1)}x';

  PronunciationsEntity? _resolvePlayablePronunciation(
    UnitKnowledgePointsEntityKnowledgeList knowledge,
  ) {
    final List<PronunciationsEntity?> pronunciations = knowledge.pronunciations ?? [];
    for (final item in pronunciations) {
      if (item == null) continue;
      if (item.national == national.value.value &&
          (item.audioUrl?.isNotEmpty ?? false)) {
        return item;
      }
    }
    for (final item in pronunciations) {
      if (item == null) continue;
      if (item.audioUrl?.isNotEmpty ?? false) {
        return item;
      }
    }
    return null;
  }

  Uri? _resolveAudioArtworkUri(
    UnitKnowledgePointsEntityKnowledgeList knowledge,
  ) {
    final List<String?> candidateUrls = <String?>[
      knowledge.video?.firstFrameUrl,
      knowledge.imageUrl,
    ];
    for (final String? rawUrl in candidateUrls) {
      final String url = rawUrl?.trim() ?? '';
      if (url.isEmpty) continue;
      final String resolvedPath = _cachedImagePathMap[url] ?? url;
      if (resolvedPath.startsWith('/') ||
          RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(resolvedPath) ||
          resolvedPath.startsWith(r'\\')) {
        return Uri.file(resolvedPath);
      }
      return Uri.tryParse(resolvedPath);
    }
    return null;
  }

  void _notifyCacheNetworkFailure() {
    if (_hasShownCacheNetworkErrorToast || isClosed) return;
    _hasShownCacheNetworkErrorToast = true;
    if (playStatus.value) {
      audioPlayAndPause(false);
    }
    HttpErrorDialog.show();
  }

  Future<void> _cacheMediaFile(
    String? url,
    ResourceType type,
    Map<String, String> cacheMap, {
    int? timeoutMilliseconds,
  }) async {
    final String normalizedUrl = url?.trim() ?? '';
    if (normalizedUrl.isEmpty || !GetUtils.isURL(normalizedUrl)) return;
    if (cacheMap.containsKey(normalizedUrl)) return;
    final String cacheKey = '${type.toString()}::$normalizedUrl';
    if (!_cachingMediaKeys.add(cacheKey)) return;
    try {
      final String? localPath = await CacheManagerUtils.instance.getFile(
        normalizedUrl,
        type,
        timeoutMilliseconds: timeoutMilliseconds,
      );
      if (localPath == null || localPath.isEmpty) {
        _notifyCacheNetworkFailure();
        return;
      }
      if (isClosed) return;
      cacheMap[normalizedUrl] = localPath;
    } finally {
      _cachingMediaKeys.remove(cacheKey);
    }
  }

  Future<void> _cacheKnowledgeAssets(
    UnitKnowledgePointsEntityKnowledgeList? knowledge,
  ) async {
    if (knowledge == null || isClosed) return;
    await _cacheMediaFile(
      knowledge.imageUrl,
      ResourceType.image,
      _cachedImagePathMap,
    );
    await _cacheMediaFile(
      knowledge.video?.firstFrameUrl,
      ResourceType.image,
      _cachedImagePathMap,
    );
    await _cacheMediaFile(
      knowledge.video?.videoUrl,
      ResourceType.video,
      _cachedVideoPathMap,
      timeoutMilliseconds: 3000,
    );
    await _cacheMediaFile(
      _resolvePlayablePronunciation(knowledge)?.audioUrl,
      ResourceType.audio,
      _cachedAudioPathMap,
      timeoutMilliseconds: 3000,
    );
  }

  Future<void> _cacheDictationAssets() async {
    if (knowledgeList.isEmpty) return;
    final int currentIndex = progress.value.clamp(0, knowledgeList.length - 1);
    final int startIndex = max(0, currentIndex - 1);
    final int endIndex = min(knowledgeList.length - 1, currentIndex + 3);
    await _cacheKnowledgeAssets(knowledgeList[currentIndex]);
    for (int i = startIndex; i <= endIndex; i++) {
      if (i == currentIndex) continue;
      unawaited(_cacheKnowledgeAssets(knowledgeList[i]));
    }
  }

  PlayerModeEnum _resolveDictationPlayMode(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) {
      return PlayerModeEnum.order;
    }
    final PlayerModeEnum mode = PlayerModeEnum.fromRawValue(rawValue);
    if (mode == PlayerModeEnum.order ||
        mode == PlayerModeEnum.reverse ||
        mode == PlayerModeEnum.random) {
      return mode;
    }
    return PlayerModeEnum.order;
  }

  double _resolveSharedInterval({
    required List<double> intervalList,
    required double sharedInterval,
    required double fallback,
  }) {
    if (intervalList.isEmpty) return fallback;
    return intervalList.contains(sharedInterval) ? sharedInterval : fallback;
  }

  int _resolveSharedLoopCount(int? loopCount, {required int max}) {
    final int value = loopCount ?? 1;
    return value.clamp(1, max);
  }

  Future<void> _pausePlaybackForSetting() async {
    _playCompleteTimer?.cancel();
    _playCompleteTimer = null;
    if (audioPlaybackUtils.isPlaying) {
      await audioPlaybackUtils.pause();
    }
    playStatus.value = false;
  }

  Future<void> _enterDictationComplete() async {
    currentPlayNum.value = 0;
    isDictationComplete.value = true;
    _pendingAudioModel = null;
    _playCompleteTimer?.cancel();
    _playCompleteTimer = null;
    playStatus.value = false;
    await audioPlaybackUtils.hardStop();
  }

  UnitKnowledgePointsEntityKnowledgeList? get _currentKnowledge {
    if (knowledgeList.isEmpty) return null;
    if (progress.value < 0 || progress.value >= knowledgeList.length) return null;
    return knowledgeList[progress.value];
  }

  void _markKnowledgeViewed(UnitKnowledgePointsEntityKnowledgeList? knowledge) {
    if (!enableLearnUpload || knowledge == null) return;
    unawaited(LearnRecordManager.instance.markContentViewed(knowledge));
  }

  int _resolveProgressForUpdatedKnowledgeList({
    required UnitKnowledgePointsEntityKnowledgeList? currentKnowledge,
    required int previousProgress,
  }) {
    if (knowledgeList.isEmpty) return 0;
    if (currentKnowledge != null) {
      final int currentIndex = knowledgeList.indexWhere(
        (item) => _isSameKnowledge(item, currentKnowledge),
      );
      if (currentIndex != -1) {
        return currentIndex;
      }
    }
    return previousProgress.clamp(0, knowledgeList.length - 1);
  }

  void _applyPlaybackModeToKnowledgeList({
    required List<UnitKnowledgePointsEntityKnowledgeList> filteredList,
    required UnitKnowledgePointsEntityKnowledgeList? currentKnowledge,
    required int previousProgress,
    bool restartFromBoundary = false,
  }) {
    knowledgeList.value = filteredList.toList();
    if (knowledgeList.isEmpty) {
      _clearRandomPlaybackState();
      progress.value = 0;
      return;
    }
    if (playMode.value == PlayerModeEnum.random) {
      progress.value = restartFromBoundary
          ? 0
          : _resolveProgressForUpdatedKnowledgeList(
              currentKnowledge: currentKnowledge,
              previousProgress: previousProgress,
            );
      _resetRandomPlaybackState(currentIndex: progress.value);
      return;
    }
    _clearRandomPlaybackState();
    if (playMode.value == PlayerModeEnum.reverse) {
      progress.value = restartFromBoundary
          ? knowledgeList.length - 1
          : _resolveProgressForUpdatedKnowledgeList(
              currentKnowledge: currentKnowledge,
              previousProgress: previousProgress,
            );
      return;
    }
    progress.value = restartFromBoundary
        ? 0
        : _resolveProgressForUpdatedKnowledgeList(
            currentKnowledge: currentKnowledge,
            previousProgress: previousProgress,
          );
  }

  bool _moveToPlaybackStep({required bool forward}) {
    if (knowledgeList.isEmpty) return false;
    if (playMode.value == PlayerModeEnum.random) {
      return forward
          ? _moveToNextRandomKnowledge()
          : _moveToPreviousRandomKnowledge();
    }
    final int nextIndex = _resolveNextProgressIndex(forward: forward);
    if (nextIndex < 0 || nextIndex >= knowledgeList.length) {
      return false;
    }
    progress.value = nextIndex;
    return true;
  }

  int _resolveNextProgressIndex({required bool forward}) {
    if (playMode.value == PlayerModeEnum.reverse) {
      return forward ? progress.value - 1 : progress.value + 1;
    }
    return forward ? progress.value + 1 : progress.value - 1;
  }

  void _resetRandomPlaybackState({required int currentIndex}) {
    if (knowledgeList.isEmpty) {
      _clearRandomPlaybackState();
      return;
    }
    final int resolvedIndex = currentIndex.clamp(0, knowledgeList.length - 1);
    _randomPlaybackOrder
      ..clear()
      ..add(resolvedIndex);
    _randomPlaybackCursor = 0;
  }

  void _clearRandomPlaybackState() {
    _randomPlaybackOrder.clear();
    _randomPlaybackCursor = -1;
  }

  bool _moveToPreviousRandomKnowledge() {
    if (_randomPlaybackCursor <= 0) return false;
    _randomPlaybackCursor--;
    progress.value = _randomPlaybackOrder[_randomPlaybackCursor];
    return true;
  }

  bool _moveToNextRandomKnowledge() {
    if (knowledgeList.isEmpty) return false;
    if (_randomPlaybackCursor >= 0 &&
        _randomPlaybackCursor < _randomPlaybackOrder.length - 1) {
      _randomPlaybackCursor++;
      progress.value = _randomPlaybackOrder[_randomPlaybackCursor];
      return true;
    }
    final int? nextIndex = _pickNextRandomKnowledgeIndex();
    if (nextIndex == null) return false;
    _randomPlaybackOrder.add(nextIndex);
    _randomPlaybackCursor = _randomPlaybackOrder.length - 1;
    progress.value = nextIndex;
    return true;
  }

  int? _pickNextRandomKnowledgeIndex() {
    if (knowledgeList.isEmpty) return null;
    final Set<int> visitedIndices = _randomPlaybackOrder.toSet();
    final List<int> candidateIndices = <int>[];
    for (int i = 0; i < knowledgeList.length; i++) {
      if (!visitedIndices.contains(i)) {
        candidateIndices.add(i);
      }
    }
    if (candidateIndices.isEmpty) return null;
    return candidateIndices[_random.nextInt(candidateIndices.length)];
  }

  List<UnitKnowledgePointsEntityKnowledgeList> _buildKnowledgeListForCheck() {
    if (playMode.value == PlayerModeEnum.reverse) {
      return knowledgeList.reversed.toList();
    }
    if (playMode.value == PlayerModeEnum.random &&
        _randomPlaybackOrder.isNotEmpty) {
      return _randomPlaybackOrder
          .map((index) => knowledgeList[index])
          .toList();
    }
    return knowledgeList.toList();
  }

  List<UnitKnowledgePointsEntityKnowledgeList> _buildFilteredKnowledgeListBySelectedTypes(
    List<UnitKnowledgePointsEntityKnowledgeList> source,
  ) {
    if (selectedKnowledgeTypes.isEmpty) {
      return source.toList();
    }
    return source
        .where((element) => selectedKnowledgeTypes.contains(element.cardType))
        .toList();
  }

  bool _isSameKnowledge(
    UnitKnowledgePointsEntityKnowledgeList left,
    UnitKnowledgePointsEntityKnowledgeList right,
  ) {
    if (left.semanticId != null &&
        right.semanticId != null &&
        left.contentType == right.contentType) {
      return left.semanticId == right.semanticId;
    }
    if (left.contentId != null &&
        right.contentId != null &&
        left.contentType == right.contentType) {
      return left.contentId == right.contentId;
    }
    if (left.uid != null && right.uid != null) {
      return left.uid == right.uid;
    }
    return left.content == right.content && left.audioUrl == right.audioUrl;
  }
}
