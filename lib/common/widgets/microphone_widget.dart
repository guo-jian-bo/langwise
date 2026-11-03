

// 文件顶部引入
import 'dart:async';
import 'dart:math' as math;
import 'package:bot_toast/bot_toast.dart';
import 'package:bubble_box/bubble_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:lib_common/utils/storage_util.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';
import '../../utils/utils.dart';
import '../values/values.dart';

enum MicrophoneEnum {
  
  /// 默认 还未开启录音
  defaultType,
  /// 录音
  recording,
  /// 加载
  loading,
}

/// 控制器
class MicrophoneController {
  
  _MicrophoneWidgetState? _state;

  MicrophoneEnum get type => _state?.microphoneEnum ?? MicrophoneEnum.defaultType;

  void setType(MicrophoneEnum type) {
    _state?.setType(type);
  }

  

}

class MicrophoneWidget extends StatefulWidget {
  final void Function()? onTapRecord;
  final void Function()? onRecordFailure;
  final MicrophoneController? controller;
  const MicrophoneWidget({
    super.key,
    this.onTapRecord,
    this.onRecordFailure,
    this.controller,
  });

  @override
  State<MicrophoneWidget> createState() => _MicrophoneWidgetState();
}

class _MicrophoneWidgetState extends State<MicrophoneWidget> {

  final GlobalKey tipsButtonKey = GlobalKey();

  bool showTips = false;

  MicrophoneEnum microphoneEnum = MicrophoneEnum.defaultType;
  

  /// 0 - 1
  double? spread;

  Timer? volumeTimer;

  /// 麦克风振幅流订阅
  StreamSubscription<double>? waveAmplitudeStreamSubscription;



  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showTipsDialog();
    });
  }

  @override
  void dispose() {
    super.dispose();
    waveAmplitudeStreamSubscription?.cancel();
    volumeTimer?.cancel();
  }


  void setType(MicrophoneEnum type) {
    microphoneEnum = type;
    if(microphoneEnum == MicrophoneEnum.recording){
      initRecording();
    }else{
      volumeTimer?.cancel();
      volumeTimer = null;
      waveAmplitudeStreamSubscription?.cancel();
      waveAmplitudeStreamSubscription = null;
      spread = null;
    }
    if(mounted) setState(() {});
  }

  Future<void> initRecording() async{
    volumeTimer?.cancel();
    volumeTimer = null;

    waveAmplitudeStreamSubscription = RecordingServerUtils.instance.waveAmplitudeStreamController.stream.listen((event){
      if (event > -60) {
        // 基于iOS Recorder.swift中的实际振幅范围：-160.0dB（安静）到 0.0dB（最大音量）
        // 实际使用时，我们关注的时候是人声范围，大约在 -60dB 到 -10dB 之间
        // 将分贝值限制在 -60 到 0 之间
        double clampedDb = event.clamp(-60.0, 0.0);

        // 将负分贝值映射到0-1的比例（接近0表示声音大，接近-60表示声音小）
        double normalizedRatio = (clampedDb + 60) / 60;

        spread = normalizedRatio;
      }else{
        spread = null;
      }

      checkVolumeZero(event);

      if(mounted) setState(() {});
    });
  }

  /// 如果录音的音量为0 那么开始定时器 5秒没有收到音 那么就认为录音失败 就提示用户
  Future<void> checkVolumeZero(event) async{
    if(event != -160){
      volumeTimer?.cancel();
      volumeTimer = null;
      return;
    }
    if(volumeTimer != null) return;
    volumeTimer?.cancel();
    volumeTimer = null;
    volumeTimer = Timer.periodic(const Duration(seconds: 10), (timer) async{
      timer.cancel();
      volumeTimer = null;
      if(mounted) setState(() {});
      ToastUtils.showToast(text: "录音失败，请检查麦克风是否可用");
      widget.onRecordFailure?.call();
    });
  }


  Future<void> showTipsDialog() async {
    bool isHide = StorageUtil().getBool(FOLLOW_UP_PROMPT_KEY);
    if(isHide) return;
    StorageUtil().setBool(FOLLOW_UP_PROMPT_KEY, true);

    await Future.delayed(const Duration(milliseconds: 500));
    BuildContext? ctx = tipsButtonKey.currentContext;
    if(ctx == null) return;
    if(!mounted) return;

    BotToast.showAttachedWidget(
      targetContext: ctx,
      backgroundColor: Colors.transparent,
      onlyOne: true,
      allowClick: false,
      preferDirection: PreferDirection.bottomCenter,
      duration: const Duration(milliseconds: 3000),
      attachedBuilder: (cancelFunc) {
        return BubbleBox(
          backgroundColor: AppTheme.cSurfaceInfo.color,
          padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 8.wMin),
          shape: BubbleShapeBorder(
            direction: BubbleDirection.top,
            arrowQuadraticBezierLength: 2.wMin,
            radius: BorderRadius.circular(8.wMin),
            arrowHeight: 8.wMin,
            arrowAngle: 10.wMin,
            smooth: 1.wMin,
          ),
          child: Text(
            "点击按钮开始跟读录音",
            style: TextStyle(
              fontSize: 22.wMin,
              color: AppTheme.cStaticWhite.color,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 基础按钮尺寸与最大扩散额外尺寸（沿用 40.wMin 预留空间）
    final double baseSize = 90.wMin;
    final double maxExtra = 40.wMin;

    // 是否显示波纹（录音状态）
    final bool isRecording = spread != null;

    // 最小扩散比例，保证“已开启录音”的提示
    const double minFactor = 0.15;

    // 将 spread 视为 0–1 值；若传入像素或 dB，请改成合适映射
    final double factor = isRecording
        ? math.max((spread!).clamp(0.0, 1.0), minFactor)
        : 0.0;

    // 当前扩散额外尺寸
    final double extra = factor * maxExtra;

    // 外层容器尺寸（固定最大，避免裁剪）
    final double containerSize = baseSize + maxExtra;

    return SizedBox(
      width: containerSize,
      height: containerSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 波纹层：三层不同强度的扩散，随 spread 变化
          Visibility(
            visible: isRecording,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildWave(baseSize, extra, AppTheme.cFeedbackInfoBackground.color, 1.0),
                _buildWave(baseSize, extra * 0.6, AppTheme.cFeedbackInfoBackground.color, 0.8),
              ],
            ),
          ),

          // 中心话筒按钮（保留原有交互与视觉）
          TapScaleWidget(
            onTap: OptimizeUtils.noneThrottle(() {
              widget.onTapRecord?.call();
            }, 500),
            sclae: 1.05,
            child: Container(
              key: tipsButtonKey,
              width: baseSize,
              height: baseSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cInversePrimary.color.withValues(
                  alpha: microphoneEnum == MicrophoneEnum.defaultType ? 0.8 : 1.0,
                ),
              ),
              child: SvgPicture.asset(
                "assets/svg/public/icon_microphone.svg",
                width: 28.wMin,
                height: 28.wMin,
              ),
            ),
          ),

        ],
      ),
    );
  }

  // 单层波纹构建：圆形填充，透明度随强度调整
  Widget _buildWave(double baseSize, double extra, Color color, double strength) {
    final double size = baseSize + extra;
    final double alpha = 0.30 * strength;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: alpha),
      ),
    );
  }
}