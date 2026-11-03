import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/official_course_details/official_course_details_dictation/views/rhythm_filter_pop_btn.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
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
  final String tagText;
  const OfficialCourseDetailsPreviewView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      OfficialCourseDetailsPreviewView(tagText: tag),
      binding: OfficialCourseDetailsPreviewBinding(tagText: tag),
      routeName: Routes.OFFICIAL_COURSE_DETAILS_PREVIEW,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    double bottom = 24.wMin;
    double playerControllerHeight = 104.wMin;
    return Container(
      color: Colors.transparent,
      height: playerControllerHeight + bottom,
      margin: EdgeInsets.only(bottom: bottom),
      child: Obx((){
        return PlayerControllerWidget(
          playerConfig: PlayerControllerConfig(
            isPlaying: controller.playStatus.value,
            onPlayPause: (value) => controller.audioPlayAndPause(),
            isShowProgress: false,
            onPreviousNext: (direction) {
              if (direction == PlayerControllerDirection.previous) {
                controller.previousClick();
              } else {
                controller.nextClick(true);
              }
            },
          ),
          volumeConfig: PlayerControllerVolumeConfig(
            isShowVolume: true,
            volume: controller.volume.value,
            onVolumeChange: controller.onVolumeChange,
          ),
          speedMultiplierConfig: PlayerControllerSpeedMultiplierConfig(
            isShowSpeedMultiplier: true,
            speedMultiplier: controller.playSpeed.value,
            speedList: Get.find<ConfigController>().userSetting.value.expandAudioSpeedList,
            onSpeedMultiplierChange: controller.changePlaySpeed,
          ),
          modeConfig: PlayerControllerModeConfig(
            isShowMode: true,
            mode: controller.playMode.value,
            defaultModeList: [
              PlayerModeEnum.list,
              PlayerModeEnum.random,
              PlayerModeEnum.singleLoop,
            ],
            loopCount: controller.playNum.value,
            onModeChange: controller.changePlayMode,
            onLoopCountChange: controller.changePlayNum,
          ),
        );
      }),
    );

    

  }
}
