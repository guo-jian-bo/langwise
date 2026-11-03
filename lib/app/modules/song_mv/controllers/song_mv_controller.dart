import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/https/https.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/favourite.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/public_controller/model/user_setting_model.dart';
import '../../../../common/public_controller/mv_player_global_float_controller.dart';
import '../../../../common/values/values.dart';
import '../../../../common/widgets/add_favourite_dialog.dart';
import '../../../../common/widgets/audio_control_widget.dart';
import '../../../../common/widgets/image_animation_switcher/image_animation_switcher.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/karaoke_subtitles_utils.dart';
import '../../../../utils/play_record_utils/play_record_utils.dart';
import '../../../../utils/utils.dart';
import '../models/song_sentence_model.dart';
import '../views/timing_close_menu_dialog.dart';

class SongMvController extends GetxController with WidgetsBindingObserver {

  static SongMvController get to => Get.find<SongMvController>();

  /// type: unit, favorite, collection, none
  String? type;

  int? typeId;

  /// 用作当前知识点的id
  int? contentId;

  /// 用作当前知识点的类型
  String? contentType;

  int? milliseconds;

  /// 知识点参数 [{"contentId": 123, "contentType": "EN_SONG"}]
  List<Map<String, dynamic>>? contents;




  /// 所有数据
  final Rx<SongEntity> songData = SongEntity().obs;

  /// 歌曲列表
  final RxList<SongEntityList> songList = <SongEntityList>[].obs;

  /// 伪随机数池 用于随机播放
  final RxList<SongEntityList> randomPoolIndices = <SongEntityList>[].obs;

  /// 没有ass时候的句子列表
  final RxList<SongSentenceModel> noAssSentenceList = <SongSentenceModel>[].obs;

  /// 当前播放的歌曲的句子列表
  final RxList<SongSentenceModel> playSentenceList = <SongSentenceModel>[].obs;

  /// 当前播放的句子下标
  final RxInt playSentenceIndex = 0.obs;

  /// 歌词的准备结果 -1=未准备好 0=准备好了 1=没有歌词
  final RxInt lyricReadyResult = (-1).obs;

  /// 页面脚手架key 用作打开抽屉(播放列表)
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  /// 音频播放工具
  final AudioPlaybackUtils audioPlayerUtils = AudioPlaybackUtils();

  /// 音频控制组件的控制器
  final AudioControlController audioControlController = AudioControlController();

  /// 播放速度
  final RxDouble playbackRate = 1.0.obs;

  /// 语言模式显示
  final Rx<LangPreference> audioControlTranslate = LangPreference.bilingual.obs;

  /// 播放模式
  final Rx<AudioControlPlayOrder> audioControlPlayOrder = AudioControlPlayOrder.loop.obs;

  /// 循环次数
  final RxInt audioLoopCount = 1.obs;

  /// 当前播放的次数
  final RxInt currentPlayCount = 0.obs;

  /// 文字大小
  final RxDouble audioFontSizeMultiple = (1.0).obs;

  /// 是否是播放状态
  final RxBool isPlaying = false.obs;

  /// 图片切换控制器
  final ImageAnimationSwitcherController imageSwitcherController = ImageAnimationSwitcherController();

  /// 当前的知识点列表 用作图片轮播
  final RxList<SongEntityListSubContentList> currentKnowledgeList = <SongEntityListSubContentList>[].obs;

  /// 当前的知识点下标
  final RxInt currentKnowledgeIndex = (-1).obs;

  /// 是否显示菜单栏
  final RxBool isShowMenu = true.obs;

  /// 菜单栏的计时
  Timer? menuShowTimer;

  /// 当前播放歌曲的id
  final RxInt currentContentId = (-1).obs;

  /// 当前播放歌曲的信息
  SongEntityList? get currentSong => songList.firstWhereOrNull((element) => element.contentId == currentContentId.value);

  /// 是否展示知识点列表
  final RxBool isShowKnowledgeList = false.obs;

  /// 是否正在加载中
  final RxBool isLoadingData = false.obs;

  /// 一次加载10条
  final int pageSize = 50;

  /// 当前已加载的数据数量
  int _loadedCount = 0;

  /// 是否还有更多数据
  final RxBool hasMoreData = true.obs;


  bool isInitAudioSetting = false;

  bool isShowLockDialog = false;

  /// 切换的时候是否加载中  只在本页面显示
  final RxBool isSwitchLoadingUI = false.obs;

  StreamSubscription<bool>? _completeSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _pauseResumeSub;
  StreamSubscription<bool>? _floatButtonStatusSub;
  


  /// 定时关闭菜单选择下标
  int timingCloseMenuIndex = -1;

  /// 定时关闭计时器（按分钟）
  Timer? _timingCloseTimer;

  /// 定时关闭剩余秒数（按分钟）
  int _timingCloseRemainingSeconds = 0;

  /// 定时关闭显示字符串
  final RxString timingCloseDisplayStr = "".obs;

  /// 定时关闭剩余首数（按次数）
  int _timingCloseSongCount = 0;

