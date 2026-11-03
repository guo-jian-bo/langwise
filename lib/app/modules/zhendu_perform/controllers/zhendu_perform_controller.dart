
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resource_cache_package/resource_cache_package.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/widgets/player_widgets/player_ass_widget.dart';
import '../../../../utils/interaction_record_utils/interaction_record_utils.dart';
import '../../../../utils/karaoke_subtitles_utils.dart';
import '../../../../utils/play_record_utils/play_record_utils.dart';
import '../../../../utils/utils.dart';
import '../../../routes/routes.dart';
import '../../../routes/routes_breadcrumb_utils.dart';
import 'zhendu_perform_player_controller.dart';

class ZhenduPerformController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  ZhenduPerformController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENDU_PERFORM;

  @override
  String get breadcrumbTitle => "动画";

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

  

  
  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
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
      print('Print${Get.arguments}');


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
      print('Print2${reqContents}');



      Map<String, dynamic> reqData = {
        "contents": reqContents,
      };

      Map<String, dynamic> reqParameters = {
        "learnType": ZhenduPageTypeEnum.perform.value,
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
      Get.find<ZhenduPerformPlayerController>(tag: tagText).startShowAudioControllerTimer();
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
        "learnType": ZhenduPageTypeEnum.perform.value,
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
      "learnType": ZhenduPageTypeEnum.perform.value,
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
      "learnType": ZhenduPageTypeEnum.perform.value,
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
    final ZhenduPerformPlayerController playerController = Get.find<ZhenduPerformPlayerController>(tag: tagText);

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

    await startPlay(lastPlayedSeconds: lastPlayedSeconds);
  }

  /// 开始播放当前曲目（委托给播放器控制器执行具体播放与缓存策略）
  Future<void> startPlay({double? lastPlayedSeconds}) async{

    try {
      ToastUtils.showLoading();
      ZhenduDetilEntity? song = currentSong;
      if (song == null) return;
      parseAssText();
      final ZhenduPerformPlayerController playerController = Get.find<ZhenduPerformPlayerController>(tag: tagText);
      String? networkUrl = song.contentInfo?.video?.videoUrl;
      if(networkUrl == null || networkUrl.isEmpty) return;

      /// 切歌时需要先结束旧播放记录，再结束旧交互会话，保证结束顺序正确。
      await PlayRecordManager.instance.switchTracking(
        source: 'zhendu_perform',
        lastPlayedSeconds: lastPlayedSeconds,
      );
      await _stopInteractionSession();

      /// 交互记录需要先于播放记录启动，确保快进等场景仍复用同一个 sessionId。
      final String sessionId = InteractionSessionManager.instance.createSessionId();
      await _startInteractionSession(song, playerController, sessionId);

      await playerController.open(networkUrl, ResourceType.video);
      await Future.delayed(const Duration(milliseconds: 200));
      
      // 开始追踪播放记录
      await PlayRecordManager.instance.startTracking(
        player: playerController.player,
        contentType: song.contentType ?? '',
        contentId: song.contentId ?? 0,
        duration: (song.contentInfo?.video?.duration ?? 0).toDouble(),
        source: 'zhendu_perform',
        lastPlayedSeconds: lastPlayedSeconds,
        type: type,
        typeId: typeId,
        styleId: song.contentInfo?.styleId,
        dialect: song.contentInfo?.dialect,
        learnType: ZhenduPageTypeEnum.perform,
        sessionId: sessionId,
      );
    } catch (e) {
      ToastUtils.showToast(text: "开始播放失败");
      ErrorLogUtils.to.logError("[zhendu_look] ${e.toString()}", null);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 启动当前内容的交互会话
  Future<void> _startInteractionSession(
    ZhenduDetilEntity song,
    ZhenduPerformPlayerController playerController,
    String sessionId,
  ) async {
    await InteractionSessionManager.instance.startSession(
      InteractionSessionStartParams(
        owner: this,
        playerAdapter: GenericPlayerInteractionAdapter(playerController.player),
        sessionId: sessionId,
        source: 'zhendu_perform',
        type: type,
        typeId: typeId,
        styleId: song.contentInfo?.styleId,
        dialect: song.contentInfo?.dialect,
        learnType: ZhenduPageTypeEnum.perform.value,
        contentType: song.contentType ?? '',
        contentId: song.contentId ?? 0,
        duration: (song.contentInfo?.video?.duration ?? 0).toDouble(),
        config: InteractionSessionConfig(
          allowBackgroundActive: Platform.isWindows || Platform.isMacOS,
          allowLockScreenActive: Platform.isWindows || Platform.isMacOS,
        ),
      ),
    );
  }

  /// 停止当前页面的交互会话
  Future<void> _stopInteractionSession() async {
    await InteractionSessionManager.instance.stopSession(
      source: 'zhendu_perform',
    );
  }

  /// 按顺序停止播放记录和交互会话。
  Future<void> _stopPlayRecordAndInteractionSession() async {
    await PlayRecordManager.instance.stopTracking(source: 'zhendu_perform');
    await _stopInteractionSession();
  }

  /// 当前内容重新播放时，重新开启交互会话和播放记录追踪。
  Future<void> restartTrackingForReplay() async {
    final song = currentSong;
    if (song == null) return;

    final playerController = Get.find<ZhenduPerformPlayerController>(tag: tagText);
    await _stopInteractionSession();

    final String sessionId = InteractionSessionManager.instance.createSessionId();
    await _startInteractionSession(song, playerController, sessionId);

    await PlayRecordManager.instance.startTracking(
      player: playerController.player,
      contentType: song.contentType ?? '',
      contentId: song.contentId ?? 0,
      duration: (song.contentInfo?.video?.duration ?? 0).toDouble(),
      source: 'zhendu_perform',
      type: type,
      typeId: typeId,
      styleId: song.contentInfo?.styleId,
      dialect: song.contentInfo?.dialect,
      learnType: ZhenduPageTypeEnum.perform,
      sessionId: sessionId,
    );
  }

  /// 解析ass字幕
  Future<void> parseAssText() async{
    ZhenduDetilEntity? song = currentSong;
    if (song == null) return;
    String? assTextData = song.contentInfo?.video?.ass;
    if (assTextData == null) return;

    // 获取释义文本
    LanguageText? translateAss = song.contentInfo?.video?.localLanguageText;
    String? translateText = translateAss?.text;

    final ZhenduPerformPlayerController playerController = Get.find<ZhenduPerformPlayerController>(tag: tagText);

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

      playerController.subtitleList.add(PlayerAssData(
        sentence: assSentences[i],
        translate: translate,
      ));
    }
    
  }

  /// 点击ass句子，跳转到对应时间
  Future<void> changeAssIndex(PlayerAssData sentence, int sentenceIndex) async{
    if(sentence.sentence.sentenceStartTime == null) return;
    final ZhenduPerformPlayerController playerController = Get.find<ZhenduPerformPlayerController>(tag: tagText);
    await playerController.onSeek(Duration(milliseconds: sentence.sentence.sentenceStartTime??0));
    playerController.player.play();
  }
  



  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    try {
      unawaited(_stopPlayRecordAndInteractionSession());
    } catch (_) {
      
    }
    super.onClose();
  }
}
