
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/utils/utils.dart';
import 'package:video_player/video_player.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/input_formatters/decimal_textInput_formatter.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';

class VideoEditController {
  _VideoEditWidgetState? _state;

  Future<void> setResource(String videoUrl, {bool isAutoPlay = true}) async{
    await _state?.setResource(videoUrl, isAutoPlay: isAutoPlay);
  }

  /// 暂停视频
  Future<void> pause() async{
    await _state?.pause();
  }

  /// 暂停播放视频
  Future<void> playOrPause() async{
    await _state?.playOrPause();
  }

}

class VideoEditWidget extends StatefulWidget {
  final String videoUrl;
  final VideoEditController? controller;
  /// 自动播放
  final bool autoPlay;
  /// 工具栏自动隐藏
  final bool autoHideControls;
  /// 初始化裁剪开始位置
  final Duration? trimStartTime;
  /// 初始化裁剪结束位置
  final Duration? trimEndTime;
  /// 初始化是否静音
  final bool isMuted;
  /// 裁剪回调
  final Function(Duration startTime, Duration endTime, bool isMute)? onTrim;
  /// 禁用编辑
  final bool disableEditing;
  /// 回调视频解析后的时长
  final Function(Duration actualDuration)? onVideoDuration;

  final Function(Duration duration)? onVideoPosition;
  /// 视频的宽高
  final Size videoSize;
  /// 视频裁剪的圆角
  final BorderRadius borderRadius;

  /// 字幕
  final String? ass;
  /// 翻译字幕
  final List<LanguageText?>? translate;
  /// 翻译语言code
  final String translateCode;

  const VideoEditWidget({
    super.key, 
    required this.videoUrl,
    required this.videoSize,
    this.controller,
    this.autoPlay = true,
    this.autoHideControls = true,
    this.trimStartTime,
    this.trimEndTime,
    this.isMuted = false,
    this.disableEditing = false,
    this.onTrim,
    this.onVideoDuration,
    this.onVideoPosition,
    this.borderRadius = BorderRadius.zero,
    this.ass,
    this.translate,
    this.translateCode = "zh",
  });

  @override
  State<VideoEditWidget> createState() => _VideoEditWidgetState();
}

class _VideoEditWidgetState extends State<VideoEditWidget> {

  final VideoPlayeController videoPlayerController = VideoPlayeController();
  final FocusNode _focusNode = FocusNode();
  String? videoUrl;

  /// 是否初始化了视频的裁剪时长
  bool initDuration = false;

  /// 播放状态
  bool _isPlaying = false;

  /// 是否静音
  bool _isMuted = false;

  /// 视频总时长
  Duration _videoDuration = Duration.zero;

  /// 视频当前位置
  Duration _currentPosition = Duration.zero;

  /// 视频裁剪开始位置
  Duration _trimStartTime = Duration.zero;
  /// 视频裁剪开始位置输入框
  final TextEditingController _trimStartTimeController = TextEditingController(text: "0.00");

  /// 视频裁剪结束位置
  Duration? _trimEndTime;
  /// 视频裁剪结束位置输入框
  final TextEditingController _trimEndTimeController = TextEditingController();

  /// 拖拽手柄宽度
  static const double _handleWidth = 14;
  /// 最小裁剪间隔（毫秒）
  static const int _minTrimGapMs = 100;



  @override
  void initState() {
    widget.controller?._state = this;
    super.initState();

    _isMuted = widget.isMuted;

    if(widget.trimStartTime != null){
      _trimStartTime = widget.trimStartTime!;
      _trimStartTimeController.text = DateFormatUtil.millisecondsToSecondsWithDecimal(widget.trimStartTime!.inMilliseconds);
      _currentPosition = widget.trimStartTime!;
    }

    if(widget.trimEndTime != null){
      initDuration = true;
      _trimEndTime = widget.trimEndTime!;
      _trimEndTimeController.text = DateFormatUtil.millisecondsToSecondsWithDecimal(widget.trimEndTime!.inMilliseconds);
    }

    videoUrl = widget.videoUrl;
  }

