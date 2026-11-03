import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/course_level_entity.dart';
import 'package:langwise/common/entities/theme_style_entity.dart';
import 'package:langwise/common/enum/study_zone_enum.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/values/cefr_enum.dart';
import 'package:langwise/common/widgets/back_widget.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/color_utils.dart';
import 'package:langwise/utils/status_utils.dart';
import 'package:langwise/utils/style_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../controllers/custom_course_manage_grade_controller.dart';
import 'custom_course_manage_grade_cell.dart';

class CustomCourseManageGradeView extends GetView<CustomCourseManageGradeController> {
  const CustomCourseManageGradeView({super.key});
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppTheme.cEditBookBackground,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.wMin, vertical: 24.wMin),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BackWidget(
                    title: "编辑教材",
                    onTap: () {
                      controller.back();
                    },
                  ),
                  SizedBox(width: 30.wMin),
                  _topListWidget(),
                  SizedBox(width: 30.wMin),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          controller.addGrade();
                        },
                        child: Container(
                          width: 176.wMin,
                          height: 60.wMin,
                          decoration: BoxDecoration(
                            color: AppTheme.cTextBrand,
                            borderRadius: BorderRadius.circular(30.wMin),
                          ),
                          child: Center(
                            child: Text(
                              "新增年级",
                              style: TextStyle(
                                fontSize: 28.wMin,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.wMin),
                      GestureDetector(
                        onTap: () {
                          controller.sortGrade();
                        },
                        child: Container(
                          width: 176.wMin,
                          height: 60.wMin,
                          decoration: BoxDecoration(
                            color: AppTheme.cMemberCardActiveBackground,
                            borderRadius: BorderRadius.circular(30.wMin),
                          ),
                          child: Center(
                            child: Text(
                              "级别排序",
                              style: TextStyle(
                                fontSize: 28.wMin,
                                color: AppTheme.cTextPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 20.wMin,
              ),
              _bottomListWidget(),
            ],
          ),
        ),
      ),
    );
  }

  _topListWidget() {
    return Expanded(
      child: DottedBorder(
        color: AppTheme.cEditBookDotted,
        strokeWidth: 2.0.wMin,
        dashPattern: const [5, 3],
        borderType: BorderType.RRect,
        radius: Radius.circular(12.0.wMin),
        padding: EdgeInsets.all(20.0.wMin),
        child: SizedBox(
          height: 300.0.wMin,
          child: GetBuilder<CustomCourseManageGradeController>(
            id: 'topScrollWidget',
            builder: (controller) {
              return CustomCourseTopScrollWidget(
                key: const ValueKey('top_scroll_widget'),
                topList: controller.topList,
                scrollController: controller.topScrollController,
                onDragStarted: controller.startDrag,
                onItemDropped: controller.moveToTop,
              );
            },
          ),
        ),
      ),
    );
  }

  _bottomListWidget() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(
          () => controller.gradesList.isEmpty
              ? const SizedBox.shrink()
              : ListView.builder(
                  clipBehavior: Clip.none,
                  controller: controller.gradeScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.gradesList.length,
                  itemBuilder: (context, index) {
                    List<CourseLevelEntityLevelListModuleList?> gradeList = controller.gradesList[index];

                    return Container(
                      clipBehavior: Clip.none,
                      margin: const EdgeInsets.only(right: 40),
                      child: CustomCourseGradeScrollWidget(
                        key: ValueKey('grade_scroll_widget_$index'),
                        gradeList: gradeList,
                        gradeIndex: index,
                        modifyGradeName: controller.modifyGradeName,
                        onDragStarted: controller.startDrag,
                        onItemDropped: controller.moveToGrade,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

//top滚动widget
class CustomCourseTopScrollWidget extends StatefulWidget {
  final List<CourseLevelEntityLevelListModuleList?> topList;
  final ScrollController scrollController;
  final Function({int? gradeIndex, int? itemIndex, bool fromTop}) onDragStarted;
  final Function(CourseLevelEntityLevelListModuleList, int) onItemDropped;

  const CustomCourseTopScrollWidget({
    super.key,
    required this.topList,
    required this.scrollController,
    required this.onDragStarted,
    required this.onItemDropped,
  });

  @override
  State<CustomCourseTopScrollWidget> createState() => _CustomCourseTopScrollWidgetState();
}

class _CustomCourseTopScrollWidgetState extends State<CustomCourseTopScrollWidget> with AutomaticKeepAliveClientMixin {
  
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final controller = Get.find<CustomCourseManageGradeController>();
    double gridSpacing = 10.0.wMin;

    return DragTarget<CourseLevelEntityLevelListModuleList>(
      onAcceptWithDetails: (details) {
        widget.onItemDropped(details.data, widget.topList.length);
      },
      builder: (context, candidateData, rejectedData) {
        return DottedBorder(
          color: candidateData.isNotEmpty ? AppTheme.cBorderBrand : Colors.transparent,
          strokeWidth: candidateData.isNotEmpty ? 2.0.wMin : 0.0,
          dashPattern: const [5, 3],
          borderType: BorderType.RRect,
          radius: Radius.circular(12.0.wMin),
          child: SizedBox(
            width: double.infinity,
            child: widget.topList.isEmpty
                ? _topListEmptyWidget()
                : GridView.builder(
                    key: const PageStorageKey('top_scroll_grid'),
                    controller: widget.scrollController,
                    scrollDirection: Axis.horizontal,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 10 / 7,
                      mainAxisSpacing: gridSpacing,
                    ),
                    itemCount: widget.topList.length,
                    itemBuilder: (context, index) {
                      return DragTarget<CourseLevelEntityLevelListModuleList>(
                        onAcceptWithDetails: (details) {
                          widget.onItemDropped(details.data, index);
                        },
                        builder: (context, candidateData, rejectedData) {
                          CourseLevelEntityLevelListModuleList? wordModel = widget.topList[index];
                          return LongPressDraggable<CourseLevelEntityLevelListModuleList>(
                            data: wordModel,
                            dragAnchorStrategy: (draggable, context, position) {
                              return Offset(100.wMin, 120.wMin);
                            },
                            onDragStarted: () {
                              widget.onDragStarted(
                                itemIndex: index,
                                fromTop: true,
                              );
                            },
                            feedback: Material(
                              color: AppTheme.cBgTertiary,
                              child: CustomCourseManageGradeCell(
                                wordModel: wordModel,
                                isDragging: true,
                                isTop: true,
                                readOnly: true,
                                courseId: controller.courseId,
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: CustomCourseManageGradeCell(
                                wordModel: wordModel,
                                isDragging: false,
                                isTop: true,
                                courseId: controller.courseId,
                              ),
                            ),
                            child: DottedBorder(
                              color: candidateData.isNotEmpty ? AppTheme.cBorderBrand : Colors.transparent,
                              strokeWidth: candidateData.isNotEmpty ? 2.0.wMin : 0.0,
                              dashPattern: const [5, 3],
                              borderType: BorderType.RRect,
                              radius: Radius.circular(8.0.wMin),
                              child: CustomCourseManageGradeCell(
                                key: ValueKey('unit_cell_${wordModel?.moduleId}'),
                                readOnly:true,
                                wordModel: wordModel,
                                isTop: true,
                                courseId: controller.courseId,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  _topListEmptyWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '教材排序暂存区',
          style: TextStyle(
            fontSize: 32.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 20.wMin),
        Text(
          '长按教材可以拖动在年级内或者跨年级排序，\n如果拖动比较远，比如从一年级拖到九年级，可以先从一年级里面拖到这里，\n滑动到九年级之后再拖下去。',
          style: TextStyle(
            fontSize: 28.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

//gradewidget
class CustomCourseGradeScrollWidget extends StatefulWidget {
  final List<CourseLevelEntityLevelListModuleList?> gradeList;
  final int gradeIndex;

  final Function(int) modifyGradeName;
  final Function({int? gradeIndex, int? itemIndex, bool fromTop}) onDragStarted;
  final Function(CourseLevelEntityLevelListModuleList, int, int) onItemDropped;

  const CustomCourseGradeScrollWidget({
    super.key,
    required this.gradeList,
    required this.gradeIndex,
    required this.modifyGradeName,
    required this.onDragStarted,
    required this.onItemDropped,
  });

  @override
  State<CustomCourseGradeScrollWidget> createState() => _CustomCourseGradeScrollWidgetState();
}

class _CustomCourseGradeScrollWidgetState extends State<CustomCourseGradeScrollWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final controller = Get.find<CustomCourseManageGradeController>();

    Color? cefrColor;
    if (UserStore.to.userInfo.value.assessmentTier == null) {
      cefrColor = StatusUtils.getCefrBackgroundColor(controller.courseEntity.value.levelList?[widget.gradeIndex]?.cefr).color2;
    } else {
      cefrColor = StatusUtils.getStudyZoneColor(controller.courseEntity.value.levelList?[widget.gradeIndex]?.studyZone) ?? AppTheme.cTextPrimary.color;
    }

    double nameWidth = 170.wMin;
    if (controller.courseEntity.value.levelList?[widget.gradeIndex]?.cefr == CefrEnum.preA1) {
      nameWidth = 140.wMin;
    }

    return DragTarget<CourseLevelEntityLevelListModuleList>(
      onAcceptWithDetails: (details) {
        widget.onItemDropped(details.data, widget.gradeIndex, widget.gradeList.length);
      },
      builder: (context, candidateData, rejectedData) {
        return DottedBorder(
          color: candidateData.isNotEmpty ? AppTheme.cBorderBrand : Colors.transparent,
          strokeWidth: candidateData.isNotEmpty ? 2.0.wMin : 0.0,
          dashPattern: const [5, 3],
          borderType: BorderType.RRect,
          radius: Radius.circular(12.0.wMin),
          child: Container(
            clipBehavior: Clip.none,
            padding: EdgeInsets.all(20.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cEditBookGradeBackground,
              borderRadius: BorderRadius.circular(12.0.wMin),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Visibility(
                  visible: controller.courseEntity.value.levelList?[widget.gradeIndex]?.studyZone == StudyZoneEnum.study,
                  child: Positioned(
                    left: -20.wMin,
                    top: -45.wMin,
                    child: SizedBox(
                      height: 70.wMin,
                      child: Stack(
                        children: [
                          SvgPicture.asset(
                            "assets/svg/public/icon_tag_flag.svg",
                            height: 70.wMin,
                          ),
                          Positioned(
                            top: 14.wMin,
                            left: 8.wMin,
                            child: Transform.rotate(
                              angle: -0.13,
                              child: Text(
                                "推荐起点",
                                style: TextStyle(
                                  fontSize: 16.wMin,
                                  color: AppTheme.cStaticWhite.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0.wMin,
                  top: 0.wMin,
                  child: GestureDetector(
                    onTap: () {
                      Get.find<CustomCourseManageGradeController>().deleteGrade(widget.gradeIndex);
                    },
                    child: SvgPicture.asset(
                      "assets/svg/public/icon_delete.svg",
                      width: 30.wMin,
                      colorFilter: const ColorFilter.mode(
                        AppTheme.cTextSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GetBuilder<CustomCourseManageGradeController>(
                      builder: (controller) {
                        return Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 8.wMin, right: 8.wMin),
                              decoration: BoxDecoration(
                                color: cefrColor,
                                borderRadius: BorderRadius.circular(8.0.wMin),
                              ),
                              child: Text(
                                'Level ${controller.courseEntity.value.levelList?[widget.gradeIndex]?.tier ?? 0}',
                                style: TextStyle(
                                  fontSize: 20.wMin,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 8.wMin,
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 8.wMin, right: 8.wMin),
                              decoration: BoxDecoration(
                                color: cefrColor,
                                borderRadius: BorderRadius.circular(8.0.wMin),
                              ),
                              child: Text(
                                controller.courseEntity.value.levelList?[widget.gradeIndex]?.cefr ?? '',
                                style: TextStyle(
                                  fontSize: 20.wMin,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 8.wMin,
                            ),
                            GestureDetector(
                              onTap: () {
                                widget.modifyGradeName(widget.gradeIndex);
                              },
                              child: Row(
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: nameWidth),
                                    child: Text(
                                      controller.gradeNameList[widget.gradeIndex]!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 24.wMin,
                                        color: StatusUtils.getStudyZoneColor(controller.courseEntity.value.levelList?[widget.gradeIndex]?.studyZone) ?? AppTheme.cTextPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SvgPicture.asset(
                                    "assets/svg/custom_course/icon_course_modify.svg",
                                    width: 30.wMin,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(
                      height: 15.wMin,
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.gradeList.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(
                                  right: 20.wMin,
                                ),
                                child: DragTarget<CourseLevelEntityLevelListModuleList>(
                                  onAcceptWithDetails: (details) {
                                    widget.onItemDropped(details.data, widget.gradeIndex, index);
                                  },
                                  builder: (context, candidateData, rejectedData) {
                                    CourseLevelEntityLevelListModuleList? wordModel = widget.gradeList[index];

                                    return LongPressDraggable<CourseLevelEntityLevelListModuleList>(
                                      data: wordModel,
                                      dragAnchorStrategy: (draggable, context, position) {
                                        return Offset(100.wMin, 120.wMin);
                                      },
                                      onDragStarted: () {
                                        widget.onDragStarted(
                                          gradeIndex: widget.gradeIndex,
                                          itemIndex: index,
                                          fromTop: false,
                                        );
                                      },
                                      feedback: Material(
                                        color: AppTheme.cBgTertiary,
                                        child: CustomCourseManageGradeCell(
                                          wordModel: wordModel,
                                          isDragging: true,
                                          isTop: true,
                                          courseId: controller.courseId,
                                        ),
                                      ),
                                      childWhenDragging: Opacity(
                                        opacity: 0.3,
                                        child: CustomCourseManageGradeCell(
                                          wordModel: wordModel,
                                          isDragging: false,
                                          isTop: false,
                                          courseId: controller.courseId,
                                        ),
                                      ),
                                      child: DottedBorder(
                                        color: candidateData.isNotEmpty ? AppTheme.cBorderBrand : Colors.transparent,
                                        strokeWidth: candidateData.isNotEmpty ? 2.0.wMin : 0.0,
                                        dashPattern: const [5, 3],
                                        borderType: BorderType.RRect,
                                        radius: Radius.circular(8.0.wMin),
                                        child: CustomCourseManageGradeCell(
                                          key: ValueKey('unit_cell_${wordModel?.moduleId}'),
                                          wordModel: wordModel,
                                          isDragging: false,
                                          isTop: false,
                                          courseId: controller.courseId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              CustomCourseManageGradeController customCourseManageGradeController = Get.find<CustomCourseManageGradeController>();
                              customCourseManageGradeController.addModule(widget.gradeIndex,controller.gradeNameList[widget.gradeIndex]??'',controller.courseEntity.value.levelList?[widget.gradeIndex]);
                            },
                            child: Container(
                              width: 380.wMin,
                              height: 380.wMin * 10 / 7,
                              padding: EdgeInsets.all(10.wMin),
                              decoration: BoxDecoration(
                                color: AppTheme.cEditBookCellBackground,
                                borderRadius: BorderRadius.circular(12.wMin),
                              ),
                              child: Stack(
                                children: [
                                  GetBuilder<CustomCourseManageGradeController>(builder: (controller) {
                                    return Container(
                                      padding: EdgeInsets.all(24.wMin),
                                      child: Wrap(
                                        spacing: 10.wMin,
                                        runSpacing: 10.wMin,
                                        children: List.generate(controller.courseEntity.value.levelList?[widget.gradeIndex]?.tierMappings?.length ?? 0, (index) {
                                          ThemeTextEntity? themeTextEntity = controller.courseEntity.value.levelList?[widget.gradeIndex]?.tierMappings?[index];

                                          ThemeTextStyleEntity? style = StyleUtils.getCurrentThemeText(themeTextEntity?.style);
                                          Color? bgColor = ColorUtils.parseColor(style?.backgroundColor);

                                          return Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8.wMin),
                                              color: bgColor,
                                            ),
                                            child: StyleUtils.getText(themeTextEntity),
                                          );
                                        }),
                                      ),
                                    );
                                  }),
                                  Center(
                                    child: ClipOval(
                                      child: Container(
                                        color: AppTheme.cWhiteAlpha10,
                                        width: 80.wMin,
                                        height: 80.wMin,
                                        child: SvgPicture.asset(
                                          Assets.publicIconAdd,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
