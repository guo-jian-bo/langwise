import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/official_course_details/common/official_course_details_sequence_video_card_widget.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/widgets/guide_engine/guide_engine.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/learning_lang_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../routes/routes.dart';
import '../bindings/official_course_details_preview_binding.dart';
import '../controllers/official_course_details_preview_controller.dart';

class OfficialCourseDetailsPreviewView extends GetView<OfficialCourseDetailsPreviewController> {
  static const double _bottomSwitcherScale = 1.5;
  final String tagText;
  const OfficialCourseDetailsPreviewView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
          () => OfficialCourseDetailsPreviewView(tagText: tag),
      binding: OfficialCourseDetailsPreviewBinding(tagText: tag),
      routeName: Routes.OFFICIAL_COURSE_DETAILS_PREVIEW,
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
              SizedBox(height: 16.wMin),
              Expanded(
                child: Center(
                  child: buildCardWidget(),
                ),
              ),
              SizedBox(height: 24.wMin),
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
        controller.currentPlayIntervalLabel,
        controller.currentPlayModeLabel,
        controller.currentRepeatLabel,
        controller.currentSpeedLabel,
      ];
      return TapScaleWidget(
        onTap: () => controller.playSetting(),
        sclae: 1.01,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 860.wMin,
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

  Widget buildCardWidget() {
    return Obx(() {
      final displayModeCode =
          Get.find<ConfigController>().userSetting.value.expandLang.code;
      controller.mediaCacheEpoch.value;
      controller.videoControllerEpoch.value;
      if (controller.knowledgeList.isEmpty) return const SizedBox.shrink();
      if (controller.progress.value < 0 ||
          controller.progress.value >= controller.knowledgeList.length) {
        return const SizedBox.shrink();
      }
      final knowledgeModel =
      controller.knowledgeList[controller.progress.value];
      final pronunciationModel = _getPronunciationModel(knowledgeModel);
      final displayGlossList = _resolveGlossList(knowledgeModel);
      final bool isTextHidden = displayModeCode == LangPreference.none.code;


      return Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Container(
              key: ValueKey(
                '${controller.progress.value}_${pronunciationModel?.audioUrl}_$displayModeCode',
              ),
              width: 2200.wMin,
              constraints: BoxConstraints(
                maxWidth: Get.width - 72.wMin,
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 20.wMin),
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
                                imageUrl: controller.resolveDisplayImagePath(knowledgeModel),
                                relationVideo: _buildRelationVideo(knowledgeModel),
                                semanticPlaybackKey:
                                'preview_${knowledgeModel.semanticId ?? knowledgeModel.contentId ?? controller.progress.value}',
                                isActive: true,
                                size: mediaSize,
                                autoPlayOnce: false,
                                playbackRate: controller.playSpeed.value,
                                videoController: controller.previewVideoController,
                                onFinished: (reason) {
                                  if (controller.isClosed) return;
                                  controller.onCurrentVideoFinished(reason);
                                },
                                onBeforePlay: () async {
                                  await controller.pausePlaybackForSetting();
                                },
                              ),
                            ),
                            _buildDifficultyLabel(knowledgeModel),
                          ],
                        ),
                      ),
                      SizedBox(width: gap),
                      Expanded(
                        child: Container(
                          height: double.infinity,
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: AutoSizeText(
                                      knowledgeModel.content ?? "",
                                      maxLines: 4,
                                      minFontSize: 18,
                                      style: TextStyle(
                                        fontSize: 56.wMin,
                                        color: AppTheme.cTextPrimary.color,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.wMin),
                                  _buildReplayButton(knowledgeModel),
                                ],
                              ),
                              if (knowledgeModel.isWord) ...[
                                SizedBox(height: 20.wMin),
                                Text(
                                  '/${pronunciationModel?.phonetic ?? ""}/',
                                  style: TextStyle(
                                    fontSize: 30.wMin,
                                    color: AppTheme.cTextTertiary.color,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                              if (!isTextHidden && displayGlossList.isNotEmpty) ...[
                                SizedBox(height: 28.wMin),
                                ...List.generate(displayGlossList.length, (index) {
                                  final item = displayGlossList[index];
                                  final bool isFirstLine = index == 0;
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: index == displayGlossList.length - 1 ? 0 : 14.wMin),
                                    child: Text(
                                      item.text ?? "",
                                      style: TextStyle(
                                        fontSize: isFirstLine ? 28.wMin : 24.wMin,
                                        color: isFirstLine
                                            ? AppTheme.cTextSecondary.color
                                            : AppTheme.cTextTertiary.color,
                                        fontWeight: FontWeight.w400,
                                        height: 1.5,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                              SizedBox(height: 28.wMin),
                              _buildViewDetailButton(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          _buildHiddenPreloadVideoWidget(),
        ],
      );
    });
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
            imageUrl: controller.resolveDisplayImagePath(preloadKnowledge),
            relationVideo: _buildRelationVideo(preloadKnowledge),
            semanticPlaybackKey:
                'preview_preload_${preloadKnowledge.semanticId ?? preloadKnowledge.contentId ?? controller.nextVideoPreloadIndex.value}',
            isActive: false,
            size: 1,
            autoPlayOnce: false,
            playbackRate: controller.playSpeed.value,
            videoController: controller.preloadVideoController,
          ),
        ),
      ),
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

  PronunciationsEntity? _getPronunciationModel(UnitKnowledgePointsEntityKnowledgeList knowledgeModel) {
    final List<PronunciationsEntity> pronunciations =
    (knowledgeModel.pronunciations ?? const []).whereType<PronunciationsEntity>().toList();
    for (final item in pronunciations) {
      if (item.national == controller.national.value.value) {
        return item;
      }
    }
    if (pronunciations.isNotEmpty) {
      return pronunciations.first;
    }
    return null;
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

  Widget _buildReplayButton(
      UnitKnowledgePointsEntityKnowledgeList knowledgeModel) {
    return Obx(() {
      final bool isActive = controller.isAudioPlaying.value &&
          controller.isCurrentKnowledge(knowledgeModel);
      return TapScaleWidget(
        onTap: () => controller.newAudioPlayer(knowledgeModel),
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
            isPlaying: isActive,
            size: 28.wMin,
          ),
        ),
      );
    });
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

  Widget _buildDifficultyLabel(UnitKnowledgePointsEntityKnowledgeList knowledgeModel) {
    if (knowledgeModel.difficulty == null) {
      return const SizedBox.shrink();
    }

    if (knowledgeModel.difficulty?.min == knowledgeModel.difficulty?.max) {
      return Positioned(
        top: 20.wMin,
        left: 20.wMin,
        child: StatusTagDifficultyWidget(
          difficulty: knowledgeModel.difficulty?.min,
          language: Get.find<ConfigController>().userSetting.value.learningLang,
          padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
          fontSize: 28.wMin,
        ),
      );
    }

    return Positioned(
      top: 20.wMin,
      left: 20.wMin,
      child: Row(
        children: [
          StatusTagDifficultyWidget(
            difficulty: knowledgeModel.difficulty?.min,
            language:
            Get.find<ConfigController>().userSetting.value.learningLang,
            padding:
            EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
            fontSize: 28.wMin,
          ),
          SizedBox(width: 5.wMin),
          Text(
            "-",
            style: TextStyle(
              fontSize: 18.wMin,
              color: const Color(0xff697179),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 5.wMin),
          StatusTagDifficultyWidget(
            difficulty: knowledgeModel.difficulty?.max,
            language:
            Get.find<ConfigController>().userSetting.value.learningLang,
            padding:
            EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
            fontSize: 28.wMin,
          ),
        ],
      ),
    );
  }

  // Widget buildPlaySettingWidget() {
  //   return Align(
  //     alignment: const Alignment(1, -0.5),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         TapScaleWidget(
  //           onTap: () {
  //             controller.playSetting();
  //           },
  //           sclae: 1.0,
  //           child: Container(
  //             height: 50.wMin,
  //             decoration: BoxDecoration(
  //               color: AppTheme.cMemberCardActiveBackground,
  //               borderRadius: BorderRadius.circular(25.wMin),
  //             ),
  //             padding: EdgeInsets.symmetric(horizontal: 25.wMin),
  //             child: Center(
  //               child: Obx(
  //                 () => RichText(
  //                   text: TextSpan(
  //                     children: [
  //                       TextSpan(
  //                         text: "${controller.playMode.value.value}  ",
  //                         style: TextStyle(
  //                           fontSize: 20.wMin,
  //                           color: AppTheme.cTextSecondary,
  //                           fontWeight: FontWeight.w400,
  //                         ),
  //                       ),
  //                       TextSpan(
  //                         text: "|",
  //                         style: TextStyle(
  //                           fontSize: 20.wMin,
  //                           color: AppTheme.cTextTertiary,
  //                           fontWeight: FontWeight.w400,
  //                         ),
  //                       ),
  //                       TextSpan(
  //                         text: "  循环${controller.playNum.value}次  ",
  //                         style: TextStyle(
  //                           fontSize: 20.wMin,
  //                           color: AppTheme.cTextSecondary,
  //                           fontWeight: FontWeight.w400,
  //                         ),
  //                       ),
  //                       TextSpan(
  //                         text: "|",
  //                         style: TextStyle(
  //                           fontSize: 20.wMin,
  //                           color: AppTheme.cTextTertiary,
  //                           fontWeight: FontWeight.w400,
  //                         ),
  //                       ),
  //                       TextSpan(
  //                         text: "  ${controller.playSpeed.value}x",
  //                         style: TextStyle(
  //                           fontSize: 20.wMin,
  //                           color: AppTheme.cTextSecondary,
  //                           fontWeight: FontWeight.w400,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //         SizedBox(width: 20.wMin),
  //       ],
  //     ),
  //   );
  // }

  Widget buildPlayWidget(BuildContext context) {
    return Obx(() {
      if (controller.knowledgeList.isEmpty) return const SizedBox.shrink();
      final int currentIndex = controller.progress.value;
      final int total = controller.knowledgeList.length;
      final int playNum = controller.playNum.value;
      final int activeIndicatorIndex = controller.currentPlayNum.value.clamp(
        0,
        playNum - 1,
      );

      return Column(
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
                            onTap: () => unawaited(controller.replayFromStart()),
                          ),
                          SizedBox(width: 12.wMin),
                          GuideStepWidget(
                            id: GuideWidgetIds.courseDetilsPreviewPreviewCompleteButton,
                            sclae: 1.02,
                            onTap: () async{
                              await controller.completePreview();
                            },
                            child: _buildActionButton(
                              text: '预习完成',
                              isPrimary: true,
                            ),
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
            '${currentIndex + 1} / $total',
            style: TextStyle(
              fontSize: (18 * _bottomSwitcherScale).wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (playNum > 1) ...[
            SizedBox(height: (10 * _bottomSwitcherScale).wMin),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(playNum, (index) {
                final bool isActive = index == activeIndicatorIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: (4 * _bottomSwitcherScale).wMin),
                  width: (8 * _bottomSwitcherScale).wMin,
                  height: (8 * _bottomSwitcherScale).wMin,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.cBgBrand.color
                        : AppTheme.cBorderSecondary.color,
                    borderRadius: BorderRadius.circular(999.wMin),
                  ),
                );
              }),
            ),
          ],
        ],
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
            onTap: controller.previousClick,
          ),
          SizedBox(width: (16 * _bottomSwitcherScale).wMin),
          _buildControlButton(
            icon: controller.playStatus.value
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            onTap: controller.audioPlayAndPause,
            isPrimary: true,
          ),
          SizedBox(width: (16 * _bottomSwitcherScale).wMin),
          _buildControlButton(
            icon: Icons.chevron_right_rounded,
            onTap: () => controller.nextClick(true),
          ),
        ],
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

  Widget _buildActionButton({
    required String text,
    VoidCallback? onTap,
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
            color: isPrimary ? AppTheme.cBorderBrand.color : AppTheme.cBorderBrand.color,
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
}
