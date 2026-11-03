import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/elements/utils/elements_page_utils.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/http_error_dialog.dart';
import 'package:lib_common/utils/storage_util.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:video_player/video_player.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/public_controller/model/user_setting_model.dart';
import '../../../../../common/values/values.dart';
import '../../../../../utils/utils.dart';
import '../views/official_course_details_flash_setting_dialog.dart';

class OfficialCourseDetailsFlashNotesController extends GetxController with RoutesBreadcrumbMixin {
  static const String _bilingualCode = 'bilingual';
  static const String _originalCode = 'original';
  static const String _translationCode = 'translation';
  static const String _noneCode = 'none';

  final String tagText;
  OfficialCourseDetailsFlashNotesController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.OFFICIAL_COURSE_DETAILS_FLASH_NOTES;

  @override
  String get breadcrumbTitle => "闪记";

  List<UnitKnowledgePointsEntityKnowledgeList>? knowledgeListArgs;
  bool enableLearnUpload = false;
  String? learnUploadType;
  bool _hasStartedLearnUpload = false;
  bool _hasStoppedLearnUpload = false;
  bool _isHandlingExit = false;
  bool _isClosing = false;
  bool _hasReleasedVideoController = false;
  static const String _learnRecordSource = 'official_course_details_flash_notes';

  /// 知识点列表
  final RxList<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = <UnitKnowledgePointsEntityKnowledgeList>[].obs;

  /// 当前选中的知识点类型
  final RxList<ElementsCardType> selectedKnowledgeTypes = <ElementsCardType>[].obs;

  /// 显示设置
  final Rx<FlashSettingCardShowType> showType = FlashSettingCardShowType.image.obs;

  final PageController pageController = PageController();

  // 当前索引
  RxInt currentIndex = 0.obs;

  /// 翻转状态
  RxBool cardIsFront = true.obs;

  /// 切换节奏
  Rx<double> playInterval = 10.0.obs;

  /// 是否自动播放（根据计时器自动翻到下一张）
  RxBool isAutoPlay = true.obs;

  /// 是否已播放至最后一项并进入完成态
  final RxBool isCompleted = false.obs;

  /// 已经掌握的知识点id列表
  final RxList<int> masteredKnowledgeIds = <int>[].obs;

  /// 待加强的知识点id列表
  final RxList<int> improvedKnowledgeIds = <int>[].obs;

  Timer? _autoNextTimer;

  RxInt audioDuration = 0.obs;

  Rx<double> playSpeed = 1.0.obs;

  /// 发音
  final Rx<LanguageServiceCodeEnum> national = LanguageServiceCodeEnum.US.obs;

  /// 页面是否准备完成
  final RxBool isReady = false.obs;

  final SequenceTipsVideoWidgetController _primaryFlashVideoController = SequenceTipsVideoWidgetController();
  final SequenceTipsVideoWidgetController _secondaryFlashVideoController = SequenceTipsVideoWidgetController();
  late SequenceTipsVideoWidgetController _activeFlashVideoController = _primaryFlashVideoController;
  late SequenceTipsVideoWidgetController _preloadFlashVideoController = _secondaryFlashVideoController;
  final RxInt nextVideoPreloadIndex = (-1).obs;
  final RxInt videoControllerEpoch = 0.obs;
  final RxInt mediaCacheEpoch = 0.obs;
  int _initialVideoWarmupVersion = 0;
  int _mediaSequenceVersion = 0;
  Future<void> _mediaControlQueue = Future<void>.value();
  bool _forcePlayCurrentOnIndexChange = false;
  int _manualAudioEpoch = 0;
  int _manualAudioStartIndex = -1;
  bool _manualAudioWasAutoPlay = false;
  bool _resumeAutoPlayAfterManualAudio = false;
  final Map<String, String> _cachedImagePathMap = <String, String>{};
  final Map<String, String> _cachedAudioPathMap = <String, String>{};
  final Map<String, String> _cachedVideoPathMap = <String, String>{};
  final Set<String> _cachingMediaKeys = <String>{};
  bool _hasShownCacheNetworkErrorToast = false;
  String? _activeKnowledgeMediaIdentity;
  String? _activeDisplayPosterPath;
  String? _activeDisplayVideoPath;

  SequenceTipsVideoWidgetController get flashVideoController => _activeFlashVideoController;
  SequenceTipsVideoWidgetController get preloadFlashVideoController => _preloadFlashVideoController;

  UnitKnowledgePointsEntityKnowledgeList? get preloadKnowledge {
    final int preloadIndex = nextVideoPreloadIndex.value;
    if (preloadIndex < 0 || preloadIndex >= knowledgeList.length) return null;
    return knowledgeList[preloadIndex];
  }

