

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../theme/theme.dart';
import '../../utils/utils.dart';
import '../entities/entities.dart';
import '../enum/enum.dart';
import '../public_controller/config_controller.dart';
import 'widgets.dart';

class ShowBigResourceDialog{

  static Future<int?> showImage({
    required BuildContext context,
    required List<String> imageUrls,
    int index = 0,
  }) async{
    return await showDialog<int?>(
      context: context,
      useSafeArea: false,
      builder: (context) {
        return ShowBigImageDialogWidget(
          imageUrls: imageUrls,
          index: index,
        );
      },
    );
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
    return await showDialog(
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
      onTap: () {
        Get.back(result: currentIndex);
      },
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
                    return PhotoViewGalleryPageOptions(
                      controller: _viewController,
                      imageProvider: NetworkImage(widget.imageUrls[index]),
                      initialScale: PhotoViewComputedScale.contained,
                      maxScale: 2.0,
                      minScale: 0.1,
                      heroAttributes: PhotoViewHeroAttributes(tag: widget.imageUrls[index]),
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

  VideoPlayeController videoController = VideoPlayeController();
  String? videoFileUrl;
  Duration positionDuration = Duration.zero;
  Duration allDuration = Duration.zero;
  bool isDragging = false;
  bool isPlaying = false;

  bool loading = true;

  LangPreference translateType = LangPreference.bilingual;
  /// 是否显示翻译菜单
  bool showTranslateMenu = false;

  @override
  /// 初始化视频地址、字幕数据以及键盘快捷键监听。
  void initState() {
    super.initState();
    initUrl();
    HardwareKeyboard.instance.addHandler(_handleGlobalKeyEvent);

    if(widget.isLearn){
      translateType = Get.find<ConfigController>().userSetting.value.courseLang;
    }else{
      translateType = Get.find<ConfigController>().userSetting.value.expandLang;
    }
    
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
    HardwareKeyboard.instance.removeHandler(_handleGlobalKeyEvent);
    super.dispose();
  }

  /// 监听键盘事件
  bool _handleGlobalKeyEvent(KeyEvent event) {
    // 检查是否有 Dialog 或其他模态路由打开
    if (ModalRoute.of(context)?.isCurrent != true) {
      return false; // 当前页面不在最前面，不处理键盘事件
    }

    // 空格键
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      videoController.playOrPause();
      return true;
    } else if(event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape){
      Get.back();
    }
    return false;
  }

  /// 初始化视频缓存地址并打开播放器，同时按片段范围设置播放区间。
  Future<void> initUrl() async{
    if(widget.relationVideo.videoUrl == null) return;
    try {

      allDuration = clipDuration;
      positionDuration = clipStartDuration;
      
      videoFileUrl = await CacheManagerUtils.instance.getFile(widget.relationVideo.videoUrl, ResourceType.video);
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
      await videoController.setPlaylistMode(PlaylistMode.none);
      await videoController.play();
    } finally{
      if(mounted) setState(() {});
    }
  }



  void changeTranslation(LangPreference lang){
    translateType = lang;
    if(mounted) setState(() {});
  }


  @override
  /// 构建大视频弹窗整体布局，包括播放器、字幕区和底部控制栏。
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
        
            Positioned.fill(
              child: Column(
                children: [
                  SizedBox(height: 40.wMin + MediaQuery.of(context).padding.top),
                  Expanded(child: _buildVideoWidget()),
                  _buildVideoSubtitlesWidget(),
                ],
              ),
            ),
        
            Positioned(
              right: 70.wMin + MediaQuery.of(context).padding.right,
              top: 24.wMin + MediaQuery.of(context).padding.top,
              child: _buildCloseWidget(),
            ),
        
          ],
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
          color: AppTheme.cSurfaceTertiary.color,
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
        
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建视频下方字幕区域，展示原文高亮字幕与对应翻译。
  Widget _buildVideoSubtitlesWidget(){

    return Container(
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
      ),
    );
  }

  /// 构建底部播放控制区域，包括进度条和播放暂停按钮。
  Widget _buildVideoControlsWidget(){

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 24.wMin + MediaQuery.of(context).padding.left,
        right: 24.wMin + MediaQuery.of(context).padding.right,
        bottom: 16.wMin + MediaQuery.of(context).padding.bottom,
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: _buildTranslateList(),
          ),

          _buildVideoProgressWidget(),

