import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/common.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';
import '../enum/enum.dart';
import '../public_controller/config_controller.dart';
import '../values/values.dart';
import 'widgets.dart';

/// 播放顺序
enum AudioControlPlayOrder {
  /// 单曲播放
  single('单曲播放', "single"),

  /// 列表循环
  loop('列表循环', "loop"),

  /// 顺序播放
  sequential('顺序播放', "sequential"),

  /// 随机播放
  random('随机播放', "random"),

  /// 单曲循环
  singleLoop('单曲循环', "singleLoop");

  final String value;
  final String key;
  const AudioControlPlayOrder(this.value, this.key);

  /// 根据key转换
  factory AudioControlPlayOrder.fromRawValue(String key) {
    return values.firstWhere(
      (element) => element.key == key,
      orElse: () => AudioControlPlayOrder.loop,
    );
  }
}


enum AudioControlPreviousNext {
  previous,
  next,
}

/// 定时关闭菜单模型
class AudioControlTimingCloseMenuModel {
  /// 时长秒数
  final int? durationSeconds;

  /// 几首
  final int? songCount;

  /// 时长文本
  final String durationText;

  /// 类型 1: 时长 2: 几首
  final int type;

  const AudioControlTimingCloseMenuModel({
    this.durationSeconds,
    this.songCount,
    required this.durationText,
    required this.type,
  });
}

class AudioControlStyle {
  /// 时间进度文字颜色
  final Color timeProgressTextColor;

  /// 进度条背景颜色
  final Color progressBarBackgroundColor;

  /// 按钮默认背景色
  final Color buttonDefaultBackgroundColor;

  /// 按钮默认文字颜色
  final Color buttonDefaultTextColor;

  /// 按钮图标颜色
  final Color buttonIconColor;

  const AudioControlStyle({
    this.timeProgressTextColor = AppTheme.cTextSecondary,
    this.progressBarBackgroundColor = AppTheme.cSurfaceQuaternary,
    this.buttonDefaultBackgroundColor = AppTheme.cSurfaceQuaternary,
    this.buttonDefaultTextColor = AppTheme.cTextPrimary,
    this.buttonIconColor = AppTheme.cTextPrimary,
  });
}

class AudioControlController {
  _AudioControlWidgetState? _state;

  /// 隐藏所有菜单
  void hideAllMenus() {
    _state?.hideAllMenus();
  }

  /// 重新加载音频信息
  Future<void> reloadAudioInfo() async {
    await _state?.reloadAudioInfo();
  }
}

class AudioControlWidget extends StatefulWidget {
  final AudioPlaybackUtils? audioPlayerUtils;
  final AudioControlController? controller;
  final AudioControlStyle style;

  /// 初始化进度
  final Duration initPosition;

  final double initSpeed;
  final void Function(double speed)? onSpeedChanged;

  /// 是否显示进度条
  final bool showProgressBar;

  /// 是否显示倍速按钮
  final bool showSpeedButton;

  /// 是否显示播放列表按钮
  final bool showAudioListButton;
  final void Function()? onAudioListButtonPressed;

  /// 是否显示翻译按钮
  final bool showTranslateButton;
  final LangPreference translateValue;
  final void Function(LangPreference type)? onTranslateChanged;
  
  /// 是否显示文字大小调节按钮
  final bool showFontSizeButton;
  final double fontSizeMultiple;
  final double minFontSizeMultiple;
  final double maxFontSizeMultiple;
  final int fontSizeDivisions;
  final void Function(double fontSizeMultiple)? onFontSizeMultipleChanged;

  /// 是否显示播放顺序按钮
  final bool showPlayOrderButton;
  final AudioControlPlayOrder playOrderValue;
  final List<AudioControlPlayOrder>? playOrderList;
  final void Function(AudioControlPlayOrder type)? onPlayOrderChanged;

  /// 每个音频的循环次数
  final int playOrderLoopCount;
  final void Function(int loopCount)? onPlayOrderLoopCountChanged;

  /// 是否显示上一句下一句按钮
  final bool showSentenceSentenceutton;
  final void Function(AudioControlPreviousNext type)? onPreviousNextSentenceChanged;

  /// 是否显示上一曲下一曲按钮
  final bool showPreviousNextTrackButton;
  final void Function(AudioControlPreviousNext type)? onPreviousNextTrackChanged;

  /// 是否显示快进快退n秒按钮
  final bool showSeekButton;

  /// 快进快退的秒数
  final int seekSeconds;

  /// 是否监听播放状态
  final bool listenPlayStatus;

  /// 播放状态
  final bool isPlaying;

  /// 播放暂停回调 如果不为null 不走默认的播放暂停逻辑
  final void Function()? onPlayPauseChanged;

  /// 是否显示收藏按钮
  final bool showFavoriteButton;
  /// 是否是收藏
  final bool isFavorite;

  /// 是否显示倒计时按钮
  final bool showMenuCloseTimerButton;
  final List<AudioControlTimingCloseMenuModel> menuCloseTimerCountdownList;
  final String? menuCloseTimerStr;
  final void Function()? onClickMenuCloseTimer;
  
