import 'dart:async';
import 'dart:io';

import 'package:api/entities/entities.dart';
import 'package:audio_player_ex/audio_player_ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wise_http/wise_http.dart';

import '../../../../../../common/https/https.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../routes/routes.dart';
import '../../../utils/utils.dart';
import '../models/manage_english_content_management_audio_model.dart';

class ManageGenerateAudioController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageGenerateAudioController({required this.tag});

  RxInt selectedMode = 0.obs;
  RxInt selectedPlatform = 1.obs;
  RxBool isCustomSound = false.obs;
  List<String> soundList = [];
  RxInt selectedAccentIndex = 0.obs;
  List<ManageEnglishContentManagementAudioAccentModel> accentList = [];

  // 自定义音色
  final TextEditingController customSoundController =
      TextEditingController(text: '');
  // 音标
  final TextEditingController phoneticController =
      TextEditingController(text: '');
  //文本
  final TextEditingController textController = TextEditingController(text: '');

  //生成状态
  ManageEnglishContentManagementAudioModel? audioModel;

  int downPercentage = 0; //下载进度

  AudioPlayerEx? audioPlayer; //音频播放器
  StreamSubscription? _positionSubscription; //音频播放位置变化的流订阅
  StreamSubscription? _playerCompleteSubscription; //音频播放完成的流订阅
  RxInt currentTime = 0.obs; //当前播放时间
  RxInt totalDurationTime = 0.obs; //总时长

  // 播放状态
  RxBool playStatus = false.obs;
  // 播放进度
  RxDouble progress = 0.0.obs;
  
  @override
  String get breadcrumbRoute => Routes.MANAGE_GENERATE_AUDIO;
  
  @override
  String get breadcrumbTitle => '音频生成';

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    initServiceData();
  }

  // 初始化服务数据
  initServiceData() async {
    try {
      ToastUtils.showLoading();
      String? provider;
      if (selectedPlatform.value == 0) {
        provider = 'bytedance';
      } else {
        provider = 'azure';
      }

      ResponseEntity<List<ManageEnglishContentManagementAudioAccentModel>>?
          res = await ManageSelectQuziKnowledge.getAudioAccentList(parameters: {
        'provider': provider,
      }, data: {});
      if (res == null) {
        return;
      }
      selectedAccentIndex.value = 0;
      accentList = res.data!;
      soundList = [];
      for (ManageEnglishContentManagementAudioAccentModel model in accentList) {
        soundList.add('${model.timbre} (${model.description} ${model.name})');
      }
      update();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //生成音频
  Future<void> generateAudio() async {
    if (isCustomSound.value) {
      if (customSoundController.text.isEmpty) {
        ToastUtils.showManageToast(
            text: '请输入自定义音色的名称', type: ManageToastType.error);
        return;
      }
    } else {
      if (accentList.isEmpty) {
        ToastUtils.showManageToast(text: '请选择音色', type: ManageToastType.error);
        return;
      }
    }
    if (selectedMode.value == 1 && phoneticController.text.isEmpty) {
      ToastUtils.showManageToast(text: '请输入音标', type: ManageToastType.error);
      return;
    }
    if (textController.text.isEmpty) {
      ToastUtils.showManageToast(text: '请输入文本', type: ManageToastType.error);
      return;
    }

    try {
      ToastUtils.showLoading();
      ManageEnglishContentManagementAudioModel? res =
          await ManageSelectQuziKnowledge.generateAudio(
        parameters: {},
        data: {
          'text': textController.text,
          'provider': selectedPlatform.value == 0 ? 'bytedance' : 'azure',
          'voice_type': isCustomSound.value
              ? customSoundController.text
              : accentList[selectedAccentIndex.value].timbre,
          'accentId': isCustomSound.value
              ? null
              : accentList[selectedAccentIndex.value].uid,
          'type': selectedMode.value == 0 ? 'text' : 'ipa',
          'ph': selectedMode.value == 0 ? null : phoneticController.text,
        },
      );
      if (res == null) {
        return;
      }
      audioModel = res;
      audioPlayerInit(audioModel?.url ?? '');
      update();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //下载音频文件
  Future<void> downloadAudioFile() async {
    ToastUtils.showLoading();

    final List<String> splitList =
        textController.text.trim().split(RegExp(r'\s+'));
    String fileName = splitList.isNotEmpty ? splitList.first : '音频';
    fileName += '.mp3';

    try {
      String? path = await getTempDirPath();
      if (path == null) return;
      path += Platform.pathSeparator + fileName;

      WiseHttp().download(
        audioModel?.url ?? '',
        path,
        cancelToken: CancelToken(),
        onReceiveProgress: (count, total) {
          if (count >= total) {
            ToastUtils.showManageToast(text: '下载完成');
          }
        },
      );
    } catch (e) {
      ToastUtils.showManageToast(text: '下载音频文件失败', type: ManageToastType.error);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<String?> getTempDirPath() async {
    if (Platform.isWindows || Platform.isMacOS) {
      return FilePicker.platform.getDirectoryPath();
    } else {
      // 其他平台（Android/iOS）
      return (await getTemporaryDirectory()).path +
          Platform.pathSeparator +
          "app";
    }
  }

  //初始化音频播放器
  void audioPlayerInit(String urlString) async {
    ToastUtils.showLoading();

    audioPlayer = AudioPlayerEx();
    audioPlayer?.setReleaseMode(ReleaseMode.stop);
    //监听播放位置变化
    _positionSubscription = audioPlayer?.onPositionChanged.listen(
      (position) {
        currentTime.value = position.inMilliseconds;
        if (totalDurationTime.value > 0) {
          progress.value = currentTime.value / totalDurationTime.value;
        }
        update();
      },
    );
    //监听播放完成
    _playerCompleteSubscription = audioPlayer?.onPlayerComplete.listen(
      (event) {
        currentTime.value = 0;
        playStatus.value = false;
        progress.value = 0.0;
        audioPlayer?.stop();
        update();
      },
    );
    //加载音频资源到播放器waveform
    await audioPlayer?.setSource(UrlSource(urlString));
    //获取音频总时长
    totalDurationTime.value =
        (await audioPlayer?.getDuration())?.inMilliseconds ?? 0;
    ToastUtils.hideLoading();
    update();
  }

  //播放 暂停
  void audioPlayAndPause() async {
    if (audioPlayer?.state == PlayerState.playing) {
      await audioPlayer?.pause();
      playStatus.value = false;
    } else {
      await audioPlayer?.resume();
      playStatus.value = true;
    }
    update();
  }

  //设置播放进度
  void setAudioPosition(double progress) async {
    currentTime.value = (progress * totalDurationTime.value).toInt();
    await audioPlayer?.seek(Duration(milliseconds: currentTime.value));
    update();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    audioPlayer?.dispose();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    textController.dispose();
    phoneticController.dispose();
    customSoundController.dispose();
    super.onClose();
  }
}
