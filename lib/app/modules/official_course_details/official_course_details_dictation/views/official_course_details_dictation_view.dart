import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../routes/routes.dart';
import '../bindings/official_course_details_dictation_binding.dart';
import '../controllers/official_course_details_dictation_controller.dart';

class OfficialCourseDetailsDictationView extends GetView<OfficialCourseDetailsDictationController> {
  static const double _bottomSwitcherScale = 1.5;
  final String tagText;
  const OfficialCourseDetailsDictationView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
          () => OfficialCourseDetailsDictationView(tagText: tag),
      binding: OfficialCourseDetailsDictationBinding(tagText: tag),
      routeName: Routes.OFFICIAL_COURSE_DETAILS_DICTATION,
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
                child: buildCenterPanel(),
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
        controller.currentPauseLabel,
        controller.currentPlayModeLabel,
        controller.currentRepeatLabel,
        controller.currentSpeedLabel,
      ];
      return TapScaleWidget(
        onTap: controller.playSetting,
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

  Widget buildCenterPanel() {
    return Center(
      child: Obx(() {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Container(
            key: ValueKey('${controller.isDictationComplete.value}_${controller.progress.value}'),
            width: 900.wMin,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(Get.context!).size.width - 120.wMin,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildContentTextWidget(),
                SizedBox(height: 40.wMin),
                controller.isDictationComplete.value
                    ? _buildCompleteButtonsWidget()
                    : _buildStatusButtonsWidget(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildContentTextWidget() {
    return Obx(() {
      bool isComplete = controller.isDictationComplete.value;
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
          children: [
            Text(
              isComplete ? "太棒啦！已完成听写！" : "请认真听并书写",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 72.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 18.wMin),
            Text(
              isComplete ? "恭喜完成，请认真核对答案" : "根据听到的内容完成听写",
              textAlign: TextAlign.center,
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

  Widget _buildStatusButtonsWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatusChip(
          text: '正在听写',
          backgroundColor: AppTheme.cSurfaceTertiary.color,
          textColor: AppTheme.cTextPrimary.color,
        ),
        SizedBox(width: 16.wMin),
        _buildStatusChip(
          text: '重复听',
          backgroundColor: const Color(0xFF4D2400),
          textColor: const Color(0xFFFF9B4A),
          onTap: OptimizeUtils.noneThrottle(() {
            controller.reListen();
          }, 300),
        ),
      ],
    );
  }

  Widget _buildStatusChip({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.02,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 28.wMin, vertical: 16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999.wMin),
          color: backgroundColor,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 28.wMin,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteButtonsWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ButtonWidget(
          text: "重新听写",
          width: 220.wMin,
          height: 84.wMin,
          borderRadius: 999,
          color: AppTheme.cSurfaceTertiary.color,
          fontSize: 30.wMin,
          fontColor: AppTheme.cTextPrimary.color,
          fontWeight: FontWeight.w600,
          sclae: 1.01,
          onTap: controller.redictation,
        ),
        SizedBox(width: 20.wMin),
        ButtonWidget(
          text: "核对答案",
          width: 220.wMin,
          height: 84.wMin,
          borderRadius: 999,
          color: AppTheme.cSurfaceInfo.color,
          fontSize: 30.wMin,
          fontColor: AppTheme.cInverseTextLight.color,
          fontWeight: FontWeight.w600,
          sclae: 1.01,
          onTap: controller.beginCheck,
        ),
      ],
    );
  }

  Widget buildPlayWidget(BuildContext context) {
    return Obx(() {
      if (controller.isDictationComplete.value || controller.knowledgeList.isEmpty) {
        return const SizedBox.shrink();
      }
      final int currentIndex = controller.progress.value;
      final int total = controller.knowledgeList.length;
      final int playNum = controller.playNum.value;
      final int activeIndicatorIndex = controller.currentPlayNum.value.clamp(
        0,
        playNum - 1,
      );
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.wMin),
        child: SizedBox(
          width: double.infinity,
          height: (176 * _bottomSwitcherScale).wMin,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
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
                              controller.preProgress();
                            }, 300),
                          ),
                          SizedBox(width: (16 * _bottomSwitcherScale).wMin),
                          _buildControlButton(
                            icon: controller.playStatus.value
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            onTap: () => controller.audioPlayAndPause(!controller.playStatus.value),
                            isPrimary: true,
                          ),
                          SizedBox(width: (16 * _bottomSwitcherScale).wMin),
                          _buildControlButton(
                            icon: Icons.chevron_right_rounded,
                            onTap: OptimizeUtils.noneThrottle(() {
                              controller.nextProgress();
                            }, 300),
                          ),
                        ],
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
                    if (playNum > 1) ...[
                      SizedBox(height: (10 * _bottomSwitcherScale).wMin),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(playNum, (index) {
                          final bool isActive = index == activeIndicatorIndex;
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: (4 * _bottomSwitcherScale).wMin),
                            width: (8 * _bottomSwitcherScale).wMin,
                            height: (8 * _bottomSwitcherScale).wMin,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppTheme.cBgBrand.color
                                  : AppTheme.cBorderSecondary.color,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: ButtonWidget(
                  text: "写完下一题",
                  width: 180.wMin,
                  height: 72.wMin,
                  borderRadius: 999,
                  color: const Color(0xFFFF7A00),
                  fontSize: 28.wMin,
                  fontColor: AppTheme.cInverseTextLight.color,
                  fontWeight: FontWeight.w600,
                  sclae: 1.01,
                  onTap: OptimizeUtils.noneThrottle(() {
                    controller.nextProgress();
                  }, 300),
                ),
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
}
