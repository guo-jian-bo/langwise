import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/official_course_details/common/official_course_details_sequence_video_card_widget.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../routes/routes.dart';
import '../bindings/official_course_details_flash_notes_binding.dart';
import '../controllers/official_course_details_flash_notes_controller.dart';
import 'official_course_details_flash_setting_dialog.dart';

class OfficialCourseDetailsFlashNotesView extends GetView<OfficialCourseDetailsFlashNotesController> {
  static const double _bottomSwitcherScale = 1.5;
  final String tagText;
  const OfficialCourseDetailsFlashNotesView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
          () => OfficialCourseDetailsFlashNotesView(tagText: tag),
      binding: OfficialCourseDetailsFlashNotesBinding(tagText: tag),
      routeName: Routes.OFFICIAL_COURSE_DETAILS_FLASH_NOTES,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await controller.handleExit();
      },
      child: Scaffold(
        backgroundColor: AppTheme.cBgPrimary.color,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              BreadcrumbWidget(
                onBack: () {
                  unawaited(controller.handleExit());
                },
                actionWidget: buildSettingEntryWidget(),
              ),
              Expanded(
                child: _buildContentWidget(),
              ),
              buildPlayWidget(context),
              SizedBox(height: 24.wMin + MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSettingEntryWidget() {
    return Obx(() {
      final summaryItems = [
        controller.currentPronunciationLabel,
        controller.currentTextDisplayLabel,
        controller.currentIntervalLabel,
        controller.currentSpeedLabel,
      ];
      return TapScaleWidget(
        onTap: controller.showSetting,
        sclae: 1.01,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 820.wMin,
            minHeight: 52.wMin,
          ),
          padding: EdgeInsets.symmetric(horizontal: 18.wMin, vertical: 12.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cBgSecondary.color,
            borderRadius: BorderRadius.circular(999.wMin),
            border: Border.all(
              color: AppTheme.cBorderPrimary.color.withValues(alpha: 0.9),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    summaryItems.join('  |  '),
                    style: TextStyle(
                      fontSize: 22.wMin,
                      color: AppTheme.cTextSecondary.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.wMin),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 22.wMin,
                color: AppTheme.cTextSecondary.color,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildContentWidget() {
    return Center(
      child: Obx(() {
        controller.mediaCacheEpoch.value;
        controller.videoControllerEpoch.value;
        if (controller.knowledgeList.isEmpty) return const SizedBox.shrink();
        return Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification && notification.dragDetails != null) {
                  controller.restartAutoNextTimer();
                }
                return false;
              },
              child: PageView.builder(
                clipBehavior: Clip.none,
                controller: controller.pageController,
                itemCount: controller.knowledgeList.length,
                itemBuilder: (ctx, index) {
                  return _buildFlashCardLayout(
                    controller.knowledgeList[index],
                    index,
                  );
                },
                onPageChanged: (index) {
                  controller.changeIndex(index);
                },
              ),
            ),
            _buildHiddenPreloadVideoWidget(),
          ],
        );
      }),
    );
  }

  Widget _buildFlashCardLayout(
      UnitKnowledgePointsEntityKnowledgeList knowledgeModel,
      int index,
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 24.wMin),
      child: Obx(() {
        final bool isCovered = controller.cardIsFront.value;
        final bool isCurrentCard = index == controller.currentIndex.value;
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(Get.context!).size.width - 72.wMin,
          ),
          child: SizedBox(
            width: 2200.wMin,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final gap = 56.wMin;
                final mediaSize = 800.wMin;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: mediaSize,
                      height: mediaSize,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OfficialCourseDetailsSequenceVideoCardWidget(
                              imageUrl: controller.resolveDisplayPosterPath(knowledgeModel),
                              relationVideo: _buildRelationVideo(knowledgeModel),
                              semanticPlaybackKey: 'flash_${knowledgeModel.semanticId ?? knowledgeModel.contentId ?? controller.currentIndex.value}',
                              isActive: isCurrentCard,
                              size: mediaSize,
                              autoPlayOnce: false,
                              playbackRate: controller.playSpeed.value,
                              videoController: isCurrentCard ? controller.flashVideoController : null,
                              onBeforePlay: () async {
                                await controller.interruptManualAudioPlayback();
                              },
                            ),
                          ),
                          _buildDifficultyLabel(knowledgeModel),
                        ],
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: isCovered
                            ? _buildCoveredPanel(knowledgeModel)
                            : _buildAnswerPanel(knowledgeModel),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      }),
    );
  }

  EnKnowledgeEntityRelationVideo? _buildRelationVideo(
      UnitKnowledgePointsEntityKnowledgeList knowledgeModel,
      ) {
    final video = knowledgeModel.video;
    final videoUrl = video?.videoUrl?.trim() ?? '';
    if (videoUrl.isEmpty) return null;
    return EnKnowledgeEntityRelationVideo(
      uid: video?.videoRelationId,
      videoId: video?.videoId,
      type: knowledgeModel.contentType,
      contentId: knowledgeModel.contentId,
      semanticId: knowledgeModel.semanticId,
      videoUrl: controller.resolveDisplayVideoPath(knowledgeModel),
      videoKey: video?.videoKey,
      duration: video?.duration,
      startSeconds: video?.startSeconds,
      endSeconds: video?.endSeconds,
      firstImageUrl: controller.resolveDisplayPosterPath(knowledgeModel),
      firstFrameUrl: controller.resolveDisplayPosterPath(knowledgeModel),
      firstFrameKey: video?.firstFrameKey,
      firstFrameMd5: video?.firstFrameMd5,
      ass: video?.ass,
      translateAss: video?.translateAss,
      translate: video?.translateAss,
      locked: video?.locked,
      isMute: video?.isMute,
    );
  }

  Widget _buildHiddenPreloadVideoWidget() {
    controller.mediaCacheEpoch.value;
    controller.videoControllerEpoch.value;
    final preloadKnowledge = controller.preloadKnowledge;
    if (preloadKnowledge == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: Offstage(
        offstage: true,
        child: SizedBox(
          width: 1,
          height: 1,
          child: OfficialCourseDetailsSequenceVideoCardWidget(
            imageUrl: controller.resolvePreviewPosterPath(preloadKnowledge),
            relationVideo: _buildRelationVideo(preloadKnowledge),
            semanticPlaybackKey:
                'flash_preload_${preloadKnowledge.semanticId ?? preloadKnowledge.contentId ?? controller.nextVideoPreloadIndex.value}',
            isActive: false,
            size: 1,
            autoPlayOnce: false,
            playbackRate: controller.playSpeed.value,
            videoController: controller.preloadFlashVideoController,
          ),
        ),
      ),
    );
  }

  Widget _buildCoveredPanel(UnitKnowledgePointsEntityKnowledgeList knowledgeModel) {
    final String? previewText = _buildCoveredPreviewText(knowledgeModel);
    return TapScaleWidget(
      onTap: controller.revealAnswer,
      sclae: 1.01,
      child: Container(
        key: const ValueKey('covered'),
        constraints: BoxConstraints(minHeight: 440.wMin),
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 24.wMin),
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              previewText ?? '点击显示答案',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: previewText == null ? 72.wMin : 64.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w700,
                height: 1.12,
              ),
            ),
            SizedBox(height: 20.wMin),
            Text(
              previewText == null ? '先想一想，再揭示答案' : '点击查看完整释义',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerPanel(UnitKnowledgePointsEntityKnowledgeList knowledgeModel) {
    final PronunciationsEntity? pronunciationModel = _findPronunciation(knowledgeModel);
    return Container(
      key: const ValueKey('revealed'),
      constraints: BoxConstraints(minHeight: 520.wMin),
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 16.wMin),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AutoSizeText(
                  knowledgeModel.content ?? "",
                  maxLines: knowledgeModel.isWord || knowledgeModel.isPhrase ? 1 : 2,
                  minFontSize: 20,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 74.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ),
              if (pronunciationModel?.audioUrl != null) ...[
                SizedBox(width: 12.wMin),
                _buildReplayButton(
                  pronunciationModel?.audioUrl,
                  controller.resolveCachedAudioPath(pronunciationModel?.audioUrl),
                ),
              ],
            ],
          ),
          if (knowledgeModel.isWord && (pronunciationModel?.phonetic?.isNotEmpty ?? false)) ...[
            SizedBox(height: 12.wMin),
            Text(
              '/${pronunciationModel?.phonetic ?? ""}/',
              style: TextStyle(
                fontSize: 28.wMin,
                color: AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          Obx(() {
            final List<LanguageText> glossList = _resolveGlossList(knowledgeModel);
            if (glossList.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.wMin),
                ...List.generate(glossList.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: index == glossList.length - 1 ? 0 : 10.wMin),
                    child: Text(
                      glossList[index].text ?? '',
                      style: TextStyle(
                        fontSize: index == 0 ? 26.wMin : 22.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: index == 0 ? FontWeight.w500 : FontWeight.w400,
                        height: 1.35,
                      ),
                    ),
                  );
                }),
              ],
            );
          }),
          SizedBox(height: 26.wMin),
          _buildViewDetailButton(),
          SizedBox(height: 24.wMin),
          Align(
            alignment: Alignment.centerRight,
            child: ButtonWidget(
              text: "重新遮住",
              width: 176.wMin,
              height: 64.wMin,
              borderRadius: 999,
              color: const Color(0xFF2B0A52),
              fontSize: 26.wMin,
              fontColor: const Color(0xFFD4B3FF),
              fontWeight: FontWeight.w600,
              sclae: 1.01,
              onTap: controller.coverAnswer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewDetailButton() {
    return TapScaleWidget(
      onTap: controller.openCurrentKnowledgeDetail,
      sclae: 1.02,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '查看详情',
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextBrand.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 6.wMin),
          Icon(
            Icons.chevron_right_rounded,
            size: 22.wMin,
            color: AppTheme.cTextBrand.color,
          ),
        ],
      ),
    );
  }

  Widget _buildReplayButton(String? audioUrl, String? audioFilePath) {
    return _FlashReplayButton(
      audioUrl: audioUrl,
      audioFilePath: audioFilePath,
      playSpeed: controller.playSpeed.value,
      onBeforePlay: controller.beginManualAudioPlayback,
      onAfterPlay: controller.endManualAudioPlayback,
    );
  }

  Widget _buildDifficultyLabel(UnitKnowledgePointsEntityKnowledgeList knowledgeModel) {
    if (knowledgeModel.difficulty == null) {
      return const SizedBox.shrink();
    }

    if (knowledgeModel.difficulty?.min == knowledgeModel.difficulty?.max) {
      return Positioned(
        top: 18.wMin,
        left: 18.wMin,
        child: StatusTagDifficultyWidget(
          difficulty: knowledgeModel.difficulty?.min,
          language: Get.find<ConfigController>().userSetting.value.learningLang,
          borderRadius: 8.wMin,
          padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
          fontSize: 28.wMin,
        ),
      );
    }

    return Positioned(
      top: 18.wMin,
      left: 18.wMin,
      child: Row(
        children: [
          StatusTagDifficultyWidget(
            difficulty: knowledgeModel.difficulty?.min,
            language: Get.find<ConfigController>().userSetting.value.learningLang,
            borderRadius: 8.wMin,
            padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
            fontSize: 28.wMin,
          ),
          SizedBox(width: 5.wMin),
          Text(
            "-",
            style: TextStyle(
              fontSize: 28.wMin,
              color: const Color(0xff697179),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 5.wMin),
          StatusTagDifficultyWidget(
            difficulty: knowledgeModel.difficulty?.max,
            language: Get.find<ConfigController>().userSetting.value.learningLang,
            borderRadius: 8.wMin,
            padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
            fontSize: 28.wMin,
          ),
        ],
      ),
    );
  }

  Widget buildPlayWidget(BuildContext context) {
    return Obx(() {
      if (controller.knowledgeList.isEmpty) {
        return const SizedBox.shrink();
      }
      final int currentIndex = controller.currentIndex.value;
      final int total = controller.knowledgeList.length;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.wMin),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 64.wMin,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: (80 * _bottomSwitcherScale).wMin,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildPlaybackControls(),
                      if (controller.isCompleted.value)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildActionButton(
                                text: '再来一遍',
                                onTap: () async {
                                  await controller.replayFromStart();
                                },
                              ),
                              SizedBox(width: 12.wMin),
                              _buildActionButton(
                                text: '闪记完成',
                                isPrimary: true,
                                onTap: () async {
                                  await controller.completeFlashNotes();
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.wMin),
              Text(
                '${currentIndex + 1}/$total',
                style: TextStyle(
                  fontSize: (18 * _bottomSwitcherScale).wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPlaybackControls() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (18 * _bottomSwitcherScale).wMin,
        vertical: (14 * _bottomSwitcherScale).wMin,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cBgSecondary.color,
        borderRadius: BorderRadius.circular(999.wMin),
        border: Border.all(color: AppTheme.cBorderPrimary.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildControlButton(
            icon: Icons.chevron_left_rounded,
            onTap: OptimizeUtils.noneThrottle(() {
              controller.previousCard(forcePlayCurrent: true);
            }, 300),
          ),
          SizedBox(width: (16 * _bottomSwitcherScale).wMin),
          _buildControlButton(
            icon: controller.isAutoPlay.value
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            onTap: controller.toggleAutoPlay,
            isPrimary: true,
          ),
          SizedBox(width: (16 * _bottomSwitcherScale).wMin),
          _buildControlButton(
            icon: Icons.chevron_right_rounded,
            onTap: OptimizeUtils.noneThrottle(() {
              controller.nextCard(forcePlayCurrent: true);
            }, 300),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.02,
      child: Container(
        height: 54.wMin,
        padding: EdgeInsets.symmetric(horizontal: 28.wMin),
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.cBgBrand.color : Colors.transparent,
          borderRadius: BorderRadius.circular(999.wMin),
          border: Border.all(
            color: AppTheme.cBorderBrand.color,
            width: 1.wMin,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 22.wMin,
              color: isPrimary ? AppTheme.cStaticWhite.color : AppTheme.cTextBrand.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.02,
      child: Container(
        width: (52 * _bottomSwitcherScale).wMin,
        height: (52 * _bottomSwitcherScale).wMin,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPrimary
              ? AppTheme.cBgBrand.color.withValues(alpha: 0.16)
              : AppTheme.cSurfaceTertiary.color,
          border: Border.all(
            color: isPrimary
                ? AppTheme.cBorderBrand.color
                : AppTheme.cBorderPrimary.color,
          ),
        ),
        child: Icon(
          icon,
          size: (30 * _bottomSwitcherScale).wMin,
          color: isPrimary ? AppTheme.cTextBrand.color : AppTheme.cTextPrimary.color,
        ),
      ),
    );
  }

  PronunciationsEntity? _findPronunciation(UnitKnowledgePointsEntityKnowledgeList knowledgeModel) {
    for (final item in knowledgeModel.pronunciations ?? []) {
      if (item.national == controller.national.value.value) {
        return item;
      }
    }
    final pronunciations = knowledgeModel.pronunciations;
    if (pronunciations == null || pronunciations.isEmpty) {
      return null;
    }
    return pronunciations.first;
  }

  List<LanguageText> _resolveGlossList(UnitKnowledgePointsEntityKnowledgeList knowledgeModel) {
    final List<LanguageText?> raw = knowledgeModel.gloss ?? const <LanguageText?>[];
    if (raw.isEmpty) return const [];

    final LangPreference preference =
        Get.find<ConfigController>().userSetting.value.expandLang;

    final LanguageText? learning = LearningLangUtils.getLearningLang(raw);
    final LanguageText? local = LearningLangUtils.getLocalLang(raw);

    LanguageText? normalize(LanguageText? value) {
      if (value == null) return null;
      if ((value.text ?? '').trim().isEmpty) return null;
      return value;
    }

    final LanguageText? learningGloss = normalize(learning);
    final LanguageText? localGloss = normalize(local);

    if (preference == LangPreference.none) return const [];

    if (preference == LangPreference.translation) {
      return localGloss == null ? const [] : [localGloss];
    }

    if (preference == LangPreference.original) {
      if (learningGloss != null) return [learningGloss];
      return localGloss == null ? const [] : [localGloss];
    }

    final List<LanguageText> result = <LanguageText>[];
    final LanguageText? primary = learningGloss ?? localGloss;
    if (primary != null) {
      result.add(primary);
    }
    if (localGloss != null &&
        (primary == null || (localGloss.text ?? '') != (primary.text ?? ''))) {
      result.add(localGloss);
    }
    return result;
  }

  String? _buildCoveredPreviewText(UnitKnowledgePointsEntityKnowledgeList knowledgeModel) {
    if (controller.showType.value == FlashSettingCardShowType.imageAndLearText) {
      return knowledgeModel.content;
    }
    if (controller.showType.value == FlashSettingCardShowType.imageAndLocalText) {
      return LearningLangUtils.getLocalLang(knowledgeModel.gloss ?? [])?.text;
    }
    return null;
  }
}

class _FlashReplayButton extends StatefulWidget {
  final String? audioUrl;
  final String? audioFilePath;
  final double playSpeed;
  final Future<int> Function() onBeforePlay;
  final Future<void> Function(int epoch) onAfterPlay;

  const _FlashReplayButton({
    required this.audioUrl,
    required this.audioFilePath,
    required this.playSpeed,
    required this.onBeforePlay,
    required this.onAfterPlay,
  });

  @override
  State<_FlashReplayButton> createState() => _FlashReplayButtonState();
}

class _FlashReplayButtonState extends State<_FlashReplayButton> {
  bool _isPlaying = false;

  Future<void> _handleTap() async {
    if (widget.audioUrl == null || widget.audioUrl!.isEmpty) return;
    final int epoch = await widget.onBeforePlay();
    setState(() {
      _isPlaying = true;
    });
    try {
      await PlayAudioUtils.instance.playSingle(
        widget.audioUrl,
        filePath: widget.audioFilePath,
        playbackRate: widget.playSpeed,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
      await widget.onAfterPlay(epoch);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: _handleTap,
      sclae: 1.02,
      child: Container(
        width: 56.wMin,
        height: 56.wMin,
        decoration: BoxDecoration(
          color: AppTheme.cBgSecondary.color,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.cBorderPrimary.color,
          ),
        ),
        alignment: Alignment.center,
        child: AnimationPlayIconWidget(
          isPlaying: _isPlaying,
          size: 28.wMin,
        ),
      ),
    );
  }
}
