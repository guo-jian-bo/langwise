import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      if (controller.knowledgeList.isEmpty) return const SizedBox.shrink();
      final knowledgeModel = controller.knowledgeList[controller.progress.value];
      final pronunciationModel = _getPronunciationModel(knowledgeModel);
      final glossList = LearningLangUtils.getShowLBList(knowledgeModel.gloss ?? []);
      final bool isTextHidden = displayModeCode == LangPreference.none.code;

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: Container(
          key: ValueKey(
            '${controller.progress.value}_${pronunciationModel?.audioUrl}_$displayModeCode',
          ),
          width: 1540.wMin,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(Get.context!).size.width - 72.wMin,
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 20.wMin),
          child: Row(
            children: [
              Expanded(
                flex: 9,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28.wMin),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedImageWidget(
                          knowledgeModel.imageUrl ?? "",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorWidget: buildEmptyWidget(),
                          placeholder: buildEmptyWidget(),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.08),
                                Colors.black.withValues(alpha: 0.18),
                              ],
                            ),
                          ),
                        ),
                        _buildDifficultyLabel(knowledgeModel),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 44.wMin),
              Expanded(
                flex: 11,
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
                      if (!isTextHidden && glossList.isNotEmpty) ...[
                        SizedBox(height: 28.wMin),
                        ...List.generate(glossList.length, (index) {
                          final item = glossList[index];
                          final bool isFirstLine = index == 0;
                          return Padding(
                            padding: EdgeInsets.only(bottom: index == glossList.length - 1 ? 0 : 14.wMin),
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
          ),
        ),
      );
    });
  }

  Widget buildPlayProgressWidget() {
    return Obx(() {
      if (controller.knowledgeList.isEmpty) return const SizedBox.shrink();
      final currentIndex = controller.progress.value;
      final total = controller.knowledgeList.length;
      final double progress = total == 0 ? 0 : (currentIndex + 1) / total;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '第 ${currentIndex + 1} / $total 张',
            style: TextStyle(
              fontSize: 22.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.wMin),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.wMin),
            child: Container(
              width: 520.wMin,
              height: 8.wMin,
              color: AppTheme.cBorderPrimary.color,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cBgBrand.color,
                    borderRadius: BorderRadius.circular(999.wMin),
                  ),
                ),
              ),
            ),
          ),
          if (controller.playNum.value > 1) ...[
            SizedBox(height: 14.wMin),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(controller.playNum.value, (i) {
                final bool isActive = controller.currentPlayNum.value >= i;
                return Container(
                  margin: EdgeInsets.only(right: 8.wMin),
                  width: 8.wMin,
                  height: 8.wMin,
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.cBgBrand.color : AppTheme.cBorderSecondary.color,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        ],
      );
    });
  }

  PronunciationsEntity? _getPronunciationModel(UnitKnowledgePointsEntityKnowledgeList knowledgeModel) {
    for (final item in knowledgeModel.pronunciations ?? []) {
      if (item.national == controller.national.value.value) {
        return item;
      }
    }
    if ((knowledgeModel.pronunciations ?? []).isNotEmpty) {
      return knowledgeModel.pronunciations!.first;
    }
    return null;
  }

  Widget _buildReplayButton(UnitKnowledgePointsEntityKnowledgeList knowledgeModel) {
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
        child: Icon(
          Icons.volume_up_rounded,
          size: 28.wMin,
          color: AppTheme.cTextPrimary.color,
        ),
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
    return Obx(() {
      if (controller.knowledgeList.isEmpty) return const SizedBox.shrink();
      final int currentIndex = controller.progress.value;
      final int total = controller.knowledgeList.length;
      final List<int> visibleIndexes = _buildVisibleIndexes(currentIndex, total);

      return Column(
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
                  onTap: controller.previousClick,
                ),
                SizedBox(width: 16.wMin),
                _buildControlButton(
                  icon: controller.playStatus.value
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  onTap: controller.audioPlayAndPause,
                  isPrimary: true,
                ),
                SizedBox(width: 16.wMin),
                _buildControlButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: () => controller.nextClick(true),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.wMin),
          Text(
            '${currentIndex + 1} / $total',
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
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 4.wMin),
                width: 8.wMin,
                height: 8.wMin,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.cBgBrand.color
                      : AppTheme.cBorderSecondary.color,
                  borderRadius: BorderRadius.circular(999.wMin),
                ),
              );
            }).toList(),
          ),
        ],
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