  String resolvePreviewVideoPath(
    UnitKnowledgePointsEntityKnowledgeList knowledge,
  ) {
    final String videoUrl = knowledge.video?.videoUrl?.trim() ?? '';
    if (videoUrl.isEmpty) return '';
    return _cachedVideoPathMap[videoUrl] ?? videoUrl;
  }

  String resolveDisplayVideoPath(
    UnitKnowledgePointsEntityKnowledgeList knowledge,
  ) {
    if (_isLockedActiveKnowledgeMedia(knowledge) &&
        (_activeDisplayVideoPath?.isNotEmpty ?? false)) {
      return _activeDisplayVideoPath!;
    }
    return resolvePreviewVideoPath(knowledge);
  }

  String resolvePreviewPosterPath(
    UnitKnowledgePointsEntityKnowledgeList knowledge,
  ) {
    final List<String?> candidateUrls = <String?>[
      knowledge.video?.firstFrameUrl,
      knowledge.imageUrl,
    ];
    for (final String? rawUrl in candidateUrls) {
      final String url = rawUrl?.trim() ?? '';
      if (url.isEmpty) continue;
      return _cachedImagePathMap[url] ?? url;
    }
    return '';
  }

  String resolveDisplayPosterPath(
    UnitKnowledgePointsEntityKnowledgeList knowledge,
  ) {
    if (_isLockedActiveKnowledgeMedia(knowledge) &&
        (_activeDisplayPosterPath?.isNotEmpty ?? false)) {
      return _activeDisplayPosterPath!;
    }
    return resolvePreviewPosterPath(knowledge);
  }

  String? resolveCachedAudioPath(String? audioUrl) {
    final String url = audioUrl?.trim() ?? '';
    if (url.isEmpty) return null;
    return _cachedAudioPathMap[url];
  }

  PronunciationsEntity? resolvePlayablePronunciation(
    UnitKnowledgePointsEntityKnowledgeList knowledge,
  ) {
    final List<PronunciationsEntity?> pronunciations =
        knowledge.pronunciations ?? [];
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

  String _buildKnowledgeMediaIdentity(
    UnitKnowledgePointsEntityKnowledgeList knowledge,
  ) {
    final String semanticId = knowledge.semanticId?.toString() ?? '';
    final String contentId = knowledge.contentId?.toString() ?? '';
    final String uid = knowledge.uid?.toString() ?? '';
    final String content = knowledge.content ?? '';
    return '${knowledge.contentType}_$semanticId$contentId$uid$content';
  }

  bool _isLockedActiveKnowledgeMedia(
    UnitKnowledgePointsEntityKnowledgeList knowledge,
  ) {
    return _activeKnowledgeMediaIdentity == _buildKnowledgeMediaIdentity(knowledge);
  }

  void _freezeCurrentKnowledgeMediaPaths(
    UnitKnowledgePointsEntityKnowledgeList knowledge,
  ) {
    _activeKnowledgeMediaIdentity = _buildKnowledgeMediaIdentity(knowledge);
    _activeDisplayPosterPath = resolvePreviewPosterPath(knowledge);
    _activeDisplayVideoPath = resolvePreviewVideoPath(knowledge);
  }

  void _notifyCacheNetworkFailure() {
    if (_hasShownCacheNetworkErrorToast || _isClosing || isClosed) return;
    _hasShownCacheNetworkErrorToast = true;
    if (isAutoPlay.value) {
      toggleAutoPlay();
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
      if (_isClosing || isClosed) {
        return;
      }
      if (cacheMap[normalizedUrl] == localPath) return;
      cacheMap[normalizedUrl] = localPath;
      mediaCacheEpoch.value++;
    } finally {
      _cachingMediaKeys.remove(cacheKey);
    }
  }

  Future<void> _cacheKnowledgeAssets(
    UnitKnowledgePointsEntityKnowledgeList? knowledge,
  ) async {
    if (knowledge == null || _isClosing || isClosed) return;
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
      resolvePlayablePronunciation(knowledge)?.audioUrl,
      ResourceType.audio,
      _cachedAudioPathMap,
      timeoutMilliseconds: 3000,
    );
  }

  Future<void> _cacheFlashAssets() async {
    if (knowledgeList.isEmpty) return;
    final int current = currentIndex.value.clamp(0, knowledgeList.length - 1);
    final int start = max(0, current - 1);
    final int end = min(knowledgeList.length - 1, current + 3);
    await _cacheKnowledgeAssets(knowledgeList[current]);
    for (int i = start; i <= end; i++) {
      if (i == current) continue;
      unawaited(_cacheKnowledgeAssets(knowledgeList[i]));
    }
  }

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    HardwareKeyboard.instance.addHandler(_handleGlobalKeyEvent);
    initUserSetting();

