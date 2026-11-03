import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/favourite.dart';
import '../../../../common/https/https.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/public_controller/model/user_setting_model.dart';
import '../../../../common/values/values.dart';
import '../../../../common/widgets/add_favourite_dialog.dart';
import '../../../../common/widgets/audio_control_widget.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/karaoke_subtitles_utils.dart';
import '../../../../utils/play_record_utils/play_record_utils.dart';
import '../models/reading_ass_model.dart';
import 'listen_and_read_shadowing_controller.dart';

class ListenAndReadController extends GetxController {
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


  /// 页面脚手架key 用作打开抽屉(播放列表)
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();


  final RxList<String> titleNavList = ["阅读", "跟读"].obs;
  // final List<String> titleNavList = ["阅读", "跟读", "练习", "写作"];

  final RxInt titleNavIndex = 0.obs;
  
  AudioPlaybackUtils audioPlayerUtils = AudioPlaybackUtils();

  final AudioControlController audioControlController = AudioControlController();

  /// 当前进度
  final Rx<Duration> position = Duration.zero.obs;

  /// 播放速率
  final RxDouble playbackRate = 1.0.obs;

  /// 翻译状态
  final Rx<LangPreference> translateStatus = LangPreference.bilingual.obs;

  /// 文字大小倍数
  final RxDouble contentFontSizeMultiple = 1.0.obs;

  /// 播放顺序
  final Rx<AudioControlPlayOrder> playOrderStatus = AudioControlPlayOrder.single.obs;

  /// 每一曲播放次数
  final RxInt playOrderLoopCount = 1.obs;

  /// 当前播放的次数
  final RxInt currentPlayCount = 0.obs;

  /// 是否播放中
  final RxBool isPlaying = false.obs;

  /// 是否显示播放控制器
  final RxBool isShowAudioController = true.obs;
  Timer? isShowAudioControllerTimer;

  /// 是否有练习题
  final RxBool hasPractice = false.obs;

  /// 获取当前播放的歌曲
  SongEntityList? get currentSong => songList.firstWhereOrNull((e) => e.contentId == currentContentId.value);

  /// 解析出来的ass 以text换行符拆分
  final RxList<ReadingAssParagraphModel> readingAssTextList = <ReadingAssParagraphModel>[].obs;

  /// 播放一句话的时间Timer
  Timer? playSentenceTimer;

  StreamSubscription<bool>? _pauseResumeSub;

  StreamSubscription<Duration>? _positionSub;

  StreamSubscription<bool>? _isPlayingSub;

  /// 最近一次滚动的段落下标（节流）
  int? _lastScrollParIndex;

  /// 是否弹出了权限弹窗
  bool isShowLockDialog = false;


  final RxList<SongEntityList> songList = <SongEntityList>[].obs;

  /// 伪随机数池 用于随机播放
  final RxList<SongEntityList> randomPoolIndices = <SongEntityList>[].obs;

  /// 是否正在加载中
  final RxBool isLoadingData = false.obs;

  /// 一次加载10条
  final int pageSize = 50;

  /// 当前已加载的数据数量
  int _loadedCount = 0;

  /// 是否还有更多数据
  final RxBool hasMoreData = true.obs;

  final RxInt currentContentId = (-1).obs;

  /// 当前句子的id
  int currentSentenceId = (-1);

  @override
  void onInit() {
    super.onInit();
    WakelockPlus.enable();
    if (Get.arguments != null) {
      type = Get.arguments["type"];
      typeId = Get.arguments["typeId"];
      contentId = Get.arguments["contentId"];
      contentType = Get.arguments["contentType"];
      milliseconds = Get.arguments["milliseconds"];
      String? playbackMode = Get.arguments["playbackMode"];

      try {
        List? argList = Get.arguments["contents"];
        if(argList != null){
          List<Map<String, dynamic>> argContents = [];
          for (var item in argList) {
            argContents.add(item as Map<String, dynamic>);
          }
          contents = argContents;
        }
      } catch (_) {
        
      }
      initUserSetting(playbackMode);
      getCurrentParamIndex();
      getSongData();
    }
  }


