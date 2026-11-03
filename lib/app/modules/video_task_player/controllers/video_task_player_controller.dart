import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart' as vp;

import '../../../../utils/toast_utils.dart';

class VideoTaskPlayerController extends GetxController with WidgetsBindingObserver {
  static VideoTaskPlayerController get to => Get.find<VideoTaskPlayerController>();

  final RxBool isReady = false.obs;
  final RxBool isPlaying = false.obs;

  final Rx<Duration> duration = Duration.zero.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> maxPlayed = Duration.zero.obs;

  final RxDouble speed = 1.0.obs;

  final List<double> _speedOptions = const [0.5, 1.0, 1.5, 2.0];

  final GlobalKey<vp.VideoPlayerWidgetState> videoKey = GlobalKey<vp.VideoPlayerWidgetState>();

  String title = '视频类任务页面';
  String rightTopText = '看完全视频，即可领取 1000 学点';
  String rewardTitle = '奖励已发放';
  String rewardDesc = '恭喜你完成观看任务，奖励已到账。';

  bool _showedCompleteDialog = false;
  bool _initializedArgs = false;
  late final String videoUrl;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    final args = (Get.arguments as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    videoUrl = (args['videoUrl'] ?? '') as String;

    final t = args['title'];
    if (t is String && t.trim().isNotEmpty) {
      title = t;
    }

    final desc = args['desc'];
    if (desc is String && desc.trim().isNotEmpty) {
      rightTopText = desc;
    }

    final rt = args['rewardTitle'];
    if (rt is String && rt.trim().isNotEmpty) {
      rewardTitle = rt;
    }

    final rd = args['rewardDesc'];
    if (rd is String && rd.trim().isNotEmpty) {
      rewardDesc = rd;
    }

    _initializedArgs = true;
  }

  void onVideoPlayInfoChange(dynamic info) {
    final Duration allDuration = info?.allDuration ?? Duration.zero;
    final Duration positionDuration = info?.positionDuration ?? Duration.zero;
    final bool playing = info?.playing ?? false;
    final double rate = info?.rate ?? 1.0;
    final bool completed = info?.completed ?? false;

    duration.value = allDuration;
    position.value = positionDuration;
    isPlaying.value = playing;
    speed.value = rate;

    if (!isReady.value && allDuration > Duration.zero) {
      isReady.value = true;
    }

    if (positionDuration > maxPlayed.value) {
      maxPlayed.value = positionDuration;
    }

    if (!_showedCompleteDialog && completed) {
      _showedCompleteDialog = true;
      isPlaying.value = false;
      Future<void>.delayed(Duration.zero, () {
        if (Get.isDialogOpen == true) return;
        Get.dialog(
          _RewardDialogWidget(
            title: rewardTitle,
            desc: rewardDesc,
          ),
          barrierDismissible: true,
        );
      });
    }
  }

  Future<void> togglePlay() async {
    if (!_initializedArgs) return;
    await videoKey.currentState?.player.playOrPause();
  }

  Future<void> play() async {
    if (!_initializedArgs) return;
    await videoKey.currentState?.player.play();
  }

  Future<void> pause() async {
    if (!_initializedArgs) return;
    await videoKey.currentState?.player.pause();
  }

  Future<void> setSpeed(double v) async {
    speed.value = v;
    if (!_initializedArgs) return;
    await videoKey.currentState?.player.setRate(v);
  }

  Future<void> cycleSpeed() async {
    final current = speed.value;
    final idx = _speedOptions.indexWhere((e) => (e - current).abs() < 0.001);
    final next = _speedOptions[(idx < 0 ? 0 : (idx + 1) % _speedOptions.length)];
    await setSpeed(next);
  }

  Future<void> seek(Duration d) async {
    if (!_initializedArgs) return;
    await videoKey.currentState?.player.seek(d);
  }

  void scheduleExceedToast() {
      ToastUtils.showToast(text: '无法快进', type: ToastType.warning);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      pause();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}

class _RewardDialogWidget extends StatelessWidget {
  final String title;
  final String desc;

  const _RewardDialogWidget({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          width: 640,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2A3A),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8), height: 1.4),
              ),
              const SizedBox(height: 18),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('知道了', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
