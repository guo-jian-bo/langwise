import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/guide_engine/guide_engine.dart';
import 'package:langwise/common/widgets/segmented_circular_progress/animated_circle_view.dart';
import 'package:langwise/common/widgets/segmented_circular_progress/circle_painter.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/theme/theme_utils.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../common/mission_control_center_dotted_line_paint.dart';
import '../../controllers/mission_control_center_controller.dart';
import '../../views/mission_control_center_planet_widget.dart';
import '../controllers/mission_control_center_daily_task_controller.dart';

class MissionControlCenterDailyTaskView extends GetView<MissionControlCenterDailyTaskController> {
  final String tagText;
  const MissionControlCenterDailyTaskView({super.key, required this.tagText});

  @override
  String? get tag => '${tagText}_daily_task';

  @override
  Widget build(BuildContext context) {
    return _MissionControlCenterDailyTaskContent(tagText: controller.shellTag);
  }
}

class _MissionControlCenterDailyTaskContent extends GetView<MissionControlCenterController> {
  final String tagText;
  const _MissionControlCenterDailyTaskContent({required this.tagText});

  @override
  String? get tag => tagText;

  Color get _panelTextColor => AppTheme.cTextPrimary.color;
  Color get _panelSecondaryTextColor => AppTheme.cTextSecondary.color;
  Color get _panelTertiaryTextColor => AppTheme.cTextTertiary;
  Color get _panelBackgroundColor => AppTheme.cSurfaceLayerBase.color;
  Color get _panelBorderColor => AppTheme.cSurfaceLayerElevated.color;
  Color get _panelDividerColor => AppTheme.cSurfaceLayerElevated.color;
  Color get _panelItemBackgroundColor => AppTheme.cSurfaceLayerBase.color;
  Color get _panelItemBorderColor => AppTheme.cSurfaceLayerElevated.color;
  double get _panelSectionGap => 16.wMin;
  double get _currentUnitCoverHeight => 160.wMin;

  SpecialtyColor _resolveCurrentCourseColor(CurrentCoursePlanInfoCourseItem item) {
    final specialty = item.currentInfo?.specialty?.trim() ?? item.specialty?.trim();
    return SpecialtyEnum.getCourseColor(specialty ?? '');
  }

