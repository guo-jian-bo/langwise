
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:video_player/video_player.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/favourite.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/public_controller/model/user_setting_model.dart';
import '../../../../common/widgets/add_favourite_dialog.dart';
import '../../../../common/widgets/player_widgets/player_jump_page_utils.dart';
import '../../../../common/widgets/player_widgets/player_ass_widget.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/interaction_record_utils/interaction_record_utils.dart';
import '../../../../utils/karaoke_subtitles_utils.dart';
import '../../../../utils/play_record_utils/play_record_utils.dart';
import '../../../../utils/utils.dart';
import 'zhendu_look_controller.dart';

class ZhenduLookPlayerController extends GetxController with WidgetsBindingObserver{
  final String tagText;
  ZhenduLookPlayerController({required this.tagText});

  /// 播放器
  Player player = Player(
    configuration: PlayerConfiguration(
      // Windows 首帧优先：降低 demuxer 缓冲，减少起播等待。
      bufferSize: Platform.isWindows ? 8 * 1024 * 1024 : 32 * 1024 * 1024,
    ),
  );
  bool _isPlayerDisposed = false;

  StreamSubscription<String>? errorSubscription;

  StreamSubscription<bool>? playingSubscription;
  /// 是否正在播放
  final RxBool isPlaying = false.obs;

  StreamSubscription<Duration>? durationSubscription;
  /// 资源时长
  final Rx<Duration> duration = Duration.zero.obs;

  StreamSubscription<Duration>? positionSubscription;
  /// 当前播放进度
  final Rx<Duration> position = Duration.zero.obs;

  /// 播放完成订阅：用于触发续播/定时停止逻辑
  StreamSubscription<bool>? completedSubscription;

  /// 播放速率
  final RxDouble speedMultiplier = 1.0.obs;

  /// 翻译状态
  final Rx<LangPreference> translateStatus = LangPreference.bilingual.obs;

  /// 文字大小倍数
  final Rx<FontSizeEnum> contentFontSizeMultiple = FontSizeEnum.standard.obs;

  /// 播放顺序
  final Rx<PlayerModeEnum> playOrderStatus = PlayerModeEnum.list.obs;

  /// 每一曲播放次数
  final RxInt playOrderLoopCount = 1.obs;

  /// 当前播放的次数
  final RxInt currentPlayCount = 0.obs;

  /// 当前音量
  final RxInt volume = 100.obs;

  /// 视频填充方式
  final Rx<VideoFitEnum> fitEnum = VideoFitEnum.contain.obs;

  /// 定时播放类型
  final Rx<PlayerTimingEnum> playerTiming = PlayerTimingEnum.close.obs;
  /// 定时播放剩余时长/几首 文本
  final RxString remainingTimeText = "".obs;

  /// 是否显示播放控制器
  final RxBool isShowAudioController = true.obs;
  Timer? isShowAudioControllerTimer;
  /// 定时播放倒计时定时器（分钟模式使用）
  Timer? timingCountDownTimer;

  /// 分钟定时剩余秒数
  int _timingRemainingSeconds = 0;
  /// 按首定时剩余首数
  int _timingRemainingSongCount = 0;