  Future<void> initUserSetting(String? playbackMode) async{
    if(Get.isRegistered<ConfigController>()){
      UserSettingModel userSetting = Get.find<ConfigController>().userSetting.value;
      playbackRate.value = userSetting.expandAudioSpeed;
      translateStatus.value = userSetting.expandLang;
    }

    AudioControlSettingModel? setting = AudioControlUtils.getSetting();
    playOrderStatus.value = setting?.playOrder ?? AudioControlPlayOrder.loop;
    playOrderLoopCount.value = setting?.playOrderLoopCount ?? 1;
    contentFontSizeMultiple.value = setting?.fontSizeMultiple ?? 1.0;

    if(playbackMode != null){
      playOrderStatus.value = AudioControlPlayOrder.fromRawValue(playbackMode);
    }
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
      if(isClosed) return;
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
      
      
      parseAssText();
      switchSong(currentSong ?? songList.first);
      prepareAudioControllerTimer();
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

      List<Map<String, dynamic>> reqDataList = [];
      for (int i = startIndex; i < endIndex; i++) {
        var item = contents![i];
        reqDataList.add({
          "uid": item["contentId"],
          "type": item["contentType"],
        });
      }

      Map<String, dynamic> reqData = {
        "contents": reqDataList,
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
      ToastUtils.showLoading();
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
      
      return songEntityList;
    } finally{
      ToastUtils.hideLoading();
    }
  }



  /// 初始化播放器
  /// [lastPlayedSeconds] 上一首的播放时长（秒），切换歌曲时传入
  Future<void> initAudioPlayer({double? lastPlayedSeconds}) async {
    SongEntityList? song = currentSong;
    if (song == null) return;
    PronunciationsEntity? audioInfo = song.audioInfo;
    if (audioInfo?.audioUrl == null) return;

    

    _isPlayingSub?.cancel();
    _pauseResumeSub?.cancel();
    _positionSub?.cancel();

    await audioPlayerUtils.prepare(
      url: audioInfo!.audioUrl!,
      title: song.title ?? "听读一体",
      artist: song.title ?? "",
      playSpeed: playbackRate.value,
      showSkipControls: true,
      androidCompactActionIndices: const [0],
      duration: Duration(seconds: (audioInfo.duration ?? 0).toInt()),
    );
    if(isClosed) return;

    audioControlController.reloadAudioInfo();

    audioPlayerUtils.setNavigationHandlers(
      onNext: () async => nextClick(),
      onPrevious: () async => previousClick(),
    );

    _isPlayingSub = audioPlayerUtils.pauseResumeStream.listen((event) {
      isPlaying.value = event;
      if(!isPlaying.value){
        cancelAssHighlight();
        cancelSentenceHighlight();
      }
    });

    _pauseResumeSub = audioPlayerUtils.playCompleteStream.listen((event) async{
      onPlayComplete();
    });

    _positionSub = audioPlayerUtils.positionStream.listen((event) {
      position.value = event;
      if(!audioPlayerUtils.isPlaying) return;
      int mill = event.inMilliseconds;
      
      playHighlightWord(mill);
    });

    
    if(isClosed) return;

    if(milliseconds != null){
      await Future.delayed(const Duration(milliseconds: 50));
      await audioPlayerUtils.seek(Duration(milliseconds: milliseconds!));
      audioPlayerUtils.resume();
      milliseconds = null;
    }else{
      audioPlayerUtils.resume();
    }
    audioControlController.reloadAudioInfo();

    if(isClosed) return;

    // 开始追踪播放记录
    PlayRecordManager.instance.startTracking(
      audioPlaybackUtils: audioPlayerUtils,
      contentType: song.contentType ?? '',
      contentId: song.contentId ?? 0,
      duration: (audioInfo.duration ?? 0).toDouble(),
      source: 'listen_and_read',
      lastPlayedSeconds: lastPlayedSeconds,
      type: type,
      typeId: typeId,
    );
  }