  bool _isCurrentWritingCourse(CurrentCoursePlanInfoCourseItem item) {
    final specialty = item.currentInfo?.specialty?.trim() ?? item.specialty?.trim();
    return specialty == SpecialtyEnum.EN_WRITING;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return LockOverlayWidget(
        rights: controller.missionEntity.value.rights,
        showBack: false,
        onPageBack: () {
          Future.microtask(() {
            controller.refreshMissionListOnly(showLoading: false, scrollToCurrent: false);
          });
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minWidth = 1540.wMin;
            final contentWidth = math.max(constraints.maxWidth, minWidth);
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: contentWidth,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(90.wMin, 0, 90.wMin, 15.wMin),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Obx(() {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (!controller.hideExamPlanPanel) ...[
                                      SizedBox(
                                        width: 400.wMin,
                                        child: _buildExamPanelWidget(context),
                                      ),
                                      SizedBox(width: _panelSectionGap),
                                    ],
                                    Expanded(
                                      child: _buildDailyMissionPanel(context),
                                    ),
                                  ],
                                );
                              }),
                            ),
                            SizedBox(height: _panelSectionGap),
                            SizedBox(
                              height: 340.wMin,
                              child: _buildSpecialExpansionPanel(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: _panelSectionGap),
                      SizedBox(
                        width: 335.wMin,
                        child: Column(
                          children: [
                            _buildAssessmentCardWidget(),
                            SizedBox(height: _panelSectionGap),
                            _buildStudyPlanCardWidget(),
                            SizedBox(height: _panelSectionGap),
                            Expanded(
                              child: _buildCurrentUnitPanelWidget(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildExamPanelWidget(BuildContext context) {
    if (controller.showExamPlanGuide) {
      return _buildExamPlanGuideWidget(context);
    }

    return _buildPanelWidget(
      child: Column(
        children: [
          Container(
            height: 160.wMin,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.wMin),
                topRight: Radius.circular(24.wMin),
              ),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2E315F),
                  Color(0x001C1F2C),
                ],
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 180.wMin,
                height: 146.wMin,
                child: Obx(() {
                  final total = controller.examReviewCards.length;
                  final completed = controller.completedExamReviewCount.clamp(0, total);
                  final progress = total == 0 ? 0.0 : completed / total;
                  return Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 8.wMin,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/mission/prepare.png',
                            fit: BoxFit.cover,
                            width: 96.wMin,
                            height: 96.wMin,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        child: SizedBox(
                          width: 112.wMin,
                          height: 112.wMin,
                          child: AnimatedCircleView(
                            key: ValueKey(progress),
                            duration: Duration.zero,
                            fadeInDuration: Duration.zero,
                            curve: Curves.linear,
                            isContinuous: true,
                            progressValue: progress,
                            borderWidth: 3.wMin,
                            strokeWidth: 3.wMin,
                            circlePainterConfig: CirclePainterConfig.full(
                              fillColor: const Color(0xFF5B61E8),
                              borderColor: const Color(0xFF5B61E8),
                              baseColor: const Color(0xFF4047A5).withValues(alpha: 0.45),
                              strokeWidth: 6.wMin,
                              borderWidth: 6.wMin,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 34.wMin,
                        child: SizedBox(
                          width: 52.wMin,
                          height: 52.wMin,
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/svg/mission/icon_exam.svg',
                              width: 52.wMin,
                              height: 52.wMin,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10.wMin,
                        child: Container(
                          height: 40.wMin,
                          padding: EdgeInsets.symmetric(horizontal: 20.wMin),
                          decoration: BoxDecoration(
                            color: const Color(0xFF818CF8),
                            borderRadius: BorderRadius.circular(999.wMin),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF818CF8).withValues(alpha: 0.28),
                                blurRadius: 14,
                                offset: Offset(0, 4.wMin),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '$completed/$total',
                                style: TextStyle(
                                  fontSize: 20.wMin,
                                  color: AppTheme.cStaticWhite.color,
                                  fontWeight: FontWeight.w500,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          SizedBox(height: 10.wMin),
          Obx(() {
            return Text(
              controller.examTitleLabel,
              style: TextStyle(
                fontSize: 36.wMin,
                color: _panelTextColor,
                fontWeight: FontWeight.w700,
              ),
            );
          }),
          SizedBox(height: 8.wMin),
          Obx(() {
            return RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '距离考试',
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: _panelSecondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: '${controller.examCountdownDays}',
                    style: TextStyle(
                      fontSize: 32.wMin,
                      color: const Color(0xFF818CF8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: '天',
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: _panelSecondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
          const Spacer(),
          SizedBox(
            height: 186.wMin,
            child: Obx(() {
              final cards = controller.examReviewCards;
              final selectedIndex = controller.selectedExamReviewIndex.value;
              return PageView.builder(
                controller: controller.examReviewPageController,
                itemCount: cards.length,
                padEnds: true,
                onPageChanged: (index) {
                  controller.selectedExamReviewIndex.value = index;
                },
                itemBuilder: (context, index) {
                  final isSelected = selectedIndex == index;
                  return Center(
                    child: TapScaleWidget(
                      sclae: 1.01,
                      onTap: () {
                        controller.examReviewPageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOut,
                        );
                        controller.selectedExamReviewIndex.value = index;
                      },
                      child: SizedBox(
                        width: 256.wMin,
                        height: 218.wMin,
                        child: _buildExamReviewCard(cards[index], isSelected: isSelected),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          SizedBox(height: 16.wMin),
        ],
      ),
    );
  }

  Widget _buildExamPlanGuideWidget(BuildContext context) {
    final examConfig = controller.missionEntity.value.examPlanDTO?.config;
    final guideTexts = examConfig?.texts ?? const <String>[];
    const guidePrimaryColor = Color(0xFF6B72FF);
    const guideSecondaryColor = Color(0xFF8A90FF);
    return _buildPanelWidget(
      child: Column(
        children: [
          Container(
              height: 120.wMin,
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24.wMin, 20.wMin, 24.wMin, 18.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.wMin),
                  topRight: Radius.circular(24.wMin),
                ),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x336366F1),
                    Color(0x006366F1),
                  ],
                  stops: [0, 1],
                ),
              ),
              child: SizedBox(
                height: 76.wMin,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 76.wMin,
                      height: 76.wMin,
                      decoration: BoxDecoration(
                        color: guidePrimaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8.wMin),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/svg/mission/icon_exam.svg',
                          width: 52.wMin,
                          height: 52.wMin,
                          colorFilter: ColorFilter.mode(
                            guidePrimaryColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.wMin),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EXAM PREP',
                            style: TextStyle(
                              fontSize: 14.wMin,
                              color: guideSecondaryColor.withValues(alpha: 0.8),
                              height: 1.2,
                            ),
                          ),
                          Text(
                            examConfig?.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 36.wMin,
                              color: AppTheme.cTextPrimary,
                              fontWeight: FontWeight.w600,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            examConfig?.title ?? '',
                            style: TextStyle(
                              fontSize: 16.wMin,
                              color: AppTheme.cTextTertiary.color,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.wMin, 6.wMin, 24.wMin, 24.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AppTheme.cWhiteAlpha10.color,
                  ),
                  SizedBox(height: 16.wMin),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              examConfig?.subTitle ?? '',
                              style: TextStyle(
                                fontSize: 18.wMin,
                                color: guideSecondaryColor.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      ...List.generate(guideTexts.length, (index) {
                        return Padding(
                          padding: EdgeInsets.only(top: 24.wMin),
                          child: _buildExamPlanGuidePoint(guideTexts[index]),
                        );
                      }),
                    ],
                  ),
                  const Spacer(),
                  ButtonWidget(
                    text: '添加备考计划',
                    height: 56.wMin,
                    borderRadius: 8.wMin,
                    color: guidePrimaryColor.withValues(alpha: 0.8),
                    fontSize: 20.wMin,
                    fontColor: AppTheme.cStaticWhite.color,
                    fontWeight: FontWeight.w500,
                    rightIcon: Padding(
                      padding: EdgeInsets.only(left: 8.wMin),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 24.wMin,
                        color: AppTheme.cStaticWhite.color,
                      ),
                    ),
                    sclae: 1.01,
                    onTap: () {
                      controller.onTapCreateExamPlan(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamPlanGuidePoint(String text) {
    const guidePrimaryColor = Color(0xFF6B72FF);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 26.wMin,
          height: 26.wMin,
          margin: EdgeInsets.only(top: 2.wMin),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: guidePrimaryColor.withValues(alpha: 0.8),
          ),
          child: Center(
            child: Icon(
              Icons.check_rounded,
              size: 16.wMin,
              color: AppTheme.cStaticWhite.color,
            ),
          ),
        ),
        SizedBox(width: 8.wMin),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16.wMin,
              color: _panelSecondaryTextColor,
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExamReviewCard(MissionControlExamReviewCard card, {required bool isSelected}) {
    final reviewStatus = card.reviewStatus ?? '';
    final isWaiting = reviewStatus == 'waiting';
    final isFinish = reviewStatus == 'finish';
    final isExpired = reviewStatus == 'expired';
    final itemBorderColor = isSelected ? const Color(0xFF6366F1).withValues(alpha: 0.20) : _panelItemBorderColor;
    final stageBackgroundColor = isWaiting
        ? AppTheme.cBgQuaternary
        : isFinish
            ? const Color(0xFF00BC7D).withValues(alpha: 0.55)
            : isExpired
                ? const Color(0xFFF43F5E).withValues(alpha: 0.55)
                : const Color(0xFF6366F1).withValues(alpha: 0.55);
    final actionTextColor = controller.examActionTextColor(card);
    final actionBackgroundColor = controller.examActionBackgroundColor(card);
    final actionBorderColor = controller.examActionBorderColor(card);
    final waitingContentOpacity = isWaiting ? 0.72 : 1.0;
    final rightStatusText = isWaiting ? null : card.statusLabel;
    final rightStatusTextColor = isWaiting
        ? AppTheme.cStaticWhite.color
        : isFinish
            ? const Color(0xFF00D492)
            : isExpired
                ? const Color(0xFFE11D48)
                : card.statusColor;
    final rightStatusBackgroundColor = isWaiting
        ? AppTheme.cOverlayActive.color
        : isFinish
            ? const Color(0xFF00BC7D).withValues(alpha: 0.12)
            : isExpired
                ? const Color(0xFFEF4444).withValues(alpha: 0.10)
                : Colors.transparent;
    final rightStatusBorderColor = isWaiting
        ? AppTheme.cOverlayActive.color
        : isFinish
            ? const Color(0xFF00D492).withValues(alpha: 0.20)
            : isExpired
                ? const Color(0xFFEF4444).withValues(alpha: 0.10)
                : Colors.transparent;
    return TapScaleWidget(
      onTap: card.actionEnabled ? () => controller.onTapExamAction(card, Get.context!) : null,
      behavior: HitTestBehavior.opaque,
      sclae: 1.02,
      borderRadius: 12.wMin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: isWaiting ? AppTheme.cOverlayDisabled.color : _panelItemBackgroundColor,
          border: Border.all(
            color: itemBorderColor,
            width: 1,
          ),
        ),
        child: Opacity(
          opacity: waitingContentOpacity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 6.wMin),
                    decoration: BoxDecoration(
                      color: stageBackgroundColor,
                      borderRadius: BorderRadius.circular(6.wMin),
                    ),
                    child: Text(
                      card.stageLabel,
                      style: TextStyle(
                        fontSize: 16.wMin,
                        color: AppTheme.cStaticWhite.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isWaiting)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 6.wMin),
                      decoration: BoxDecoration(
                        color: rightStatusBackgroundColor,
                        borderRadius: BorderRadius.circular(6.wMin),
                        border: Border.all(
                          color: rightStatusBorderColor,
                          width: 1.wMin,
                        ),
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 16.wMin,
                        color: rightStatusTextColor,
                      ),
                    )
                  else if ((rightStatusText ?? '').isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 6.wMin),
                      decoration: BoxDecoration(
                        color: rightStatusBackgroundColor,
                        borderRadius: BorderRadius.circular(6.wMin),
                        border: Border.all(
                          color: rightStatusBorderColor,
                          width: 1.wMin,
                        ),
                      ),
                      child: Text(
                        rightStatusText!,
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: rightStatusTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              Text(
                card.date,
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: _panelTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                card.time,
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextTertiary.color,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.wMin),
                  color: actionBackgroundColor,
                  border: Border.all(
                    color: actionBorderColor,
                    width: 1.wMin,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      card.actionLabel,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: actionTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (card.actionEnabled) ...[
                      SizedBox(width: 6.wMin),
                      SvgPicture.asset(
                        'assets/svg/mission/icon_right.svg',
                        width: 8.wMin,
                        colorFilter: ColorFilter.mode(actionTextColor, BlendMode.srcIn),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyMissionPanel(BuildContext context) {
    return _buildPanelWidget(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.wMin),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 160.wMin,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(0, 153, 220, 0.08),
                        Color.fromRGBO(56, 189, 248, 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.wMin, 12, 24.wMin, 24.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    return Row(
                      children: [
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF0099DC),
                                Color(0xFF7DD3FC),
                              ],
                              stops: [0.2547, 0.8346],
                            ).createShader(bounds);
                          },
                          child: Text(
                            '主线课程',
                            style: TextStyle(
                              fontSize: 32.wMin,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        _buildMissionStatText('任务进度', controller.missionProgressText, const Color(0xFF34D399)),
                        SizedBox(width: 18.wMin),
                        _buildMissionStatText('已用时', controller.missionDurationText, const Color(0xFF60A5FA)),
                        SizedBox(width: 18.wMin),
                        _buildMissionStatText('平均正确率', controller.missionAccuracyText, const Color(0xFFA78BFA)),
                        SizedBox(width: 18.wMin),
                        _buildMissionStatText('总星星', controller.missionPointText, const Color(0xFFF59E0B)),
                        SizedBox(width: 12.wMin),
                        Visibility(
                          visible: (controller.missionEntity.value.completeShowCount ?? true) && controller.isAllCompleted.value,
                          child: TapScaleWidget(
                            sclae: 1.02,
                            onTap: () => controller.showMissionStatisticsDialog(context),
                            child: _buildHeaderActionWidget(
                              title: '详细',
                              iconPath: 'assets/svg/public/icon_polyline.svg',
                            ),
                          ),
                        ),
                        SizedBox(width: 8.wMin),
                        Visibility(
                          visible: controller.isAllCompleted.value,
                          child: TapScaleWidget(
                            sclae: 1.02,
                            onTap: () => controller.advanceLearning(context),
                            child: Container(
                              height: 48.wMin,
                              padding: EdgeInsets.symmetric(horizontal: 18.wMin),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2563EB),
                                    Color(0xFF4338CA),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '我要提前学',
                                  style: TextStyle(
                                    fontSize: 20.wMin,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: 18.wMin),
                  _buildMissionOverviewWidget(),
                  SizedBox(height: 12.wMin),
                  Expanded(
                    child: _buildMissionListWidget(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionOverviewWidget() {
    return Obx(() {
      final knowledgeList = controller.todayMissionKnowledgeList;
      final reviewList = knowledgeList.where((item) => item.isOldKnowledge).toList();
      final newList = knowledgeList.where((item) => item.isNewKnowledge).toList();
      final totalCount = knowledgeList.length;

      int countByType(List<TaskMissionEntityMissionKnowledgeItem> list, String type) {
        return list.where((item) => item.contentType == type).length;
      }

      return GuideStepWidget(
        id: GuideWidgetIds.missionControlCenterTodayKnowledgeOverviewButton,
        sclae: 1,
        onTap: controller.onTapMissionOverview,
        child: Container(
          width: double.infinity,
          height: 52.wMin,
          padding: EdgeInsets.symmetric(horizontal: 8.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: _panelItemBackgroundColor,
            border: Border.all(
              color: _panelItemBorderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                '今日知识概览',
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: _panelTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              _buildMissionOverviewGroup(
                title: '旧识',
                count: reviewList.length,
                color: const Color(0xFFF59E0B),
                wordCount: countByType(reviewList, 'EN_WORD'),
                phraseCount: countByType(reviewList, 'EN_PHRASE'),
                sentenceCount: countByType(reviewList, 'EN_SENTENCE'),
              ),
              SizedBox(width: 8.wMin),
              _buildMissionOverviewGroup(
                title: '新知',
                count: newList.length,
                color: const Color(0xFF84CC16),
                wordCount: countByType(newList, 'EN_WORD'),
                phraseCount: countByType(newList, 'EN_PHRASE'),
                sentenceCount: countByType(newList, 'EN_SENTENCE'),
              ),
              Spacer(),
              Container(
                height: 36.wMin,
                padding: EdgeInsets.symmetric(horizontal: 14.wMin),
                decoration: BoxDecoration(
                  color: AppTheme.cSurfaceLayerElevated.color,
                  borderRadius: BorderRadius.circular(10.wMin),
                ),
                child: Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '总数 ',
                            style: TextStyle(
                              fontSize: 18.wMin,
                              color: _panelTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: '$totalCount 个',
                            style: TextStyle(
                              fontSize: 18.wMin,
                              color: AppTheme.cTextPrimary.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 6.wMin),
                    SvgPicture.asset(
                      'assets/svg/mission/icon_right.svg',
                      width: 8.wMin,
                      colorFilter: ColorFilter.mode(_panelSecondaryTextColor, BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMissionListWidget() {
    return Obx(() {
      if (controller.todayTaskStatusNoRights.value) {
        final message = controller.todayTaskGenerateMessage.value.isNotEmpty ? controller.todayTaskGenerateMessage.value : '暂无权限';
        return NotDataWidget(message: message);
      }
      final rights = controller.missionEntity.value.rights;
      if ((rights?.isNoRights ?? false) || (rights?.isLock ?? false)) {
        return const SizedBox.shrink();
      }
      final generatingStatus = controller.todayTaskGenerateStatus.value;
      final isGenerating = generatingStatus != null && generatingStatus != HomeGenerateStatusEnum.FINISHED;
      if (isGenerating || (controller.missionList.isEmpty && controller.dailyMissionPanelLoading.value)) {
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 24.wMin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _GradientLoopProgressBar(),
              SizedBox(height: 32.wMin),
              Text(
                controller.todayTaskGenerateMessage.value,
                   
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
      }
      if (!controller.isTodayMission.value) {
        return const NotDataWidget(message: '没有任务了\n明天再来挑战吧');
      }
      final currentIndex = controller.currentMissionIndex.value;
      final isAllCompleted = controller.isAllCompleted.value;
      return ClipRRect(
        borderRadius: BorderRadius.circular(24.wMin),
        child: CustomPaint(
          painter: MissionControlCenterDottedLinePaint(
            missionList: controller.missionList,
            rootKey: controller.listRootKey,
            lineColor: AppTheme.cBgQuaternary,
            lineWidth: 6.wMin,
            dashSpace: 20.wMin,
            dashWidth: 16.wMin,
            repaint: controller.scrollController,
          ),
          child: ListView.builder(
            key: controller.listRootKey,
            controller: controller.scrollController,
            itemCount: controller.missionList.length,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 18.wMin, right: 48.wMin),
            itemBuilder: (context, index) {
              bool isLock = index > controller.currentMissionIndex.value;
              if (controller.missionList[index].missions.learned) isLock = false;
              if (controller.missionList[index].missions.learning) isLock = false;
              final isAdmin = UserStore.to.rolePermissions.value.isOfficial;
              if (isAdmin) isLock = false;

              String? widgetId = getFirstPreviewTaskWidgetId(index);
              return MissionControlCenterPlanetWidget(
                widgetId: isLock ? null : widgetId,
                missionModel: controller.missionList[index],
                index: index,
                currentIndex: isAllCompleted ? -1 : currentIndex,
                onTap: isLock
                    ? null
                    : () async {
                        controller.startMission(controller.missionList[index], index, again: false, widgetId: widgetId);
                      },
                onAgainTap: isLock
                    ? null
                    : () {
                        controller.startMission(controller.missionList[index], index, again: true);
                      },
              );
            },
          ),
        ),
      );
    });
  }
  /// 获取第一个预习或任务的widgetid

  /// 获取第一个预习或任务的widgetid
  String? getFirstPreviewTaskWidgetId(int index) {
    if (index < 0 || index >= controller.missionList.length) return null;

    final currentMission = controller.missionList[index].missions;
    final isNewKnowledgeMission = !currentMission.isPreview && !currentMission.isTest && !currentMission.isReview;
    if (currentMission.isPreview) {
      final hasPreviousPreview = controller.missionList.take(index).any((item) => item.missions.isPreview);
      return hasPreviousPreview ? null : GuideWidgetIds.missionControlCenterFirstPreparationButton;
    }

    if (isNewKnowledgeMission) {
      final hasPreviousNewKnowledgeMission = controller.missionList.take(index).any((item) => !item.missions.isPreview && !item.missions.isTest && !item.missions.isReview);
      return hasPreviousNewKnowledgeMission ? null : GuideWidgetIds.missionControlCenterFirstNewKnowledgeButton;
    }

    return null;
  }

  Widget _buildSpecialExpansionPanel() {
    return Container(
      key: controller.specialMissionPanelKey,
      child: _buildPanelWidget(
        padding: EdgeInsets.all(12.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 6.wMin),
                Text(
                  '专项拓展',
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: _panelTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 6.wMin),
                Text(
                  '· 拔尖学习，按需选做',
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: _panelSecondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: '总钻石数 ',
                      style: TextStyle(
                        fontSize: 16.wMin,
                        color: _panelTextColor,
                      ),
                    ),
                    TextSpan(
                      text: '${controller.specialMissionDiamondTotal}',
                      style: TextStyle(
                        fontSize: 16.wMin,
                        color: const Color(0xFFC084FC),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
            SizedBox(height: 12.wMin),
            Expanded(
              child: Obx(() {
                final menuItems = controller.taskMissionMenuList.toList();
                final titles = controller.specialMissionTitles;
                const slotCount = 5;
                final itemCount = math.min(titles.length, slotCount);
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final spacing = 12.wMin;
                    final itemWidth = (constraints.maxWidth - (slotCount - 1) * spacing) / slotCount;
                    return Row(
                      children: List.generate(slotCount * 2 - 1, (index) {
                        if (index.isOdd) {
                          return SizedBox(width: spacing);
                        }
                        final slotIndex = index ~/ 2;

                        TaskMissionMenuEntityList? menuItem = slotIndex < menuItems.length ? menuItems[slotIndex] : null;
                        String? widgetId = _getOverallWidgetId(menuItem);
                        Widget bodyWidget = Container();
                        if (widgetId == null) {
                          bodyWidget = TapScaleWidget(
                            onTap: menuItem == null
                                ? null
                                : () {
                                    controller.onTapSpecialMission(menuItem);
                                  },
                            sclae: 1.01,
                            child: _buildSpecialCardWidget(
                              titles[slotIndex],
                              menuItem: menuItem,
                            ),
                          );
                        } else {
                          bodyWidget = GuideStepWidget(
                            id: widgetId,
                            onTap: () async {
                              if (menuItem != null) {
                                controller.onTapSpecialMission(menuItem, widgetId: widgetId);
                              }
                            },
                            sclae: 1.01,
                            child: _buildSpecialCardWidget(
                              titles[slotIndex],
                              menuItem: menuItem,
                            ),
                          );
                        }
                        return SizedBox(
                          width: itemWidth,
                          child: slotIndex < itemCount ? bodyWidget : const SizedBox.shrink(),
                        );
                      }),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取听说读写综合的widgetid
  String? _getOverallWidgetId(TaskMissionMenuEntityList? menuItem) {
    if (menuItem?.type == null) return null;
    if (menuItem?.type == LSRWEnum.listening) {
      return GuideWidgetIds.missionControlCenterListenButton;
    } else if (menuItem?.type == LSRWEnum.speaking) {
      return GuideWidgetIds.missionControlCenterSpeakButton;
    } else if (menuItem?.type == LSRWEnum.reading) {
      return GuideWidgetIds.missionControlCenterReadButton;
    } else if (menuItem?.type == LSRWEnum.writing) {
      return GuideWidgetIds.missionControlCenterWriteButton;
    } else if (menuItem?.type == LSRWEnum.overall) {
      return GuideWidgetIds.missionControlCenterOverallButton;
    }
    return null;
  }

  Widget _buildStatusCardWidget({
    required String badge,
    required String title,
    required String subtitle,
    required Color badgeColor,
    Color? titleColor,
    Color? subtitleColor,
    String? badgeValue,
    void Function()? onTap,
  }) {
    final resolvedTitleColor = titleColor ?? _panelTextColor;
    final resolvedSubtitleColor = subtitleColor ?? _panelSecondaryTextColor;
    final isMultilineBadge = badge.contains('\n');
    final badgeFontSize = isMultilineBadge ? 20.wMin : 32.wMin;
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.01,
      child: _buildPanelWidget(
        padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 14.wMin),
        child: Row(
          children: [
            Container(
              width: 64.wMin,
              height: 64.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.wMin),
                color: badgeColor.withValues(alpha: 0.12),
                border: Border.all(
                  color: badgeColor.withValues(alpha: 0.18),
                  width: 1.wMin,
                ),
              ),
              child: badgeValue == null
                  ? Text(
                      badge,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: badge == 'Pre A1' ? 16.wMin : badgeFontSize,
                        color: badgeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _panelItemBackgroundColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(11.wMin),
                                topRight: Radius.circular(11.wMin),
                              ),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                fontSize: 16.wMin,
                                color: _panelTextColor,
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 1.wMin,
                          color: _panelDividerColor,
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text(
                              badgeValue,
                              style: TextStyle(
                                fontSize: 32.wMin,
                                color: badgeColor,
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            SizedBox(width: 16.wMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 28.wMin,
                            color: resolvedTitleColor,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.wMin),
                      Padding(
                        padding: EdgeInsets.only(top: 2.wMin),
                        child: SvgPicture.asset(
                          'assets/svg/mission/icon_right.svg',
                          width: 12.wMin,
                          colorFilter: ColorFilter.mode(resolvedTitleColor, BlendMode.srcIn),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.wMin),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: resolvedSubtitleColor,
                      fontWeight: FontWeight.w400,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentCardWidget() {
    return Obx(() {
      return GuideStepWidget(
        id: GuideWidgetIds.missionControlCenterCurrentLevelButton,
        sclae: 1.01,
        onTap: () async {
          controller.onTapAssessmentPanel();
        },
        child: _buildStatusCardWidget(
          badge: controller.assessmentBadgeLabel,
          title: controller.currentLevelLabel,
          subtitle: controller.assessmentSubtitle,
          badgeColor: controller.assessmentPanelBadgeColor,
          titleColor: controller.assessmentPanelTitleColor,
          subtitleColor: controller.assessmentPanelSubtitleColor,
        ),
      );
    });
  }

  Widget _buildStudyPlanCardWidget() {
    return Obx(() {
      final accentColor = controller.studyPlanAccentColor;
      return GuideStepWidget(
        id: GuideWidgetIds.missionControlCenterPlanButton,
        onTap: controller.onTapStudyPlanPanel,
        sclae: 1.01,
        child: Stack(
          children: [
            _buildPanelWidget(
              padding: EdgeInsets.fromLTRB(20.wMin, 18.wMin, 18.wMin, 18.wMin),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    controller.workdayStudyLabel,
                    style: TextStyle(
                      fontSize: 52.wMin,
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                  SizedBox(width: 14.wMin),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                controller.workdayStudyUnit,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 24.wMin,
                                  color: _panelTextColor,
                                  fontWeight: FontWeight.w700,
                                  height: 1.05,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.wMin),
                            SvgPicture.asset(
                              'assets/svg/mission/icon_right.svg',
                              width: 12.wMin,
                              colorFilter: ColorFilter.mode(_panelSecondaryTextColor, BlendMode.srcIn),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.wMin),
                        Text(
                          controller.studyPlanSubtitle.replaceAll('\n', ' '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.wMin,
                            color: _panelSecondaryTextColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                constraints: BoxConstraints(),
                padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 8.wMin),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15.wMin),
                    bottomLeft: Radius.circular(12.wMin),
                  ),
                ),
                child: Text(
                  controller.workdayStudyTagLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCurrentUnitItemWidget(CurrentCoursePlanInfoCourseItem item, int index) {
    return TapScaleWidget(
      onTap: () => controller.onTapCurrentCourse(item),
      sclae: 1.01,
      child: _buildCurrentUnitCardWidget(item, index),
    );
  }

  Widget _buildCurrentUnitPanelWidget() {
    return _buildPanelWidget(
      padding: EdgeInsets.all(12.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
              final units = controller.displayCurrentCoursePlanList;
              final unitCount = units.length;
              final startedUnitCount = units.where((item) => !item.isPendingStart).length;
            return Row(
              children: [
                Text(
                  '当前学习单元',
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: _panelTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                    '$startedUnitCount / $unitCount',
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: _panelSecondaryTextColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 14.wMin),
          Expanded(
            child: Obx(() {
              final units = controller.displayCurrentCoursePlanList;
              return ListView.separated(
                itemCount: units.length,
                itemBuilder: (_, index) => _buildCurrentUnitItemWidget(units[index], index),
                separatorBuilder: (_, __) => Column(
                  children: [
                    SizedBox(height: 8.wMin),
                    Divider(height: 1, color: _panelDividerColor),
                    SizedBox(height: 8.wMin),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUnitCardWidget(CurrentCoursePlanInfoCourseItem item, int index) {
    final moduleName = item.currentInfo?.moduleName?.trim() ?? '';
    final courseName = item.courseName?.trim() ?? '';
    final title = controller.currentCourseDisplayTitle(item);
    return SizedBox(
      height: _currentUnitCoverHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.wMin),
                border: Border.all(
                  color: AppTheme.cMemberCardActiveBackground.color,
                  width: 1.wMin,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.wMin),
                child: _buildUnitCoverWidget(
                  item,
                  index,
                  moduleName: moduleName,
                  courseName: courseName,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.wMin),
          Expanded(
            child: _buildCurrentUnitRightContent(item, title),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitCoverWidget(
    CurrentCoursePlanInfoCourseItem item,
    int index, {
    required String moduleName,
    required String courseName,
  }) {
    if (!item.hasCurrentInfo) {
      return _buildCurrentUnitEmptyCover(item, courseName);
    }
    final double? progress = controller.currentCourseUnitPercent(item);
    final unitIndex = item.currentInfo?.unitIndex ?? 0;
    final unitTotal = item.currentInfo?.unitTotal ?? 0;
    final courseColor = _resolveCurrentCourseColor(item);
    final coverUrl = item.currentInfo?.moduleCoverUrl ?? '';
    final cover = coverUrl.isNotEmpty
        ? CachedImageWidget(
            coverUrl,
            fadeInDuration: Duration.zero,
            errorWidget: _buildFallbackCoverWidget(index),
            placeholder: _buildFallbackCoverWidget(index),
          )
        : _buildFallbackCoverWidget(index);

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          cover,
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  AppTheme.cBlackAlpha70.color.withValues(alpha: 0.5),
                ],
                stops: const [0, 0.7, 1],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(6.wMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (courseName.isNotEmpty)
                  VideoImageInnerButtonWidget(
                    text: courseName,
                    backgroundColor: courseColor.color1.withValues(alpha: 0.72),
                    borderColor: courseColor.color2.withValues(alpha: 0.84),
                    padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 4.wMin),
                    textStyle: TextStyle(
                      fontSize: 12.wMin,
                      color: AppTheme.cStaticWhite.color,
                    ),
                  ),
                const Spacer(),
                if (moduleName.isNotEmpty)
                  Text(
                    moduleName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.wMin,
                      color: AppTheme.cStaticWhite.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                if (progress != null && unitTotal > 0) ...[
                  if (moduleName.isNotEmpty) SizedBox(height: 4.wMin),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99.wMin),
                          child: Container(
                            height: 4.wMin,
                            color: courseColor.color1.withValues(alpha: 0.22),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (progress / 100).clamp(0, 1),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      courseColor.color1,
                                      courseColor.color2,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.wMin),
                      Text(
                        '$unitIndex/$unitTotal',
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: AppTheme.cStaticWhite.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUnitEmptyCover(CurrentCoursePlanInfoCourseItem item, String courseName) {
    final courseColor = _resolveCurrentCourseColor(item);
    if (item.isPendingStartWithoutAssessmentPlan) {
      return SizedBox.expand(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: courseColor.color1.withValues(alpha: 0.12),
          ),
          child: Padding(
            padding: EdgeInsets.all(6.wMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (courseName.isNotEmpty)
                  VideoImageInnerButtonWidget(
                    text: courseName,
                    backgroundColor: courseColor.color1.withValues(alpha: 0.72),
                    borderColor: courseColor.color2.withValues(alpha: 0.84),
                    padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 4.wMin),
                    textStyle: TextStyle(
                      fontSize: 12.wMin,
                      color: AppTheme.cStaticWhite.color,
                    ),
                  ),
                const Spacer(),
                Align(
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/svg/mission/icon_add.svg',
                    width: 44.wMin,
                    height: 44.wMin,
                    colorFilter: ColorFilter.mode(
                      courseColor.color1,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const Spacer(),
                _buildCurrentUnitAssessmentPlanName(item),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFF3D4149),
      padding: EdgeInsets.all(6.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (courseName.isNotEmpty)
            VideoImageInnerButtonWidget(
              text: courseName,
              backgroundColor: courseColor.color1.withValues(alpha: 0.72),
              borderColor: courseColor.color2.withValues(alpha: 0.84),
              padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 4.wMin),
              textStyle: TextStyle(
                fontSize: 12.wMin,
                color: AppTheme.cStaticWhite.color,
              ),
            ),
          const Spacer(),
          Align(
            alignment: Alignment.center,
            child: Text(
              '未开始',
              style: TextStyle(
                fontSize: 26.wMin,
                color: AppTheme.cStaticWhite.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          _buildCurrentUnitAssessmentPlanName(item),
        ],
      ),
    );
  }

  Widget _buildCurrentUnitAssessmentPlanName(CurrentCoursePlanInfoCourseItem item) {
    final assessmentPlanName = item.assessmentPlanName?.trim() ?? '';
    if (assessmentPlanName.isEmpty) {
      return const SizedBox.shrink();
    }
    return Text(
      assessmentPlanName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12.wMin,
        color: AppTheme.cStaticWhite.color,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildCurrentUnitRightContent(CurrentCoursePlanInfoCourseItem item, String title) {
    if (item.isPendingStart) {
      return _buildCurrentUnitCenterAction(
        title: _buildCurrentUnitStartTitle(item),
        color: _panelTextColor,
        subtitle: item.isPendingStartWithoutAssessmentPlan ? '加入当前学习方案' : null,
      );
    }

    if (item.isNeedUnlock) {
      return _buildCurrentUnitOverlayContent(
        child: const SizedBox.shrink(),
        overlayChild: _buildCurrentUnitStatusOverlay(
          badgeText: 'LOCKED',
          title: '自动解锁',
          subtitle: _buildCurrentUnitUnlockRequirement(item),
        ),
      );
    }

    if (!item.hasCurrentInfo) {
      return _buildCurrentUnitCenterAction(
        title: _buildCurrentUnitStartTitle(item),
        color: _panelTextColor,
      );
    }

    final compositionTaskName = item.currentInfo?.compositionTaskName?.trim() ?? '';
    final baseContent = _isCurrentWritingCourse(item)
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: _panelTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (compositionTaskName.isNotEmpty) ...[
                SizedBox(height: 8.wMin),
                Text(
                  compositionTaskName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: _panelTertiaryTextColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: _panelTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _buildCurrentCourseActionGrid(item),
            ],
          );

    if (item.isCompleted) {
      return _buildCurrentUnitOverlayContent(
        child: baseContent,
        overlayChild: _buildCurrentUnitStatusOverlay(
          badgeText: 'COMPLETED',
          title: '已学完',
          badgeColor: const Color(0xFF00BC7D),
        ),
      );
    }

    if (item.isPaused) {
      return _buildCurrentUnitOverlayContent(
        child: baseContent,
        overlayChild: _buildCurrentUnitStatusOverlay(
          badgeText: 'PAUSED',
          title: '已暂停',
          subtitle: '新内容暂停，复习继续',
        ),
      );
    }

    return baseContent;
  }

  String _buildCurrentUnitStartTitle(CurrentCoursePlanInfoCourseItem item) {
    final planRunTip = item.planRunTip?.trim() ?? '';
    if (planRunTip.isNotEmpty) return planRunTip;
    final courseName = item.courseName?.trim() ?? '';
    if (courseName.isEmpty) return '开始学习 >';
    return '开始$courseName >';
  }

  String? _buildCurrentUnitUnlockRequirement(CurrentCoursePlanInfoCourseItem item) {
    final triggerType = item.trigger?.type?.trim();
    final triggerTier = item.triggerTier;
    if (triggerType == null || triggerType.isEmpty || triggerTier == null) return null;

    final specialty = 'en_$triggerType'.toUpperCase();
    final courseName = SpecialtyEnum.getCourseName(specialty);
    if (courseName == null || courseName.isEmpty) {
      return 'Level $triggerTier';
    }
    return '$courseName Level $triggerTier';
  }

  Widget _buildCurrentUnitStatusOverlay({
    required String badgeText,
    required String title,
    String? subtitle,
    Color? badgeColor,
  }) {
    final overlayBadgeColor = badgeColor ?? _panelTextColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 6.wMin),
          decoration: BoxDecoration(
            color: overlayBadgeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999.wMin),
            border: Border.all(
              color: overlayBadgeColor.withValues(alpha: 0.15),
              width: 1.wMin,
            ),
          ),
          child: Text(
            badgeText,
            style: TextStyle(
              fontSize: 14.wMin,
              color: overlayBadgeColor,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ),
        SizedBox(height: 2.wMin),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cStaticWhite.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 2.wMin),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCurrentUnitCenterAction({
    required String title,
    required Color color,
    String? subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 2.wMin),
              Icon(
                Icons.chevron_right,
                size: 20.wMin,
                color: color,
              ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: 8.wMin),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cTextTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentUnitOverlayContent({
    required Widget child,
    required Widget overlayChild,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cBlackAlpha50,
              borderRadius: BorderRadius.circular(12.wMin),
            ),
            alignment: Alignment.center,
            child: overlayChild,
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackCoverWidget(int index) {
    final colors = [
      const [Color(0xFF1D4ED8), Color(0xFF38BDF8)],
      const [Color(0xFF9333EA), Color(0xFFF472B6)],
      const [Color(0xFFF59E0B), Color(0xFFF97316)],
    ];
    final colorPair = colors[index % colors.length];
    return Container(
      width: 92.wMin,
      height: 122.wMin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colorPair,
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/svg/guided_settings/icon_graduation_cap.svg',
          width: 34.wMin,
          colorFilter: ColorFilter.mode(AppTheme.cStaticWhite.color, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildSpecialCardWidget(
    String title, {
    TaskMissionMenuEntityList? menuItem,
  }) {
    final displayTitle = (menuItem?.title?.isNotEmpty ?? false) ? menuItem!.title! : title;
    final taskCount = menuItem?.taskCount ?? 0;
    const diamondMax = 2;
    final diamondCount = (menuItem?.diamondCount ?? 0).clamp(0, diamondMax);
    final learnedDurationSec = menuItem?.learnedDurationSec ?? 0;
    final learnedMinutes = learnedDurationSec <= 0 ? 0 : (learnedDurationSec ~/ 60);
    final tags = menuItem?.tags?.whereType<String>().where((e) => e.isNotEmpty).toList() ?? <String>[];
    final showTaskDot = taskCount >= 1;
    final actionText = switch (diamondCount) {
      0 => '蓄势待发',
      1 => '乘胜追击',
      _ => '完美双钻',
    };
    return Container(
      padding: EdgeInsets.fromLTRB(12.wMin, 12.wMin, 12.wMin, 12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: _panelItemBackgroundColor,
        border: Border.all(
          color: _panelItemBorderColor,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Text(
                    displayTitle,
                    style: TextStyle(
                      fontSize: 40.wMin,
                      color: _panelTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (showTaskDot)
                    Positioned(
                      top: 2.wMin,
                      right: -14.wMin,
                      child: Container(
                        width: 8.wMin,
                        height: 8.wMin,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF4D67),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.fromLTRB(12.wMin, 6.wMin, 6.wMin, 6.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999.wMin),
                  border: Border.all(
                    color: _panelDividerColor,
                    width: 1.wMin,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      actionText,
                      style: TextStyle(
                        fontSize: 16.wMin,
                        color: _panelTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6.wMin),
                    SvgPicture.asset(
                      'assets/svg/mission/icon_right.svg',
                      width: 10.wMin,
                      colorFilter: ColorFilter.mode(_panelTextColor, BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 6.wMin),
          Container(
            height: 1.wMin,
            color: _panelDividerColor,
          ),
          SizedBox(height: 6.wMin),
          if (tags.isNotEmpty)
            Wrap(
              spacing: 4.wMin,
              runSpacing: 8.wMin,
              children: tags.map((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.wMin, vertical: 4.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.wMin),
                    color: _panelBackgroundColor,
                    border: Border.all(
                      color: _panelDividerColor,
                      width: 1.wMin,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 14.wMin,
                      color: _panelSecondaryTextColor,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                );
              }).toList(),
            ),
          if (tags.isNotEmpty) SizedBox(height: 6.wMin),
          Expanded(
            child: Row(
              children: List.generate(diamondMax, (index) {
                return Expanded(
                  child: Center(
                    child: _SpecialDiamondBadge(isSuccess: index < diamondCount),
                  ),
                );
              }),
            ),
          ),
          Container(
            height: 1.wMin,
            color: _panelDividerColor,
          ),
          SizedBox(height: 12.wMin),
          Row(
            children: [
              Text(
                '每5分钟1钻',
                style: TextStyle(
                  fontSize: 18.wMin,
                  color: _panelSecondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '今日已学 ',
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: _panelSecondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: '$learnedMinutes',
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: const Color(0xFFC084FC),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: ' 分钟',
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: _panelSecondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPanelWidget({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.wMin),
        color: _panelBackgroundColor,
        border: Border.all(color: _panelBorderColor, width: 1),
      ),
      child: child,
    );
  }

  Widget _buildMissionStatText(String label, String value, Color valueColor) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(
              fontSize: 16.wMin,
              color: _panelTertiaryTextColor,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: 20.wMin,
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionOverviewGroup({
    required String title,
    required int count,
    required Color color,
    required int wordCount,
    required int phraseCount,
    required int sentenceCount,
  }) {
    return Container(
      height: 36.wMin,
      padding: EdgeInsets.symmetric(horizontal: 14.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceLayerElevated.color,
        borderRadius: BorderRadius.circular(10.wMin),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: ' $count',
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: _panelTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.wMin),
          Text(
            '单词$wordCount ｜ 短语$phraseCount ｜ 句子$sentenceCount',
            style: TextStyle(
              fontSize: 16.wMin,
              color: _panelTertiaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderActionWidget({
    required String title,
    required String iconPath,
  }) {
    return Container(
      height: 44.wMin,
      padding: EdgeInsets.symmetric(horizontal: 14.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: _panelItemBackgroundColor,
        border: Border.all(color: _panelItemBorderColor, width: 1),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
            width: 18.wMin,
            colorFilter: ColorFilter.mode(_panelSecondaryTextColor, BlendMode.srcIn),
          ),
          SizedBox(width: 8.wMin),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.wMin,
              color: _panelTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitTagWidget(
    String text,
    Color color, {
    void Function()? onTap,
    bool enabled = true,
  }) {
    final displayColor = enabled ? color : AppTheme.cTextTertiary.color.withValues(alpha: 0.6);
    final backgroundColor = AppTheme.cSurfaceLayerBase;
    final borderColor = AppTheme.cSurfaceLayerElevated;
    return TapScaleWidget(
      onTap: enabled ? onTap : null,
      sclae: 1.02,
      child: Container(
        height: 50.wMin,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 3.wMin, vertical: 4.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.wMin),
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: 1.wMin,
          ),
        ),
        child: Text(
          text,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.wMin,
            color: displayColor,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentCourseActionGrid(CurrentCoursePlanInfoCourseItem item) {
    final buttons = <Widget>[];
    final actionTextColor = AppTheme.cTextSecondary.color;

    void addButton(bool visible, String text, VoidCallback onTap) {
      if (!visible) return;
      buttons.add(
        _buildUnitTagWidget(
          text,
          actionTextColor,
          onTap: onTap,
        ),
      );
    }

    addButton(
      item.showListening,
      '情景\n导入',
      () => controller.onTapCurrentCoursePreview(item),
    );
    addButton(
      item.showSpeaking,
      '自拼\n音标',
      () => controller.onTapCurrentCoursePhonics(item),
    );
    addButton(
      item.showReading,
      '情景\n认读',
      () => controller.onTapCurrentCourseFlashNotes(item),
    );
    addButton(
      item.showWriting,
      '听写\n默写',
      () => controller.onTapCurrentCourseDictation(item),
    );

    if (buttons.isEmpty) return const SizedBox.shrink();

    final firstRow = buttons.take(2).toList();
    final secondRow = buttons.length > 2 ? buttons.sublist(2) : const <Widget>[];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCurrentCourseActionRow(firstRow),
        if (secondRow.isNotEmpty) ...[
          SizedBox(height: 6.wMin),
          _buildCurrentCourseActionRow(secondRow),
        ],
      ],
    );
  }

  Widget _buildCurrentCourseActionRow(List<Widget> buttons) {
    if (buttons.isEmpty) return const SizedBox.shrink();
    if (buttons.length == 1) {
      return Row(
        children: [
          Expanded(child: buttons.first),
          SizedBox(width: 6.wMin),
          const Expanded(child: SizedBox.shrink()),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: buttons[0]),
        SizedBox(width: 6.wMin),
        Expanded(child: buttons[1]),
      ],
    );
  }
}

class _SpecialDiamondBadge extends StatelessWidget {
  final bool isSuccess;
  const _SpecialDiamondBadge({required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    final isLight = ThemeUtils.isCurrentTheme(AppThemeKey.light.value);
    final assetPath = isLight
        ? (isSuccess ? 'assets/images/mission/icon_diamond_yes.png' : 'assets/images/mission/icon_diamond.png')
        : (isSuccess ? 'assets/images/mission/icon_diamond_black_yes.png' : 'assets/images/mission/icon_diamond_black.png');
    return SizedBox(
      height: 46.wMin,
      child: Image.asset(
        assetPath,
        height: 46.wMin,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _GradientLoopProgressBar extends StatefulWidget {
  const _GradientLoopProgressBar();

  @override
  State<_GradientLoopProgressBar> createState() => _GradientLoopProgressBarState();
}

class _GradientLoopProgressBarState extends State<_GradientLoopProgressBar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24.wMin,
      width: 500.wMin,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth;
          return ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppTheme.cSurfaceLayerBase.color,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: AppTheme.cBorderDefault.color,
                        width: 1.wMin,
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final double left = (maxWidth + 100.wMin) * _controller.value - 100.wMin;
                    return Positioned(
                      left: left,
                      top: 0,
                      bottom: 0,
                      child: child ?? Container(),
                    );
                  },
                  child: Container(
                    width: 100.wMin,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xff6366F1).withValues(alpha: 0),
                          Color(0xff3986ED).withValues(alpha: 0.5),
                          Color(0xff4E76EF).withValues(alpha: 0.75),
                          Color(0xff3986ED).withValues(alpha: 0.5),
                          Color(0xff6366F1).withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
