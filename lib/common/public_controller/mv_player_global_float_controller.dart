import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/song_mv/controllers/song_mv_controller.dart';

import '../../app/routes/routes.dart';
import '../../utils/utils.dart';
import '../widgets/widgets.dart';

class MvPlayerGlobalFloatController extends GetxController with WidgetsBindingObserver{

  static MvPlayerGlobalFloatController get to => Get.find<MvPlayerGlobalFloatController>();

  final RotationTransitionController rotationTransitionController = RotationTransitionController();

  /// 播放暂停按钮的事件流
  final StreamController<bool> _playPauseEventStreamController = StreamController<bool>.broadcast();

  Stream<bool> get playPauseEventStreamController => _playPauseEventStreamController.stream;

  final Rx<Size> windowSize = Size.zero.obs;
  
  /// 是否显示悬浮按钮
  final RxBool isShowFloatButton = false.obs;

  /// 播放状态
  final RxBool isPlaying = false.obs;

  /// 显示的图片网络url
  final Rx<String> mvImageUrl = "".obs;

  /// 当前进度
  final Rx<double> progress = 0.0.obs;

  Timer? _eventTimer;

    @override
  void onInit() {
    super.onInit(); 
    WidgetsBinding.instance.addObserver(this);
  }
  
  /// 隐藏播放器
  void hide() {
    isShowFloatButton.value = false;
  }


  /// 切换是否显示悬浮按钮
  void toggleIsShowFloatButton(bool value) {

    if(isShowFloatButton.value == value) return;

    if(value){
      isShowFloatButton.value = value;
    }else{
      isShowFloatButton.value = false;
      _playPauseEventStreamController.add(false);
    }
    
  }

  /// 停止播放
  Future<void> stop({bool isStopB = true}) async{
    // 停止播放记录追踪（song_mv 源）
    
    toggleIsPlaying(false);
    isShowFloatButton.value = false;
    _playPauseEventStreamController.add(false);
    await Get.find<SongMvController>().stop(isStopB: isStopB); 
    toggleIsShowFloatButton(false);
  }


  /// 设置MV图片
  void setMvImageUrl(String? url) {
    if(url == null) return;
    mvImageUrl.value = url;
  }

  /// 设置当前进度
  void setProgress(Duration duration, Duration position) {
    if(duration.inSeconds == 0) return;
    if(position.inSeconds > duration.inSeconds) return;
    progress.value = position.inSeconds.toDouble() / duration.inSeconds.toDouble();
  }

  /// 单独的切换播放状态
  void toggleIsPlayingOnly(bool value) {
    isPlaying.value = value;
    if(value){
      rotationTransitionController.resume();
    }else{
      rotationTransitionController.pause();
    }
  }

  /// 切换播放状态
  void toggleIsPlaying(bool value) {
    
    toggleIsPlayingOnly(value);


    _playPauseEventStreamController.add(value);

  }




  /// 跳转至MV播放页面
  Future<void> navigateToMvDetail() async{
    if(Get.currentRoute == Routes.SONG_MV) return;
    if(LockUtils.showPlayLearnDialog){
      // 如果弹出了学点支付弹窗 那么先关闭弹窗
      Get.back();
    }

    JumpPageUtils.jumpSongMv();
  }

  @override
  void didChangeMetrics() {
    if(Get.context != null){
      final window = View.of(Get.context!).physicalSize;
      windowSize.value = window;
    }
  }



  @override
  void onClose() {
    super.onClose();
    WidgetsBinding.instance.removeObserver(this);
    _playPauseEventStreamController.close();
    _eventTimer?.cancel();
  }

}