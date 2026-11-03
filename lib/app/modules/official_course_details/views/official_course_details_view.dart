import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/values/values.dart';
import '../../../../common/widgets/widgets.dart';
import '../controllers/official_course_details_controller.dart';

class OfficialCourseDetailsView extends GetView<OfficialCourseDetailsController> {
  const OfficialCourseDetailsView({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        backgroundColor: AppTheme.cSurfacePrimary,
        body: Obx(() {
          List<ThemeColorEntity?>? bgColor = controller.currentUnit.value.bgColor;
          ThemeColorEntity? colors = StyleUtils.getCurrentThemeColors(bgColor);
          LinearGradient? linearGradient = StyleUtils.parseCssLinearGradient(colors?.color);
          return Stack(
            children: [
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      gradient: linearGradient,
                    ),
                    child: Column(
                      children: [
                        _buildTitleWidget(context),
                        buildTitleBodyWidget(),
                      ],
                    ),
                  ),
                  _buildListWidget(),
                ],
              ),
              Obx(() {
                if (!controller.showCustomCourseStatus.value) return Container();
                return _buildListFilterWidget();
              }),
            ],
          );
        }),
      );
    });
  }

  Widget _buildListWidget() {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.wMin)),
        child: Container(
          alignment: Alignment.center,
          color: AppTheme.cSurfacePrimary,
          child: Stack(
            children: [
              Obx(() {
                List<CourseModuleHoursEntityUnits?> units = controller.detilData.value.units ?? [];
                return CustomScrollView(
                  key: ValueKey(controller.detilData.value.moduleId),
                  controller: controller.scrollController,
                  scrollDirection: Axis.horizontal,
                  slivers: List.generate(units.length, (unitIndex) {
                    List<CourseModuleHoursEntityUnitsLessons?> lessons = units[unitIndex]?.lessons ?? [];
                    if (lessons.isEmpty) return const SliverFillRemaining();
                    CourseModuleHoursEntityUnitsLessons? targetLesson = lessons.first;

                    // 计算之前所有单元的课程总数
                    int previousLessonsCount = 0;
                    for (int i = 0; i < unitIndex; i++) {
                      previousLessonsCount += (units[i]?.lessons?.length ?? 0);
                    }

                    return SliverStickyHeader.builder(
                      builder: (context, state) {
                        return buildTarget(units[unitIndex], targetLesson);
                      },
                      sliver: AnimationLimiter(
                        child: SliverList.builder(
                          itemCount: lessons.length - 1,
                          itemBuilder: (context, itemIndex) {
                            // 当前项在整个二维数组中的索引 = 之前单元的课程总数 + 当前单元中的索引
                            int globalIndex = previousLessonsCount + itemIndex;
                            return buildListItem(context, lessons[itemIndex + 1], units[unitIndex], globalIndex);
                          },
                        ),
                      ),
                    );
                  }),
                );
              }),
              Obx(() {
                if (controller.customCourseModuleId.value == -1 || controller.customCourseModuleId.value != controller.detilData.value.moduleId) return Container();
                return _buildModuleFilterWidget();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListFilterWidget() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20.wMin, sigmaY: 20.wMin),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xff131617).withValues(alpha: 0.2),
        ),
        child: Container(
          padding: EdgeInsets.all(30.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cBgTertiary,
            borderRadius: BorderRadius.circular(25.wMin),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20.wMin),
                  Text(
                    "您有一个未完成的任务",
                    style: TextStyle(
                      fontSize: 32.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 40.wMin),
                  SizedBox(
                    height: 400.wMin,
                    child: AspectRatio(
                      aspectRatio: 198.8 / 280,
                      child: CachedImageWidget(
                        controller.statusEntity.value.currentModule?.coverUrl ?? "",
                        borderRadius: BorderRadius.circular(10.wMin),
                        fadeInDuration: Duration.zero,
                        errorWidget: ClipRRect(
                          borderRadius: BorderRadius.circular(10.wMin),
                          child: Image.asset(
                            "assets/images/custom_course/module_default.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                        placeholder: buildLoadingWidget(),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.wMin),
                  Text(
                    controller.statusEntity.value.currentModule?.name ?? "",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 80.wMin),
                  StepProgressWidget(
                    steps: List.generate(controller.customCourseStatusList.length, (index) {
                      CustomCourseStatusEntityStatusesComments? comments = controller.customCourseStatusList[index].comments?.first;

                      return StepProgressData(
                        step: index + 1,
                        name: controller.customCourseStatusList[index].title ?? "",
                        complete: controller.customCourseStatusList[index].completed ?? false,
                        current: controller.customCourseStatusList[index].current ?? false,
                        subName: comments?.description,
                        buttonText: comments?.title,
                        jump: comments?.jump,
                      );
                    }),
                    onTap: (data) {
                      controller.toCustomCoursePage(data.jump);
                    },
                  ),
                ],
              ),
              Positioned(
                right: 0.wMin,
                top: 0.wMin,
                child: TapScaleWidget(
                  onTap: () {
                    controller.showCustomCourseStatus.value = false;
                    controller.update();
                  },
                  sclae: 1.1,
                  child: SvgPicture.asset(
                    "assets/svg/custom_course/icon_course_back.svg",
                    width: 50.wMin,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleFilterWidget() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20.wMin, sigmaY: 20.wMin),
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xff131617).withValues(alpha: 0.02),
        ),
        child: StepProgressWidget(
          steps: List.generate(controller.customCourseStatusList.length, (index) {
            CustomCourseStatusEntityStatusesComments? comments = controller.customCourseStatusList[index].comments?.first;
            return StepProgressData(
              step: index + 1,
              name: controller.customCourseStatusList[index].title ?? "",
              complete: controller.customCourseStatusList[index].completed ?? false,
              current: controller.customCourseStatusList[index].current ?? false,
              subName: comments?.description,
              buttonText: comments?.title,
              jump: comments?.jump,
            );
          }),
          onTap: (data) {
            controller.toCustomCoursePage(data.jump);
          },
        ),
      ),
    );
  }

  Widget _buildTitleWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24.wMin,
        left: 40.wMin,
        right: 40.wMin,
      ),
      child: Obx(() {
        return Row(
          children: [
            BackWidget(title: controller.detilData.value.courseName),
            const Spacer(),
            controller.isManageCourse.value == true
                ? GestureDetector(
                    onTap: () => controller.toLevel(),
                    child: Container(
                      width: 194.wMin,
                      height: 60.wMin,
                      decoration: BoxDecoration(
                        color: AppTheme.cMemberCardActiveBackground,
                        borderRadius: BorderRadius.circular(30.wMin),
                      ),
                      padding: EdgeInsets.only(left: 30.wMin),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "切换教材",
                            style: TextStyle(
                              fontSize: 24.wMin,
                              color: AppTheme.cTextPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8.wMin),
                          SvgPicture.asset(
                            "assets/svg/public/icon_switch.svg",
                            height: 32.wMin,
                            colorFilter: const ColorFilter.mode(AppTheme.cTextPrimary, BlendMode.srcIn),
                          ),
                        ],
                      ),
                    ),
                  )
                : Visibility(
                    visible: (controller.detilData.value.levelName ?? "") != "",
                    child: TapScaleWidget(
                      sclae: 1.05,
                      onTap: () {
                        controller.toLevel();
                      },
                      child: _buildArrowDownWidget(controller.detilData.value.levelName ?? ""),
                    ),
                  ),
            SizedBox(width: 20.wMin),
            Visibility(
              visible: controller.isManageCourse.value,
              child: GestureDetector(
                onTap: () => controller.editCourse(context),
                child: Container(
                  width: 176.wMin,
                  height: 60.wMin,
                  decoration: BoxDecoration(
                    color: AppTheme.cTextBrand,
                    borderRadius: BorderRadius.circular(30.wMin),
                  ),
                  child: Center(
                    child: Text(
                      "编辑教材",
                      style: TextStyle(
                        fontSize: 28.wMin,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildArrowDownWidget(String text) {
    return Container(
      color: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 32.wMin,
              color: AppTheme.cTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8.wMin),
          SvgPicture.asset(
            "assets/svg/official_course_details/icon_arrow_down.svg",
            height: 24.wMin,
            colorFilter: const ColorFilter.mode(AppTheme.cTextSecondary, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }

  Widget buildTitleBodyWidget() {
    double getProgressPercentage() {
      if (controller.detilData.value.learned) {
        return 1;
      }
      return controller.detilData.value.moduleProgress ?? 0;
    }

    return Container(
      padding: EdgeInsets.only(
        left: 90.wMin,
        right: 90.wMin,
        bottom: 40.wMin,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModuleWidget(),
          SizedBox(height: 12.wMin),
          Row(
            children: [
              buildTitleBodyImageWidget(),
              SizedBox(width: 16.wMin),
              Expanded(
                child: SizedBox(
                  height: 280.wMin,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() {
                        if (controller.detilData.value.courseId == null) return Container();

                        String title = controller.detilData.value.moduleName ?? "名称待确认";

                        if ((controller.detilData.value.units?.length ?? 0) > 0) {
                          title += "·${controller.detilData.value.units?.length ?? 0}个单元";
                        } else {
                          title += "·单元数量待确认";
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 40.wMin,
                                color: AppTheme.cTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 16.wMin),
                            Visibility(
                              visible: controller.detilData.value.moduleDescription != null,
                              child: Text(
                                controller.detilData.value.descriptionTitle ?? "",
                                style: TextStyle(
                                  fontSize: 24.wMin,
                                  color: AppTheme.cTextPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 4.wMin),
                            Text(
                              controller.detilData.value.moduleDescription ?? "",
                              style: TextStyle(
                                fontSize: 24.wMin,
                                color: AppTheme.cTextSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        );
                      }),
                      const Spacer(),
                      Obx(() {
                        if ((controller.detilData.value.lessonCount ?? 0) == 0) return Container();
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "进度",
                              style: TextStyle(
                                fontSize: 28.wMin,
                                color: AppTheme.cTextSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 7.wMin),
                              child: Text(
                                "${(getProgressPercentage() * 100).toStringAsFixed(2)}%",
                                style: TextStyle(
                                  fontSize: 28.wMin,
                                  color: AppTheme.cTextSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      SizedBox(height: 10.wMin),
                      Obx(() {
                        return Visibility(
                          visible: (controller.detilData.value.lessonCount ?? 0) != 0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30.wMin),
                            child: Container(
                              width: double.infinity,
                              height: 14.wMin,
                              color: AppTheme.cBlackAlpha10,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  double maxWidth = constraints.maxWidth;
                                  return Stack(
                                    children: [
                                      AnimatedPositioned(
                                        duration: const Duration(milliseconds: 300),
                                        left: -(maxWidth - (maxWidth * getProgressPercentage())),
                                        width: constraints.maxWidth,
                                        child: Container(
                                          height: 14.wMin,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: AppTheme.cBgBrand,
                                            borderRadius: BorderRadius.circular(30.wMin),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTitleBodyImageWidget() {
    return SizedBox(
      height: 280.wMin,
      child: Obx(() {
        if (controller.detilData.value.specialty == SpecialtyEnum.EN_PHONICS) {
          List<PronunciationsEntity?> pronunciations = controller.detilData.value.moduleContentInfo?.pronunciations ?? [];

          return AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.wMin),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CachedImageWidget(
                    controller.detilData.value.moduleCoverUrl ?? "",
                    placeholder: buildEmptyWidget(),
                    errorWidget: buildEmptyWidget(),
                  ),
                  Container(
                    width: double.infinity,
                    color: AppTheme.cBlackAlpha50.color,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PronunciationsPlayIpaTextWidget(
                          ipa: controller.detilData.value.moduleTopic,
                          pronunciations: pronunciations,
                          national: LanguageServiceCode.US,
                          style: TextStyle(
                            fontSize: 70.wMin,
                            color: AppTheme.cInverseTextLight.color,
                            fontWeight: FontWeight.w700,
                            fontFamily: "AndikaRegular",
                          ),
                        ),
                        PronunciationsColorWidget(
                          content: controller.detilData.value.moduleContentInfo?.content,
                          ipa: controller.detilData.value.moduleTopic,
                          pronunciations: pronunciations,
                          national: LanguageServiceCode.US,
                          style: TextStyle(
                            fontSize: 48.wMin,
                            color: AppTheme.cInverseTextLight.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 36.wMin),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(pronunciations.length, (index) {
                      return PlayLottieIconWidget(
                        size: 48.wMin,
                        audioUrl: pronunciations[index]?.audioUrl,
                        backgroundImageUrl: pronunciations[index]?.nationalIconUrl,
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        }

        return AspectRatio(
          aspectRatio: 198.8 / 280,
          child: CachedImageWidget(
            controller.detilData.value.moduleCoverUrl ?? "",
            borderRadius: BorderRadius.circular(10.wMin),
            fadeInDuration: Duration.zero,
            errorWidget: ClipRRect(
              borderRadius: BorderRadius.circular(10.wMin),
              child: Image.asset(
                "assets/images/custom_course/module_default.png",
                fit: BoxFit.cover,
              ),
            ),
            placeholder: buildLoadingWidget(),
          ),
        );
      }),
    );
  }

  /// 模块tab
  Widget _buildModuleWidget() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(bottom: 12.wMin),
      child: Obx(() {
        int? currentModuleId = controller.detilData.value.moduleId;
        int customModuleId = controller.detilData.value.customModuleId ?? (-1);

        return Row(
          spacing: 12.wMin,
          children: List.generate(controller.moduleList.length, (index) {
            bool isSelect = currentModuleId == controller.moduleList[index].uid;
            String? name = controller.moduleList[index].name ?? "";

            return TapScaleWidget(
              onTap: isSelect
                  ? null
                  : () {
                      controller.switchModule(controller.moduleList[index].uid);
                    },
              sclae: 1.01,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 28.wMin,
                            fontWeight: FontWeight.w600,
                            color: isSelect ? AppTheme.cTextPrimary : AppTheme.cTextSecondary,
                          ),
                        ),
                        SizedBox(height: 2.wMin),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 100),
                          opacity: isSelect ? 1 : 0,
                          child: Container(
                            width: 24.wMin,
                            height: 4.wMin,
                            decoration: BoxDecoration(
                              color: AppTheme.cBgBrand,
                              borderRadius: BorderRadius.circular(99.wMin),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: customModuleId != -1,
                      child: Container(),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  /// 单元目标
  Widget buildTarget(CourseModuleHoursEntityUnits? data, CourseModuleHoursEntityUnitsLessons? unitData) {
    ThemeColorEntity? colors = StyleUtils.getCurrentThemeColors(data?.bgColor);
    LinearGradient? linearGradient = StyleUtils.parseCssLinearGradient(colors?.color);

    return Container(
      width: 430.wMin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.95, 1],
          colors: [
            AppTheme.cSurfacePrimary,
            AppTheme.cSurfacePrimary.withValues(alpha: 0.01),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 100.wMin,
            alignment: Alignment.bottomCenter,
            child: Text(
              data?.unitName ?? "",
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 28.wMin,
                color: (linearGradient?.colors.first ?? AppTheme.cBgBrand).withValues(alpha: 1),
                fontWeight: FontWeight.w500,
                // height: 1.25,
              ),
            ),
          ),
          Container(
            height: 60.wMin,
            alignment: Alignment.center,
            child: Text(
              unitData?.name ?? "",
              style: TextStyle(
                fontSize: 40.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 32.wMin),
          TapScaleWidget(
            onTap: () {
              controller.toTargetPage(data?.unitId);
            },
            sclae: 1.05,
            child: SizedBox(
              width: 240.wMin,
              height: 240.wMin,
              child: ClipOval(
                child: CachedImageWidget(
                  unitData?.coverUrl ?? "",
                  fit: BoxFit.cover,
                  errorWidget: buildEmptyWidget(),
                  placeholder: buildLoadingWidget(),
                ),
              ),
            ),
          ),
          SizedBox(height: 36.wMin),
        ],
      ),
    );
  }

  Widget buildListItem(BuildContext context, CourseModuleHoursEntityUnitsLessons? data, CourseModuleHoursEntityUnits? unit, int animatedIndex) {
    ThemeColorEntity? colors = StyleUtils.getCurrentThemeColors(unit?.bgColor);
    LinearGradient? unitLinearGradient = StyleUtils.parseCssLinearGradient(colors?.color);

    return ListAnimationWidget(
      index: animatedIndex + 1,
      horizontalOffset: 50,
      child: Container(
        width: 360.wMin,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(height: 100.wMin),
            Container(
              height: 60.wMin,
              alignment: Alignment.center,
              child: AutoSizeText(
                data?.name ?? "",
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                minFontSize: 10,
                style: TextStyle(
                  fontSize: 40.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.22,
                ),
              ),
            ),
            SizedBox(height: 32.wMin),
            TapScaleWidget(
              onTap: () {
                controller.getLessonTasks(context, unit?.unitId, data?.uid);
              },
              sclae: 1.05,
              child: Obx(() {
                double progress = data?.progress ?? 0;
                if (data?.learned ?? false) {
                  progress = 1;
                }

                return LessonCircleWidget(
                  isComplete: data?.learned ?? false,
                  progress: progress,
                  showNew: data?.newExercise ?? false,
                  selected: data?.uid == controller.currentLessonId.value,
                  borderColor: (unitLinearGradient?.colors.first ?? AppTheme.cBgBrand).withValues(alpha: 1),
                  showProgess: !(data?.isTest ?? false),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CachedImageWidget(
                      data?.coverUrl ?? "",
                      errorWidget: buildEmptyWidget(),
                      placeholder: buildLoadingWidget(),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 36.wMin),
          ],
        ),
      ),
    );
  }
}
