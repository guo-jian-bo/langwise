import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/official_course_details/official_course_details_dictation/views/rhythm_filter_pop_btn.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/widgets/audio_control_widget.dart';
import 'package:langwise/common/widgets/back_widget.dart';
import 'package:langwise/common/widgets/build_image.dart';
import 'package:langwise/common/widgets/status_tag_widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/learning_lang_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../controllers/official_course_details_preview_controller.dart';

class OfficialCourseDetailsPreviewView extends GetView<OfficialCourseDetailsPreviewController> {
  const OfficialCourseDetailsPreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.audioControlController.hideAllMenus();
      },
      child: Scaffold(
        backgroundColor: AppTheme.cBgPrimary.color,
        extendBody: true,
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
                  const BackWidget(title: "预习模式"),
                  Positioned(right:40.wMin,child: RhythmFilterPopButton(onChanged: (v){
                    controller.playInterval.value = v;
                  },value: controller.playInterval))
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: buildCardWidget(),
              ),
            ),
            SizedBox(height: 100.wMin + MediaQuery.of(context).padding.bottom),
          ],
        ),
        bottomNavigationBar: buildPlayWidget(context),
      ),
    );
  }

  Widget buildPlayProgressWidget() {
    return Obx((){

      if(controller.knowledgeList.isEmpty) return Container();
      int allCount = controller.knowledgeList.length;
      int currentIndex = controller.progress.value;
      double progressPercent = (currentIndex + 1) / allCount * 100;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "第 ${controller.progress.value + 1} / ${controller.knowledgeList.length} 张",
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
          SizedBox(height: 8.wMin),
          Visibility(
            visible: controller.playNum.value > 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8.wMin,
              children: List.generate(controller.playNum.value, (i) {
                return Container(
                  width: 8.wMin,
                  height: 8.wMin,
                  decoration: BoxDecoration(
                    color: controller.currentPlayNum.value >= i ? AppTheme.cBgBrand : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          )
        ],
      );
    });
  }

  Widget buildCardWidget() {
    return Obx((){
      if(controller.knowledgeList.isEmpty) return Container();
      UnitKnowledgePointsEntityKnowledgeList knowledgeModel = controller.knowledgeList[controller.progress.value];

      PronunciationsEntity? pronunciationModel;
      for (var item in knowledgeModel.pronunciations ?? []) {
        if (item.national == controller.national) {
          pronunciationModel = item;
          break;
        }
      }

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: SizedBox(
          key: ValueKey(pronunciationModel?.audioUrl),
          width: 560.wMin,
          height: 820.wMin,
          child: Card(
            color: AppTheme.cSurfaceSecondary.color,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.wMin),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      CachedImageWidget(
                        knowledgeModel.imageUrl??"",
                        fit: BoxFit.fill,
                        width: double.infinity,
                        height: double.infinity,
                        errorWidget: buildEmptyWidget(),
                        placeholder: buildEmptyWidget(),
                      ),
                      _buildDifficultyLabel(knowledgeModel),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 8.wMin,
                      children: [
                        AutoSizeText(
                          knowledgeModel.content ?? "",
                          maxLines: 2,
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
                            gloss.text??"",
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
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
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
            language: Get.find<ConfigController>().userSetting.value.learningLang,
            padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
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
            language: Get.find<ConfigController>().userSetting.value.learningLang,
            padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 2.wMin),
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

    return Container(
      padding: EdgeInsets.only(
        top: 16.wMin,
        left: 40.wMin,
        right: 40.wMin,
        bottom: MediaQuery.of(context).padding.bottom + 16.wMin,
      ),
      color: AppTheme.cSurfaceSecondary.color,
      child: Obx((){
        if(!controller.isReady.value) return Container(height: 0);
        return AudioControlWidget(
          audioPlayerUtils: controller.audioPlaybackUtils,
          controller: controller.audioControlController,
          showProgressBar: false,
          showAudioListButton: false,
          showFontSizeButton: false,
          showPlayOrderButton: true,
          showPreviousNextTrackButton: true,
          showSeekButton: false,
          showSentenceSentenceutton: false,
          showSpeedButton: true,
          showTranslateButton: false,
          onPreviousNextTrackChanged: (type) {
            if (type == AudioControlPreviousNext.previous) {
              controller.previousClick();
            } else {
              controller.nextClick(true);
            }
          },
          listenPlayStatus: false,
          isPlaying: controller.playStatus.value,
          onPlayPauseChanged: () {
            controller.audioPlayAndPause();
          },
          playOrderList: const [
            AudioControlPlayOrder.loop,
            AudioControlPlayOrder.sequential,
            AudioControlPlayOrder.random,
            AudioControlPlayOrder.singleLoop,
          ],
          playOrderValue: controller.playMode.value,
          onPlayOrderChanged: (order) {
            controller.changePlayMode(order);
          },
          playOrderLoopCount: controller.playNum.value,
          onPlayOrderLoopCountChanged: (loopCount) {
            controller.changePlayNum(loopCount);
          },
          initSpeed: controller.playSpeed.value,
          onSpeedChanged: (speed) {
            controller.changePlaySpeed(speed);
          },
        );
      }),
    );

  }
}