  /// 播放完成事件
  void onPlayComplete(){
    
    cancelSentenceHighlight();
    cancelAssHighlight();
    if(audioPlayerUtils.isPlaying) return;
    
    /// 只有阅读才会处理下面的逻辑
    if (titleNavIndex.value != 0) return;

    if (songList.isEmpty) return;

    // 播放完成时上报（使用歌曲总时长作为播放时长）
    final duration = currentSong?.audioInfo?.duration ?? 0;
    PlayRecordManager.instance.reportPlayComplete(duration.toDouble());

    // 单曲循环：无限次重播
    if (playOrderStatus.value == AudioControlPlayOrder.singleLoop) {
      _restartPlayback();
      return;
    }

    // 其他模式：按循环次数重播
    currentPlayCount.value++;
    if (currentPlayCount.value < playOrderLoopCount.value) {
      _restartPlayback();
      return;
    }

    currentPlayCount.value = 0;

    int currentIndex = 0;
    if (playOrderStatus.value == AudioControlPlayOrder.random) {
      currentIndex = randomPoolIndices.indexWhere((e) => e.contentId == currentContentId.value);
    } else {
      currentIndex = songList.indexWhere((e) => e.contentId == currentContentId.value);
    }

    if (currentIndex < 0) currentIndex = 0;

    if (playOrderStatus.value == AudioControlPlayOrder.loop) {
      int nextIndex = (currentIndex + 1) % songList.length;
      // 接近末尾时预加载更多数据
      if (nextIndex >= songList.length - 3) {
        loadData();
      }
      switchSong(songList[nextIndex]);
    } else if (playOrderStatus.value == AudioControlPlayOrder.random) {
      int nextIndex = (currentIndex + 1) % randomPoolIndices.length;
      switchSong(randomPoolIndices[nextIndex]);
      if (nextIndex >= randomPoolIndices.length - 3) {
        loadData();
      }
    } else if (playOrderStatus.value == AudioControlPlayOrder.sequential) {
      int nextIndex = currentIndex + 1;
      // 接近末尾时预加载更多数据
      if (nextIndex >= songList.length - 3) {
        loadData();
      }
      if (nextIndex >= songList.length) {
        return;
      }
      switchSong(songList[nextIndex]);
    } else if (playOrderStatus.value == AudioControlPlayOrder.single) {
      return;
    }
  }

  // 重头开始播放并复位状态
  Future<void> _restartPlayback() async {
    cancelSentenceHighlight();
    cancelAssHighlight();
    await audioPlayerUtils.seek(Duration.zero);
    await audioPlayerUtils.resume();
  }

