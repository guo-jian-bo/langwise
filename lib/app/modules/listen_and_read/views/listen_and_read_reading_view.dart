
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/public_controller/player_global_settings_controller.dart';
import '../../../../common/widgets/player_widgets/play_page_type_widgets.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../common/listen_and_read_content_widget.dart';
import '../controllers/listen_and_read_controller.dart';
import '../controllers/listen_and_read_reading_controller.dart';

class ListenAndReadReadingView extends GetView<ListenAndReadReadingController> {
  final String tagText;
  final PlayerGlobalSettingsController playerGlobalSettingsController = Get.find<PlayerGlobalSettingsController>();
  /// 阅读页面
  ListenAndReadReadingView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          GestureDetector(
            onTap: () {
              controller.listenAndReadController.toggleAudioController();
            },
            onDoubleTap: () {
              controller.listenAndReadController.pauseAndPlay();
            },
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              child: Obx((){
                if(controller.listenAndReadController.readingAssTextList.isEmpty) return Container();
                double topPadding = 110.wMin + MediaQuery.of(context).padding.top;
                return Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).padding.left,
                          right: MediaQuery.of(context).padding.right,
                        ),
                        child: ListenAndReadContentWidget(
                          paddingTop: topPadding,
                          contentFontSize: playerGlobalSettingsController.audioFontSize.value,
                          translateStatus: playerGlobalSettingsController.subtitleDisplay.value,
                          readingAssTextList: controller.listenAndReadController.readingAssTextList,
                          clickSelectSentence: controller.listenAndReadController.clickSelectSentence,
                          hoverSelectWord: controller.hoverSelectWord,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          Obx((){
            if(controller.listenAndReadController.currentSong?.audioInfo?.audioUrl == null) return Container();
            bool isShowAudioController = controller.listenAndReadController.isShowAudioController.value;
            double bottomPadding = 200.wMin;
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: isShowAudioController ? 0 : -bottomPadding,
              width: MediaQuery.of(context).size.width,
              child: GestureDetector(
                onTap: (){
                  controller.listenAndReadController.prepareAudioControllerTimer();
                },
                child: Container(
                  padding: EdgeInsets.only(
                    top: 16.wMin,
                    bottom: 24.wMin,
                  ),

                  child: _ListenAndReadReadingPlayerControllerWidget(
                    key: ValueKey(controller.listenAndReadController.currentContentUniqueKey.value),
                    listenAndReadController: controller.listenAndReadController,
                    isFavorite: controller.listenAndReadController.currentSong?.favorited ?? false,
                  ),
                ),
              ),
            );
          }),
          Positioned(
            top: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 2.wMin),
              color: AppTheme.cSurfaceSecondary.color,
              child: Obx((){
                return Text(
                "ID:${controller.listenAndReadController.currentSong?.contentId??""}",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary.color,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

}

class _ListenAndReadReadingPlayerControllerWidget extends StatefulWidget {
  const _ListenAndReadReadingPlayerControllerWidget({
    super.key,
    required this.listenAndReadController,
    required this.isFavorite,
  });

  final ListenAndReadController listenAndReadController;
  final bool isFavorite;

  @override
  State<_ListenAndReadReadingPlayerControllerWidget> createState() => _ListenAndReadReadingPlayerControllerWidgetState();
}

class _ListenAndReadReadingPlayerControllerWidgetState extends State<_ListenAndReadReadingPlayerControllerWidget> {
  ListenAndReadController get _controller => widget.listenAndReadController;
  final PlayerGlobalSettingsController playerGlobalSettingsController = Get.find<PlayerGlobalSettingsController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return PlayerControllerWidget(
        style: PlayerControllerStyle(
          cFeedbackInfoBackground: AppTheme.cFeedbackInfoBackground.color,
          cSurfaceBrand: AppTheme.cSurfaceBrand.color,
          cSurfacePlayerBackground: AppTheme.cSurfacePlayerBackground.color,
          cSurfaceLayerElevated: AppTheme.cSurfaceLayerElevated.color,
          cSurfacePlayerOverlay: AppTheme.cSurfacePlayerOverlay.color,
          cBorderDark: AppTheme.cBorderDark.color,
          cBorderDefault: AppTheme.cBorderDefault.color,
          cBorderPrimary: AppTheme.cBorderPrimary.color,
          cTextBrand: AppTheme.cTextBrand.color,
          cTextPrimary: AppTheme.cTextPrimary.color,
          cTextSecondary: AppTheme.cTextSecondary.color,
          cTextTertiary: AppTheme.cTextTertiary.color,
        ),
        playerConfig: PlayerControllerConfig(
          isPlaying: _controller.isPlaying.value,
          duration: _controller.playerDuration.value,
          position: _controller.position.value,
          isShowPreviousNext: true,
          isShowPreviousNextSentence: true,
          onPlayPause: (_) async {
            await _controller.pauseAndPlay();
          },
          onSeek: (position) async {
            await _controller.audioPlayerUtils.seek(position);
          },
          onPreviousNext: (direction) {
            if (direction == PlayerControllerDirection.previous) {
              _controller.previousClick();
            } else {
              _controller.nextClick();
            }
          },
          onPreviousNextSentence: (direction) {
            _controller.nextOrPreviousSentence(direction);
          },
        ),
        favoriteConfig: PlayerControllerFavoriteConfig(
          isShowFavorite: true,
          isFavorite: widget.isFavorite,
          onFavorite: (_) async {
            await _controller.toggleFavourite();
          },
        ),
        downloadConfig: PlayerControllerDownloadConfig(
          isShowDownload: true,
          onTap: () {
            _controller.downloadAudio(context);
          },
        ),
        volumeConfig: PlayerControllerVolumeConfig(
          isShowVolume: true,
          volume: playerGlobalSettingsController.volume.value,
          onVolumeChange: (value) async {
            await _controller.onVolumeChange(value);
          },
        ),
        speedMultiplierConfig: PlayerControllerSpeedMultiplierConfig(
          isShowSpeedMultiplier: true,
          speedMultiplier: playerGlobalSettingsController.playbackRate.value,
          speedList: playerGlobalSettingsController.expandAudioSpeedList,
          onSpeedMultiplierChange: (value) async {
            await playerGlobalSettingsController.onPlaybackRateChange(value);
            await _controller.audioPlayerUtils.setPlaybackRate(value);
          },
        ),
        subtitleConfig: PlayerControllerSubtitleConfig(
          isShowSubtitle: true,
          langPreference: playerGlobalSettingsController.subtitleDisplay.value,
          fontSize: playerGlobalSettingsController.audioFontSize.value,
          onSubtitleChange: (value) async {
            await playerGlobalSettingsController.onSubtitleDisplayChange(value);
          },
          onSubtitleFontSizeChange: (value) async {
            await playerGlobalSettingsController.onFontSizeChange(value);
          },
        ),
        modeConfig: PlayerControllerModeConfig(
          isShowMode: true,
          mode: playerGlobalSettingsController.audioControlPlayOrder.value,
          loopCount: playerGlobalSettingsController.audioLoopCount.value,
          onModeChange: (value) {
            _controller.setPlayOrderStatus(value);
          },
          onLoopCountChange: (value) {
            _controller.setPlayOrderLoopCount(value);
          },
        ),
        listConfig: PlayerControllerListConfig(
          isShowList: true,
          onListShow: _controller.toggleDrawer,
        ),
        onPopupVisibilityChanged: (visible) {
          _controller.toggleAudioControllerAlwaysShow(visible);
        },
        customCenterWidget: Row(
          spacing: 10.wMin,
          children: [
            PlayPageTypeButtonWidget(
              pageTypeConfig: PlayPageTypeConfig(
                learnItems: _controller.currentSongDetail?.learnItems?.whereType<ZhenduLearnItems>().toList() ?? [],
                currentPageType: ZhenduPageTypeEnum.read,
                onPageTypeChange: (item) async {
                  _controller.onPageTypeChange(context, item);
                },
              ),
              onPopupVisibilityChanged: (visible) {
                _controller.toggleAudioControllerAlwaysShow(visible);
              },
            ),
            ButtonWidget(
              text: "跟读",
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
                  "assets/svg/public/icon_read_book.svg",
                  width: 32.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
                ),
              ),
              onTap: (){
                _controller.toggleShadowingMode();
              },
            ),
          ],
        ),

      );
    });
  }
}
