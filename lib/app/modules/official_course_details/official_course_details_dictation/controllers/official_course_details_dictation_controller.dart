import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/icon_dropdown_widget.dart';
import 'package:lib_common/common.dart';
import 'package:video_player/video_player.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/public_controller/model/user_setting_model.dart';
import '../../../../../common/values/values.dart';
import '../../../../../utils/utils.dart';
import '../views/official_course_details_dictation_setting_dialog.dart';

class OfficialCourseDetailsDictationController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  OfficialCourseDetailsDictationController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.OFFICIAL_COURSE_DETAILS_DICTATION;

  @override
  String get breadcrumbTitle => "听写";

  String? moduleName; //书名称
  String? unitName; //单元名称

  /// 知识点列表参数
  List<UnitKnowledgePointsEntityKnowledgeList>? knowledgeListArgs = [];

  /// 知识点列表
  final RxList<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = <UnitKnowledgePointsEntityKnowledgeList>[].obs;

  /// 播放次数
  final Rx<int> playNum = 1.obs;

  /// 当前播放次数
  final Rx<int> currentPlayNum = 0.obs;

  /// 停顿间隔
  final Rx<double> pauseInterval = 10.0.obs;

  /// 播放速度
  final Rx<double> playSpeed = 1.0.obs;

  /// 播放模式
  final Rx<PlayerModeEnum> playMode = PlayerModeEnum.order.obs;

  // 播放进度
  RxInt progress = 0.obs;

  /// 播放状态
  RxBool playStatus = false.obs;

  /// 播放音量
  final RxInt volume = 100.obs;

  /// 默写是否完成
  RxBool isDictationComplete = false.obs;

  /// 再听一遍
  RxBool isListenAgain = false.obs;

  /// 英音、美音
  final Rx<LanguageServiceCodeEnum> national = LanguageServiceCodeEnum.US.obs;

  late AudioPlaybackUtils audioPlaybackUtils;

  StreamSubscription? _playerCompleteSubscription; //音频播放完成的流订阅

  /// 播放完成后延时切换用的定时器
  Timer? _playCompleteTimer;

  RxInt totalDurationTime = 0.obs; //总时长

  /// 是否正在切换音频，防止并发 prepare 导致 just_audio 崩溃
  bool _isSwitchingAudio = false;

  /// 等待中的下一首（在频繁点击时只保留最后一次请求）
  UnitKnowledgePointsEntityKnowledgeList? _pendingAudioModel;

  /// * 语言显示设置菜单
  final List<IconDropdownCheckData<String>> learLangShowSettingMenu = [
    IconDropdownCheckData<String>(value: "US", title: "美音"),
    IconDropdownCheckData<String>(value: "UK", title: "英音"),
  ];

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    HardwareKeyboard.instance.addHandler(_handleGlobalKeyEvent);
    List<double> intervalList = Get.find<ConfigController>().userSetting.value.intervalMenu!.map((e) => e.value!).toList();
    if (intervalList.isEmpty) {
      pauseInterval.value = 5;
    } else {
      pauseInterval.value = StorageUtil().getDouble(INTERVAL_SPEED_KEY) ?? intervalList.first;
      var _idx = intervalList.indexOf(pauseInterval.value);
      if (_idx == -1) {
        pauseInterval.value = intervalList.first;
      }
    }

    initUserSetting();
    audioPlaybackUtils = AudioPlaybackUtils();
    national.value = LanguageServiceCodeEnum.fromValue(UserStore.to.userInfo.value.config?.national);

    if (Get.arguments != null) {
      moduleName = Get.arguments["moduleName"];
      unitName = Get.arguments["unitName"];
      knowledgeListArgs = List<UnitKnowledgePointsEntityKnowledgeList>.from(Get.arguments["knowledgeList"]);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) {
        playSetting(isFirst: true);
      }
    });
  }

    /// 获取本地储存的设置
  Future<void> initUserSetting() async{
    if(Get.isRegistered<ConfigController>()){
      UserSettingModel userSetting = Get.find<ConfigController>().userSetting.value;
      playSpeed.value = userSetting.expandAudioSpeed;
    }

    AudioControlSettingModel? setting = AudioControlUtils.getSetting();
    volume.value = setting?.volume ?? 100;
  }

  @override
  void onClose() {
    super.onClose();
    HardwareKeyboard.instance.removeHandler(_handleGlobalKeyEvent);
    audioPlaybackUtils.stop();
    audioPlaybackUtils.dispose();
    audioPlaybackUtils.setNavigationHandlers(onNext: null, onPrevious: null);
    _playerCompleteSubscription?.cancel();
    _playCompleteTimer?.cancel();
    _playCompleteTimer = null;
    ToastUtils.hideLoading();
  }

  /// 初始化音频播放器
  void audioPlayerInit() {
    audioPlaybackUtils.setNavigationHandlers(
      onNext: () => nextProgress(),
      onPrevious: () => preProgress(),
    );
    audioPlaybackUtils.setPlaybackRate(playSpeed.value);
    _playerCompleteSubscription?.cancel();
    _playCompleteTimer?.cancel();
    _playerCompleteSubscription = audioPlaybackUtils.playCompleteStream.listen((state) {
      if (audioPlaybackUtils.isPlaying) return;
      // 播放完成沿用你已有的逻辑
      int durationTime;
      if (currentPlayNum.value < playNum.value - 1) {
        // 同一个知识点内部的重复，一律 1s 间隔
        durationTime = 1000;
      } else {
        // 最后一次播放完，切到下一个知识点，用设置里的停顿间隔
        durationTime = (totalDurationTime.value * pauseInterval.value).toInt();
      }
      int oldProgress = progress.value;
      _playCompleteTimer?.cancel();
      _playCompleteTimer = Timer(Duration(milliseconds: durationTime), () async {
        if (isClosed) {
          return;
        }

        if (isListenAgain.value) {
          isListenAgain.value = false;
        }

        currentPlayNum.value++;
        if (playStatus.value && oldProgress == progress.value) {
          if (currentPlayNum.value >= playNum.value) {
            if (progress.value < knowledgeList.length - 1) {
              currentPlayNum.value = 0;
              progress.value++;
              newAudioPlayer(knowledgeList[progress.value]);
            } else {
              playStatus.value = false;
              await audioPlaybackUtils.stop();
              isDictationComplete.value = true;
            }
          } else {
            newAudioPlayer(knowledgeList[progress.value]);
          }
        }
      });
    });
  }

  /// 设置新的音频
  Future<void> newAudioPlayer(UnitKnowledgePointsEntityKnowledgeList? model) async {
    if (model == null || isClosed) return;

    // 如果当前正在切换音频，则只记录最新的一次请求，等当前切换完成再处理
    if (_isSwitchingAudio) {
      _pendingAudioModel = model;
      return;
    }

    _isSwitchingAudio = true;
    _pendingAudioModel = null;

    PronunciationsEntity? pronunciationModel;
    for (PronunciationsEntity? item in model.pronunciations ?? []) {
      if (item?.national == national.value.value) {
        pronunciationModel = item;
        break;
      }
    }

    String urlString = pronunciationModel?.audioUrl ?? '';
    if (urlString.isEmpty) {
      _isSwitchingAudio = false;
      nextProgress();
      return;
    }

    try {
      //获取音频总时长
      totalDurationTime.value = pronunciationModel?.duration != null ? (pronunciationModel!.duration! * 1000).toInt() : 0;

      // 串行化 stop + prepare，避免在还没处理完前再次 prepare
      await audioPlaybackUtils.stop();

      // 提供锁屏信息（可按需丰富）
      await audioPlaybackUtils.prepare(
        url: urlString,
        title: '听写模式',
        artist: moduleName ?? '',
        album: unitName ?? '',
        playSpeed: playSpeed.value,
        duration: Duration(milliseconds: totalDurationTime.value),
        image: model.imageUrl != null ? Uri.tryParse(model.imageUrl!) : null,
        androidCompactActionIndices: const [0, 1, 2],
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (!isClosed) {
        audioPlaybackUtils.resume();
        playStatus.value = true;
      }
    } catch (e) {
      debugPrint('dictation newAudioPlayer error: $e');
    } finally {
      _isSwitchingAudio = false;

      final nextModel = _pendingAudioModel;
      if (nextModel != null && !isClosed) {
        _pendingAudioModel = null;
        unawaited(newAudioPlayer(nextModel));
      }
    }
  }

  //播放 暂停
  void audioPlayAndPause(bool status) async {
    if (status) {
      await audioPlaybackUtils.resume();
      playStatus.value = true;
    } else {
      await audioPlaybackUtils.pause();
      playStatus.value = false;
    }
  }

  // knowledgeListArgs 原参
  // knowledgeList 当前播放列表
  // progress 当前播放下标（已播放区间为 [0, progress]）
  void changePlayMode(PlayerModeEnum mode) {
    if (knowledgeListArgs == null || knowledgeListArgs!.isEmpty) return;

    playMode.value = mode;

    // 已播放区间：从当前播放列表中取 [0, progress]，保证切换顺序时这些保持不变
    final int playedEndIndex = progress.value.clamp(0, (knowledgeList.length - 1).clamp(0, knowledgeList.length));
    final List<UnitKnowledgePointsEntityKnowledgeList> played =
        knowledgeList.isNotEmpty ? knowledgeList.sublist(0, playedEndIndex + 1) : <UnitKnowledgePointsEntityKnowledgeList>[];

    // 剩余未播放区间：从原始列表中过滤掉已播放的项，然后按不同模式重组
    final List<UnitKnowledgePointsEntityKnowledgeList> baseRemain = knowledgeListArgs!.where((e) => !played.contains(e)).toList();

    List<UnitKnowledgePointsEntityKnowledgeList> reorderedRemain;
    if (playMode.value == PlayerModeEnum.order) {
      reorderedRemain = baseRemain;
    } else if (playMode.value == PlayerModeEnum.reverse) {
      reorderedRemain = baseRemain.reversed.toList();
    } else {
      reorderedRemain = baseRemain.toList();
      reorderedRemain.shuffle();
    }

    knowledgeList.value = <UnitKnowledgePointsEntityKnowledgeList>[...played, ...reorderedRemain];
    // progress 仍然指向同一条（位置不变），无需重置 currentPlayNum / audioPlayerInit
  }

  Future<void> changePlayNum(int loopCount) async {
    if (playNum.value > loopCount) {
      playNum.value = loopCount;
    } else {
      playNum.value = loopCount;
      currentPlayNum.value = 0;
      await audioPlaybackUtils.stop();
      audioPlayerInit();
      newAudioPlayer(knowledgeList[progress.value]);
    }
  }

  void changePlaySpeed(double speed) {
    playSpeed.value = speed;
    audioPlaybackUtils.setPlaybackRate(speed);
    ConfigController configController = Get.find<ConfigController>();
    configController.setUserSetting(expandAudioSpeed: speed);
  }

  /// 修改播放音量
  Future<void> onVolumeChange(int value) async{
    volume.value = value;
    await audioPlaybackUtils.setVolume(value.toDouble());
    AudioControlUtils.saveSetting(AudioControlSettingModel(volume: value));
  }

  void setLanguageSetting(String nationalCode) {
    national.value = LanguageServiceCodeEnum.fromValue(nationalCode);
  }

  /// 播放设置
  void playSetting({bool isFirst = false}) async {
    if (knowledgeListArgs == null) return;

    audioPlayAndPause(false);

    List<UnitKnowledgePointsEntityKnowledgeList> words = [];
    List<UnitKnowledgePointsEntityKnowledgeList> phrases = [];
    List<UnitKnowledgePointsEntityKnowledgeList> sentences = [];

    for (int i = 0; i < knowledgeListArgs!.length; i++) {
      if(knowledgeListArgs![i].pronunciations == null) continue;
      if (knowledgeListArgs![i].isWord) {
        words.add(knowledgeListArgs![i]);
      } else if (knowledgeListArgs![i].isPhrase) {
        phrases.add(knowledgeListArgs![i]);
      } else if (knowledgeListArgs![i].isSentence) {
        sentences.add(knowledgeListArgs![i]);
      }
    }

    List<DictationSettingKnowledgeTypeItemModel> knowledgePoints = [];
    if (words.isNotEmpty) {
      knowledgePoints.add(DictationSettingKnowledgeTypeItemModel(
        type: ElementsCardType.word,
        typeText: '单词',
        count: words.length,
      ));
    }
    if (phrases.isNotEmpty) {
      knowledgePoints.add(DictationSettingKnowledgeTypeItemModel(
        type: ElementsCardType.phrase,
        typeText: '短语',
        count: phrases.length,
      ));
    }
    if (sentences.isNotEmpty) {
      knowledgePoints.add(DictationSettingKnowledgeTypeItemModel(
        type: ElementsCardType.sentence,
        typeText: '句子',
        count: sentences.length,
      ));
    }

    DictationSettingModel? newGraph = await OfficialCourseDetailsDictationSettingDialog.show(
      context: Get.context!,
      initSetting: DictationSettingModel(
        knowledgePoints: knowledgePoints,
        selectedKnowledgePoints: knowledgePoints.map((e) => e.type).toList(),
        playNum: playNum.value,
        pauseInterval: pauseInterval.value,
        playOrder: playMode.value,
        national: national.value,
      ),
    );

    if (isFirst) {
      if (newGraph == null) {
        Get.back();
        return;
      } else {
        audioPlayerInit();
      }
    } else {
      if (newGraph == null) return;
    }

    playStatus.value = false;
    await audioPlaybackUtils.stop();
    currentPlayNum.value = 0;
    progress.value = 0;
    isDictationComplete.value = false;

    playNum.value = newGraph.playNum;
    pauseInterval.value = newGraph.pauseInterval;
    StorageUtil().setDouble(INTERVAL_SPEED_KEY, pauseInterval.value);
    playMode.value = newGraph.playOrder;
    national.value = newGraph.national;

    if (playMode.value == PlayerModeEnum.order) {
      knowledgeList.value = knowledgeListArgs!.toList();
    } else if (playMode.value == PlayerModeEnum.reverse) {
      final list = knowledgeListArgs!.toList();
      knowledgeList.value = list.reversed.toList();
    } else {
      final list = knowledgeListArgs!.toList();
      list.shuffle();
      knowledgeList.value = list;
    }
    knowledgeList.removeWhere((element) => !newGraph.selectedKnowledgePoints.contains(element.cardType));
    newAudioPlayer(knowledgeList.first);
  }

  /// 上一个
  Future<void> preProgress() async {
    debugPrint('上一个被点击');
    if (progress.value > 0) {
      isListenAgain.value = true;
      currentPlayNum.value = 0;
      progress.value--;
      newAudioPlayer(knowledgeList[progress.value]);
    } else {
      ToastUtils.showToast(text: '当前已是第一个');
    }
  }

  /// 下一个
  Future<void> nextProgress() async {
    if (progress.value < knowledgeList.length - 1) {
      isListenAgain.value = true;
      currentPlayNum.value = 0;
      progress.value++;
      await newAudioPlayer(knowledgeList[progress.value]);
      isListenAgain.value = false;
    } else {
      currentPlayNum.value = 0;
      isDictationComplete.value = true;
      audioPlayAndPause(false);
    }
  }

  /// 再听一遍
  void reListen() async {
    await audioPlaybackUtils.stop();
    currentPlayNum.value = 0;
    isListenAgain.value = true;
    newAudioPlayer(knowledgeList[progress.value]);
  }

  /// 重新听写
  void redictation() {
    currentPlayNum.value = 0;
    progress.value = 0;
    isDictationComplete.value = false;
    isListenAgain.value = false;
    newAudioPlayer(knowledgeList[progress.value]);
    isListenAgain.value = false;
  }

  /// 开始核验
  void beginCheck() {
    TagRoutes.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS_DICTATION_CHECK,
      arguments: {
        "knowledgeList": knowledgeList.toList(),
      },
    );
  }

  /// 键盘事件处理
  bool _handleGlobalKeyEvent(KeyEvent event) {
    if (knowledgeList.isEmpty) return true;
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        audioPlayAndPause(!playStatus.value);
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        preProgress();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        nextProgress();
        return true;
      }
    }
    return true;
  }
}
