import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/widgets/player_widgets/play_list_drwer_widget.dart';
import '../../../../common/widgets/player_widgets/play_page_type_widgets.dart';
import '../../../../common/widgets/player_widgets/play_title_widget.dart';
import '../../../../common/widgets/player_widgets/player_ass_widget.dart';
import '../../../../utils/interaction_record_utils/interaction_record_utils.dart';
import '../../../routes/routes.dart';
import '../bindings/zhendu_perform_binding.dart';
import '../controllers/zhendu_perform_controller.dart';
import '../controllers/zhendu_perform_player_controller.dart';

class ZhenduPerformView extends GetView<ZhenduPerformController> {
  final String tagText;
  const ZhenduPerformView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenduPerformView(tagText: tag),
      binding: ZhenduPerformBinding(tagText: tag),
      routeName: Routes.ZHENDU_PERFORM,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ZhenduPerformPlayerController playerController = Get.find<ZhenduPerformPlayerController>(tag: tagText);
    return InteractionSessionContainer(
      source: 'zhendu_perform',
      child: Scaffold(
        backgroundColor: AppTheme.cBgPrimary.color,
        body: Obx((){
          return Video(
            fill: AppTheme.cBgPrimary.color,
            controller: playerController.videoController,
            fit: playerController.fitEnum.value.boxFit,
            controls: (state) {
              return Builder(
                builder: (context) {
                  return MouseRegion(
                    onHover: (event) {
                      playerController.startShowAudioControllerTimer();
                    },
                    child: Scaffold(
                      backgroundColor: Colors.transparent,
                      endDrawer: Obx((){
                        return PlayListDrwerWidget(
                          songs: controller.songList.toList(),
                          contents: controller.contents,
                          allCount: controller.contents?.length ?? controller.songList.length,
                          selectedUniqueKey: controller.currentContentUniqueKey.value,
                          onSelected: (data) {
                            controller.switchSong(data);
                          },
                          onScrollEnd: () async{
                            await controller.loadData();
                          },
                        );
                      }),
                      drawerEnableOpenDragGesture: false,
                      drawerScrimColor: Colors.transparent,
                      body: Builder(
                        builder: (scaffoldBodyContext) {
                          return Container(
                            width: double.infinity,
                            color: Colors.transparent,
                            child: Stack(
                              children: [
                                _buildContentWidget(),
                                _buildBottomWidget(scaffoldBodyContext),
                                _buildTitleWidget(scaffoldBodyContext),
                                _buildAITextWidget(context),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        }),
      ),
    );
  }

  /// ai文字标识
  Widget _buildAITextWidget(BuildContext context) {
    return Positioned(
      bottom: 20.wMin,
      right: 20.wMin,
      child: Text(
        "内容由 AI 生成",
        style: TextStyle(
          fontSize: 18.wMin,
          color: AppTheme.cTextQuaternary.color,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildContentWidget(){
    final ZhenduPerformPlayerController playerController = Get.find<ZhenduPerformPlayerController>(tag: tagText);
    return GestureDetector(
      onTap: () {
        playerController.toggleShowAudioController();
      },
      onDoubleTap: () {
        playerController.player.playOrPause();
      },
      child: Container(
        color: Colors.transparent,
      ),
    );
  }

  Widget _buildTitleWidget(BuildContext context){
    double top = MediaQuery.of(context).padding.top + 24.wMin;
    return Obx((){
      final ZhenduPerformPlayerController playerController = Get.find<ZhenduPerformPlayerController>(tag: tagText);
      return AnimatedPositioned(
        width: MediaQuery.of(context).size.width,
        top: playerController.isShowAudioController.value ? top : -(top + 72.wMin + 10.wMin),
        duration: const Duration(milliseconds: 300),
        child: PlayTitleWidget(
          title: controller.currentSong?.contentInfo?.title,
          onFeedbackError: () {
            playerController.showFeedbackErrorContentDialog(context);
          },
        ),
      );
    });
  }

  Widget _buildBottomWidget(BuildContext context){
    double bottom = 24.wMin;
    double playerControllerHeight = 104.wMin + 40.wMin;
    return Positioned(
      bottom: 0,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Obx((){
            final ZhenduPerformPlayerController playerController = Get.find<ZhenduPerformPlayerController>(tag: tagText);
            if(playerController.subtitleList.isEmpty) return Container();
            return PlayerAssWidget(
              subtitleList: playerController.subtitleList.toList(),
              currentSentenceIndex: playerController.currentSentenceIndex.value,
              currentWordIndex: playerController.currentWordIndex.value,
              langPreference: playerController.translateStatus.value,
              fontSize: playerController.contentFontSizeMultiple.value,
              onSentence: (sentence, sentenceIndex) async{
                await controller.changeAssIndex(sentence, sentenceIndex);
              },
              onWord: (sentence, ass, sentenceIndex, wordIndex) {
                playerController.openSmallDictionary(context, sentence, ass, sentenceIndex, wordIndex);
              },
            );
          }),
      
          Container(
            color: Colors.transparent,
            height: playerControllerHeight + bottom,
            child: Stack(
              children: [
                Obx((){
                  final ZhenduPerformPlayerController playerController = Get.find<ZhenduPerformPlayerController>(tag: tagText);
                  return AnimatedPositioned(
                    width: MediaQuery.of(context).size.width,
                    bottom: playerController.isShowAudioController.value ? bottom : -(bottom + playerControllerHeight + 10.wMin),
                    duration: const Duration(milliseconds: 300),
                    child: _buildPlayerControllerWidget(context),
                  );
                }),
              ],
            ),
          ),
      
        ],
      ),
    );
  }


  Widget _buildPlayerControllerWidget(BuildContext context) {
    return Obx((){
      final ZhenduPerformPlayerController playerController = Get.find<ZhenduPerformPlayerController>(tag: tagText);
      final bool isFullScreen = isFullscreen(context);
      return PlayerControllerWidget(
        // key: ValueKey(isFullScreen),
        playerConfig: PlayerControllerConfig(
          isPlaying: playerController.isPlaying.value,
          duration: playerController.duration.value,
          position: playerController.position.value,
          onPlayPause: playerController.onPlayPause,
          onSeek: playerController.onSeek,
          onPreviousNext: playerController.onPreviousNext,
        ),
        favoriteConfig: PlayerControllerFavoriteConfig(
          isShowFavorite: true,
          isFavorite: controller.currentSong?.contentInfo?.isFavorite == true,
          onFavorite: playerController.onFavorite,
        ),
        volumeConfig: PlayerControllerVolumeConfig(
          isShowVolume: true,
          volume: playerController.volume.value,
          onVolumeChange: playerController.onVolumeChange,
        ),
        fitConfig: PlayerControllerFitConfig(
          isShowFit: true,
          fitEnum: playerController.fitEnum.value,
          onFitChange: playerController.onFitChange,
        ),
        speedMultiplierConfig: PlayerControllerSpeedMultiplierConfig(
          isShowSpeedMultiplier: true,
          speedMultiplier: playerController.speedMultiplier.value,
          speedList: Get.find<ConfigController>().userSetting.value.expandAudioSpeedList,
          onSpeedMultiplierChange: playerController.onSpeedMultiplierChange,
        ),
        subtitleConfig: PlayerControllerSubtitleConfig(
          isShowSubtitle: true,
          langPreference: playerController.translateStatus.value,
          fontSize: playerController.contentFontSizeMultiple.value,
          onSubtitleChange: playerController.onSubtitleChange,
          onSubtitleFontSizeChange: playerController.onSubtitleFontSizeChange,
        ),
        durationConfig: PlayerControllerDurationConfig(
          isShowDuration: true,
          timing: playerController.playerTiming.value,
          remainingTimeText: playerController.remainingTimeText.value,
          onDurationChange: playerController.onPlayerTimingChange,
        ),
        modeConfig: PlayerControllerModeConfig(
          isShowMode: true,
          mode: playerController.playOrderStatus.value,
          loopCount: playerController.playOrderLoopCount.value,
          onModeChange: playerController.onModeChange,
          onLoopCountChange: playerController.onLoopCountChange,
        ),
        listConfig: PlayerControllerListConfig(
          isShowList: true,
          onListShow: () async{
            Scaffold.maybeOf(context)?.openEndDrawer();
          },
        ),
        onPopupVisibilityChanged: playerController.onPlayerPopupVisibilityChanged,
        customCenterWidget: Row(
          children: [
            PlayPageTypeButtonWidget(
              pageTypeConfig: PlayPageTypeConfig(
                learnItems: controller.currentSong?.learnItems?.whereType<ZhenduLearnItems>().toList() ?? [],
                currentPageType: ZhenduPageTypeEnum.perform,
                onPageTypeChange: (item) async {
                  playerController.onPageTypeChange(context, item, isFullScreen);
                },
              ),
              onPopupVisibilityChanged: playerController.onPlayerPopupVisibilityChanged,
            ),
            Visibility(
              visible: Platform.isMacOS || Platform.isWindows,
              child: Container(
                margin: EdgeInsets.only(left: 10.wMin),
                child: ButtonWidget(
                  text: isFullScreen ? "缩小" : "全屏",
                  height: 56.wMin,
                  width: 136.wMin,
                  color: AppTheme.cSurfaceLayerElevated.color,
                  border: Border.all(width: 1.2.wMin, color: AppTheme.cSurfaceGhostBgSubtle.color),
                  fontColor: AppTheme.cTextSecondary.color,
                  borderRadius: 999,
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w500,
                  sclae: 1.05,
                  leftIcon: Container(
                    margin: EdgeInsets.only(right: 8.wMin),
                    child: SvgPicture.asset(
                      "assets/svg/public/icon_player_full.svg",
                      width: 40.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
                    ),
                  ),
                  onTap: (){
                    playerController.onFullScreen(context);
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

}
