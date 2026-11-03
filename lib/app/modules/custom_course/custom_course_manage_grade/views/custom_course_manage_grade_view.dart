import 'dart:math' as math;
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/common/widgets/custom_button/LWCircularButton.dart';
import 'package:langwise/common/entities/course_level_entity.dart';
import 'package:langwise/common/enum/study_zone_enum.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/status_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../bindings/custom_course_manage_grade_binding.dart';
import '../controllers/custom_course_manage_grade_controller.dart';
import 'custom_course_manage_grade_cell.dart';

class CustomCourseManageGradeView extends GetView<CustomCourseManageGradeController> {
  final String tagText;

  const CustomCourseManageGradeView({super.key, required this.tagText});

  static const String _storageUpdateId = 'topScrollWidget';

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => CustomCourseManageGradeView(tagText: tag),
      binding: CustomCourseManageGradeBinding(tagText: tag),
      routeName: Routes.CUSTOM_COURSE_MANAGE_GRADE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  double get _panelSpacing => 24.wMin;
  double get _levelSectionGap => 26.wMin;
  double get _moduleHeaderGap => 12.wMin;
  double get _moduleGridSpacing => 18.wMin;

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
              BreadcrumbWidget(
                onBack: controller.back,
                actionWidget: _buildActionButton(
                  title: '完成管理',
                  width: 176.wMin,
                  onTap: controller.back,
                ),
              ),
              SizedBox(height: 24.wMin),
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 125.wMin),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildLevelWorkspace(),
                          ),
                          SizedBox(width: _panelSpacing),
                          Expanded(
                            flex: 1,
                            child: _buildStorageWorkspace(),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 5.wMin,
                      right: 5.wMin,
                      bottom: 20.wMin,
                      child: _buildBottomLevelBar(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelWorkspace() {
    return GetBuilder<CustomCourseManageGradeController>(
      tag: tagText,
      id: 'gradeWorkspace',
      builder: (_) {
        final List<CourseLevelEntityLevelList?> levels =
            controller.courseEntity.value.levelList ?? <CourseLevelEntityLevelList?>[];
        if (levels.isEmpty) {
          return _buildNoGradePlaceholder();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final double cardWidth =
                (constraints.maxWidth - _moduleGridSpacing) / 2;

            return ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                controller: controller.gradeScrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsets.only(
                  right: 8.wMin,
                  bottom: 400.wMin,
                ),
                child: Column(
                  children: List.generate(levels.length, (index) {
                    final CourseLevelEntityLevelList? level = levels[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == levels.length - 1 ? 0 : _levelSectionGap,
                      ),
                      child: _buildLevelSection(
                        level: level,
                        gradeIndex: index,
                        cardWidth: cardWidth,
                      ),
                    );
                  }),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLevelSection({
    required CourseLevelEntityLevelList? level,
    required int gradeIndex,
    required double cardWidth,
  }) {
    final List<CourseLevelEntityLevelListModuleList?> modules =
        controller.gradesList.length > gradeIndex ? controller.gradesList[gradeIndex] : <CourseLevelEntityLevelListModuleList?>[];
    final int totalCount = modules.length + 1;
    final int rowCount = math.max(1, (totalCount / 2).ceil());
    final String moduleSignature =
        modules.map((item) => item?.moduleId?.toString() ?? 'null').join('_');

    final Key? sectionKey = level?.levelId != null
        ? controller.levelSectionKeys[level!.levelId!]
        : ValueKey('level_${gradeIndex}_$moduleSignature');

    return Column(
      key: sectionKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLevelHeader(level: level, gradeIndex: gradeIndex),
        SizedBox(height: _moduleHeaderGap),
        Column(
          children: List.generate(rowCount, (rowIndex) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: rowIndex == rowCount - 1 ? 0 : _moduleGridSpacing,
              ),
              child: LayoutBuilder(
                builder: (context, rowConstraints) {
                  final double rowCardWidth = (rowConstraints.maxWidth - _moduleGridSpacing) / 2;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(3, (slotIndex) {
                      if (slotIndex == 1) {
                        return SizedBox(width: _moduleGridSpacing);
                      }
                      final int columnIndex = slotIndex ~/ 2;
                      final int overallIndex = rowIndex * 2 + columnIndex;
                      if (overallIndex >= totalCount) {
                        return Expanded(child: SizedBox(width: rowCardWidth));
                      }
                      if (overallIndex == modules.length) {
                        return Expanded(
                          child: _buildAddModuleCard(
                            gradeIndex: gradeIndex,
                            level: level,
                            insertIndex: modules.length,
                            cardWidth: rowCardWidth,
                          ),
                        );
                      }
                      return Expanded(
                        child: _buildGradeCard(
                          module: modules[overallIndex],
                          gradeIndex: gradeIndex,
                          moduleIndex: overallIndex,
                          cardWidth: rowCardWidth,
                        ),
                      );
                    }),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLevelHeader({
    required CourseLevelEntityLevelList? level,
    required int gradeIndex,
  }) {
    final bool isRecommended = level?.studyZone == StudyZoneEnum.study;
    final Color titleColor = StatusUtils.getStudyZoneColor(level?.studyZone) ?? AppTheme.cTextPrimary.color;
    final int? levelId = level?.levelId;

    return SizedBox(
      key: levelId == null ? null : controller.getLevelHeaderKey(levelId),
      height: controller.moduleHeaderHeight,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                if (isRecommended) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.wMin,
                      vertical: 4.wMin,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.cFeedbackInfoBackground.color,
                      borderRadius: BorderRadius.circular(999.wMin),
                    ),
                    child: Text(
                      '推荐起点',
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextBrand.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.wMin),
                ],
                Expanded(
                  child: Text(
                    level?.name ?? '未命名年级',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 32.wMin,
                      color: titleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.wMin),
          _buildHeaderPill(
            title: '重命名',
            onTap: () => controller.modifyGradeName(gradeIndex),
          ),
          SizedBox(width: 8.wMin),
          _buildHeaderPill(
            title: '删除',
            danger: true,
            onTap: () => controller.deleteGrade(gradeIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPill({
    required String title,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.wMin,
        padding: EdgeInsets.symmetric(horizontal: 14.wMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: danger
              ? AppTheme.cFeedbackErrorText.color.withValues(alpha: 0.1)
              : AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.wMin),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18.wMin,
            color: danger ? AppTheme.cFeedbackErrorText.color : AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStorageWorkspace() {
    return Container(
      padding: EdgeInsets.all(20.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cEditBookGradeBackground,
        borderRadius: BorderRadius.circular(20.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '教材排序暂存区',
            style: TextStyle(
              fontSize: 30.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.wMin),
          Text(
            '拖进来暂存后，可再拖回任意 Level 的教材旁边。',
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 16.wMin),
          Expanded(
            child: GetBuilder<CustomCourseManageGradeController>(
              tag: tagText,
              id: _storageUpdateId,
              builder: (_) {
                return DragTarget<CourseLevelEntityLevelListModuleList>(
                  onAcceptWithDetails: (details) {
                    controller.moveToTop(details.data, 0);
                  },
                  builder: (context, candidateData, rejectedData) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.all(16.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.wMin),
                        border: Border.all(
                          color: candidateData.isNotEmpty
                              ? AppTheme.cBorderBrand.color
                              : Colors.transparent,
                          width: candidateData.isNotEmpty ? 2.wMin : 0,
                        ),
                      ),
                      child: controller.topList.isEmpty
                          ? _buildStorageEmptyState()
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final double spacing = 16.wMin;
                                final double tileWidth =
                                    (constraints.maxWidth - spacing) / 2;
                                return ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context)
                                      .copyWith(scrollbars: false),
                                  child: SingleChildScrollView(
                                    controller: controller.topScrollController,
                                    child: Wrap(
                                      spacing: spacing,
                                      runSpacing: spacing,
                                      children: List.generate(
                                        controller.topList.length,
                                        (index) => SizedBox(
                                          width: tileWidth,
                                          child: _buildStorageCard(
                                            module: controller.topList[index],
                                            index: index,
                                            width: tileWidth,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 16.wMin),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  title: '级别排序',
                  onTap: controller.sortGrade,
                ),
              ),
              SizedBox(width: 12.wMin),
              Expanded(
                child: _buildActionButton(
                  title: '新增年级',
                  onTap: controller.addGrade,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoGradePlaceholder() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cEditBookGradeBackground,
        borderRadius: BorderRadius.circular(20.wMin),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '还没有可管理的年级',
            style: TextStyle(
              fontSize: 32.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.wMin),
          Text(
            '先新增一个年级，再把教材拖进对应 Level 里。',
            style: TextStyle(
              fontSize: 22.wMin,
              color: AppTheme.cTextSecondary,
            ),
          ),
          SizedBox(height: 24.wMin),
          _buildActionButton(
            title: '新增年级',
            width: 180.wMin,
            onTap: controller.addGrade,
          ),
        ],
      ),
    );
  }

  Widget _buildGradeCard({
    required CourseLevelEntityLevelListModuleList? module,
    required int gradeIndex,
    required int moduleIndex,
    required double cardWidth,
  }) {
    if (module == null) {
      return KeyedSubtree(
        key: ValueKey('grade_empty_${gradeIndex}_$moduleIndex'),
        child: CustomCourseManageGradeCell(
          wordModel: null,
          isTop: false,
          courseId: controller.courseId,
          tagText: tagText,
          width: cardWidth,
        ),
      );
    }

    return KeyedSubtree(
      key: ValueKey('grade_card_${gradeIndex}_${module.moduleId}_$moduleIndex'),
      child: DragTarget<CourseLevelEntityLevelListModuleList>(
        onAcceptWithDetails: (details) {
          controller.moveToGrade(details.data, gradeIndex, moduleIndex);
        },
        builder: (context, candidateData, rejectedData) {
          return DottedBorder(
            color: candidateData.isNotEmpty ? AppTheme.cBorderBrand : Colors.transparent,
            strokeWidth: candidateData.isNotEmpty ? 2.wMin : 0,
            dashPattern: const [5, 3],
            borderType: BorderType.RRect,
            radius: Radius.circular(20.wMin),
            child: LongPressDraggable<CourseLevelEntityLevelListModuleList>(
              data: module,
              onDragStarted: () {
                controller.startDrag(
                  gradeIndex: gradeIndex,
                  itemIndex: moduleIndex,
                  fromTop: false,
                );
              },
              feedback: Material(
                color: Colors.transparent,
                child: CustomCourseManageGradeCell(
                  wordModel: module,
                  isTop: false,
                  courseId: controller.courseId,
                  tagText: tagText,
                  width: cardWidth,
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0,
                child: SizedBox(
                  width: cardWidth,
                  height: 354.wMin,
                ),
              ),
              child: CustomCourseManageGradeCell(
                key: ValueKey('grade_${gradeIndex}_${module.moduleId}'),
                wordModel: module,
                isTop: false,
                courseId: controller.courseId,
                tagText: tagText,
                width: cardWidth,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStorageCard({
    required CourseLevelEntityLevelListModuleList? module,
    required int index,
    required double width,
  }) {
    if (module == null) {
      return const SizedBox.shrink();
    }

    return LongPressDraggable<CourseLevelEntityLevelListModuleList>(
      data: module,
      onDragStarted: () {
        controller.startDrag(itemIndex: index, fromTop: true);
      },
      feedback: Material(
        color: Colors.transparent,
        child: _buildStorageCoverTile(
          module: module,
          width: math.min(220.wMin, width),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0,
        child: SizedBox(
          width: math.min(220.wMin, width),
          height: math.min(220.wMin, width) * 246 / 220,
        ),
      ),
      child: _buildStorageCoverTile(
        key: ValueKey('top_${module.moduleId}'),
        module: module,
        width: width,
      ),
    );
  }

  Widget _buildStorageCoverTile({
    Key? key,
    required CourseLevelEntityLevelListModuleList module,
    required double width,
  }) {
    final double tileWidth = math.min(220.wMin, width);
    final double tileHeight = tileWidth * 246 / 220;

    return Center(
      child: SizedBox(
        key: key,
        width: tileWidth,
        height: tileHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.wMin),
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceLayerBase.color,
              borderRadius: BorderRadius.circular(20.wMin),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: module.coverUrl?.isNotEmpty == true
                      ? CachedImageWidget(
                          module.coverUrl!,
                          fit: BoxFit.cover,
                          placeholder: buildLoadingWidget(),
                          errorWidget: buildEmptyWidget(),
                        )
                      : buildEmptyWidget(),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding:
                        EdgeInsets.fromLTRB(14.wMin, 12.wMin, 14.wMin, 12.wMin),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.72),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      module.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: Colors.white,
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
    );
  }

  Widget _buildAddModuleCard({
    required int gradeIndex,
    required CourseLevelEntityLevelList? level,
    required int insertIndex,
    required double cardWidth,
  }) {
    final double cardHeight = 354.wMin;

    return DragTarget<CourseLevelEntityLevelListModuleList>(
      onAcceptWithDetails: (details) {
        controller.moveToGrade(details.data, gradeIndex, insertIndex);
      },
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: () {
            controller.addModule(
              gradeIndex,
              controller.gradeNameList[gradeIndex] ?? '',
              level,
            );
          },
          child: DottedBorder(
            color: candidateData.isNotEmpty ? AppTheme.cBorderBrand : Colors.transparent,
            strokeWidth: candidateData.isNotEmpty ? 2.wMin : 0,
            dashPattern: const [6, 4],
            borderType: BorderType.RRect,
            radius: Radius.circular(20.wMin),
            child: Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                color: AppTheme.cSurfaceLayerElevated.color,
                border: Border.all(
                  color: AppTheme.cBorderSecondary.color,
                  width: 1.wMin,
                ),
                borderRadius: BorderRadius.circular(20.wMin),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.wMin),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 92.wMin,
                      height: 92.wMin,
                      decoration: BoxDecoration(
                        color: AppTheme.cWhiteAlpha10,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(22.wMin),
                      child: SvgPicture.asset(
                        Assets.publicIconAdd,
                        colorFilter: ColorFilter.mode(
                          AppTheme.cTextBrand.color,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Text('添加教材', style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextPrimary, fontWeight: FontWeight.w600),),
                    SizedBox(height: 12.wMin),
                    Text('拖入教材，或为这个 Level 预留一个新的书位。',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: AppTheme.cTextSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStorageEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.wMin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '先拖几本教材进来',
              style: TextStyle(
                fontSize: 28.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.wMin),
            Text(
              '这里适合做跨年级调序的中转站。\n左侧拖进来后，再拖回任意 Level 旁边。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required VoidCallback onTap,
    double? width,
    bool danger = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 40.wMin,
        decoration: BoxDecoration(
          color: danger
              ? AppTheme.cFeedbackErrorText.color.withValues(alpha: 0.1)
              : AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.wMin),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18.wMin,
              color: danger
                  ? AppTheme.cFeedbackErrorText.color
                  : AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomLevelBar(BuildContext context) {
    return Obx(() {
      final List<CourseLevelEntityLevelList?> levels = controller.courseEntity.value.levelList ?? <CourseLevelEntityLevelList?>[];
      if (levels.isEmpty) return const SizedBox.shrink();
      final int currentActiveLevelId = controller.activeLevelId.value;
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999.wMin),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.wMin, sigmaY: 4.wMin),
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
                  key: controller.levelTabViewportKey,
                  controller: controller.levelTabScrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(levels.length, (index) {
                      final CourseLevelEntityLevelList? item = levels[index];
                      final String text = item?.name ?? 'Level ${index + 1}';
                      final bool isActive = item?.levelId == currentActiveLevelId;
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == levels.length - 1 ? 0 : 12.wMin,
                        ),
                        child: LWCircularButtonWidget(
                          key: item?.levelId == null ? null : controller.getLevelTabKey(item!.levelId!),
                          text: text,
                          isAction: isActive,
                          color: AppTheme.cLevelA2Text,
                          onTap: () {
                            final int? levelId = item?.levelId;
                            if (levelId == null) {
                              controller.selectGrade(index);
                              return;
                            }
                            controller.scrollToLevel(levelId);
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
}
