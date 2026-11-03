import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/https/https.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/favourite.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/public_controller/model/user_setting_model.dart';
import '../../../../common/public_controller/mv_player_global_float_controller.dart';
import '../../../../common/widgets/add_favourite_dialog.dart';
import '../../../../common/widgets/image_animation_switcher/image_animation_switcher.dart';
import '../../../../common/widgets/player_widgets/player_jump_page_utils.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/karaoke_subtitles_utils.dart';
import '../../../../utils/play_record_utils/play_record_utils.dart';
import '../../../../utils/utils.dart';
import '../models/song_sentence_model.dart';

class SongMvController extends GetxController with WidgetsBindingObserver {

  static SongMvController get to => Get.find<SongMvController>();

  /// type: unit, favorite, collection, none
  String? type;

  int? typeId;

  /// 用作当前知识点的id
  int? contentId;
  /// 用作当前知识点的类型
  String? contentType;
  /// 用作当前知识点的语种id
  int? styleId;
  /// 用作当前知识点的语种id
  String? dialect;
  /// 用作当前知识点的语种id
  int? semanticId;
  /// 是否是管理端的标识
  String? traceAdminHeader;

  int? milliseconds;

  /// 知识点参数 [{"contentId": 123, "contentType": "EN_SONG"}]
  List<Map<String, dynamic>>? contents;


  /// 是否退出了页面
  final RxBool isExitPage = true.obs;
  int _playRequestSerial = 0;

  /// 所有数据
  final Rx<SongEntity> songData = SongEntity().obs;

  /// 歌曲列表
  final RxList<ZhenduDetilEntity> songList = <ZhenduDetilEntity>[].obs;

  /// 伪随机数池 用于随机播放
  final RxList<ZhenduDetilEntity> randomPoolIndices = <ZhenduDetilEntity>[].obs;

  /// 没有ass时候的句子列表
  final RxList<SongSentenceModel> noAssSentenceList = <SongSentenceModel>[].obs;

  /// 当前播放的歌曲的句子列表
  final RxList<SongSentenceModel> playSentenceList = <SongSentenceModel>[].obs;

  /// 当前播放的句子下标
  final RxInt playSentenceIndex = 0.obs;

  /// 当前播放句子中的单词下标
  final RxInt playWordIndex = (-1).obs;

  /// 歌词的准备结果 -1=未准备好 0=准备好了 1=没有歌词
  final RxInt lyricReadyResult = (-1).obs;

  /// 页面脚手架key 用作打开抽屉(播放列表)
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  /// 音频播放工具
  final AudioPlaybackUtils audioPlayerUtils = AudioPlaybackUtils();

  /// 播放速度
  final RxDouble playbackRate = 1.0.obs;

  /// 语言模式显示
  final Rx<LangPreference> audioControlTranslate = LangPreference.bilingual.obs;

  /// 播放模式
  final Rx<PlayerModeEnum> audioControlPlayOrder = PlayerModeEnum.list.obs;

  /// 循环次数
  final RxInt audioLoopCount = 1.obs;

  /// 当前播放的次数
  final RxInt currentPlayCount = 0.obs;

  /// 文字大小
  final Rx<FontSizeEnum> audioFontSize = FontSizeEnum.standard.obs;

  /// 当前音量
  final RxInt volume = 100.obs;

  /// 是否是播放状态
  final RxBool isPlaying = false.obs;

  /// 播放器总时长（底部控制条）
  final Rx<Duration> playerDuration = Duration.zero.obs;

  /// 播放器当前位置（底部控制条）
  final Rx<Duration> playerPosition = Duration.zero.obs;

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

  /// 当前播放歌曲唯一标识: contentId+semanticId+contentType+styleId+dialect
  final RxString currentContentUniqueKey = "".obs;

  /// 当前播放歌曲的信息
  ZhenduDetilEntity? get currentSong => songList.firstWhereOrNull((element) => getSongUniqueKeyBySong(element) == currentContentUniqueKey.value);

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
  


