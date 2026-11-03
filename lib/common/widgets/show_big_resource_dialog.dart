
import 'dart:async';

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

class ShowBigResourceDialog{

  /// 是否显示了弹窗
  static bool isShow = false;

  static Future<int?> showImage({
    required BuildContext context,
    required List<String> imageUrls,
    int index = 0,
  }) async{
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
  }) async{
    if(relationVideo == null) return;
    if(relationVideo.videoUrl == null) return;
    
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
                      child: CachedImageWidget(
                        widget.imageUrls[index],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                        placeholder: buildLoadingWidget(),
                        errorWidget: buildEmptyWidget(),
                      ),
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
                    if(mounted) setState(() {});
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
                    if(currentIndex <= 0) return;
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
                    if(currentIndex >= widget.imageUrls.length - 1) return;
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
  const ShowBigVideoDialogWidget({
    super.key, 
    required this.relationVideo,
    this.translateLangCode = "zh", 
    this.isLearn = false,
    this.aspectRatio = 1,
  });

  @override
  /// 创建视频弹窗对应的状态对象。
  State<ShowBigVideoDialogWidget> createState() => _ShowBigVideoDialogWidgetState();
}

class _ShowBigVideoDialogWidgetState extends State<ShowBigVideoDialogWidget> {
  static const Duration _progressSnapTolerance = Duration(milliseconds: 50);
  final PlayerGlobalSettingsController playerGlobalSettingsController = Get.find<PlayerGlobalSettingsController>();

