import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/widgets/image_animation_switcher/image_animation_switcher.dart';
import '../../../../common/widgets/player_widgets/play_list_drwer_widget.dart';
import '../../../../common/widgets/player_widgets/play_page_type_widgets.dart';
import '../../../../common/widgets/player_widgets/play_title_widget.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/interaction_record_utils/interaction_record_utils.dart';
import '../../../../utils/utils.dart';
import '../controllers/song_mv_controller.dart';
import '../models/song_sentence_model.dart';
import 'song_mv_lyrics_scrolling_widget.dart';

class SongMvView extends GetView<SongMvController> {
  const SongMvView({super.key});
  @override
  Widget build(BuildContext context) {
    return InteractionSessionContainer(
      source: 'song_mv',
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          controller.back();
        },
        child: GestureDetector(
          onTap: () {
            controller.toggleMenuShow();
          },
          onDoubleTap: () {
            controller.pausePlayback();
          },
          child: MouseRegion(
            onHover: (event) {
              controller.startMenuShowTime();
            },
            child: Scaffold(
              key: controller.scaffoldKey,
              backgroundColor: AppTheme.cBgPrimary.color,
              endDrawer: Obx(() {
                return PlayListDrwerWidget(
                  songs: controller.songList.toList(),
                  contents: controller.contents,
                  allCount: controller.contents?.length ?? 0,
                  selectedUniqueKey: controller.currentContentUniqueKey.value,
                  isLoading: controller.isLoadingData.value,
                  onSelected: (song) {
                    controller.switchSong(song);
                  },
                  onScrollEnd: () {
                    controller.loadData();
                  },
                );
              }),
              drawerEnableOpenDragGesture: false,
              drawerScrimColor: Colors.transparent,
              body: SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned.fill(child: _buildImageAnimationSwitcherWidget(context)),
                    Positioned.fill(child: _buildLyricWidget(context)),
                    _buildAITextWidget(context),
                    _buildKnowledgeListWidget(context),
                    _buildKnowledgeTextWidget(context),
                    _buildAudioControlWidget(context),
                    _buildLoadingUIWidget(),
                    _buildTitleWidget(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildLoadingUIWidget(){
    return Obx((){
      if(!controller.isSwitchLoadingUI.value) return Container();
      return Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        child: SpinKitFadingCircle(
          color: AppTheme.cBgBrand.color,
          size: 100.wMin,
        ),
      );
    });
  }


  Widget _buildTitleWidget(BuildContext context) {
    double top = MediaQuery.of(context).padding.top + 24.wMin;
    return Obx(() {
      return AnimatedPositioned(
        width: MediaQuery.of(context).size.width,
        top: controller.isShowMenu.value ? top : -(top + 72.wMin + 10.wMin),
        duration: const Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: () {
            controller.startMenuShowTime();
          },
          child: PlayTitleWidget(
            title: controller.currentSong?.contentInfo?.title,
            onFeedbackError: () {
              controller.showFeedbackErrorContentDialog(context);
            },
          ),
        ),
      );
    });
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

  /// 底部控制播放
  Widget _buildAudioControlWidget(BuildContext context) {
    return Obx(() {
      ZhenduDetilEntity? song = controller.currentSong;
      bool isFavorite = song?.contentInfo?.isFavorite ?? false;

      return AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        bottom: controller.isShowMenu.value ? 0 : -300.wMin,
        child: GestureDetector(
          onTap: () {
            controller.startMenuShowTime();
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(
              top: 16.wMin,
              bottom: 24.wMin,
            ),
            child: _SongMvPlayerControllerWidget(
              key: ValueKey(controller.currentContentUniqueKey.value),
              songMvController: controller,
              contextForDialog: context,
              isFavorite: isFavorite,
            ),
          ),
        ),
      );
    });
  }

  /// 图片切换组件
  Widget _buildImageAnimationSwitcherWidget(BuildContext context) {
    return Obx(() {
      if (controller.currentKnowledgeList.isEmpty) {
        ZhenduDetilEntity? song = controller.currentSong;

        if(song == null) return const SizedBox();

        if(song.contentInfo?.imageUrl == null) return const SizedBox();

        return ImageAnimationSwitcher(
          widgetSwitchType: ImageAnimationSwitchType.order,
          initIndex: 0,
          switchInterval: const Duration(seconds: 2),
          images: [
            CachedImageWidget(
              song.contentInfo?.imageUrl??"",
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              fadeInDuration: Duration.zero,
              errorWidget: Container(),
              placeholder: Container(),
            ),
          ],
        );
      }
      if (controller.currentKnowledgeIndex.value == -1) return const SizedBox();
      
      return ImageAnimationSwitcher(
        widgetSwitchType: ImageAnimationSwitchType.order,
        initIndex: controller.currentKnowledgeIndex.value,
        onIndexChanged: (index) {
          controller.updateBackgroundImage(index);
        },
        onSwitchIndex: (Duration? currentSwitchInterval, int currentIndex) {
          return controller.switchSentenceAndGetKnowledgeIndex(currentSwitchInterval, currentIndex);
        },
        controller: controller.imageSwitcherController,
        switchInterval: const Duration(seconds: 2),
        images: List.generate(controller.currentKnowledgeList.length, (index) {
          return CachedImageWidget(
            controller.currentKnowledgeList[index].imageUrl ?? "",
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            fadeInDuration: Duration.zero,
            errorWidget: Container(),
            placeholder: Container(),
          );
        }),
      );
    });
  }

  /// 当前知识点的文字
  Widget _buildKnowledgeTextWidget(BuildContext context) {
    return Obx(() {
      if (controller.isShowKnowledgeList.value) return const SizedBox();
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 360),
        left: 0,
        bottom: (controller.isShowMenu.value ? 180.wMin : 24.wMin) + MediaQuery.of(context).padding.bottom,
        child: Obx(() {
          List<SongEntityListSubContentList> currentKnowledgeList = controller.currentKnowledgeList.toList();
          if (currentKnowledgeList.isEmpty) return const SizedBox();
          if (controller.currentKnowledgeIndex.value == -1) return const SizedBox();
          int currentKnowledgeIndex = controller.currentKnowledgeIndex.value;
          if (currentKnowledgeIndex >= currentKnowledgeList.length) return const SizedBox();

          SongEntityListSubContentList currentKnowledge = currentKnowledgeList[currentKnowledgeIndex];

          return TapScaleWidget(
            onTap: () {
              controller.isShowKnowledgeList.value = !controller.isShowKnowledgeList.value;
            },
            sclae: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 76.wMin),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: _buildKnowledgeItemWidget(context, currentKnowledge, showArrow: true),
              ),
            ),
          );
        }),
      );
    });
  }

  Widget _buildKnowledgeItemWidget(BuildContext context, SongEntityListSubContentList item, {bool showArrow = false}) {
    List<LanguageText?>? gloss = item.gloss;
    List<LanguageText>? settingGloss = LearningLangUtils.getShowLBList(gloss);
    List<LanguageText> showGloss = LearningLangUtils.sortLearningLangFirst(settingGloss);

    return Container(
      key: ValueKey(item.contentId),
      width: 320.wMin,
      padding: EdgeInsets.only(left: 16.wMin, right: 10.wMin, top: 2.wMin, bottom: 2.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cInverseOverlay.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.content ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 28.wMin,
                    color: AppTheme.cInverseTextLight.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Visibility(
                visible: showArrow,
                child: SvgPicture.asset(
                  "assets/svg/public/icon_w_arrow_right.svg",
                  width: 24.wMin,
                  height: 24.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cInverseTextLight.color, BlendMode.srcIn),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(showGloss.length, (index) {
              if (showGloss[index].text == null) return const SizedBox();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: index != 0,
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      dashPattern: [5.wMin, 3.5.wMin],
                      color: AppTheme.cInverseTextLight.color.withValues(alpha: 0.8),
                      strokeWidth: 1.wMin,
                      customPath: (size) => Path()
                        ..moveTo(0, size.height)
                        ..relativeLineTo(size.width, 0),
                      padding: EdgeInsets.zero,
                      child: SizedBox(height: 1.wMin, width: 129.wMin),
                    ),
                  ),
                  Text(
                    showGloss[index].text ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: index == 0 ? 22.wMin : 18.wMin,
                      color: AppTheme.cInverseTextLight.color.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 知识点列表
  Widget _buildKnowledgeListWidget(BuildContext context) {
    return Obx(() {
      if (!controller.isShowKnowledgeList.value) return const SizedBox();
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 360),
        left: 0,
        bottom: (controller.isShowMenu.value ? 180.wMin : 24.wMin) + MediaQuery.of(context).padding.bottom,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(left: 76.wMin),
                child: TapScaleWidget(
                  onTap: () {
                    controller.isShowKnowledgeList.value = false;
                  },
                  sclae: 1,
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 16.wMin),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 10.wMin,
                      children: [
                        Container(
                          width: 38.wMin,
                          height: 38.wMin,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.cInverseOverlay.color,
                          ),
                          child: SvgPicture.asset(
                            "assets/svg/public/x.svg",
                            width: 24.wMin,
                            height: 24.wMin,
                            colorFilter: ColorFilter.mode(AppTheme.cInverseTextLight.color, BlendMode.srcIn),
                          ),
                        ),
                        Text(
                          "关闭知识点列表",
                          style: TextStyle(
                            fontSize: 22.wMin,
                            color: AppTheme.cInverseTextLight.color,
                            fontWeight: FontWeight.w400,
                            shadows: [
                              Shadow(
                                color: AppTheme.cStaticBlack.color.withValues(alpha: 0.4),
                                offset: const Offset(0, 2),
                                blurRadius: 4.wMin,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Obx(() {
                List<SongSentenceModel> playSentenceList = controller.playSentenceList.toList();
                Set<SongEntityListSubContentList> uniqueKnowledgeList = {};
                for (int i = 0; i < playSentenceList.length; i++) {
                  SongSentenceModel sentence = playSentenceList[i];
                  uniqueKnowledgeList.addAll(sentence.knowledgeList);
                }
                List<SongEntityListSubContentList> showKnowledgeList = uniqueKnowledgeList.toList();
                if (uniqueKnowledgeList.isEmpty) {
                  showKnowledgeList = controller.currentKnowledgeList.toList();
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 76.wMin),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 16.wMin,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(showKnowledgeList.length, (index) {
                      return ListAnimationWidget(
                        index: index,
                        horizontalOffset: 20.wMin,
                        child: _buildKnowledgeItemWidget(context, showKnowledgeList[index]),
                      );
                    }),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  /// 歌词显示组件
  Widget _buildLyricWidget(BuildContext context) {
    return Obx(() {
      int lyricReadyResult = controller.lyricReadyResult.value;
      if (lyricReadyResult == -1) {
        return const SizedBox();
      } else if (lyricReadyResult == 0) {
        return _buildLyricListWidget(context);
      } else if (lyricReadyResult == 1) {
        return _buildFullTextWidget(context);
      }
      return const SizedBox();
    });
  }

  /// 全文显示的歌词
  Widget _buildFullTextWidget(BuildContext context) {
    return Obx(() {
      bool isShowLyric = controller.audioControlTranslate.value != LangPreference.none;
      if (!isShowLyric) return const SizedBox();
      ZhenduDetilEntity? song = controller.currentSong;
      if (song == null) return const SizedBox();
      

      return Container(
        alignment: Alignment.center,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false, // 隐藏所有滚动条
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 76.wMin,
              right: 76.wMin,
              top: MediaQuery.of(context).padding.top + 200.wMin,
              bottom: MediaQuery.of(context).padding.bottom + 400.wMin,
            ),
            child: Column(
              spacing: 16.wMin,
              children: List.generate(controller.noAssSentenceList.length, (sentenceIndex) {
                SongSentenceModel sentenceModel = controller.noAssSentenceList[sentenceIndex];
                return Wrap(
                  alignment: WrapAlignment.center,
                  children: List.generate(sentenceModel.sentence.length, (wordIndex) {
                    return _buildFullTextLyricWidget(context, sentenceModel, wordIndex);
                  }),
                );
              }),
            ),
          ),
        ),
      );
    });
  }


  /// 全文显示的歌词文本
  Widget _buildFullTextLyricWidget(BuildContext context, SongSentenceModel sentence, int wordIndex) {
    bool isSelect = sentence.selectedWordIndex == wordIndex;

    return Obx((){
      double fontSize = _fullTextWordFontSize(controller.audioFontSize.value);

      TextStyle textStyle = TextStyle(
        fontSize: fontSize.wMin,
        fontWeight: FontWeight.w400,
        color: AppTheme.cInverseTextLight.color.withValues(alpha: isSelect ? 1.0 : 0.7),
        shadows: [
          Shadow(
            color: AppTheme.cStaticBlack.color.withValues(alpha: 0.4),
            offset: const Offset(0, 2),
            blurRadius: 4.wMin,
          ),
        ],
      );

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 100),
            textAlign: TextAlign.center,
            style: textStyle,
            child: Text(sentence.sentence[wordIndex].leftSpace),
          ),
          TapScaleLongRightWidget(
            onLongSecondaryTap: (globalPosition, localPosition) {
              controller.openSmallDictionary(context, sentence, wordIndex);
            },
            sclae: 1.02,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.wMin),
                color: AppTheme.cTextBrand.color.withValues(alpha: isSelect ? 0.6 : 0.0),
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 100),
                textAlign: TextAlign.center,
                style: textStyle,
                child: Text(sentence.sentence[wordIndex].text),
              ),
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 100),
            textAlign: TextAlign.center,
            style: textStyle,
            child: Text(sentence.sentence[wordIndex].rightSpace),
          ),
        ],
      );
    });
  }

  /// 逐句显示的歌词列表
  Widget _buildLyricListWidget(BuildContext context) {
    return Obx(() {
      return SongMvLyricsScrollingWidget(
        key: ValueKey(controller.currentContentUniqueKey.value),
        playSentenceList: controller.playSentenceList.toList(),
        currentSentenceIndex: controller.playSentenceIndex.value,
        currentWordIndex: controller.playWordIndex,
        audioControlTranslate: controller.audioControlTranslate.value,
        audioFontSize: controller.audioFontSize.value,
        onSentenceTap: (sentence, sentenceIndex) {
          controller.playForSentence(sentence, sentenceIndex);
        },
        onWordLongPress: (ctx, sentence, index, {required onLongPressEnd}) {
          controller.openSmallDictionary(context, sentence, index, onLongPressEnd: onLongPressEnd);
        },
      );
    });
  }

  double _fullTextWordFontSize(FontSizeEnum fontSize) {
    switch (fontSize) {
      case FontSizeEnum.extraSmall:
        return 56;
      case FontSizeEnum.small:
        return 62;
      case FontSizeEnum.standard:
        return 70;
      case FontSizeEnum.large:
        return 78;
      case FontSizeEnum.extraLarge:
        return 86;
      case FontSizeEnum.extraExtraLarge:
        return 94;
    }
  }
  
}

class _SongMvPlayerControllerWidget extends StatefulWidget {
  const _SongMvPlayerControllerWidget({
    super.key,
    required this.songMvController,
    required this.contextForDialog,
    required this.isFavorite,
  });

  final SongMvController songMvController;
  final BuildContext contextForDialog;
  final bool isFavorite;

  @override
  State<_SongMvPlayerControllerWidget> createState() => _SongMvPlayerControllerWidgetState();
}

class _SongMvPlayerControllerWidgetState extends State<_SongMvPlayerControllerWidget> {
  SongMvController get _controller => widget.songMvController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {

      List<ZhenduLearnItems?> pageTypeList = _controller.currentSong?.learnItems ?? [];

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
          position: _controller.playerPosition.value,
          isShowPreviousNextSentence: _controller.playSentenceList.isNotEmpty,
          onPlayPause: (_) async {
            await _controller.pausePlayback();
          },
          onSeek: (position) async {
            await _controller.audioPlayerUtils.seek(position);
          },
          onPreviousNext: (direction) async {
            if (direction == PlayerControllerDirection.previous) {
              await _controller.previousClick();
            } else {
              await _controller.nextClick();
            }
          },
          onPreviousNextSentence: (direction) async {
            if (direction == PlayerControllerDirection.previous) {
              await _controller.previousSentenceClick();
            } else {
              await _controller.nextSentenceClick();
            }
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
          volume: _controller.volume.value,
          onVolumeChange: (value) async {
            await _controller.onVolumeChange(value);
          },
        ),
        fitConfig: PlayerControllerFitConfig(
          isShowFit: false,
        ),
        speedMultiplierConfig: PlayerControllerSpeedMultiplierConfig(
          isShowSpeedMultiplier: true,
          speedMultiplier: _controller.playbackRate.value,
          speedList: Get.find<ConfigController>().userSetting.value.expandAudioSpeedList,
          onSpeedMultiplierChange: (value) async {
            _controller.playbackRate.value = value;
            await _controller.audioPlayerUtils.setPlaybackRate(value);
            ConfigController configController = Get.find<ConfigController>();
            configController.setUserSetting(expandAudioSpeed: value);
          },
        ),
        subtitleConfig: PlayerControllerSubtitleConfig(
          isShowSubtitle: true,
          langPreference: _controller.audioControlTranslate.value,
          fontSize: _controller.audioFontSize.value,
          onSubtitleChange: (value) {
            _controller.audioControlTranslate.value = value;
            ConfigController configController = Get.find<ConfigController>();
            configController.setUserSetting(expandTranslationType: value.code);
          },
          onSubtitleFontSizeChange: (value) {
            _controller.audioFontSize.value = value;
            AudioControlUtils.saveSetting(AudioControlSettingModel(fontSize: value));
          },
        ),
        durationConfig: PlayerControllerDurationConfig(
          isShowDuration: true,
          timing: _controller.playerTiming.value,
          remainingTimeText: _controller.timingCloseDisplayStr.value,
          onDurationChange: (value) async {
            await _controller.onPlayerTimingChange(value);
          },
        ),
        modeConfig: PlayerControllerModeConfig(
          isShowMode: true,
          mode: _controller.audioControlPlayOrder.value,
          loopCount: _controller.audioLoopCount.value,
          onModeChange: (value) {
            _controller.audioControlPlayOrder.value = value;
            AudioControlUtils.saveSetting(AudioControlSettingModel(playOrder: value));
          },
          onLoopCountChange: (value) {
            _controller.audioLoopCount.value = value;
            AudioControlUtils.saveSetting(AudioControlSettingModel(playOrderLoopCount: value));
          },
        ),
        listConfig: PlayerControllerListConfig(
          isShowList: true,
          onListShow: _controller.toggleDrawer,
        ),
        onPopupVisibilityChanged: (visible) {
          _controller.onMenuShow(visible);
        },
        customCenterWidget: PlayPageTypeButtonWidget(
          pageTypeConfig: PlayPageTypeConfig(
            learnItems: pageTypeList.whereType<ZhenduLearnItems>().toList(),
            currentPageType: ZhenduPageTypeEnum.listen,
            onPageTypeChange: (item) async {
              _controller.onPageTypeChange(widget.contextForDialog, item);
            },
          ),
          onPopupVisibilityChanged: (visible) {
            _controller.onMenuShow(visible);
          },
        ),
      );
    });
  }
}
