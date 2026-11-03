import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
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
import '../../../../theme/theme.dart';
import '../../../routes/routes.dart';
import '../bindings/zhendu_look_binding.dart';
import '../controllers/zhendu_look_controller.dart';
import '../controllers/zhendu_look_player_controller.dart';

class ZhenduLookView extends GetView<ZhenduLookController> {
  final String tagText;
  const ZhenduLookView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenduLookView(tagText: tag),
      binding: ZhenduLookBinding(tagText: tag),
      routeName: Routes.ZHENDU_LOOK,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ZhenduLookPlayerController playerController = Get.find<ZhenduLookPlayerController>(tag: tagText);

    return MouseRegion(
      onHover: (event) {
        if(controller.isFrameOnlyPlaybackMode) return;
        playerController.startShowAudioControllerTimer();
      },
      child: Scaffold(
        backgroundColor: AppTheme.cBgPrimary.color,
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
                  Positioned.fill(child: _buildContentWidget(context)),
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

  Widget _buildContentWidget(BuildContext context){
    final ZhenduLookPlayerController playerController = Get.find<ZhenduLookPlayerController>(tag: tagText);
    return GestureDetector(
      onTap: () {
        playerController.toggleShowAudioController();
      },
      onDoubleTap: () {
        playerController.onGesturePlayPause();
      },
      child: Container(
        color: Colors.transparent,
        child: Obx((){
          if(controller.frameList.isEmpty) return const SizedBox.expand();

          BoxFit fit = playerController.fitEnum.value.boxFit;
          return PageView.builder(
            itemCount: controller.frameList.length,
            controller: controller.pageController,
            allowImplicitScrolling: true,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                color: Colors.transparent,
                child: CachedImageWidget(
                  controller.frameList[index].frameData.frameUrl??"",
                  fit: fit,
                  errorWidget: const SizedBox.expand(),
                  placeholder: const SizedBox.expand(),
                  gaplessPlayback: true,
                  fadeInDuration: Duration.zero,
                ),
              );
            },
            onPageChanged: (value) {
              controller.onFramePageChanged(value);
            },
          );
        }),
      ),
    );
  }

  Widget _buildTitleWidget(BuildContext context){
    double top = MediaQuery.of(context).padding.top + 24.wMin;
    return Obx((){
      final ZhenduLookPlayerController playerController = Get.find<ZhenduLookPlayerController>(tag: tagText);
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
            final ZhenduLookPlayerController playerController = Get.find<ZhenduLookPlayerController>(tag: tagText);
            if(playerController.subtitleList.isEmpty) return Container();
            return PlayerAssWidget(
              subtitleList: playerController.subtitleList.toList(),
              currentSentenceIndex: playerController.currentSentenceIndex.value,
              currentWordIndex: playerController.currentWordIndex.value,
              langPreference: playerController.translateStatus.value,
              fontSize: playerController.contentFontSizeMultiple.value,
              onSentence: (sentence, sentenceIndex) {
                controller.changeAssIndex(sentence, sentenceIndex);
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
                  final ZhenduLookPlayerController playerController = Get.find<ZhenduLookPlayerController>(tag: tagText);
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
      final ZhenduLookPlayerController playerController = Get.find<ZhenduLookPlayerController>(tag: tagText);
      return PlayerControllerWidget(
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
        customCenterWidget: PlayPageTypeButtonWidget(
          pageTypeConfig: PlayPageTypeConfig(
            learnItems: controller.currentSong?.learnItems?.whereType<ZhenduLearnItems>().toList() ?? [],
            currentPageType: ZhenduPageTypeEnum.watch,
            onPageTypeChange: (item) async {
              playerController.onPageTypeChange(item);
            },
          ),
          onPopupVisibilityChanged: playerController.onPlayerPopupVisibilityChanged,
        ),
      );
    });
  }

}