  /// 下一曲
  Future<void> nextClick() async {
    if(titleNavIndex.value != 0) return; // 不是阅读页面 不允许切换到下一曲
    prepareAudioControllerTimer();
    if (songList.isEmpty) return;
    if (playOrderStatus.value == AudioControlPlayOrder.random) {
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
    if(titleNavIndex.value != 0) return; // 不是阅读页面 不允许切换到下一曲
    prepareAudioControllerTimer();
    if (songList.isEmpty) return;

    if (playOrderStatus.value == AudioControlPlayOrder.random) {
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

  /// 切换歌曲
  Future<void> switchSong(SongEntityList song) async {
    if(titleNavIndex.value != 0) return; // 不是阅读页面 不允许切换到下一曲
    
    // 在切换前获取当前播放位置，用于上报上一首的播放时长
    final lastPosition = await audioPlayerUtils.getCurrentPosition();
    final lastPlayedSeconds = lastPosition.inMilliseconds / 1000.0;
    
    SongEntityList? detailSong = await getSongDetail(song);
    if(detailSong == null) return;
    if(isClosed) return;
    // 更新 songList 中的数据
    int index = songList.indexWhere((e) => e.contentId == detailSong.contentId);
    if (index >= 0) {
      songList[index] = detailSong;
    }

    if (detailSong.contentId == null) return;
    currentContentId.value = detailSong.contentId!;
    currentPlayCount.value = 0;
    readingAssTextList.clear();
    _lastScrollParIndex = null;
    currentSentenceId = -1;

    hasPractice.value = detailSong.exerciseIds != null && (detailSong.exerciseIds?.isNotEmpty??false);
    if(hasPractice.value){
      titleNavList.value = ["阅读", "跟读", "练习"];
    }else{
      titleNavList.value = ["阅读", "跟读"];
    }

    await parseAssText();
    if(isClosed) return;
    await initAudioPlayer(lastPlayedSeconds: lastPlayedSeconds);
    audioControlController.reloadAudioInfo();
  }
  


  /// 设置播放模式
  void setPlayOrderStatus(AudioControlPlayOrder type) {
    if(playOrderStatus.value == type) return;
    playOrderStatus.value = type;
    currentPlayCount.value = 0;
  }

  /// 设置播放循环次数
  void setPlayOrderLoopCount(int loopCount) {
    if(playOrderLoopCount.value == loopCount) return;
    playOrderLoopCount.value = loopCount;
    currentPlayCount.value = 0;
    // 
  }

  /// 播放高亮单词
  void playHighlightWord(int mill) {
    if (mill == 0) return;
    

    int currentParagraphIndex = -1;
    int currentSentenceIndex = -1;
    for (int i = 0; i < readingAssTextList.length; i++) {
      List<ReadingAssSentenceModel> sentences = readingAssTextList[i].sentences;

      for (int j = 0; j < sentences.length; j++) {
        List<ReadingAssWordModel> words = sentences[j].words;

        for (int k = 0; k < words.length; k++) {
          ReadingAssWordModel word = words[k];
          if (word.ass.startTime <= mill && mill <= word.ass.endTime) {
            word.ass.isRead = true;
            currentSentenceIndex = j;
            currentParagraphIndex = i;
          } else {
            word.ass.isRead = false;
          }
        }
      }

      if (currentSentenceIndex != -1 && currentParagraphIndex != -1) {
        // 如果读到这一句 句子高亮
        ReadingAssSentenceModel sentence = readingAssTextList[currentParagraphIndex].sentences[currentSentenceIndex];
        cancelSentenceHighlight();
        sentence.isSentenceHighlight = true;
        currentSentenceId = sentence.id;
        if(titleNavIndex.value == 0){
          String lyric = sentence.words.map((e) => e.ass.text).join(" ");
          audioPlayerUtils.updateLyric(lyric);
        }
        
      } else {
        cancelSentenceHighlight();
      }

      readingAssTextList.refresh();

      // 定位到这个段落
      if(sentences.isNotEmpty && sentences.first.words.isNotEmpty && sentences.last.words.isNotEmpty){
        if((sentences.first.startTime??0) <= mill && mill <= (sentences.last.endTime??0)){
          // 进入新句子时滚动到该句子（节流）
          scrollToSentence(i);
        }
      }

    }
  }

  /// 滚动到指定句子
  Future<void> scrollToSentence(int prIndex) async{
    if(_lastScrollParIndex == prIndex) return;
    if(prIndex < 0 || prIndex >= readingAssTextList.length) return;

    final BuildContext? ctx = readingAssTextList[prIndex].paragrapKey.currentContext;
    if (ctx != null) {
      try {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          alignment: 0.5,
        );
      } catch (_) {}
    }
    _lastScrollParIndex = prIndex;
  }

  /// 解析ass文本
  Future<void> parseAssText() async {
    SongEntityList? song = currentSong;
    if (song == null) return;
    String? assTextData = song.audioInfo?.audioAss;
    String? content = song.content;
    if (assTextData == null || content == null) return;

    // 获取释义文本
    LanguageText? translateAss = song.audioInfo?.translateAssText;
    String? translateText = translateAss?.text;
    List<AssSubtitle> translateSentences = [];
    if(translateText != null && translateText != ""){
      translateSentences = KaraokeSubtitlesUtils.parseAssTranslateDialogue(translateText);
    }

    List<SubtitlesSentenceModel> paragraphs = KaraokeSubtitlesUtils.parseAssDialogue(assTextData);

    // 以text换行符拆分assText
    List<String> textList = content.split("\n");
    textList.removeWhere((element) => element.isEmpty);
    int countIndex = 0;
    int sentenceId = 0;
    for (int i = 0; i < textList.length; i++) {
      List<SubtitlesSentenceModel> textAss = KaraokeSubtitlesUtils.parseAssLineBreakByText(textList[i], paragraphs);
      paragraphs = paragraphs.sublist(textAss.length);
      textAss.removeWhere((element) => element.words.isEmpty);

      List<ReadingAssSentenceModel> sentences = [];

      for (int j = 0; j < textAss.length; j++) {
        List<AssSubtitle> dialogue = textAss[j].words;

        ReadingAssWordModel? translateWordModel;
        if(translateSentences.isNotEmpty && countIndex < translateSentences.length){
          translateWordModel = ReadingAssWordModel(ass: translateSentences[countIndex]);
          countIndex++;
        }

        sentences.add(ReadingAssSentenceModel(
          id: sentenceId++,
          words: dialogue.map((e) => ReadingAssWordModel(ass: e)).toList(),
          sentenceTranslate: translateWordModel,
          startTime: textAss[j].sentenceStartTime,
          endTime: textAss[j].sentenceEndTime,
        ));
      }

      readingAssTextList.add(ReadingAssParagraphModel(
        paragrapKey: GlobalKey(),
        text: textList[i],
        sentences: sentences,
      ));
    }
  }

  /// 取消ass高亮
  void cancelAssHighlight() {
    for (int i = 0; i < readingAssTextList.length; i++) {
      for (int j = 0; j < readingAssTextList[i].sentences.length; j++) {
        for (var element in readingAssTextList[i].sentences[j].words) {
          element.ass.isRead = false;
        }
      }
    }
    readingAssTextList.refresh();
  }

  /// 取消句子高亮
  void cancelSentenceHighlight() {
    for (int i = 0; i < readingAssTextList.length; i++) {
      for (int j = 0; j < readingAssTextList[i].sentences.length; j++) {
        readingAssTextList[i].sentences[j].isSentenceHighlight = false;
      }
    }
    readingAssTextList.refresh();
  }

  /// 暂停/播放
  Future<void> pauseAndPlay() async{
    if(isPlaying.value){
      audioPlayerUtils.pause();
    }else{
      Duration position = await audioPlayerUtils.getCurrentPosition();
      Duration duration = await audioPlayerUtils.getDuration();

      if(duration.inMilliseconds - 100 <= position.inMilliseconds){
        await audioPlayerUtils.seek(Duration.zero);
      }

      audioPlayerUtils.resume();
    }

    prepareAudioControllerTimer();
    
  }

  

  /// 播放某一句
  Future<void> playSentence(ReadingAssSentenceModel sentenceModel) async {
    if (sentenceModel.words.isEmpty) return;
    playSentenceTimer?.cancel();

    int startMs = sentenceModel.startTime??0;
    int endMs = sentenceModel.endTime??0;
    Duration endDuration = Duration(milliseconds: endMs);
    await audioPlayerUtils.seek(Duration(milliseconds: startMs));

    cancelSentenceHighlight();
    cancelAssHighlight();
    audioPlayerUtils.resume();

    playSentenceTimer = Timer.periodic(const Duration(milliseconds: 50), (t) async{
      if(audioPlayerUtils.isPlaying == false){
        t.cancel();
        return;
      }
      Duration currentPosition = await audioPlayerUtils.getCurrentPosition();
      if(currentPosition >= endDuration){
        t.cancel();
        await audioPlayerUtils.pause();
        cancelSentenceHighlight();
        cancelAssHighlight();
      }
    });
  }

  Future<void> changeTitleNavIndex(int index) async {
    if (index == 3) return; // 禁用写作

    if(index == 1){
      audioPlayerUtils.seek(Duration.zero);
    }
    if (index == 2) { // 如果没有播放完成禁用练习
      if (!hasPractice.value) {
        return;
      }
    }

    playSentenceTimer?.cancel();
    if (index == 1 || index == 2 || index == 3 || titleNavIndex.value == 1 || titleNavIndex.value == 2 || titleNavIndex.value == 3) {// 跟读/练习 暂停音频播放
      Future.sync(() async {
        await audioPlayerUtils.seek(Duration.zero);
        await audioPlayerUtils.stop();
        cancelSentenceHighlight();
        cancelAssHighlight();
      });
    }

    titleNavIndex.value = index;

    if(index != 1){ // 非跟读模式停止录音
      if (Get.isRegistered<ListenAndReadShadowingController>()) {
        Get.find<ListenAndReadShadowingController>().stopRecord();
      }
    }

    if(index == 0){
      prepareAudioControllerTimer();
    }else{
      isShowAudioControllerTimer?.cancel();
      isShowAudioController.value = true;
    }
    
  }


  /// 点击选中句子
  Future<void> clickSelectSentence(ReadingAssSentenceModel sentence) async {
    prepareAudioControllerTimer();
    cancelAssHighlight();
    cancelSentenceHighlight();

    sentence.isSentenceHighlight = true;

    await audioPlayerUtils.seek(Duration(milliseconds: sentence.startTime??0));
    audioPlayerUtils.resume();
  }

  /// 上一句下一句
  void nextOrPreviousSentence(AudioControlPreviousNext type) {
    prepareAudioControllerTimer();

    // 获取所有句子的扁平列表
    List<ReadingAssSentenceModel> allSentences = [];
    for (var paragraph in readingAssTextList) {
      allSentences.addAll(paragraph.sentences);
    }
    if (allSentences.isEmpty) return;

    // 找到当前句子的索引
    int currentIndex = allSentences.indexWhere((s) => s.id == currentSentenceId);
    if (currentIndex == -1) currentIndex = 0;

    // 取消当前选中的句子
    cancelSentenceHighlight();

    // 根据类型选择上一句或下一句
    int targetIndex;
    if (type == AudioControlPreviousNext.previous) {
      // 上一句：如果是第一句则跳转到最后一句
      targetIndex = currentIndex == 0 ? allSentences.length - 1 : currentIndex - 1;
    } else {
      // 下一句：如果是最后一句则跳转到第一句
      targetIndex = currentIndex == allSentences.length - 1 ? 0 : currentIndex + 1;
    }

    // 跳转到目标句子
    ReadingAssSentenceModel targetSentence = allSentences[targetIndex];
    clickSelectSentence(targetSentence);
  }

  /// 判断控制器设置弹出的时候是否一直显示音频控制器
  void toggleAudioControllerAlwaysShow(bool showSpeedList, bool showTranslateList, bool showFontSizeList, bool showPlayOrderList) {
    if(showSpeedList || showTranslateList || showFontSizeList || showPlayOrderList){
      isShowAudioControllerTimer?.cancel();
      isShowAudioController.value = true;
    }else{
      prepareAudioControllerTimer();
    }
  }

  /// 点击空白显示隐藏
  void toggleAudioController() {
    if(titleNavIndex.value != 0){
      isShowAudioController.value = true;
      isShowAudioControllerTimer?.cancel();
      audioControlController.hideAllMenus();
      return; 
    }

    if(isShowAudioController.value){
      isShowAudioController.value = false;
      audioControlController.hideAllMenus();
      
    }else{
      prepareAudioControllerTimer();
    }
  }

  /// 倒计时音频控制器显示倒计时
  void prepareAudioControllerTimer() {
    if(titleNavIndex.value != 0){
      isShowAudioController.value = true;
      isShowAudioControllerTimer?.cancel();
      audioControlController.hideAllMenus();
      return;
    }

    isShowAudioController.value = true;
    isShowAudioControllerTimer?.cancel();
    isShowAudioControllerTimer = Timer(const Duration(seconds: 5), () {
      isShowAudioController.value = false;
      audioControlController.hideAllMenus();
    });
  }


  /// 弹出错误反馈弹窗
  Future<void> showFeedbackErrorContentDialog(BuildContext context) async {

    await audioPlayerUtils.pause();

    Duration? position;
    SongEntityList? song = currentSong;

    if(titleNavIndex.value != 2){
      position = await audioPlayerUtils.getCurrentPosition();
    }

    FeedbackErrorContentDialog.show(
      context: context, 
      position: position,
      name: song?.title, 
      content: song?.content, 
      contentType: song?.contentType, 
      contentId: song?.contentId,
    );
  }

  /// 歌曲列表的打开与关闭
  void toggleDrawer() {
    if (scaffoldKey.currentState == null) return;
    scaffoldKey.currentState!.openEndDrawer();
  }

  Future<void> toggleFavourite() async {
    SongEntityList? song = currentSong;
    if(song == null) return;
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

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    PlayRecordManager.instance.stopTracking(source: 'listen_and_read');
    super.onClose();
    try {
      isShowAudioControllerTimer?.cancel();
      _isPlayingSub?.cancel();
      _pauseResumeSub?.cancel();
      _positionSub?.cancel();
      playSentenceTimer?.cancel();
      // audioPlayerUtils.stop();

      /// 删除录音文件
      for (int i = 0; i < readingAssTextList.length; i++) {
        for (int j = 0; j < readingAssTextList[i].sentences.length; j++) {
          String? recordFilePath = readingAssTextList[i].sentences[j].recordFilePcmPath;
          if (recordFilePath == null) continue;
          File file = File(recordFilePath);
          if (file.existsSync()) {
            file.deleteSync();
          }
        }
      }

      WakelockPlus.disable();
    } catch (_) {}
  }
}
