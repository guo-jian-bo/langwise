import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../theme/theme.dart';
import '../../utils/utils.dart';
import '../entities/entities.dart';
import '../public_controller/config_controller.dart';
import '../public_controller/model/user_setting_model.dart';
import '../public_controller/player_global_settings_controller.dart';
import 'widgets.dart';

class ShowBigResourceDialog {
  /// 是否显示了弹窗
  static bool isShow = false;

  static Future<int?> showImage({
    required BuildContext context,
    required List<String> imageUrls,
    int index = 0,
  }) async {
    isShow = true;
    int? res = await showDialog<int?>(
      context: context,
      useSafeArea: false,
      builder: (context) {
        return ShowBigImageDialogWidget(
          imageUrls: imageUrls,
          index: index,
        );
      },
    );
    isShow = false;
    return res;
  }

  /// * [isLearn] 是否是学习类 如果是课程题目 设置为true
  static Future<void> showVideo({
    required BuildContext context,
    required EnKnowledgeEntityRelationVideo? relationVideo,
    String translateLangCode = "zh",
    bool isLearn = false,
    double aspectRatio = 1,
    bool useAspectRatio = true,
    /// 是否显示字幕设置
    bool showSubtitleSetting = true,
  }) async {
    if (relationVideo == null) return;
    if (relationVideo.videoUrl == null) return;

    isShow = true;

    await showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) {
        return ShowBigVideoDialogWidget(
          relationVideo: relationVideo,
          translateLangCode: translateLangCode,
          isLearn: isLearn,
          aspectRatio: aspectRatio,
          useAspectRatio: useAspectRatio,
          showSubtitleSetting: showSubtitleSetting,
        );
      },
    );

    isShow = false;
  }
}

class ShowBigImageDialogWidget extends StatefulWidget {
  final List<String> imageUrls;
  final int index;
  const ShowBigImageDialogWidget({super.key, required this.imageUrls, required this.index});

  @override
  State<ShowBigImageDialogWidget> createState() => _ShowBigImageDialogWidgetState();
}

class _ShowBigImageDialogWidgetState extends State<ShowBigImageDialogWidget> {
  late PageController pageController;

