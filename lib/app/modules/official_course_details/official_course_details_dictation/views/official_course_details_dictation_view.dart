import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/official_course_details/official_course_details_dictation/views/language_filter_pop_btn.dart';
import 'package:langwise/app/modules/official_course_details/official_course_details_dictation/views/official_course_details_dictation_setting_dialog.dart';
import 'package:langwise/app/modules/official_course_details/official_course_details_dictation/views/rhythm_filter_pop_btn.dart';
import 'package:langwise/common/widgets/audio_control_widget.dart';
import 'package:langwise/common/widgets/listenwrite_audio_control_widget.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../controllers/official_course_details_dictation_controller.dart';

class OfficialCourseDetailsDictationView extends GetView<OfficialCourseDetailsDictationController> {
  const OfficialCourseDetailsDictationView({super.key});

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
              child: Stack(alignment: Alignment.center, children: [
                buildPlayProgressWidget(),
                const BackWidget(title: "听写模式"),
                Positioned(
                    right: 40.wMin,
                    child: Row(children: [
                      LanguageFilteringPopButton(),
                      SizedBox(width: 12.wMin),
                      RhythmFilterPopButton(
                          onChanged: (v) {
                            controller.pauseInterval.value = v;
                          },
                          value: controller.pauseInterval)
                    ]))
              ])),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    _buildContentTextWidget(),
                    SizedBox(height: 128.wMin),
                    Obx(() => controller.isDictationComplete.value
                        ? AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, -0.5),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: _buildCompleteButtonsWidget(),
                          )
                        : _buildPlayControlWidget()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildPlayWidget(context),
    );
  }

  Widget buildPlayProgressWidget() {
    return Obx(() {
      if (controller.knowledgeList.isEmpty) return const SizedBox();

      int allCount = controller.knowledgeList.length;
      int currentIndex = controller.progress.value;
      double progressPercent = (currentIndex + 1) / allCount * 100;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "第 ${controller.progress.value + 1} / ${controller.knowledgeList.length} 个",
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

  Widget buildPlaySettingWidget() {
    TextStyle borerStyle = TextStyle(
      fontSize: 24.wMin,
      color: AppTheme.cBorderTertiary.color,
      fontWeight: FontWeight.w400,
    );

    return TapScaleWidget(
      onTap: () {
        controller.playSetting();
      },
      sclae: 1.01,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceTertiary.color,
          borderRadius: BorderRadius.circular(999),
        ),
        padding: EdgeInsets.symmetric(horizontal: 25.wMin, vertical: 12.wMin),
        child: Obx(() {
          return RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w400,
              ),
              children: [
                TextSpan(text: "重复${controller.playNum.value}次"),
                TextSpan(text: "  |  ", style: borerStyle),
                TextSpan(text: "间隔${controller.pauseInterval.value}x"),
                TextSpan(text: "  |  ", style: borerStyle),
                TextSpan(text: "${controller.playMode.value.value}播放"),
                TextSpan(text: "  |  ", style: borerStyle),
                TextSpan(text: controller.national.value.text),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContentTextWidget() {
    return Obx(() {
      bool isComplete = controller.isDictationComplete.value;
      // isComplete = true;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.5),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Column(
          key: ValueKey(isComplete),
          spacing: 16.wMin,
          children: [
            Text(
              isComplete ? "太棒啦！已完成听写！" : "请认真听单词并书写",
              style: TextStyle(
                fontSize: 56.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              isComplete ? "恭喜完成，请认真核对" : "正在播放单词，请仔细听清楚",
              style: TextStyle(
                fontSize: 28.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 播放控制
  Widget _buildPlayControlWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceAround,
        //   children: [
        //     _buildSvgButtonWidget(
        //       svgPath: "assets/svg/public/icon_previous_track.svg",
        //       onTap: OptimizeUtils.noneThrottle(() {
        //         controller.preProgress();
        //       }, 300),
        //     ),
        //     TapScaleWidget(
        //       onTap: () {
        //         controller.audioPlayAndPause(!controller.playStatus.value);
        //       },
        //       sclae: 1.02,
        //       child: Container(
        //         width: 220.wMin,
        //         height: 220.wMin,
        //         alignment: Alignment.center,
        //         decoration: BoxDecoration(
        //           shape: BoxShape.circle,
        //           color: AppTheme.cSurfaceInfo.color,
        //         ),
        //         child: Obx((){
        //           return AnimatedSwitcher(
        //             duration: const Duration(milliseconds: 150),
        //             transitionBuilder: (child, animation) {
        //               return ScaleTransition(
        //                 scale: animation,
        //                 child: child,
        //               );
        //             },
        //             child: Icon(
        //               controller.playStatus.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
        //               color: Colors.white,
        //               size: 140.wMin,
        //               key: ValueKey(controller.playStatus.value),
        //             ),
        //           );
        //         }),
        //       ),
        //     ),
        //     _buildSvgButtonWidget(
        //       svgPath: "assets/svg/public/icon_next_track.svg",
        //       onTap: OptimizeUtils.noneThrottle(() {
        //         controller.nextProgress();
        //       }, 300),
        //     ),
        //   ],
        // ),
        // SizedBox(height: 56.wMin),
        TapScaleWidget(
          sclae: 1.03,
          onTap: OptimizeUtils.noneThrottle(() {
            controller.reListen();
          }, 300),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30.wMin),
            height: 100.wMin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: AppTheme.cTransparentBrand1.color,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8.wMin,
              children: [
                SvgPicture.asset(
                  "assets/svg/public/icon_refresh.svg",
                  width: 40.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextBrand.color, BlendMode.srcIn),
                ),
                Text(
                  "再听一次",
                  style: TextStyle(
                    fontSize: 36.wMin,
                    color: AppTheme.cTextBrand.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 按钮
  Widget buildSvgButtonWidget({
    required String svgPath,
    void Function()? onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.05,
      borderRadius: 999,
      backColor: AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
      child: Container(
        width: 120.wMin,
        height: 120.wMin,
        color: Colors.transparent,
        alignment: Alignment.center,
        child: SvgPicture.asset(
          svgPath,
          width: 70.wMin,
          colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildCompleteButtonsWidget() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ButtonWidget(
            text: "重新听写",
            width: 600.wMin,
            height: 100.wMin,
            borderRadius: 999,
            color: AppTheme.cTransparentBrand1.color,
            fontSize: 36.wMin,
            fontColor: AppTheme.cTextBrand.color,
            fontWeight: FontWeight.w600,
            sclae: 1.01,
            onTap: () {
              controller.redictation();
            },
          ),
          ButtonWidget(
            text: "核对答案",
            width: 600.wMin,
            height: 100.wMin,
            borderRadius: 999,
            color: AppTheme.cSurfaceInfo.color,
            fontSize: 36.wMin,
            fontColor: AppTheme.cInverseTextLight.color,
            fontWeight: FontWeight.w600,
            sclae: 1.01,
            onTap: () {
              controller.beginCheck();
            },
          ),
        ],
      ),
    );
  }

  Widget buildPlayWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16.wMin,
        left: 40.wMin,
        right: 40.wMin,
        bottom: MediaQuery.of(context).padding.bottom + 16.wMin,
      ),
      color: AppTheme.cSurfaceSecondary.color,
      child: Obx(() {
        return ListenwriteAudioControlWidget(
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
              controller.preProgress();
            } else {
              controller.nextProgress();
            }
          },
          listenPlayStatus: false,
          isPlaying: controller.playStatus.value,
          onPlayPauseChanged: () {
            controller.audioPlayAndPause(!controller.playStatus.value);
          },
          playOrderList: const [
            CourseDetailsDictationMode.order,
            CourseDetailsDictationMode.reverse,
            CourseDetailsDictationMode.random,
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

  Widget buildCompleteWidget() {
    return Container();
    // return Positioned(
    //   bottom: 40.wMin,
    //   left: 0,
    //   right: 0,
    //   child: Row(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //       TapScaleWidget(
    //         onTap: () {
    //           controller.beginCheck();
    //         },
    //         sclae: 1.0,
    //         child: buildButtonWidget(AppTheme.cBgBrand, "听写结束，开始核对", Colors.white),
    //       ),
    //     ],
    //   ),
    // );
  }
}
