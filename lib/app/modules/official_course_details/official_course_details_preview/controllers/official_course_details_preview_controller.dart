import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/values/storage.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/storage_util.dart';
import 'package:video_player/video_player.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/public_controller/model/user_setting_model.dart';
import '../views/official_course_details_preview_setting_dialog.dart';

class OfficialCourseDetailsPreviewController extends GetxController {
  String? moduleName; //书名称
  String? unitName; //单元名称

  /// 顺序知识点列表
  List<UnitKnowledgePointsEntityKnowledgeList> sequentialKnowledgeList = [];

  /// 随机知识点列表
  List<UnitKnowledgePointsEntityKnowledgeList> randomKnowledgeList = [];

  /// 知识点列表
  final RxList<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = <UnitKnowledgePointsEntityKnowledgeList>[].obs;

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

  /// 播放音量
  final RxInt volume = 100.obs;

  // 播放进度
  RxInt progress = 0.obs;

  /// 播放状态
  RxBool playStatus = false.obs;

  /// 英音、美音
  String? national;

  AudioPlaybackUtils audioPlaybackUtils = AudioPlaybackUtils();

  StreamSubscription? _playerCompleteSubscription; //音频播放完成的流订阅

  bool isCompleted = false;

  /// 页面是否准备完成
  final RxBool isReady = false.obs;

  /// 每个切换等待的timer
  Timer? _switchTimer;

  /// 回调防抖
  bool debounce = false;

  RxInt totalDurationTime = 0.obs; //总时长

  /// 是否正在切换音频，防止并发 stop/prepare 导致 just_audio 崩溃
  bool _isSwitchingAudio = false;

  /// 等待中的下一首（在频繁点击时只保留最后一次请求）
  UnitKnowledgePointsEntityKnowledgeList? _pendingAudioModel;