  VideoPlayeController videoController = VideoPlayeController();
  String? videoFileUrl;
  Duration positionDuration = Duration.zero;
  Duration allDuration = Duration.zero;
  bool isDragging = false;
  bool isPlaying = false;
  int volume = 100;
  double playSpeed = 1.0;

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
    initUrl();
    initUserSetting();
  }

  /// 获取本地储存的设置
  Future<void> initUserSetting() async {
    if(Get.isRegistered<ConfigController>()){
      UserSettingModel userSetting = Get.find<ConfigController>().userSetting.value;
      
      if(widget.isLearn){
        translateType = userSetting.courseLang;
        playSpeed = userSetting.courseAudioSpeed;
      }
    }
    if(widget.isLearn){
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
    Duration rawDuration = DateFormatUtil.secondsToDuration(widget.relationVideo.duration ?? 0);
    Duration endDuration = widget.relationVideo.endSeconds == null
        ? rawDuration
        : DateFormatUtil.secondsToDuration(widget.relationVideo.endSeconds ?? 0);
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
    super.dispose();
  }


  /// 初始化视频缓存地址并打开播放器，同时按片段范围设置播放区间。
  Future<void> initUrl() async{
    if(widget.relationVideo.videoUrl == null) return;
    try {

      allDuration = clipDuration;
      positionDuration = clipStartDuration;

      Future<String?> cacheFuture = CacheManagerUtils.instance.getFile(widget.relationVideo.videoUrl, ResourceType.video);
      String? fastCachePath;
      try {
        fastCachePath = await cacheFuture.timeout(const Duration(milliseconds: 350));
      } catch (_) {}

      if(fastCachePath != null && fastCachePath.isNotEmpty){
        videoFileUrl = fastCachePath;
      }else{
        videoFileUrl = widget.relationVideo.videoUrl;
      }
      if(videoFileUrl == null) return;

      Duration startSeconds = clipStartDuration;
      Duration endSeconds = clipEndDuration;

      await videoController.open([MediaModel(
        resource: videoFileUrl??"",
        start: startSeconds,
        end: endSeconds == Duration.zero ? null : endSeconds,
      )]);
      if(widget.relationVideo.isMute == true){
        await videoController.setVolume(0);
      }
      await videoController.setRate(playSpeed);
      await videoController.setPlaylistMode(PlaylistMode.none);
      await videoController.play();

      unawaited(cacheFuture);
    } finally{
      if(mounted) setState(() {});
    }
  }

  /// 修改播放音量
  Future<void> onVolumeChange(int value) async {
    volume = value;
    if(mounted) setState(() {});
    await videoController.setVolume(value.toDouble());
    if(widget.isLearn){
      AudioControlUtils.saveSetting(AudioControlSettingModel(volume: value));
      return;
    }
    await playerGlobalSettingsController.onVolumeChange(value);
  }

  /// 修改播放速度
  void changePlaySpeed(double speed) async {
    playSpeed = speed;
    if(mounted) setState(() {});
    await videoController.setRate(speed);
    if(widget.isLearn){
      ConfigController configController = Get.find<ConfigController>();
      configController.setUserSetting(courseAudioSpeed: speed);
      return;
    }
    await playerGlobalSettingsController.onPlaybackRateChange(speed);
  }

  /// 改变翻译状态
  Future<void> onSubtitleChange(LangPreference value) async {
    translateType = value;
    if(mounted) setState(() {});
    if(widget.isLearn){
      ConfigController configController = Get.find<ConfigController>();
      configController.setUserSetting(courseTranslationType: value.code);
      return;
    }
    await playerGlobalSettingsController.onSubtitleDisplayChange(value);
  }

  /// 改变文字大小倍数
  Future<void> onSubtitleFontSizeChange(FontSizeEnum value) async {
    contentFontSizeMultiple = value;
    if(mounted) setState(() {});
    if(widget.isLearn){
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
  Widget _buildCloseWidget(){
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
  Widget _buildVideoWidget(){

    Duration startSeconds = clipStartDuration;
    Duration endSeconds = clipEndDuration;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.wMin),
      child: GestureDetector(
        onTap: (){},
        onDoubleTap: () {
          videoController.playOrPause();
        },
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: Container(
            color: AppTheme.cSurfaceSecondary.color,
            child: Stack(
              children: [
                VideoPlayerWidget(
                  controller: videoController,
                  autoPlay: false,
                  playList: [
                    MediaModel(
                      resource: videoFileUrl??"",
                      start: startSeconds,
                      end: endSeconds == Duration.zero ? null : endSeconds,
                    ),
                  ],
                  onReady: () {},
                  controls: (p0) {
                    return Container();
                  },
                  onVideoPlayInfoChange: (into) {
                    if(isPlaying != into.playing){
                      isPlaying = into.playing;
                      if(mounted) setState(() {});
                    }
        
                    Duration currentPosition = normalizeProgressDuration(into.positionDuration);
                    if(positionDuration != currentPosition && !isDragging){
                      positionDuration = currentPosition;
                      if(mounted) setState(() {});
                    }
        
                    if(into.positionDuration != Duration.zero && loading){
                      loading = false;
                      if(mounted) setState(() {});
                    }
                    
                    if(into.completed){
                      videoController.pause();
                      positionDuration = startSeconds;
                      videoController.seek(startSeconds);
                      if(mounted) setState(() {});
                    }
                  },
                ),
        
                Visibility(
                  visible: loading,
                  child: CachedImageWidget(
                    widget.relationVideo.firstImageUrl??"",
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
  Widget _buildVideoSubtitlesWidget(){
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
      onTap: (){},
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
          translate: translateType == LangPreference.bilingual || translateType == LangPreference.translation ? widget.relationVideo.translate : null,
          translateLangCode: widget.translateLangCode,
          assFontSize: assFontSize,
          translateFontSize: translateFontSize,
        ),
      ),
    );
  }

  /// 构建底部播放控制区域，包括进度条和播放暂停按钮。
  Widget _buildVideoControlsWidget(){
    UserSettingModel userSetting = Get.find<ConfigController>().userSetting.value;

    final Duration displayDuration = allDuration == Duration.zero ? clipDuration : allDuration;
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
          playerConfig: PlayerControllerConfig(
            isPlaying: isPlaying,
            onPlayPause: (value) => videoController.playOrPause(),
            onSeek: (value) {
              final Duration seekPosition = normalizeProgressDuration(clipStartDuration + value);
              positionDuration = seekPosition;
              if (mounted) setState(() {});
              videoController.seek(seekPosition);
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
          subtitleConfig: PlayerControllerSubtitleConfig(
            isShowSubtitle: true,
            langPreference: translateType,
            fontSize: contentFontSizeMultiple,
            onSubtitleChange: onSubtitleChange,
            onSubtitleFontSizeChange: onSubtitleFontSizeChange,
          ),
        ),
      ),
    );

  }

}
