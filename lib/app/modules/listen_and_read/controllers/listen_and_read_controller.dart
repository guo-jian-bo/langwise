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

    try {
      ToastUtils.showLoading();
      await parseAssText();
      if(isClosed) return;
      await initAudioPlayer(lastPlayedSeconds: lastPlayedSeconds);
    } finally{
      ToastUtils.hideLoading();
    }
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
    // String? content = "Listen. Hear that sound? Boom, boom, boom! It is a drum. Splash, splash! It is water. Look at the boats. They have many colors. Red, green, and blue. They are dragon boats.\nA dragon boat is long. It is not wide. It has a big head like a dragon. The head has bright colors. The tail has colors too. Many people sit in the boat. They use long wood sticks to move. They move fast. They move to the sound of the drum. Boom, boom, go! Splash, splash, move! The water jumps and shines in the sun.\nDragon boat racing is fun. It is loud and full of life. It tells a story from long ago. It joins all people together with sound.\nLong, long ago, people made this race. They lived by a big river. They wanted rain for their rice cake. They made boats and hit drums. They said, \"Rain, please come!\" This made them very happy. It was a good way to live.\nBut then, for some years, the drums were quiet. All people forgot the boats. The sound was gone. It was a sad time. No more splashes. No more cheers. The water was very quiet.\nThen, the sound came back! In Hong Kong, people thought of the old ways. They brought back the boats. They said, \"Let us race again!\" Now, many lands have dragon boats. China has many, many racers. Every summer, a lot of people come to Hong Kong. They race with big smiles.\nThe drum beats. The water splashes. The colors are bright. This is the sound of dragon boat racing. It is a sound of joy. It is a story from the past. Listen. Can you hear it?";
    if (content == null) return;
    String assTextData = song.audioInfo?.audioAss ?? "";
    // assTextData = "Dialogue:0,0:00:1.75,0:00:5.13,Default,,0,0,0,,{\\k59}Listen.{\\k165}{\\k28}Hear{\\k26}that{\\k60}sound?\nDialogue:0,0:00:5.76,0:00:9.48,Default,,0,0,0,,{\\k42}Boom,{\\k65}boom,{\\k112}boom!{\\k10}{\\k12}It{\\k13}is{\\k5}a{\\k50}drum.\nDialogue:0,0:00:10.12,0:00:13.20,Default,,0,0,0,,{\\k83}Splash,{\\k84}splash!{\\k51}{\\k15}It{\\k15}is{\\k45}water.\nDialogue:0,0:00:14.12,0:00:14.91,Default,,0,0,0,,{\\k18}Look{\\k9}at{\\k7}the{\\k45}boats.\nDialogue:0,0:00:15.01,0:00:16.26,Default,,0,0,0,,{\\k30}They{\\k16}have{\\k30}many{\\k49}colors.\nDialogue:0,0:00:16.36,0:00:18.22,Default,,0,0,0,,{\\k35}Red,{\\k55}green,{\\k16}and{\\k52}blue.\nDialogue:0,0:00:18.86,0:00:20.30,Default,,0,0,0,,{\\k23}They{\\k14}are{\\k55}dragon{\\k52}boats.\nDialogue:0,0:00:22.25,0:00:23.69,Default,,0,0,0,,{\\k12}A{\\k51}dragon{\\k28}boat{\\k16}is{\\k37}long.\nDialogue:0,0:00:23.79,0:00:24.77,Default,,0,0,0,,{\\k7}It{\\k13}is{\\k23}not{\\k55}wide.\nDialogue:0,0:00:25.62,0:00:27.78,Default,,0,0,0,,{\\k13}It{\\k19}has{\\k5}a{\\k42}big{\\k28}head{\\k22}like{\\k4}a{\\k83}dragon.\nDialogue:0,0:00:27.88,0:00:29.33,Default,,0,0,0,,{\\k15}The{\\k27}head{\\k19}has{\\k38}bright{\\k46}colors.\nDialogue:0,0:00:29.43,0:00:31.09,Default,,0,0,0,,{\\k4}The{\\k50}tail{\\k21}has{\\k44}colors{\\k47}too.\nDialogue:0,0:00:31.42,0:00:33.03,Default,,0,0,0,,{\\k30}Many{\\k36}people{\\k34}sit{\\k10}in{\\k9}the{\\k42}boat.\nDialogue:0,0:00:33.28,0:00:35.37,Default,,0,0,0,,{\\k23}They{\\k36}use{\\k35}long{\\k25}wood{\\k42}sticks{\\k12}to{\\k36}move.\nDialogue:0,0:00:35.47,0:00:36.49,Default,,0,0,0,,{\\k10}They{\\k28}move{\\k64}fast.\nDialogue:0,0:00:36.60,0:00:38.90,Default,,0,0,0,,{\\k35}They{\\k42}move{\\k12}to{\\k11}the{\\k49}sound{\\k10}of{\\k11}the{\\k60}drum.\nDialogue:0,0:00:39.30,0:00:41.10,Default,,0,0,0,,{\\k48}Boom,{\\k50}boom,{\\k48}go!\nDialogue:0,0:00:41.24,0:00:43.88,Default,,0,0,0,,{\\k93}Splash,{\\k91}splash,{\\k57}move!\nDialogue:0,0:00:44.16,0:00:46.50,Default,,0,0,0,,{\\k9}The{\\k45}water{\\k46}jumps{\\k12}and{\\k61}shines{\\k6}in{\\k10}the{\\k45}sun.\nDialogue:0,0:00:47.88,0:00:49.59,Default,,0,0,0,,{\\k46}Dragon{\\k31}boat{\\k39}racing{\\k20}is{\\k35}fun.\nDialogue:0,0:00:50.11,0:00:51.91,Default,,0,0,0,,{\\k14}It{\\k15}is{\\k44}loud{\\k13}and{\\k24}full{\\k12}of{\\k57}life.\nDialogue:0,0:00:52.20,0:00:54.55,Default,,0,0,0,,{\\k12}It{\\k41}tells{\\k5}a{\\k62}story{\\k26}from{\\k31}long{\\k57}ago.\nDialogue:0,0:00:54.78,0:00:57.16,Default,,0,0,0,,{\\k17}It{\\k48}joins{\\k16}all{\\k39}people{\\k45}together{\\k22}with{\\k51}sound.\nDialogue:0,0:00:57.81,0:01:1.62,Default,,0,0,0,,{\\k53}Long,{\\k28}long{\\k44}ago,{\\k30}people{\\k34}made{\\k22}this{\\k30}race.\nDialogue:0,0:01:1.72,0:01:3.56,Default,,0,0,0,,{\\k38}They{\\k39}lived{\\k18}by{\\k9}a{\\k37}big{\\k40}river.\nDialogue:0,0:01:3.75,0:01:5.86,Default,,0,0,0,,{\\k21}They{\\k36}wanted{\\k38}rain{\\k18}for{\\k13}their{\\k48}rice{\\k37}cake.\nDialogue:0,0:01:6.01,0:01:7.73,Default,,0,0,0,,{\\k23}They{\\k28}made{\\k44}boats{\\k13}and{\\k15}hit{\\k49}drums.\nDialogue:0,0:01:7.83,0:01:10.74,Default,,0,0,0,,{\\k9}They{\\k34}said,{\\k105}\"Rain,{\\k46}please{\\k80}come!\"\nDialogue:0,0:01:10.84,0:01:12.26,Default,,0,0,0,,{\\k21}This{\\k27}made{\\k14}them{\\k34}very{\\k46}happy.\nDialogue:0,0:01:12.66,0:01:14.25,Default,,0,0,0,,{\\k14}It{\\k18}was{\\k6}a{\\k37}good{\\k23}way{\\k12}to{\\k49}live.\nDialogue:0,0:01:14.49,0:01:18.43,Default,,0,0,0,,{\\k76}But{\\k48}then,{\\k10}for{\\k28}some{\\k53}years,{\\k8}the{\\k40}drums{\\k15}were{\\k46}quiet.\nDialogue:0,0:01:18.53,0:01:20.04,Default,,0,0,0,,{\\k15}All{\\k38}people{\\k49}forgot{\\k8}the{\\k41}boats.\nDialogue:0,0:01:20.14,0:01:21.24,Default,,0,0,0,,{\\k4}The{\\k46}sound{\\k22}was{\\k38}gone.\nDialogue:0,0:01:21.55,0:01:22.65,Default,,0,0,0,,{\\k6}It{\\k19}was{\\k4}a{\\k54}sad{\\k27}time.\nDialogue:0,0:01:22.80,0:01:23.82,Default,,0,0,0,,{\\k16}No{\\k21}more{\\k65}splashes.\nDialogue:0,0:01:23.92,0:01:24.83,Default,,0,0,0,,{\\k10}No{\\k20}more{\\k61}cheers.\nDialogue:0,0:01:25.16,0:01:26.83,Default,,0,0,0,,{\\k12}The{\\k36}water{\\k27}was{\\k32}very{\\k60}quiet.\nDialogue:0,0:01:27.59,0:01:29.91,Default,,0,0,0,,{\\k60}Then,{\\k6}the{\\k41}sound{\\k27}came{\\k34}back!\nDialogue:0,0:01:30.01,0:01:32.48,Default,,0,0,0,,{\\k5}In{\\k32}Hong{\\k38}Kong,{\\k34}people{\\k33}thought{\\k10}of{\\k15}the{\\k27}old{\\k28}ways.\nDialogue:0,0:01:32.58,0:01:33.62,Default,,0,0,0,,{\\k4}They{\\k30}brought{\\k25}back{\\k7}the{\\k38}boats.\nDialogue:0,0:01:33.72,0:01:35.54,Default,,0,0,0,,{\\k6}They{\\k40}said,{\\k19}\"Let{\\k16}us{\\k32}race{\\k47}again!\"\nDialogue:0,0:01:35.66,0:01:37.95,Default,,0,0,0,,{\\k47}Now,{\\k52}many{\\k43}lands{\\k15}have{\\k41}dragon{\\k28}boats.\nDialogue:0,0:01:38.05,0:01:40.08,Default,,0,0,0,,{\\k36}China{\\k23}has{\\k35}many,{\\k33}many{\\k57}racers.\nDialogue:0,0:01:40.32,0:01:43.32,Default,,0,0,0,,{\\k28}Every{\\k43}summer,{\\k15}a{\\k21}lot{\\k13}of{\\k30}people{\\k31}come{\\k14}to{\\k35}Hong{\\k41}Kong.\nDialogue:0,0:01:43.55,0:01:45.30,Default,,0,0,0,,{\\k15}They {\\k36}race {\\k19}with {\\k33}big {\\k72}smiles.\nDialogue:0,0:01:46.77,0:01:47.75,Default,,0,0,0,,{\\k15}The{\\k33}drum{\\k50}beats.\nDialogue:0,0:01:48.29,0:01:49.40,Default,,0,0,0,,{\\k13}The{\\k33}water{\\k65}splashes.\nDialogue:0,0:01:49.50,0:01:50.62,Default,,0,0,0,,{\\k7}The{\\k49}colors{\\k9}are{\\k47}bright.\nDialogue:0,0:01:50.92,0:01:53.14,Default,,0,0,0,,{\\k23}This{\\k9}is{\\k10}the{\\k47}sound{\\k13}of{\\k42}dragon{\\k27}boat{\\k51}racing.\nDialogue:0,0:01:53.29,0:01:54.83,Default,,0,0,0,,{\\k15}It{\\k13}is{\\k5}a{\\k50}sound{\\k15}of{\\k56}joy.\nDialogue:0,0:01:55.01,0:01:56.88,Default,,0,0,0,,{\\k14}It{\\k13}is{\\k5}a{\\k53}story{\\k22}from{\\k10}the{\\k70}past.\nDialogue:0,0:01:57.46,0:01:59.49,Default,,0,0,0,,{\\k142}Listen.{\\k10}{\\k11}Can{\\k10}you{\\k28}hear{\\k1}it?";

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
      // audioPlayerUtils.stopB();
      // audioPlayerUtils.prepare(url: "");

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