  @override
  void onInit() {
    super.onInit();
    national = UserStore.to.userInfo.value.config?.national;
    initUserSetting();
    List<double> intervalList = Get.find<ConfigController>().userSetting.value.intervalMenu!.map((e) => e.value!).toList();
    if (intervalList.isEmpty) {
      playInterval.value = 7.5;
    } else {
      playInterval.value = StorageUtil().getDouble(INTERVAL_SPEED_KEY) ?? intervalList[1];
      var _idx = intervalList.indexOf(playInterval.value);
      if (_idx == -1) {
        playInterval.value = intervalList[1];
      }
    }
    if (Get.arguments != null) {
      moduleName = Get.arguments["moduleName"];
      unitName = Get.arguments["unitName"];

      sequentialKnowledgeList = Get.arguments["knowledgeList"];
      randomKnowledgeList = sequentialKnowledgeList.toList();
      randomKnowledgeList.shuffle();
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
    playMode.value = setting?.playOrder ?? PlayerModeEnum.list;
    playNum.value = setting?.playOrderLoopCount ?? 1;
    volume.value = setting?.volume ?? 100;
  }

  @override
  void onClose() {
    super.onClose();
    _switchTimer?.cancel();
    _playerCompleteSubscription?.cancel();
    audioPlaybackUtils.setPlaybackRate(1.0);
    audioPlaybackUtils.setNavigationHandlers(onNext: null, onPrevious: null);
    audioPlaybackUtils.stop();
    audioPlaybackUtils.dispose();
    ToastUtils.hideLoading();
  }

  /// 初始化音频播放器
  void audioPlayerInit() {
    audioPlaybackUtils.setNavigationHandlers(
      onNext: () async => nextClick(true),
      onPrevious: () async => previousClick(),
    );
    _playerCompleteSubscription?.cancel();
    _switchTimer?.cancel();
    _playerCompleteSubscription = audioPlaybackUtils.playCompleteStream.distinct().listen((state) async {
      if (audioPlaybackUtils.isPlaying) return;
      if (debounce) return;
      debounce = true;
      // 播放完成沿用你已有的逻辑
      debugPrint('------播放完成-----');
      currentPlayNum.value++;
      if (currentPlayNum.value >= playNum.value) {
        if (playMode.value == PlayerModeEnum.singleLoop) {
          currentPlayNum.value = 0;
          await newAudioPlayer(knowledgeList[progress.value]);
        } else {
          int oldProgress = progress.value;
          var delayMs = totalDurationTime.value * playInterval.value.toInt() + 800;
          _switchTimer = Timer(Duration(milliseconds: delayMs),  () {
            if (!isClosed && playStatus.value && oldProgress == progress.value) {
              print(playStatus);
              nextClick(false);
            }
          });
        }
      } else {
        Future.delayed(const Duration(milliseconds: 800), () async{
          if(isClosed) return;
          await newAudioPlayer(knowledgeList[progress.value]);
        });
      }

      Future.delayed(const Duration(milliseconds: 800), () {
        debounce = false;
      });
    });
  }

  /// 设置新的音频资源
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
    for (var item in model.pronunciations ?? []) {
      if (item.national == national) {
        pronunciationModel = item;
        break;
      }
    }

    String urlString = pronunciationModel?.audioUrl ?? '';
    if (urlString.isEmpty) {
      _isSwitchingAudio = false;
      return;
    }

    try {
      totalDurationTime.value = pronunciationModel?.duration != null ? (pronunciationModel!.duration! * 1000).toInt() : 0;

      // 串行化 stop + prepare，避免在还没 stop 完就再次 prepare
      await audioPlaybackUtils.stop();

      // 提供锁屏信息（可按需丰富）
      await audioPlaybackUtils.prepare(
        url: urlString,
        title: model.content ?? '',
        artist: moduleName ?? '',
        album: unitName ?? '',
        image: model.imageUrl != null ? Uri.tryParse(model.imageUrl!) : null,
        duration: Duration(milliseconds: totalDurationTime.value),
        androidCompactActionIndices: const [0, 1, 2],
        playSpeed: playSpeed.value,
      );

      // repeat interval
      if (currentPlayNum.value > 0) {
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      if (!isClosed) {
        audioPlaybackUtils.resume();
        playStatus.value = true;
      }
    } catch (e) {
      // 这里不抛给上层，防止 just_audio 的内部异常导致页面崩溃
      debugPrint('newAudioPlayer error: $e');
    } finally {
      _isSwitchingAudio = false;

      // 如果在切换过程中又有新的切换请求，只保留最后一次，串行执行
      final nextModel = _pendingAudioModel;
      if (nextModel != null && !isClosed) {
        _pendingAudioModel = null;
        // 不 await，防止递归过深；由下一次调用自己接管锁
        unawaited(newAudioPlayer(nextModel));
      }
    }
  }

  //播放 暂停
  void audioPlayAndPause() async {
    if (playStatus.value) {
      audioPlaybackUtils.pause();
      playStatus.value = false;
    } else {
      if (isCompleted) {
        isCompleted = false;
        currentPlayNum.value = 0;
        await newAudioPlayer(knowledgeList[progress.value]);
      } else {
        audioPlaybackUtils.resume();
      }
      playStatus.value = true;
    }
  }

  /// 播放设置
  void playSetting({bool isFirst = false}) async {
    List<UnitKnowledgePointsEntityKnowledgeList> words = [];
    List<UnitKnowledgePointsEntityKnowledgeList> phrases = [];
    List<UnitKnowledgePointsEntityKnowledgeList> sentences = [];

    for (int i = 0; i < sequentialKnowledgeList.length; i++) {
      if (sequentialKnowledgeList[i].isWord) {
        words.add(sequentialKnowledgeList[i]);
      } else if (sequentialKnowledgeList[i].isPhrase) {
        phrases.add(sequentialKnowledgeList[i]);
      } else if (sequentialKnowledgeList[i].isSentence) {
        sentences.add(sequentialKnowledgeList[i]);
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

    PreviewSettingModel? newGraph = await OfficialCourseDetailsPreviewSettingDialog.show(
      context: Get.context!,
      initModel: PreviewSettingModel(
        playMode: playMode.value,
        playNum: playNum.value,
        playSpeed: playSpeed.value,
        knowledgePoints: knowledgePoints,
        playInterval: playInterval.value,
        selectedKnowledgePoints: knowledgePoints.map((e) => e.type).toList(),
      ),
    );

    if (newGraph == null) {
      if (isFirst) {
        Get.back();
      }
      return;
    }
    audioPlayerInit();

    playNum.value = newGraph.playNum;
    playSpeed.value = newGraph.playSpeed;
    playMode.value = newGraph.playMode;
    playInterval.value = newGraph.playInterval;
    StorageUtil().setDouble(INTERVAL_SPEED_KEY, playInterval.value);
    await audioPlaybackUtils.setPlaybackRate(playSpeed.value);

    playStatus.value = false;
    await audioPlaybackUtils.stop();
    currentPlayNum.value = 0;
    progress.value = 0;

    sequentialKnowledgeList.removeWhere((element) => !newGraph.selectedKnowledgePoints.contains(element.cardType));
    randomKnowledgeList.removeWhere((element) => !newGraph.selectedKnowledgePoints.contains(element.cardType));

    if (playMode.value == PlayerModeEnum.random) {
      knowledgeList.value = randomKnowledgeList.toList();
    } else {
      knowledgeList.value = sequentialKnowledgeList.toList();
    }

    if (playMode.value == PlayerModeEnum.singleLoop) {
      playNum.value = 1;
    }

    newAudioPlayer(knowledgeList.first).then((_) {
      isReady.value = true;
    });
  }

  /// 上一个
  void previousClick() {
    debugPrint('上一个被点击');
    if (progress.value > 0) {
      currentPlayNum.value = 0;
      progress.value--;
      newAudioPlayer(knowledgeList[progress.value]);
    } else {
      if (playMode.value == PlayerModeEnum.list) {
        currentPlayNum.value = 0;
        progress.value = knowledgeList.length - 1;
        newAudioPlayer(knowledgeList[progress.value]);
      }  else if (playMode.value == PlayerModeEnum.random) {
        ToastUtils.showToast(text: '当前已是第一个');
      } else if (playMode.value == PlayerModeEnum.singleLoop) {
        ToastUtils.showToast(text: '当前已是第一个');
      }
    }
  }

  /// 下一个
  Future<void> nextClick(bool isManual) async {
    debugPrint('下一个被点击=====$isManual');
    if (progress.value < knowledgeList.length - 1) {
      currentPlayNum.value = 0;
      progress.value++;
      await newAudioPlayer(knowledgeList[progress.value]);
    } else {
      if (playMode.value == PlayerModeEnum.list) {
        currentPlayNum.value = 0;
        progress.value = 0;
        await newAudioPlayer(knowledgeList[progress.value]);
      } else if (playMode.value == PlayerModeEnum.random) {
        if (isManual) {
          ToastUtils.showToast(text: '当前已是最后一个');
        } else {
          currentPlayNum.value = 0;
          progress.value = 0;
          playStatus.value = false;
          isCompleted = true;
          audioPlaybackUtils.stop();
          ToastUtils.showToast(text: '太棒了！知识点预习完成~ ', type: ToastType.success);
        }
      } else if (playMode.value == PlayerModeEnum.singleLoop) {
        ToastUtils.showToast(text: '当前已是最后一个');
      }
    }
  }

  /// 修改播放模式
  void changePlayMode(PlayerModeEnum playMode) {
    this.playMode.value = playMode;
    if (playMode == PlayerModeEnum.list) {
      knowledgeList.value = sequentialKnowledgeList.toList();
    } else if (playMode == PlayerModeEnum.random) {
      knowledgeList.value = randomKnowledgeList.toList();
    }
    audioPlayerInit();
    newAudioPlayer(knowledgeList[progress.value]);

    AudioControlUtils.saveSetting(AudioControlSettingModel(playOrder: playMode));
  }

  /// 修改循环次数
  void changePlayNum(int playNum) {
    currentPlayNum.value = 0;
    this.playNum.value = playNum;
    audioPlayerInit();
    newAudioPlayer(knowledgeList[progress.value]);
    AudioControlUtils.saveSetting(AudioControlSettingModel(playOrderLoopCount: playNum));
  }

  /// 修改播放速度
  void changePlaySpeed(double speed) async {
    playSpeed.value = speed;
    await audioPlaybackUtils.setPlaybackRate(speed);
    ConfigController configController = Get.find<ConfigController>();
    configController.setUserSetting(expandAudioSpeed: speed);
  }

  /// 修改播放音量
  Future<void> onVolumeChange(int value) async{
    volume.value = value;
    await audioPlaybackUtils.setVolume(value.toDouble());
    AudioControlUtils.saveSetting(AudioControlSettingModel(volume: value));
  }

}
