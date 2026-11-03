import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/widgets/player_widgets/player_ass_widget.dart';
import '../../../../utils/karaoke_subtitles_utils.dart';
import '../../../../utils/play_record_utils/play_record_utils.dart';
import '../../../../utils/utils.dart';
import '../models/zhendu_look_model.dart';
import 'zhendu_look_player_controller.dart';

class ZhenduLookController extends GetxController {

  /// type: unit, favorite, collection, none
  String? type;
  int? typeId;
  /// 用作当前知识点的id
  int? contentId;
  /// 用作当前知识点的类型
  String? contentType;
  /// 用作当前知识点的语义
  int? semanticId;
  /// 用作当前知识点的风格
  int? styleId;
  /// 用作当前知识点的语种
  String? dialect;
  /// 是否是管理端的标识
  String? traceAdminHeader;
  int? milliseconds;
  /// 知识点参数 [{"contentId": 123, "contentType": "EN_SONG", "styleId": 1, "dialect": "en-US"}]
  List<Map<String, dynamic>>? contents;

  /// 是否弹出了权限弹窗
  bool isShowLockDialog = false;

  /// 一次加载50条
  final int pageSize = 50;

  /// 当前已加载的数据数量
  int loadedCount = 0;

  /// 是否正在加载中
  final RxBool isLoadingData = false.obs;

  /// 是否还有更多数据
  final RxBool hasMoreData = true.obs;

  /// 所有节目数据
  final RxList<ZhenduDetilEntity> songList = <ZhenduDetilEntity>[].obs;

  /// 伪随机数池 用于随机播放
  final RxList<ZhenduDetilEntity> randomPoolIndices = <ZhenduDetilEntity>[].obs;

  /// 当前节目唯一标识
  final RxString currentContentUniqueKey = "".obs;

  /// 获取当前播放的歌曲
  ZhenduDetilEntity? get currentSong => songList.firstWhereOrNull((e) => getSongUniqueKeyBySong(e) == currentContentUniqueKey.value);

  

  /// 帧数据
  final RxList<ZhenduLookModel> frameList = <ZhenduLookModel>[].obs;

  /// PageController
  final PageController pageController = PageController(initialPage: 0);

  /// 程序驱动 PageView 动画期间，屏蔽 onPageChanged 里的 seek，避免联动回环。
  bool _isProgrammaticPageChanging = false;
  int _programmaticPageChangeToken = 0;

  /// 手动滑页后启用“本幕播放模式”：只播放当前幕，到幕尾自动暂停。
  bool _isFrameOnlyPlaybackMode = false;
  int _frameOnlyEndMilliseconds = -1;
  bool _isFrameOnlyStopping = false;

  /// 自动播放的“幕切换停顿”控制：
  /// - 用 token 取消等待中的切幕流程，避免与手动滑动/点句子等行为冲突
  /// - 用 _isAutoFrameSwitching 防抖，避免 position 高频回调重复触发
  bool _isAutoFrameSwitching = false;
  int _autoFrameSwitchToken = 0;
  int _suppressAutoFrameSwitchUntilEpochMs = 0;
  int _suppressSentenceFrameSyncUntilEpochMs = 0;

  /// 是否是本幕播放模式
  bool get isFrameOnlyPlaybackMode => _isFrameOnlyPlaybackMode;

  
  @override
  void onInit() {
    super.onInit();
    WakelockPlus.enable();
    if (Get.arguments != null) {
      type = Get.arguments["type"];
      typeId = Get.arguments["typeId"];
      contentId = Get.arguments["contentId"];
      contentType = Get.arguments["contentType"];
      semanticId = Get.arguments["semanticId"];
      styleId = Get.arguments["styleId"];
      dialect = Get.arguments["dialect"];
      traceAdminHeader = Get.arguments["traceAdminHeader"];
      milliseconds = Get.arguments["milliseconds"];

      try {
        List? argList = Get.arguments["contents"];
        if(argList != null){
          List<Map<String, dynamic>> argContents = [];
          for (var item in argList) {
            argContents.add(item as Map<String, dynamic>);
          }
          contents = argContents;
        }
      } catch (_) {}
      getCurrentParamIndex();
      getDataList();
    }
  }


  /// 在列表中获取播放的下标
  void getCurrentParamIndex() {
    if (contents == null) return;
    if (contents!.isEmpty) return;
    if (contentId == null || contentType == null) {
      currentContentUniqueKey.value = getSongUniqueKeyByContentItem(contents!.first);
      return;
    }
    final targetKey = buildSongUniqueKey(
      contentId: contentId,
      semanticId: semanticId,
      contentType: contentType,
      styleId: styleId,
      dialect: dialect,
    );
    final int index = contents!.indexWhere((item) => getSongUniqueKeyByContentItem(item) == targetKey);
    currentContentUniqueKey.value = index < 0 ? getSongUniqueKeyByContentItem(contents!.first) : getSongUniqueKeyByContentItem(contents![index]);
  }