  /// 定时关闭类型
  final Rx<PlayerTimingEnum> playerTiming = PlayerTimingEnum.close.obs;

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
    try {
      ErrorLogUtils.to.logInfo('[SongMV] onInit start');
      WidgetsBinding.instance.addObserver(this);
      unawaited(initAudioPlayerEvent());
      listenerUserSettingshUserSettings();
      ErrorLogUtils.to.logInfo('[SongMV] onInit complete');
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] onInit error: $e', s);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(Platform.isAndroid || Platform.isIOS){
      _isAppInForeground = state == AppLifecycleState.resumed;
    }
  }

  void _resumeAudio(String scene) {
    unawaited(audioPlayerUtils.resume().catchError((e, s) {
      ErrorLogUtils.to.logError('[SongMV] $scene resume error: $e', s);
    }));
  }

  /// 没有参数的情况跳转进来
  void noParam() {
    try {
      ErrorLogUtils.to.logInfo('[SongMV] noParam start');
      startMenuShowTime();
      MvPlayerGlobalFloatController.to.hide();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          WakelockPlus.enable();
        } catch (e, s) {
          ErrorLogUtils.to.logError('[SongMV] noParam postFrameCallback error: $e', s);
        }
      });
      isExitPage.value = false;
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] noParam error: $e', s);
    }
  }

  /// 设置参数 跳转到这个页面之前需要设置
  Future<void> setParam(
    List<Map<String, dynamic>> contents, 
    {int? contentId, 
    String? contentType, 
    int? semanticId,
    int? styleId,
    String? dialect,
    int? milliseconds, 
    String? type, 
    int? typeId,
    String? traceAdminHeader,
  }) async{
    try {
      ErrorLogUtils.to.logInfo('[SongMV] setParam start, contentId=$contentId, contentType=$contentType, contentsLen=${contents.length}');
      this.contents = contents;
      this.contentId = contentId;
      this.contentType = contentType;
      this.milliseconds = milliseconds;
      this.type = type;
      this.typeId = typeId;
      this.semanticId = semanticId;
      this.styleId = styleId;
      this.dialect = dialect;
      this.traceAdminHeader = traceAdminHeader;

      currentContentUniqueKey.value = buildSongUniqueKey(
        contentId: contentId,
        semanticId: semanticId,
        contentType: contentType,
        styleId: styleId,
        dialect: dialect,
      );

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
      playWordIndex.value = -1;
      lyricReadyResult.value = -1;
      currentPlayCount.value = 0;
      currentKnowledgeList.clear();
      currentKnowledgeIndex.value = -1;
      if (contentId == null || contentType == null) {
        currentContentUniqueKey.value = "";
      }
      isShowKnowledgeList.value = false;
      isLoadingData.value = true;
      hasMoreData.value = true;

      isExitPage.value = false;

      await initAudioPlayerEvent();
      
      await getSongData();

      MvPlayerGlobalFloatController.to.toggleIsShowFloatButton(false);

      

      try {
        WakelockPlus.enable();
      } catch (e) {
        ErrorLogUtils.to.logError('[SongMV] setParam WakelockPlus.enable error: $e', null);
      }
      ErrorLogUtils.to.logInfo('[SongMV] setParam complete');
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] setParam error: $e', s);
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
  /// 当前 Song 详情中无 `semanticId` 字段，因此该段使用空值占位。
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

  /// 监听用户设置的倍速和显示模式
  void listenerUserSettingshUserSettings(){
    if(Get.isRegistered<ConfigController>()){
      ever(Get.find<ConfigController>().userSetting, (value) async {
        try {
          playbackRate.value = value.expandAudioSpeed;
          await audioPlayerUtils.setPlaybackRate(playbackRate.value);
          audioControlTranslate.value = value.expandLang;
        } catch (e, s) {
          ErrorLogUtils.to.logError('[SongMV] listenerUserSettingshUserSettings error: $e', s);
        }
      });
    }
    
  }

  /// 返回页面
  void back() {
    try {
      MvPlayerGlobalFloatController.to.toggleIsShowFloatButton(true);
      WakelockPlus.disable();
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] back error: $e', s);
    }
  }

  /// 停止播放
  Future<void> stop({bool isStopB = false}) async{
    try {
      ErrorLogUtils.to.logInfo('[SongMV] stop start');
      try { WakelockPlus.disable(); } catch (e) { ErrorLogUtils.to.logError('[SongMV] stop WakelockPlus.disable error: $e', null); }
      if(isStopB){
        await audioPlayerUtils.stopB();
      }else{
        await audioPlayerUtils.stop();
      }
      
      await PlayRecordManager.instance.stopTracking(source: 'song_mv');
      isPlaying.value = false;
      await _cancelAudioPlayerEventSubs();
      _cancelTimingCloseTask();
      isExitPage.value = true;
      ErrorLogUtils.to.logInfo('[SongMV] stop complete');
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] stop error: $e', s);
    }
  }

  /// 监听音频事件
  Future<void> initAudioPlayerEvent() async {
    try {
      ErrorLogUtils.to.logInfo('[SongMV] initAudioPlayerEvent start');
      await _cancelAudioPlayerEventSubs();
      ErrorLogUtils.to.logInfo('[SongMV] initAudioPlayerEvent cancelSubs done');
      playerDuration.value = await audioPlayerUtils.getDuration();
      playerPosition.value = await audioPlayerUtils.getCurrentPosition();
      isPlaying.value = audioPlayerUtils.isPlaying;

      AudioControlSettingModel? setting = AudioControlUtils.getSetting();
      audioControlPlayOrder.value = setting?.playOrder ?? PlayerModeEnum.list;
      audioLoopCount.value = setting?.playOrderLoopCount ?? 1;
      audioFontSize.value = setting?.fontSize ?? _fontSizeFromMultiple(setting?.fontSizeMultiple ?? 1.0);
      volume.value = setting?.volume ?? 100;
      await audioPlayerUtils.setVolume(volume.value.toDouble());
      ErrorLogUtils.to.logInfo('[SongMV] initAudioPlayerEvent readSetting done');

      _completeSub = audioPlayerUtils.playCompleteStream.listen((event) async {
        try {
          ErrorLogUtils.to.logInfo('[SongMV] playCompleteStream event=$event');
          playCompleteHandle();
        } catch (e, s) {
          ErrorLogUtils.to.logError('[SongMV] playCompleteStream callback error: $e', s);
        }
      }, onError: (e, s) {
        ErrorLogUtils.to.logError('[SongMV] playCompleteStream onError: $e', s);
      });

      _pauseResumeSub = audioPlayerUtils.pauseResumeStream.listen((event) {
        try {
          isPlaying.value = event;
          if (Get.isRegistered<MvPlayerGlobalFloatController>()) {
            MvPlayerGlobalFloatController.to.toggleIsPlayingOnly(event);
          }
        } catch (e, s) {
          ErrorLogUtils.to.logError('[SongMV] pauseResumeStream callback error: $e', s);
        }
      }, onError: (e, s) {
        ErrorLogUtils.to.logError('[SongMV] pauseResumeStream onError: $e', s);
      });

      _positionSub = audioPlayerUtils.positionStream.listen((event) {
        try {
          playerPosition.value = event;
          if (playerDuration.value == Duration.zero) {
            unawaited(audioPlayerUtils.getDuration().then((value) {
              playerDuration.value = value;
            }));
          }
          if (!audioPlayerUtils.isPlaying) return;
          int mill = event.inMilliseconds;
          
          // 只在前台时更新UI相关的歌词高亮，后台只更新锁屏歌词
          if (_isAppInForeground) {
            playHighlightWord(mill);
          } else {
            _updateLockScreenLyricOnly(mill);
          }

          ZhenduDetilEntity? song = songList.firstWhereOrNull((element) => getSongUniqueKeyBySong(element) == currentContentUniqueKey.value);

          if(song?.contentInfo != null && Get.isRegistered<MvPlayerGlobalFloatController>()){
            MvPlayerGlobalFloatController.to.setProgress(
              Duration(seconds: (song!.contentInfo?.audioInfo?.duration ?? 0).toInt()), 
              event,
            );
          }
        } catch (e, s) {
          ErrorLogUtils.to.logError('[SongMV] positionStream callback error: $e', s);
        }
      }, onError: (e, s) {
        ErrorLogUtils.to.logError('[SongMV] positionStream onError: $e', s);
      });

      if (Get.isRegistered<MvPlayerGlobalFloatController>()) {
        _floatButtonStatusSub = MvPlayerGlobalFloatController.to.playPauseEventStreamController.listen((playing) async {
          try {
            if(playing){
              _resumeAudio('floatButtonStatusSub');
            }else{
              await audioPlayerUtils.pause();
            }
          } catch (e, s) {
            ErrorLogUtils.to.logError('[SongMV] floatButtonStatusSub callback error: $e', s);
          }
        }, onError: (e, s) {
          ErrorLogUtils.to.logError('[SongMV] floatButtonStatusSub onError: $e', s);
        });
      } else {
        ErrorLogUtils.to.logInfo('[SongMV] initAudioPlayerEvent skip floatButton listener: controller not registered');
      }
      ErrorLogUtils.to.logInfo('[SongMV] initAudioPlayerEvent complete');
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] initAudioPlayerEvent error: $e', s);
    }
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
        "learnType": ZhenduPageTypeEnum.listen.value,
      };

      SongEntity? songEntity = await SongRequest.getPlayKnowledgeList(data: reqData, parameters: reqParameters, traceAdminHeader: traceAdminHeader);
      if (songEntity == null) return;
      songData.value = songEntity;
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
      
      getCurrentParamIndex();
      await startPlaySong();
      startMenuShowTime();
    } finally {
      isLoadingData.value = false;
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

      Map<String, dynamic> reqParameters = {
        "learnType": ZhenduPageTypeEnum.listen.value,
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

  /// 开始播放
  /// [lastPlayedSeconds] 上一首的播放时长（秒），切换歌曲时传入
  Future<void> initAudioPlayer({double? lastPlayedSeconds}) async {
    try {
      final int requestSerial = ++_playRequestSerial;
      ErrorLogUtils.to.logInfo('[SongMV] initAudioPlayer start, currentUniqueKey=${currentContentUniqueKey.value}');
      ZhenduDetilEntity? song;
      if (audioControlPlayOrder.value == PlayerModeEnum.random) {
        song = randomPoolIndices.firstWhereOrNull((element) => getSongUniqueKeyBySong(element) == currentContentUniqueKey.value);
      } else {
        song = songList.firstWhereOrNull((element) => getSongUniqueKeyBySong(element) == currentContentUniqueKey.value);
      }
      if(song == null) {
        ErrorLogUtils.to.logInfo('[SongMV] initAudioPlayer song is null, return');
        return;
      }

      SongEntityList? songInfo = song.contentInfo;
      PronunciationsEntity? audioInfo = songInfo?.audioInfo;
      String? audioUrl = audioInfo?.audioUrl;
      ErrorLogUtils.to.logInfo('[SongMV] initAudioPlayer audioUrl=${audioUrl != null ? "exists(${audioUrl.length} chars)" : "null"}, duration=${audioInfo?.duration}');
      playerPosition.value = Duration.zero;
      playerDuration.value = Duration(seconds: (audioInfo?.duration ?? 0).toInt());

      if (audioUrl == null) {
        audioPlayerUtils.prepare(url: "");
        audioPlayerUtils.stop();
        return;
      }

      playSentenceIndex.value = 0;
      playWordIndex.value = -1;
      await audioPlayerUtils.pause();
      // await audioPlayerUtils.seek(Duration.zero);
      // 切歌时后续会 prepare 新音源，这里不再提前 seek，避免 Windows 卡住。
     

      ErrorLogUtils.to.logInfo('[SongMV] initAudioPlayer prepare start');
      await audioPlayerUtils.prepare(
        url: audioUrl,
        title: songInfo?.title ?? "",
        playSpeed: playbackRate.value,
        showSkipControls: true,
        artist: songInfo?.title ?? "",
        duration: Duration(seconds: (audioInfo?.duration ?? 0).toInt()),
      );
      ErrorLogUtils.to.logInfo('[SongMV] initAudioPlayer prepare done');
      if (requestSerial != _playRequestSerial || isExitPage.value) {
        ErrorLogUtils.to.logInfo('[SongMV] initAudioPlayer prepare done but request canceled, skip auto resume');
        return;
      }

      audioPlayerUtils.setNavigationHandlers(
        onNext: () async => nextClick(),
        onPrevious: () async => previousClick(),
      );

      initFirstKnowledge();

      ErrorLogUtils.to.logInfo('[SongMV] initAudioPlayer resume start');

      if(milliseconds != null){
        await Future.delayed(const Duration(milliseconds: 80));
        if (requestSerial != _playRequestSerial || isExitPage.value) {
          ErrorLogUtils.to.logInfo('[SongMV] initAudioPlayer delayed seek canceled, skip auto resume');
          return;
        }
        ErrorLogUtils.to.logInfo('[SongMV] initAudioPlayer seek to $milliseconds ms');
        await audioPlayerUtils.seek(Duration(milliseconds: milliseconds!));
        _resumeAudio('initAudioPlayer');
        milliseconds = null;
      }else{
        if (requestSerial != _playRequestSerial || isExitPage.value) {
          ErrorLogUtils.to.logInfo('[SongMV] initAudioPlayer request canceled before resume, skip auto resume');
          return;
        }
        _resumeAudio('initAudioPlayer');
      }
      
      playSentenceIndex.value = 0;
      playWordIndex.value = -1;

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
        styleId: song.contentInfo?.styleId ?? 0,
        dialect: song.contentInfo?.dialect ?? "",
        learnType: ZhenduPageTypeEnum.listen,
      );
      ErrorLogUtils.to.logInfo('[SongMV] initAudioPlayer complete');
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] initAudioPlayer error: $e', s);
    }
  }

  /// 歌词着色 并更新后台歌词
  void playHighlightWord(int mill) {
    if (playSentenceList.isEmpty) return;
    int targetSentenceIndex = -1;
    int targetWordIndex = -1;

    for (int i = 0; i < playSentenceList.length; i++) {
      SongSentenceModel item = playSentenceList[i];
      if ((item.startTime ?? 0) <= mill && (item.endTime ?? 0) >= mill) {
        targetSentenceIndex = i;
        List<AssSubtitle> sentence = item.sentence;
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

    if (targetSentenceIndex == -1) {
      if (playWordIndex.value != -1) {
        playWordIndex.value = -1;
      }
      return;
    }

    if (playSentenceIndex.value != targetSentenceIndex || playSentenceIndex.value == 0) {
      playSentenceIndex.value = targetSentenceIndex;
      audioPlayerUtils.updateLyric(playSentenceList[targetSentenceIndex].sentenceText);
    }
    if (playWordIndex.value != targetWordIndex) {
      playWordIndex.value = targetWordIndex;
    }
  }

    /// 刷新制定歌曲
  Future<void> refreshSingleSong(ZhenduDetilEntity? data) async{
    if(data == null) return;
    List<Map<String, dynamic>> reqDataList = [{
      "uid": data.contentId,
      "type": data.contentType,
      "styleId": data.contentInfo?.styleId,
      "dialect": data.contentInfo?.dialect,
    }];
    Map<String, dynamic> reqData = {
      "contents": reqDataList,
    };
    Map<String, dynamic> reqParameters = {
      "learnType": ZhenduPageTypeEnum.listen.value,
    };
    SongEntity? songEntity = await SongRequest.getPlayKnowledgeList(data: reqData, parameters: reqParameters, traceAdminHeader: traceAdminHeader);
    if (songEntity == null) return;
    List<SongEntityList?> list = songEntity.list ?? [];
    if(list.isEmpty) return;
    data.contentInfo = list.first;
  }


  ///获取歌曲详情
  Future<ZhenduDetilEntity?> getSongDetail(ZhenduDetilEntity? data) async{
    if(data == null) return data;
    SongEntityList? dataInfo = data.contentInfo;

    try {
      ErrorLogUtils.to.logInfo('[SongMV] getSongDetail start, contentId=${data.contentId}, hasCardRights=${dataInfo?.cardRights != null}, hasPronunciations=${dataInfo?.pronunciations != null}');
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
        "learnType": ZhenduPageTypeEnum.listen.value,
        "styleId": data.contentInfo?.styleId,
        "dialect": data.contentInfo?.dialect,
      };
      try {
        isSwitchLoadingUI.value = true;
        ErrorLogUtils.to.logInfo('[SongMV] getSongDetail requesting detail from server');
        ZhenduDetilEntity? songEntity = await SongRequest.getPlayKnowledgeInfoV2(parameters, traceAdminHeader: traceAdminHeader);
        if(songEntity == null || songEntity.contentInfo == null) {
          ErrorLogUtils.to.logInfo('[SongMV] getSongDetail server returned null');
          return null;
        }

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

        if(Get.currentRoute != Routes.SONG_MV){
          MvPlayerGlobalFloatController.to.toggleIsShowFloatButton(true);
        }
        
        ErrorLogUtils.to.logInfo('[SongMV] getSongDetail complete, hasAudioInfo=${songEntity.contentInfo?.audioInfo != null}');
        return songEntity;
      } finally{
        isSwitchLoadingUI.value = false;
      }
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] getSongDetail error: $e', s);
      return null;
    }
  }

  /// 开始播放歌曲
  /// [lastPlayedSeconds] 上一首的播放时长（秒），切换歌曲时传入
  Future<void> startPlaySong({double? lastPlayedSeconds}) async{
    try {
      ErrorLogUtils.to.logInfo('[SongMV] startPlaySong start, currentUniqueKey=${currentContentUniqueKey.value}');
      ZhenduDetilEntity? song;
      if (audioControlPlayOrder.value == PlayerModeEnum.random) {
        song = randomPoolIndices.firstWhereOrNull((element) => getSongUniqueKeyBySong(element) == currentContentUniqueKey.value);
      } else {
        song = songList.firstWhereOrNull((element) => getSongUniqueKeyBySong(element) == currentContentUniqueKey.value);
      }
      if(song == null) {
        ErrorLogUtils.to.logInfo('[SongMV] startPlaySong song is null, return');
        return;
      }

      ErrorLogUtils.to.logInfo('[SongMV] startPlaySong getSongDetail start');
      song = await getSongDetail(song);
      if(song == null) {
        ErrorLogUtils.to.logInfo('[SongMV] startPlaySong getSongDetail returned null, return');
        return;
      }

      SongEntityList? songInfo = song.contentInfo;
      if (songInfo == null) return;
      /// 获取当前播放歌曲的相关知识点
      List<SongEntityListSubContentList?> subContentList = songInfo.contentList ?? [];

      PronunciationsEntity? audioInfo = songInfo.audioInfo;

      /// 获取ass
      String? audioAss = audioInfo?.audioAss;
      String? translateAss = audioInfo?.translateAssText?.text;
      ErrorLogUtils.to.logInfo('[SongMV] startPlaySong parseAss, hasAss=${audioAss != null && audioAss.isNotEmpty}, hasTranslate=${translateAss != null && translateAss.isNotEmpty}');
      
      playSentenceList.clear();
      noAssSentenceList.clear();
      if (audioAss != null && audioAss != "") {
        List<SubtitlesSentenceModel> assSentences = KaraokeSubtitlesUtils.parseAssSentenceByDialogue(audioAss);
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
            lyric += sub.rightSpace;
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
        List<String> contentList = songInfo.content?.split("\n") ?? [];
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
              leftSpace: i == 0 ? "" : " ",
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

      ErrorLogUtils.to.logInfo('[SongMV] startPlaySong initAudioPlayer, sentenceCount=${playSentenceList.length}');
      initAudioPlayer(lastPlayedSeconds: lastPlayedSeconds);
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] startPlaySong error: $e', s);
    }
  }

  /// 播放完成的处理
  void playCompleteHandle() async {
    try {
    ErrorLogUtils.to.logInfo('[SongMV] playCompleteHandle start, songListLen=${songList.length}, isPlaying=${audioPlayerUtils.isPlaying}');
    if (songList.isEmpty) return;
    if (audioPlayerUtils.isPlaying) return;

    // 播放完成时上报（使用歌曲总时长作为播放时长）
    final duration = currentSong?.contentInfo?.audioInfo?.duration ?? 0;
    PlayRecordManager.instance.reportPlayComplete(duration.toDouble());

    // 检查首数倒计时
      if (_timingCloseSongCount > 0) {
      _checkSongCountTimingClose();
        if (_timingCloseSongCount <= 0) {
        // 倒计时结束，不再切换下一首
        return;
      }
    }

    if (audioControlPlayOrder.value == PlayerModeEnum.singleLoop) {
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
    if (audioControlPlayOrder.value == PlayerModeEnum.random) {
      currentIndex = randomPoolIndices.indexWhere((e) => getSongUniqueKeyBySong(e) == currentContentUniqueKey.value);
    } else {
      currentIndex = songList.indexWhere((e) => getSongUniqueKeyBySong(e) == currentContentUniqueKey.value);
    }

    if (currentIndex < 0) currentIndex = 0;

    if (audioControlPlayOrder.value == PlayerModeEnum.list) {
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
    } else if (audioControlPlayOrder.value == PlayerModeEnum.random) {
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
    } else if (audioControlPlayOrder.value == PlayerModeEnum.single) {
      return;
    }
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] playCompleteHandle error: $e', s);
    }
  }

  /// 暂停恢复播放
  Future<void> pausePlayback() async {
    try {
      ErrorLogUtils.to.logInfo('[SongMV] pausePlayback start, isPlaying=${audioPlayerUtils.isPlaying}');
      if (audioPlayerUtils.isPlaying) {
        await audioPlayerUtils.pause();
      }else{
        playSentenceIndex.value = 0;
      
        Duration position = await audioPlayerUtils.getCurrentPosition();
        Duration duration = await audioPlayerUtils.getDuration();
        ErrorLogUtils.to.logInfo('[SongMV] pausePlayback position=${position.inMilliseconds}ms, duration=${duration.inMilliseconds}ms');

        if(duration.inMilliseconds - 100 <= position.inMilliseconds){
          switchSong(currentSong);
          return;
          
        }

        _resumeAudio('pausePlayback');
      }

      startMenuShowTime();
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] pausePlayback error: $e', s);
    }
  }

  /// 下一曲
  Future<void> nextClick() async {
    try {
      ErrorLogUtils.to.logInfo('[SongMV] nextClick start');
      startMenuShowTime();
      if (songList.isEmpty) return;
      if (audioControlPlayOrder.value == PlayerModeEnum.random) {
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
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] nextClick error: $e', s);
    }
  }

  /// 上一曲
  Future<void> previousClick() async {
    try {
      ErrorLogUtils.to.logInfo('[SongMV] previousClick start');
      startMenuShowTime();
      if (songList.isEmpty) return;

      if (audioControlPlayOrder.value == PlayerModeEnum.random) {
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
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] previousClick error: $e', s);
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

  /// 上一句
  Future<void> previousSentenceClick() async {
    try {
      startMenuShowTime();
      if (playSentenceList.isEmpty) return;
      if (playSentenceIndex.value <= 0) return;
      playSentenceIndex.value--;
      playWordIndex.value = -1;
      Duration duration = Duration(milliseconds: playSentenceList[playSentenceIndex.value].startTime??0);
      await audioPlayerUtils.pause();
      await audioPlayerUtils.seek(duration);
      clearAssHighlight();
      await Future.delayed(const Duration(milliseconds: 500));
      _resumeAudio('previousSentenceClick');
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] previousSentenceClick error: $e', s);
    }
  }

  /// 下一句
  Future<void> nextSentenceClick() async {
    try {
      startMenuShowTime();
      if (playSentenceList.isEmpty) return;
      if (playSentenceIndex.value >= playSentenceList.length - 1) return;
      playSentenceIndex.value++;
      playWordIndex.value = -1;
      Duration duration = Duration(milliseconds: playSentenceList[playSentenceIndex.value].startTime??0);
      await audioPlayerUtils.pause();
      await audioPlayerUtils.seek(duration);
      clearAssHighlight();
      await Future.delayed(const Duration(milliseconds: 500));
      _resumeAudio('nextSentenceClick');
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] nextSentenceClick error: $e', s);
    }
  }

  /// 根据句子数据播放这一句
  Future<void> playForSentence(SongSentenceModel sentence, int sentenceIndex) async {
    try {
      startMenuShowTime();
      playSentenceIndex.value = sentenceIndex;
      playWordIndex.value = -1;
      Duration duration = Duration(milliseconds: sentence.startTime??0);
      await audioPlayerUtils.pause();
      await audioPlayerUtils.seek(duration);
      clearAssHighlight();
      await Future.delayed(const Duration(milliseconds: 500));
      _resumeAudio('playForSentence');
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] playForSentence error: $e', s);
    }
  }

  /// 重新播放
  Future<void> restartPlayback() async {
    try {
      ErrorLogUtils.to.logInfo('[SongMV] restartPlayback start');
      playSentenceIndex.value = 0;
      playWordIndex.value = -1;

      await audioPlayerUtils.seek(Duration.zero);
      _resumeAudio('restartPlayback');
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] restartPlayback error: $e', s);
    }
  }

  /// 初始化的时候获取第一张知识点
  void initFirstKnowledge() {
    if(currentKnowledgeList.isEmpty){
      // 没有知识点使用默认图片
      
      ZhenduDetilEntity? song = songList.firstWhereOrNull((element) => getSongUniqueKeyBySong(element) == currentContentUniqueKey.value);
      if(song == null) return;
      String? defaultImageUrl = song.contentInfo?.imageUrl;
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
  void onMenuShow(bool visible) {
    if (visible) {
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
      isShowMenu.value = false;
    });
  }

  /// 歌曲列表的打开与关闭
  void toggleDrawer() {
    if (scaffoldKey.currentState == null) return;
    scaffoldKey.currentState!.openEndDrawer();
  }

  /// 切换歌曲
  Future<void> switchSong(ZhenduDetilEntity? song) async {
    try {
      if (song == null || song.contentId == null) {
        ErrorLogUtils.to.logInfo('[SongMV] switchSong song or contentId is null, return');
        return;
      }

      ErrorLogUtils.to.logInfo('[SongMV] switchSong start, targetContentId=${song.contentId}, title=${song.contentInfo?.title}');

      // 在切换前获取当前播放位置，用于上报上一首的播放时长
      final lastPosition = await audioPlayerUtils.getCurrentPosition();
      final lastPlayedSeconds = lastPosition.inMilliseconds / 1000.0;

      song = await getSongDetail(song);
      if(song == null) {
        ErrorLogUtils.to.logInfo('[SongMV] switchSong getSongDetail returned null, return');
        return;
      }

      lyricReadyResult.value = (-1);
      
      currentContentUniqueKey.value = getSongUniqueKeyBySong(song);
      isShowKnowledgeList.value = false;
      
      currentPlayCount.value = 0;
      currentKnowledgeIndex.value = (-1);

      await startPlaySong(lastPlayedSeconds: lastPlayedSeconds);

      ErrorLogUtils.to.logInfo('[SongMV] switchSong complete');
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] switchSong error: $e', s);
    }
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
        _resumeAudio('openSmallDictionary_emptyWordInfo');
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
      _resumeAudio('openSmallDictionary');
    }

  }

  /// 获取句子中单词的解析
  Future<void> getSentenceWordAss(SongSentenceModel sentence) async {
    if (sentence.wordInfos != null) return;
    String sentenceText = "";

    for (int i = 0; i < sentence.sentence.length; i++) {
      sentenceText += sentence.sentence[i].leftSpace;
      sentenceText += sentence.sentence[i].text;
      sentenceText += sentence.sentence[i].rightSpace;
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
    bool hasSelectedWord = false;
    for (int i = 0; i < playSentenceList.length; i++) {
      SongSentenceModel item = playSentenceList[i];
      if (item.selectedWordIndex != -1) {
        hasSelectedWord = true;
      }
      item.selectedWordIndex = (-1);
    }
    if (playWordIndex.value != -1) {
      playWordIndex.value = -1;
    }
    if (hasSelectedWord) {
      playSentenceList.refresh();
    }
  }


  /// 弹出错误反馈弹窗
  Future<void> showFeedbackErrorContentDialog(BuildContext context) async {

    menuShowTimer?.cancel();
    menuShowTimer = null;
    isShowMenu.value = true;

    await audioPlayerUtils.pause();

    ZhenduDetilEntity? song = songList.firstWhereOrNull((element) => getSongUniqueKeyBySong(element) == currentContentUniqueKey.value);
    if(song == null) {
      ErrorLogUtils.to.logInfo('[SongMV] showFeedbackErrorContentDialog song not found for contentId=${currentContentUniqueKey.value}');
      startMenuShowTime();
      return;
    }
    SongEntityList? songInfo = song.contentInfo;
    if(songInfo == null) return;
    Duration position = await audioPlayerUtils.getCurrentPosition();
    await FeedbackErrorContentDialog.show(
      context: context, 
      position: position,
      name: songInfo.title, 
      content: songInfo.content, 
      contentType: song.contentType, 
      contentId: song.contentId,
    );

    startMenuShowTime();
  }

  Future<void> toggleFavourite() async {
    startMenuShowTime();
    ZhenduDetilEntity? song = songList.firstWhereOrNull((element) => getSongUniqueKeyBySong(element) == currentContentUniqueKey.value);
    if(song == null) return;
    if(song.contentId == null || song.contentType == null) return;
    SongEntityList? songInfo = song.contentInfo;
    if(songInfo == null) return;
    
    if (songInfo.isFavorite) {
      //todo:取消收藏
      songInfo.favorited = false;
      var res = await FavouriteRequest.removeContent(
        playListId: 0, 
        uid: song.contentId!, 
        type: song.contentType!, 
        styleId: songInfo.styleId, 
        dialect: songInfo.dialect,
      );
      if (!res) {
        songInfo.favorited = true;
      }
    } else {
      songInfo.favorited = true;
      var res = await FavouriteRequest.addContent(
        playListId: 0, 
        uid: song.contentId!, 
        type: song.contentType!, 
        styleId: songInfo.styleId, 
        dialect: songInfo.dialect,
      );
      if (res) {
        AddFavouriteDialog.show(Get.context!, song.contentId!, song.contentType!, styleId: songInfo.styleId, dialect: songInfo.dialect);
      } else {
        songInfo.favorited = false;
        ToastUtils.showToast(text: '收藏失败', type: ToastType.error);
      }
    }
    songList.refresh();
  }

  /// 播放器页面类型切换
  Future<void> onPageTypeChange(BuildContext context, ZhenduLearnItems value) async{
    ZhenduDetilEntity? song = currentSong;
    if(song == null) return;
    if(song.contentId == null || song.contentType == null) return;
    if(contents == null || contents!.isEmpty) return;
    await audioPlayerUtils.stop();
    await PlayerJumpPageUtils.jumpToPage(
      pageType: value.pageType,
      contentId: song.contentId,
      contentType: song.contentType,
      styleId: song.contentInfo?.styleId,
      dialect: song.contentInfo?.dialect,
      semanticId: null,
      contents: contents,
      type: PlayRecordPageType.fromValue(type),
      typeId: typeId,
      traceAdminHeader: traceAdminHeader,
    );
  }

  /// 定时播放
  Future<void> onPlayerTimingChange(PlayerTimingEnum value) async{
    _startTimingCloseTask(value);
  }

  /// 改变音量
  Future<void> onVolumeChange(int value) async{
    volume.value = value;
    AudioControlUtils.saveSetting(AudioControlSettingModel(volume: value));
    await audioPlayerUtils.setVolume(value.toDouble());
  }

  /// 开始定时关闭任务
  void _startTimingCloseTask(PlayerTimingEnum timing) {
    // 先取消之前的定时任务
    _cancelTimingCloseTask();
    playerTiming.value = timing;

    switch (timing) {
      case PlayerTimingEnum.minutes15:
        _timingCloseRemainingSeconds = 15 * 60;
        _updateTimingCloseDisplay();
        _timingCloseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _timingCloseRemainingSeconds--;
          if (_timingCloseRemainingSeconds <= 0) {
            unawaited(_executeTimingClose());
          } else {
            _updateTimingCloseDisplay();
          }
        });
        break;
      case PlayerTimingEnum.minutes30:
        _timingCloseRemainingSeconds = 30 * 60;
        _updateTimingCloseDisplay();
        _timingCloseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _timingCloseRemainingSeconds--;
          if (_timingCloseRemainingSeconds <= 0) {
            unawaited(_executeTimingClose());
          } else {
            _updateTimingCloseDisplay();
          }
        });
        break;
      case PlayerTimingEnum.minutes60:
        _timingCloseRemainingSeconds = 60 * 60;
        _updateTimingCloseDisplay();
        _timingCloseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _timingCloseRemainingSeconds--;
          if (_timingCloseRemainingSeconds <= 0) {
            unawaited(_executeTimingClose());
          } else {
            _updateTimingCloseDisplay();
          }
        });
        break;
      case PlayerTimingEnum.complete:
        _timingCloseSongCount = 1;
        timingCloseDisplayStr.value = "剩余$_timingCloseSongCount首";
        break;
      case PlayerTimingEnum.complete2:
        _timingCloseSongCount = 2;
        timingCloseDisplayStr.value = "剩余$_timingCloseSongCount首";
        break;
      case PlayerTimingEnum.complete3:
        _timingCloseSongCount = 3;
        timingCloseDisplayStr.value = "剩余$_timingCloseSongCount首";
        break;
      case PlayerTimingEnum.close:
        playerTiming.value = PlayerTimingEnum.close;
        break;
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
  Future<void> _executeTimingClose() async {
    try {
      _cancelTimingCloseTask();
      playerTiming.value = PlayerTimingEnum.close;
      await audioPlayerUtils.pause();
      isPlaying.value = false;
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] _executeTimingClose error: $e', s);
    }
  }

  /// 检查首数倒计时（在播放完成时调用）
  void _checkSongCountTimingClose() {
    if (_timingCloseSongCount <= 0) return;
    _timingCloseSongCount--;
    if (_timingCloseSongCount <= 0) {
      unawaited(_executeTimingClose());
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
    try {
      ErrorLogUtils.to.logInfo('[SongMV] onClose start');
      WidgetsBinding.instance.removeObserver(this);
      PlayRecordManager.instance.stopTracking(source: 'song_mv');
      _cancelTimingCloseTask();
      ErrorLogUtils.to.logInfo('[SongMV] onClose complete');
      isExitPage.value = true;
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] onClose error: $e', s);
    }
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

  Future<void> _cancelAudioPlayerEventSubs() async {
    try {
      await _completeSub?.cancel();
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] cancel _completeSub error: $e', s);
    } finally {
      _completeSub = null;
    }
    try {
      await _positionSub?.cancel();
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] cancel _positionSub error: $e', s);
    } finally {
      _positionSub = null;
    }
    try {
      await _pauseResumeSub?.cancel();
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] cancel _pauseResumeSub error: $e', s);
    } finally {
      _pauseResumeSub = null;
    }
    try {
      await _floatButtonStatusSub?.cancel();
    } catch (e, s) {
      ErrorLogUtils.to.logError('[SongMV] cancel _floatButtonStatusSub error: $e', s);
    } finally {
      _floatButtonStatusSub = null;
    }
  }

  FontSizeEnum _fontSizeFromMultiple(double multiple) {
    if (multiple <= 0.84) return FontSizeEnum.extraSmall;
    if (multiple <= 0.92) return FontSizeEnum.small;
    if (multiple <= 1.0) return FontSizeEnum.standard;
    if (multiple <= 1.08) return FontSizeEnum.large;
    if (multiple <= 1.16) return FontSizeEnum.extraLarge;
    return FontSizeEnum.extraExtraLarge;
  }
}
