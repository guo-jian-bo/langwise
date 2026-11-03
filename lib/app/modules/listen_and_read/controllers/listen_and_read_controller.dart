import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/favourite.dart';
import '../../../../common/https/https.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/public_controller/model/user_setting_model.dart';
import '../../../../common/widgets/add_favourite_dialog.dart';
import '../../../../common/widgets/player_widgets/player_jump_page_utils.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/karaoke_subtitles_utils.dart';
import '../../../../utils/play_record_utils/play_record_utils.dart';
import '../models/reading_ass_model.dart';
import 'listen_and_read_shadowing_controller.dart';
import '../../../routes/routes.dart';
import '../../../routes/routes_breadcrumb_utils.dart';

class ListenAndReadController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  ListenAndReadController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.LISTEN_AND_READ;

  @override
  String get breadcrumbTitle => "阅读";

  /// type: unit, favorite, collection, none
  String? type;
  int? typeId;
  /// 用作当前知识点的id
  int? contentId;
  /// 用作当前知识点的类型
  String? contentType;
  /// 用作当前知识点的语种
  String? dialect;
  /// 用作当前知识点的风格
  int? styleId;
  /// 用作当前知识点的语义
  int? semanticId;
  /// 是否是管理端的标识
  String? traceAdminHeader;


   int? milliseconds;
  /// 知识点参数 [{"contentId": 123, "contentType": "EN_SONG", "styleId": 1, "dialect": "en-US"}]
  List<Map<String, dynamic>>? contents;


  /// 页面脚手架key 用作打开抽屉(播放列表)
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();


  /// 是否是跟读
  final RxBool isShadowing = false.obs;
  
  AudioPlaybackUtils audioPlayerUtils = AudioPlaybackUtils();

  /// 当前进度
  final Rx<Duration> position = Duration.zero.obs;

  /// 当前音频总时长（底部控制条）
  final Rx<Duration> playerDuration = Duration.zero.obs;

  /// 播放速率
  final RxDouble playbackRate = 1.0.obs;

  /// 翻译状态
  final Rx<LangPreference> translateStatus = LangPreference.bilingual.obs;

  /// 文字大小
  final Rx<FontSizeEnum> contentFontSize = FontSizeEnum.standard.obs;

  /// 当前音量
  final RxInt volume = 100.obs;

  /// 播放顺序
  final Rx<PlayerModeEnum> playOrderStatus = PlayerModeEnum.single.obs;

  /// 每一曲播放次数
  final RxInt playOrderLoopCount = 1.obs;

  /// 当前播放的次数
  final RxInt currentPlayCount = 0.obs;

  /// 是否播放中
  final RxBool isPlaying = false.obs;

  /// 是否显示播放控制器
  final RxBool isShowAudioController = true.obs;
  Timer? isShowAudioControllerTimer;

  /// 获取当前播放的歌曲详情包装
  ZhenduDetilEntity? get currentSongDetail => songList.firstWhereOrNull((e) => getSongUniqueKeyBySong(e) == currentContentUniqueKey.value);

  /// 获取当前播放的歌曲内容
  SongEntityList? get currentSong => currentSongDetail?.contentInfo;

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


  final RxList<ZhenduDetilEntity> songList = <ZhenduDetilEntity>[].obs;

  /// 伪随机数池 用于随机播放
  final RxList<ZhenduDetilEntity> randomPoolIndices = <ZhenduDetilEntity>[].obs;

  /// 是否正在加载中
  final RxBool isLoadingData = false.obs;

  /// 一次加载10条
  final int pageSize = 50;

  /// 当前已加载的数据数量
  int _loadedCount = 0;

  /// 是否还有更多数据
  final RxBool hasMoreData = true.obs;

  final RxString currentContentUniqueKey = "".obs;

  /// 当前句子的id
  int currentSentenceId = (-1);

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
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
    playOrderStatus.value = setting?.playOrder ?? PlayerModeEnum.list;
    playOrderLoopCount.value = setting?.playOrderLoopCount ?? 1;
    contentFontSize.value = setting?.fontSize ?? FontSizeEnum.standard;
    volume.value = setting?.volume ?? 100;
    await audioPlayerUtils.setVolume(volume.value.toDouble());

    if(playbackMode != null){
      playOrderStatus.value = PlayerModeEnum.fromRawValue(playbackMode);
    }
  }

  /// 构建播放项唯一值：`contentId+semanticId+contentType+styleId+dialect`
  /// 各段允许为空，统一用空字符串占位，保证结构稳定。
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
  /// 这里会做基础类型兜底转换（int/double/string）。
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

  /// 获取数据 - 初始化时加载到当前位置+pageSize条
  Future<void> getSongData() async {
    if (contents == null) return ToastUtils.hideLoading();
    if (contents!.isEmpty) return ToastUtils.hideLoading();

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
        "learnType": ZhenduPageTypeEnum.read.value,
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
      _loadedCount = initialLoadCount;
      hasMoreData.value = _loadedCount < contents!.length;

      if(songList.isEmpty) return;
      
      
      parseAssText();
      switchSong(currentSongDetail ?? songList.first);
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
          "styleId": item["styleId"],
          "dialect": item["dialect"],
        });
      }

      Map<String, dynamic> reqData = {
        "contents": reqDataList,
      };
      Map<String, dynamic> reqParameters = {
        "learnType": ZhenduPageTypeEnum.read.value,
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
      _loadedCount = endIndex;
      hasMoreData.value = _loadedCount < contents!.length;
    } finally {
      isLoadingData.value = false;
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
      "learnType": ZhenduPageTypeEnum.read.value,
    };
    SongEntity? songEntity = await SongRequest.getPlayKnowledgeList(data: reqData, parameters: reqParameters, traceAdminHeader: traceAdminHeader);
    if (songEntity == null) return;
    List<SongEntityList?> list = songEntity.list ?? [];
    if(list.isEmpty) return;
    data.contentInfo = list.first;
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
    final index = contents!.indexWhere((item) => getSongUniqueKeyByContentItem(item) == targetKey);
    currentContentUniqueKey.value = index < 0 ? getSongUniqueKeyByContentItem(contents!.first) : getSongUniqueKeyByContentItem(contents![index]);
  }

  ///获取歌曲详情
  Future<ZhenduDetilEntity?> getSongDetail(ZhenduDetilEntity? data) async{
    if(data == null) return data;
    SongEntityList? dataInfo = data.contentInfo;

    if(Get.context != null && dataInfo?.cardRights != null){
      if(isShowLockDialog) return null;
      isShowLockDialog = true;
      bool res = await LockUtils.checkLock(
        dataInfo?.cardRights,
        Get.context!, 
        contentType: data.contentType,
        onPlaySuccess: () async{
          await refreshSingleSong(data);
        },
      );
      isShowLockDialog = false;
      if(res) return null;
    }

    if(dataInfo?.pronunciations != null){
      return data;
    }
    Map<String, dynamic> parameters = {
      "contentId": data.contentId,
      "contentType": data.contentType,
      "learnType": ZhenduPageTypeEnum.read.value,
      "styleId": data.contentInfo?.styleId,
      "dialect": data.contentInfo?.dialect,
    };
    try {
      ToastUtils.showLoading();
      ZhenduDetilEntity? songEntity = await SongRequest.getPlayKnowledgeInfoV2(parameters, traceAdminHeader: traceAdminHeader);
      if(songEntity == null || songEntity.contentInfo == null) return null;

      final targetUniqueKey = getSongUniqueKeyBySong(songEntity);
      for(int i = 0; i < songList.length; i++){
        if(targetUniqueKey == getSongUniqueKeyBySong(songList[i])){
          songEntity.globalKey = songList[i].globalKey;
          songList[i] = songEntity;
        }
      }

      for(int i = 0; i < randomPoolIndices.length; i++){
        if(targetUniqueKey == getSongUniqueKeyBySong(randomPoolIndices[i])){
          randomPoolIndices[i] = songEntity;
        }
      }
      
      return songEntity;
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
    playerDuration.value = Duration(seconds: (audioInfo?.duration ?? 0).toInt());
    position.value = Duration.zero;
    isPlaying.value = audioPlayerUtils.isPlaying;

    

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
      if (playerDuration.value == Duration.zero) {
        unawaited(audioPlayerUtils.getDuration().then((value) {
          playerDuration.value = value;
        }));
      }
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
      styleId: song.styleId,
      dialect: song.dialect,
      learnType: ZhenduPageTypeEnum.read,
    );
  }

  /// 播放完成事件
  void onPlayComplete(){
    
    cancelSentenceHighlight();
    cancelAssHighlight();
    if(audioPlayerUtils.isPlaying) return;
    
    /// 只有阅读才会处理下面的逻辑
    if(isShadowing.value) return;

    if (songList.isEmpty) return;

    // 播放完成时上报（使用歌曲总时长作为播放时长）
    final duration = currentSong?.audioInfo?.duration ?? 0;
    PlayRecordManager.instance.reportPlayComplete(duration.toDouble());

    // 单曲循环：无限次重播
    if (playOrderStatus.value == PlayerModeEnum.singleLoop) {
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
    if (playOrderStatus.value == PlayerModeEnum.random) {
      currentIndex = randomPoolIndices.indexWhere((e) => getSongUniqueKeyBySong(e) == currentContentUniqueKey.value);
    } else {
      currentIndex = songList.indexWhere((e) => getSongUniqueKeyBySong(e) == currentContentUniqueKey.value);
    }

    if (currentIndex < 0) currentIndex = 0;

    if (playOrderStatus.value == PlayerModeEnum.list) {
      int nextIndex = (currentIndex + 1) % songList.length;
      // 接近末尾时预加载更多数据
      if (nextIndex >= songList.length - 3) {
        loadData();
      }
      int? targetIndex = _findSupportedIndexByDirection(
        list: songList,
        currentIndex: currentIndex,
        direction: PlayerControllerDirection.next,
      );
      if (targetIndex == null) return;
      switchSong(songList[targetIndex]);
    } else if (playOrderStatus.value == PlayerModeEnum.random) {
      int nextIndex = (currentIndex + 1) % randomPoolIndices.length;
      if (nextIndex >= randomPoolIndices.length - 3) {
        loadData();
      }
      int? targetIndex = _findSupportedIndexByDirection(
        list: randomPoolIndices,
        currentIndex: currentIndex,
        direction: PlayerControllerDirection.next,
      );
      if (targetIndex == null) return;
      switchSong(randomPoolIndices[targetIndex]);
    }  else if (playOrderStatus.value == PlayerModeEnum.single) {
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
    // 不是阅读页面 不允许切换到下一曲
    if(isShadowing.value) return;

    prepareAudioControllerTimer();
    if (songList.isEmpty) return;
    if (playOrderStatus.value == PlayerModeEnum.random) {
      int currentIndex = randomPoolIndices.indexWhere((e) => getSongUniqueKeyBySong(e) == currentContentUniqueKey.value);
      if (currentIndex < 0) currentIndex = 0;

      int? targetIndex = _findSupportedIndexByDirection(
        list: randomPoolIndices,
        currentIndex: currentIndex,
        direction: PlayerControllerDirection.next,
      );
      if (targetIndex == null) return;
      switchSong(randomPoolIndices[targetIndex]);
    } else {
      int currentIndex = songList.indexWhere((e) => getSongUniqueKeyBySong(e) == currentContentUniqueKey.value);
      if (currentIndex < 0) currentIndex = 0;

      int nextIndex = (currentIndex + 1) % songList.length;
      // 接近末尾时预加载更多数据
      if (nextIndex >= songList.length - 3) {
        loadData();
      }
      int? targetIndex = _findSupportedIndexByDirection(
        list: songList,
        currentIndex: currentIndex,
        direction: PlayerControllerDirection.next,
      );
      if (targetIndex == null) return;
      switchSong(songList[targetIndex]);
    }
  }

  /// 上一曲
  Future<void> previousClick() async {
    // 不是阅读页面 不允许切换到下一曲
    if(isShadowing.value) return;

    prepareAudioControllerTimer();
    if (songList.isEmpty) return;

    if (playOrderStatus.value == PlayerModeEnum.random) {
      int currentIndex = randomPoolIndices.indexWhere((e) => getSongUniqueKeyBySong(e) == currentContentUniqueKey.value);
      if (currentIndex < 0) currentIndex = 0;

      int? targetIndex = _findSupportedIndexByDirection(
        list: randomPoolIndices,
        currentIndex: currentIndex,
        direction: PlayerControllerDirection.previous,
      );
      if (targetIndex == null) return;
      switchSong(randomPoolIndices[targetIndex]);
    } else {
      int currentIndex = songList.indexWhere((e) => getSongUniqueKeyBySong(e) == currentContentUniqueKey.value);
      if (currentIndex < 0) currentIndex = 0;

      int? targetIndex = _findSupportedIndexByDirection(
        list: songList,
        currentIndex: currentIndex,
        direction: PlayerControllerDirection.previous,
      );
      if (targetIndex == null) return;
      switchSong(songList[targetIndex]);
    }
  }

  /// 按方向循环查找可播放歌曲索引。
  /// 仅当 learnTypeSupport == false 时跳过；null/true 都视为可播放。
  int? _findSupportedIndexByDirection({
    required List<ZhenduDetilEntity> list,
    required int currentIndex,
    required PlayerControllerDirection direction,
  }) {
    if (list.isEmpty) return null;
    int index = currentIndex;
    for (int i = 0; i < list.length; i++) {
      if (direction == PlayerControllerDirection.next) {
        index = (index + 1) % list.length;
      } else {
        index = (index - 1 + list.length) % list.length;
      }
      final ZhenduDetilEntity song = list[index];
      if (song.contentInfo?.learnTypeSupport != false) {
        return index;
      }
    }
    return null;
  }

  /// 切换歌曲
  Future<void> switchSong(ZhenduDetilEntity song) async {
    // 不是阅读页面 不允许切换到下一曲
    if(isShadowing.value) return;
    
    // 在切换前获取当前播放位置，用于上报上一首的播放时长
    final lastPosition = await audioPlayerUtils.getCurrentPosition();
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
    currentPlayCount.value = 0;
    readingAssTextList.clear();
    _lastScrollParIndex = null;
    currentSentenceId = -1;

    await parseAssText();
    if(isClosed) return;
    await initAudioPlayer(lastPlayedSeconds: lastPlayedSeconds);
  }
  


  /// 设置播放模式
  void setPlayOrderStatus(PlayerModeEnum type) {
    if(playOrderStatus.value == type) return;
    playOrderStatus.value = type;
    currentPlayCount.value = 0;
    AudioControlUtils.saveSetting(AudioControlSettingModel(playOrder: type, playOrderLoopCount: playOrderLoopCount.value));
  }

  /// 设置播放循环次数
  void setPlayOrderLoopCount(int loopCount) {
    if(playOrderLoopCount.value == loopCount) return;
    playOrderLoopCount.value = loopCount;
    currentPlayCount.value = 0;
    // 保存设置
    AudioControlUtils.saveSetting(AudioControlSettingModel(playOrder: playOrderStatus.value, playOrderLoopCount: loopCount));
  }

  /// 改变音量
  Future<void> onVolumeChange(int value) async {
    volume.value = value;
    AudioControlUtils.saveSetting(AudioControlSettingModel(volume: value));
    await audioPlayerUtils.setVolume(value.toDouble());
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
        if(!isShadowing.value){
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
    String? content = song.content;
    // String? content = "Big news! Ships are indanger. Oilpricesgoupfast.\n\nThree ships are attacked near a waterway. Thiswaterwayiscalled the Strait of Hormuz. The ships are from different places. One ship has a fire. People on the ships are safe.\n\nOil prices jump high. This affects many countries. Everyone is watching.\n\nThe strait is very important. It carries much oil and gas. Now, ships stop moving. They wait outside the strait. This is a big problem.\n\nWhy is this happening? Iran says do not pass through. Other countries are involved. There is conflict in the Middle East.\n\nWe will watch for more news. Stay tuned.";
    if (content == null) return;
    String assTextData = song.audioInfo?.audioAss ?? "";
    // assTextData = "Dialogue: 0,0:00:0.00,0:00:3.46,Default,,0,0,0,,{\\k22}One {\\k34}sunny {\\k63}morning, {\\k22}Li {\\k21}Xue {\\k53}prepared {\\k96}breakfast.\nDialogue: 0,0:00:3.56,0:00:7.89,Default,,0,0,0,,{\\k32}Three {\\k36}bowls {\\k14}of {\\k62}porridge {\\k18}and {\\k25}three {\\k36}cups {\\k10}of {\\k28}soy {\\k48}milk {\\k36}sat {\\k7}on {\\k8}the {\\k67}table.\nDialogue: 0,0:00:8.44,0:00:10.79,Default,,0,0,0,,{\\k23}But {\\k8}the {\\k34}plate {\\k16}for {\\k38}steamed {\\k39}buns {\\k17}was {\\k60}empty.\nDialogue: 0,0:00:11.65,0:00:13.62,Default,,0,0,0,,{\\k33}Oh!{\\k13}{\\k25}Where {\\k17}are {\\k9}the {\\k40}steamed {\\k60}buns?\nDialogue: 0,0:00:13.79,0:00:14.92,Default,,0,0,0,,{\\k10}I {\\k23}put {\\k12}them {\\k23}right {\\k45}here.\nDialogue: 0,0:00:15.44,0:00:16.89,Default,,0,0,0,,{\\k48}Mom, {\\k22}where {\\k6}are {\\k11}the {\\k51}buns?\nDialogue: 0,0:00:16.99,0:00:17.94,Default,,0,0,0,,{\\k26}I’m {\\k69}hungry!\nDialogue: 0,0:00:18.04,0:00:19.65,Default,,0,0,0,,{\\k30}Drink {\\k11}your {\\k28}soy {\\k36}milk, {\\k21}Wang {\\k31}Lin.\nDialogue: 0,0:00:19.96,0:00:21.24,Default,,0,0,0,,{\\k19}I {\\k36}want {\\k20}my {\\k53}bun!\nDialogue: 0,0:00:21.60,0:00:22.87,Default,,0,0,0,,{\\k15}Did {\\k11}the {\\k39}puppy {\\k32}take {\\k30}them?\nDialogue: 0,0:00:23.55,0:00:24.28,Default,,0,0,0,,{\\k11}I {\\k1}don’t {\\k39}know.\nDialogue: 0,0:00:24.38,0:00:25.75,Default,,0,0,0,,{\\k1}Let’s {\\k26}look {\\k16}for {\\k32}them.\nDialogue: 0,0:00:26.92,0:00:30.26,Default,,0,0,0,,{\\k16}In {\\k8}the {\\k56}kitchen, {\\k27}Wang {\\k19}Jie {\\k23}and {\\k24}Wang {\\k21}Lin {\\k34}search {\\k15}for {\\k8}the {\\k63}buns.\nDialogue: 0,0:00:30.50,0:00:32.64,Default,,0,0,0,,{\\k31}Wang {\\k20}Zai {\\k65}follows, {\\k32}tail {\\k57}wagging.\nDialogue: 0,0:00:33.20,0:00:34.03,Default,,0,0,0,,{\\k28}Not {\\k55}here.\nDialogue: 0,0:00:34.59,0:00:36.72,Default,,0,0,0,,{\\k31}Just {\\k18}an {\\k45}empty {\\k41}plate {\\k11}and {\\k67}steamer.\nDialogue: 0,0:00:36.96,0:00:39.13,Default,,0,0,0,,{\\k25}Wang {\\k49}Zai, {\\k20}did {\\k13}you {\\k15}see {\\k12}the {\\k52}buns?\nDialogue: 0,0:00:39.52,0:00:42.18,Default,,0,0,0,,{\\k23}Wang {\\k24}Zai {\\k32}tilts {\\k15}his {\\k50}head {\\k17}and {\\k34}whines {\\k60}softly.\nDialogue: 0,0:00:43.04,0:00:44.37,Default,,0,0,0,,{\\k11}They {\\k32}check {\\k9}the {\\k42}living {\\k39}room.\nDialogue: 0,0:00:44.60,0:00:48.25,Default,,0,0,0,,{\\k33}Wang {\\k23}Zai {\\k49}sniffs {\\k50}Grandpa's {\\k27}chair {\\k1}and {\\k1}barks—Woof!{\\k111}{\\k70}Woof!\nDialogue: 0,0:00:48.76,0:00:50.15,Default,,0,0,0,,{\\k34}Maybe {\\k43}Grandpa {\\k26}took {\\k36}them?\nDialogue: 0,0:00:50.28,0:00:51.47,Default,,0,0,0,,{\\k16}He {\\k26}loves {\\k32}steamed {\\k45}buns.\nDialogue: 0,0:00:51.57,0:00:53.28,Default,,0,0,0,,{\\k1}Let’s {\\k31}find {\\k81}Grandpa!\nDialogue: 0,0:00:53.70,0:00:55.55,Default,,0,0,0,,{\\k14}They {\\k41}hurry {\\k25}out {\\k9}of {\\k11}the {\\k42}living {\\k43}room.\nDialogue: 0,0:00:56.63,0:00:59.95,Default,,0,0,0,,{\\k22}At {\\k60}Grandpa's {\\k54}room, {\\k30}Wang {\\k18}Jie {\\k50}pushes {\\k12}the {\\k57}door.\nDialogue: 0,0:01:0.05,0:01:1.12,Default,,0,0,0,,{\\k10}The {\\k27}bed {\\k18}is {\\k52}empty.\nDialogue: 0,0:01:1.22,0:01:3.05,Default,,0,0,0,,{\\k1}He’s {\\k34}not {\\k60}here.\nDialogue: 0,0:01:3.50,0:01:5.43,Default,,0,0,0,,{\\k18}Oh {\\k57}no.{\\k10}{\\k5}.{\\k10}{\\k6}.{\\k10}{\\k15}Where {\\k16}is {\\k45}he?\nDialogue: 0,0:01:5.91,0:01:8.60,Default,,0,0,0,,{\\k21}Wang {\\k22}Zai {\\k67}barks {\\k20}and {\\k28}runs {\\k32}toward {\\k6}the {\\k69}balcony.\nDialogue: 0,0:01:9.44,0:01:12.21,Default,,0,0,0,,{\\k17}On {\\k9}the {\\k88}balcony, {\\k12}they {\\k35}find {\\k42}Grandpa {\\k50}Wang.\nDialogue: 0,0:01:12.55,0:01:15.63,Default,,0,0,0,,{\\k15}The {\\k27}old {\\k30}man {\\k18}is {\\k30}eating {\\k6}a {\\k44}steamed {\\k55}bun, {\\k79}smiling.\nDialogue: 0,0:01:16.22,0:01:18.22,Default,,0,0,0,,{\\k93}Haha, {\\k21}you {\\k38}found {\\k31}me!\nDialogue: 0,0:01:18.64,0:01:20.11,Default,,0,0,0,,{\\k15}The {\\k35}buns {\\k32}smelled {\\k20}too {\\k45}good.\nDialogue: 0,0:01:20.47,0:01:21.21,Default,,0,0,0,,{\\k74}Grandpa!\nDialogue: 0,0:01:21.31,0:01:22.68,Default,,0,0,0,,{\\k18}You {\\k26}took {\\k23}all {\\k9}the {\\k57}buns!\nDialogue: 0,0:01:22.95,0:01:24.54,Default,,0,0,0,,{\\k11}We {\\k15}were {\\k43}looking {\\k82}everywhere!\nDialogue: 0,0:01:24.64,0:01:26.39,Default,,0,0,0,,{\\k56}I’m {\\k119}sorry.\nDialogue: 0,0:01:26.49,0:01:27.87,Default,,0,0,0,,{\\k19}But {\\k15}they {\\k14}are {\\k90}delicious.\nDialogue: 0,0:01:28.02,0:01:28.83,Default,,0,0,0,,{\\k53}Want {\\k28}one?\nDialogue: 0,0:01:29.36,0:01:34.63,Default,,0,0,0,,{\\k56}Grandpa {\\k38}Wang {\\k34}held {\\k16}out {\\k8}the {\\k67}plate, {\\k13}and {\\k8}the {\\k1}children’s {\\k50}faces {\\k22}lit {\\k17}up {\\k14}with {\\k86}smiles.\nDialogue: 0,0:01:35.69,0:01:40.51,Default,,0,0,0,,{\\k28}Back {\\k12}at {\\k9}the {\\k76}table, {\\k45}Grandpa {\\k57}Wang, {\\k36}Wang {\\k31}Jie {\\k13}and {\\k31}Wang {\\k34}Lin {\\k22}sit {\\k73}together.\nDialogue: 0,0:01:41.19,0:01:43.27,Default,,0,0,0,,{\\k17}The {\\k39}plate {\\k17}is {\\k23}full {\\k12}of {\\k41}steamed {\\k59}buns.\nDialogue: 0,0:01:43.84,0:01:45.38,Default,,0,0,0,,{\\k17}I {\\k37}brought {\\k10}the {\\k38}buns {\\k52}back.\nDialogue: 0,0:01:45.48,0:01:46.57,Default,,0,0,0,,{\\k61}Let’s {\\k48}eat!\nDialogue: 0,0:01:46.67,0:01:47.83,Default,,0,0,0,,{\\k24}Thank {\\k22}you, {\\k61}grandpa.\nDialogue: 0,0:01:47.96,0:01:48.95,Default,,0,0,0,,{\\k31}These {\\k11}are {\\k9}the {\\k48}best.\nDialogue: 0,0:01:49.20,0:01:51.16,Default,,0,0,0,,{\\k50}Yum!{\\k16}{\\k21}I {\\k34}love {\\k33}steamed {\\k42}buns.\nDialogue: 0,0:01:51.74,0:01:54.83,Default,,0,0,0,,{\\k9}The {\\k45}morning {\\k24}was {\\k23}full {\\k14}of {\\k75}laughter {\\k25}and {\\k31}warm {\\k60}buns.";

    // 获取释义文本
    LanguageText? translateAss = song.audioInfo?.translateAssText;
    String? translateText = translateAss?.text;
    List<AssSubtitle> translateSentences = [];
    if(translateText != null && translateText != ""){
      translateSentences = KaraokeSubtitlesUtils.parseAssTranslateDialogue(translateText);
    }

    List<SubtitlesSentenceModel> paragraphs = KaraokeSubtitlesUtils.parseAssSentenceByDialogue(assTextData);

    // 以text换行符拆分assText
    List<String> textList = content.split("\n");
    textList.removeWhere((element) => element.isEmpty);
    int countIndex = 0;
    int sentenceId = 0;
    for (int i = 0; i < textList.length; i++) {
      List<SubtitlesSentenceModel> textAss = KaraokeSubtitlesUtils.parseAssLineBreakByText(textList[i], paragraphs);
      final int consumedAssCount = textAss.where((e) => (e.dialogueText ?? '').isNotEmpty).length;
      if (consumedAssCount >= paragraphs.length) {
        paragraphs = [];
      } else if (consumedAssCount > 0) {
        paragraphs = paragraphs.sublist(consumedAssCount);
      }
      textAss.removeWhere((element) => element.words.isEmpty);

      List<ReadingAssSentenceModel> sentences = [];

      for (int j = 0; j < textAss.length; j++) {
        List<AssSubtitle> dialogue = textAss[j].words;

        ReadingAssWordModel? translateWordModel;
        if((textAss[j].dialogueText ?? '').isNotEmpty && translateSentences.isNotEmpty && countIndex < translateSentences.length){
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

  /// 切换阅读/跟读模式
  Future<void> toggleShadowingMode() async { 
    isShadowing.value = !isShadowing.value;
    playSentenceTimer?.cancel();
    Future.sync(() async {
      await audioPlayerUtils.seek(Duration.zero);
      await audioPlayerUtils.stop();
      cancelSentenceHighlight();
      cancelAssHighlight();
    });

    if(!isShadowing.value){ // 非跟读模式停止录音
      if (Get.isRegistered<ListenAndReadShadowingController>(tag: tagText)) {
        Get.find<ListenAndReadShadowingController>(tag: tagText).stopRecord();
      }
      isShowAudioControllerTimer?.cancel();
      isShowAudioController.value = true;
    }else{
      prepareAudioControllerTimer();
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
  void nextOrPreviousSentence(PlayerControllerDirection type) {
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
    if (type == PlayerControllerDirection.previous) {
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
  void toggleAudioControllerAlwaysShow(bool visible) {
    if(visible){
      isShowAudioControllerTimer?.cancel();
      isShowAudioController.value = true;
    }else{
      prepareAudioControllerTimer();
    }
  }

  /// 点击空白显示隐藏
  void toggleAudioController() {
    if(isShadowing.value){
      isShowAudioController.value = true;
      isShowAudioControllerTimer?.cancel();
      return; 
    }

    if(isShowAudioController.value){
      isShowAudioController.value = false;
      
    }else{
      prepareAudioControllerTimer();
    }
  }

  /// 倒计时音频控制器显示倒计时
  void prepareAudioControllerTimer() {
    if(isShadowing.value){
      isShowAudioController.value = true;
      isShowAudioControllerTimer?.cancel();
      return;
    }

    isShowAudioController.value = true;
    isShowAudioControllerTimer?.cancel();
    isShowAudioControllerTimer = Timer(const Duration(seconds: 5), () {
      isShowAudioController.value = false;
    });
  }


  /// 弹出错误反馈弹窗
  Future<void> showFeedbackErrorContentDialog(BuildContext context) async {

    await audioPlayerUtils.pause();

    Duration? position = await audioPlayerUtils.getCurrentPosition();
    SongEntityList? song = currentSong;

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
      var res = await FavouriteRequest.removeContent(
        playListId: 0, 
        uid: song.contentId!, 
        type: song.contentType!, 
        styleId: song.styleId, 
        dialect: song.dialect,
      );
      if (!res) {
        song.favorited = true;
      }
    } else {
      song.favorited = true;
      var res = await FavouriteRequest.addContent(
        playListId: 0, 
        uid: song.contentId!, 
        type: song.contentType!, 
        styleId: song.styleId, 
        dialect: song.dialect,
      );
      if (res) {
        AddFavouriteDialog.show(Get.context!, song.contentId!, song.contentType!, styleId: song.styleId, dialect: song.dialect);
      } else {
        song.favorited = false;
        ToastUtils.showToast(text: '收藏失败', type: ToastType.error);
      }
    }
    songList.refresh();
  }

/// 播放器页面类型切换（参考 song_mv）
  Future<void> onPageTypeChange(BuildContext context, ZhenduLearnItems value) async {
    ZhenduDetilEntity? song = currentSongDetail;
    if (song == null) return;
    if (song.contentId == null || song.contentType == null) return;
    if (contents == null || contents!.isEmpty) return;
    await audioPlayerUtils.stop();
    await PlayRecordManager.instance.stopTracking(source: 'listen_and_read');
    print('value.pageType${value.pageType}');
    print('song.contentId${song.contentId}');
    print("${song.contentType}");
    print("contents${contents}");
    print("PlayRecordPageType.fromValue(type)${PlayRecordPageType.fromValue(type)}");
    print('typeId${typeId}');
    

    await PlayerJumpPageUtils.jumpToPage(
      pageType: value.pageType,
      contentId: song.contentId,
      contentType: song.contentType,
      semanticId: null,
      styleId: song.contentInfo?.styleId,
      dialect: song.contentInfo?.dialect,
      contents: contents,
      type: PlayRecordPageType.fromValue(type),
      typeId: typeId,
      traceAdminHeader: traceAdminHeader,
    );
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
