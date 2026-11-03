import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../theme/theme.dart';
import '../../utils/utils.dart';
import 'widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

class AnimationPlayTextSelectWidget extends StatefulWidget {
  final String? audioUrl;
  final String text;
  final double? iconSize;
  final TextStyle? textStyle;
  final Color? backColor;
  final EdgeInsets? padding;
  final double sclae;
  final double spacing;
  final double radius;
  final void Function()? onTap;
  const AnimationPlayTextSelectWidget({
    super.key,
    this.audioUrl,
    required this.text,
    this.iconSize,
    this.textStyle,
    this.backColor,
    this.padding,
    this.sclae = 1.03,
    this.spacing = 0,
    this.radius = 0,
    this.onTap,
  });

  @override
  State<AnimationPlayTextSelectWidget> createState() => _AnimationPlayTextSelectWidgetState();
}

class _AnimationPlayTextSelectWidgetState extends State<AnimationPlayTextSelectWidget> {
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: () async {
        widget.onTap?.call();
        if (widget.audioUrl == null) return;
        isPlaying = true;
        if (mounted) setState(() {});
        await PlayAudioUtils.instance.playSingle(widget.audioUrl);
        isPlaying = false;
        if (mounted) setState(() {});
      },
      sclae: widget.sclae,
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          color: widget.backColor,
        ),
        child: Container(
          color: Colors.transparent,
          child: Row(
            spacing: widget.spacing,
            children: [
              AnimationPlayIconWidget(isPlaying: isPlaying, size: widget.iconSize),
              Text(
                widget.text,
                style: widget.textStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimationPlayIconWidget extends StatefulWidget {
  final bool isPlaying;
  final double? size;

  /// 播放按钮动画
  const AnimationPlayIconWidget({super.key, this.isPlaying = false, this.size});

  @override
  State<AnimationPlayIconWidget> createState() => _AnimationPlayIconWidgetState();
}

class _AnimationPlayIconWidgetState extends State<AnimationPlayIconWidget> {
  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/lottie/icon_speaker.json',
      key: ValueKey(widget.isPlaying),
      repeat: true,
      animate: widget.isPlaying,
      width: widget.size,
      height: widget.size,
    );
  }
}

class PlayLottieIconController {
  _PlayLottieIconWidgetState? _state;

  void play() {
    _state?.play();
  }
}

class PlayLottieIconWidget extends StatefulWidget {
  final double? size;
  final String? audioUrl;
  final Color? backgroundColor;
  final String? backgroundImageUrl;
  final double? tapPadding;
  final double? childPadding;
  final Function()? onTap;
  final double? playSpeed;
  final PlayLottieIconController? controller;
  const PlayLottieIconWidget({
    super.key,
    this.size,
    this.audioUrl,
    this.backgroundColor,
    this.backgroundImageUrl,
    this.tapPadding,
    this.childPadding,
    this.onTap,
    this.playSpeed,
    this.controller,
  });

  @override
  State<PlayLottieIconWidget> createState() => _PlayLottieIconWidgetState();
}

class _PlayLottieIconWidgetState extends State<PlayLottieIconWidget> {
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
  }

  Future<void> play() async {
    widget.onTap?.call();
    if (widget.audioUrl == null) return;

    if (isPlaying) {
      await PlayAudioUtils.instance.stopAll();
      isPlaying = false;
      if (mounted) setState(() {});
      return;
    }

    isPlaying = true;
    if (mounted) setState(() {});
    await PlayAudioUtils.instance.playSingle(widget.audioUrl,playbackRate: widget.playSpeed);
    isPlaying = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audioUrl == null) return Container();
    return TapScaleWidget(
      onTap: () {
        play();
      },
      sclae: 1.05,
      child: Container(
        padding: EdgeInsets.all(widget.tapPadding ?? 10.wMin),
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(widget.childPadding ?? 10.wMin),
          alignment: Alignment.center,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.backgroundColor,
            image: widget.backgroundImageUrl != null
                ? DecorationImage(
                    image: NetworkImage(widget.backgroundImageUrl ?? ""),
                    opacity: 0.8,
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: Lottie.asset(
            'assets/lottie/icon_speaker_w.json',
            key: ValueKey(isPlaying),
            repeat: true,
            animate: isPlaying,
          ),
        ),
      ),
    );
  }
}


class AnimationPlayIconTextWidget extends StatefulWidget {
  final double? iconSize;
  final String? audioUrl;
  final Color? backgroundColor;
  final String? backgroundImageUrl;
  final String? phonetic;
  final String? nationalTitle;
  final double? tapPadding;
  final double? childPadding;
  final double? playSpeed;
  const AnimationPlayIconTextWidget({
    super.key,
    this.iconSize,
    this.audioUrl,
    this.backgroundColor,
    this.backgroundImageUrl,
    this.phonetic,
    this.nationalTitle,
    this.tapPadding,
    this.childPadding,
    this.playSpeed,
  });

  @override
  State<AnimationPlayIconTextWidget> createState() => _AnimationPlayIconTextWidgetState();
}

class _AnimationPlayIconTextWidgetState extends State<AnimationPlayIconTextWidget> {
  PlayLottieIconController controller = PlayLottieIconController();
  
  @override
  Widget build(BuildContext context) {
    if(widget.audioUrl == null) return Container();
    return TapScaleWidget(
      onTap: () {
        controller.play();
      },
      sclae: 1.01,
      child: Container(
        padding: EdgeInsets.only(
          left: 4.wMin,
          right: 12.wMin,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8.wMin,
          children: [
            PlayLottieIconWidget(
              size: widget.iconSize,
              childPadding: widget.childPadding,
              backgroundImageUrl: widget.backgroundImageUrl,
              backgroundColor: widget.backgroundColor,
              tapPadding: widget.tapPadding,
              audioUrl: widget.audioUrl,
              controller: controller,
            ),
            Text(
              widget.nationalTitle??"",
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
            Visibility(
              visible: widget.phonetic != null,
              child: Text(
                "/ ${widget.phonetic??''} /",
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextSecondary.color,
                  fontWeight: FontWeight.w400,
                  fontFamily: "AndikaRegular",
                ),
              ),
            ),
      
          ],
        ),
      ),
    );
  }
}