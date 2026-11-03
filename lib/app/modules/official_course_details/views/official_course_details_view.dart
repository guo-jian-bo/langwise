import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/values/values.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../common/widgets/custom_button/LWCircularButton.dart';
import '../../../routes/routes.dart';
import '../../../routes/tag_routes.dart';
import '../bindings/official_course_details_binding.dart';
import '../controllers/official_course_details_controller.dart';
import '../official_course_details_level/controllers/official_course_details_level_controller.dart';

class OfficialCourseDetailsView extends GetView<OfficialCourseDetailsController> {
  final String tagText;
  const OfficialCourseDetailsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => OfficialCourseDetailsView(tagText: tag),
      binding: OfficialCourseDetailsBinding(tagText: tag),
      routeName: Routes.OFFICIAL_COURSE_DETAILS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        backgroundColor: AppTheme.cBgPrimary,
        body: Stack(
          children: [
            Column(
              children: [
                _buildSimpleTitleWidget(context),
                _buildListWidget(context),
              ],
            ),
            Obx(() {
              if (!controller.showCustomCourseStatus.value) return Container();
              return _buildListFilterWidget();
            }),
            Obx(() {
              if (controller.showCustomCourseStatus.value) {
                return const SizedBox.shrink();
              }
              return Positioned(
                bottom: 45.wMin,
                left: 90.wMin,
                right: 90.wMin,
                child: _buildBottomActionBar(context),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildSimpleTitleWidget(BuildContext context) {
    return BreadcrumbWidget(
      onBack: () async {
        await _backToCourseLevel();
      },
      onRouteWithItem: (item) async {
        if (item.route != Routes.OFFICIAL_COURSE_DETAILS_LEVEL) return false;
        await _backToCourseLevel();
        return true;
      },
    );
  }

  Future<void> _backToCourseLevel() async {
    final levelController =
        TagRoutes.findLast<OfficialCourseDetailsLevelController>(
      Routes.OFFICIAL_COURSE_DETAILS_LEVEL,
    );
    if (levelController != null) {
      await levelController.syncManageModeFromDetails(
        targetLevelId: controller.levelId,
        targetModuleId: controller.moduleId,
      );
    }
    final int currentUnitId = controller.activeUnitId.value;
    Get.back(
      result: {
        "courseId": controller.courseId,
        "levelId": controller.levelId,
        "moduleId": controller.moduleId,
        "unitId": currentUnitId > 0 ? currentUnitId : null,
      },
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return Obx(() {
      final showEditButton = controller.isManageCourse.value && controller.fromType != 4;
      return Row(
        children: [
          if (showEditButton)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IgnorePointer(
                  child: Opacity(
                    opacity: 0,
                    child: _buildEditCourseButton(context),
                  ),
                ),
                SizedBox(width: 16.wMin),
              ],
            ),
          Expanded(
            child: Center(
              child: _buildBottomUnitBar(context),
            ),
          ),
          if (showEditButton)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 16.wMin),
                _buildEditCourseButton(context),
              ],
            ),
        ],
      );
    });
  }

  Widget _buildEditCourseButton(BuildContext context) {
    final color = controller.chemeColor.value;
    return TapScaleWidget(
      sclae: 1.05,
      onTap: () {
        controller.editCourse(context);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: PlatformBackdropFilterWidget(
          sigmaX: 10.wMin,
          sigmaY: 10.wMin,
          child: Container(
            height: 64.wMin,
            padding: EdgeInsets.symmetric(horizontal: 18.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: color.withValues(alpha: 0.15),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1.wMin,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              "管理教材",
              style: TextStyle(
                color: color,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListWidget(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        color: AppTheme.cBgPrimary,
        child: Stack(
          children: [
            Obx(() {
              final units = controller.detilData.value.units?.whereType<CourseModuleHoursEntityUnits>().toList() ?? const <CourseModuleHoursEntityUnits>[];
              if (controller.isModuleDataLoading.value) {
                return Center(
                );
              }
              if (units.isEmpty) {
                return Center(
                  child: buildTitleBodyWidget(),
                );
              }
              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ListView.builder(
                  key: ValueKey(controller.detilData.value.moduleId),
                  controller: controller.scrollController,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: EdgeInsets.only(
                    top: 24.wMin,
                    bottom: 140.wMin + (MediaQuery.of(context).size.height * 0.5),
                  ),
                  itemCount: units.length,
                  itemBuilder: (context, unitIndex) {
                    final unit = units[unitIndex];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 40.wMin),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (unitIndex != 0)
                            Container(
                              width: double.infinity,
                              height: 1,
                              color: AppTheme.cBgQuaternary.withValues(alpha: 0.6),
                            ),
                          Padding(
                            padding: EdgeInsets.only(left: 90.wMin, right: 90.wMin, top: unitIndex == 0 ? 0 : 22.wMin),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildUnitSectionHeader(context, unitIndex, unit),
                                SizedBox(height: 18.wMin),
                                _buildUnitLessonsRow(context, unit),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitSectionHeader(BuildContext context, int unitIndex, CourseModuleHoursEntityUnits unit) {
    final lessons = unit.lessons ?? const <CourseModuleHoursEntityUnitsLessons?>[];
    final objectiveLesson = lessons.isNotEmpty ? lessons.first : null;
    final lessonCount = (lessons.length - 1).clamp(0, 1 << 30);
    int completed = 0;
    for (int i = 1; i < lessons.length; i++) {
      final l = lessons[i];
      if (l == null) continue;
      if (l.learned) completed += 1;
    }
    final rawUnitProgress = unit.progress ?? 0;
    final pct = rawUnitProgress <= 0
        ? 0
        : rawUnitProgress <= 1
            ? (rawUnitProgress * 100).round().clamp(0, 100)
            : rawUnitProgress.round().clamp(0, 100);

    ThemeColorEntity? colors = StyleUtils.getCurrentThemeColors(unit.bgColor);
    LinearGradient? unitLinearGradient = StyleUtils.parseCssLinearGradient(colors?.color);
    final accent = (unitLinearGradient?.colors.first ?? AppTheme.cBgBrand).withValues(alpha: 1);

    final buttonWidgets = <Widget>[
      CardLearningButtonsItemWidget(
        title: '情景导入',
        color: const Color(0xff818CF8),
        index: 0,
        onTap: () {
          controller.previewUnit(context, unit.unitId);
        },
      ),
      CardLearningButtonsItemWidget(
        title: '情景认读',
        color: const Color(0xffEC4899),
        index: 1,
        onTap: () {
          controller.flashUnit(context, unit.unitId);
        },
      ),
      CardLearningButtonsItemWidget(
        title: '自拼音标',
        color: const Color(0xff8B5CF6),
        index: 2,
        onTap: () {
          controller.phonicsUnit(context, unit.unitId);
        },
      ),
      CardLearningButtonsItemWidget(
        title: '听写默写',
        color: AppTheme.cSurfaceInfo.color,
        index: 3,
        onTap: () {
          controller.dictationUnit(context, unit.unitId);
        },
      ),
      if(controller.detilData.value.specialty != SpecialtyEnum.EN_PHONICS) CardLearningButtonsItemWidget(
        title: '熏听歌曲',
        color: AppTheme.cSurfaceError,
        index: 4,
        onTap: () {
          controller.playUnitFirstSong(context, unit.unitId);
        },
      ),
      if (unit.isScript == true)
        CardLearningButtonsItemWidget(
          title: '情景剧场',
          color: const Color(0xff14B8A6),
          index: 5,
          onTap: () {
            controller.toUnitScriptList(context, unit);
          },
        ),
      if(controller.detilData.value.specialty != SpecialtyEnum.EN_PHONICS) CardLearningButtonsItemWidget(
        title: '学习探索',
        color: const Color(0xffF59E0B),
        index: unit.isScript == true ? 6 : 5,
        onTap: () {
          controller.exploreUnit(context, unit.unitId);
        },
      ),
    ];

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 72.wMin),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(left: 200.wMin, right: 200.wMin),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < buttonWidgets.length; i++) ...[
                        if (i != 0) SizedBox(width: 14.wMin),
                        buttonWidgets[i],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 320.wMin,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  KeyedSubtree(
                    key: controller.getUnitSectionKey(unitIndex),
                    child: Text(
                      unit.unitName ?? "",
                      style: TextStyle(
                        fontSize: 28.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.wMin),
                  Row(
                    children: [
                      Text(
                        "$completed / $lessonCount 课时",
                        style: TextStyle(
                          fontSize: 20.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 12.wMin),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99.wMin),
                          child: Container(
                            height: 6.wMin,
                            color: AppTheme.cTextPrimary.withValues(alpha: 0.18),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (pct / 100).clamp(0, 1).toDouble(),
                              child: Container(color: AppTheme.cTextPrimary),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.wMin),
                      Text(
                        "$pct%",
                        style: TextStyle(
                          fontSize: 20.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Opacity(
              opacity: objectiveLesson != null ? 1 : 0,
              child: TapScaleWidget(
                onTap: () {
                  controller.toTargetPage(unit.unitId);
                },
                child: Container(
                  height: 64.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 20.wMin),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999.wMin),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "单元目标",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4.wMin),
                      Icon(
                        Icons.chevron_right,
                        size: 24.wMin,
                        color: accent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitLessonsRow(BuildContext context, CourseModuleHoursEntityUnits unit) {
    final lessons = unit.lessons ?? const <CourseModuleHoursEntityUnitsLessons?>[];
    if (lessons.length <= 1) return const SizedBox.shrink();
    final list = lessons.sublist(1).whereType<CourseModuleHoursEntityUnitsLessons>().toList();
    if (list.isEmpty) return const SizedBox.shrink();

    ThemeColorEntity? colors = StyleUtils.getCurrentThemeColors(unit.bgColor);
    LinearGradient? unitLinearGradient = StyleUtils.parseCssLinearGradient(colors?.color);
    final accent = (unitLinearGradient?.colors.first ?? AppTheme.cBgBrand).withValues(alpha: 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 6.wMin,
        mainAxisSpacing: 10.wMin,
        mainAxisExtent: 360.wMin,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final l = list[index];
        return _buildLessonCircleItem(
          context: context,
          unitId: unit.unitId,
          lesson: l,
          borderColor: accent,
        );
      },
    );
  }

  Widget _buildLessonCircleItem({
    required BuildContext context,
    required int? unitId,
    required CourseModuleHoursEntityUnitsLessons lesson,
    required Color borderColor,
  }) {
    final isActive = lesson.uid == controller.detilData.value.lessonId;
    double progress = lesson.progress ?? 0;
    if (lesson.learned) {
      progress = 1;
    }
    final showProgress = !(lesson.isTest);
    final timeText = _formatEstimatedTime(lesson.estimatedTime);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final circleSize = (maxW * 0.98).clamp(120.wMin, 220.wMin).toDouble();
        return Column(
          children: [
            TapScaleWidget(
              sclae: 1,
              onTap: () {
                controller.getLessonTasks(context, unitId, lesson.uid);
              },
              child: SizedBox(
                width: circleSize,
                height: circleSize,
                child: LessonCircleWidget(
                  size: circleSize,
                  innerSize: circleSize * 0.92,
                  continuousProgress: true,
                  isComplete: lesson.learned,
                  progress: progress,
                  showNew: lesson.newExercise ?? false,
                  selected: isActive,
                  borderColor: borderColor,
                  showProgess: showProgress,
                  child: _LazyVisibilityImage(
                    visibilityKey: 'lesson_${lesson.uid}_${lesson.coverUrl ?? ''}',
                    imageBuilder: () => _buildCachedNetworkImage(
                      lesson.coverUrl ?? "",
                      fit: BoxFit.cover,
                      errorWidget: buildEmptyWidget(),
                      placeholder: buildLoadingWidget(),
                    ),
                    placeholder: buildLoadingWidget(),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.wMin),
            Text(
              lesson.name ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.wMin),
            Text(
              timeText ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23.wMin,
                color: AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 8.wMin),
            TapScaleWidget(
              onTap: () async {
                if (unitId == null) return;
                if (lesson.uid == null) return;
                await TagRoutes.toNamed(
                  Routes.OFFICIAL_COURSE_DETAILS_LESSON_QUIZ_LIST,
                  arguments: {
                    "parentTagText": tagText,
                    "unitId": unitId,
                    "lessonId": lesson.uid!,
                    "title": lesson.name ?? "题目列表",
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 8.wMin),
                decoration: BoxDecoration(
                  color: AppTheme.cBorderPrimary.color.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999.wMin),
                  border: Border.all(color: AppTheme.cSurfaceQuaternary.color.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "题目列表",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: 6.wMin),
                    Icon(Icons.chevron_right, size: 18.wMin, color: AppTheme.cTextPrimary.color),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String? _formatEstimatedTime(int? estimatedTime) {
    if (estimatedTime == null) return null;
    if (estimatedTime <= 0) return null;
    if (estimatedTime < 60) return "$estimatedTime sec";
    final minutes = (estimatedTime / 60).ceil();
    return "$minutes min";
  }

  Widget _buildBottomUnitBar(BuildContext context) {
    return Obx(() {
      final units = controller.detilData.value.units?.whereType<CourseModuleHoursEntityUnits>().toList() ?? const <CourseModuleHoursEntityUnits>[];
      if (units.isEmpty) return const SizedBox.shrink();
      final activeId = controller.activeUnitId.value;

      return Center(
        child: ClipRRect(
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
                  key: controller.unitTabViewportKey,
                  controller: controller.unitTabScrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(units.length, (i) {
                      final u = units[i];
                      final id = u.unitId ?? -1;
                      final isActive = id == activeId;
                      final text = u.unitName ?? "Unit ${i + 1}";

                      return Padding(
                        padding: EdgeInsets.only(right: i == units.length - 1 ? 0 : 12.wMin),
                        child: LWCircularButtonWidget(
                          key: controller.getUnitTabKey(i),
                          text: text,
                          isAction: isActive,
                          color: controller.chemeColor.value,
                          sclae: 1.02,
                          onTap: () {
                            controller.scrollToUnitIndex(i, unitId: u.unitId);
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildListFilterWidget() {
    return PlatformBackdropFilterWidget(
      sigmaX: 20.wMin,
      sigmaY: 20.wMin,
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
                      child: _buildCachedNetworkImage(
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
    return Positioned.fill(
        child: ClipRRect(
      child: PlatformBackdropFilterWidget(
          sigmaX: 20.wMin,
          sigmaY: 20.wMin,
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
          )),
    ));
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
          // _buildModuleWidget(),
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
                  _buildCachedNetworkImage(
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
                        national: pronunciations[index]?.national,
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
          child: _buildCachedNetworkImage(
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
  Widget buildTarget(BuildContext context, CourseModuleHoursEntityUnits? data, CourseModuleHoursEntityUnitsLessons? unitData) {
    ThemeColorEntity? colors = StyleUtils.getCurrentThemeColors(data?.bgColor);
    LinearGradient? linearGradient = StyleUtils.parseCssLinearGradient(colors?.color);

    return Container(
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
          SizedBox(height: 12.wMin),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 12.wMin,
            children: [
              TapScaleWidget(
                onTap: () {
                  controller.quickStartForUnit(context, data?.unitId);
                },
                sclae: 1.05,
                child: Container(
                  height: 48.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 18.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfaceSecondary.color,
                    borderRadius: BorderRadius.circular(99.wMin),
                    border: Border.all(color: AppTheme.cBorderSecondary.color),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "一键开始",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              TapScaleWidget(
                onTap: () {
                  controller.toTargetPage(data?.unitId);
                },
                sclae: 1.05,
                child: Container(
                  height: 48.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 18.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfaceSecondary.color,
                    borderRadius: BorderRadius.circular(99.wMin),
                    border: Border.all(color: AppTheme.cBorderSecondary.color),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "查看知识点",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
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
                child: _buildCachedNetworkImage(
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
        width: double.infinity,
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
              sclae: 1,
              child: Obx(() {
                double progress = data?.progress ?? 0;
                if (data?.learned ?? false) {
                  progress = 1;
                }

                return LessonCircleWidget(
                  isComplete: data?.learned ?? false,
                  progress: progress,
                  showNew: data?.newExercise ?? false,
                  selected: data?.uid == controller.detilData.value.lessonId,
                  borderColor: (unitLinearGradient?.colors.first ?? AppTheme.cBgBrand).withValues(alpha: 1),
                  showProgess: !(data?.isTest ?? false),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _buildCachedNetworkImage(
                      data?.coverUrl ?? "",
                      errorWidget: buildEmptyWidget(),
                      placeholder: buildLoadingWidget(),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 8.wMin),
            Builder(builder: (_) {
              bool isTest = data?.isTest ?? false;
              bool isNew = data?.newExercise ?? false;
              bool learned = data?.learned ?? false;
              double p = data?.progress ?? 0;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8.wMin,
                children: [
                  Visibility(
                    visible: isTest,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                      decoration: BoxDecoration(
                        color: AppTheme.cFeedbackInfoBackground.color,
                        borderRadius: BorderRadius.circular(8.wMin),
                      ),
                      child: Text(
                        "测试",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: AppTheme.cFeedbackInfoText.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isNew,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                      decoration: BoxDecoration(
                        color: AppTheme.cFeedbackWarningBackground.color,
                        borderRadius: BorderRadius.circular(8.wMin),
                      ),
                      child: Text(
                        "新",
                        style: TextStyle(
                          fontSize: 18.wMin,
                          color: AppTheme.cFeedbackWarningText.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                    decoration: BoxDecoration(
                      color: learned ? AppTheme.cFeedbackSuccessBackground.color : AppTheme.cSurfaceTertiary.color,
                      borderRadius: BorderRadius.circular(8.wMin),
                    ),
                    child: Text(
                      learned ? "已完成" : (p > 0 ? "进行中 ${(p * 100).toStringAsFixed(0)}%" : "未开始"),
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: learned ? AppTheme.cFeedbackSuccessText.color : AppTheme.cTextTertiary.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: 24.wMin),
          ],
        ),
      ),
    );
  }
}

class _LazyVisibilityImage extends StatefulWidget {
  final String visibilityKey;
  final Widget Function() imageBuilder;
  final Widget placeholder;

  const _LazyVisibilityImage({
    required this.visibilityKey,
    required this.imageBuilder,
    required this.placeholder,
  });

  @override
  State<_LazyVisibilityImage> createState() => _LazyVisibilityImageState();
}

Widget _buildCachedNetworkImage(
  String imageUrl, {
  BoxFit fit = BoxFit.cover,
  BorderRadiusGeometry? borderRadius,
  Duration fadeInDuration = Duration.zero,
  Widget? placeholder,
  Widget? errorWidget,
}) {
  return CachedImageWidget(
    imageUrl,
    fit: fit,
    borderRadius: borderRadius,
    fadeInDuration: fadeInDuration,
    placeholder: placeholder ?? const SizedBox.shrink(),
    errorWidget: errorWidget ?? const SizedBox.shrink(),
  );
}

class _LazyVisibilityImageState extends State<_LazyVisibilityImage> {
  bool _shouldLoad = false;
  late final String _instanceVisibilityKey;

  @override
  void initState() {
    super.initState();
    _instanceVisibilityKey = '${widget.visibilityKey}_${identityHashCode(this)}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _shouldLoad) return;
      _tryLoadIfInViewport();
    });
  }

  void _tryLoadIfInViewport() {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached || !renderObject.hasSize) {
      return;
    }
    final Offset topLeft = renderObject.localToGlobal(Offset.zero);
    final Rect widgetRect = topLeft & renderObject.size;
    final Rect viewportRect = Offset.zero & MediaQuery.sizeOf(context);
    if (!widgetRect.overlaps(viewportRect)) return;
    setState(() {
      _shouldLoad = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey(_instanceVisibilityKey),
      onVisibilityChanged: (info) {
        if (_shouldLoad || info.visibleFraction <= 0) return;
        if (!mounted) return;
        setState(() {
          _shouldLoad = true;
        });
      },
      child: _shouldLoad ? widget.imageBuilder() : widget.placeholder,
    );
  }
}