  /// 应用是否在前台
  bool _isAppInForeground = true;



  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    initAudioPlayerEvent();
    listenerUserSettingshUserSettings();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppInForeground = state == AppLifecycleState.resumed;
  }

  /// 没有参数的情况跳转进来
  void noParam() {
    startMenuShowTime();
    MvPlayerGlobalFloatController.to.hide();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      audioControlController.reloadAudioInfo();
      WakelockPlus.enable();
    });
  }

  /// 设置参数 跳转到这个页面之前需要设置
  Future<void> setParam(
    List<Map<String, dynamic>> contents, 
    {int? contentId, String? contentType, int? milliseconds, String? type, int? typeId}) async{
    this.contents = contents;
    this.contentId = contentId;
    this.contentType = contentType;
    this.milliseconds = milliseconds;
    this.type = type;
    this.typeId = typeId;

    if(!isInitAudioSetting){
      isInitAudioSetting = true;
      if(Get.isRegistered<ConfigController>()){
        UserSettingModel userSetting = Get.find<ConfigController>().userSetting.value;
        playbackRate.value = userSetting.expandAudioSpeed;
        audioControlTranslate.value = userSetting.expandLang;
      }
      
    }

    // 初始化参数后需要重新获取数据

    songList.clear();
    randomPoolIndices.clear();
    _loadedCount = 0;
    playSentenceIndex.value = 0;
    lyricReadyResult.value = -1;
    currentPlayCount.value = 0;
    currentKnowledgeList.clear();
    currentKnowledgeIndex.value = -1;
    currentContentId.value = -1;
    isShowKnowledgeList.value = false;
    isLoadingData.value = true;
    hasMoreData.value = true;

    initAudioPlayerEvent();
    
    await getSongData();

    MvPlayerGlobalFloatController.to.toggleIsShowFloatButton(false);

    WakelockPlus.enable();
  }

  /// 监听用户设置的倍速和显示模式
  void listenerUserSettingshUserSettings(){
    if(Get.isRegistered<ConfigController>()){
      ever(Get.find<ConfigController>().userSetting, (value){
        playbackRate.value = value.expandAudioSpeed;
        audioPlayerUtils.setPlaybackRate(playbackRate.value);
        audioControlTranslate.value = value.expandLang;
      });
    }
    
  }

  /// 返回页面
  void back() {
    MvPlayerGlobalFloatController.to.toggleIsShowFloatButton(true);
    WakelockPlus.disable();
  }

  /// 停止播放
  Future<void> stop() async{
    WakelockPlus.disable();
    await audioPlayerUtils.stop();
    await PlayRecordManager.instance.stopTracking(source: 'song_mv');
    isPlaying.value = false;
    _completeSub?.cancel();
    _positionSub?.cancel();
    _pauseResumeSub?.cancel();
    _cancelTimingCloseTask();
  }

  /// 监听音频事件
  void initAudioPlayerEvent() {
    _completeSub?.cancel();
    _positionSub?.cancel();
    _pauseResumeSub?.cancel();
    _floatButtonStatusSub?.cancel();

    AudioControlSettingModel? setting = AudioControlUtils.getSetting();
    audioControlPlayOrder.value = setting?.playOrder ?? AudioControlPlayOrder.loop;
    audioLoopCount.value = setting?.playOrderLoopCount ?? 1;
    audioFontSizeMultiple.value = setting?.fontSizeMultiple ?? 1.0;

    _completeSub = audioPlayerUtils.playCompleteStream.listen((event) async {
      print("播放完成");
      playCompleteHandle();
    });

    _pauseResumeSub = audioPlayerUtils.pauseResumeStream.listen((event) {
      isPlaying.value = event;
      MvPlayerGlobalFloatController.to.toggleIsPlayingOnly(event);
    });

    _positionSub = audioPlayerUtils.positionStream.listen((event) {
      if (!audioPlayerUtils.isPlaying) return;
      int mill = event.inMilliseconds;
      
      // 只在前台时更新UI相关的歌词高亮，后台只更新锁屏歌词
      if (_isAppInForeground) {
        playHighlightWord(mill);
      } else {
        _updateLockScreenLyricOnly(mill);
      }

      SongEntityList? song = songList.firstWhereOrNull((element) => element.contentId == currentContentId.value);

      if(song != null){
        MvPlayerGlobalFloatController.to.setProgress(
          Duration(seconds: (song.audioInfo?.duration ?? 0).toInt()), 
          event,
        );
      }
    });

    _floatButtonStatusSub = MvPlayerGlobalFloatController.to.playPauseEventStreamController.listen((playing) {
      if(playing){
        audioPlayerUtils.resume();
      }else{
        audioPlayerUtils.pause();
      }
    });
  }

  /// 获取数据 - 初始化时加载到当前位置+pageSize条
  Future<void> getSongData() async {
    if (contents == null) return ToastUtils.hideLoading();
    if (contents!.isEmpty) return ToastUtils.hideLoading();

    try {
      ToastUtils.showLoading();

      // 计算当前contentId在songParam中的位置
      int currentIndex = 0;
      if (contentId != null) {
        currentIndex = contents!.indexWhere((item) => item["contentId"] == contentId);
        if (currentIndex < 0) currentIndex = 0;
      }

      // 初始加载到当前位置 + pageSize 条数据
      int initialLoadCount = currentIndex + pageSize;
      if (initialLoadCount > contents!.length) {
        initialLoadCount = contents!.length;
      }

  
      List<Map<String, dynamic>> reqContents = [];
      for (int i = 0; i < initialLoadCount; i++) {
        var item = contents![i];
        reqContents.add({
          "uid": item["contentId"],
          "type": item["contentType"],
        });
      }

      Map<String, dynamic> reqData = {
        "contents": reqContents,
      };

      SongEntity? songEntity = await SongRequest.getPlayKnowledgeList(reqData);
      if (songEntity == null) return;
      songData.value = songEntity;
      List<SongEntityList?> list = songEntity.list ?? [];
      songList.clear();
      randomPoolIndices.clear();
      for (var item in list) {
        if (item == null) continue;
        songList.add(item);
        randomPoolIndices.add(item);
      }
      randomPoolIndices.shuffle();
      
      // 更新已加载数量和是否有更多数据
      _loadedCount = initialLoadCount;
      hasMoreData.value = _loadedCount < contents!.length;

      if(songList.isEmpty) return;
      
      getCurrentParamIndex();
      await startPlaySong();
      startMenuShowTime();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 上拉加载 - 每次加载pageSize条数据
  Future<void> loadData() async {
    if (contents == null) return;
    if (isLoadingData.value) return;
    if (!hasMoreData.value) return;

    isLoadingData.value = true;

    try {
      // 计算本次需要加载的数据范围
      int startIndex = _loadedCount;
      int endIndex = startIndex + pageSize;
      if (endIndex > contents!.length) {
        endIndex = contents!.length;
      }

      // 如果没有更多数据需要加载
      if (startIndex >= contents!.length) {
        hasMoreData.value = false;
        return;
      }

      List<Map<String, dynamic>> reqContents = [];
      for (int i = startIndex; i < endIndex; i++) {
        var item = contents![i];
        reqContents.add({
          "uid": item["contentId"],
          "type": item["contentType"],
        });
      }

      Map<String, dynamic> reqData = {
        "contents": reqContents,
      };

      SongEntity? songEntity = await SongRequest.getPlayKnowledgeList(reqData);
      if (songEntity == null) return;

      List<SongEntityList?> list = songEntity.list ?? [];
      for (var item in list) {
        if (item == null) continue;
        songList.add(item);
        randomPoolIndices.add(item);
      }
      randomPoolIndices.shuffle();

      // 更新已加载数量和是否有更多数据
      _loadedCount = endIndex;
      hasMoreData.value = _loadedCount < contents!.length;
    } finally {
      isLoadingData.value = false;
    }
  }

  /// 在列表中获取播放的下标
  void getCurrentParamIndex() {
    if (contents == null) return;
    if (contents!.isEmpty) return;
    if (contentId == null) {
      currentContentId.value = contents!.first["contentId"] ?? (-1);
      return;
    }
    currentContentId.value = contentId!;
  }

  /// 开始播放
  /// [lastPlayedSeconds] 上一首的播放时长（秒），切换歌曲时传入
  Future<void> initAudioPlayer({double? lastPlayedSeconds}) async {
    SongEntityList? song;
    if (audioControlPlayOrder.value == AudioControlPlayOrder.random) {
      song = randomPoolIndices.firstWhereOrNull((element) => element.contentId == currentContentId.value);
    } else {
      song = songList.firstWhereOrNull((element) => element.contentId == currentContentId.value);
    }
    if(song == null) return;

    PronunciationsEntity? audioInfo = song.audioInfo;

    String? audioUrl = audioInfo?.audioUrl;

    if (audioUrl == null) {
      audioPlayerUtils.prepare(url: "");
      audioPlayerUtils.stop();
      return;
    }

    await audioPlayerUtils.prepare(
      url: audioUrl,
      title: song.title ?? "",
      playSpeed: playbackRate.value,
      showSkipControls: true,
      artist: song.title ?? "",
      duration: Duration(seconds: (audioInfo?.duration ?? 0).toInt()),
    );

    audioPlayerUtils.setNavigationHandlers(
      onNext: () async => nextClick(),
      onPrevious: () async => previousClick(),
    );

    if(milliseconds != null){
      await audioPlayerUtils.seek(Duration(milliseconds: milliseconds!));
      milliseconds = null;
    }

    initFirstKnowledge();

    audioPlayerUtils.resume();
    audioControlController.reloadAudioInfo();
    playSentenceIndex.value = 0;

    // 开始追踪播放记录
    PlayRecordManager.instance.startTracking(
      audioPlaybackUtils: audioPlayerUtils,
      contentType: song.contentType ?? '',
      contentId: song.contentId ?? 0,
      duration: (audioInfo?.duration ?? 0).toDouble(),
      source: 'song_mv',
      lastPlayedSeconds: lastPlayedSeconds,
      type: type,
      typeId: typeId,
    );
  }

  /// 歌词着色 并更新后台歌词
  void playHighlightWord(int mill) {
    if (playSentenceList.isEmpty) return;
    for (int i = 0; i < playSentenceList.length; i++) {
      SongSentenceModel item = playSentenceList[i];
      
      List<AssSubtitle> sentence = item.sentence;
      if (sentence.isEmpty) continue;

      for (var sub in sentence) {
        if (sub.startTime <= mill && sub.endTime >= mill) {
          sub.isRead = true;
        } else {
          sub.isRead = false;
        }
      }

      if ((item.startTime??0) <= mill && (item.endTime??0) >= mill) {
        playSentenceIndex.value = i;
        audioPlayerUtils.updateLyric(item.sentenceText);
        break;
      }
    }
    playSentenceList.refresh();
  }

    /// 刷新制定歌曲
  Future<void> refreshSingleSong(SongEntityList? data) async{
    if(data == null) return;
    List<Map<String, dynamic>> reqDataList = [{
      "uid": data.contentId,
      "type": data.contentType,
    }];
    Map<String, dynamic> reqData = {
      "contents": reqDataList,
    };
    SongEntity? songEntity = await SongRequest.getPlayKnowledgeList(reqData);
    if (songEntity == null) return;
    List<SongEntityList?> list = songEntity.list ?? [];
    if(list.isEmpty) return;
    data = list.first;
  }


  ///获取歌曲详情
  Future<SongEntityList?> getSongDetail(SongEntityList? data) async{
    if(data == null) return data;

    if(Get.context != null && data.cardRights != null){
      if(isShowLockDialog) return null;
      isShowLockDialog = true;
      bool res = await LockUtils.checkLock(
        data.cardRights, 
        Get.context!, 
        hintStorageKey: SPECIAL_PAY_NOT_REMIND_KEY,
        onPlaySuccess: () async{
          await refreshSingleSong(data);
        },
      );
      isShowLockDialog = false;
      if(res) return null;
    }

    if(data.pronunciations != null){
      return data;
    }
    Map<String, dynamic> parameters = {
      "contentId": data.contentId,
      "contentType": data.contentType,
    };
    try {
      isSwitchLoadingUI.value = true;
      SongEntityList? songEntityList = await SongRequest.getPlayKnowledgeInfoList(parameters);
      if(songEntityList == null) return null;

      for(int i = 0; i < songList.length; i++){
        if(songEntityList.contentId == songList[i].contentId && songEntityList.contentType == songList[i].contentType){
          songList[i] = songEntityList;
        }
      }

      for(int i = 0; i < randomPoolIndices.length; i++){
        if(songEntityList.contentId == randomPoolIndices[i].contentId && songEntityList.contentType == randomPoolIndices[i].contentType){
          randomPoolIndices[i] = songEntityList;
        }
      }

      if(Get.currentRoute != Routes.SONG_MV){
        MvPlayerGlobalFloatController.to.toggleIsShowFloatButton(true);
      }
      
      return songEntityList;
    } finally{
      print("--------------- isSwitchLoadingUI.value = false");
      isSwitchLoadingUI.value = false;
    }
  }

  /// 开始播放歌曲
  /// [lastPlayedSeconds] 上一首的播放时长（秒），切换歌曲时传入
  Future<void> startPlaySong({double? lastPlayedSeconds}) async{
    SongEntityList? song;
    if (audioControlPlayOrder.value == AudioControlPlayOrder.random) {
      song = randomPoolIndices.firstWhereOrNull((element) => element.contentId == currentContentId.value);
    } else {
      song = songList.firstWhereOrNull((element) => element.contentId == currentContentId.value);
    }
    if(song == null) return;

    song = await getSongDetail(song);
    if(song == null) return;

    /// 获取当前播放歌曲的相关知识点
    List<SongEntityListSubContentList?> subContentList = song.contentList ?? [];

    PronunciationsEntity? audioInfo = song.audioInfo;

    /// 获取ass
    String? audioAss = audioInfo?.audioAss;
    String? translateAss = audioInfo?.translateAssText?.text;
    
    playSentenceList.clear();
    noAssSentenceList.clear();
    if (audioAss != null && audioAss != "") {
      List<SubtitlesSentenceModel> assSentences = KaraokeSubtitlesUtils.parseAssDialogue(audioAss);
      // 获取释义文本
      String? translateText = translateAss;
      List<AssSubtitle> translateSentences = [];
      if (translateText != null && translateText != "") {
        translateSentences = KaraokeSubtitlesUtils.parseAssTranslateDialogue(translateText);
      }

      for (int i = 0; i < assSentences.length; i++) {
        List<AssSubtitle> item = assSentences[i].words;
        if (item.isEmpty) continue;
        AssSubtitle? translate;
        if (i < translateSentences.length) {
          translate = translateSentences[i];
        }

        List<SongEntityListSubContentList> knowledgeList = [];

        String lyric = "";
        for (var sub in item) {
          lyric += sub.leftSpace;
          lyric += sub.text;
        }

        for (var knowledge in subContentList) {
          if (knowledge == null) continue;
          if (knowledge.content == null) continue;
          if (lyric.toLowerCase().contains(knowledge.content!.toLowerCase())) {
            knowledgeList.add(knowledge);
          }
        }

        playSentenceList.add(SongSentenceModel(
          sentence: item,
          sentenceText: lyric,
          translate: translate,
          knowledgeList: knowledgeList,
          startTime: assSentences[i].sentenceStartTime,
          endTime: assSentences[i].sentenceEndTime,
          key: GlobalKey(),
        ));
      }
    }else{
      noAssSentenceList.clear();
      List<String> contentList = song.content?.split("\n") ?? [];
      for (var item in contentList) {
        if (item.isEmpty) continue;
        List<AssSubtitle> sentence = [];
        List<String> itemList = item.split(" ");
        for (int i = 0; i < itemList.length; i++) {
          if (itemList[i].isEmpty) continue;
          sentence.add(AssSubtitle(
            startTime: -1,
            endTime: -1,
            text: itemList[i],
            leftSpace: i == 0 ? "" : KaraokeSubtitlesUtils.getLocalSpace(),
          ));
        }
        noAssSentenceList.add(SongSentenceModel(
          sentence: sentence,
          sentenceText: item,
          translate: null,
          startTime: -1,
          endTime: -1,
          knowledgeList: [],
          key: GlobalKey(),
        ));
      }
    }

    lyricReadyResult.value = playSentenceList.isNotEmpty ? 0 : 1;

    currentKnowledgeList.clear();
    for (var item in subContentList) {
      if (item == null) continue;
      currentKnowledgeList.add(item);
    }

    initAudioPlayer(lastPlayedSeconds: lastPlayedSeconds);
  }

  /// 播放完成的处理
  void playCompleteHandle() async {
    if (songList.isEmpty) return;
    if (audioPlayerUtils.isPlaying) return;

    // 播放完成时上报（使用歌曲总时长作为播放时长）
    final duration = currentSong?.audioInfo?.duration ?? 0;
    PlayRecordManager.instance.reportPlayComplete(duration.toDouble());

    // 检查首数倒计时
    if (_timingCloseSongCount > 0) {
      _checkSongCountTimingClose();
      if (_timingCloseSongCount <= 0 && timingCloseMenuIndex == -1) {
        // 倒计时结束，不再切换下一首
        return;
      }
    }

    if (audioControlPlayOrder.value == AudioControlPlayOrder.singleLoop) {
      restartPlayback();
      return;
    }

    currentPlayCount.value++;
    if (currentPlayCount.value < audioLoopCount.value) {
      restartPlayback();
      return;
    }

    currentPlayCount.value = 0;

    

    int currentIndex = 0;
    if (audioControlPlayOrder.value == AudioControlPlayOrder.random) {
      currentIndex = randomPoolIndices.indexWhere((e) => e.contentId == currentContentId.value);
    } else {
      currentIndex = songList.indexWhere((e) => e.contentId == currentContentId.value);
    }

    if (currentIndex < 0) currentIndex = 0;

    if (audioControlPlayOrder.value == AudioControlPlayOrder.loop) {
      int nextIndex = (currentIndex + 1) % songList.length;
      // 接近末尾时预加载更多数据
      if (nextIndex >= songList.length - 3) {
        loadData();
      }
      switchSong(songList[nextIndex]);
    } else if (audioControlPlayOrder.value == AudioControlPlayOrder.random) {
      int nextIndex = (currentIndex + 1) % randomPoolIndices.length;
      switchSong(randomPoolIndices[nextIndex]);
      if (nextIndex >= randomPoolIndices.length - 3) {
        loadData();
      }
    } else if (audioControlPlayOrder.value == AudioControlPlayOrder.sequential) {
      int nextIndex = currentIndex + 1;
      // 接近末尾时预加载更多数据
      if (nextIndex >= songList.length - 3) {
        loadData();
      }
      if (nextIndex >= songList.length) {
        return;
      }
      switchSong(songList[nextIndex]);
    } else if (audioControlPlayOrder.value == AudioControlPlayOrder.single) {
      return;
    }
  }

  /// 暂停恢复播放
  Future<void> pausePlayback() async {
    if (audioPlayerUtils.isPlaying) {
      await audioPlayerUtils.pause();
      audioControlController.hideAllMenus();
    }else{
      playSentenceIndex.value = 0;
    
      Duration position = await audioPlayerUtils.getCurrentPosition();
      Duration duration = await audioPlayerUtils.getDuration();

      if(duration.inMilliseconds - 100 <= position.inMilliseconds){
        switchSong(currentSong);
        return;
        
      }

      audioPlayerUtils.resume();
    }

    startMenuShowTime();
  }

  /// 下一曲
  Future<void> nextClick() async {
    startMenuShowTime();
    if (songList.isEmpty) return;
    if (audioControlPlayOrder.value == AudioControlPlayOrder.random) {
      int currentIndex = randomPoolIndices.indexWhere((e) => e.contentId == currentContentId.value);
      if (currentIndex < 0) currentIndex = 0;

      int nextIndex = (currentIndex + 1) % randomPoolIndices.length;
      switchSong(randomPoolIndices[nextIndex]);
    } else {
      int currentIndex = songList.indexWhere((e) => e.contentId == currentContentId.value);
      if (currentIndex < 0) currentIndex = 0;

      int nextIndex = (currentIndex + 1) % songList.length;
      // 接近末尾时预加载更多数据
      if (nextIndex >= songList.length - 3) {
        loadData();
      }
      switchSong(songList[nextIndex]);
    }
  }

  /// 上一曲
  Future<void> previousClick() async {
    startMenuShowTime();
    if (songList.isEmpty) return;

    if (audioControlPlayOrder.value == AudioControlPlayOrder.random) {
      int currentIndex = randomPoolIndices.indexWhere((e) => e.contentId == currentContentId.value);
      if (currentIndex < 0) currentIndex = 0;

      int previousIndex = (currentIndex - 1 + randomPoolIndices.length) % randomPoolIndices.length;
      switchSong(randomPoolIndices[previousIndex]);
    } else {
      int currentIndex = songList.indexWhere((e) => e.contentId == currentContentId.value);
      if (currentIndex < 0) currentIndex = 0;

      int previousIndex = (currentIndex - 1 + songList.length) % songList.length;

      switchSong(songList[previousIndex]);
    }
  }

  /// 上一句
  Future<void> previousSentenceClick() async {
    startMenuShowTime();
    if (playSentenceList.isEmpty) return;
    if (playSentenceIndex.value <= 0) return;
    playSentenceIndex.value--;
    for (var element in playSentenceList[playSentenceIndex.value].sentence) {
      element.isRead = false;
    }
    Duration duration = Duration(milliseconds: playSentenceList[playSentenceIndex.value].startTime??0);
    await audioPlayerUtils.pause();
    await audioPlayerUtils.seek(duration);
    clearAssHighlight();
    await Future.delayed(const Duration(milliseconds: 500));
    await audioPlayerUtils.resume();
    audioControlController.reloadAudioInfo();
  }

  /// 下一句
  Future<void> nextSentenceClick() async {
    startMenuShowTime();
    if (playSentenceList.isEmpty) return;
    if (playSentenceIndex.value >= playSentenceList.length - 1) return;
    playSentenceIndex.value++;
    for (var element in playSentenceList[playSentenceIndex.value].sentence) {
      element.isRead = false;
    }
    Duration duration = Duration(milliseconds: playSentenceList[playSentenceIndex.value].startTime??0);
    await audioPlayerUtils.pause();
    await audioPlayerUtils.seek(duration);
    clearAssHighlight();
    await Future.delayed(const Duration(milliseconds: 500));
    await audioPlayerUtils.resume();
    audioControlController.reloadAudioInfo();
  }

  /// 根据句子数据播放这一句
  Future<void> playForSentence(SongSentenceModel sentence, int sentenceIndex) async {
    startMenuShowTime();
    playSentenceIndex.value = sentenceIndex;
    Duration duration = Duration(milliseconds: sentence.startTime??0);
    await audioPlayerUtils.pause();
    await audioPlayerUtils.seek(duration);
    clearAssHighlight();
    await Future.delayed(const Duration(milliseconds: 500));
    await audioPlayerUtils.resume();
    audioControlController.reloadAudioInfo();
  }

  /// 重新播放
  Future<void> restartPlayback() async {
    playSentenceIndex.value = 0;
    for (var item in playSentenceList) {
      for (var element in item.sentence) {
        element.isRead = false;
      }
    }

    await audioPlayerUtils.seek(Duration.zero);
    await audioPlayerUtils.resume();
    audioControlController.reloadAudioInfo();
  }

  /// 初始化的时候获取第一张知识点
  void initFirstKnowledge() {
    if(currentKnowledgeList.isEmpty){
      // 没有知识点使用默认图片
      
      SongEntityList? song = songList.firstWhereOrNull((element) => element.contentId == currentContentId.value);
      if(song == null) return;
      String? defaultImageUrl = song.imageUrl;
      if(defaultImageUrl == null) return;

      MvPlayerGlobalFloatController.to.setMvImageUrl(defaultImageUrl);
      return;
    }
    if (playSentenceList.isEmpty) {
      // 没有字幕歌词，默认显示第一个知识点
      currentKnowledgeIndex.value = 0;
      updateBackgroundImage(currentKnowledgeIndex.value);
      return;
    }
    // 寻找匹配最近歌词的知识点
    for (int i = 0; i < playSentenceList.length; i++) {
      SongSentenceModel item = playSentenceList[i];
      if (item.knowledgeList.isEmpty) continue;
      // 找出这个知识点在当前歌曲的所有知识点的下标

      SongEntityListSubContentList? initKnowledge;
      for (int j = 0; j < item.knowledgeList.length; j++) {
        String? knowledge = item.knowledgeList[j].content;
        if (knowledge == null) continue;
        if (item.sentenceText.toLowerCase().contains(knowledge.toLowerCase())) {
          initKnowledge = item.knowledgeList[j];
        }
      }
      if (initKnowledge == null) {
        currentKnowledgeIndex.value = 0;
        continue;
      }

      int knowledgeIndex = currentKnowledgeList.indexWhere((k) => (k.contentId == initKnowledge?.contentId));
      if (knowledgeIndex == -1) continue;
      currentKnowledgeIndex.value = knowledgeIndex;
      updateBackgroundImage(currentKnowledgeIndex.value);
      break;
    }
  }

  /// 切换句子获取当前句子下的知识点信息并返回下标
  Future<int?>? switchSentenceAndGetKnowledgeIndex(Duration? currentSwitchInterval, int currentIndex) async {
    if (currentKnowledgeList.isEmpty) return null;
    if (playSentenceList.isEmpty) {
      // 没有歌词字幕 顺序播放知识点
      int nextKnowledgeIndex = (currentIndex + 1) % currentKnowledgeList.length;
      return nextKnowledgeIndex;
    }

    if (playSentenceList.length <= playSentenceIndex.value) return null;
    if (currentKnowledgeList.isEmpty) return null;

    Duration pos = await audioPlayerUtils.getCurrentPosition();
    int targetMs = pos.inMilliseconds + 1900;

    int targetSentenceIndex = -1;
    for (int i = 0; i < playSentenceList.length; i++) {
      List<AssSubtitle> s = playSentenceList[i].sentence;
      if (s.isEmpty) continue;
      if (s.first.startTime <= targetMs && s.last.endTime >= targetMs) {
        targetSentenceIndex = i;
        break;
      }
    }
    if (targetSentenceIndex == -1) {
      for (int i = 0; i < playSentenceList.length; i++) {
        List<AssSubtitle> s = playSentenceList[i].sentence;
        if (s.isEmpty) continue;
        if (s.first.startTime > targetMs) {
          targetSentenceIndex = i;
          break;
        }
      }
    }
    if (targetSentenceIndex == -1) return null;

    List<SongEntityListSubContentList> knowledgeList = playSentenceList[targetSentenceIndex].knowledgeList;
    if (knowledgeList.isEmpty) return null;

    List<int> candidates = [];
    for (int i = 0; i < currentKnowledgeList.length; i++) {
      SongEntityListSubContentList item = currentKnowledgeList[i];
      if (knowledgeList.any((k) => (k.contentId == item.contentId))) {
        candidates.add(i);
      }
    }
    candidates.removeWhere((element) => element == currentIndex);
    if (candidates.isEmpty) return null;

    /// 随机一个知识点下标
    int knowledgeIndex = candidates[Random().nextInt(candidates.length)];
    return knowledgeIndex;
  }

  /// 更新后台歌词或者图片
  void updateBackgroundLyricOrImage() {
    if (playSentenceList.isEmpty) return;
    SongSentenceModel item = playSentenceList[playSentenceIndex.value];
    if (item.translate == null) return;
    String translate = item.translate!.text;
    audioPlayerUtils.updateLyric(translate);
  }

  /// 图片轮播组件返回的下标更新后台图片
  void updateBackgroundImage(int index) {
    if (index >= currentKnowledgeList.length) return;
    currentKnowledgeIndex.value = index;
    SongEntityListSubContentList item = currentKnowledgeList[index];
    if (item.imageUrl == null) return;
    audioPlayerUtils.updateImage(item.imageUrl!);

    MvPlayerGlobalFloatController.to.setMvImageUrl(item.imageUrl);
  }

  /// 音频控制组件的菜单是否显示
  void onMenuShow(bool showSpeedList, bool showTranslateList, bool showFontSizeList, bool showPlayOrderList) {
    if (showSpeedList || showTranslateList || showFontSizeList || showPlayOrderList) {
      menuShowTimer?.cancel();
      menuShowTimer = null;
      isShowMenu.value = true;
    } else {
      startMenuShowTime();
    }
  }

  /// 菜单栏的显示与隐藏
  void toggleMenuShow() {
    isShowMenu.value = !isShowMenu.value;
    audioControlController.hideAllMenus();
    if (isShowMenu.value) {
      startMenuShowTime();
    }
  }


  /// 计时菜单栏显示的时间
  void startMenuShowTime() {
    isShowMenu.value = true;
    menuShowTimer?.cancel();
    menuShowTimer = null;
    menuShowTimer = Timer(const Duration(seconds: 5), () {
      audioControlController.hideAllMenus();
      isShowMenu.value = false;
    });
  }

  /// 歌曲列表的打开与关闭
  void toggleDrawer() {
    if (scaffoldKey.currentState == null) return;
    scaffoldKey.currentState!.openEndDrawer();
  }

  /// 切换歌曲
  Future<void> switchSong(SongEntityList? song) async {
    if (song == null || song.contentId == null) return;

    // 在切换前获取当前播放位置，用于上报上一首的播放时长
    final lastPosition = await audioPlayerUtils.getCurrentPosition();
    final lastPlayedSeconds = lastPosition.inMilliseconds / 1000.0;

    song = await getSongDetail(song);
    if(song == null) return;

    lyricReadyResult.value = (-1);
    
    currentContentId.value = song.contentId!;
    isShowKnowledgeList.value = false;
    
    currentPlayCount.value = 0;
    currentKnowledgeIndex.value = (-1);

    await startPlaySong(lastPlayedSeconds: lastPlayedSeconds);

    audioControlController.reloadAudioInfo();
  }

  /// 点击歌词打开小词典
  Future<void> openSmallDictionary(
    BuildContext context, 
    SongSentenceModel sentence, 
    int wordIndex, 
    {void Function()? onLongPressEnd}
  ) async {
    bool isPlaying = audioPlayerUtils.isPlaying;
    await audioPlayerUtils.pause();
    clearAssHighlight();

    await getSentenceWordAss(sentence);

    SentenceParsingWordsEntityList? wordInfo;

    if ((sentence.wordInfos?.length??0) > wordIndex) {
      wordInfo = sentence.wordInfos?[wordIndex];
    }

    bool wordContentisNull = wordInfo?.imageUrl == null && wordInfo?.contentPosList == null && wordInfo?.pronunciations == null;

    if (wordInfo == null || wordContentisNull) {
      onLongPressEnd?.call();
      if(isPlaying){
        audioPlayerUtils.resume();
      }
      ToastUtils.showToast(text: "词库正在努力扩充中~", type: ToastType.warning);
      return;
    }

    sentence.selectedWordIndex = wordIndex;
    playSentenceList.refresh();

    bool isToDetail = await SimpleDictionaryDialog.show(
      context: context,
      wordInfo: wordInfo,
    );

    sentence.selectedWordIndex = (-1);
    playSentenceList.refresh();
    onLongPressEnd?.call();

    if(isToDetail) return;

    if(isPlaying){
      audioPlayerUtils.resume();
    }

  }

  /// 获取句子中单词的解析
  Future<void> getSentenceWordAss(SongSentenceModel sentence) async {
    if (sentence.wordInfos != null) return;
    String sentenceText = "";

    for (int i = 0; i < sentence.sentence.length; i++) {
      sentenceText += sentence.sentence[i].leftSpace;
      sentenceText += sentence.sentence[i].text;
    }

    if (sentenceText.isEmpty) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "sentence": sentenceText,
      };
      SentenceParsingWordsEntity? model = await ListenAndReadRequest.getSentenceWordAss(reqData);
      if (model == null) return;
      List<SentenceParsingWordsEntityList?> list = model.list ?? [];
      if (list.isEmpty) return;

      List<SentenceParsingWordsEntityList> wordInfoList = [];

      for (int i = 0; i < sentence.sentence.length; i++) {
        if (i >= list.length) break;
        wordInfoList.add(list[i]!);
      }
      sentence.wordInfos = wordInfoList;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 清除ass着色
  void clearAssHighlight() {
    for (int i = 0; i < playSentenceList.length; i++) {
      SongSentenceModel item = playSentenceList[i];
      item.selectedWordIndex = (-1);
      List<AssSubtitle> sentence = item.sentence;
      if (sentence.isEmpty) continue;
      for (var sub in sentence) {
        sub.isRead = false;
      }
    }
    playSentenceList.refresh();
  }


  /// 弹出错误反馈弹窗
  Future<void> showFeedbackErrorContentDialog(BuildContext context) async {

    menuShowTimer?.cancel();
    menuShowTimer = null;
    isShowMenu.value = true;

    await audioPlayerUtils.pause();

    SongEntityList song = songList.firstWhere((element) => element.contentId == currentContentId.value);
    Duration position = await audioPlayerUtils.getCurrentPosition();
    await FeedbackErrorContentDialog.show(
      context: context, 
      position: position,
      name: song.title, 
      content: song.content, 
      contentType: song.contentType, 
      contentId: song.contentId,
    );

    startMenuShowTime();
  }

  Future<void> toggleFavourite() async {
    startMenuShowTime();
    SongEntityList? song = songList.firstWhereOrNull((element) => element.contentId == currentContentId.value);
    if(song == null) return;
    if(song.contentId == null || song.contentType == null) return;
    
    if (song.isFavorite) {
      //todo:取消收藏
      song.favorited = false;
      var res = await FavouriteRequest.removeContent(playListId: 0, uid: song.contentId!, type: song.contentType!);
      if (!res) {
        song.favorited = true;
      }
    } else {
      song.favorited = true;
      var res = await FavouriteRequest.addContent(playListId: 0, uid: song.contentId!, type: song.contentType!);
      if (res) {
        AddFavouriteDialog.show(Get.context!, song.contentId!, song.contentType!);
      } else {
        song.favorited = false;
        ToastUtils.showToast(text: '收藏失败', type: ToastType.error);
      }
    }
    songList.refresh();
  }

  /// 跳转至读页面
  Future<void> jumpToReadPage() async {
    try {
      ToastUtils.showLoading();

      int contentId = currentContentId.value;
      if(contentId == -1) return;
      String? contentType = songList.firstWhere((element) => element.contentId == contentId).contentType;
      if (contentType == null) return;

      _executeTimingClose();

      List<Map<String, dynamic>> contents = songList.map((song) => {
        'contentId': song.contentId,
        'contentType': song.contentType,
        'title': song.title,
        'content': song.content,
      }).toList();

      int milliseconds = (await audioPlayerUtils.getCurrentPosition()).inMilliseconds;

      await stop();

      await Get.offAndToNamed(
      Routes.LISTEN_AND_READ,
      arguments: {
        'contentId': contentId,
        'contentType': contentType,
        "contents": contents,
        "milliseconds": milliseconds,
        "type": type,
        "typeId": typeId,
      },
    );

    } finally{
      ToastUtils.hideLoading();
    }
    
  }


  /// 弹出定时关闭选择菜单弹窗
  Future<void> showTimingCloseMenuDialog(BuildContext context) async {

    isShowMenu.value = true;
    menuShowTimer?.cancel();
    menuShowTimer = null;
    
    List<TimingCloseMenuModel> list = [
      TimingCloseMenuModel(value: 15, name: "15分钟后"),
      TimingCloseMenuModel(value: 30, name: "30分钟后"),
      TimingCloseMenuModel(value: 60, name: "60分钟后"),
      TimingCloseMenuModel(type: 1, value: 1, name: "播完当前"),
      TimingCloseMenuModel(type: 1, value: 2, name: "播完2首"),
      TimingCloseMenuModel(type: 1, value: 3, name: "播完3首"),
      TimingCloseMenuModel(value: -1, name: "关闭倒计时"),
    ];

    int? index = await TimingCloseMenuDialog.show(
      context: context, 
      list: list,
      selectedIndex: timingCloseMenuIndex,
    );
    startMenuShowTime();

    if(index == null) return;

    timingCloseMenuIndex = index;

    // 执行倒计时任务
    _startTimingCloseTask(list[index]);
  }

  /// 开始定时关闭任务
  void _startTimingCloseTask(TimingCloseMenuModel model) {
    // 先取消之前的定时任务
    _cancelTimingCloseTask();

    // 关闭倒计时
    if (model.value == -1) {
      timingCloseMenuIndex = -1;
      return;
    }

    if (model.type == 0) {
      // 按分钟倒计时
      _timingCloseRemainingSeconds = model.value * 60;
      _updateTimingCloseDisplay();
      _timingCloseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _timingCloseRemainingSeconds--;
        if (_timingCloseRemainingSeconds <= 0) {
          _executeTimingClose();
        } else {
          _updateTimingCloseDisplay();
        }
      });
    } else if (model.type == 1) {
      // 按首数倒计时
      _timingCloseSongCount = model.value;
      timingCloseDisplayStr.value = "剩余$_timingCloseSongCount首";
    }
  }

  /// 更新定时关闭显示字符串
  void _updateTimingCloseDisplay() {
    int minutes = _timingCloseRemainingSeconds ~/ 60;
    int seconds = _timingCloseRemainingSeconds % 60;
    timingCloseDisplayStr.value = "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  /// 取消定时关闭任务
  void _cancelTimingCloseTask() {
    _timingCloseTimer?.cancel();
    _timingCloseTimer = null;
    _timingCloseRemainingSeconds = 0;
    _timingCloseSongCount = 0;
    timingCloseDisplayStr.value = "";
  }

  /// 执行定时关闭
  void _executeTimingClose() {
    _cancelTimingCloseTask();
    timingCloseMenuIndex = -1;
    audioPlayerUtils.pause();
    isPlaying.value = false;
  }

  /// 检查首数倒计时（在播放完成时调用）
  void _checkSongCountTimingClose() {
    if (_timingCloseSongCount <= 0) return;
    _timingCloseSongCount--;
    if (_timingCloseSongCount <= 0) {
      _executeTimingClose();
    } else {
      timingCloseDisplayStr.value = "剩余$_timingCloseSongCount首";
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    PlayRecordManager.instance.stopTracking(source: 'song_mv');
    _cancelTimingCloseTask();
    super.onClose();
  }

  /// 后台时只更新锁屏歌词显示，不更新UI
  void _updateLockScreenLyricOnly(int mill) {
    if (playSentenceList.isEmpty) return;
    for (int i = 0; i < playSentenceList.length; i++) {
      SongSentenceModel item = playSentenceList[i];
      if ((item.startTime ?? 0) <= mill && (item.endTime ?? 0) >= mill) {
        if (playSentenceIndex.value != i) {
          playSentenceIndex.value = i;
          audioPlayerUtils.updateLyric(item.sentenceText);
        }
        break;
      }
    }
  }
}