  /// 收藏按钮回调
  final void Function(bool isFavorite)? onFavoriteChanged;

  /// 正在显示的菜单列表
  final void Function(bool showSpeedList, bool showTranslateList, bool showFontSizeList, bool showPlayOrderList)? onMenuShow;

  /// 音频播放控制
  const AudioControlWidget({
    super.key,
    this.audioPlayerUtils,
    this.style = const AudioControlStyle(),
    this.initPosition = Duration.zero,
    this.controller,
    this.showProgressBar = true,
    this.initSpeed = 1.0,
    this.onSpeedChanged,
    this.showSpeedButton = true,
    this.showAudioListButton = false,
    this.onAudioListButtonPressed,
    this.showTranslateButton = true,
    this.translateValue = LangPreference.bilingual,
    this.showSentenceSentenceutton = true,
    this.showPreviousNextTrackButton = true,
    this.onTranslateChanged,
    this.onPreviousNextSentenceChanged,
    this.onPreviousNextTrackChanged,
    this.showSeekButton = false,
    this.seekSeconds = 5,
    this.showFontSizeButton = false,
    this.minFontSizeMultiple = 0.8,
    this.maxFontSizeMultiple = 1.2,
    this.fontSizeDivisions = 5,
    this.fontSizeMultiple = 1.0,
    this.onFontSizeMultipleChanged,
    this.showPlayOrderButton = false,
    this.playOrderList,
    this.playOrderValue = AudioControlPlayOrder.single,
    this.playOrderLoopCount = 1,
    this.onPlayOrderLoopCountChanged,
    this.onPlayOrderChanged,
    this.onPlayPauseChanged,
    this.listenPlayStatus = true,
    this.isPlaying = false,
    this.showFavoriteButton = false,
    this.isFavorite = false,
    this.showMenuCloseTimerButton = false,
    this.menuCloseTimerStr,
    this.menuCloseTimerCountdownList = const [],
    this.onClickMenuCloseTimer,
    this.onFavoriteChanged,
    this.onMenuShow,
  });

  @override
  State<AudioControlWidget> createState() => _AudioControlWidgetState();
}

class _AudioControlWidgetState extends State<AudioControlWidget> {
  List<AudioControlPlayOrder> playOrderList = AudioControlPlayOrder.values;

  /// 当前倍速
  double speed = 1.0;

  /// 音频总时长
  Duration duration = Duration.zero;

  /// 音频当前播放进度
  Duration position = Duration.zero;

  /// 播放状态
  bool isPlaying = false;

  /// 是否显示倍速列表
  bool showSpeedList = false;

  /// 是否显示翻译列表
  bool showTranslateList = false;

  /// 是否显示文字大小调节列表
  bool showFontSizeList = false;

  /// 是否显示播放顺序列表
  bool showPlayOrderList = false;

  /// 是否正在拖动进度条
  bool isDragging = false;