    if (Get.arguments != null) {
      knowledgeListArgs = List<UnitKnowledgePointsEntityKnowledgeList>.from(Get.arguments["knowledgeList"]).toList();
      enableLearnUpload = Get.arguments["enableLearnUpload"] == true;
      learnUploadType = Get.arguments["learnUploadType"]?.toString();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSetting(isFirst: true);
      });
    }
  }

  /// 获取本地储存的设置
  Future<void> initUserSetting() async{
    if(Get.isRegistered<ConfigController>()){
      UserSettingModel userSetting = Get.find<ConfigController>().userSetting.value;
      playSpeed.value = userSetting.expandAudioSpeed;
      national.value = LanguageServiceCodeEnum.fromValue(userSetting.expandPronunciationCode);
      final List<double> intervalList = (userSetting.intervalMenu ?? const [])
          .map((e) => e.value!)
          .toList();
      playInterval.value = _resolveSharedInterval(
        intervalList: intervalList,
        sharedInterval: userSetting.expandInterval,
        fallback: intervalList.length > 3 ? intervalList[3] : 12.5,
      );
    } else {
      national.value = LanguageServiceCodeEnum.fromValue(UserStore.to.userInfo.value.config?.national);
    }
  }

  /// 开始或暂停自动播放
  void toggleAutoPlay() {
    isAutoPlay.value = !isAutoPlay.value;
    if (isAutoPlay.value) {
      restartAutoNextTimer();
    } else {
      _autoNextTimer?.cancel();
      _autoNextTimer = null;
      _mediaSequenceVersion++;
      _manualAudioEpoch++;
      _manualAudioStartIndex = -1;
      _manualAudioWasAutoPlay = false;
      _resumeAutoPlayAfterManualAudio = false;
      if (!_hasReleasedVideoController) {
        unawaited(_activeFlashVideoController.stopAndReset());
        unawaited(_preloadFlashVideoController.stopAndReset());
      }
      unawaited(PlayAudioUtils.instance.stopAll());
      cancelAutoNextTimer();
    }
  }

  Future<void> pauseCurrentKnowledge() async {
    final int epoch = await beginManualAudioPlayback();
    await endManualAudioPlayback(epoch);
  }

  Future<void> interruptManualAudioPlayback() async {
    _manualAudioEpoch++;
    _manualAudioStartIndex = -1;
    _manualAudioWasAutoPlay = false;
    _resumeAutoPlayAfterManualAudio = false;
    await PlayAudioUtils.instance.stopAll();
  }

  /// 重启自动翻页计时器
  void restartAutoNextTimer() async {
    unawaited(_enqueueMediaControl(() async {
      await _stopActiveMedia();
      if (!isAutoPlay.value) return;
      if (knowledgeList.isEmpty) return;
      await WidgetsBinding.instance.endOfFrame;
      if (!isAutoPlay.value || knowledgeList.isEmpty) return;
      final int sequenceVersion = ++_mediaSequenceVersion;
      unawaited(_runCurrentCardMediaSequence(sequenceVersion));
    }));
  }

  void cancelAutoNextTimer() {
    unawaited(_enqueueMediaControl(() async {
      await _stopActiveMedia();
    }));
  }

  Future<void> _enqueueMediaControl(Future<void> Function() action) {
    final Future<void> next = _mediaControlQueue.then((_) => action());
    _mediaControlQueue = next.catchError((_) {});
    return next;
  }

  Future<void> _stopActiveMedia({bool cancelManualAudio = true}) async {
    _autoNextTimer?.cancel();
    _autoNextTimer = null;
    _mediaSequenceVersion++;
    if (cancelManualAudio) {
      _manualAudioEpoch++;
      _manualAudioStartIndex = -1;
      _manualAudioWasAutoPlay = false;
      _resumeAutoPlayAfterManualAudio = false;
    }
    if (!_hasReleasedVideoController) {
      await _stopAllVideoControllers();
    }
    await PlayAudioUtils.instance.stopAll();
  }

  Future<void> showSetting({bool isFirst = false}) async {
    if (knowledgeListArgs == null) return;
    if (Get.context == null) return;

    final bool wasAutoPlayBeforeSetting = isAutoPlay.value;
    final UnitKnowledgePointsEntityKnowledgeList? currentKnowledge =
        _currentKnowledge;
    final int previousIndex = currentIndex.value;
    isAutoPlay.value = false;
    await _stopActiveMedia();
    if (isFirst) {
      _primeInitialKnowledgeListForVideoWarmup();
      unawaited(_warmupFirstVideoBehindSettingDialog());
    }

    List<UnitKnowledgePointsEntityKnowledgeList> words = [];
    List<UnitKnowledgePointsEntityKnowledgeList> phrases = [];
    List<UnitKnowledgePointsEntityKnowledgeList> sentences = [];

    for (int i = 0; i < knowledgeListArgs!.length; i++) {
      if (knowledgeListArgs![i].isWord) {
        words.add(knowledgeListArgs![i]);
      } else if (knowledgeListArgs![i].isPhrase) {
        phrases.add(knowledgeListArgs![i]);
      } else if (knowledgeListArgs![i].isSentence) {
        sentences.add(knowledgeListArgs![i]);
      }
    }

    List<FlashSettingKnowledgeTypeItemModel> knowledgePoints = [];
    if (words.isNotEmpty) {
      knowledgePoints.add(FlashSettingKnowledgeTypeItemModel(
        type: ElementsCardType.word,
        typeText: '单词',
        count: words.length,
      ));
    }
    if (phrases.isNotEmpty) {
      knowledgePoints.add(FlashSettingKnowledgeTypeItemModel(
        type: ElementsCardType.phrase,
        typeText: '短语',
        count: phrases.length,
      ));
    }
    if (sentences.isNotEmpty) {
      knowledgePoints.add(FlashSettingKnowledgeTypeItemModel(
        type: ElementsCardType.sentence,
        typeText: '句子',
        count: sentences.length,
      ));
    }

    FlashSettingModel? newGraph = await OfficialCourseDetailsFlashSettingDialog.show(
      context: Get.context!,
      showKonwlede: isFirst,
      initSetting: FlashSettingModel(
          knowledgePoints: knowledgePoints,
          selectedKnowledgePoints: selectedKnowledgeTypes.isEmpty
              ? knowledgePoints.map((e) => e.type).toList()
              : knowledgePoints
                  .where((e) => selectedKnowledgeTypes.contains(e.type))
                  .map((e) => e.type)
                  .toList(),
          showType: showType.value,
          interval: playInterval.value,
          playSpeed: playSpeed.value,
          national: national.value,
          textDisplayCode: _currentTextDisplayCode),
    );
    if (newGraph == null) {
      if (isFirst) {
        Get.back();
      } else if (wasAutoPlayBeforeSetting) {
        isAutoPlay.value = true;
        restartAutoNextTimer();
      }
      return;
    }

    showType.value = newGraph.showType;
    playInterval.value = newGraph.interval;
    playSpeed.value = newGraph.playSpeed;
    national.value = newGraph.national;
    selectedKnowledgeTypes.value = newGraph.selectedKnowledgePoints.toList();
    StorageUtil().setDouble(INTERVAL_SPEED_KEY, playInterval.value);
    Get.find<ConfigController>().setUserSetting(
      expandAudioSpeed: playSpeed.value,
      expandTranslationType: newGraph.textDisplayCode,
      expandPronunciationCode: national.value.value,
      expandInterval: playInterval.value,
    );
    knowledgeList.value = knowledgeListArgs!.toList();
    knowledgeList.removeWhere((element) => !newGraph.selectedKnowledgePoints.contains(element.cardType));
    currentIndex.value = _resolveCurrentIndexForUpdatedKnowledgeList(
      currentKnowledge: currentKnowledge,
      previousIndex: previousIndex,
    );
    _clearNextVideoPreload(resetController: false);
    cardIsFront.value = true;
    if (knowledgeList.isEmpty) {
      isAutoPlay.value = false;
      return;
    }
    if (pageController.hasClients) {
      pageController.jumpToPage(currentIndex.value);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!pageController.hasClients) return;
        pageController.jumpToPage(currentIndex.value);
      });
    }
    await _startLearnUploadIfNeeded();
    _markCurrentContentViewed();
    setAudioDuration().then((_) {
      isReady.value = true;
      isAutoPlay.value = true;
      unawaited(_cacheFlashAssets());
      restartAutoNextTimer();
    });
  }

  Future<void> setAudioDuration() async {
    // 优先使用当前卡片的发音音频 URL 计算时长
    final current = knowledgeList[currentIndex.value];
    String? audioUrl;
    if (current.pronunciations != null && current.pronunciations!.isNotEmpty) {
      audioUrl = current.pronunciations!.first?.audioUrl;
    }
    audioUrl ??= current.audioUrl;

    int duration = 0;
    duration = current.pronunciations!.first!.duration!.toInt() * 1000;

    int delayMs;
    if (duration == 0) {
      delayMs = (playInterval.value * 1000).toInt();
    } else {
      delayMs = (duration * playInterval.value).toInt();
    }
    audioDuration.value = delayMs;
  }

  Future<void> _runCurrentCardMediaSequence(int sequenceVersion) async {
    final UnitKnowledgePointsEntityKnowledgeList? current = _currentKnowledge;
    if (current == null) return;
    final int expectedIndex = currentIndex.value;
    unawaited(_cacheFlashAssets());
    _freezeCurrentKnowledgeMediaPaths(current);
    await _prepareVideoControllerForCurrentKnowledge(current);
    unawaited(_ensureNextKnowledgeVideoPreloaded());
    await _playCurrentVideoIfNeeded(sequenceVersion, expectedIndex, current);
    if (!_isMediaSequenceActive(sequenceVersion, expectedIndex)) return;
    _autoNextTimer = Timer(_switchIntervalDuration, () async {
      if (!_isMediaSequenceActive(sequenceVersion, expectedIndex)) return;
      await nextCard();
    });
  }

  Future<void> _playCurrentVideoIfNeeded(
    int sequenceVersion,
    int expectedIndex,
    UnitKnowledgePointsEntityKnowledgeList knowledge,
  ) async {
    final String videoUrl = resolveDisplayVideoPath(knowledge);
    if (videoUrl.isEmpty) return;
    final bool isBound = await flashVideoController.waitUntilBoundToVideo(videoUrl);
    if (!isBound || !_isMediaSequenceActive(sequenceVersion, expectedIndex)) return;
    await flashVideoController.setPlaybackRate(playSpeed.value);
    await flashVideoController.playOnce(
      muted: knowledge.video?.isMute ?? false,
    );
  }

  bool _isMediaSequenceActive(int sequenceVersion, int expectedIndex) {
    return !_isClosing &&
        !isClosed &&
        isAutoPlay.value &&
        knowledgeList.isNotEmpty &&
        sequenceVersion == _mediaSequenceVersion &&
        expectedIndex == currentIndex.value;
  }

  Duration get _switchIntervalDuration {
    return Duration(
      milliseconds: (playInterval.value * 1000).round(),
    );
  }

  UnitKnowledgePointsEntityKnowledgeList? get _currentKnowledge {
    if (knowledgeList.isEmpty) return null;
    if (currentIndex.value < 0 || currentIndex.value >= knowledgeList.length) return null;
    return knowledgeList[currentIndex.value];
  }

  int _resolveCurrentIndexForUpdatedKnowledgeList({
    required UnitKnowledgePointsEntityKnowledgeList? currentKnowledge,
    required int previousIndex,
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
    return previousIndex.clamp(0, knowledgeList.length - 1);
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
    return left.content == right.content && left.imageUrl == right.imageUrl;
  }

  /// 上一张卡片
  Future<void> previousCard({bool forcePlayCurrent = false}) async {
    if (currentIndex.value > 0) {
      if (forcePlayCurrent && _manualAudioStartIndex != -1) {
        isAutoPlay.value = _manualAudioWasAutoPlay;
        _resumeAutoPlayAfterManualAudio = false;
      } else if (forcePlayCurrent && _resumeAutoPlayAfterManualAudio) {
        isAutoPlay.value = true;
        _resumeAutoPlayAfterManualAudio = false;
        _manualAudioWasAutoPlay = false;
      }
      if (forcePlayCurrent) {
        isAutoPlay.value = true;
        _manualAudioStartIndex = -1;
        _manualAudioWasAutoPlay = false;
        _resumeAutoPlayAfterManualAudio = false;
      }
      _forcePlayCurrentOnIndexChange = forcePlayCurrent;
      currentIndex.value--;
      pageController.animateToPage(currentIndex.value, duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      ToastUtils.showToast(text: '当前已是第一个');
      update();
      return;
    }
    _clearNextVideoPreload(resetController: false);
    cardIsFront.value = true;
    isCompleted.value = false;
    _markCurrentContentViewed();
  }

  /// 下一张卡片
  Future<void> nextCard({bool forcePlayCurrent = false}) async {
    if (currentIndex.value < knowledgeList.length - 1) {
      if (forcePlayCurrent && _manualAudioStartIndex != -1) {
        isAutoPlay.value = _manualAudioWasAutoPlay;
        _resumeAutoPlayAfterManualAudio = false;
      } else if (forcePlayCurrent && _resumeAutoPlayAfterManualAudio) {
        isAutoPlay.value = true;
        _resumeAutoPlayAfterManualAudio = false;
        _manualAudioWasAutoPlay = false;
      }
      if (forcePlayCurrent) {
        isAutoPlay.value = true;
        _manualAudioStartIndex = -1;
        _manualAudioWasAutoPlay = false;
        _resumeAutoPlayAfterManualAudio = false;
      }
      _forcePlayCurrentOnIndexChange = forcePlayCurrent;
      currentIndex.value++;
      pageController.animateToPage(currentIndex.value, duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      isCompleted.value = true;
      isAutoPlay.value = false;
      await _stopActiveMedia();
      _clearNextVideoPreload(resetController: false);
      return;
    }
    _clearNextVideoPreload(resetController: false);
    cardIsFront.value = true;
    isCompleted.value = false;
    _markCurrentContentViewed();
  }

  /// 改变下标
  void changeIndex(int index) {
    final bool forcePlayCurrent = _forcePlayCurrentOnIndexChange;
    _forcePlayCurrentOnIndexChange = false;
    currentIndex.value = index;
    _clearNextVideoPreload(resetController: false);
    cardIsFront.value = true;
    isCompleted.value = false;
    _markCurrentContentViewed();
    setAudioDuration().then((_) {
      if (forcePlayCurrent) {
        isAutoPlay.value = true;
        playCurrentKnowledgeOnce(allowAutoAdvance: true);
      } else {
        restartAutoNextTimer();
      }
    });
  }

  Future<int> beginManualAudioPlayback() async {
    final int epoch = ++_manualAudioEpoch;
    _manualAudioStartIndex = currentIndex.value;
    _manualAudioWasAutoPlay = isAutoPlay.value;
    _resumeAutoPlayAfterManualAudio = false;
    isAutoPlay.value = false;
    await _enqueueMediaControl(() async {
      await _stopActiveMedia(cancelManualAudio: false);
    });
    return epoch;
  }

  Future<void> endManualAudioPlayback(int epoch) async {
    if (epoch != _manualAudioEpoch) return;
    final int startIndex = _manualAudioStartIndex;
    _manualAudioStartIndex = -1;
    if (startIndex != currentIndex.value) return;
    if (!_manualAudioWasAutoPlay) return;
    _resumeAutoPlayAfterManualAudio = true;
  }

  void playCurrentKnowledgeOnce({required bool allowAutoAdvance}) {
    unawaited(_enqueueMediaControl(() async {
      await _stopActiveMedia();
      if (knowledgeList.isEmpty) return;
      final UnitKnowledgePointsEntityKnowledgeList? current = _currentKnowledge;
      if (current == null) return;
      await WidgetsBinding.instance.endOfFrame;
      if (knowledgeList.isEmpty || current != _currentKnowledge) return;
      final int expectedIndex = currentIndex.value;
      final int sequenceVersion = ++_mediaSequenceVersion;
      unawaited(_cacheFlashAssets());
      _freezeCurrentKnowledgeMediaPaths(current);
      await _prepareVideoControllerForCurrentKnowledge(current);
      unawaited(_ensureNextKnowledgeVideoPreloaded());
      final Future<void> playbackFuture =
          _playCurrentVideoIgnoringAutoPlay(sequenceVersion, expectedIndex, current);
      if (!allowAutoAdvance) return;
      unawaited(() async {
        try {
          await playbackFuture;
        } catch (_) {}
        if (!_isMediaSequenceActive(sequenceVersion, expectedIndex)) return;
        _autoNextTimer = Timer(_switchIntervalDuration, () async {
          if (!_isMediaSequenceActive(sequenceVersion, expectedIndex)) return;
          await nextCard();
        });
      }());
    }));
  }

  Future<void> _playCurrentVideoIgnoringAutoPlay(
    int sequenceVersion,
    int expectedIndex,
    UnitKnowledgePointsEntityKnowledgeList knowledge,
  ) async {
    final String videoUrl = resolveDisplayVideoPath(knowledge);
    if (videoUrl.isEmpty) return;
    final bool isBound = await flashVideoController.waitUntilBoundToVideo(videoUrl);
    if (!isBound || !_isManualSequenceActive(sequenceVersion, expectedIndex)) return;
    await flashVideoController.setPlaybackRate(playSpeed.value);
    await flashVideoController.playOnce(
      muted: knowledge.video?.isMute ?? false,
    );
  }

  bool _isManualSequenceActive(int sequenceVersion, int expectedIndex) {
    return !_isClosing &&
        !isClosed &&
        knowledgeList.isNotEmpty &&
        sequenceVersion == _mediaSequenceVersion &&
        expectedIndex == currentIndex.value;
  }

  /// 已掌握
  void masteredClick() {
    UnitKnowledgePointsEntityKnowledgeList knowledge = knowledgeList[currentIndex.value];
    if (knowledge.contentId != null) {
      if (improvedKnowledgeIds.contains(knowledge.contentId!)) {
        improvedKnowledgeIds.remove(knowledge.contentId!);
      }
      if (!masteredKnowledgeIds.contains(knowledge.contentId!)) {
        masteredKnowledgeIds.add(knowledge.contentId!);
      }
    }

    nextCard();
  }

  /// 待加强
  void improvedClick() {
    UnitKnowledgePointsEntityKnowledgeList knowledge = knowledgeList[currentIndex.value];
    if (knowledge.contentId != null) {
      if (masteredKnowledgeIds.contains(knowledge.contentId!)) {
        masteredKnowledgeIds.remove(knowledge.contentId!);
      }
      if (!improvedKnowledgeIds.contains(knowledge.contentId!)) {
        improvedKnowledgeIds.add(knowledge.contentId!);
      }
    }

    nextCard();
  }

  /// 键盘事件处理
  bool _handleGlobalKeyEvent(KeyEvent event) {
    if (knowledgeList.isEmpty) return true;
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        previousCard();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        nextCard();
        return true;
      }
    }
    return true;
  }

    /// 修改播放速度
  void changePlaySpeed(double speed) async {
    playSpeed.value = speed;
    await flashVideoController.setPlaybackRate(speed);
    await preloadFlashVideoController.setPlaybackRate(speed);

    ConfigController configController = Get.find<ConfigController>();
    configController.setUserSetting(expandAudioSpeed: speed);
  }

  void revealAnswer() {
    cardIsFront.value = false;
  }

  void coverAnswer() {
    cardIsFront.value = true;
  }

  Future<void> replayFromStart() async {
    if (knowledgeList.isEmpty) return;
    isCompleted.value = false;
    isAutoPlay.value = true;
    currentIndex.value = 0;
    cardIsFront.value = true;
    if (pageController.hasClients) {
      await pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
    _markCurrentContentViewed();
    await setAudioDuration();
    restartAutoNextTimer();
  }

  Future<void> completeFlashNotes() async {
    await _stopActiveMedia();
    await handleExit();
  }

  Future<void> openCurrentKnowledgeDetail() async {
    if (knowledgeList.isEmpty) return;
    isAutoPlay.value = false;
    await _stopActiveMedia();
    final currentKnowledge = knowledgeList[currentIndex.value];
    await ElementsPageUtils.jumpElementsPage(
      contentId: currentKnowledge.contentId,
      contentType: currentKnowledge.contentType,
      semanticId: currentKnowledge.semanticId,
      styleId: currentKnowledge.styleId,
      dialect: currentKnowledge.dialect,
      semanticIds: currentKnowledge.semanticId == null
          ? null
          : [currentKnowledge.semanticId],
      content: currentKnowledge.content,
      pos: currentKnowledge.posTitle,
    );
  }

  String get currentPronunciationLabel => national.value.text;

  String get currentTextDisplayLabel {
    final String code = _currentTextDisplayCode;
    if (code == _originalCode) return '原文语言';
    if (code == _translationCode) return '译文语言';
    if (code == _noneCode) return '隐藏文本';
    return '双语对照';
  }

  String get currentIntervalLabel {
    final List<UserPreferenceIntervalSpeedOption> menu =
        Get.find<ConfigController>().userSetting.value.intervalMenu ?? [];
    for (final item in menu) {
      if (item.value == playInterval.value) {
        return '节奏${item.title ?? playInterval.value}';
      }
    }
    return '节奏${playInterval.value}';
  }

  String get currentShowTypeLabel => showType.value.value;

  String get currentSpeedLabel => '倍速 ${playSpeed.value.toStringAsFixed(1)}x';

  String get _currentTextDisplayCode {
    final ConfigController configController = Get.find<ConfigController>();
    final String currentCode = configController.userSetting.value.expandLang.code;
    if (currentCode.isNotEmpty) {
      return currentCode;
    }
    final menus = configController.userSetting.value.expandDropdownMenu ?? const [];
    for (final item in menus) {
      final String code = (item.code ?? '').trim();
      if (code.isNotEmpty) {
        return code;
      }
    }
    return _bilingualCode;
  }

  double _resolveSharedInterval({
    required List<double> intervalList,
    required double sharedInterval,
    required double fallback,
  }) {
    if (intervalList.isEmpty) return fallback;
    return intervalList.contains(sharedInterval) ? sharedInterval : fallback;
  }

  Future<void> _prepareVideoControllerForCurrentKnowledge(
    UnitKnowledgePointsEntityKnowledgeList currentKnowledge,
  ) async {
    if (_canUsePreloadedVideoForKnowledge(currentKnowledge)) {
      final SequenceTipsVideoWidgetController previousActiveController =
          _activeFlashVideoController;
      final SequenceTipsVideoWidgetController promotedController =
          _preloadFlashVideoController;

      nextVideoPreloadIndex.value = -1;
      videoControllerEpoch.value++;
      await WidgetsBinding.instance.endOfFrame;

      await previousActiveController.stopAndReset();

      _activeFlashVideoController = promotedController;
      _preloadFlashVideoController = previousActiveController;
      videoControllerEpoch.value++;
      await WidgetsBinding.instance.endOfFrame;
      return;
    }
    await _activeFlashVideoController.stopAndReset();
  }

  bool _canUsePreloadedVideoForKnowledge(
    UnitKnowledgePointsEntityKnowledgeList knowledge,
  ) {
    final String videoUrl = resolveDisplayVideoPath(knowledge);
    if (videoUrl.isEmpty) return false;
    if (nextVideoPreloadIndex.value != currentIndex.value) return false;
    return preloadFlashVideoController.currentVideoPath == videoUrl;
  }

  Future<void> _ensureNextKnowledgeVideoPreloaded() async {
    final int? targetIndex = _resolveNextVideoPreloadIndex();
    if (targetIndex == null) {
      _clearNextVideoPreload();
      return;
    }
    final UnitKnowledgePointsEntityKnowledgeList targetKnowledge =
        knowledgeList[targetIndex];
    unawaited(_cacheKnowledgeAssets(targetKnowledge));
    final String videoUrl = resolvePreviewVideoPath(targetKnowledge);
    if (videoUrl.isEmpty) {
      _clearNextVideoPreload();
      return;
    }
    final bool isSameTarget = nextVideoPreloadIndex.value == targetIndex &&
        preloadFlashVideoController.currentVideoPath == videoUrl;
    if (isSameTarget) {
      await preloadFlashVideoController.setPlaybackRate(playSpeed.value);
      return;
    }
    nextVideoPreloadIndex.value = targetIndex;
    await WidgetsBinding.instance.endOfFrame;
    if (_isClosing || isClosed || nextVideoPreloadIndex.value != targetIndex) {
      return;
    }
    final bool isBound =
        await preloadFlashVideoController.waitUntilBoundToVideo(videoUrl);
    if (!isBound ||
        _isClosing ||
        isClosed ||
        nextVideoPreloadIndex.value != targetIndex) {
      return;
    }
    try {
      await preloadFlashVideoController.setPlaybackRate(playSpeed.value);
      await preloadFlashVideoController.preload();
    } catch (_) {}
  }

  int? _resolveNextVideoPreloadIndex() {
    final int nextIndex = currentIndex.value + 1;
    if (nextIndex < 0 || nextIndex >= knowledgeList.length) return null;
    return nextIndex;
  }

  void _clearNextVideoPreload({bool resetController = true}) {
    nextVideoPreloadIndex.value = -1;
    if (resetController) {
      unawaited(preloadFlashVideoController.stopAndReset());
    }
  }

  Future<void> _stopAllVideoControllers() async {
    await _activeFlashVideoController.stopAndReset();
    await _preloadFlashVideoController.stopAndReset();
  }

  void _primeInitialKnowledgeListForVideoWarmup() {
    if (knowledgeList.isNotEmpty) return;
    final source = knowledgeListArgs;
    if (source == null || source.isEmpty) return;
    knowledgeList.value = source.toList();
    currentIndex.value = currentIndex.value.clamp(0, knowledgeList.length - 1);
    unawaited(_cacheFlashAssets());
  }

  Future<void> _warmupFirstVideoBehindSettingDialog() async {
    final UnitKnowledgePointsEntityKnowledgeList? currentKnowledge =
        _currentKnowledge;
    if (currentKnowledge == null) return;
    unawaited(_cacheFlashAssets());
    _freezeCurrentKnowledgeMediaPaths(currentKnowledge);
    final String videoUrl = resolveDisplayVideoPath(currentKnowledge);
    if (videoUrl.isEmpty) return;
    final int warmupVersion = ++_initialVideoWarmupVersion;
    await WidgetsBinding.instance.endOfFrame;
    if (_isClosing || isClosed || warmupVersion != _initialVideoWarmupVersion) {
      return;
    }
    final bool isBound = await flashVideoController.waitUntilBoundToVideo(
      videoUrl,
      timeout: const Duration(seconds: 5),
    );
    if (!isBound ||
        _isClosing ||
        isClosed ||
        warmupVersion != _initialVideoWarmupVersion) {
      return;
    }
    try {
      await flashVideoController.setPlaybackRate(playSpeed.value);
      await flashVideoController.preload();
    } catch (_) {}
  }

  @override
  void onClose() {
    _isClosing = true;
    if (enableLearnUpload && !_hasStoppedLearnUpload) {
      unawaited(LearnRecordManager.instance.stopTracking(source: _learnRecordSource));
    }
    HardwareKeyboard.instance.removeHandler(_handleGlobalKeyEvent);
    unawaited(_releasePlaybackResources());
    super.onClose();
  }

  Future<void> handleExit() async {
    if (_isHandlingExit) return;
    _isHandlingExit = true;
    try {
      await _shutdownPlaybackBeforePop();
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

  Future<void> _shutdownPlaybackBeforePop() async {
    _isClosing = true;
    isAutoPlay.value = false;
    await _enqueueMediaControl(() async {
      await _stopActiveMedia();
    });
  }

  Future<void> _releasePlaybackResources() async {
    await _enqueueMediaControl(() async {
      await _stopActiveMedia();
      if (_hasReleasedVideoController) return;
      _hasReleasedVideoController = true;
      await _activeFlashVideoController.release();
      await _preloadFlashVideoController.release();
    });
  }

  Future<void> _startLearnUploadIfNeeded() async {
    if (!enableLearnUpload || _hasStartedLearnUpload || knowledgeList.isEmpty) return;
    _hasStartedLearnUpload = true;
    await LearnRecordManager.instance.startTracking(
      source: _learnRecordSource,
      type: learnUploadType,
    );
  }

  void _markCurrentContentViewed() {
    if (!enableLearnUpload || knowledgeList.isEmpty) return;
    unawaited(LearnRecordManager.instance.markContentViewed(knowledgeList[currentIndex.value]));
  }
}
