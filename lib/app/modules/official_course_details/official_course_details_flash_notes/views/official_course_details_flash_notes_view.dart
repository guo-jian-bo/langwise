import 'package:auto_size_text/auto_size_text.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/official_course_details/official_course_details_dictation/views/rhythm_filter_pop_btn.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/learning_lang_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:video_player/video_player.dart';
import '../../../../../common/entities/entities.dart';
import '../../../../../common/stores/stores.dart';
import '../controllers/official_course_details_flash_notes_controller.dart';
import 'official_course_details_flash_setting_dialog.dart';
import 'flip_filter_pop_btn.dart';

class OfficialCourseDetailsFlashNotesView extends GetView<OfficialCourseDetailsFlashNotesController> {
  const OfficialCourseDetailsFlashNotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24.wMin,
              left: 40.wMin,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                buildPlayProgressWidget(),
                // buildResultWidget(),
                const BackWidget(title: "闪记模式"),
                Positioned(
                  right: 40.wMin,
                  child: Row(
                    spacing: 12.wMin,
                    children: [
                      FlipFilterPopButton(
                        value: controller.showType,
                        onChanged: (type) {
                          controller.showType.value = type;
                        },
                      ),
                      RhythmFilterPopButton(
                        onChanged: (v) {
                          controller.playInterval.value = v;
                        },
                        value: controller.playInterval,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildContentWidget(),
          ),
        ],
      ),
      bottomNavigationBar: buildPlayWidget(context),
    );
  }

  Widget buildResultWidget() {
    return Positioned(
      right: 50.wMin,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            spacing: 8.wMin,
            children: [
              SvgPicture.asset(
                "assets/svg/public/icon_warning_orange.svg",
                height: 32.wMin,
              ),
              Obx(() {
                return Text(
                  "待加强: ${controller.improvedKnowledgeIds.length}",
                  style: TextStyle(
                    color: AppTheme.cSurfaceWarning.color,
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w400,
                  ),
                );
              }),
            ],
          ),
          SizedBox(width: 56.wMin),
          Row(
            spacing: 8.wMin,
            children: [
              SvgPicture.asset(
                "assets/svg/public/icon_check_circle_green.svg",
                height: 32.wMin,
              ),
              Obx(() {
                return Text(
                  "已掌握: ${controller.masteredKnowledgeIds.length}",
                  style: TextStyle(
                    color: AppTheme.cFeedbackSuccessText.color,
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w400,
                  ),
                );
              }),
            ],
          ),
          SizedBox(width: 56.wMin),
          TapScaleWidget(
            onTap: () {
              controller.showSetting();
            },
            sclae: 1.1,
            child: Container(
              padding: EdgeInsets.all(16.wMin),
              color: Colors.transparent,
              child: SvgPicture.asset(
                "assets/svg/public/icon_setting1.svg",
                width: 32.wMin,
                height: 32.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPlayProgressWidget() {
    return Obx(() {
      if (controller.knowledgeList.isEmpty) return Container();
      int allCount = controller.knowledgeList.length;
      int currentIndex = controller.currentIndex.value;
      double progressPercent = (currentIndex + 1) / allCount * 100;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "第 ${currentIndex + 1} / $allCount 张",
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.wMin),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 640.wMin,
              height: 12.wMin,
              color: AppTheme.cBorderSecondary.color,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  AnimatedPositioned(
                    width: 640.wMin,
                    height: 12.wMin,
                    duration: const Duration(milliseconds: 300),
                    left: -(640.wMin - (640.wMin * progressPercent / 100)),
                    child: Container(
                      height: 12.wMin,
                      width: 640.wMin,
                      decoration: BoxDecoration(
                        color: AppTheme.cBgBrand,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildContentWidget() {
    return Obx(() {
      if (controller.knowledgeList.isEmpty) return Container();

      return Stack(
        alignment: Alignment.center,
        children: [
          NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // 用户开始用手拖动 PageView
                if (notification is ScrollStartNotification && notification.dragDetails != null) {
                  // 这里就可以认为发生了一次用户交互，重置计时器
                  controller.restartAutoNextTimer();
                }
                return false; // 继续向下分发通知
              },
              child: PageView.builder(
                clipBehavior: Clip.none,
                controller: controller.pageController,
                itemCount: controller.knowledgeList.length,
                itemBuilder: (ctx, index) {
                  return _buildCardWidget(controller.knowledgeList[index]);
                },
                onPageChanged: (index) {
                  controller.changeIndex(index);
                },
              )),

          // Positioned(
          //   left: 114.wMin,
          //   child: _buildArrowButtonWidget(
          //     iconPath: "assets/svg/public/icon_arrow_left_thin.svg",
          //     onTap: () {
          //       controller.previousCard();
          //     },
          //   ),
          // ),
          // Positioned(
          //   right: 114.wMin,
          //   child: _buildArrowButtonWidget(
          //     iconPath: "assets/svg/public/icon_arrow_right_thin.svg",
          //     onTap: () {
          //       controller.nextCard();
          //     },
          //   ),
          // ),
        ],
      );
    });
  }

  Widget buildArrowButtonWidget({
    required String iconPath,
    required void Function() onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.01,
      borderRadius: 999,
      backColor: AppTheme.cTextSecondary.color.withValues(alpha: 0.1),
      child: Container(
        width: 90.wMin,
        height: 90.wMin,
        alignment: Alignment.center,
        child: SvgPicture.asset(
          iconPath,
          height: 60.wMin,
          colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildCardWidget(UnitKnowledgePointsEntityKnowledgeList knowledgeModel) {
    return Center(
      child: SizedBox(
        width: 560.wMin,
        height: 750.wMin,
        child: FlipCard(
          direction: FlipDirection.HORIZONTAL,
          side: CardSide.BACK,
          front: _buildCardBackWidget(knowledgeModel),
          back: _buildCardFrontWidget(knowledgeModel),
          onFlip: () {
            controller.restartAutoNextTimer();
          },
          onFlipDone: (isFrontDone) {
            controller.cardIsFront.value = isFrontDone;
          },
        ),
      ),
    );
  }

  Widget _buildCardFrontWidget(UnitKnowledgePointsEntityKnowledgeList knowledgeModel) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.wMin),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cBlackAlpha10.color,
            offset: Offset(2.wMin, 4.wMin),
            blurRadius: 16,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.wMin),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceSecondary.color,
          ),
          child: Column(
            children: [
              _buildCardImageWidget(knowledgeModel, true),
              Expanded(
                child: _buildCardFrontContentWidget(
                  knowledgeModel: knowledgeModel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardBackWidget(UnitKnowledgePointsEntityKnowledgeList knowledgeModel) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.wMin),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cBlackAlpha10.color,
            offset: Offset(2.wMin, 4.wMin),
            blurRadius: 16,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.wMin),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceSecondary.color,
          ),
          child: Column(
            children: [
              _buildCardImageWidget(knowledgeModel, false),
              Expanded(
                child: _buildCardContentWidget(
                  knowledgeModel: knowledgeModel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardFrontContentWidget({
    required UnitKnowledgePointsEntityKnowledgeList knowledgeModel,
  }) {
    return Container(
      margin: EdgeInsets.all(16.wMin),
      alignment: Alignment.center,
      child: Obx(() {
        if (controller.showType.value == FlashSettingCardShowType.image) {
          return Container();
        } else if (controller.showType.value == FlashSettingCardShowType.imageAndLearText) {
          return AutoSizeText(
            knowledgeModel.content ?? "",
            maxLines: 4,
            minFontSize: 10,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 48.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          );
        }

        LanguageText? gloss = LearningLangUtils.getLocalLang(knowledgeModel.gloss ?? []);

        return AutoSizeText(
          gloss?.text ?? "",
          textAlign: TextAlign.center,
          maxLines: 4,
          minFontSize: 10,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 46.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary,
            letterSpacing: 0.072,
          ),
        );
      }),
    );
  }

  Widget _buildCardContentWidget({
    required UnitKnowledgePointsEntityKnowledgeList knowledgeModel,
  }) {
    String? national = UserStore.to.userInfo.value.config?.national;

    PronunciationsEntity? pronunciationModel;
    for (var item in knowledgeModel.pronunciations ?? []) {
      if (item.national == national) {
        pronunciationModel = item;
        break;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8.wMin,
        children: [
          AutoSizeText(
            knowledgeModel.content ?? "",
            maxLines: knowledgeModel.isWord || knowledgeModel.isPhrase ? 1 : 2,
            minFontSize: 10,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 48.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          Visibility(
            visible: knowledgeModel.isWord,
            child: Text(
              '/${pronunciationModel?.phonetic ?? ""}/',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28.wMin,
                color: AppTheme.cTextTertiary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Obx(() {
            LanguageText? gloss = LearningLangUtils.getShowLList(knowledgeModel.gloss ?? []);
            if (gloss == null) return Container();
            return AutoSizeText(
              gloss.text ?? '',
              textAlign: TextAlign.center,
              maxLines: 2,
              minFontSize: 10,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 28.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextPrimary,
                letterSpacing: 0.072,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCardImageWidget(UnitKnowledgePointsEntityKnowledgeList knowledgeModel, bool isFront) {
    return AspectRatio(
      aspectRatio: 1,
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
          Visibility(
            visible: (knowledgeModel.pronunciations?.isNotEmpty ?? false) && !isFront,
            child: Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(knowledgeModel.pronunciations?.length ?? 0, (index) {
                  return Obx(()=>PlayLottieIconWidget(
                    size: 56.wMin,
                    audioUrl: knowledgeModel.pronunciations?[index]?.audioUrl,
                    backgroundImageUrl: knowledgeModel.pronunciations?[index]?.nationalIconUrl,
                    playSpeed: controller.playSpeed.value,
                    onTap: () {
                      controller.restartAutoNextTimer();
                    },
                  ));
                }),
              ),
            ),
          ),
          Visibility(
            visible: isFront,
            child: Positioned(
              top: 18.wMin,
              right: 18.wMin,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.wMin),
                  color: AppTheme.cInverseOverlay.color,
                ),
                child: Text(
                  "点击翻转",
                  style: TextStyle(
                    color: AppTheme.cInverseTextLight.color,
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
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

    double bottom = 24.wMin;
    double playerControllerHeight = 104.wMin;
    return Container(
      color: Colors.transparent,
      height: playerControllerHeight + bottom,
      margin: EdgeInsets.only(bottom: bottom),
      child: Obx((){
        return PlayerControllerWidget(
          playerConfig: PlayerControllerConfig(
            isPlaying: controller.isAutoPlay.value,
            onPlayPause: (value) => controller.toggleAutoPlay(),
            isShowProgress: false,
            onPreviousNext: (direction) {
              if (direction == PlayerControllerDirection.previous) {
                controller.previousCard();
              } else {
                controller.nextCard();
              }
            },
          ),
          speedMultiplierConfig: PlayerControllerSpeedMultiplierConfig(
            isShowSpeedMultiplier: true,
            speedMultiplier: controller.playSpeed.value,
            speedList: Get.find<ConfigController>().userSetting.value.expandAudioSpeedList,
            onSpeedMultiplierChange: controller.changePlaySpeed,
          ),
        );
      }),
    );
  }

  Widget buildCompleteWidget(BuildContext context) {
    return Obx(() {
      return AnimatedOpacity(
        opacity: controller.cardIsFront.value ? 0 : 1,
        duration: const Duration(milliseconds: 200),
        child: IgnorePointer(
          ignoring: controller.cardIsFront.value,
          child: Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 24.wMin,
            ),
            padding: EdgeInsets.symmetric(horizontal: 100.wMin),
            child: Row(
              spacing: 65.wMin,
              children: [
                Expanded(
                  child: ButtonWidget(
                    text: "待加强",
                    height: 80.wMin,
                    borderRadius: 999,
                    color: AppTheme.cSurfaceWarning.color,
                    fontSize: 28.wMin,
                    fontColor: AppTheme.cInverseTextLight.color,
                    fontWeight: FontWeight.w500,
                    sclae: 1.01,
                    onTap: () {
                      controller.improvedClick();
                    },
                  ),
                ),
                Expanded(
                  child: ButtonWidget(
                    text: "已掌握",
                    height: 80.wMin,
                    borderRadius: 999,
                    color: AppTheme.cSurfaceSuccess.color,
                    fontSize: 28.wMin,
                    fontColor: AppTheme.cInverseTextLight.color,
                    fontWeight: FontWeight.w500,
                    sclae: 1.01,
                    onTap: () {
                      controller.masteredClick();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
