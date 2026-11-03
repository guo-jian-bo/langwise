import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/elements/utils/elements_page_utils.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/guide_engine/guide_engine.dart';
import 'package:langwise/common/widgets/http_error_dialog.dart';
import 'package:langwise/utils/preview_audio_utils.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/storage_util.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:video_player/video_player.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/public_controller/model/user_setting_model.dart';
import '../views/official_course_details_preview_setting_dialog.dart';

enum _PreviewPlaybackPhase {
  idle,
  video,
  videoPaused,
  waitingAfterVideo,
  waitingAfterVideoPaused,
  audio,
  audioPaused,
  waitingAfterAudio,
  waitingAfterAudioPaused,
}

// #region debug-point A:preview-log-helper
Future<void> _previewDebugLog(
  String hypothesisId,
  String msg, {
  Map<String, dynamic>? data,
}) async {
  debugPrint(
      '[PREVIEW-STALL][$hypothesisId] $msg ${jsonEncode(data ?? <String, dynamic>{})}');
}
// #endregion

class OfficialCourseDetailsPreviewController extends GetxController
    with RoutesBreadcrumbMixin, WidgetsBindingObserver {
  final String tagText;
  OfficialCourseDetailsPreviewController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.OFFICIAL_COURSE_DETAILS_PREVIEW;

  @override
  String get breadcrumbTitle => "预习";

  String? moduleName; //书名称
  String? unitName; //单元名称
  bool enableLearnUpload = false;
  String? learnUploadType;
  bool forceSequentialPlayMode = false;
  bool _hasStartedLearnUpload = false;
  bool _isHandlingExit = false;
  bool _hasStoppedLearnUpload = false;
  static const String _learnRecordSource = 'official_course_details_preview';

  /// 原始知识点列表
  List<UnitKnowledgePointsEntityKnowledgeList> allKnowledgeList = [];

  /// 顺序知识点列表
  List<UnitKnowledgePointsEntityKnowledgeList> sequentialKnowledgeList = [];

  /// 知识点列表
  final RxList<UnitKnowledgePointsEntityKnowledgeList> knowledgeList =
      <UnitKnowledgePointsEntityKnowledgeList>[].obs;

  /// 播放模式
  final Rx<PlayerModeEnum> playMode = PlayerModeEnum.list.obs;

  /// 播放次数
  final Rx<int> playNum = 3.obs;

  /// 切换间隔
  final Rx<double> playInterval = 10.0.obs;

  /// 当前播放次数
  final Rx<int> currentPlayNum = 0.obs;

  /// 播放速度
  final Rx<double> playSpeed = 1.0.obs;

  // 播放进度
  RxInt progress = 0.obs;

  /// 播放状态
  RxBool playStatus = false.obs;
  final RxBool isAudioPlaying = false.obs;

  bool isCurrentKnowledge(UnitKnowledgePointsEntityKnowledgeList knowledge) {
    final currentKnowledge = _currentKnowledge;
    if (currentKnowledge == null) return false;
    return _isSameKnowledge(currentKnowledge, knowledge);
  }

  /// 首次进入时优先从服务端标记的当前知识点开始。
  UnitKnowledgePointsEntityKnowledgeList? _preferredStartKnowledge;

  /// 英音、美音
  final Rx<LanguageServiceCodeEnum> national = LanguageServiceCodeEnum.US.obs;

  final PreviewAudioUtils previewAudioUtils = PreviewAudioUtils.instance;



  StreamSubscription? _playerCompleteSubscription; //音频播放完成的流订阅

  final RxBool isCompleted = false.obs;

  /// 页面是否准备完成
  final RxBool isReady = false.obs;

  final Random _random = Random();
  final List<int> _randomPlaybackOrder = <int>[];
  int _randomPlaybackCursor = -1;

  /// 每个切换等待的timer
  Timer? _switchTimer;
  Timer? _debounceResetTimer;

  /// 回调防抖
  bool debounce = false;

  RxInt totalDurationTime = 0.obs; //总时长

  /// 是否正在切换音频，防止并发 stop/prepare 导致 just_audio 崩溃
  bool _isSwitchingAudio = false;

  /// 等待中的下一首（在频繁点击时只保留最后一次请求）
  UnitKnowledgePointsEntityKnowledgeList? _pendingAudioModel;
  final SequenceTipsVideoWidgetController _primaryPreviewVideoController =
      SequenceTipsVideoWidgetController();
  final SequenceTipsVideoWidgetController _secondaryPreviewVideoController =
      SequenceTipsVideoWidgetController();
  late SequenceTipsVideoWidgetController _activePreviewVideoController =
      _primaryPreviewVideoController;
  late SequenceTipsVideoWidgetController _preloadPreviewVideoController =
      _secondaryPreviewVideoController;
  final RxInt nextVideoPreloadIndex = (-1).obs;
  final RxInt videoControllerEpoch = 0.obs;
  final RxInt mediaCacheEpoch = 0.obs;
  _PreviewPlaybackPhase _playbackPhase = _PreviewPlaybackPhase.idle;
  int _sequenceVersion = 0;
  int _initialVideoWarmupVersion = 0;
  int? _predictedNextRandomIndex;
  static const Duration _videoToAudioGap = Duration(milliseconds: 500);
  bool _isClosing = false;
  bool _hasReleasedVideoController = false;
  final Map<String, String> _cachedImagePathMap = <String, String>{};
  final Map<String, String> _cachedAudioPathMap = <String, String>{};
  final Map<String, String> _cachedVideoPathMap = <String, String>{};
  final Set<String> _cachingMediaKeys = <String>{};
  bool _hasShownCacheNetworkErrorToast = false;
  String? _activeKnowledgeMediaIdentity;
  String? _activeDisplayPosterPath;
  String? _activeDisplayVideoPath;
  String? _initialEntryKnowledgeMediaIdentity;
  bool _preferRemoteMediaForInitialEntryKnowledge = false;

  SequenceTipsVideoWidgetController get previewVideoController =>
      _activePreviewVideoController;

  SequenceTipsVideoWidgetController get preloadVideoController =>
      _preloadPreviewVideoController;

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

  String resolveDisplayImagePath(
    UnitKnowledgePointsEntityKnowledgeList knowledge,
  ) {
    final String imageUrl = knowledge.imageUrl?.trim() ?? '';
    if (imageUrl.isEmpty) return '';
    return _cachedImagePathMap[imageUrl] ?? imageUrl;
  }

  String _resolveRemotePosterPath(
    UnitKnowledgePointsEntityKnowledgeList knowledge,
  ) {
    final List<String?> candidateUrls = <String?>[
      knowledge.video?.firstFrameUrl,
      knowledge.imageUrl,
    ];
    for (final String? rawUrl in candidateUrls) {
      final String url = rawUrl?.trim() ?? '';
      if (url.isNotEmpty) return url;
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

  Uri? resolveAudioArtworkUri(
    UnitKnowledgePointsEntityKnowledgeList knowledge,
  ) {
    final String artworkPath = resolveDisplayPosterPath(knowledge);
    if (artworkPath.isEmpty) return null;
    if (artworkPath.startsWith('/') ||
        RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(artworkPath) ||
        artworkPath.startsWith(r'\\')) {
      return Uri.file(artworkPath);
    }
    return Uri.tryParse(artworkPath);
  }

  PronunciationsEntity? _resolvePlayablePronunciation(
    UnitKnowledgePointsEntityKnowledgeList model,
  ) {
    final List<PronunciationsEntity?> pronunciations = model.pronunciations ?? [];
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

  bool _shouldPreferRemoteMediaForInitialEntryKnowledge(
      UnitKnowledgePointsEntityKnowledgeList knowledge) {
    return _preferRemoteMediaForInitialEntryKnowledge &&
        _initialEntryKnowledgeMediaIdentity ==
            _buildKnowledgeMediaIdentity(knowledge);
  }

  void _freezeCurrentKnowledgeMediaPaths(
      UnitKnowledgePointsEntityKnowledgeList knowledge,
      {bool preferRemoteMedia = false}) {
    _activeKnowledgeMediaIdentity = _buildKnowledgeMediaIdentity(knowledge);
    _activeDisplayPosterPath = preferRemoteMedia
        ? _resolveRemotePosterPath(knowledge)
        : resolvePreviewPosterPath(knowledge);
    _activeDisplayVideoPath = preferRemoteMedia
        ? (knowledge.video?.videoUrl?.trim() ?? '')
        : resolvePreviewVideoPath(knowledge);
  }

  void _notifyCacheNetworkFailure() {
    if (_hasShownCacheNetworkErrorToast || _isClosing || isClosed) return;
    _hasShownCacheNetworkErrorToast = true;
    if (playStatus.value) {
      audioPlayAndPause();
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
      _resolvePlayablePronunciation(knowledge)?.audioUrl,
      ResourceType.audio,
      _cachedAudioPathMap,
      timeoutMilliseconds: 3000,
    );
  }

  Future<void> _cachePreviewAssets() async {
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

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    initBreadcrumb(tagText);
    initUserSetting();
    if (Get.arguments != null) {
      moduleName = Get.arguments["moduleName"];
      unitName = Get.arguments["unitName"];
      enableLearnUpload = Get.arguments["enableLearnUpload"] == true;
      learnUploadType = Get.arguments["learnUploadType"]?.toString();
      forceSequentialPlayMode =
          Get.arguments["forceSequentialPlayMode"] == true;

      allKnowledgeList = List<UnitKnowledgePointsEntityKnowledgeList>.from(
        Get.arguments["knowledgeList"] ?? const [],
      );
      final int preferredIndex =
          allKnowledgeList.indexWhere((item) => item.current == true);
      if (preferredIndex != -1) {
        _preferredStartKnowledge = allKnowledgeList[preferredIndex];
        progress.value = preferredIndex;
      }
      sequentialKnowledgeList = allKnowledgeList.toList();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) {
        playSetting(isFirst: true);
      }
    });
    GuideTaskController.to.loadTasks(pageCode: AppRoutesCode.courseDetilsPreview);
  }

  /// 获取本地储存的设置
  Future<void> initUserSetting() async {
    AudioControlSettingModel? setting = AudioControlUtils.getSetting();
    if (Get.isRegistered<ConfigController>()) {
      UserSettingModel userSetting =
          Get.find<ConfigController>().userSetting.value;
      playSpeed.value = userSetting.expandAudioSpeed;
      national.value = LanguageServiceCodeEnum.fromValue(
          userSetting.expandPronunciationCode);
      final List<double> intervalList = (userSetting.intervalMenu ?? const [])
          .map((e) => e.value)
          .whereType<double>()
          .toList();
      playInterval.value = _resolveSharedInterval(
        intervalList: intervalList,
        sharedInterval: userSetting.expandInterval,
        fallback: intervalList.length > 1 ? intervalList[1] : 7.5,
      );
      playMode.value = _resolvePreviewPlayMode(
        userSetting.expandPlayOrder.isNotEmpty
            ? userSetting.expandPlayOrder
            : setting?.playOrder?.value,
      );
      playNum.value = _resolveSharedLoopCount(
        userSetting.expandPlayOrderLoopCount > 0
            ? userSetting.expandPlayOrderLoopCount
            : setting?.playOrderLoopCount,
        max: 5,
      );
    } else {
      national.value = LanguageServiceCodeEnum.fromValue(
          UserStore.to.userInfo.value.config?.national);
    }
    if (playMode.value == PlayerModeEnum.singleLoop) {
      playNum.value = 1;
    }
    if (forceSequentialPlayMode && playMode.value == PlayerModeEnum.random) {
      playMode.value = PlayerModeEnum.list;
    }
  }

  @override
  void onClose() {
    _isClosing = true;
    WidgetsBinding.instance.removeObserver(this);
    _switchTimer?.cancel();
    _debounceResetTimer?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerCompleteSubscription = null;
    debounce = false;
    _sequenceVersion++;
    playStatus.value = false;
    isAudioPlaying.value = false;
    _playbackPhase = _PreviewPlaybackPhase.idle;
    previewAudioUtils.setNavigationHandlers(onNext: null, onPrevious: null);
    if (enableLearnUpload && !_hasStoppedLearnUpload) {
      unawaited(
          LearnRecordManager.instance.stopTracking(source: _learnRecordSource));
    }
    if (!_hasReleasedVideoController) {
      _hasReleasedVideoController = true;
      unawaited(_releaseAllVideoControllers());
    }
    previewAudioUtils.setPlaybackRate(1.0);
    previewAudioUtils.stop();
    ToastUtils.hideLoading();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    unawaited(_previewDebugLog('L', 'preview lifecycle changed', data: {
      'state': state.name,
      'progress': progress.value,
      'sequenceVersion': _sequenceVersion,
      'phase': _playbackPhase.name,
      'playStatus': playStatus.value,
    }));
  }

  Future<void> handleExit({bool isCompleted = false}) async {
    if (_isHandlingExit) return;
    _isHandlingExit = true;
    try {
      _isClosing = true;
      await _shutdownPlaybackBeforePop();
      if (enableLearnUpload && !_hasStoppedLearnUpload) {
        ToastUtils.showLoading();
        await LearnRecordManager.instance
            .stopTracking(source: _learnRecordSource);
        _hasStoppedLearnUpload = true;
      }
      if (!isClosed) {
        Get.back(result: {'learnUploadFinished': true, "isCompleted": isCompleted});
      }
    } finally {
      _isHandlingExit = false;
      ToastUtils.hideLoading();
    }
  }

  Future<void> _shutdownPlaybackBeforePop() async {
    _switchTimer?.cancel();
    _switchTimer = null;
    _debounceResetTimer?.cancel();
    _debounceResetTimer = null;
    _playerCompleteSubscription?.cancel();
    _playerCompleteSubscription = null;
    debounce = false;
    _sequenceVersion++;
    playStatus.value = false;
    isAudioPlaying.value = false;
    _playbackPhase = _PreviewPlaybackPhase.idle;
    previewAudioUtils.setNavigationHandlers(onNext: null, onPrevious: null);
    await _stopAllVideoControllers();
    await previewAudioUtils.stop();
  }

  /// 初始化音频播放器
  void audioPlayerInit() {
    previewAudioUtils.setNavigationHandlers(
      onNext: () async => nextClick(true),
      onPrevious: () async => previousClick(),
    );
    _playerCompleteSubscription?.cancel();
    _switchTimer?.cancel();
    _playerCompleteSubscription =
        previewAudioUtils.playCompleteStream.distinct().listen((state) async {
      // #region debug-point B:audio-complete-stream
      unawaited(_previewDebugLog('B', 'audio complete stream fired', data: {
        'state': state,
        'isPlaying': previewAudioUtils.isPlaying,
        'phase': _playbackPhase.name,
        'playStatus': playStatus.value,
        'progress': progress.value,
        'sequenceVersion': _sequenceVersion,
        'currentPlayNum': currentPlayNum.value,
      }));
      // #endregion
      if (_isClosing || isClosed) return;
      if (previewAudioUtils.isPlaying) return;
      if (debounce) return;
      if (_playbackPhase != _PreviewPlaybackPhase.audio) return;
      if (!playStatus.value) return;
      debounce = true;
      await _handleAudioPlaybackCompleted();
      _debounceResetTimer?.cancel();
      _debounceResetTimer = Timer(const Duration(milliseconds: 300), () {
        if (_isClosing || isClosed) return;
        debounce = false;
      });
    });
  }

  /// 设置新的音频资源
  Future<void> newAudioPlayer(
    UnitKnowledgePointsEntityKnowledgeList? model, {
    bool autoSequence = false,
  }) async {
    if (model == null || isClosed || _isClosing) return;
    // #region debug-point E:audio-start
    unawaited(_previewDebugLog('E', 'newAudioPlayer enter', data: {
      'content': model.content,
      'progress': progress.value,
      'sequenceVersion': _sequenceVersion,
      'autoSequence': autoSequence,
      'phase': _playbackPhase.name,
      'playStatus': playStatus.value,
    }));
    // #endregion
    // 如果当前正在切换音频，则只记录最新的一次请求，等当前切换完成再处理
    if (_isSwitchingAudio) {
      _pendingAudioModel = model;
      return;
    }

    _isSwitchingAudio = true;
    _pendingAudioModel = null;

    await _stopAllVideoControllers();

    final PronunciationsEntity? pronunciationModel =
        _resolvePlayablePronunciation(model);

    String urlString = pronunciationModel?.audioUrl ?? '';
    if (urlString.isEmpty) {
      // #region debug-point E:audio-missing
      unawaited(_previewDebugLog('E', 'audio missing for knowledge', data: {
        'content': model.content,
        'progress': progress.value,
        'sequenceVersion': _sequenceVersion,
        'national': national.value.value,
        'pronunciationCount': model.pronunciations?.length ?? 0,
      }));
      // #endregion
      isAudioPlaying.value = false;
      _isSwitchingAudio = false;
      if (autoSequence) {
        await _handleMissingAudioForSequence();
      }
      return;
    }

    try {
      totalDurationTime.value = pronunciationModel?.duration != null
          ? (pronunciationModel!.duration! * 1000).toInt()
          : 0;

      // 串行化 stop + prepare，避免在还没 stop 完就再次 prepare
      await previewAudioUtils.stop();

      // 提供锁屏信息（可按需丰富）
      await previewAudioUtils.prepare(
        url: urlString,
        title: model.content ?? '',
        artist: moduleName ?? '',
        album: unitName ?? '',
        image: resolveAudioArtworkUri(model),
        duration: Duration(milliseconds: totalDurationTime.value),
        androidCompactActionIndices: const [0, 1, 2],
        playSpeed: playSpeed.value,
      );
      // #region debug-point E:audio-prepared
      unawaited(_previewDebugLog('E', 'audio prepared', data: {
        'content': model.content,
        'progress': progress.value,
        'sequenceVersion': _sequenceVersion,
        'durationMs': totalDurationTime.value,
        'playSpeed': playSpeed.value,
      }));
      // #endregion

      if (!isClosed && !_isClosing) {
        _playbackPhase = _PreviewPlaybackPhase.audio;
        await previewAudioUtils.resume();
        playStatus.value = true;
        isAudioPlaying.value = true;
        // #region debug-point E:audio-resume
        unawaited(_previewDebugLog('E', 'audio resumed', data: {
          'content': model.content,
          'progress': progress.value,
          'sequenceVersion': _sequenceVersion,
          'phase': _playbackPhase.name,
        }));
        // #endregion
      }
    } catch (e) {
      // #region debug-point E:audio-error
      unawaited(_previewDebugLog('E', 'newAudioPlayer error', data: {
        'content': model.content,
        'progress': progress.value,
        'sequenceVersion': _sequenceVersion,
        'error': e.toString(),
      }));
      // #endregion
      // 这里不抛给上层，防止 just_audio 的内部异常导致页面崩溃
      debugPrint('newAudioPlayer error: $e');
    } finally {
      _isSwitchingAudio = false;

      // 如果在切换过程中又有新的切换请求，只保留最后一次，串行执行
      final nextModel = _pendingAudioModel;
      if (nextModel != null && !isClosed && !_isClosing) {
        _pendingAudioModel = null;
        // 不 await，防止递归过深；由下一次调用自己接管锁
        unawaited(newAudioPlayer(nextModel));
      }
    }
  }

  //播放 暂停
  void audioPlayAndPause() async {
    if (playStatus.value) {
      await _pausePlaybackPreservingPhase();
    } else {
      if (isCompleted.value) {
        isCompleted.value = false;
        currentPlayNum.value = 0;
        await _restartCurrentKnowledgeSequence();
      } else {
        await _resumePlaybackFromPause();
      }
    }
  }

  /// 播放设置
  void playSetting({bool isFirst = false}) async {
    final bool wasPlayingBeforeSetting = playStatus.value;
    await pausePlaybackForSetting();

    List<UnitKnowledgePointsEntityKnowledgeList> words = [];
    List<UnitKnowledgePointsEntityKnowledgeList> phrases = [];
    List<UnitKnowledgePointsEntityKnowledgeList> sentences = [];

    for (int i = 0; i < allKnowledgeList.length; i++) {
      if (allKnowledgeList[i].isWord) {
        words.add(allKnowledgeList[i]);
      } else if (allKnowledgeList[i].isPhrase) {
        phrases.add(allKnowledgeList[i]);
      } else if (allKnowledgeList[i].isSentence) {
        sentences.add(allKnowledgeList[i]);
      }
    }

    List<PreviewSettingKnowledgeTypeItemModel> knowledgePoints = [];
    if (words.isNotEmpty) {
      knowledgePoints.add(PreviewSettingKnowledgeTypeItemModel(
        type: ElementsCardType.word,
        typeText: '单词',
        count: words.length,
      ));
    }
    if (phrases.isNotEmpty) {
      knowledgePoints.add(PreviewSettingKnowledgeTypeItemModel(
        type: ElementsCardType.phrase,
        typeText: '短语',
        count: phrases.length,
      ));
    }
    if (sentences.isNotEmpty) {
      knowledgePoints.add(PreviewSettingKnowledgeTypeItemModel(
        type: ElementsCardType.sentence,
        typeText: '句子',
        count: sentences.length,
      ));
    }

    final UnitKnowledgePointsEntityKnowledgeList? currentKnowledge =
        _currentKnowledge ?? _preferredStartKnowledge;
    final int previousProgress = progress.value;
    if (isFirst) {
      _primeInitialKnowledgeListForVideoWarmup(currentKnowledge);
      unawaited(_warmupFirstVideoBehindSettingDialog());
    }

    final BuildContext? dialogContext = Get.context ?? Get.overlayContext;
    if (dialogContext == null) {
      return;
    }

    PreviewSettingModel? newGraph =
        await OfficialCourseDetailsPreviewSettingDialog.show(
      context: dialogContext,
      initModel: PreviewSettingModel(
        playMode:
            forceSequentialPlayMode && playMode.value == PlayerModeEnum.random
                ? PlayerModeEnum.list
                : playMode.value,
        playNum: playNum.value,
        playSpeed: playSpeed.value,
        knowledgePoints: knowledgePoints,
        playInterval: playInterval.value,
        selectedKnowledgePoints: _getSelectedKnowledgeTypes(knowledgePoints),
        national: national.value,
        textDisplayCode: _currentTextDisplayCode,
        enableRandomPlayMode: !forceSequentialPlayMode,
      ),
    );

    if (newGraph == null) {
      if (isFirst) {
        Get.back();
      } else if (wasPlayingBeforeSetting) {
        await _resumePlaybackFromPause();
      }
      return;
    }
    audioPlayerInit();

    playNum.value = newGraph.playNum;
    playSpeed.value = newGraph.playSpeed;
    playMode.value =
        forceSequentialPlayMode && newGraph.playMode == PlayerModeEnum.random
            ? PlayerModeEnum.list
            : newGraph.playMode;
    playInterval.value = newGraph.playInterval;
    national.value = newGraph.national;
    final configController = Get.find<ConfigController>();
    StorageUtil().setDouble(INTERVAL_SPEED_KEY, playInterval.value);
    await previewAudioUtils.setPlaybackRate(playSpeed.value);
    await previewVideoController.setPlaybackRate(playSpeed.value);
    await preloadVideoController.setPlaybackRate(playSpeed.value);

    playStatus.value = false;
    await previewAudioUtils.stop();
    await _stopAllVideoControllers();
    currentPlayNum.value = 0;

    sequentialKnowledgeList = allKnowledgeList
        .where((element) =>
            newGraph.selectedKnowledgePoints.contains(element.cardType))
        .toList();
    knowledgeList.value = sequentialKnowledgeList.toList();
    progress.value = _resolveProgressForUpdatedKnowledgeList(
      currentKnowledge: currentKnowledge,
      previousProgress: previousProgress,
    );
    if (playMode.value == PlayerModeEnum.random) {
      _resetRandomPlaybackState(currentIndex: progress.value);
    } else {
      _clearRandomPlaybackState();
    }
    _clearNextVideoPreload(resetController: false);

    if (playMode.value == PlayerModeEnum.singleLoop) {
      playNum.value = 1;
    }
    configController.setUserSetting(
      expandAudioSpeed: playSpeed.value,
      expandTranslationType: newGraph.textDisplayCode,
      expandPronunciationCode: national.value.value,
      expandInterval: playInterval.value,
      expandPlayOrder: playMode.value.value,
      expandPlayOrderLoopCount: playNum.value,
    );
    AudioControlUtils.saveSetting(AudioControlSettingModel(
      playbackRate: playSpeed.value,
      playOrder: playMode.value,
      playOrderLoopCount: playNum.value,
    ));

    if (knowledgeList.isEmpty) {
      isReady.value = false;
      return;
    }

    unawaited(_cachePreviewAssets());
    await _startLearnUploadIfNeeded();
    await _restartCurrentKnowledgeSequence();
    isReady.value = true;
  }

  Future<void> _startLearnUploadIfNeeded() async {
    if (!enableLearnUpload || _hasStartedLearnUpload || knowledgeList.isEmpty) {
      return;
    }
    _hasStartedLearnUpload = true;
    await LearnRecordManager.instance.startTracking(
      source: _learnRecordSource,
      type: learnUploadType,
    );
  }

  /// 上一个
  void previousClick() {
    debugPrint('上一个被点击');
    if (playMode.value == PlayerModeEnum.random) {
      if (_moveToPreviousRandomKnowledge()) {
        _clearPredictedNextRandomIndex();
        currentPlayNum.value = 0;
        unawaited(_restartCurrentKnowledgeSequence());
      } else {
        ToastUtils.showToast(text: '当前已是第一个');
      }
      return;
    }
    if (progress.value > 0) {
      currentPlayNum.value = 0;
      progress.value--;
      _clearPredictedNextRandomIndex();
      unawaited(_restartCurrentKnowledgeSequence());
    } else {
      if (playMode.value == PlayerModeEnum.list) {
        currentPlayNum.value = 0;
        progress.value = knowledgeList.length - 1;
        unawaited(_restartCurrentKnowledgeSequence());
      } else if (playMode.value == PlayerModeEnum.random) {
        ToastUtils.showToast(text: '当前已是第一个');
      } else if (playMode.value == PlayerModeEnum.singleLoop) {
        ToastUtils.showToast(text: '当前已是第一个');
      }
    }
  }

  /// 下一个
  Future<void> nextClick(bool isManual) async {
    debugPrint('下一个被点击=====$isManual');
    if (playMode.value == PlayerModeEnum.random) {
      if (_moveToNextRandomKnowledge(
        preferredIndex: _predictedNextRandomIndex,
      )) {
        _clearPredictedNextRandomIndex();
        currentPlayNum.value = 0;
        await _restartCurrentKnowledgeSequence();
      } else {
        _clearPredictedNextRandomIndex();
        await _stopPlaybackAtCurrentItem();
      }
      return;
    }
    if (progress.value < knowledgeList.length - 1) {
      currentPlayNum.value = 0;
      progress.value++;
      _clearPredictedNextRandomIndex();
      await _restartCurrentKnowledgeSequence();
    } else {
      _clearPredictedNextRandomIndex();
      if (playMode.value == PlayerModeEnum.list) {
        await _stopPlaybackAtCurrentItem();
      } else if (playMode.value == PlayerModeEnum.random) {
        await _stopPlaybackAtCurrentItem();
      } else if (playMode.value == PlayerModeEnum.singleLoop) {
        await _stopPlaybackAtCurrentItem();
      }
    }
  }

  Future<void> _stopPlaybackAtCurrentItem() async {
    currentPlayNum.value = 0;
    playStatus.value = false;
    isAudioPlaying.value = false;
    _playbackPhase = _PreviewPlaybackPhase.idle;
    isCompleted.value = true;
    _switchTimer?.cancel();
    await _stopAllVideoControllers();
    await previewAudioUtils.stop();
    _clearNextVideoPreload(resetController: false);

    /// 播放完成后 需要进行引导
    GuideTaskController.to.start(AppRoutesCode.courseDetilsPreview);
  }

  /// 修改播放模式
  void changePlayMode(PlayerModeEnum playMode) {
    if (forceSequentialPlayMode && playMode == PlayerModeEnum.random) {
      playMode = PlayerModeEnum.list;
    }
    final UnitKnowledgePointsEntityKnowledgeList? currentKnowledge =
        _currentKnowledge;
    final int previousProgress = progress.value;
    this.playMode.value = playMode;
    knowledgeList.value = sequentialKnowledgeList.toList();
    progress.value = _resolveProgressForUpdatedKnowledgeList(
      currentKnowledge: currentKnowledge,
      previousProgress: previousProgress,
    );
    if (playMode == PlayerModeEnum.random) {
      _resetRandomPlaybackState(currentIndex: progress.value);
    } else {
      _clearRandomPlaybackState();
    }
    _clearNextVideoPreload(resetController: false);
    currentPlayNum.value = 0;
    isCompleted.value = false;
    if (playMode == PlayerModeEnum.singleLoop) {
      playNum.value = 1;
    }
    audioPlayerInit();
    if (knowledgeList.isNotEmpty) {
      unawaited(_restartCurrentKnowledgeSequence());
    }

    Get.find<ConfigController>().setUserSetting(
      expandPlayOrder: this.playMode.value.value,
      expandPlayOrderLoopCount: playNum.value,
    );
    AudioControlUtils.saveSetting(
      AudioControlSettingModel(
        playOrder: playMode,
        playOrderLoopCount: playNum.value,
      ),
    );
  }

  /// 修改循环次数
  void changePlayNum(int playNum) {
    currentPlayNum.value = 0;
    this.playNum.value = playNum;
    audioPlayerInit();
    unawaited(_restartCurrentKnowledgeSequence());
    Get.find<ConfigController>().setUserSetting(
      expandPlayOrderLoopCount: playNum,
    );
    AudioControlUtils.saveSetting(
        AudioControlSettingModel(playOrderLoopCount: playNum));
  }

  /// 修改播放速度
  void changePlaySpeed(double speed) async {
    playSpeed.value = speed;
    await previewAudioUtils.setPlaybackRate(speed);
    await previewVideoController.setPlaybackRate(speed);
    await preloadVideoController.setPlaybackRate(speed);
    ConfigController configController = Get.find<ConfigController>();
    configController.setUserSetting(expandAudioSpeed: speed);
  }

  Future<void> onCurrentVideoFinished(
      SequenceTipsVideoFinishReason reason) async {
    // #region debug-point A:video-finished
    unawaited(_previewDebugLog('A', 'video finished callback', data: {
      'reason': reason.name,
      'phase': _playbackPhase.name,
      'playStatus': playStatus.value,
      'progress': progress.value,
      'sequenceVersion': _sequenceVersion,
    }));
    // #endregion
    if (_isClosing || isClosed) return;
    if (reason != SequenceTipsVideoFinishReason.completed) return;
    if (_playbackPhase != _PreviewPlaybackPhase.video) return;
    if (!playStatus.value || isClosed || _isClosing) return;
    final currentKnowledge = _currentKnowledge;
    if (currentKnowledge == null) return;
    final sequenceVersion = _sequenceVersion;
    _playbackPhase = _PreviewPlaybackPhase.waitingAfterVideo;
    _schedulePhaseTransition(_videoToAudioGap, sequenceVersion, () async {
      await _startAudioPhase(sequenceVersion, currentKnowledge);
    });
  }

  Future<void> _handleAudioPlaybackCompleted() async {
    // #region debug-point E:audio-completed-handler
    unawaited(_previewDebugLog('E', 'handle audio playback completed', data: {
      'progress': progress.value,
      'sequenceVersion': _sequenceVersion,
      'currentPlayNum': currentPlayNum.value,
      'playNum': playNum.value,
      'playMode': playMode.value.name,
    }));
    // #endregion
    final currentKnowledge = _currentKnowledge;
    if (currentKnowledge == null) return;
    isAudioPlaying.value = false;
    currentPlayNum.value++;
    final int sequenceVersion = _sequenceVersion;
    if (currentPlayNum.value < playNum.value) {
      _playbackPhase = _PreviewPlaybackPhase.waitingAfterAudio;
      _schedulePhaseTransition(_switchIntervalDuration, sequenceVersion,
          () async {
        await _restartCurrentKnowledgeAudioSequence();
      });
      return;
    }

    if (playMode.value == PlayerModeEnum.singleLoop) {
      currentPlayNum.value = 0;
      _playbackPhase = _PreviewPlaybackPhase.waitingAfterAudio;
      _schedulePhaseTransition(_switchIntervalDuration, sequenceVersion,
          () async {
        await _restartCurrentKnowledgeAudioSequence();
      });
      return;
    }

    _playbackPhase = _PreviewPlaybackPhase.waitingAfterAudio;
    _schedulePhaseTransition(_switchIntervalDuration, sequenceVersion,
        () async {
      await nextClick(false);
    });
  }

  Future<void> _handleMissingAudioForSequence() async {
    // #region debug-point E:audio-missing-handler
    unawaited(_previewDebugLog('E', 'handle missing audio for sequence', data: {
      'progress': progress.value,
      'sequenceVersion': _sequenceVersion,
      'phase': _playbackPhase.name,
    }));
    // #endregion
    if (!playStatus.value || isClosed || _isClosing) return;
    final int sequenceVersion = _sequenceVersion;
    if (playMode.value == PlayerModeEnum.singleLoop) {
      await _stopPlaybackAtCurrentItem();
      return;
    }
    _playbackPhase = _PreviewPlaybackPhase.waitingAfterAudio;
    _schedulePhaseTransition(_switchIntervalDuration, sequenceVersion,
        () async {
      await nextClick(false);
    });
  }

  Future<void> _restartCurrentKnowledgeSequence({
    bool resetPlayCount = true,
  }) async {
    final currentKnowledge = _currentKnowledge;
    if (currentKnowledge == null) return;
    _markKnowledgeViewed(currentKnowledge);
    final int sequenceVersion = ++_sequenceVersion;
    // #region debug-point C:sequence-restart
    unawaited(
        _previewDebugLog('C', 'restart current knowledge sequence', data: {
      'content': currentKnowledge.content,
      'progress': progress.value,
      'sequenceVersion': sequenceVersion,
      'playStatus': playStatus.value,
      'hasVideo': _shouldPlayVideo(currentKnowledge),
    }));
    // #endregion
    _switchTimer?.cancel();
    debounce = false;
    _playbackPhase = _PreviewPlaybackPhase.idle;
    await previewAudioUtils.stop();
    unawaited(_cachePreviewAssets());
    final bool preferRemoteMedia =
        _shouldPreferRemoteMediaForInitialEntryKnowledge(currentKnowledge);
    _freezeCurrentKnowledgeMediaPaths(
      currentKnowledge,
      preferRemoteMedia: preferRemoteMedia,
    );
    await _prepareVideoControllerForCurrentKnowledge(currentKnowledge);
    if (resetPlayCount) {
      currentPlayNum.value = 0;
    }
    isCompleted.value = false;
    playStatus.value = true;
    isAudioPlaying.value = false;
    if (_shouldPlayVideo(currentKnowledge)) {
      unawaited(_ensureNextKnowledgeVideoPreloaded());
      _playbackPhase = _PreviewPlaybackPhase.video;
      // #region debug-point A:video-start
      unawaited(_previewDebugLog('A', 'start video phase', data: {
        'content': currentKnowledge.content,
        'progress': progress.value,
        'sequenceVersion': sequenceVersion,
        'videoUrl': currentKnowledge.video?.videoUrl,
        'startSeconds': currentKnowledge.video?.startSeconds,
        'endSeconds': currentKnowledge.video?.endSeconds,
      }));
      // #endregion
      unawaited(_startVideoPhase(sequenceVersion, currentKnowledge));
      return;
    }
    unawaited(_ensureNextKnowledgeVideoPreloaded());
    await _startAudioPhase(sequenceVersion, currentKnowledge);
  }

  Future<void> _restartCurrentKnowledgeAudioSequence() async {
    final currentKnowledge = _currentKnowledge;
    if (currentKnowledge == null) return;
    final int sequenceVersion = ++_sequenceVersion;
    unawaited(_previewDebugLog('C', 'restart current knowledge audio sequence',
        data: {
          'content': currentKnowledge.content,
          'progress': progress.value,
          'sequenceVersion': sequenceVersion,
          'playStatus': playStatus.value,
          'currentPlayNum': currentPlayNum.value,
        }));
    _switchTimer?.cancel();
    debounce = false;
    _playbackPhase = _PreviewPlaybackPhase.idle;
    await previewAudioUtils.stop();
    unawaited(_cachePreviewAssets());
    unawaited(_ensureNextKnowledgeVideoPreloaded());
    isCompleted.value = false;
    playStatus.value = true;
    isAudioPlaying.value = false;
    await _startAudioPhase(sequenceVersion, currentKnowledge);
  }

  Future<void> replayFromStart() async {
    if (knowledgeList.isEmpty) return;
    progress.value = 0;
    if (playMode.value == PlayerModeEnum.random) {
      _resetRandomPlaybackState(currentIndex: progress.value);
    }
    _clearPredictedNextRandomIndex();
    currentPlayNum.value = 0;
    isCompleted.value = false;
    await _restartCurrentKnowledgeSequence();
  }

  Future<void> completePreview() async {
    await handleExit(isCompleted: true);
  }

  Future<void> _startVideoPhase(
    int sequenceVersion,
    UnitKnowledgePointsEntityKnowledgeList knowledge,
  ) async {
    final String videoUrl = resolveDisplayVideoPath(knowledge);
    if (videoUrl.isEmpty) {
      await _startAudioPhase(sequenceVersion, knowledge);
      return;
    }
    final bool isBound =
        await previewVideoController.waitUntilBoundToVideo(videoUrl);
    // #region debug-point C:video-bind-check
    unawaited(_previewDebugLog('C', 'wait video controller bind result', data: {
      'content': knowledge.content,
      'progress': progress.value,
      'sequenceVersion': sequenceVersion,
      'expectedVideoUrl': videoUrl,
      'boundVideoUrl': previewVideoController.currentVideoPath,
      'isBound': isBound,
      'currentSequenceVersion': _sequenceVersion,
      'playStatus': playStatus.value,
    }));
    // #endregion
    if (!isBound) {
      if (sequenceVersion == _sequenceVersion &&
          !isClosed &&
          !_isClosing &&
          playStatus.value) {
        await _startAudioPhase(sequenceVersion, knowledge);
      }
      return;
    }
    if (sequenceVersion != _sequenceVersion ||
        isClosed ||
        _isClosing ||
        !playStatus.value) {
      return;
    }
    isAudioPlaying.value = false;
    await previewAudioUtils.stop();
    await previewVideoController.setPlaybackRate(playSpeed.value);
    await previewVideoController.playOnce(
      muted: knowledge.video?.isMute ?? false,
    );
  }

  Future<void> _startAudioPhase(
    int sequenceVersion,
    UnitKnowledgePointsEntityKnowledgeList knowledge,
  ) async {
    // #region debug-point C:start-audio-phase
    unawaited(_previewDebugLog('C', 'start audio phase', data: {
      'content': knowledge.content,
      'progress': progress.value,
      'sequenceVersion': sequenceVersion,
      'currentSequenceVersion': _sequenceVersion,
      'playStatus': playStatus.value,
    }));
    // #endregion
    if (sequenceVersion != _sequenceVersion ||
        isClosed ||
        _isClosing ||
        !playStatus.value) {
      return;
    }
    await newAudioPlayer(
      knowledge,
      autoSequence: true,
    );
  }

  void _schedulePhaseTransition(
    Duration delay,
    int sequenceVersion,
    Future<void> Function() onRun,
  ) {
    _switchTimer?.cancel();
    // #region debug-point D:schedule-transition
    unawaited(_previewDebugLog('D', 'schedule phase transition', data: {
      'delayMs': delay.inMilliseconds,
      'sequenceVersion': sequenceVersion,
      'currentSequenceVersion': _sequenceVersion,
      'phase': _playbackPhase.name,
      'progress': progress.value,
    }));
    // #endregion
    _switchTimer = Timer(delay, () {
      // #region debug-point D:timer-fired
      unawaited(_previewDebugLog('D', 'phase transition timer fired', data: {
        'sequenceVersion': sequenceVersion,
        'currentSequenceVersion': _sequenceVersion,
        'phase': _playbackPhase.name,
        'progress': progress.value,
        'playStatus': playStatus.value,
        'isClosed': isClosed,
      }));
      // #endregion
      if (isClosed || _isClosing) return;
      if (!playStatus.value) return;
      if (sequenceVersion != _sequenceVersion) return;
      unawaited(onRun());
    });
  }

  Duration get _switchIntervalDuration {
    return Duration(
      milliseconds: (playInterval.value * 1000).round(),
    );
  }

  Future<void> pausePlaybackForSetting() async {
    await _pausePlaybackPreservingPhase();
  }

  Future<void> _pausePlaybackPreservingPhase() async {
    _switchTimer?.cancel();
    _sequenceVersion++;
    if (_playbackPhase == _PreviewPlaybackPhase.audio &&
        previewAudioUtils.isPlaying) {
      previewAudioUtils.pause();
      _playbackPhase = _PreviewPlaybackPhase.audioPaused;
    } else if (_playbackPhase == _PreviewPlaybackPhase.waitingAfterAudio) {
      _playbackPhase = _PreviewPlaybackPhase.waitingAfterAudioPaused;
    } else if (_playbackPhase == _PreviewPlaybackPhase.waitingAfterVideo) {
      _playbackPhase = _PreviewPlaybackPhase.waitingAfterVideoPaused;
    } else if (_playbackPhase == _PreviewPlaybackPhase.video) {
      await _stopAllVideoControllers();
      await previewAudioUtils.stop();
      _playbackPhase = _PreviewPlaybackPhase.videoPaused;
    } else {
      await _stopAllVideoControllers();
      await previewAudioUtils.stop();
      _playbackPhase = _PreviewPlaybackPhase.idle;
    }
    playStatus.value = false;
    isAudioPlaying.value = false;
  }

  Future<void> _resumePlaybackFromPause() async {
    final currentKnowledge = _currentKnowledge;
    if (currentKnowledge == null) return;
    if (_playbackPhase == _PreviewPlaybackPhase.audioPaused) {
      _playbackPhase = _PreviewPlaybackPhase.audio;
      await previewAudioUtils.resume();
      playStatus.value = true;
      isAudioPlaying.value = true;
      return;
    }
    if (_playbackPhase == _PreviewPlaybackPhase.waitingAfterAudioPaused) {
      final int sequenceVersion = ++_sequenceVersion;
      _playbackPhase = _PreviewPlaybackPhase.waitingAfterAudio;
      playStatus.value = true;
      _schedulePhaseTransition(_switchIntervalDuration, sequenceVersion,
          () async {
        if (playMode.value == PlayerModeEnum.singleLoop ||
            currentPlayNum.value < playNum.value) {
          await _restartCurrentKnowledgeAudioSequence();
          return;
        }
        await nextClick(false);
      });
      return;
    }
    if (_playbackPhase == _PreviewPlaybackPhase.waitingAfterVideoPaused) {
      final int sequenceVersion = ++_sequenceVersion;
      _playbackPhase = _PreviewPlaybackPhase.waitingAfterVideo;
      playStatus.value = true;
      _schedulePhaseTransition(_videoToAudioGap, sequenceVersion, () async {
        await _startAudioPhase(sequenceVersion, currentKnowledge);
      });
      return;
    }
    if (_playbackPhase == _PreviewPlaybackPhase.videoPaused) {
      await _restartCurrentKnowledgeSequence(resetPlayCount: false);
      return;
    }
    await _restartCurrentKnowledgeSequence(resetPlayCount: false);
  }

  List<ElementsCardType> _getSelectedKnowledgeTypes(
    List<PreviewSettingKnowledgeTypeItemModel> knowledgePoints,
  ) {
    final Set<ElementsCardType> selectedTypes =
        sequentialKnowledgeList.map((item) => item.cardType).toSet();
    if (selectedTypes.isEmpty) {
      return knowledgePoints.map((item) => item.type).toList();
    }
    return knowledgePoints
        .where((item) => selectedTypes.contains(item.type))
        .map((item) => item.type)
        .toList();
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
    _clearPredictedNextRandomIndex();
  }

  void _clearRandomPlaybackState() {
    _randomPlaybackOrder.clear();
    _randomPlaybackCursor = -1;
    _clearPredictedNextRandomIndex();
  }

  bool _moveToPreviousRandomKnowledge() {
    if (_randomPlaybackCursor <= 0) return false;
    _randomPlaybackCursor--;
    progress.value = _randomPlaybackOrder[_randomPlaybackCursor];
    return true;
  }

  bool _moveToNextRandomKnowledge({int? preferredIndex}) {
    if (knowledgeList.isEmpty) return false;
    if (_randomPlaybackCursor >= 0 &&
        _randomPlaybackCursor < _randomPlaybackOrder.length - 1) {
      _randomPlaybackCursor++;
      progress.value = _randomPlaybackOrder[_randomPlaybackCursor];
      return true;
    }
    final int? nextIndex = _pickNextRandomKnowledgeIndex(
      preferredIndex: preferredIndex,
    );
    if (nextIndex == null) return false;
    _randomPlaybackOrder.add(nextIndex);
    _randomPlaybackCursor = _randomPlaybackOrder.length - 1;
    progress.value = nextIndex;
    return true;
  }

  int? _pickNextRandomKnowledgeIndex({int? preferredIndex}) {
    if (knowledgeList.isEmpty) return null;
    final Set<int> visitedIndices = _randomPlaybackOrder.toSet();
    if (preferredIndex != null &&
        preferredIndex >= 0 &&
        preferredIndex < knowledgeList.length &&
        !visitedIndices.contains(preferredIndex)) {
      return preferredIndex;
    }
    final List<int> candidateIndices = <int>[];
    for (int i = 0; i < knowledgeList.length; i++) {
      if (!visitedIndices.contains(i)) {
        candidateIndices.add(i);
      }
    }
    if (candidateIndices.isEmpty) return null;
    return candidateIndices[_random.nextInt(candidateIndices.length)];
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

  UnitKnowledgePointsEntityKnowledgeList? get _currentKnowledge {
    if (knowledgeList.isEmpty) return null;
    if (progress.value < 0 || progress.value >= knowledgeList.length) {
      return null;
    }
    return knowledgeList[progress.value];
  }

  void _markKnowledgeViewed(UnitKnowledgePointsEntityKnowledgeList? knowledge) {
    if (!enableLearnUpload || knowledge == null) return;
    unawaited(LearnRecordManager.instance.markContentViewed(knowledge));
  }

  bool _shouldPlayVideo(UnitKnowledgePointsEntityKnowledgeList knowledge) {
    final bool preferVideo =
        Get.find<ConfigController>().currentShowResource.value ==
            ResourceTypeEnum.video;
    if (!preferVideo) return false;
    return (knowledge.video?.videoUrl ?? '').trim().isNotEmpty;
  }

  Future<void> _prepareVideoControllerForCurrentKnowledge(
    UnitKnowledgePointsEntityKnowledgeList currentKnowledge,
  ) async {
    _clearNextVideoPreload(resetController: false);
    await _preloadPreviewVideoController.release();
    if (_canUsePreloadedVideoForKnowledge(currentKnowledge)) {
      final SequenceTipsVideoWidgetController previousActiveController =
          _activePreviewVideoController;
      final SequenceTipsVideoWidgetController promotedController =
          _preloadPreviewVideoController;

      nextVideoPreloadIndex.value = -1;
      videoControllerEpoch.value++;
      await WidgetsBinding.instance.endOfFrame;

      await previousActiveController.stopAndReset();

      _activePreviewVideoController = promotedController;
      _preloadPreviewVideoController = previousActiveController;
      videoControllerEpoch.value++;
      await WidgetsBinding.instance.endOfFrame;
      return;
    }
    await _activePreviewVideoController.stopAndReset();
  }

  bool _canUsePreloadedVideoForKnowledge(
    UnitKnowledgePointsEntityKnowledgeList knowledge,
  ) {
    final String videoUrl = resolveDisplayVideoPath(knowledge);
    if (videoUrl.isEmpty) return false;
    if (nextVideoPreloadIndex.value != progress.value) return false;
    return preloadVideoController.currentVideoPath == videoUrl;
  }

  Future<void> _ensureNextKnowledgeVideoPreloaded() async {
    _clearNextVideoPreload(resetController: false);
    await _preloadPreviewVideoController.release();
  }

  void _clearPredictedNextRandomIndex() {
    _predictedNextRandomIndex = null;
  }

  void _clearNextVideoPreload({bool resetController = true}) {
    nextVideoPreloadIndex.value = -1;
    if (resetController) {
      unawaited(preloadVideoController.stopAndReset());
    }
  }

  Future<void> _stopAllVideoControllers() async {
    await _activePreviewVideoController.stopAndReset();
    await _preloadPreviewVideoController.stopAndReset();
  }

  Future<void> _releaseAllVideoControllers() async {
    await _stopAllVideoControllers();
    await _activePreviewVideoController.release();
    await _preloadPreviewVideoController.release();
  }

  void _primeInitialKnowledgeListForVideoWarmup(
    UnitKnowledgePointsEntityKnowledgeList? currentKnowledge,
  ) {
    if (knowledgeList.isNotEmpty) return;
    if (sequentialKnowledgeList.isEmpty) return;
    knowledgeList.value = sequentialKnowledgeList.toList();
    if (knowledgeList.isEmpty) return;
    if (currentKnowledge != null) {
      final int index = knowledgeList.indexWhere(
        (item) => _isSameKnowledge(item, currentKnowledge),
      );
      if (index != -1) {
        progress.value = index;
        unawaited(_cachePreviewAssets());
        return;
      }
    }
    progress.value = progress.value.clamp(0, knowledgeList.length - 1);
    unawaited(_cachePreviewAssets());
  }

  Future<void> _warmupFirstVideoBehindSettingDialog() async {
    final UnitKnowledgePointsEntityKnowledgeList? currentKnowledge =
        _currentKnowledge ?? _preferredStartKnowledge;
    if (currentKnowledge == null) return;
    if (!_shouldPlayVideo(currentKnowledge)) return;
    _initialEntryKnowledgeMediaIdentity =
        _buildKnowledgeMediaIdentity(currentKnowledge);
    _preferRemoteMediaForInitialEntryKnowledge = true;
    _freezeCurrentKnowledgeMediaPaths(
      currentKnowledge,
      preferRemoteMedia: true,
    );
    unawaited(_cachePreviewAssets());
    final String videoUrl = currentKnowledge.video?.videoUrl?.trim() ?? '';
    if (videoUrl.isEmpty) return;
    final int warmupVersion = ++_initialVideoWarmupVersion;
    await WidgetsBinding.instance.endOfFrame;
    if (_isClosing || isClosed || warmupVersion != _initialVideoWarmupVersion) {
      return;
    }
    final bool isBound = await previewVideoController.waitUntilBoundToVideo(
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
      await previewVideoController.setPlaybackRate(playSpeed.value);
      await previewVideoController.preload();
    } catch (_) {}
  }

  PlayerModeEnum _resolvePreviewPlayMode(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) {
      return PlayerModeEnum.list;
    }
    final PlayerModeEnum mode = PlayerModeEnum.fromRawValue(rawValue);
    if (mode == PlayerModeEnum.list ||
        mode == PlayerModeEnum.random ||
        mode == PlayerModeEnum.singleLoop) {
      return mode;
    }
    return PlayerModeEnum.list;
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

  String get currentPronunciationLabel => national.value.text;

  String get currentTextDisplayLabel {
    final String code = _currentTextDisplayCode;
    if (code == LangPreference.original.code) return '原文语言';
    if (code == LangPreference.translation.code) return '译文语言';
    if (code == LangPreference.none.code) return '隐藏文本';
    return '双语对照';
  }

  String get currentPlayModeLabel => playMode.value.title;

  String get currentPlayIntervalLabel {
    final List<UserPreferenceIntervalSpeedOption> menu =
        Get.find<ConfigController>().userSetting.value.intervalMenu ?? [];
    for (final item in menu) {
      if (item.value == playInterval.value) {
        return item.title ?? '${playInterval.value}秒';
      }
    }
    return '${playInterval.value}秒';
  }

  String get currentRepeatLabel {
    return '循环次数 ${playNum.value}次';
  }

  String get currentSpeedLabel => '倍速 ${playSpeed.value.toStringAsFixed(1)}x';

  Future<void> openCurrentKnowledgeDetail() async {
    if (knowledgeList.isEmpty) return;
    await pausePlaybackForSetting();
    final UnitKnowledgePointsEntityKnowledgeList currentKnowledge =
        knowledgeList[progress.value];
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

  String get _currentTextDisplayCode {
    final ConfigController configController = Get.find<ConfigController>();
    final String currentCode =
        configController.userSetting.value.expandLang.code;
    if (currentCode.isNotEmpty) {
      return currentCode;
    }
    final menus =
        configController.userSetting.value.expandDropdownMenu ?? const [];
    for (final item in menus) {
      final String code = (item.code ?? '').trim();
      if (code.isNotEmpty) {
        return code;
      }
    }
    return LangPreference.bilingual.code;
  }
}
