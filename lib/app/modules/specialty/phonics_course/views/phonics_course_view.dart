import 'package:bubble_box/bubble_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/values/values.dart';
import '../../../../../common/widgets/custom_button/LWCircularButton.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../elements/common/elements_card_body_widget.dart';
import '../../../elements/common/elements_public_widgets.dart';
import '../../../../routes/routes.dart';
import '../bindings/phonics_course_binding.dart';
import '../common/phonics_course_image_widget.dart';
import '../controllers/phonics_course_controller.dart';

class PhonicsCourseView extends GetView<PhonicsCourseController> {
  static const Color _phonicsAccentColor = AppTheme.cPhonics;
  static const double _horizontalContentPadding = 90;
  final String? controllerTag;
  final bool showBackButton;
  final bool showBreadcrumb;
  final String tagText;

  const PhonicsCourseView({
    super.key,
    this.tagText = '',
    this.controllerTag,
    this.showBackButton = true,
    this.showBreadcrumb = false,
  });

  @override
  String? get tag => controllerTag ?? (tagText.isEmpty ? null : tagText);

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    final bool asPrimaryPage =
        arguments is Map<String, dynamic> && arguments['asPrimaryPage'] == true;
    return await Get.to<T>(
      () => PhonicsCourseView(
        tagText: tag,
        showBackButton: !asPrimaryPage,
        showBreadcrumb: asPrimaryPage,
      ),
      binding: PhonicsCourseBinding(tagText: tag),
      routeName: Routes.PHONICS_COURSE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Column(
        children: [
          BreadcrumbWidget(actionWidget: const SizedBox.shrink()),
          Expanded(
            child: ClipRRect(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(40.wMin)),
              child: Obx(() {
                final bool hasLock =
                    controller.courseData.value.rights?.isLock == true ||
                    controller.courseData.value.rights?.isNoRights == true;
                return LockOverlayWidget(
                  rights: controller.courseData.value.rights,
                  showBack: false,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      _buildListWidget(context),
                      Positioned(
                        left: _horizontalContentPadding.wMin,
                        right: _horizontalContentPadding.wMin,
                        bottom: MediaQuery.of(context).padding.bottom + 20.wMin,
                        child: IgnorePointer(
                          ignoring: hasLock,
                          child: _buildFloatingBottomActions(context),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRandomWordButton() {
    if (controller.createStudyPlan) {
      return const SizedBox.shrink();
    }
    return TapScaleWidget(
      sclae: 1.02,
      onTap: () {
        controller.getLevelDatas();
      },
      child: Container(
        height: 56.wMin,
        padding: EdgeInsets.symmetric(horizontal: 20.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999.wMin),
          color: _phonicsAccentColor.withValues(alpha: 0.12),
          border: Border.all(
            color: _phonicsAccentColor.withValues(alpha: 0.2),
            width: 1.wMin,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          "随机示例单词",
          style: TextStyle(
            color: _phonicsAccentColor,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBottomActions(BuildContext context) {
    return Obx(() {
      if (controller.levelDatas.isEmpty) {
        return const SizedBox.shrink();
      }
      final bool showRandomButton = !controller.createStudyPlan;
      return Row(
        children: [
          Expanded(
            child: _buildFloatingBottomBar(context),
          ),
          if (showRandomButton) ...[
            SizedBox(width: 16.wMin),
            _buildRandomWordButton(),
          ],
        ],
      );
    });
  }

  Widget _buildFloatingBottomBar(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999.wMin),
      child: PlatformBackdropFilterWidget(
        sigmaX: 4.wMin,
        sigmaY: 4.wMin,
        child: Container(
          height: 80.wMin,
          padding: EdgeInsets.symmetric(horizontal: 12.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceSearchBackground.color,
            borderRadius: BorderRadius.circular(999.wMin),
            border: Border.all(
              color: AppTheme.cBorderDark.color,
              width: 1.wMin,
            ),
          ),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              key: controller.levelTabViewportKey,
              controller: controller.levelTabScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(controller.levelDatas.length, (index) {
                  final PhonicsCourseLevelList levelData =
                      controller.levelDatas[index];
                  final int levelId = controller.levelIdentityAt(index);
                  final String compactTitle = _compactTabTitle(levelData.name);
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == controller.levelDatas.length - 1
                          ? 0
                          : 12.wMin,
                    ),
                    child: LWCircularButtonWidget(
                      key: controller.getLevelTabKey(levelId),
                      text: compactTitle.isNotEmpty
                          ? compactTitle
                          : "Level ${index + 1}",
                      isAction: controller.activeLevelId.value == levelId,
                      color: _phonicsAccentColor,
                      onTap: () {
                        controller.scrollToLevel(levelId);
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _compactTabTitle(String? name) {
    final String raw = (name ?? '').trim();
    if (raw.isEmpty) return '';
    final int zhParenIndex = raw.indexOf('（');
    final int enParenIndex = raw.indexOf('(');
    int cutIndex = -1;
    if (zhParenIndex >= 0 && enParenIndex >= 0) {
      cutIndex = zhParenIndex < enParenIndex ? zhParenIndex : enParenIndex;
    } else if (zhParenIndex >= 0) {
      cutIndex = zhParenIndex;
    } else if (enParenIndex >= 0) {
      cutIndex = enParenIndex;
    }
    if (cutIndex <= 0) return raw;
    final String compact = raw.substring(0, cutIndex).trim();
    return compact.isEmpty ? raw : compact;
  }

  Widget _buildListWidget(BuildContext context) {
    final double lastBottomPadding =
        MediaQuery.of(context).padding.bottom + 180.wMin;

    return Obx(() {
      final List<Widget> slivers = <Widget>[];
      for (int index = 0; index < controller.levelDatas.length; index++) {
        final List<PhonicsCourseLevelListModuleList?> moduleList =
            controller.levelDatas[index].moduleList ?? [];
        slivers.add(
          SliverToBoxAdapter(
            child: _buildTitleWidget(controller.levelDatas[index], index),
          ),
        );
        slivers.add(
          SliverPadding(
            padding: EdgeInsets.only(
              left: _horizontalContentPadding.wMin,
              right: _horizontalContentPadding.wMin,
              bottom: index == controller.levelDatas.length - 1
                  ? lastBottomPadding
                  : 56.wMin,
              top: 12.wMin,
            ),
            sliver: SliverGrid.builder(
              itemCount: moduleList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 24.wMin,
                crossAxisSpacing: 24.wMin,
                childAspectRatio: 346 / 570,
              ),
              itemBuilder: (context, itemIndex) {
                return SizedBox(
                  key: index == 0 && itemIndex == 0
                      ? controller.firstModuleKey
                      : null,
                  child: _buildItemWidget(
                    context,
                    controller.levelDatas[index],
                    moduleList[itemIndex],
                  ),
                );
              },
            ),
          ),
        );
      }
      return CustomScrollView(
        controller: controller.scrollController,
        slivers: slivers,
      );
    });
  }

  Widget _buildTitleWidget(
    PhonicsCourseLevelList levelData,
    int levelIndex,
  ) {
    return Container(
      key: controller.getLevelHeaderKey(controller.levelIdentityAt(levelIndex)),
      height: 90.wMin,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(
        left: _horizontalContentPadding.wMin,
        right: _horizontalContentPadding.wMin,
        top: 10.wMin,
        bottom: 10.wMin,
      ),
      color: AppTheme.cBgPrimary,
      child: Text(
        levelData.name ?? "",
        style: TextStyle(
          fontSize: 40.wMin,
          color: AppTheme.cTextPrimary.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildItemWidget(
    BuildContext context,
    PhonicsCourseLevelList levelData,
    PhonicsCourseLevelListModuleList? moduleData,
  ) {
    final List<PronunciationsEntity?> pronunciations =
        moduleData?.contentInfo?.pronunciations ?? [];
    final bool isCurrent =
        moduleData?.current == true && controller.isSelectThisModule;
    return TapScaleWidget(
      onTap: () {
        controller.toModulePage(context, levelData, moduleData);
      },
      sclae: 1.00,
      child: Container(
        clipBehavior: Clip.none,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.wMin),
          border: Border.all(
            color: AppTheme.cBorderSecondary.color,
            width: 2.wMin,
          ),
          color: AppTheme.cBgSecondary.color,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 8.wMin,
            right: 8.wMin,
            top: 8.wMin,
            bottom: 10.wMin,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildItemCoverWidget(moduleData),
                  SizedBox(height: 6.wMin),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(top: 6.wMin,bottom: 6.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.wMin),
                        color: AppTheme.cBgTertiary.color,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                         PronunciationsPlayIpaTextWidget(
                                  ipa: moduleData?.topic,
                                  pronunciations: pronunciations,
                                  national: LanguageServiceCode.US,
                                  style: TextStyle(
                                    fontSize: 48.wMin,
                                    color: _phonicsAccentColor,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "AndikaRegular",
                                  ),
                                ),
                 
                          _buildKnowledgeColorWidget(
                            moduleData,
                            showArrow: false,
                            style: TextStyle(
                              fontSize: 36.wMin,
                              color: AppTheme.cTextPrimary.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                 
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: controller.createStudyPlan
                                    ? const SizedBox.shrink()
                                    : _buildPronunciationRow(pronunciations),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildDetailAction(
                      onTap: () {
                        controller.toModulePage(
                          context,
                          levelData,
                          moduleData,
                        );
                      },
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: isCurrent,
                child: Positioned(
                  bottom: -34.wMin,
                  child: SizedBox(
                    width: 152.wMin,
                    height: 60.wMin,
                    child: BubbleBox(
                      backgroundColor: const Color(0xFFB06CFF),
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.all(2.wMin),
                      shape: BubbleShapeBorder(
                        direction: BubbleDirection.top,
                        arrowQuadraticBezierLength: 4,
                        radius: BorderRadius.circular(14.wMin),
                        arrowHeight: 10.wMin,
                        arrowAngle: 10.wMin,
                        smooth: 0,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF121212),
                          borderRadius: BorderRadius.circular(12.wMin),
                        ),
                        child: Text(
                          "当前位置",
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: const Color(0xFFC084FF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCoverWidget(PhonicsCourseLevelListModuleList? moduleData) {
    final ElementsCardEntityDataVideo? video = moduleData?.contentInfo?.video;
    final bool hasVideo = (video?.videoUrl ?? '').trim().isNotEmpty;
    final String fallbackImagePath =
        moduleData?.coverUrl ?? moduleData?.contentInfo?.imageUrl ?? "";
    final String coverImagePath = hasVideo
        ? ((video?.firstFrameUrl ?? '').trim().isNotEmpty
            ? (video?.firstFrameUrl ?? '')
            : fallbackImagePath)
        : fallbackImagePath;
    return AspectRatio(
      aspectRatio: 1,
      child: ElementsCardBodyWidget(
        child: hasVideo
            ? TapScaleWidget(
                sclae: 1,
                onTap: () async {
                  final BuildContext? ctx = Get.context;
                  if (ctx == null) return;
                  final PhonicsCourseLevelListModuleListContentInfo? contentInfo =
                      moduleData?.contentInfo;
                  final ElementsCardEntityDataVideo? relationVideo =
                      contentInfo?.video;
                  if (contentInfo == null) return;
                  if (relationVideo == null) return;
                  if ((relationVideo.videoUrl ?? '').trim().isEmpty) return;
                  await ShowBigResourceDialog.showVideo(
                    context: ctx,
                    relationVideo: EnKnowledgeEntityRelationVideo(
                      uid: relationVideo.videoId,
                      videoId: relationVideo.videoId,
                      type: contentInfo.contentType,
                      contentId: contentInfo.contentId,
                      semanticId: contentInfo.semanticId,
                      videoUrl: relationVideo.videoUrl,
                      videoKey: relationVideo.videoKey,
                      duration: relationVideo.duration,
                      startSeconds: relationVideo.startSeconds,
                      endSeconds: relationVideo.endSeconds,
                      firstImageUrl: relationVideo.firstFrameUrl,
                      firstFrameUrl: relationVideo.firstFrameUrl,
                      firstFrameKey: relationVideo.firstFrameKey,
                      firstFrameMd5: relationVideo.firstFrameMd5,
                      ass: relationVideo.ass,
                      translateAss: relationVideo.translateAss,
                      translate: relationVideo.translateAss,
                      isMute: relationVideo.isMute,
                    ),
                    isLearn: true,
                  );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PhonicsCourseImageWidget(
                      imagePath: coverImagePath,
                      child: const SizedBox.shrink(),
                    ),
                    Center(
                      child: ClipOval(
                        child: Container(
                          width: 80.wMin,
                          height: 80.wMin,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.cInverseTextLight
                                .withValues(alpha: 0.03),
                            border: Border.all(
                              color: AppTheme.cInverseTextLight
                                  .withValues(alpha: 0.4),
                              width: 1.wMin,
                            ),
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: AppTheme.cInverseTextLight,
                            size: 50.wMin,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : PhonicsCourseImageWidget(
                imagePath: coverImagePath,
                child: const SizedBox.shrink(),
              ),
      ),
    );
  }

  Widget _buildPronunciationRow(List<PronunciationsEntity?> pronunciations) {
    final List<PronunciationsEntity> validPronunciations =
        pronunciations.whereType<PronunciationsEntity>().toList();
    if (validPronunciations.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 50.wMin,
      runSpacing: 8.wMin,
      children: List.generate(validPronunciations.length, (index) {
        final PronunciationsEntity item = validPronunciations[index];
        return _PhonicsPronunciationButton(
          label: _resolvePronunciationLabel(item),
          phonetic: item.phonetic,
          audioUrl: item.audioUrl,
        );
      }),
    );
  }

  String _resolvePronunciationLabel(PronunciationsEntity item) {
    final String national = (item.national ?? "").trim().toUpperCase();
    if (national.isNotEmpty) return national;
    return (item.nationalTitle ?? "").contains("英") ? "UK" : "US";
  }

  Widget _buildKnowledgeColorWidget(
    PhonicsCourseLevelListModuleList? moduleData, {
    required bool showArrow,
    required TextStyle style,
  }) {
    final String? topic = moduleData?.topic;
    final String? content = moduleData?.contentInfo?.content;
    final List<PronunciationsEntity?> pronunciations =
        moduleData?.contentInfo?.pronunciations ?? [];

    return PronunciationsColorWidget(
      content: content,
      ipa: topic,
      pronunciations: pronunciations,
      national: LanguageServiceCode.US,
      showArrow: showArrow,
      style: style,
      highlightColor: _phonicsAccentColor,
    );
  }

  Widget _buildDetailAction({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(top: 6.wMax),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "查看详情",
                style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextPrimary.color.withValues(alpha: 0.8),
                  ),
            ),
            SizedBox(width: 4.wMin),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.wMin,
              color: AppTheme.cTextPrimary.color.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhonicsPronunciationButton extends StatefulWidget {
  final String label;
  final String? phonetic;
  final String? audioUrl;

  const _PhonicsPronunciationButton({
    required this.label,
    this.phonetic,
    this.audioUrl,
  });

  @override
  State<_PhonicsPronunciationButton> createState() =>
      _PhonicsPronunciationButtonState();
}

class _PhonicsPronunciationButtonState
    extends State<_PhonicsPronunciationButton> {
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return ElementsPronunciationCapsuleButton(
      label: widget.label,
      phonetic: widget.phonetic,
      isPlaying: isPlaying,
      onTap: () async {
        if ((widget.audioUrl ?? "").isEmpty) return;
        try {
          setState(() {
            isPlaying = true;
          });
          await PlayAudioUtils.instance.playSingle(widget.audioUrl);
        } finally {
          if (mounted) {
            setState(() {
              isPlaying = false;
            });
          }
        }
      },
    );
  }
}