          Row(
            children: [

              SizedBox(width: 72.wMin),

              Expanded(
                child: TapScaleWidget(
                  onTap: () {
                    videoController.playOrPause();
                  },
                  sclae: 1.05,
                  child: Container(
                    width: 80.wMin,
                    height: 80.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
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
                        color: Colors.white,
                        size: 48.wMin,
                        key: ValueKey(isPlaying),
                      ),
                    ),
                  ),
                ),
              ),

              TapScaleWidget(
                onTap: () {
                  showTranslateMenu = !showTranslateMenu;
                  if(mounted) setState(() {});

                  
                },
                sclae: 1.05,
                child: Container(
                  width: 72.wMin,
                  height: 72.wMin,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent
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
                      showTranslateMenu ? "assets/svg/public/icon_caret_down.svg" : "assets/svg/public/icon_translation.svg",
                      width: 32.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                    ),
                  ),
                  
                ),
              ),



            ],
          ),

        ],
      ),
    );
  }


  /// 翻译菜单列表
  Widget _buildTranslateList() {
    if(!showTranslateMenu) return Container();

    List<UserPreferenceDefinitionDisplayModeOption> expandDropdownMenu = Get.find<ConfigController>().userSetting.value.expandDropdownMenu??[];
    if(expandDropdownMenu.isEmpty) return Container();


    return Container(
      margin: EdgeInsets.only(bottom: 16.wMin),
      height: 80.wMin,
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceSecondary.color,
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(expandDropdownMenu.length, (index) {

          LangPreference itemLang = LangPreference.fromRawValue(expandDropdownMenu[index].code);

          return Expanded(
            child: TapScaleWidget(
              onTap: () async {
                // widget.onTranslateChanged?.call(itemLang);

                changeTranslation(itemLang);

              },
              sclae: 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                alignment: Alignment.center,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  color: AppTheme.cBgBrand.color.withValues(alpha: translateType == itemLang ? 1 : 0),
                ),
                child: AutoSizeText(
                  expandDropdownMenu[index].title??"",
                  style: TextStyle(
                    color: translateType == itemLang ? Colors.white : AppTheme.cTextPrimary.color,
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

  /// 构建视频播放进度条与左右时间文本，并处理拖动跳转。
  Widget _buildVideoProgressWidget(){

    Duration currentPosition = normalizeProgressDuration(positionDuration);
    Duration currentProgress = currentPosition - clipStartDuration;
    if (currentProgress.isNegative) {
      currentProgress = Duration.zero;
    }
    Duration totalProgress = allDuration;
    if (totalProgress.isNegative) {
      totalProgress = Duration.zero;
    }

    String posStr = DateFormatUtil.convertMillisecondsToMinSec(currentProgress.inMilliseconds);
    String allStr = DateFormatUtil.convertMillisecondsToMinSec(allDuration.inMilliseconds);

    double _duration = totalProgress.inMicroseconds.toDouble();
    double _position = currentProgress.inMicroseconds.toDouble();

    /// 判断当前进度是否超出最大最小范围
    bool isOutOfRange = _position > _duration || _position < 0;
    double sliderValue = isOutOfRange
        ? 0
        : _position.clamp(0.0, _duration <= 0 ? 0.0 : _duration).toDouble();
    double sliderMax = _duration <= 0 ? 1 : _duration;

    return Row(
      children: [
        Container(
          width: 100.wMin,
          alignment: Alignment.centerRight,
          child: Text(
            posStr,
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color.withValues(alpha: 0.8),
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 8.wMin,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 12.wMin,
              ),
            ),
            child: Slider(
              value: sliderValue,
              max: sliderMax,
              activeColor: AppTheme.cBgBrand.color,
              inactiveColor: AppTheme.cTextPrimary.withValues(alpha: 0.1),
              onChangeStart: (value) {
                isDragging = true;
                if (mounted) setState(() {});
              },
              onChanged: (value) {
                positionDuration = clampToClipRange(
                  clipStartDuration + Duration(microseconds: value.toInt()),
                );
                if (mounted) setState(() {});
              },
              onChangeEnd: (value) {
                Duration seekPosition = clampToClipRange(
                  clipStartDuration + Duration(microseconds: value.toInt()),
                );
                positionDuration = seekPosition;
                videoController.seek(seekPosition);
                isDragging = false;
                if (mounted) setState(() {});
              },
            ),
          ),
        ),
        Container(
          width: 100.wMin,
          alignment: Alignment.centerLeft,
          child: Text(
            allStr,
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
        ),
      ],
    );
  }


}