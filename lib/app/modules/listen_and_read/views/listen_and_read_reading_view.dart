
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/audio_control_widget.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../common/listen_and_read_content_widget.dart';
import '../controllers/listen_and_read_reading_controller.dart';

class ListenAndReadReadingView extends GetView<ListenAndReadReadingController> {
  /// 阅读页面
  const ListenAndReadReadingView({super.key});

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
                          contentFontSizeMultiple: controller.listenAndReadController.contentFontSizeMultiple.value,
                          translateStatus: controller.listenAndReadController.translateStatus.value,
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
            double bottomPadding = MediaQuery.of(context).padding.bottom + 200.wMin;
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: isShowAudioController ? 0 : -bottomPadding,
              width: MediaQuery.of(context).size.width,
              child: GestureDetector(
                onTap: (){},
                child: Container(
                  padding: EdgeInsets.only(
                    top: 16.wMin,
                    bottom: 24.wMin + MediaQuery.of(context).padding.bottom,
                    left: 80.wMin,
                    right: 80.wMin,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                      AppTheme.cBgPrimary.withValues(alpha: 0.8),
                      AppTheme.cBgPrimary.withValues(alpha: 1),
                      ],
                    ),
                  ),
                  child: AudioControlWidget(
                    audioPlayerUtils: controller.listenAndReadController.audioPlayerUtils,
                    controller: controller.listenAndReadController.audioControlController,
                    initSpeed: controller.listenAndReadController.playbackRate.value,
                    initPosition: controller.listenAndReadController.position.value,
                    translateValue: controller.listenAndReadController.translateStatus.value,
                    showPreviousNextTrackButton: true,
                    showFontSizeButton: true,
                    showPlayOrderButton: true,
                    playOrderLoopCount: controller.listenAndReadController.playOrderLoopCount.value,
                    fontSizeMultiple: controller.listenAndReadController.contentFontSizeMultiple.value,
                    playOrderValue: controller.listenAndReadController.playOrderStatus.value,
                    onSpeedChanged: (speed) {
                      controller.listenAndReadController.playbackRate.value = speed;
                    },
                    onPlayOrderLoopCountChanged: (loopCount) {
                      controller.listenAndReadController.setPlayOrderLoopCount(loopCount);
                    },
                    onPlayOrderChanged: (type) {
                      controller.listenAndReadController.setPlayOrderStatus(type);
                    },
                    onFontSizeMultipleChanged: (fontSizeMultiple) {
                      controller.listenAndReadController.contentFontSizeMultiple.value = fontSizeMultiple;
                    },
                    onTranslateChanged: (type) {
                      controller.listenAndReadController.translateStatus.value = type;
                    },
                    onPreviousNextSentenceChanged: (type) {
                      controller.listenAndReadController.nextOrPreviousSentence(type);
                    },
                    onMenuShow: controller.listenAndReadController.toggleAudioControllerAlwaysShow,
                    showAudioListButton: true,
                    onAudioListButtonPressed: () {
                      controller.listenAndReadController.toggleDrawer();
                    },
                    onPreviousNextTrackChanged: (type) {
                      if(type == AudioControlPreviousNext.next) {
                        controller.listenAndReadController.nextClick();
                      } else {
                        controller.listenAndReadController.previousClick();
                      }
                    },
                    showFavoriteButton: true,
                    isFavorite: controller.listenAndReadController.currentSong?.favorited ?? false,
                    onFavoriteChanged: (isFavorite) {
                      controller.listenAndReadController.toggleFavourite();
                    },
                    onPlayPauseChanged: () {
                      controller.listenAndReadController.pauseAndPlay();
                    },
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
      floatingActionButton: _buildListenButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }


  /// 听按钮
  Widget _buildListenButton() {

    return Obx((){
      bool isShowMenu = controller.listenAndReadController.isShowAudioController.value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(
          bottom: isShowMenu ? 180.wMin : 0,
        ),
        child: TapScaleWidget(
          onTap: () {
            controller.jumpToMvPlayPage();
          },
          sclae: 1.05,
          child: SvgPicture.asset(
            'assets/svg/public/icon_listen_button.svg',
            width: 90.wMin,
          ),
        ),
      );
    });

  }

  


}