  StreamSubscription<Duration>? positionStream;
  StreamSubscription<bool>? pauseResumeStream;
  StreamSubscription<bool>? playCompleteStream;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    if (widget.playOrderList != null) {
      playOrderList = widget.playOrderList!;
    }
    speed = widget.initSpeed;
    _initAudio();
    HardwareKeyboard.instance.addHandler(_handleGlobalKeyEvent);
  }

  @override
  void dispose() {
    positionStream?.cancel();
    pauseResumeStream?.cancel();
    playCompleteStream?.cancel();
    HardwareKeyboard.instance.removeHandler(_handleGlobalKeyEvent);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AudioControlWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      isPlaying = widget.isPlaying;
      if (mounted) setState(() {});
    }
  }

  /// 监听键盘事件
  bool _handleGlobalKeyEvent(KeyEvent event) {
    // 检查是否有 Dialog 或其他模态路由打开
    if (ModalRoute.of(context)?.isCurrent != true) {
      return false; // 当前页面不在最前面，不处理键盘事件
    }

    // 空格键
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      if (widget.onPlayPauseChanged != null) {
        widget.onPlayPauseChanged!();
      } else {
        if (isPlaying) {
          widget.audioPlayerUtils?.pause();
        } else {
          if(duration.inMilliseconds - 100 <= position.inMilliseconds){
            widget.audioPlayerUtils?.seek(Duration.zero).then((_){
              widget.audioPlayerUtils?.resume();
            });
          }else{
            widget.audioPlayerUtils?.resume();
          }
        }
      }

      return true;
    } else if(event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape){
      widget.onMenuShow?.call(showSpeedList, showTranslateList, showFontSizeList, showPlayOrderList);
    }
    return false;
  }

  Future<void> _initAudio() async {
    try {
      duration = await widget.audioPlayerUtils?.getDuration() ?? Duration.zero;
      position = widget.initPosition;

      // position = await widget.audioPlayerUtils.getCurrentPosition();

      // 根据配置决定初始播放状态来源：
      // - listenPlayStatus=true: 跟随 audioPlayerUtils 内部状态
      // - listenPlayStatus=false: 完全由外部 isPlaying 控制
      if (widget.listenPlayStatus) {
        isPlaying = widget.audioPlayerUtils?.isPlaying ?? false;
      } else {
        isPlaying = widget.isPlaying;
      }
      if (mounted) setState(() {});
    } catch (_) {}

    if (widget.listenPlayStatus) {
      positionStream = widget.audioPlayerUtils?.positionStream.listen((event) {
        if (duration == Duration.zero) {
          widget.audioPlayerUtils?.getDuration().then((value) {
            duration = value;
            if (mounted) setState(() {});
          });
        }

        if (!isDragging && duration.inMilliseconds >= event.inMilliseconds) {
          position = event;
        }
        if (mounted) setState(() {});
      });

      pauseResumeStream = widget.audioPlayerUtils?.pauseResumeStream.listen((event) {
        isPlaying = event;
        if (mounted) setState(() {});
      });

      // playCompleteStream = widget.audioPlayerUtils?.playCompleteStream.listen((event) {
      //   isPlaying = false;
      //   if (mounted) setState(() {});
      // });
    }
  }

  /// 跳转进度
  Future<void> seekTo(Duration pos) async {
    if (pos.inMilliseconds < 0) {
      position = Duration.zero;
    } else if (pos.inMilliseconds > duration.inMilliseconds) {
      position = duration;
    } else {
      position = pos;
    }
    await widget.audioPlayerUtils?.seek(position);
  }

  /// 隐藏所有菜单
  void hideAllMenus() {
    showSpeedList = false;
    showTranslateList = false;
    showFontSizeList = false;
    showPlayOrderList = false;

    if (mounted) setState(() {});
  }

  /// 重新加载音频信息
  Future<void> reloadAudioInfo() async {
    try {
      duration = await widget.audioPlayerUtils?.getDuration() ?? Duration.zero;

      position = await widget.audioPlayerUtils?.getCurrentPosition() ?? Duration.zero;

      isPlaying = widget.audioPlayerUtils?.isPlaying ?? false;
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSpeedList(),
          _buildTranslateList(),
          _buildFontSizeListWidget(),
          _buildPlayOrderListWidget(),
          Visibility(
            visible: widget.showProgressBar,
            child: Container(
              margin: EdgeInsets.only(bottom: 16.wMin),
              child: Row(
                children: [
                  Text(
                    DateFormatUtil.convertSecondsToMinSec(position.inSeconds),
                    style: TextStyle(
                      color: widget.style.timeProgressTextColor,
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Expanded(child: _buildProgressBar()),
                  Text(
                    DateFormatUtil.convertSecondsToMinSec(duration.inSeconds),
                    style: TextStyle(
                      color: widget.style.timeProgressTextColor,
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  _buildSpeedButton(),
                  _buildPlayOrderButton(),
                  _buildFavoriteButtonWIdget(),
                  const Spacer(),
                  _buildFontSizeWidget(),
                  _buildTranslateButtonWidget(),
                  _buildTimingButtonWidget(),
                  _buildAudioListButton(),
                ],
              ),
              _buildPlayPauseButton(),
            ],
          ),
        ],
      ),
    );
  }

  /// 进度条
  Widget _buildProgressBar() {
    double _duration = duration.inMilliseconds.toDouble();
    double _position = position.inMilliseconds.toDouble();

    /// 判断当前进度是否超出最大最小范围
    bool isOutOfRange = _position > _duration || _position < 0;

    return Visibility(
      visible: _duration > 0,
      child: Container(
        height: 32.wMin,
        width: double.infinity,
        alignment: Alignment.center,
        child: SliderTheme(
          data: SliderThemeData(
            trackHeight: 8.wMin,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 12.wMin,
            ),
          ),
          child: Slider(
            value: isOutOfRange ? 0 : _position,
            min: 0,
            max: isOutOfRange ? 0 : _duration,
            activeColor: AppTheme.cBgBrand.color,
            inactiveColor: widget.style.progressBarBackgroundColor,
            onChangeStart: (value) {
              isDragging = true;
              if (mounted) setState(() {});
            },
            onChanged: (value) {
              position = Duration(milliseconds: value.toInt());
              if (mounted) setState(() {});
            },
            onChangeEnd: (value) {
              seekTo(position);
              isDragging = false;
              if (mounted) setState(() {});
            },
          ),
        ),
      ),
    );
  }

  /// 倒计时按钮
  Widget _buildTimingButtonWidget(){
    if(!widget.showMenuCloseTimerButton) return Container();
    return Container(
      margin: EdgeInsets.only(left: 8.wMin),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          TapScaleWidget(
            onTap: () {
              showFontSizeList = false;
              showTranslateList = false;
              showPlayOrderList = false;
              showSpeedList = false;
              showPlayOrderList = false;
              if (mounted) setState(() {});
          
              widget.onClickMenuCloseTimer?.call();
            },
            sclae: 1.08,
            child: Container(
              alignment: Alignment.center,
              width: 80.wMin,
              height: 80.wMin,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: SvgPicture.asset(
                "assets/svg/public/icon_duration.svg",
                width: 48.wMin,
                colorFilter: ColorFilter.mode(widget.style.buttonDefaultTextColor, BlendMode.srcIn),
              ),
            ),
          ),
          Positioned(
            bottom: -6.wMin,
            child: IgnorePointer(
              ignoring: true,
              child: Text(
                widget.menuCloseTimerStr??"",
                style: TextStyle(
                  color: widget.style.buttonDefaultTextColor,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          ),
        ],
      ),
    );
  }


  /// 播放列表按钮
  Widget _buildAudioListButton() {
    if (!widget.showAudioListButton) return Container();

    return Container(
      margin: EdgeInsets.only(left: 8.wMin),
      child: TapScaleWidget(
        onTap: () {
          showFontSizeList = false;
          showTranslateList = false;
          showPlayOrderList = false;
          showSpeedList = false;
          showPlayOrderList = false;
          if (mounted) setState(() {});

          widget.onAudioListButtonPressed?.call();
          widget.onMenuShow?.call(showSpeedList, showTranslateList, showFontSizeList, showPlayOrderList);
        },
        sclae: 1.08,
        child: Container(
          alignment: Alignment.center,
          width: 80.wMin,
          height: 80.wMin,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: SvgPicture.asset(
            "assets/svg/public/icon_audio_list.svg",
            width: 48.wMin,
            colorFilter: ColorFilter.mode(widget.style.buttonDefaultTextColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  /// 播放顺序按钮
  Widget _buildPlayOrderButton() {
    if (!widget.showPlayOrderButton) return Container();

    String svgPath = "assets/svg/public/icon_list_loop.svg";
    if (widget.playOrderValue == AudioControlPlayOrder.single) {
      svgPath = "assets/svg/public/icon_single_play.svg";
    } else if (widget.playOrderValue == AudioControlPlayOrder.loop) {
      svgPath = "assets/svg/public/icon_list_loop.svg";
    } else if (widget.playOrderValue == AudioControlPlayOrder.sequential) {
      svgPath = "assets/svg/public/icon_sequential_play.svg";
    } else if (widget.playOrderValue == AudioControlPlayOrder.random) {
      svgPath = "assets/svg/public/icon_shuffle_play.svg";
    } else if (widget.playOrderValue == AudioControlPlayOrder.singleLoop) {
      svgPath = "assets/svg/public/icon_single_song_repeat.svg";
    }

    return TapScaleWidget(
      onTap: () async {
        if (showSpeedList || showTranslateList || showFontSizeList) {
          showSpeedList = false;
          showTranslateList = false;
          showFontSizeList = false;
          if (mounted) setState(() {});
          await Future.delayed(const Duration(milliseconds: 300));
        }
        showPlayOrderList = !showPlayOrderList;
        if (mounted) setState(() {});
        widget.onMenuShow?.call(showSpeedList, showTranslateList, showFontSizeList, showPlayOrderList);
      },
      sclae: 1.08,
      child: Container(
        alignment: Alignment.center,
        width: 80.wMin,
        height: 80.wMin,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
          child: SvgPicture.asset(
            showPlayOrderList ? "assets/svg/public/icon_caret_down.svg" : svgPath,
            width: 48.wMin,
            key: ValueKey(showPlayOrderList),
            colorFilter: ColorFilter.mode(widget.style.buttonDefaultTextColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  /// 播放顺序列表
  Widget _buildPlayOrderListWidget() {
    if (!showPlayOrderList) return Container();

    List<int> loopCountList = [1, 2, 3, 4, 5];

    bool showLoopCount = widget.playOrderValue != AudioControlPlayOrder.singleLoop;

    return Container(
      margin: EdgeInsets.only(bottom: 16.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80.wMin,
            padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
            decoration: BoxDecoration(
              color: widget.style.buttonDefaultBackgroundColor,
              borderRadius: BorderRadius.circular(12.wMin),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(playOrderList.length, (index) {
                return Expanded(
                  child: TapScaleWidget(
                    onTap: () async {
                      widget.onPlayOrderChanged?.call(playOrderList[index]);
                      AudioControlUtils.saveSetting(AudioControlSettingModel(
                        playOrder: playOrderList[index],
                      ));
                    },
                    sclae: 1,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      alignment: Alignment.center,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.wMin),
                        color: AppTheme.cBgBrand.color.withValues(alpha: widget.playOrderValue == playOrderList[index] ? 1 : 0),
                      ),
                      child: AutoSizeText(
                        playOrderList[index].value,
                        style: TextStyle(
                          color: widget.playOrderValue == playOrderList[index] ? Colors.white : widget.style.buttonDefaultTextColor,
                          fontSize: 28.wMin,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 16.wMin),
          Text(
            "循环次数 x ${widget.playOrderValue == AudioControlPlayOrder.singleLoop ? "∞" : widget.playOrderLoopCount}",
            style: TextStyle(
              fontSize: 28.wMin,
              color: widget.style.buttonDefaultTextColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          Visibility(
            visible: showLoopCount,
            child: Container(
              margin: EdgeInsets.only(top: 8.wMin),
              height: 80.wMin,
              child: Row(
                spacing: 9.wMin,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(loopCountList.length, (index) {
                  return Expanded(
                    child: TapScaleWidget(
                      onTap: () async {
                        widget.onPlayOrderLoopCountChanged?.call(loopCountList[index]);
                        AudioControlUtils.saveSetting(AudioControlSettingModel(
                          playOrderLoopCount: loopCountList[index],
                        ));
                      },
                      sclae: 1,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        alignment: Alignment.center,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.wMin),
                          color: widget.playOrderLoopCount == loopCountList[index] ? AppTheme.cBgBrand.color : widget.style.buttonDefaultBackgroundColor,
                        ),
                        child: AutoSizeText(
                          loopCountList[index].toString(),
                          style: TextStyle(
                            color: widget.playOrderLoopCount == loopCountList[index] ? Colors.white : widget.style.buttonDefaultTextColor,
                            fontSize: 28.wMin,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }



  /// 倍速按钮
  Widget _buildSpeedButton() {
    if (!widget.showSpeedButton) return Container();
    return Container(
      margin: EdgeInsets.only(right: 8.wMin),
      child: TapScaleWidget(
        onTap: () async {
          if (showFontSizeList || showTranslateList || showPlayOrderList) {
            showFontSizeList = false;
            showTranslateList = false;
            showPlayOrderList = false;
            if (mounted) setState(() {});
            await Future.delayed(const Duration(milliseconds: 300));
          }
          showSpeedList = !showSpeedList;
          if (mounted) setState(() {});
          widget.onMenuShow?.call(showSpeedList, showTranslateList, showFontSizeList, showPlayOrderList);
        },
        sclae: 1.08,
        child: Container(
          alignment: Alignment.center,
          width: 80.wMin,
          height: 80.wMin,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: showSpeedList
                ? SvgPicture.asset(
                    "assets/svg/public/icon_caret_down.svg",
                    width: 48.wMin,
                    key: ValueKey(showSpeedList),
                    colorFilter: ColorFilter.mode(widget.style.buttonDefaultTextColor, BlendMode.srcIn),
                  )
                : AutoSizeText(
                    "${speed}x",
                    maxLines: 1,
                    minFontSize: 6,
                    style: TextStyle(
                      color: widget.style.buttonDefaultTextColor,
                      fontSize: 32.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// 倍速列表
  Widget _buildSpeedList() {
    if (!showSpeedList) return Container();

    List<double> speedList = Get.find<ConfigController>().userSetting.value.expandAudioSpeedList;

    return Container(
      margin: EdgeInsets.only(bottom: 16.wMin),
      height: 80.wMin,
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        color: widget.style.buttonDefaultBackgroundColor,
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(speedList.length, (index) {
          return AspectRatio(
            aspectRatio: 1,
            child: TapScaleWidget(
              onTap: () async {
                speed = speedList[index];
                if (mounted) setState(() {});
                await widget.audioPlayerUtils?.setPlaybackRate(speed);
                widget.onSpeedChanged?.call(speed);
                await Future.delayed(const Duration(milliseconds: 500));
                if (mounted) setState(() {});

                // AudioControlUtils.saveSetting(AudioControlSettingModel(
                //   playbackRate: speed,
                // ));
              },
              sclae: 1.01,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                alignment: Alignment.center,
                height: double.infinity,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cBgBrand.color.withValues(alpha: speed == speedList[index] ? 1 : 0),
                ),
                child: AutoSizeText(
                  "${speedList[index]}",
                  style: TextStyle(
                    color: speed == speedList[index] ? Colors.white : widget.style.buttonDefaultTextColor,
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

    /// 收藏按钮
  Widget _buildFavoriteButtonWIdget(){
    if (!widget.showFavoriteButton) return Container();
    return Container(
      margin: EdgeInsets.only(left: 8.wMin),
      child: TapScaleWidget(
        onTap: () async {
          widget.onFavoriteChanged?.call(!widget.isFavorite);
          widget.onMenuShow?.call(showSpeedList, showTranslateList, showFontSizeList, showPlayOrderList);
        },
        sclae: 1.08,
        child: Container(
          alignment: Alignment.center,
          width: 80.wMin,
          height: 80.wMin,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOutBack,
            transitionBuilder: (child, animation) {

              final animWidget = child.key == ValueKey(widget.isFavorite);
              if(animWidget){
                if(!widget.isFavorite) return child;
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              }

              if(widget.isFavorite) return child;
              
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
              
            },
            child: SvgPicture.asset(
              widget.isFavorite ? "assets/svg/public/icon_like.svg" : "assets/svg/public/icon_dislike.svg",
              width: 48.wMin,
              key: ValueKey(widget.isFavorite),
            ),
          ),
        ),
      ),
    );
  }

  /// 文字大小调节按钮
  Widget _buildFontSizeWidget() {
    if (!widget.showFontSizeButton) return Container();
    return Container(
      margin: EdgeInsets.only(left: 8.wMin),
      child: TapScaleWidget(
        onTap: () async {
          if (showSpeedList || showTranslateList || showPlayOrderList) {
            showSpeedList = false;
            showTranslateList = false;
            showPlayOrderList = false;
            if (mounted) setState(() {});
            await Future.delayed(const Duration(milliseconds: 300));
          }
          showFontSizeList = !showFontSizeList;
          if (mounted) setState(() {});
          widget.onMenuShow?.call(showSpeedList, showTranslateList, showFontSizeList, showPlayOrderList);
        },
        sclae: 1.08,
        child: Container(
          alignment: Alignment.center,
          width: 80.wMin,
          height: 80.wMin,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: SvgPicture.asset(
              showFontSizeList ? "assets/svg/public/icon_caret_down.svg" : "assets/svg/public/icon_fontsize.svg",
              width: 48.wMin,
              key: ValueKey(showFontSizeList),
              colorFilter: ColorFilter.mode(widget.style.buttonDefaultTextColor, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }

  /// 文字大小调节列表
  Widget _buildFontSizeListWidget() {
    if (!showFontSizeList) return Container();

    return Container(
      margin: EdgeInsets.only(bottom: 16.wMin),
      height: 80.wMin,
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        color: widget.style.buttonDefaultBackgroundColor,
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Row(
        spacing: 10.wMin,
        children: [
          Container(
            width: 52.wMin,
            height: 52.wMin,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              "assets/svg/public/icon_a_max.svg",
              width: 20.wMin,
              colorFilter: ColorFilter.mode(widget.style.buttonDefaultTextColor, BlendMode.srcIn),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                // 轨道更粗一些
                trackHeight: 6.wMin,
                // 统一轨道颜色，让前后段看起来一致为灰色
                activeTrackColor: widget.style.buttonDefaultTextColor.withValues(alpha: 0.6),
                inactiveTrackColor: widget.style.buttonDefaultTextColor.withValues(alpha: 0.6),
                // 刻度颜色与轨道一致
                activeTickMarkColor: widget.style.buttonDefaultTextColor.withValues(alpha: 0.6),
                inactiveTickMarkColor: AppTheme.cTextBrand.color,
                // 拇指样式：更大圆形
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: 18.wMin,
                ),
                thumbColor: AppTheme.cTextBrand.color,
                trackShape: const RectangularSliderTrackShape(),
                // 使用自定义的“竖线”刻度
                tickMarkShape: VerticalLineSliderTickMarkShape(
                  width: 6.wMin,
                  height: 24.wMin,
                ),
              ),
              child: Slider(
                value: widget.fontSizeMultiple,
                min: widget.minFontSizeMultiple,
                max: widget.maxFontSizeMultiple,
                divisions: widget.fontSizeDivisions,
                onChanged: (value) {
                  widget.onFontSizeMultipleChanged?.call(value);
                  AudioControlUtils.saveSetting(AudioControlSettingModel(
                    fontSizeMultiple: value,
                  ));
                },
              ),
            ),
          ),
          Container(
            width: 52.wMin,
            height: 52.wMin,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              "assets/svg/public/icon_a_max.svg",
              width: 32.wMin,
              colorFilter: ColorFilter.mode(widget.style.buttonDefaultTextColor, BlendMode.srcIn),
            ),
          ),
        ],
      ),
    );
  }

  /// 翻译按钮
  Widget _buildTranslateButtonWidget() {
    if (!widget.showTranslateButton) return Container();
    return Container(
      margin: EdgeInsets.only(left: 8.wMin),
      child: TapScaleWidget(
        onTap: () async {
          if (showFontSizeList || showSpeedList || showPlayOrderList) {
            showFontSizeList = false;
            showSpeedList = false;
            showPlayOrderList = false;
            if (mounted) setState(() {});
            await Future.delayed(const Duration(milliseconds: 300));
          }

          showTranslateList = !showTranslateList;
          if (mounted) setState(() {});
          widget.onMenuShow?.call(showSpeedList, showTranslateList, showFontSizeList, showPlayOrderList);
        },
        sclae: 1.08,
        child: Container(
          alignment: Alignment.center,
          width: 80.wMin,
          height: 80.wMin,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: SvgPicture.asset(
              showTranslateList ? "assets/svg/public/icon_caret_down.svg" : "assets/svg/public/icon_translation.svg",
              width: 48.wMin,
              key: ValueKey(showTranslateList),
              colorFilter: ColorFilter.mode(widget.style.buttonDefaultTextColor, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }

  /// 翻译菜单列表
  Widget _buildTranslateList() {
    if (!showTranslateList) return Container();

    List<UserPreferenceDefinitionDisplayModeOption> expandDropdownMenu = Get.find<ConfigController>().userSetting.value.expandDropdownMenu??[];
    if(expandDropdownMenu.isEmpty) return Container();


    return Container(
      margin: EdgeInsets.only(bottom: 16.wMin),
      height: 80.wMin,
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        color: widget.style.buttonDefaultBackgroundColor,
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(expandDropdownMenu.length, (index) {

          LangPreference itemLang = LangPreference.fromRawValue(expandDropdownMenu[index].code);


          return Expanded(
            child: TapScaleWidget(
              onTap: () async {
                widget.onTranslateChanged?.call(itemLang);
                // AudioControlUtils.saveSetting(AudioControlSettingModel(
                //   translate: translateList[index],
                // ));
              },
              sclae: 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                alignment: Alignment.center,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  color: AppTheme.cBgBrand.color.withValues(alpha: widget.translateValue == itemLang ? 1 : 0),
                ),
                child: AutoSizeText(
                  expandDropdownMenu[index].title??"",
                  style: TextStyle(
                    color: widget.translateValue == itemLang ? Colors.white : widget.style.buttonDefaultTextColor,
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 播放暂停按钮
  Widget _buildPlayPauseButton() {
    List<Widget> leftWidgets = [];
    List<Widget> rightWidgets = [];

    if (widget.showSeekButton) {
      leftWidgets.add(_buildSeekButtonWidget(true));
    }
    if (widget.showPreviousNextTrackButton) {
      leftWidgets.add(TapScaleWidget(
        sclae: 1.05,
        onTap: () => widget.onPreviousNextTrackChanged?.call(AudioControlPreviousNext.previous),
        child: _buildIconButtonWidget("icon_previous_track.svg"), // 上一曲,
      ));
    }
    if (widget.showSentenceSentenceutton) {
      leftWidgets.add(TapScaleWidget(
        sclae: 1.05,
        onTap: () => widget.onPreviousNextSentenceChanged?.call(AudioControlPreviousNext.previous),
        child: _buildPreviousNextSentenceButtonWidget(AudioControlPreviousNext.previous), // 上一句
      ));
    }

    if (widget.showSentenceSentenceutton) {
      rightWidgets.add(TapScaleWidget(
        sclae: 1.05,
        onTap: () => widget.onPreviousNextSentenceChanged?.call(AudioControlPreviousNext.next),
        child: _buildPreviousNextSentenceButtonWidget(AudioControlPreviousNext.next), // 下一句,
      ));
    }
    if (widget.showPreviousNextTrackButton) {
      rightWidgets.add(TapScaleWidget(
        sclae: 1.05,
        onTap: () => widget.onPreviousNextTrackChanged?.call(AudioControlPreviousNext.next),
        child: _buildIconButtonWidget("icon_next_track.svg"), // 下一曲,
      ));
    }
    if (widget.showSeekButton) {
      rightWidgets.add(_buildSeekButtonWidget(false));
    }

    return Row(
      spacing: 10.wMin,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...leftWidgets,
        TapScaleWidget(
          onTap: () async {
            if (widget.onPlayPauseChanged != null) {
              widget.onPlayPauseChanged!();
              return;
            }

            if (isPlaying) {
              await widget.audioPlayerUtils?.pause();
            } else {
              if (position.inMilliseconds + 100 >= duration.inMilliseconds) {
                await widget.audioPlayerUtils?.seek(Duration.zero);
              }
              await widget.audioPlayerUtils?.resume();
            }
          },
          sclae: 1.08,
          child: Container(
            alignment: Alignment.center,
            width: 80.wMin,
            height: 80.wMin,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.style.buttonDefaultBackgroundColor,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                color: widget.style.buttonIconColor,
                size: 48.wMin,
                key: ValueKey(isPlaying),
              ),
            ),
          ),
        ),
        ...rightWidgets,
      ],
    );
  }

  /// 快进快退n秒的按钮
  Widget _buildSeekButtonWidget(bool isBack) {
    String svg = isBack ? "icon_rewind_second.svg" : "icon_forward_second.svg";
    return TapScaleWidget(
      onTap: () async {
        if (isBack) {
          seekTo(position - Duration(seconds: widget.seekSeconds));
        } else {
          seekTo(position + Duration(seconds: widget.seekSeconds));
        }
      },
      sclae: 1.05,
      child: Container(
        width: 80.wMin,
        height: 80.wMin,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              "assets/svg/public/$svg",
              width: 48.wMin,
              colorFilter: ColorFilter.mode(widget.style.buttonDefaultTextColor, BlendMode.srcIn),
            ),
            Container(
              margin: EdgeInsets.only(top: 5.wMin),
              child: Text(
                "${widget.seekSeconds}",
                style: TextStyle(
                  color: widget.style.buttonDefaultTextColor,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// icon 按钮
  Widget _buildIconButtonWidget(String svgName) {
    return Container(
      alignment: Alignment.center,
      width: 80.wMin,
      height: 80.wMin,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.transparent),
      child: SvgPicture.asset(
        "assets/svg/public/$svgName",
        colorFilter: ColorFilter.mode(widget.style.buttonIconColor, BlendMode.srcIn),
        height: 48.wMin,
      ),
    );
  }

  /// 上一句下一句按钮
  Widget _buildPreviousNextSentenceButtonWidget(AudioControlPreviousNext previousNext) {
    return Container(
      width: 132.wMin,
      height: 62.wMin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.transparent,
      ),
      child: Text(
        previousNext == AudioControlPreviousNext.previous ? "上一句" : "下一句",
        style: TextStyle(
          color: widget.style.buttonDefaultTextColor,
          fontSize: 28.wMin,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// 自定义：竖线刻度形状，让 divisions 显示为竖线而不是圆点
class VerticalLineSliderTickMarkShape extends SliderTickMarkShape {
  final double width;
  final double height;

  const VerticalLineSliderTickMarkShape({
    this.width = 2.0,
    this.height = 12.0,
  });

  @override
  Size getPreferredSize({
    required SliderThemeData sliderTheme,
    required bool isEnabled,
  }) {
    return Size(width, height);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    required bool isEnabled,
    required TextDirection textDirection,
  }) {
    final Canvas canvas = context.canvas;

    final ColorTween colorTween = ColorTween(
      begin: sliderTheme.inactiveTickMarkColor ?? sliderTheme.inactiveTrackColor,
      end: sliderTheme.activeTickMarkColor ?? sliderTheme.activeTrackColor,
    );

    final paint = Paint()
      ..color = colorTween.evaluate(enableAnimation) ?? (sliderTheme.activeTrackColor ?? Colors.grey)
      ..style = PaintingStyle.fill;

    final Rect rect = Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );

    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(width / 2)), paint);
  }
}

class AudioControlSettingModel {
  /// 倍速
  double? playbackRate;

  /// 播放模式
  AudioControlPlayOrder? playOrder;

  /// 循环次数
  int? playOrderLoopCount;

  /// 文字大小倍数
  double? fontSizeMultiple;

  /// 翻译配置
  LangPreference? translate;
  
  AudioControlSettingModel({
    this.playbackRate,
    this.playOrder,
    this.playOrderLoopCount,
    this.fontSizeMultiple,
    this.translate,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    if (playbackRate != null) {
      map['playbackRate'] = playbackRate;
    }
    if (playOrder != null) {
      map['playOrder'] = playOrder!.key;
    }
    if (playOrderLoopCount != null) {
      map['playOrderLoopCount'] = playOrderLoopCount;
    }
    if (fontSizeMultiple != null) {
      map['fontSizeMultiple'] = fontSizeMultiple;
    }
    if(translate != null){
      map['translate'] = translate!.code;
    }
    return map;
  }

  AudioControlSettingModel.fromJson(Map map) {
    if (map['playbackRate'] != null) {
      playbackRate = map['playbackRate']?.toDouble();
    }
    if (map['playOrder'] != null) {
      playOrder = AudioControlPlayOrder.fromRawValue(map['playOrder']);
    }
    if (map['playOrderLoopCount'] != null) {
      playOrderLoopCount = map['playOrderLoopCount']?.toInt();
    }
    if (map['fontSizeMultiple'] != null) {
      fontSizeMultiple = map['fontSizeMultiple']?.toDouble();
    }
    if(map['translate'] != null){
      translate = LangPreference.fromRawValue(map['translate']);
    }
  }
}

class AudioControlUtils {
  /// 储存配置到本地
  static void saveSetting(AudioControlSettingModel setting) {
    String? settingStr = StorageUtil().getString(AUDIO_CONTROL_SETTING_KEY);
    Map settingMap = {};
    if (settingStr.isEmpty) {
      settingMap = setting.toJson();
    } else {
      Map oldSettingMap = jsonDecode(settingStr);
      if (setting.playbackRate != null) {
        oldSettingMap['playbackRate'] = setting.playbackRate;
      }
      if (setting.fontSizeMultiple != null) {
        oldSettingMap['fontSizeMultiple'] = setting.fontSizeMultiple;
      }
      if (setting.playOrder != null) {
        oldSettingMap['playOrder'] = setting.playOrder!.key;
      }
      if (setting.playOrderLoopCount != null) {
        oldSettingMap['playOrderLoopCount'] = setting.playOrderLoopCount;
      }
      if(setting.translate != null){
        oldSettingMap['translate'] = setting.translate!.code;
      }
      settingMap = oldSettingMap;
    }
    StorageUtil().setString(AUDIO_CONTROL_SETTING_KEY, jsonEncode(settingMap));
  }

  /// 获取本地储存配置
  static AudioControlSettingModel? getSetting() {
    String settingStr = StorageUtil().getString(AUDIO_CONTROL_SETTING_KEY);
    if (settingStr.isEmpty) return null;
    try {
      Map settingMap = jsonDecode(settingStr);
      return AudioControlSettingModel.fromJson(settingMap);
    } catch (e) {
      return null;
    }
  }
}