  final _viewController = PhotoViewController();

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.index;
    pageController = PageController(initialPage: widget.index);
  }

  bool _isLocalImagePath(String path) {
    if (path.isEmpty) return false;
    if (path.startsWith('file://')) return true;
    return File(path).existsSync();
  }

  String _normalizeLocalImagePath(String path) {
    if (!path.startsWith('file://')) return path;
    return Uri.parse(path).toFilePath();
  }

  Widget _buildPreviewImageWidget(String imageUrl) {
    if (_isLocalImagePath(imageUrl)) {
      return Image.file(
        File(_normalizeLocalImagePath(imageUrl)),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => buildEmptyWidget(),
      );
    }
    return CachedImageWidget(
      imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.contain,
      placeholder: buildLoadingWidget(),
      errorWidget: buildEmptyWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: OptimizeUtils.noneThrottle(() {
        Get.back(result: currentIndex);
      }, 1000),
      child: Material(
        color: AppTheme.cBgPrimary.color,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Listener(
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent) {
                    final delta = event.scrollDelta.dy;
                    final scale = _viewController.scale ?? 1.0;
                    final newScale = scale - delta / 1000;
                    _viewController.scale = newScale.clamp(0.2, 10.0);
                  }
                },
                child: PhotoViewGallery.builder(
                  scrollPhysics: const ClampingScrollPhysics(),
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions.customChild(
                      controller: _viewController,
                      childSize: MediaQuery.of(context).size,
                      initialScale: PhotoViewComputedScale.contained,
                      maxScale: 2.0,
                      minScale: 0.1,
                      heroAttributes: PhotoViewHeroAttributes(tag: widget.imageUrls[index]),
                      child: _buildPreviewImageWidget(widget.imageUrls[index]),
                    );
                  },
                  itemCount: widget.imageUrls.length,
                  loadingBuilder: (context, event) => Center(
                    child: Center(
                      child: SpinKitFadingCircle(
                        color: AppTheme.cBgBrand.color,
                        size: 100.wMin,
                      ),
                    ),
                  ),
                  backgroundDecoration: BoxDecoration(color: AppTheme.cBgPrimary.color),
                  pageController: pageController,
                  onPageChanged: (index) {
                    currentIndex = index;
                    if (mounted) setState(() {});
                  },
                ),
              ),
            ),
            Positioned(
              right: 24.wMin + MediaQuery.of(context).padding.right,
              top: 24.wMin + MediaQuery.of(context).padding.top,
              child: TapScaleWidget(
                sclae: 1.05,
                onTap: () => Get.back(result: currentIndex),
                child: Container(
                  width: 56.wMin,
                  height: 56.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cSurfaceTertiary.color,
                  ),
                  child: SvgPicture.asset(
                    "assets/svg/public/x.svg",
                    width: 32.wMin,
                    height: 32.wMin,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 24.wMin + MediaQuery.of(context).padding.right,
              bottom: 24.wMin + MediaQuery.of(context).padding.bottom,
              child: Visibility(
                visible: widget.imageUrls.length > 1,
                child: Container(
                  padding: EdgeInsets.all(8.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfaceTertiary.color,
                    borderRadius: BorderRadius.circular(8.wMin),
                  ),
                  child: Text(
                    "${currentIndex + 1}/${widget.imageUrls.length}",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 48.wMin + MediaQuery.of(context).padding.left,
              child: Visibility(
                visible: widget.imageUrls.length > 1,
                child: TapScaleWidget(
                  onTap: () {
                    if (currentIndex <= 0) return;
                    pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  sclae: 1.05,
                  child: Container(
                    width: 80.wMin,
                    height: 80.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.cSurfaceTertiary.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: AppTheme.cTextPrimary.color,
                      size: 48.wMin,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 48.wMin + MediaQuery.of(context).padding.left,
              child: Visibility(
                visible: widget.imageUrls.length > 1,
                child: TapScaleWidget(
                  onTap: () {
                    if (currentIndex >= widget.imageUrls.length - 1) return;
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  sclae: 1.05,
                  child: Container(
                    width: 80.wMin,
                    height: 80.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.cSurfaceTertiary.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppTheme.cTextPrimary.color,
                      size: 48.wMin,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShowBigVideoDialogWidget extends StatefulWidget {
  final EnKnowledgeEntityRelationVideo relationVideo;
  final String translateLangCode;

  /// 是否是学习类 如果是课程题目 设置为true
  final bool isLearn;
  final double aspectRatio;

  /// 是否优先按外部传入的宽高比显示视频。
  final bool useAspectRatio;

  /// 是否显示字幕设置
  final bool showSubtitleSetting;

  const ShowBigVideoDialogWidget({
    super.key,
    required this.relationVideo,
    this.translateLangCode = "zh",
    this.isLearn = false,
    this.aspectRatio = 1,
    this.useAspectRatio = true,
    this.showSubtitleSetting = true,
  });

  @override

  /// 创建视频弹窗对应的状态对象。
  State<ShowBigVideoDialogWidget> createState() => _ShowBigVideoDialogWidgetState();
}

class _ShowBigVideoDialogWidgetState extends State<ShowBigVideoDialogWidget> {
  static const Duration _progressSnapTolerance = Duration(milliseconds: 50);
  final PlayerGlobalSettingsController playerGlobalSettingsController = Get.find<PlayerGlobalSettingsController>();

  final Player _player = Player();
  late final VideoController _videoWidgetController = VideoController(_player);
  String? videoFileUrl;
  Duration positionDuration = Duration.zero;
  StreamSubscription<bool>? _playingSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<bool>? _completedSubscription;
  StreamSubscription<int?>? _videoWidthSubscription;
  StreamSubscription<int?>? _videoHeightSubscription;

  /// 当前视频的真实总时长，优先使用接口值，缺失时由播放器回填。
  Duration mediaDuration = Duration.zero;
  bool isDragging = false;
  bool isPlaying = false;
  int volume = 100;
  double playSpeed = 1.0;

  /// 当前视频的真实宽高比，来自播放器回调。
  double videoAspectRatio = 0;

  bool loading = true;

  /// 翻译状态
  LangPreference translateType = LangPreference.bilingual;

  /// 文字大小倍数
  FontSizeEnum contentFontSizeMultiple = FontSizeEnum.standard;

  /// 是否显示翻译菜单
  bool showTranslateMenu = false;

  @override

  /// 初始化视频地址、字幕数据以及键盘快捷键监听。
  void initState() {
    super.initState();
    _listenPlayer();
    initUrl();
    initUserSetting();
  }

  /// 监听播放器状态，驱动弹窗内的播放进度、时长与尺寸显示。
  void _listenPlayer() {
    _playingSubscription = _player.stream.playing.listen((playing) {
      if (isPlaying == playing) return;
      isPlaying = playing;
      if (mounted) setState(() {});
    });

    _durationSubscription = _player.stream.duration.listen((duration) {
      if (duration == Duration.zero || mediaDuration == duration) return;
      mediaDuration = duration;
      if (mounted) setState(() {});
    });

    _positionSubscription = _player.stream.position.listen((duration) {
      final Duration currentPosition = normalizeProgressDuration(duration);
      bool needRefresh = false;
      if (positionDuration != currentPosition && !isDragging) {
        positionDuration = currentPosition;
        needRefresh = true;
      }
      if (duration != Duration.zero && loading) {
        loading = false;
        needRefresh = true;
      }
      if (needRefresh && mounted) {
        setState(() {});
      }
    });

    _completedSubscription = _player.stream.completed.listen((completed) async {
      if (!completed) return;
      await _player.pause();
      await _player.seek(clipStartDuration);
      positionDuration = clipStartDuration;
      isPlaying = false;
      if (mounted) setState(() {});
    });

    _videoWidthSubscription = _player.stream.width.listen((width) {
      _updateVideoAspectRatio(width: width);
    });
    _videoHeightSubscription = _player.stream.height.listen((height) {
      _updateVideoAspectRatio(height: height);
    });
  }

  /// 根据播放器回调的原始宽高更新视频展示比例。
  void _updateVideoAspectRatio({int? width, int? height}) {
    final int currentWidth = width ?? _player.state.width ?? 0;
    final int currentHeight = height ?? _player.state.height ?? 0;
    if (currentWidth <= 0 || currentHeight <= 0) return;
    final double currentVideoAspectRatio = currentWidth / currentHeight;
    if (videoAspectRatio == currentVideoAspectRatio) return;
    videoAspectRatio = currentVideoAspectRatio;
    if (mounted) setState(() {});
  }

  /// 获取本地储存的设置
  Future<void> initUserSetting() async {
    if (Get.isRegistered<ConfigController>()) {
      UserSettingModel userSetting = Get.find<ConfigController>().userSetting.value;

      if (widget.isLearn) {
        translateType = userSetting.courseLang;
        playSpeed = userSetting.courseAudioSpeed;
      }
    }
    if (widget.isLearn) {
      AudioControlSettingModel? setting = AudioControlUtils.getSetting();
      contentFontSizeMultiple = setting?.fontSize ?? FontSizeEnum.standard;
      volume = setting?.volume ?? 100;
      return;
    }
    translateType = playerGlobalSettingsController.subtitleDisplay.value;
    playSpeed = playerGlobalSettingsController.playbackRate.value;
    contentFontSizeMultiple = playerGlobalSettingsController.audioFontSize.value;
    volume = playerGlobalSettingsController.volume.value;
  }

  /// 获取当前片段在原视频中的起始时间。
  Duration get clipStartDuration => DateFormatUtil.secondsToDuration(widget.relationVideo.startSeconds ?? 0);

  /// 获取当前片段在原视频中的结束时间，并确保不会越界。
  Duration get clipEndDuration {
    Duration rawDuration = mediaDuration;
    Duration endDuration =
        widget.relationVideo.endSeconds == null ? rawDuration : DateFormatUtil.secondsToDuration(widget.relationVideo.endSeconds ?? 0);
    if (endDuration < clipStartDuration) {
      return clipStartDuration;
    }
    if (rawDuration != Duration.zero && endDuration > rawDuration) {
      return rawDuration;
    }
    return endDuration;
  }

  /// 计算当前裁剪片段的总时长。
  Duration get clipDuration {
    Duration duration = clipEndDuration - clipStartDuration;
    if (duration.isNegative) {
      return Duration.zero;
    }
    return duration;
  }

  /// 将传入时间限制在当前片段的起止区间内。
  Duration clampToClipRange(Duration duration) {
    if (duration < clipStartDuration) {
      return clipStartDuration;
    }
    if (duration > clipEndDuration) {
      return clipEndDuration;
    }
    return duration;
  }

  /// 规范化播放进度，吸附到片段首尾附近，避免细微误差影响显示。
  Duration normalizeProgressDuration(Duration duration) {
    Duration clampedDuration = clampToClipRange(duration);
    Duration startOffset = clampedDuration - clipStartDuration;
    if (startOffset.abs() <= _progressSnapTolerance) {
      return clipStartDuration;
    }

    Duration endOffset = clipEndDuration - clampedDuration;
    if (endOffset.abs() <= _progressSnapTolerance) {
      return clipEndDuration;
    }

    return clampedDuration;
  }

  @override
  void dispose() {
    _playingSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _completedSubscription?.cancel();
    _videoWidthSubscription?.cancel();
    _videoHeightSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  /// 初始化视频缓存地址并打开播放器，同时按片段范围设置播放区间。
  Future<void> initUrl() async {
    if (widget.relationVideo.videoUrl == null) return;
    try {
      mediaDuration = DateFormatUtil.secondsToDuration(widget.relationVideo.duration ?? 0);
      positionDuration = clipStartDuration;

      Future<String?> cacheFuture = CacheManagerUtils.instance.getFile(widget.relationVideo.videoUrl, ResourceType.video);
      String? fastCachePath;
      try {
        fastCachePath = await cacheFuture.timeout(const Duration(milliseconds: 350));
      } catch (_) {}

      if (fastCachePath != null && fastCachePath.isNotEmpty) {
        videoFileUrl = fastCachePath;
      } else {
        videoFileUrl = widget.relationVideo.videoUrl;
      }
      if (videoFileUrl == null) return;

      Duration startSeconds = clipStartDuration;
      Duration endSeconds = clipEndDuration;

      await _player.open(
        Media(
          videoFileUrl ?? "",
          start: startSeconds,
          end: endSeconds == Duration.zero ? null : endSeconds,
        ),
        play: false,
      );
      if (widget.relationVideo.isMute == true) {
        await _player.setVolume(0);
      }
      await _player.setRate(playSpeed);
      await _player.setPlaylistMode(PlaylistMode.none);
      await _player.play();

      unawaited(cacheFuture);
    } finally {
      if (mounted) setState(() {});
    }
  }

  /// 修改播放音量
  Future<void> onVolumeChange(int value) async {
    volume = value;
    if (mounted) setState(() {});
    await _player.setVolume(value.toDouble());
    if (widget.isLearn) {
      AudioControlUtils.saveSetting(AudioControlSettingModel(volume: value));
      return;
    }
    await playerGlobalSettingsController.onVolumeChange(value);
  }

  /// 修改播放速度
  void changePlaySpeed(double speed) async {
    playSpeed = speed;
    if (mounted) setState(() {});
    await _player.setRate(speed);
    if (widget.isLearn) {
      ConfigController configController = Get.find<ConfigController>();
      configController.setUserSetting(courseAudioSpeed: speed);
      return;
    }
    await playerGlobalSettingsController.onPlaybackRateChange(speed);
  }

  /// 改变翻译状态
  Future<void> onSubtitleChange(LangPreference value) async {
    translateType = value;
    if (mounted) setState(() {});
    if (widget.isLearn) {
      ConfigController configController = Get.find<ConfigController>();
      configController.setUserSetting(courseTranslationType: value.code);
      return;
    }
    await playerGlobalSettingsController.onSubtitleDisplayChange(value);
  }

  /// 改变文字大小倍数
  Future<void> onSubtitleFontSizeChange(FontSizeEnum value) async {
    contentFontSizeMultiple = value;
    if (mounted) setState(() {});
    if (widget.isLearn) {
      AudioControlUtils.saveSetting(AudioControlSettingModel(fontSize: value));
      return;
    }
    await playerGlobalSettingsController.onFontSizeChange(value);
  }

  @override

  /// 构建大视频弹窗整体布局，包括播放器、字幕区和底部控制栏。
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          color: Colors.transparent,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    SizedBox(height: 20.wMin + MediaQuery.of(context).padding.top),
                    Expanded(child: _buildVideoWidget()),
                    _buildVideoSubtitlesWidget(),
                  ],
                ),
              ),
              Positioned(
                right: 100.wMin + MediaQuery.of(context).padding.right,
                top: 24.wMin + MediaQuery.of(context).padding.top,
                child: _buildCloseWidget(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildVideoControlsWidget(),
    );
  }

  /// 构建右上角关闭按钮。
  Widget _buildCloseWidget() {
    return TapScaleWidget(
      sclae: 1.05,
      onTap: () => Get.back(),
      child: Container(
        width: 56.wMin,
        height: 56.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.cSurfaceQuaternary.color,
        ),
        child: SvgPicture.asset(
          "assets/svg/public/x.svg",
          width: 32.wMin,
          height: 32.wMin,
        ),
      ),
    );
  }

  /// 构建视频显示区域，并在播放状态变化时同步更新进度与加载态。
  Widget _buildVideoWidget() {
    double displayAspectRatio = widget.aspectRatio > 0 ? widget.aspectRatio : 1;
    if (!widget.useAspectRatio && videoAspectRatio > 0) {
      displayAspectRatio = videoAspectRatio;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.wMin),
      child: GestureDetector(
        onTap: () {},
        onDoubleTap: () {
          _player.playOrPause();
        },
        child: AspectRatio(
          aspectRatio: displayAspectRatio,
          child: Container(
            color: AppTheme.cBgPrimary.color,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {},
                    child: Video(
                      controller: _videoWidgetController,
                      fill: AppTheme.cBgPrimary.color,
                      controls: (state) => Container(),
                    ),
                  ),
                ),
                Visibility(
                  visible: loading,
                  child: CachedImageWidget(
                    widget.relationVideo.firstImageUrl ?? "",
                    fit: BoxFit.cover,
                    placeholder: Container(),
                    errorWidget: Container(),
                  ),
                ),
                Visibility(
                  visible: loading,
                  child: SpinKitFadingCircle(
                    color: AppTheme.cBgBrand.color,
                    size: 100.wMin,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建视频下方字幕区域，展示原文高亮字幕与对应翻译。
  Widget _buildVideoSubtitlesWidget() {
    final String assText = widget.relationVideo.ass?.trim() ?? "";
    final bool hasAss = assText.isNotEmpty;
    final bool hasTranslate =
        (widget.relationVideo.translate ?? const <LanguageText?>[]).any((item) => item?.text?.trim().isNotEmpty == true);
    if (!hasAss && !hasTranslate) {
      return const SizedBox.shrink();
    }

    double assFontSize = 48.wMin;
    double translateFontSize = 28.wMin;

    if (contentFontSizeMultiple == FontSizeEnum.extraSmall) {
      assFontSize = 24.wMin;
      translateFontSize = 20.wMin;
    } else if (contentFontSizeMultiple == FontSizeEnum.small) {
      assFontSize = 32.wMin;
      translateFontSize = 26.wMin;
    } else if (contentFontSizeMultiple == FontSizeEnum.standard) {
      assFontSize = 40.wMin;
      translateFontSize = 32.wMin;
    } else if (contentFontSizeMultiple == FontSizeEnum.large) {
      assFontSize = 46.wMin;
      translateFontSize = 36.wMin;
    } else if (contentFontSizeMultiple == FontSizeEnum.extraLarge) {
      assFontSize = 50.wMin;
      translateFontSize = 40.wMin;
    } else if (contentFontSizeMultiple == FontSizeEnum.extraExtraLarge) {
      assFontSize = 54.wMin;
      translateFontSize = 44.wMin;
    }

    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: 120.wMin,
        ),
        margin: EdgeInsets.only(top: 10.wMin),
        padding: EdgeInsets.symmetric(horizontal: 48.wMin),
        child: VideoAssTextWidget(
          position: positionDuration,
          ass: translateType == LangPreference.bilingual || translateType == LangPreference.original ? widget.relationVideo.ass : null,
          translate: translateType == LangPreference.bilingual || translateType == LangPreference.translation
              ? widget.relationVideo.translate
              : null,
          translateLangCode: widget.translateLangCode,
          assFontSize: assFontSize,
          translateFontSize: translateFontSize,
        ),
      ),
    );
  }

  /// 构建底部播放控制区域，包括进度条和播放暂停按钮。
  Widget _buildVideoControlsWidget() {
    UserSettingModel userSetting = Get.find<ConfigController>().userSetting.value;

    final Duration displayDuration = clipDuration;
    Duration displayPosition = positionDuration - clipStartDuration;
    if (displayPosition.isNegative) {
      displayPosition = Duration.zero;
    } else if (displayPosition > displayDuration) {
      displayPosition = displayDuration;
    }

    double bottom = 24.wMin;
    double playerControllerHeight = 104.wMin + 20.wMin;
    return Container(
      color: Colors.transparent,
      height: playerControllerHeight + bottom,
      margin: EdgeInsets.only(bottom: bottom),
      child: IgnorePointer(
        ignoring: loading,
        child: PlayerControllerWidget(
          style: PlayerControllerStyle(
            cBorderDark: AppTheme.cBorderDark.color,
            cFeedbackInfoBackground: AppTheme.cFeedbackInfoBackground.color,
            cSurfaceBrand: AppTheme.cSurfaceBrand.color,
            cSurfacePlayerBackground: AppTheme.cSurfacePlayerBackground.color,
            cSurfaceLayerElevated: AppTheme.cSurfaceLayerElevated.color,
            cSurfacePlayerOverlay: AppTheme.cSurfacePlayerOverlay.color,
            cTextPrimary: AppTheme.cTextPrimary.color,
            cTextSecondary: AppTheme.cTextSecondary.color,
            cTextTertiary: AppTheme.cTextTertiary.color,
            cTextBrand: AppTheme.cTextBrand.color,
            cBorderPrimary: AppTheme.cBorderPrimary.color,
            cBorderDefault: AppTheme.cBorderDefault.color,
          ),
          playerConfig: PlayerControllerConfig(
            isPlaying: isPlaying,
            onPlayPause: (value) => _player.playOrPause(),
            onSeek: (value) {
              final Duration seekPosition = normalizeProgressDuration(clipStartDuration + value);
              positionDuration = seekPosition;
              if (mounted) setState(() {});
              _player.seek(seekPosition);
            },
            duration: displayDuration,
            position: displayPosition,
            isShowPreviousNext: false,
          ),
          volumeConfig: PlayerControllerVolumeConfig(
            isShowVolume: widget.relationVideo.isMute != true,
            volume: volume,
            onVolumeChange: onVolumeChange,
          ),
          speedMultiplierConfig: PlayerControllerSpeedMultiplierConfig(
            isShowSpeedMultiplier: true,
            speedMultiplier: playSpeed,
            speedList: widget.isLearn ? userSetting.courseAudioSpeedList : playerGlobalSettingsController.expandAudioSpeedList,
            onSpeedMultiplierChange: changePlaySpeed,
          ),
          subtitleConfig: widget.showSubtitleSetting ? PlayerControllerSubtitleConfig(
            isShowSubtitle: true,
            langPreference: translateType,
            fontSize: contentFontSizeMultiple,
            onSubtitleChange: onSubtitleChange,
            onSubtitleFontSizeChange: onSubtitleFontSizeChange,
          ) : null,
        ),
      ),
    );
  }
}
