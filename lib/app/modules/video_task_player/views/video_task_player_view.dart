import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart' as vp;

import '../../../../theme/theme.dart';
import '../controllers/video_task_player_controller.dart';

class VideoTaskPlayerView extends GetView<VideoTaskPlayerController> {
  const VideoTaskPlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF2B313B),
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              Positioned.fill(child: _VideoLayer()),
              Positioned(top: 0, left: 0, right: 0, child: _TopBar()),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoLayer extends StatelessWidget {
  final VideoTaskPlayerController c = VideoTaskPlayerController.to;

  _VideoLayer();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        children: [
          Positioned.fill(
            child: vp.VideoPlayerWidget(
              key: c.videoKey,
              playList: [
                vp.MediaModel(resource: c.videoUrl),
              ],
              autoPlay: false,
              onVideoPlayInfoChange: (info) {
                c.onVideoPlayInfoChange(info);
              },
              controls: (state) {
                return _BottomControls();
              },
              loadingWidget: Center(
                child: SizedBox(
                  width: 56.wMin,
                  height: 56.wMin,
                  child: CircularProgressIndicator(color: AppTheme.cTextBrand.color),
                ),
              ),
            ),
          ),
          if (!c.isReady.value)
            Center(
              child: SizedBox(
                width: 56.wMin,
                height: 56.wMin,
                child: CircularProgressIndicator(color: AppTheme.cTextBrand.color),
              ),
            ),
        ],
      );
    });
  }
}

class _TopBar extends StatelessWidget {
  final VideoTaskPlayerController c = VideoTaskPlayerController.to;

  _TopBar();

  String _format(Duration d) {
    final total = d.inSeconds;
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16.wMin,
        left: 24.wMin,
        right: 24.wMin,
        bottom: 16.wMin,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.all(10.wMin),
              child: Icon(Icons.arrow_back_ios_new, color: AppTheme.cInverseTextLight, size: 26.wMin),
            ),
          ),
          SizedBox(width: 8.wMin),
          Expanded(
            child: Text(
              c.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.cInverseTextLight,
                fontSize: 26.wMin,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 12.wMin),
          Obx(() {
            final d = c.duration.value;
            final p = c.position.value;
            final remain = d > Duration.zero ? (d - p) : Duration.zero;
            final remainText = _format(remain < Duration.zero ? Duration.zero : remain);
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 18.wMin, vertical: 10.wMin),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999.wMin),
                border: Border.all(color: Colors.white.withValues(alpha: 0.16), width: 1.wMin),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    c.rightTopText,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 14.wMin),
                  Text(
                    '剩余',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 6.wMin),
                  Text(
                    remainText,
                    style: TextStyle(
                      color: AppTheme.cTextBrand.color,
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 4.wMin),
                  Text(
                    '领奖励',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BottomControls extends StatefulWidget {
  @override
  State<_BottomControls> createState() => _BottomControlsState();
}

class _BottomControlsState extends State<_BottomControls> with SingleTickerProviderStateMixin {
  final VideoTaskPlayerController c = VideoTaskPlayerController.to;

  bool _dragging = false;
  bool _wasPlayingBeforeDrag = false;

  double _sliderValue = 0;
  double _sliderMax = 1;

  late final AnimationController _bounceController;
  Animation<double>? _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
    c.position.listen((_) {
      if (_dragging) return;
      final d = c.duration.value;
      final p = c.position.value;
      final max = d.inMilliseconds <= 0 ? 1.0 : d.inMilliseconds.toDouble();
      setState(() {
        _sliderMax = max;
        _sliderValue = p.inMilliseconds.clamp(0, d.inMilliseconds).toDouble();
      });
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    final total = d.inSeconds;
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startBounceTo(double target) {
    final from = _sliderValue;
    _bounceController.stop();
    _bounceController.reset();
    _bounceAnimation = Tween<double>(begin: from, end: target).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    )
      ..addListener(() {
        final v = _bounceAnimation?.value;
        if (v == null) return;
        setState(() {
          _sliderValue = v;
        });
      });
    _bounceController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 24.wMin, right: 24.wMin, bottom: 18.wMin, top: 8.wMin),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.35),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Spacer(),
          Row(
            children: [
              Obx(() {
                return Text(
                  _format(c.position.value),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 18.wMin, fontWeight: FontWeight.w500),
                );
              }),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.cTextBrand.color,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.22),
                    thumbColor: AppTheme.cTextBrand.color,
                    trackHeight: 3.wMin,
                    overlayShape: SliderComponentShape.noOverlay,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.wMin),
                  ),
                  child: Slider(
                    value: _sliderValue.clamp(0, _sliderMax),
                    min: 0,
                    max: _sliderMax,
                    onChangeStart: (_) async {
                      _dragging = true;
                      _wasPlayingBeforeDrag = c.isPlaying.value;
                      await c.pause();
                    },
                    onChanged: (v) {
                      final maxAllowed = c.maxPlayed.value.inMilliseconds.toDouble();
                      if (maxAllowed > 0 && v > maxAllowed) {
                        c.scheduleExceedToast();
                        setState(() {
                          _sliderValue = maxAllowed;
                        });
                        return;
                      }

                      setState(() {
                        _sliderValue = v;
                      });
                    },
                    onChangeEnd: (v) async {
                      _dragging = false;

                      final maxAllowed = c.maxPlayed.value.inMilliseconds.toDouble();
                      if (maxAllowed > 0 && v > maxAllowed) {
                        c.scheduleExceedToast();
                        _startBounceTo(maxAllowed);
                        await c.seek(Duration(milliseconds: maxAllowed.toInt()));
                        if (_wasPlayingBeforeDrag) {
                          await c.play();
                        }
                        return;
                      }

                      await c.seek(Duration(milliseconds: v.toInt()));
                      if (_wasPlayingBeforeDrag) {
                        await c.play();
                      }
                    },
                  ),
                ),
              ),
              Obx(() {
                return Text(
                  _format(c.duration.value),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 18.wMin, fontWeight: FontWeight.w500),
                );
              }),
            ],
          ),
          SizedBox(height: 10.wMin),
          Container(
            height: 64.wMin,
            alignment: Alignment.center,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    await c.cycleSpeed();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Obx(() {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
                      child: Text(
                        '${c.speed.value.toStringAsFixed(1)}x',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 18.wMin, fontWeight: FontWeight.w600),
                      ),
                    );
                  }),
                ),
                const Spacer(),
                Obx(() {
                  final playing = c.isPlaying.value;
                  return GestureDetector(
                    onTap: () async {
                      await c.togglePlay();
                    },
                    child: Container(
                      width: 56.wMin,
                      height: 56.wMin,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.wMin),
                      ),
                      child: Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 30.wMin,
                      ),
                    ),
                  );
                }),
                const Spacer(),
                SizedBox(width: 56.wMin),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