  /// 构建播放项唯一值：`contentId+semanticId+contentType+styleId+dialect`
  String buildSongUniqueKey({
    required int? contentId,
    required int? semanticId,
    required String? contentType,
    required int? styleId,
    required String? dialect,
  }) {
    return "${contentId ?? ''}+${semanticId ?? '0'}+${contentType ?? ''}+${styleId ?? ''}+${dialect ?? ''}";
  }

  /// 由已加载歌曲对象生成唯一值。
  String getSongUniqueKeyBySong(ZhenduDetilEntity? song) {
    return buildSongUniqueKey(
      contentId: song?.contentId,
      semanticId: null,
      contentType: song?.contentType,
      styleId: song?.contentInfo?.styleId,
      dialect: song?.contentInfo?.dialect,
    );
  }

  /// 由路由入参 `contents` 的单条数据生成唯一值。
  String getSongUniqueKeyByContentItem(Map<String, dynamic>? item) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString());
    }

    return buildSongUniqueKey(
      contentId: parseInt(item?["contentId"]),
      semanticId: parseInt(item?["semanticId"]),
      contentType: item?["contentType"]?.toString(),
      styleId: parseInt(item?["styleId"]),
      dialect: item?["dialect"]?.toString(),
    );
  }

  /// 获取节目列表
  Future<void> getDataList() async{
    try {
      ToastUtils.showLoading();

      // 计算当前唯一值在 songParam 中的位置
      int currentIndex = 0;
      if (currentContentUniqueKey.value.isEmpty && contentId != null && contentType != null) {
        final targetKey = buildSongUniqueKey(
          contentId: contentId,
          semanticId: semanticId,
          contentType: contentType,
          styleId: styleId,
          dialect: dialect,
        );
        final targetIndex = contents!.indexWhere((item) => getSongUniqueKeyByContentItem(item) == targetKey);
        if (targetIndex >= 0) {
          currentContentUniqueKey.value = getSongUniqueKeyByContentItem(contents![targetIndex]);
        }
      }
      if (currentContentUniqueKey.value.isNotEmpty) {
        currentIndex = contents!.indexWhere((item) => getSongUniqueKeyByContentItem(item) == currentContentUniqueKey.value);
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
          "styleId": item["styleId"],
          "dialect": item["dialect"],
        });
      }

      Map<String, dynamic> reqData = {
        "contents": reqContents,
      };

      Map<String, dynamic> reqParameters = {
        "learnType": ZhenduPageTypeEnum.watch.value,
      };

      SongEntity? songEntity = await SongRequest.getPlayKnowledgeList(data: reqData, parameters: reqParameters, traceAdminHeader: traceAdminHeader);
      if (songEntity == null) return;
      if(isClosed) return;
      List<SongEntityList?> list = songEntity.list ?? [];
      songList.clear();
      randomPoolIndices.clear();
      for (var item in list) {
        if (item == null) continue;
        songList.add(ZhenduDetilEntity(
          contentId: item.contentId,
          contentType: item.contentType,
          contentInfo: item,
          globalKey: GlobalKey(),
        ));
        randomPoolIndices.add(ZhenduDetilEntity(
          contentId: item.contentId,
          contentType: item.contentType,
          contentInfo: item,
        ));
      }
      randomPoolIndices.shuffle();
      
      // 更新已加载数量和是否有更多数据
      loadedCount = initialLoadCount;
      hasMoreData.value = loadedCount < contents!.length;

      if(songList.isEmpty) return;
      
      switchSong(currentSong ?? songList.first);
      Get.find<ZhenduLookPlayerController>().startShowAudioControllerTimer();
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
      int startIndex = loadedCount;
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
          "styleId": item["styleId"],
          "dialect": item["dialect"],
        });
      }

      Map<String, dynamic> reqData = {
        "contents": reqDataList,
      };

      Map<String, dynamic> reqParameters = {
        "learnType": ZhenduPageTypeEnum.watch.value,
      };

      SongEntity? songEntity = await SongRequest.getPlayKnowledgeList(data: reqData, parameters: reqParameters, traceAdminHeader: traceAdminHeader);
      if (songEntity == null) return;

      List<SongEntityList?> list = songEntity.list ?? [];
      for (var item in list) {
        if (item == null) continue;
        songList.add(ZhenduDetilEntity(
          contentId: item.contentId,
          contentType: item.contentType,
          contentInfo: item,
          globalKey: GlobalKey(),
        ));
        randomPoolIndices.add(ZhenduDetilEntity(
          contentId: item.contentId,
          contentType: item.contentType,
          contentInfo: item,
        ));
      }
      randomPoolIndices.shuffle();

      // 更新已加载数量和是否有更多数据
      loadedCount = endIndex;
      hasMoreData.value = loadedCount < contents!.length;
    } finally {
      isLoadingData.value = false;
    }
  }

  /// 获取详情数据
  Future<ZhenduDetilEntity?> getSongDetail(ZhenduDetilEntity? data) async{
    if(data == null) return data;

    if(Get.context != null && data.contentInfo?.cardRights != null){
      if(isShowLockDialog) return null;
      isShowLockDialog = true;
      bool res = await LockUtils.checkLock(
        data.contentInfo?.cardRights, 
        Get.context!, 
        contentType: data.contentType,
        onPlaySuccess: () async{
          await refreshSingleSong(data);
        },
      );
      isShowLockDialog = false;
      if(res) return null;
    }

    if(data.contentInfo?.pronunciations != null){
      return data;
    }
    Map<String, dynamic> parameters = {
      "contentId": data.contentId,
      "contentType": data.contentType,
      "learnType": ZhenduPageTypeEnum.watch.value,
      "styleId": data.contentInfo?.styleId,
      "dialect": data.contentInfo?.dialect,
    };
    try {
      ToastUtils.showLoading();
      // getPlayKnowledgeInfoV2
      ZhenduDetilEntity? songEntityList = await SongRequest.getPlayKnowledgeInfoV2(parameters, traceAdminHeader: traceAdminHeader);
      if(songEntityList == null) return null;

      final targetUniqueKey = getSongUniqueKeyBySong(songEntityList);
      for(int i = 0; i < songList.length; i++){
        if(targetUniqueKey == getSongUniqueKeyBySong(songList[i])){
          songList[i] = songEntityList;
        }
      }

      for(int i = 0; i < randomPoolIndices.length; i++){
        if(targetUniqueKey == getSongUniqueKeyBySong(randomPoolIndices[i])){
          randomPoolIndices[i] = songEntityList;
        }
      }
      
      return songEntityList;
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 刷新指定歌曲
  Future<void> refreshSingleSong(ZhenduDetilEntity? data) async{
    if(data == null) return;
    List<Map<String, dynamic>> reqDataList = [{
      "uid": data.contentId,
      "type": data.contentType,
    }];
    Map<String, dynamic> reqData = {
      "contents": reqDataList,
    };
    Map<String, dynamic> reqParameters = {
      "learnType": ZhenduPageTypeEnum.watch.value,
    };
    SongEntity? songEntity = await SongRequest.getPlayKnowledgeList(data: reqData, parameters: reqParameters, traceAdminHeader: traceAdminHeader);
    if (songEntity == null) return;
    List<SongEntityList?> list = songEntity.list ?? [];
    if(list.isEmpty) return;
    data.contentInfo = list.first;
  }

  /// 切换歌曲（页面入口）
  /// 负责：补全详情 -> 更新当前曲目 -> 重置循环计数 -> 触发开始播放。
  Future<void> switchSong(ZhenduDetilEntity song) async {
    try {
      final ZhenduLookPlayerController playerController = Get.find<ZhenduLookPlayerController>();
      // 在切换前获取当前播放位置，用于切歌上报
      final lastPosition = playerController.position.value;
      final lastPlayedSeconds = lastPosition.inMilliseconds / 1000.0;
      
      ZhenduDetilEntity? detailSong = await getSongDetail(song);
      if(detailSong == null) return;
      if(isClosed) return;
      // 更新 songList 中的数据
      final targetUniqueKey = getSongUniqueKeyBySong(detailSong);
      int index = songList.indexWhere((e) => getSongUniqueKeyBySong(e) == targetUniqueKey);
      if (index >= 0) {
        songList[index] = detailSong;
      }

      currentContentUniqueKey.value = targetUniqueKey;
      playerController.currentSentenceIndex.value = -1;
      playerController.currentWordIndex.value = -1;
      playerController.subtitleList.clear();
      playerController.currentPlayCount.value = 0;
      frameList.clear();

      await startPlay(lastPlayedSeconds: lastPlayedSeconds);
    } catch (_) {}
  }

  /// 开始播放当前曲目（委托给播放器控制器执行具体播放与缓存策略）
  Future<void> startPlay({double? lastPlayedSeconds}) async{

    ZhenduDetilEntity? song = currentSong;
    if (song == null) return;
    await parseAssText();
    final ZhenduLookPlayerController playerController = Get.find<ZhenduLookPlayerController>();

    PronunciationsEntity? pronunciations = song.contentInfo?.audioInfo;
    if(pronunciations == null) return;

    String? audioUrl = pronunciations.audioUrl;
    if(audioUrl == null || audioUrl.isEmpty) return;
    resetFramePageToFirst();
    
    await playerController.open(audioUrl, ResourceType.audio);

    // 开始追踪播放记录
    PlayRecordManager.instance.startTracking(
      player: playerController.player,
      contentType: song.contentType ?? '',
      contentId: song.contentId ?? 0,
      duration: (pronunciations.duration ?? 0).toDouble(),
      source: 'zhendu_look',
      lastPlayedSeconds: lastPlayedSeconds,
      type: type,
      typeId: typeId,
      styleId: song.contentInfo?.styleId,
      dialect: song.contentInfo?.dialect,
      learnType: ZhenduPageTypeEnum.watch,
    );

  }

  /// 解析ass字幕
  Future<void> parseAssText() async{
    ZhenduDetilEntity? song = currentSong;
    if (song == null) return;
    String? assTextData = song.contentInfo?.audioInfo?.audioAss;
    if (assTextData == null) return;

    // 获取释义文本
    LanguageText? translateAss = song.contentInfo?.audioInfo?.translateAssText;
    String? translateText = translateAss?.text;

    final ZhenduLookPlayerController playerController = Get.find<ZhenduLookPlayerController>();

    List<AssSubtitle> translateSentences = [];
    if (translateText != null && translateText != "") {
      translateSentences = KaraokeSubtitlesUtils.parseAssTranslateDialogue(translateText);
    }
    
    List<SubtitlesSentenceModel> assSentences = KaraokeSubtitlesUtils.parseAssSentenceByDialogue(assTextData);

    for (int i = 0; i < assSentences.length; i++) {
      List<AssSubtitle> item = assSentences[i].words;
      if (item.isEmpty) continue;
      AssSubtitle? translate;
      if (i < translateSentences.length) {
        translate = translateSentences[i];
      }

      String? actorAvatar = findActorAvatar(assSentences[i].actor);

      PlayerAssData<List<SentenceParsingWordsEntityList>?> playerAssData = PlayerAssData(
        sentence: assSentences[i],
        translate: translate,
        actorName: assSentences[i].actor,
        actorAvatar: actorAvatar,
      );

      playerController.subtitleList.add(playerAssData);
    }

    List<ZhenduDetilEntityExtraFrames?> frameData = song.extra?.frames??[];
    if(frameData.isEmpty) return;

    for(int i = 0; i < frameData.length; i++){
      if(frameData[i] == null) continue;
      if(i == 0 && frameData[i]!.frameUrl != null){
        await CacheManagerUtils.instance.getFile(frameData[i]!.frameUrl!, ResourceType.image); //缓存帧图片
      }
      frameList.add(ZhenduLookModel(
        frameData: frameData[i]!,
        assDatas: findAssByFrame(frameData[i]!),
      ));
    }

    unawaited(cacheImage());

  }

  /// 缓存图片资源
  Future<void> cacheImage() async{
    for (var element in frameList) {
      if(element.frameData.frameUrl == null || element.frameData.frameUrl == "") continue;
      await CacheManagerUtils.instance.getFile(element.frameData.frameUrl, ResourceType.image); //缓存帧图片
      if(isClosed) return;
    }

  }
  

  /// 查找演员头像
  String? findActorAvatar(String? actor) {
    if(actor == null || actor.isEmpty) return null;
    ZhenduDetilEntity? song = currentSong;
    if (song == null) return null;
    List<ZhenduDetilEntityExtraPersonaList?>? personaList = song.extra?.personaList??[];
    if(personaList.isEmpty) return null;
    for(ZhenduDetilEntityExtraPersonaList? item in personaList){
      if(item?.speaker == actor){
        return item?.avatarUrl;
      }
    }
    return null;
  }

  /// 根据帧图片查找ass句子
  List<PlayerAssData<List<SentenceParsingWordsEntityList>?>> findAssByFrame(ZhenduDetilEntityExtraFrames frame){

    List<PlayerAssData<List<SentenceParsingWordsEntityList>?>> resp = [];
    final ZhenduLookPlayerController playerController = Get.find<ZhenduLookPlayerController>();


    // 如果对话索引为空 使用开始结束时间判断
    if(frame.start == null || frame.end == null) return resp;
    int start = DateFormatUtil.secondsToDuration(frame.start!).inMilliseconds;
    int end = DateFormatUtil.secondsToDuration(frame.end!).inMilliseconds;

    for(int i = 0; i < playerController.subtitleList.length; i++){
      int? assStart = playerController.subtitleList[i].sentence.sentenceStartTime;
      int? assEnd = playerController.subtitleList[i].sentence.sentenceEndTime;
      if(start <= assEnd! && end >= assStart!){
        resp.add(playerController.subtitleList[i]);
      }
    }
    return resp;
  }


  /// 根据音频的进度查找对应的图片
  void changeFrameByAudioProgress(int sentenceIndex){
    if(_isFrameOnlyPlaybackMode) return;
    if(_isAutoFrameSwitching) return;
    if(DateTime.now().millisecondsSinceEpoch < _suppressSentenceFrameSyncUntilEpochMs){
      return;
    }
    if(sentenceIndex < 0) return;
    final ZhenduLookPlayerController playerController = Get.find<ZhenduLookPlayerController>();
    if(sentenceIndex >= playerController.subtitleList.length) return;
    final PlayerAssData sentence = playerController.subtitleList[sentenceIndex];
    final int? sentenceStart = sentence.sentence.sentenceStartTime;
    final int? sentenceEnd = sentence.sentence.sentenceEndTime ?? sentenceStart;
    final int targetFrameIndex = _findFrameIndexBySentence(
      sentenceStart: sentenceStart,
      sentenceEnd: sentenceEnd,
    );
    _jumpToFrame(targetFrameIndex, skipSeekOnPageChanged: true);
  }

  /// pageview改变
  void onFramePageChanged(int index){
    if(index < 0 || index >= frameList.length) return;
    if(_isProgrammaticPageChanging){
      return;
    }
    _cancelAutoFrameSwitch();
    exitFrameOnlyPlaybackMode();
    final ZhenduLookPlayerController playerController = Get.find<ZhenduLookPlayerController>();
    final ({int? start, int? end}) frameBounds = _resolveFramePlaybackBounds(frameList[index]);
    final int? frameStart = frameBounds.start;
    final int? frameEnd = frameBounds.end;
    if(frameStart == null || frameEnd == null || frameEnd < frameStart){
      return;
    }

    _enableFrameOnlyPlayback(frameEnd);
    playerController.hideAudioController();
    unawaited(_seekAndPlayFrameStart(playerController, frameStart));
  }

  void resetFramePageToFirst(){
    _cancelAutoFrameSwitch();
    exitFrameOnlyPlaybackMode();
    if(!pageController.hasClients) return;
    _isProgrammaticPageChanging = true;
    final int token = ++_programmaticPageChangeToken;
    try {
      pageController.jumpToPage(0);
    } catch (_) {
      try {
        pageController.jumpTo(0);
      } catch (_) {}
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(token == _programmaticPageChangeToken){
        _isProgrammaticPageChanging = false;
      }
    });
  }

  /// 改变ass 查找对应的图片
  Future<void> changeAssIndex(PlayerAssData sentence, int sentenceIndex) async{
    _cancelAutoFrameSwitch();
    exitFrameOnlyPlaybackMode();
    final ZhenduLookPlayerController playerController = Get.find<ZhenduLookPlayerController>();
    final int? sentenceStart = sentence.sentence.sentenceStartTime;
    final int? sentenceEnd = sentence.sentence.sentenceEndTime ?? sentenceStart;

    final int targetFrameIndex = _findFrameIndexBySentence(
      sentenceStart: sentenceStart,
      sentenceEnd: sentenceEnd,
    );
    _jumpToFrame(targetFrameIndex, skipSeekOnPageChanged: true);

    if(sentenceStart != null){
      await playerController.onSeek(Duration(milliseconds: sentenceStart));
      if(!playerController.isPlaying.value){
        playerController.onGesturePlayPause();
      }
    }
  }

  /// 继续播放时退出“本幕播放模式”，恢复正常连播。
  void exitFrameOnlyPlaybackMode(){
    _isFrameOnlyPlaybackMode = false;
    _frameOnlyEndMilliseconds = -1;
    _isFrameOnlyStopping = false;
  }

  /// 在 position listener 中调用：命中本幕尾部时暂停并钉在幕尾。
  bool handleFrameOnlyPlaybackBoundary(Duration position){
    if(!_isFrameOnlyPlaybackMode) return false;
    if(_frameOnlyEndMilliseconds < 0) return false;
    if(_isFrameOnlyStopping) return true;
    if(frameList.isNotEmpty && pageController.hasClients){
      final int currentPage = pageController.page?.round() ?? pageController.initialPage;
      if(currentPage >= frameList.length - 1){
        exitFrameOnlyPlaybackMode();
        return false;
      }
    }
    // 手动模式：严格按本幕 end 触发暂停，并在暂停后 seek 回 end，把进度钉在本幕末尾。
    if(position.inMilliseconds <= _frameOnlyEndMilliseconds) return false;
    _isFrameOnlyStopping = true;
    unawaited(_pauseAtFrameEnd());
    return true;
  }

  /// 在 position listener 中调用：自动播放时，命中幕尾后暂停 -> 切幕动画 -> 停 1 秒 -> 继续播放。
  /// 返回 true 表示已接管本次 position 处理（避免继续走句子定位，导致重复触发/联动）。
  bool handleAutoPlaybackFrameBoundary(Duration position){
    if(_isFrameOnlyPlaybackMode) return false;
    if(frameList.isEmpty) return false;
    if(_isAutoFrameSwitching) return true;
    if(DateTime.now().millisecondsSinceEpoch < _suppressAutoFrameSwitchUntilEpochMs){
      return false;
    }
    if(!pageController.hasClients) return false;
    if(_isProgrammaticPageChanging) return false;

    final ZhenduLookPlayerController playerController = Get.find<ZhenduLookPlayerController>();
    final int milliseconds = position.inMilliseconds;

    final int currentPage = pageController.page?.round() ?? pageController.initialPage;
    if(currentPage < 0 || currentPage >= frameList.length) return false;

    // 只有在实际播放中才触发“幕尾暂停 + 切幕 + 停 1 秒”。
    if(!playerController.isPlaying.value) return false;

    final ({int? start, int? end}) frameBounds = _resolveFramePlaybackBounds(frameList[currentPage]);
    final int? frameEnd = frameBounds.end;
    if(frameEnd == null) return false;
    if(currentPage >= frameList.length - 1) return false;

    if(milliseconds < frameEnd) return false;

    // 自动模式：暂停并钉回本幕末尾 -> 切到下一幕 -> 停顿 1 秒-> 续播。
    unawaited(_autoPauseAndSwitchFrame(
      currentPage + 1,
      pauseAtMilliseconds: frameEnd,
    ));
    return true;
  }

  /// 启用本幕播放模式，并记录幕尾边界。
  void _enableFrameOnlyPlayback(int frameEndMilliseconds){
    _isFrameOnlyPlaybackMode = true;
    _frameOnlyEndMilliseconds = frameEndMilliseconds;
    _isFrameOnlyStopping = false;
  }

  /// 优先使用 ASS 句子边界；若本幕无 ASS，回落到 frame start/end。
  ({int? start, int? end}) _resolveFramePlaybackBounds(ZhenduLookModel model){
    int? start;
    int? end;

    if(model.assDatas.isNotEmpty){
      start = model.assDatas.first.sentence.sentenceStartTime;
      end = model.assDatas.last.sentence.sentenceEndTime ??
          model.assDatas.last.sentence.sentenceStartTime;
    }

    int? frameStart;
    int? frameEnd;
    if(model.frameData.start != null && model.frameData.end != null){
      frameStart = DateFormatUtil.secondsToDuration(model.frameData.start!).inMilliseconds;
      frameEnd = DateFormatUtil.secondsToDuration(model.frameData.end!).inMilliseconds;
    }

    // 以服务端 frame start/end 为准进行钳制，避免由于 assDatas 覆盖范围偏大导致 start/end 异常（例如 start=0 造成回跳）。
    if(frameStart != null){
      start = start == null ? frameStart : start < frameStart ? frameStart : start;
    }
    if(frameEnd != null){
      end = end == null ? frameEnd : end > frameEnd ? frameEnd : end;
    }
    if(frameStart != null && frameEnd != null && start != null && end != null && end < start){
      start = frameStart;
      end = frameEnd;
    }
    return (start: start, end: end);
  }

  /// 到幕尾后：先暂停，再将进度精确定位到幕尾。
  Future<void> _pauseAtFrameEnd() async{
    final ZhenduLookPlayerController playerController = Get.find<ZhenduLookPlayerController>();
    final Duration end = Duration(milliseconds: _frameOnlyEndMilliseconds);
    try {
      await playerController.player.pause();
      await playerController.onSeek(end, exitFrameOnlyMode: false, userInitiated: false);

    } finally {
      _isFrameOnlyStopping = false;
    }
  }

  /// 手动切到某一幕后：先定位，再开始播放，避免旧进度瞬时越界。
  Future<void> _seekAndPlayFrameStart(ZhenduLookPlayerController playerController, int frameStart) async{
    await playerController.onSeek(
      Duration(milliseconds: frameStart),
      exitFrameOnlyMode: false,
      userInitiated: false,
    );
    await playerController.player.play();
  }

  /// 取消正在进行的自动切幕（例如用户手动滑动/点句子），并允许后续重新触发自动切幕。
  void _cancelAutoFrameSwitch(){
    _autoFrameSwitchToken++;
    _isAutoFrameSwitching = false;
  }

  /// 自动播放的“切幕停顿”流程：
  /// 1) pause（可选）并 seek 到 [pauseAtMilliseconds]（本幕尾）；
  /// 2) PageView 切到 [targetFrameIndex]；
  /// 3) 等待 1 秒（给切幕动画时间）；
  Future<void> _autoPauseAndSwitchFrame(
    int targetFrameIndex, {
    int? pauseAtMilliseconds,
  }) async{
    if(_isFrameOnlyPlaybackMode) return;
    if(_isAutoFrameSwitching) return;
    if(targetFrameIndex < 0 || targetFrameIndex >= frameList.length) return;
    if(!pageController.hasClients) return;

    final ZhenduLookPlayerController playerController = Get.find<ZhenduLookPlayerController>();
    final int currentPage = pageController.page?.round() ?? pageController.initialPage;
    if(currentPage == targetFrameIndex) return;

    _isAutoFrameSwitching = true;
    final int token = ++_autoFrameSwitchToken;
    final Stopwatch stopwatch = Stopwatch()..start();
    final bool wasPlaying = playerController.isPlaying.value;
    try {
      if(wasPlaying){
        await playerController.player.pause();
        // 清除单词字幕高亮
        playerController.currentWordIndex.value = -1;
      }
      if(pauseAtMilliseconds != null){
        await playerController.onSeek(
          Duration(milliseconds: pauseAtMilliseconds),
          exitFrameOnlyMode: false,
          userInitiated: false,
        );
      }
      await _jumpToFrameAsync(targetFrameIndex, skipSeekOnPageChanged: true);
      final Duration remaining = const Duration(seconds: 1) - stopwatch.elapsed;
      if(remaining > Duration.zero){
        await Future.delayed(remaining);
      }
      if(isClosed) return;
      if(token != _autoFrameSwitchToken) return;
      if(_isFrameOnlyPlaybackMode) return;
      if(wasPlaying){
        await playerController.player.play();
      }
    } finally {
      if(token == _autoFrameSwitchToken){
        _isAutoFrameSwitching = false;
      }
    }
  }

  Future<void> onUserSeek(Duration position) async{
    _cancelAutoFrameSwitch();
    // 用户拖动进度条属于“跳变”，此时不应触发自动切幕的停顿逻辑。
    // 同时短暂屏蔽句子进度驱动的切幕，避免 seek 后 sentenceIndex 误命中导致回跳。
    _suppressAutoFrameSwitchUntilEpochMs =
        DateTime.now().millisecondsSinceEpoch + 2500;
    _suppressSentenceFrameSyncUntilEpochMs =
        DateTime.now().millisecondsSinceEpoch + 1200;
    _syncFrameByPosition(position);
  }

  void _syncFrameByPosition(Duration position){
    final int targetFrameIndex = _findFrameIndexByFrameTime(position.inMilliseconds);
    if(targetFrameIndex < 0) return;
    _jumpToFrame(targetFrameIndex, skipSeekOnPageChanged: true, isUserSeek: true);
  }

  int _findFrameIndexByFrameTime(int milliseconds){
    int bestIndex = -1;
    int bestStart = -1;
    for(int i = 0; i < frameList.length; i++){
      final model = frameList[i];
      if(model.frameData.start == null || model.frameData.end == null) continue;
      final int frameStart = DateFormatUtil.secondsToDuration(model.frameData.start!).inMilliseconds;
      final int frameEnd = DateFormatUtil.secondsToDuration(model.frameData.end!).inMilliseconds;
      if(frameStart <= milliseconds && frameEnd >= milliseconds){
        return i;
      }
      if(frameStart <= milliseconds && frameStart > bestStart){
        bestStart = frameStart;
        bestIndex = i;
      }
    }
    if(bestIndex >= 0) return bestIndex;
    return frameList.isEmpty ? -1 : 0;
  }

  /// 以程序驱动的方式切换 PageView：
  /// - skipSeekOnPageChanged=true 时，会临时屏蔽 onPageChanged 中的 seek，避免自动/手动逻辑联动回环。
  Future<void> _jumpToFrameAsync(int frameIndex, {bool skipSeekOnPageChanged = false}) async{
    if(frameIndex < 0 || frameIndex >= frameList.length) return;
    if(!pageController.hasClients) return;
    final int currentPage = pageController.page?.round() ?? pageController.initialPage;
    if(currentPage == frameIndex) return;
    final int pageDistance = (frameIndex - currentPage).abs();

    if(pageDistance > 1){
      if(skipSeekOnPageChanged){
        _isProgrammaticPageChanging = true;
        final int token = ++_programmaticPageChangeToken;
        pageController.jumpToPage(frameIndex);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if(token == _programmaticPageChangeToken){
            _isProgrammaticPageChanging = false;
          }
        });
        return;
      }
      pageController.jumpToPage(frameIndex);
      return;
    }

    if(skipSeekOnPageChanged){
      _isProgrammaticPageChanging = true;
      final int token = ++_programmaticPageChangeToken;
      await pageController.animateToPage(
        frameIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.linear,
      );
      if(token == _programmaticPageChangeToken){
        _isProgrammaticPageChanging = false;
      }
      return;
    }

    await pageController.animateToPage(
      frameIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
  }

  /// 根据句子时间查找对应的帧索引（支持一帧对应多句）
  int _findFrameIndexBySentence({
    required int? sentenceStart,
    required int? sentenceEnd,
  }){
    if(sentenceStart == null || sentenceEnd == null) return -1;

    // 优先用 frameData 的时间区间做映射：它是“幕”本身的定义，避免 assDatas 覆盖范围偏大导致回跳。
    int bestIndex = -1;
    int bestStart = -1;

    for(int i = 0; i < frameList.length; i++){
      final model = frameList[i];
      if(model.frameData.start == null || model.frameData.end == null) continue;
      final int frameStart = DateFormatUtil.secondsToDuration(model.frameData.start!).inMilliseconds;
      final int frameEnd = DateFormatUtil.secondsToDuration(model.frameData.end!).inMilliseconds;
      final bool hit = frameStart <= sentenceStart && frameEnd >= sentenceEnd;
      if(!hit) continue;
      if(frameStart > bestStart){
        bestStart = frameStart;
        bestIndex = i;
      }
    }
    if(bestIndex >= 0) return bestIndex;

    bestIndex = -1;
    bestStart = -1;
    for(int i = 0; i < frameList.length; i++){
      final model = frameList[i];
      if(model.frameData.start == null || model.frameData.end == null) continue;
      final int frameStart = DateFormatUtil.secondsToDuration(model.frameData.start!).inMilliseconds;
      final int frameEnd = DateFormatUtil.secondsToDuration(model.frameData.end!).inMilliseconds;
      final bool hit = frameStart <= sentenceEnd && frameEnd >= sentenceStart;
      if(!hit) continue;
      if(frameStart > bestStart){
        bestStart = frameStart;
        bestIndex = i;
      }
    }
    if(bestIndex >= 0) return bestIndex;

    // frameData 不完整时，再回落到 assDatas 的重叠判断。
    bestIndex = -1;
    bestStart = -1;
    for(int i = 0; i < frameList.length; i++){
      final ({int? start, int? end}) bounds = _resolveFramePlaybackBounds(frameList[i]);
      final int? start = bounds.start;
      final int? end = bounds.end;
      if(start == null || end == null) continue;
      final bool hit = start <= sentenceEnd && end >= sentenceStart;
      if(!hit) continue;
      if(start > bestStart){
        bestStart = start;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  /// 跳转到指定帧
  void _jumpToFrame(int frameIndex, {bool skipSeekOnPageChanged = false, bool isUserSeek = false}){
    if(frameIndex < 0 || frameIndex >= frameList.length) return;
    if(!pageController.hasClients) return;
    final int currentPage = pageController.page?.round() ?? pageController.initialPage;
    if(currentPage == frameIndex) return;

    if(isUserSeek){
      if(skipSeekOnPageChanged){
        _isProgrammaticPageChanging = true;
        final int token = ++_programmaticPageChangeToken;
        pageController.jumpToPage(frameIndex);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if(token == _programmaticPageChangeToken){
            _isProgrammaticPageChanging = false;
          }
        });
        return;
      }
      pageController.jumpToPage(frameIndex);
      return;
    }

    if(skipSeekOnPageChanged){
      _isProgrammaticPageChanging = true;
      final int token = ++_programmaticPageChangeToken;
      
      pageController.animateToPage(
        frameIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.linear,
      ).whenComplete(() {
        if(token == _programmaticPageChangeToken){
          _isProgrammaticPageChanging = false;
        }
      });
      return;
    }
    pageController.animateToPage(
      frameIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    PlayRecordManager.instance.stopTracking(source: 'zhendu_look');
    WakelockPlus.disable();
    super.onClose();
  }
}
