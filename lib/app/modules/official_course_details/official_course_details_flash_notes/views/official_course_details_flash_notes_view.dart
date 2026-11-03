import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../routes/routes.dart';
import '../bindings/official_course_details_flash_notes_binding.dart';
import '../controllers/official_course_details_flash_notes_controller.dart';
import 'official_course_details_flash_setting_dialog.dart';

class OfficialCourseDetailsFlashNotesView extends GetView<OfficialCourseDetailsFlashNotesController> {
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
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BreadcrumbWidget(
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
    );
  }

  Widget buildSettingEntryWidget() {
    return Obx(() {
      final summaryItems = [
        controller.currentPronunciationLabel,
        controller.currentTextDisplayLabel,
        controller.currentIntervalLabel,
        controller.currentShowTypeLabel,
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
        if (controller.knowledgeList.isEmpty) return const SizedBox.shrink();
        return NotificationListener<ScrollNotification>(
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
              return _buildFlashCardLayout(controller.knowledgeList[index]);
            },
            onPageChanged: (index) {
              controller.changeIndex(index);
            },
          ),
        );
      }),
    );
  }

  Widget _buildFlashCardLayout(UnitKnowledgePointsEntityKnowledgeList knowledgeModel) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 24.wMin),
      child: Obx(() {
        final bool isCovered = controller.cardIsFront.value;
        return SizedBox(
          width: 1040.wMin,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 520.wMin,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.wMin),
                    child: Stack(
                      children: [
                        CachedImageWidget(
                          knowledgeModel.imageUrl ?? "",
                          fit: BoxFit.fill,
                          width: double.infinity,
                          height: double.infinity,
                          fadeInDuration: Duration.zero,
                          errorWidget: buildEmptyWidget(),
                          placeholder: buildEmptyWidget(),
                        ),
                        _buildDifficultyLabel(knowledgeModel),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 48.wMin),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: isCovered
                      ? _buildCoveredPanel(knowledgeModel)
                      : _buildAnswerPanel(knowledgeModel),
                ),
              ),
            ],
          ),
        );
      }),
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
              previewText == null ? '先想一想，再解释答案' : '点击查看完整释义',
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
    final List<LanguageText> glossList = _resolveGlossList(knowledgeModel);
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
                _buildReplayButton(pronunciationModel?.audioUrl),
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
          if (glossList.isNotEmpty) ...[
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
              color: AppTheme.cTextLink.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 6.wMin),
          Icon(
            Icons.chevron_right_rounded,
            size: 22.wMin,
            color: AppTheme.cTextLink.color,
          ),
        ],
      ),
    );
  }

  Widget _buildReplayButton(String? audioUrl) {
    return TapScaleWidget(
      onTap: () async {
        controller.restartAutoNextTimer();
        if (audioUrl == null || audioUrl.isEmpty) return;
        await PlayAudioUtils.instance.playSingle(
          audioUrl,
          playbackRate: controller.playSpeed.value,
        );
      },
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
        child: Icon(
          Icons.volume_up_rounded,
          size: 28.wMin,
          color: AppTheme.cTextPrimary.color,
        ),
      ),
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
      final List<int> visibleIndexes = _buildVisibleIndexes(currentIndex, total);
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.wMin),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18.wMin, vertical: 14.wMin),
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
                        controller.previousCard();
                      }, 300),
                    ),
                    SizedBox(width: 16.wMin),
                    _buildControlButton(
                      icon: controller.isAutoPlay.value
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      onTap: controller.toggleAutoPlay,
                      isPrimary: true,
                    ),
                    SizedBox(width: 16.wMin),
                    _buildControlButton(
                      icon: Icons.chevron_right_rounded,
                      onTap: OptimizeUtils.noneThrottle(() {
                        controller.nextCard();
                      }, 300),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.wMin),
              Text(
                '${currentIndex + 1}/$total',
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10.wMin),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: visibleIndexes.map((index) {
                  final bool isActive = index == currentIndex;
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.wMin),
                    width: 8.wMin,
                    height: 8.wMin,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.cBgBrand.color
                          : AppTheme.cBorderSecondary.color,
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    });
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
        width: 52.wMin,
        height: 52.wMin,
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
          size: 30.wMin,
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
    final LanguageText? primaryGloss = LearningLangUtils.getShowLList(knowledgeModel.gloss ?? []);
    if (primaryGloss == null || (primaryGloss.text ?? '').isEmpty) {
      return const [];
    }
    final LanguageText? localGloss = LearningLangUtils.getLocalLang(knowledgeModel.gloss ?? []);
    if (localGloss == null ||
        (localGloss.text ?? '').isEmpty ||
        localGloss.text == primaryGloss.text) {
      return [primaryGloss];
    }
    return [primaryGloss, localGloss];
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

  List<int> _buildVisibleIndexes(int currentIndex, int total) {
    if (total <= 5) {
      return List<int>.generate(total, (index) => index);
    }
    if (currentIndex <= 1) {
      return [0, 1, 2, 3, 4];
    }
    if (currentIndex >= total - 2) {
      return List<int>.generate(5, (index) => total - 5 + index);
    }
    return List<int>.generate(5, (index) => currentIndex - 2 + index);
  }
}
