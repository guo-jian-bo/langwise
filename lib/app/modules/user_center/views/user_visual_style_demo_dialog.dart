
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/enum/enum.dart' show ResourceTypeEnum;
import 'package:langwise/theme/theme.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/access_enum.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/utils.dart';

/// 演示视觉风格
class UserVisualStyleDemoDialog{

  static Future<void> show({
    required BuildContext context,
    required TeamStyleEntityStyleItems data,
  }) async{
    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return UserVisualStyleDemoDialogWidget(data: data);
      },
    );
  }

}

class UserVisualStyleDemoDialogWidget extends StatefulWidget {
  final TeamStyleEntityStyleItems data;
  const UserVisualStyleDemoDialogWidget({super.key, required this.data});

  @override
  State<UserVisualStyleDemoDialogWidget> createState() => _UserVisualStyleDemoDialogWidgetState();
}

class _UserVisualStyleDemoDialogWidgetState extends State<UserVisualStyleDemoDialogWidget> {

  /// 资源类型
  ResourceTypeEnum resourceType = ResourceTypeEnum.image;
  final FocusNode _focusNode = FocusNode();

  Player player = Player();
  late VideoController videoController;
  /// 是否准备好视频资源
  bool videoReady = false;
  /// 视频播放状态
  bool isPlaying = false;
  /// 视频是否正在播放中
  bool isPlayVideo = false;

  @override
  void initState() {
    super.initState();
    videoController = VideoController(player);
    setVideo();
    listenVideo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(_focusNode.canRequestFocus){
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
    player.dispose();
  }

  /// 监听视频播放
  void listenVideo(){
    player.stream.playing.listen((e){
      isPlaying = e;
      if(mounted) setState(() {});
    });
    player.stream.position.listen((e){
      isPlayVideo = e > Duration.zero;
      if(mounted) setState(() {});
    });
    player.stream.completed.listen((e) async{
      if(e){
        isPlaying = false;
        isPlayVideo = false;
        await player.pause();
        await player.seek(Duration.zero);
        if(mounted) setState(() {});
      }
    });
  }

  Future<void> setVideo() async{
    String videoUrl = widget.data.video?.videoUrl??"";
    if(videoUrl.isEmpty) return;

    String? fileUrl = await CacheManagerUtils.instance.getFile(
      videoUrl, 
      ResourceType.video,
      timeoutMilliseconds: 5000,
    );
    if(fileUrl == null){
      await player.open(Media(videoUrl), play: false);
    }else{
      await player.open(Media(fileUrl), play: false);
    }
    
    videoReady = true;
    if(mounted) setState(() {});
  }

  /// 键盘空格控制视频播放
  void _toggleVideoPlayback(){
    if(resourceType != ResourceTypeEnum.video || !videoReady) return;
    player.playOrPause();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.space): const ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) {
              _toggleVideoPlayback();
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: _focusNode,
          autofocus: true,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Material(
              color: AppTheme.cOverlayBackground.color,
              child: Center(
                child: GestureDetector(
                  onTap: (){},
                  child: Container(
                    width: 800.wMin,
                    decoration: BoxDecoration(
                      color: AppTheme.cSurfaceSecondary.color,
                      borderRadius: BorderRadius.circular(20.wMin),
                      border: Border.all(
                        color: AppTheme.cBorderPrimary.color,
                        width: 1.wMin,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        _buldImageWidget(),

                        Container(
                          padding: EdgeInsets.all(24.wMin),
                          child: Column(
                            children: [
                              _buildContentWidget(),
                              SizedBox(height: 16.wMin),
                              _buildSwitchWidget(),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buldImageWidget(){
    String imageUrl = widget.data.image?.imageUrl??"";
    if(resourceType == ResourceTypeEnum.video){
      imageUrl = widget.data.video?.firstFrameUrl??"";
    }

    return AspectRatio(
      aspectRatio: 1,
      child: IgnorePointer(
        ignoring: resourceType != ResourceTypeEnum.video || !videoReady,
        child: TapScaleWidget(
          onTap: () {
            _toggleVideoPlayback();
          },
          sclae: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.wMin)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Video(
                  controller: videoController,
                  controls: (state) {
                    return Container();
                  },
                ),
          
                IgnorePointer(
                  ignoring: true,
                  child: Opacity(
                    opacity: isPlaying || isPlayVideo ? 0 : 1,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: CachedImageWidget(
                        imageUrl,
                        errorWidget: buildEmptyWidget(),
                        placeholder: buildLoadingWidget(),
                        key: ValueKey(imageUrl),
                      ),
                    ),
                  ),
                ),
          
                IgnorePointer(
                  ignoring: true,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: (resourceType == ResourceTypeEnum.video && videoReady && !isPlaying) ? 1 : 0,
                    child: Container(
                      padding: EdgeInsets.all(20.wMin),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 80.wMin,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
          
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentWidget(){
    List<LanguageText?> styleTitle = widget.data.styleTitle??[];
    LanguageText? localText = LearningLangUtils.getLocalLang(styleTitle);

    List<LanguageText?> styleDesc = widget.data.styleDesc??[];
    LanguageText? localDescTextDesc = LearningLangUtils.getLocalLang(styleDesc);

    bool isSubscribed = false;
    if(resourceType == ResourceTypeEnum.image){
      isSubscribed = widget.data.imageRights == 1;
    }else if(resourceType == ResourceTypeEnum.video){
      isSubscribed = widget.data.videoRights == 1;
    }


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                localText?.text??"",
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 8.wMin),
            Visibility(
              visible: widget.data.accessEnum == AccessEnum.NORMAL,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4.wMin, horizontal: 6.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.wMin),
                  color: isSubscribed ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12) : AppTheme.cSurfacePrimary.color,
                  border: Border.all(
                    color: isSubscribed ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2) : AppTheme.cSurfacePrimary.color,
                    width: 1.wMin,
                  ),
                ),
                child: Text(
                  isSubscribed ? "已订阅" : "可订阅",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: isSubscribed ? AppTheme.cSurfaceSuccess.color : AppTheme.cTextSecondary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
        Text(
          localDescTextDesc?.text??"",
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchWidget(){
    return Container(
      height: 72.wMin,
      padding: EdgeInsets.all(8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: resourceType == ResourceTypeEnum.image ? Alignment.centerLeft : Alignment.centerRight,
                child: AnimatedContainer(
                  width: constraints.maxWidth / 2,
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.wMin),
                    color: resourceType.color.withValues(alpha: 0.12),
                    border: Border.all(
                      color: resourceType.color.withValues(alpha: 0.2),
                      width: 0.8.wMin,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  _buildSwitchItemWidget(ResourceTypeEnum.image),
                  _buildSwitchItemWidget(ResourceTypeEnum.video),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSwitchItemWidget(ResourceTypeEnum mode){
    return Expanded(
      child: TapScaleWidget(
        onTap: () async{
          resourceType = mode;
          if(mounted) setState(() {});
          await player.pause();
          await player.seek(Duration.zero);

        },
        sclae: 1,
        child: Container(
          height: double.infinity,
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                mode.svg,
                width: 40.wMin,
                colorFilter: ColorFilter.mode(
                  mode == resourceType ? mode.color : AppTheme.cTextPrimary.color, 
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 16.wMin),
              Text(
                "${mode.name}模式",
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: mode == resourceType ? mode.color : AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