  @override
  void dispose(){
    _focusNode.dispose();
    super.dispose();
  }

  /// 重新设置资源
  Future<void> setResource(String url, {bool isAutoPlay = true}) async{
    videoUrl = url;
    initDuration = false;
    try {
      Duration startSeconds = Duration.zero;
      if(widget.trimStartTime != null){
        startSeconds = widget.trimStartTime!;
      }
      Duration? endSeconds;
      if(widget.trimEndTime != null){
        endSeconds = widget.trimEndTime;
      }

      await videoPlayerController.open([MediaModel(resource: url, start: startSeconds, end: endSeconds)], autoPlay: isAutoPlay);
    } finally{
      if(mounted) setState(() {});
    }
  }

  /// 单独设置资源
  Future<void> _setResource() async{
    await videoPlayerController.open([MediaModel(resource: videoUrl!, start: _trimStartTime, end: _trimEndTime)], autoPlay: true);
  }

  Future<void> pause() async{
    await videoPlayerController.pause();
  }

  Future<void> playOrPause() async{
    await videoPlayerController.playOrPause();
  }


  @override
  Widget build(BuildContext context) {
    if(videoUrl == null) return Container();
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey != LogicalKeyboardKey.space) return KeyEventResult.ignored;
        videoPlayerController.playOrPause();
        return KeyEventResult.handled;
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: widget.borderRadius,
            child: Container(
              color: Colors.transparent,
              width: widget.videoSize.width,
              height: widget.videoSize.height,
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    VideoPlayerWidget(
                      autoPlay: widget.autoPlay,
                      controller: videoPlayerController,
                      playList: [MediaModel(resource: videoUrl!, start: _trimStartTime, end: _trimEndTime)],
                      loadingWidget: SpinKitFadingCircle(
                        color: AppTheme.cBgBrand.color,
                        size: 100.wMin,
                      ),
                      onReady: () {
                        if(_isMuted){
                          videoPlayerController.setVolume(0);
                        }
                      },
                      controls: (p0) {
                        return GestureDetector(
                          onTap: () async{
                            if (!_focusNode.hasFocus) {
                              _focusNode.requestFocus();
                            }
                            videoPlayerController.playOrPause();
                          },
                          child: Container(color: Colors.transparent),
                        );
                      },
                      onVideoPlayInfoChange: (into) async{
                        
                        _isPlaying = into.playing;
                        
                        if(_videoDuration == Duration.zero){
                          _videoDuration = into.allDuration;
                          widget.onTrim?.call(_trimStartTime, _trimEndTime ?? _videoDuration, _isMuted);

                        }
                        _currentPosition = into.positionDuration;

                        widget.onVideoPosition?.call(_currentPosition);
                                        
                        // 播放到裁剪结束位置时暂停
                        // if(_trimEndTime != Duration.zero){
                        //   if(_isPlaying && _currentPosition >= _trimEndTime){
                        //     await videoPlayerController.pause();
                        //     _currentPosition = _trimEndTime;
                        //     await videoPlayerController.seek(_trimEndTime);
                        //   }
                        // }
                                        
                        if(_videoDuration != Duration.zero){
                          widget.onVideoDuration?.call(_videoDuration);
                          if(widget.trimEndTime != null){ // 如果 初始化裁剪位置 大于视频的长度 那么裁剪位置设置为视频长度
                            if(widget.trimEndTime! > _videoDuration){
                              _trimEndTime = _videoDuration;
                              _trimEndTimeController.text = DateFormatUtil.millisecondsToSecondsWithDecimal(_videoDuration.inMilliseconds);
                              widget.onTrim?.call(_trimStartTime, _trimEndTime ?? _videoDuration, _isMuted);
                            }
                          }
                        }
                                        
                        if(!initDuration && _videoDuration != Duration.zero){
                          initDuration = true;
                          if(_trimEndTime == Duration.zero){
                            _trimEndTime = _videoDuration;
                            widget.onTrim?.call(_trimStartTime, _trimEndTime??_videoDuration, _isMuted);
                          }
                          
                          _trimEndTimeController.text = DateFormatUtil.millisecondsToSecondsWithDecimal(_videoDuration.inMilliseconds);
                                        
                        }
                        if(mounted) setState(() {});
                      },
                    ),
                    
                  ],
                ),
              ),
            ),
          ),

          Visibility(
            visible: widget.ass != null || widget.translate != null,
            child: VideoAssTextWidget(
              ass: widget.ass,
              translate: widget.translate,
              translateLangCode: widget.translateCode,
              position: _currentPosition,
              assFontSize: 38.wMin,
              translateFontSize: 22.wMin,

            ),
          ),

          _buildControlWidget(),
        ],
      ),
    );
  }

  Widget _buildControlWidget(){
    return Container(
      margin: EdgeInsets.only(top: 16.wMin),
      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDropWidget(),
          SizedBox(height: 6.wMin),
          _buildProgressWidget(),
        ],
      ),
    );
  }
  
  Widget _buildProgressWidget(){
    double startMaxValue = (_trimEndTime??_videoDuration).inMilliseconds / 1000;
    double endMaxValue = _videoDuration.inMilliseconds / 1000;

    // 裁剪结束时间 减去 裁剪开始时间
    double inputStart = double.tryParse(_trimStartTimeController.text)??0;
    int startDou = (inputStart * 100).toInt();
    double inputEnd = double.tryParse(_trimEndTimeController.text)??0;
    int endDou = (inputEnd * 100).toInt();
    double clipDuration = (endDou - startDou) / 100;
    

    return Row(
      children: [

        TapScaleWidget(
          onTap: () async{
            videoPlayerController.playOrPause();
          },
          sclae: 1.1,
          child: Container(
            padding: EdgeInsets.all(6.wMin),
            color: Colors.transparent,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 38.wMin,
                key: ValueKey(_isPlaying),
              ),
            ),
          ),
        ),

        IgnorePointer(
          ignoring: widget.disableEditing,
          child: TapScaleWidget(
            onTap: () {
              if(_isMuted){
                _isMuted = false;
                videoPlayerController.setVolume(100);
              }else{
                _isMuted = true;
                videoPlayerController.setVolume(0);
              }
              widget.onTrim?.call(_trimStartTime, _trimEndTime ?? _videoDuration, _isMuted);
              if(mounted) setState(() {});
            },
            sclae: 1.1,
            child: Container(
              padding: EdgeInsets.all(10.wMin),
              color: Colors.transparent,
              child: SvgPicture.asset(
                _isMuted ? "assets/svg/public/icon_mute.svg" : "assets/svg/public/icon_volume.svg",
                width: 28.wMin,
              ),
            ),
          ),
        ),

        Text(
          DateFormatUtil.formatMillisecondsToMinSec(_currentPosition),
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),

        Text(
          " / ${DateFormatUtil.formatMillisecondsToMinSec(_videoDuration)}",
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),

        const Spacer(),

        SvgPicture.asset(
          "assets/svg/public/icon_scissors.svg",
          width: 24.wMin,
        ),

        SizedBox(width: 10.wMin),

        _buildNumberInputWidget(
          minValue: 0,
          maxValue: startMaxValue - 0.1,
          controller: _trimStartTimeController,
          onChange: (duration) {
            _trimStartTime = duration;
            if(mounted) setState(() {});
            widget.onTrim?.call(_trimStartTime, _trimEndTime ?? _videoDuration, _isMuted);
          },
        ),
        SizedBox(width: 10.wMin),
        Container(width: 10.wMin, height: 2.wMin, color: Colors.white.withValues(alpha: 0.6)),
        SizedBox(width: 10.wMin),
        _buildNumberInputWidget(
          minValue: _trimStartTime.inMilliseconds / 1000 + 0.1,
          maxValue: endMaxValue,
          controller: _trimEndTimeController,
          onChange: (duration) {
            _trimEndTime = duration;
            if(mounted) setState(() {});
            widget.onTrim?.call(_trimStartTime, _trimEndTime ?? _videoDuration, _isMuted);
          },
        ),
        Container(
          width: 60.wMin,
          alignment: Alignment.centerRight,
          child: Text(
            "${clipDuration.toStringAsFixed(2)}s",
            style: TextStyle(
              fontSize: 16.wMin,
              color: const Color(0xff38BDF8),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

      ],
    );
  }



  Widget _buildNumberInputWidget({
    required double minValue,
    required double maxValue,
    required TextEditingController controller,
    void Function(Duration duration)? onChange,
  }){

    return Container(
      width: 100.wMin,
      height: 40.wMin,
      padding: EdgeInsets.only(left: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.wMin),
        color: Colors.black.withValues(alpha: 0.4),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !widget.disableEditing,
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              inputFormatters: [
                DecimalTextInputFormatter(maxValue: maxValue),
              ],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
              },
              onChanged: (value) {
                final seconds = double.tryParse(value) ?? 0;
                final milliseconds = (seconds * 1000).toInt();
                final newDuration = Duration(milliseconds: milliseconds);
                onChange?.call(newDuration);
              },
            ),
          ),

          Visibility(
            visible: !widget.disableEditing,
            child: Column(
              children: [
                Expanded(
                  child: TapScaleWidget(
                    onTap: () {
                      // 从输入框获取当前值
                      final currentSeconds = double.tryParse(controller.text) ?? 0;
                      final currentMilliseconds = (currentSeconds * 1000).toInt();
                      // 增加10毫秒
                      final newMilliseconds = currentMilliseconds + 10;
                      final maxMilliseconds = (maxValue * 1000).toInt();
                      if (newMilliseconds <= maxMilliseconds) {
                        final newDuration = Duration(milliseconds: newMilliseconds);
                        controller.text = DateFormatUtil.millisecondsToSecondsWithDecimal(newMilliseconds);
                        onChange?.call(newDuration);
                        if (mounted) setState(() {});
                      }
                    },
                    sclae: 1.2,
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.transparent,
                      child: SvgPicture.asset(
                        "assets/svg/manage/icon_chevron_up.svg",
                        width: 24.wMin,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TapScaleWidget(
                    onTap: () {
                      // 从输入框获取当前值
                      final currentSeconds = double.tryParse(controller.text) ?? 0;
                      final currentMilliseconds = (currentSeconds * 1000).toInt();
                      // 减少10毫秒
                      final newMilliseconds = currentMilliseconds - 10;
                      final minMilliseconds = (minValue * 1000).toInt();
                      if (newMilliseconds >= minMilliseconds) {
                        final newDuration = Duration(milliseconds: newMilliseconds);
                        controller.text = DateFormatUtil.millisecondsToSecondsWithDecimal(newMilliseconds);
                        onChange?.call(newDuration);
                        if (mounted) setState(() {});
                      }
                    },
                    sclae: 1.1,
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.transparent,
                      child: SvgPicture.asset(
                        "assets/svg/manage/icon_chevron_down.svg",
                        width: 24.wMin,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }



  /// 手动脱拽区域
  Widget _buildDropWidget(){
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final handleWidthPx = _handleWidth.wMin;
        // 可用于时间轴的宽度（去掉两个手柄）
        final timelineWidth = totalWidth - handleWidthPx * 2;
        
        // 计算开始和结束位置的比例
        final totalMs = _videoDuration.inMilliseconds;
        if (totalMs == 0) {
          return Container(
            height: 40.wMin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.wMin),
              color: const Color(0xff1D2021).withValues(alpha: 0.9),
            ),
          );
        }
        
        final startRatio = _trimStartTime.inMilliseconds / totalMs;
        final endRatio = (_trimEndTime??_videoDuration).inMilliseconds / totalMs;
        
        // 左侧灰色区域宽度
        final leftGrayWidth = startRatio * timelineWidth;
        // 右侧灰色区域宽度
        final rightGrayWidth = (1 - endRatio) * timelineWidth;
        // 中间选中区域宽度
        final selectedWidth = timelineWidth - leftGrayWidth - rightGrayWidth;
        
        // 当前播放位置比例
        final currentRatio = _currentPosition.inMilliseconds / totalMs;
        // 播放位置指示器的x坐标（相对于整个容器）
        final playheadX = handleWidthPx + currentRatio * timelineWidth;
        
        // 左侧手柄的x位置
        final leftHandleX = startRatio * timelineWidth;
        // 右侧手柄的x位置
        final rightHandleX = endRatio * timelineWidth + handleWidthPx;
        
        return Container(
          height: 40.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.wMin),
            color: const Color(0xff1D2021).withValues(alpha: 0.9),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 刻度线
              Positioned.fill(
                left: 0,
                right: handleWidthPx,
                child: CustomPaint(
                  painter: _TimelineTickPainter(
                    totalDuration: _videoDuration,
                    tickColor: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
              // 左侧灰色区域（未选中）
              Positioned(
                left: handleWidthPx,
                top: 0,
                bottom: 0,
                width: leftGrayWidth,
                child: Container(),
              ),
              // 点击时间轴定位播放位置
              Positioned(
                left: handleWidthPx,
                right: handleWidthPx,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTapDown: (details) {
                    _onTimelineTap(details, timelineWidth, totalMs);
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),
              // 中间选中区域
              Positioned(
                left: handleWidthPx + leftGrayWidth,
                top: 0,
                bottom: 0,
                width: selectedWidth,
                child: GestureDetector(
                  onTapDown: (details) {
                    // 计算相对于整个时间轴的位置
                    final tapX = leftGrayWidth + details.localPosition.dx;
                    _onTimelineTapAtX(tapX, timelineWidth, totalMs);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff38BDF8).withValues(alpha: 0.2),
                      border: Border.symmetric(
                        horizontal: BorderSide(width: 2.wMin, color: const Color(0xff38BDF8)),
                      ),
                    ),
                  ),
                ),
              ),
              // 右侧灰色区域（未选中）
              Positioned(
                left: handleWidthPx + leftGrayWidth + selectedWidth,
                top: 0,
                bottom: 0,
                width: rightGrayWidth,
                child: Container(),
              ),
              // 左侧手柄
              Positioned(
                left: leftHandleX,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  ignoring: widget.disableEditing,
                  child: GestureDetector(
                    onHorizontalDragStart: (details) {
                      videoPlayerController.pause();
                    },
                    onHorizontalDragUpdate: (details) {
                      _onLeftHandleDrag(details, timelineWidth, totalMs);
                    },
                    onHorizontalDragEnd: (details) {
                      _onHandleDragEnd();
                    },
                    child: _buildDropMouseWidget(),
                  ),
                ),
              ),
              // 右侧手柄
              Positioned(
                left: rightHandleX,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  ignoring: widget.disableEditing,
                  child: GestureDetector(
                    onHorizontalDragStart: (details) {
                      videoPlayerController.pause();
                    },
                    onHorizontalDragUpdate: (details) {
                      _onRightHandleDrag(details, timelineWidth, totalMs);
                    },
                    onHorizontalDragEnd: (details) {
                      _onHandleDragEnd();
                    },
                    child: _buildDropMouseWidget(isLeft: false),
                  ),
                ),
              ),
              // 当前播放位置指示器（白色竖线）
              Positioned(
                left: playheadX - 6.wMin,
                top: -12.wMin,
                bottom: 0,
                child: Column(
                  children: [
                    Container(
                      width: 12.wMin,
                      height: 12.wMin,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 2.wMin,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 左侧手柄拖拽处理
  void _onLeftHandleDrag(DragUpdateDetails details, double timelineWidth, int totalMs) {
    final delta = details.delta.dx;
    final deltaMs = (delta / timelineWidth * totalMs).round();
    
    var newStartMs = _trimStartTime.inMilliseconds + deltaMs;
    // 约束：不能小于0
    newStartMs = newStartMs.clamp(0, totalMs);
    // 约束：开始时间不能超过结束时间 - 最小间隔
    final maxStartMs = (_trimEndTime??_videoDuration).inMilliseconds - _minTrimGapMs;
    newStartMs = newStartMs.clamp(0, maxStartMs);
    
    _trimStartTime = Duration(milliseconds: newStartMs);
    _trimStartTimeController.text = DateFormatUtil.millisecondsToSecondsWithDecimal(newStartMs);
    _currentPosition = _trimStartTime;
    videoPlayerController.seek(_trimStartTime);
    widget.onTrim?.call(_trimStartTime, _trimEndTime ?? _videoDuration, _isMuted);
    if (mounted) setState(() {});
  }

  /// 右侧手柄拖拽处理
  void _onRightHandleDrag(DragUpdateDetails details, double timelineWidth, int totalMs) {
    final delta = details.delta.dx;
    final deltaMs = (delta / timelineWidth * totalMs).round();
    
    var newEndMs = (_trimEndTime??_videoDuration).inMilliseconds + deltaMs;
    // 约束：不能超过总时长
    newEndMs = newEndMs.clamp(0, totalMs);
    // 约束：结束时间不能低于开始时间 + 最小间隔
    final minEndMs = _trimStartTime.inMilliseconds + _minTrimGapMs;
    newEndMs = newEndMs.clamp(minEndMs, totalMs);
    
    _trimEndTime = Duration(milliseconds: newEndMs);
    _trimEndTimeController.text = DateFormatUtil.millisecondsToSecondsWithDecimal(newEndMs);
    _currentPosition = _trimEndTime ?? _videoDuration;
    videoPlayerController.seek(_trimEndTime ?? _videoDuration);
    widget.onTrim?.call(_trimStartTime, _trimEndTime ?? _videoDuration, _isMuted);
    if (mounted) setState(() {});
  }

  /// 拖拽结束后seek到开始位置并播放
  Future<void> _onHandleDragEnd() async {
    _setResource();
  }

  /// 点击时间轴定位播放位置
  void _onTimelineTap(TapDownDetails details, double timelineWidth, int totalMs) {
    final tapX = details.localPosition.dx;
    _onTimelineTapAtX(tapX, timelineWidth, totalMs);
  }

  /// 根据x坐标定位播放位置
  void _onTimelineTapAtX(double tapX, double timelineWidth, int totalMs) async {
    final ratio = (tapX / timelineWidth).clamp(0.0, 1.0);
    final targetMs = (ratio * totalMs).round();
    final targetDuration = Duration(milliseconds: targetMs);
    
    await videoPlayerController.seek(targetDuration);
    if (mounted) setState(() {});
  }


  Widget _buildDropMouseWidget({bool isLeft = true}){
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.wMin),
        width: 14.wMin,
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.horizontal(
            left: !isLeft ? Radius.zero : Radius.circular(4.wMin),
            right: isLeft ? Radius.zero : Radius.circular(4.wMin),
          ),
          color: const Color(0xff38BDF8),
        ),
        child: Container(
          width: 2.wMin,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2.wMin),
          ),
        ),
      ),
    );
  }




}

/// 时间轴刻度线绘制器
class _TimelineTickPainter extends CustomPainter {
  final Duration totalDuration;
  final Color tickColor;

  _TimelineTickPainter({
    required this.totalDuration,
    required this.tickColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final totalSeconds = totalDuration.inMilliseconds / 1000;
    if (totalSeconds <= 0) return;

    final paint = Paint()
      ..color = tickColor
      ..strokeWidth = 1;

    // 每秒一个刻度
    final secondCount = totalSeconds.ceil();
    for (int i = 0; i <= secondCount; i++) {
      final x = (i / totalSeconds) * size.width;
      if (x > size.width) break;
      
      // 整秒刻度线高度
      final tickHeight = size.height * 0.3;
      final startY = size.height - tickHeight;
      
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimelineTickPainter oldDelegate) {
    return oldDelegate.totalDuration != totalDuration ||
           oldDelegate.tickColor != tickColor;
  }
}