  /// 字幕列表
  final RxList<PlayerAssData<List<SentenceParsingWordsEntityList>?>> subtitleList = <PlayerAssData<List<SentenceParsingWordsEntityList>?>>[].obs;
  /// 字幕当前执行的句子下标
  final RxInt currentSentenceIndex = (-1).obs;
  /// 字幕当前执行的单词下标
  final RxInt currentWordIndex = (-1).obs;


  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    initUserSetting();
    listenPlayer();
  }

  /// 监听播放器
  void listenPlayer(){
    errorSubscription?.cancel();
    playingSubscription?.cancel();
    durationSubscription?.cancel();
    positionSubscription?.cancel();
    completedSubscription?.cancel();

    errorSubscription = player.stream.error.listen((event) {
      ErrorLogUtils.to.logError("[zhendu_look] $event", null);
    });

    playingSubscription = player.stream.playing.listen((event) {
      isPlaying.value = event;
      if(!event){
        currentWordIndex.value = -1;
      }
    });

    durationSubscription = player.stream.duration.listen((event) {
      duration.value = event;
    });

    positionSubscription = player.stream.position.listen((event) {
      position.value = event;
      final ZhenduLookController performController = Get.find<ZhenduLookController>(tag: tagText);
      if(performController.handleFrameOnlyPlaybackBoundary(event)){
        return;
      }
      // 自动播放：幕尾暂停 1 秒后再续播（给 PageView 切幕动画留出时间）。
      if(performController.handleAutoPlaybackFrameBoundary(event)){
        return;
      }
      positionSentenceAssIndex();
    });

    completedSubscription = player.stream.completed.listen((event) {
      if(!event) return;
      unawaited(_handlePlayCompleted());
    });
  }

  /// 获取本地储存的设置
  Future<void> initUserSetting() async{
    if(Get.isRegistered<ConfigController>()){
      UserSettingModel userSetting = Get.find<ConfigController>().userSetting.value;
      speedMultiplier.value = userSetting.expandAudioSpeed;
      translateStatus.value = userSetting.expandLang;
    }


    AudioControlSettingModel? setting = AudioControlUtils.getSetting();
    playOrderStatus.value = setting?.playOrder ?? PlayerModeEnum.list;
    playOrderLoopCount.value = setting?.playOrderLoopCount ?? 1;
    contentFontSizeMultiple.value = setting?.fontSize ?? FontSizeEnum.standard;
    volume.value = setting?.volume ?? 100;
    fitEnum.value = setting?.fit ?? VideoFitEnum.contain;
  }


  /// 处理ass的句子单词下标
  void positionSentenceAssIndex(){
    if (subtitleList.isEmpty) return;
    int mill = position.value.inMilliseconds;

    int targetSentenceIndex = -1;
    int targetWordIndex = -1;

    for (int i = 0; i < subtitleList.length; i++) {
      PlayerAssData item = subtitleList[i];
      if ((item.sentence.sentenceStartTime ?? 0) <= mill && (item.sentence.sentenceEndTime ?? 0) >= mill) {
        targetSentenceIndex = i;
        List<AssSubtitle> sentence = item.sentence.words;
        for (int j = 0; j < sentence.length; j++) {
          AssSubtitle sub = sentence[j];
          if (sub.startTime <= mill && sub.endTime >= mill) {
            targetWordIndex = j;
            break;
          }
        }
        break;
      }
    }

    if (currentSentenceIndex.value != targetSentenceIndex) {
      currentSentenceIndex.value = targetSentenceIndex;
      // 调用 查找对应的图片方法
      final ZhenduLookController performController = Get.find<ZhenduLookController>(tag: tagText);
      performController.changeFrameByAudioProgress(targetSentenceIndex);
    }
    if (currentWordIndex.value != targetWordIndex && isPlaying.value) {
      currentWordIndex.value = targetWordIndex;
    }

  }
  
  /// 控制栏的显示隐藏
  void toggleShowAudioController(){
    if(!isShowAudioController.value){
      startShowAudioControllerTimer(showWhenFrameOnlyMode: true);
    }else{
      isShowAudioControllerTimer?.cancel();
      isShowAudioControllerTimer = null;
      isShowAudioController.value = false;
    }
  }

  /// 开始控制栏的倒计时
  void startShowAudioControllerTimer({bool showWhenFrameOnlyMode = false}){
    final ZhenduLookController performController = Get.find<ZhenduLookController>(tag: tagText);
    if(performController.isFrameOnlyPlaybackMode && !showWhenFrameOnlyMode){
      hideAudioController();
      return;
    }
    isShowAudioController.value = true;
    isShowAudioControllerTimer?.cancel();
    isShowAudioControllerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      isShowAudioController.value = false;
    });
  }

  /// 直接隐藏控制栏 并且取消定时器
  void hideAudioController(){
    isShowAudioController.value = false;
    isShowAudioControllerTimer?.cancel();
    isShowAudioControllerTimer = null;
  }

  /// 播放器参数弹窗显示状态变化：
  /// - 弹窗显示时：固定展示控制栏并停止自动隐藏倒计时；
  /// - 弹窗关闭时：重新启动自动隐藏倒计时。
  void onPlayerPopupVisibilityChanged(bool visible){
    final ZhenduLookController performController = Get.find<ZhenduLookController>(tag: tagText);
    if(performController.isFrameOnlyPlaybackMode){
      hideAudioController();
      return;
    }
    if(visible){
      isShowAudioController.value = true;
      isShowAudioControllerTimer?.cancel();
      isShowAudioControllerTimer = null;
      return;
    }
    startShowAudioControllerTimer();
  }

  /// 打开视频资源（优先缓存，未命中则走网络并后台缓存）
  /// 1) 先快速等待缓存结果，命中就直接播本地文件；
  /// 2) 超时则立即播放网络地址，避免首次下载阻塞；
  /// 3) 后台继续缓存，但不在当前播放中途切换到本地文件。
  Future<void> open(String url, ResourceType resourceType) async{
    if(url.isEmpty) return ToastUtils.showToast(text: "播放地址为空");
    if(!GetUtils.isURL(url)) return ToastUtils.showToast(text: "播放地址格式错误");

    Future<String?> cacheFuture = CacheManagerUtils.instance.getFile(url, resourceType);
    String? fastCachePath;
    try {
      fastCachePath = await cacheFuture.timeout(const Duration(milliseconds: 350));
    } catch (_) {}
    if(isClosed) return;

    if(fastCachePath != null && fastCachePath.isNotEmpty){
      await _openSource(fastCachePath);
      return;
    }

    await _openSource(url);
    // 首次未命中缓存时，只做后台缓存，不做播放源切换。
    unawaited(cacheFuture);
  }

  /// 播放/暂停
  Future<void> onPlayPause(bool playing) async{
    if(!isPlaying.value){
      final ZhenduLookController performController = Get.find<ZhenduLookController>(tag: tagText);
      performController.exitFrameOnlyPlaybackMode();
    }
    await player.playOrPause();
  }

  /// 手势双击播放/暂停：切到播放时恢复正常连播模式。
  Future<void> onGesturePlayPause() async{
    if(!isPlaying.value){
      final ZhenduLookController performController = Get.find<ZhenduLookController>(tag: tagText);
      performController.exitFrameOnlyPlaybackMode();
    }
    await player.playOrPause();
  }

  /// 改变进度
  Future<void> onSeek(
    Duration value, {
    bool exitFrameOnlyMode = true,
    bool userInitiated = true,
  }) async {
    if(exitFrameOnlyMode){
      final ZhenduLookController performController = Get.find<ZhenduLookController>(tag: tagText);
      performController.exitFrameOnlyPlaybackMode();
    }
    if(userInitiated){
      final ZhenduLookController performController = Get.find<ZhenduLookController>(tag: tagText);
      performController.onUserSeek(value);
    }
    await player.seek(value);
  }

  /// 上一首/下一首
  /// 随机模式走 randomPoolIndices，其它模式按列表顺序循环切换。
  Future<void> onPreviousNext(PlayerControllerDirection direction) async{
    final ZhenduLookController performController = Get.find<ZhenduLookController>(tag: tagText);
    if(performController.songList.isEmpty) return;
    ZhenduDetilEntity? currentSong = performController.currentSong;
    if(currentSong == null) return;
    final currentUniqueKey = performController.getSongUniqueKeyBySong(currentSong);
    int currentIndex = performController.songList.indexWhere((e) => performController.getSongUniqueKeyBySong(e) == currentUniqueKey);
    if(currentIndex < 0){
      currentIndex = 0;
    }

    ZhenduDetilEntity? targetSong;
    PlayerModeEnum mode = playOrderStatus.value;
    if(mode == PlayerModeEnum.random){
      List<ZhenduDetilEntity> randomList = performController.randomPoolIndices.toList();
      if(randomList.isEmpty) return;
      int randomIndex = randomList.indexWhere((e) => performController.getSongUniqueKeyBySong(e) == currentUniqueKey);
      if(randomIndex < 0){
        randomIndex = 0;
      }
      targetSong = _findSupportedSongByDirection(
        list: randomList,
        currentIndex: randomIndex,
        direction: direction,
      );
    }else{
      targetSong = _findSupportedSongByDirection(
        list: performController.songList.toList(),
        currentIndex: currentIndex,
        direction: direction,
      );
    }
    if(targetSong == null) return;
    await performController.switchSong(targetSong);
  }

  /// 查找支持播放的歌曲
  ZhenduDetilEntity? _findSupportedSongByDirection({
    required List<ZhenduDetilEntity> list,
    required int currentIndex,
    required PlayerControllerDirection direction,
  }){
    if(list.isEmpty) return null;
    int index = currentIndex;
    for(int i = 0; i < list.length; i++){
      if(direction == PlayerControllerDirection.next){
        index = (index + 1) % list.length;
      }else{
        index = (index - 1 + list.length) % list.length;
      }
      final ZhenduDetilEntity song = list[index];
      if(song.contentInfo?.learnTypeSupport != false){
        return song;
      }
    }
    return null;
  }

  /// 收藏
  Future<void> onFavorite(bool value) async{
    final ZhenduLookController performController = Get.find<ZhenduLookController>(tag: tagText);

    ZhenduDetilEntity? song = performController.currentSong;
    if(song == null) return;
    if (song.contentInfo?.isFavorite == true) {
      //todo:取消收藏
      song.contentInfo?.favorited = false;
      var res = await FavouriteRequest.removeContent(
        playListId: 0, 
        uid: song.contentId!, 
        type: song.contentType!, 
        styleId: song.contentInfo?.styleId, 
        dialect: song.contentInfo?.dialect,
      );
      if (!res) {
        song.contentInfo?.favorited = true;
      }
    } else {
      song.contentInfo?.favorited = true;
      var res = await FavouriteRequest.addContent(
        playListId: 0, 
        uid: song.contentId!, 
        type: song.contentType!, 
        styleId: song.contentInfo?.styleId, 
        dialect: song.contentInfo?.dialect,
      );
      if (res) {
        AddFavouriteDialog.show(Get.context!, song.contentId!, song.contentType!, styleId: song.contentInfo?.styleId, dialect: song.contentInfo?.dialect);
      } else {
        song.contentInfo?.favorited = false;
        ToastUtils.showToast(text: '收藏失败');
      }
    }
    performController.songList.refresh();
  }

  /// 改变音量
  Future<void> onVolumeChange(int value) async{
    volume.value = value;
    AudioControlUtils.saveSetting(AudioControlSettingModel(volume: value));
    await player.setVolume(value.toDouble());
  }

  /// 改变视频填充方式
  Future<void> onFitChange(VideoFitEnum value) async{
    fitEnum.value = value;
    AudioControlUtils.saveSetting(AudioControlSettingModel(fit: value));
  }

  /// 改变播放速率
  Future<void> onSpeedMultiplierChange(double value) async{
    speedMultiplier.value = value;
    await player.setRate(value);
    ConfigController configController = Get.find<ConfigController>();
    configController.setUserSetting(expandAudioSpeed: value);
  }

  /// 改变翻译状态
  Future<void> onSubtitleChange(LangPreference value) async{
    translateStatus.value = value;
    ConfigController configController = Get.find<ConfigController>();
    configController.setUserSetting(expandTranslationType: value.code);
  }

  /// 改变文字大小倍数
  Future<void> onSubtitleFontSizeChange(FontSizeEnum value) async{
    contentFontSizeMultiple.value = value;
    AudioControlUtils.saveSetting(AudioControlSettingModel(fontSize: value));
  }

  /// 定时播放
  Future<void> onPlayerTimingChange(PlayerTimingEnum value) async{
    _applyTimingSetting(value);
  }

  /// 改变播放顺序
  Future<void> onModeChange(PlayerModeEnum value) async{
    playOrderStatus.value = value;
    AudioControlUtils.saveSetting(AudioControlSettingModel(playOrder: value));
  }

  /// 改变每一曲播放次数
  Future<void> onLoopCountChange(int value) async{
    playOrderLoopCount.value = value;
    AudioControlUtils.saveSetting(AudioControlSettingModel(playOrderLoopCount: value));
  }

  /// 下载音频
  Future<void> downloadAudio(BuildContext context) async {
    final ZhenduLookController performController = Get.find<ZhenduLookController>(tag: tagText);
    player.pause();
    DownloadPlayerAudioUtils.downloadAudio(context: context, song: performController.currentSong);
  }

  /// 弹出错误反馈弹窗
  Future<void> showFeedbackErrorContentDialog(BuildContext context) async {
    final ZhenduLookController performController = Get.find<ZhenduLookController>(tag: tagText);

    await player.pause();

    ZhenduDetilEntity? song = performController.currentSong;

    FeedbackErrorContentDialog.show(
      context: context, 
      position: position.value,
      name: song?.contentInfo?.title, 
      content: song?.contentInfo?.content, 
      contentType: song?.contentType, 
      contentId: song?.contentId,
    );

  }

  /// 点击歌词打开小词典
  Future<void> openSmallDictionary(BuildContext context, PlayerAssData sentence, AssSubtitle ass, int sentenceIndex, int wordIndex) async {

    bool playing = isPlaying.value;
    await player.pause();
    currentSentenceIndex.value = sentenceIndex;
    currentWordIndex.value = wordIndex;

    await getSentenceWordAss(sentence);

    SentenceParsingWordsEntityList? wordInfo;

    List<SentenceParsingWordsEntityList>? wordInfoList = sentence.data;

    if ((wordInfoList?.length??0) > wordIndex) {
      wordInfo = wordInfoList?[wordIndex];
    }

    bool wordContentisNull = wordInfo?.imageUrl == null && wordInfo?.contentPosList == null && wordInfo?.pronunciations == null;

    if (wordInfo == null || wordContentisNull) {
      ToastUtils.showToast(text: "词库正在努力扩充中~", type: ToastType.warning);
      if(playing) player.play();
      return;
    }

    bool isToDetail = await SimpleDictionaryDialog.show(
      context: context,
      wordInfo: wordInfo,
    );

    if(isToDetail) return;

    if(playing) player.play();

  }

  /// 获取句子中单词的解析
  Future<void> getSentenceWordAss(PlayerAssData sentence) async {
    List<SentenceParsingWordsEntityList>? wordInfoList = sentence.data;
    if (wordInfoList != null) return;
    final List<SentenceParsingWordsEntityList>? wordList =
        await SimpleDictionaryDialog.getSentenceWordAssList(
      words: sentence.sentence.words,
      getText: (word) => word.text,
      getLeftSpace: (word) => word.leftSpace,
      getRightSpace: (word) => word.rightSpace,
    );
    if (wordList == null || wordList.isEmpty) return;
    sentence.data = wordList;
  }




  /// 实际打开播放源，并恢复公共播放参数。
  /// [resumePosition] 和 [keepPlaying] 用于网络源切缓存源时尽量无感切换。
  Future<void> _openSource(String source, {Duration? resumePosition, bool? keepPlaying}) async{
    try {
      await player.open(Media(source));
      await player.setRate(speedMultiplier.value);
      await player.setVolume(volume.value.toDouble());
      if(resumePosition != null && resumePosition > Duration.zero){
        await player.seek(resumePosition);
      }
      if(keepPlaying != null){
        if(keepPlaying){
          await player.play();
        }else{
          await player.pause();
        }
      }
    } catch (e) {
      ToastUtils.showToast(text: "打开播放源失败");
      ErrorLogUtils.to.logError("[zhendu_look] ${e.toString()}", null);
    }
  }

  /// 改变页面类型
  Future<void> onPageTypeChange(ZhenduLearnItems value) async{
    final ZhenduLookController performController = Get.find<ZhenduLookController>(tag: tagText);
    ZhenduDetilEntity? song = performController.currentSong;
    if(song == null) return;
    await player.pause();
    await _disposePlayerSafely();
    
    await PlayerJumpPageUtils.jumpToPage(
      pageType: value.pageType,
      contentId: song.contentId,
      contentType: song.contentType,
      semanticId: null,
      styleId: song.contentInfo?.styleId,
      dialect: song.contentInfo?.dialect,
      contents: performController.contents,
      typeId: performController.typeId,
      traceAdminHeader: performController.traceAdminHeader,
    );
  }

  /// 单曲播放结束后的续播策略：
  /// - singleLoop: 同曲无限循环；
  /// - single: 同曲按 loopCount 次数播放后停止；
  /// - list/random: 当前曲按 loopCount 次数播放后切到下一曲。
  Future<void> _handlePlayCompleted() async{
    final ZhenduLookController performController = Get.find<ZhenduLookController>(tag: tagText);

    performController.exitFrameOnlyPlaybackMode();

    // 播放完成时上报（使用资源总时长作为播放时长）
    final duration = performController.currentSong?.contentInfo?.audioInfo?.duration ?? 0;
    await PlayRecordManager.instance.reportPlayComplete(duration.toDouble());
    InteractionSessionManager.instance.notifyPlaybackCompleted();

    await Future.delayed(const Duration(milliseconds: 500));
    if(isClosed) return;
    performController.resetFramePageToFirst();

    // “播完当前/2首/3首”优先于播放模式，达到目标后直接停止。
    if(_isCompleteTiming(playerTiming.value)){
      _timingRemainingSongCount--;
      if(_timingRemainingSongCount <= 0){
        await _onTimingReached();
        await performController.restartTrackingForReplay();
        return;
      }
      _updateTimingSongText();
    }

    if(playOrderStatus.value == PlayerModeEnum.singleLoop){
      await player.seek(Duration.zero);
      await player.play();
      await performController.restartTrackingForReplay();
      return;
    }

    currentPlayCount.value++;
    if(playOrderStatus.value == PlayerModeEnum.single){
      if(currentPlayCount.value < playOrderLoopCount.value){
        await player.seek(Duration.zero);
        await player.play();
        await performController.restartTrackingForReplay();
      }else{
        currentPlayCount.value = 0;
        await player.pause();
        await player.seek(Duration.zero);
        await performController.restartTrackingForReplay();
      }
      return;
    }

    if(currentPlayCount.value < playOrderLoopCount.value){
      await player.seek(Duration.zero);
      await player.play();
      await performController.restartTrackingForReplay();
      return;
    }

    currentPlayCount.value = 0;
    await onPreviousNext(PlayerControllerDirection.next);
  }

  /// 应用定时播放设置，并初始化对应的倒计时/剩余首数。
  void _applyTimingSetting(PlayerTimingEnum value){
    playerTiming.value = value;
    _timingRemainingSeconds = 0;
    _timingRemainingSongCount = 0;
    timingCountDownTimer?.cancel();
    timingCountDownTimer = null;

    switch(value){
      case PlayerTimingEnum.minutes15:
        _timingRemainingSeconds = 15 * 60;
        _updateTimingTextBySeconds();
        _startTimingCountDown();
        break;
      case PlayerTimingEnum.minutes30:
        _timingRemainingSeconds = 30 * 60;
        _updateTimingTextBySeconds();
        _startTimingCountDown();
        break;
      case PlayerTimingEnum.minutes60:
        _timingRemainingSeconds = 60 * 60;
        _updateTimingTextBySeconds();
        _startTimingCountDown();
        break;
      case PlayerTimingEnum.complete:
        _timingRemainingSongCount = 1;
        _updateTimingSongText();
        break;
      case PlayerTimingEnum.complete2:
        _timingRemainingSongCount = 2;
        _updateTimingSongText();
        break;
      case PlayerTimingEnum.complete3:
        _timingRemainingSongCount = 3;
        _updateTimingSongText();
        break;
      case PlayerTimingEnum.close:
        remainingTimeText.value = "";
        break;
    }
  }

  /// 启动分钟定时倒计时，每秒刷新剩余文本，到点后自动暂停。
  void _startTimingCountDown(){
    timingCountDownTimer?.cancel();
    timingCountDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if(!_isMinutesTiming(playerTiming.value)){
        timer.cancel();
        timingCountDownTimer = null;
        return;
      }

      _timingRemainingSeconds--;
      if(_timingRemainingSeconds <= 0){
        unawaited(_onTimingReached());
        return;
      }
      _updateTimingTextBySeconds();
    });
  }

  /// 是否为分钟倒计时类型（15/30/60 分钟）。
  bool _isMinutesTiming(PlayerTimingEnum timing){
    return timing == PlayerTimingEnum.minutes15 ||
        timing == PlayerTimingEnum.minutes30 ||
        timing == PlayerTimingEnum.minutes60;
  }

  /// 是否为按首数结束类型（播完当前/2首/3首）。
  bool _isCompleteTiming(PlayerTimingEnum timing){
    return timing == PlayerTimingEnum.complete ||
        timing == PlayerTimingEnum.complete2 ||
        timing == PlayerTimingEnum.complete3;
  }

  /// 将分钟倒计时格式化为 mm:ss 文案并更新到 UI。
  void _updateTimingTextBySeconds(){
    if(_timingRemainingSeconds <= 0){
      remainingTimeText.value = "";
      return;
    }
    remainingTimeText.value = DateFormatUtil.convertMillisecondsToMinSec(_timingRemainingSeconds * 1000);
  }

  /// 更新“剩余首数”文案（例如：2首）。
  void _updateTimingSongText(){
    if(_timingRemainingSongCount <= 0){
      remainingTimeText.value = "";
      return;
    }
    remainingTimeText.value = "$_timingRemainingSongCount首";
  }

  /// 定时触发后的统一收口：停止倒计时、清空状态并暂停播放。
  Future<void> _onTimingReached() async{
    timingCountDownTimer?.cancel();
    timingCountDownTimer = null;
    _timingRemainingSeconds = 0;
    _timingRemainingSongCount = 0;
    remainingTimeText.value = "";
    playerTiming.value = PlayerTimingEnum.close;
    await player.pause();
  }

  /// 关闭控制栏的倒计时
  @override
  void onClose(){
    try {
      WidgetsBinding.instance.removeObserver(this);
      isShowAudioControllerTimer?.cancel();
      timingCountDownTimer?.cancel();
      playingSubscription?.cancel();
      durationSubscription?.cancel();
      positionSubscription?.cancel();
      completedSubscription?.cancel();
      errorSubscription?.cancel();
    } catch (_) {
      
    }
    unawaited(_disposePlayerSafely());
    super.onClose();
  }

  Future<void> _disposePlayerSafely() async {
    if (_isPlayerDisposed) return;
    _isPlayerDisposed = true;
    try {
      await player.dispose();
    } catch (e, s) {
      ErrorLogUtils.to.logError('[ZhenduLook] dispose player error: $e', s);
    }
  }

}
