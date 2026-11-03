import 'dart:math' as math;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/custom_course/custom_course_manage_grade/controllers/custom_course_manage_grade_controller.dart';
import 'package:langwise/common/entities/course_level_entity.dart';
import 'package:langwise/common/enum/study_zone_enum.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/status_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'cards/manage_module_card.dart';
import 'storage_workspace.dart';

class ManageSection extends GetView<CustomCourseManageGradeController> {
  static const Duration _cardLongPressDelay = Duration(milliseconds: 350);
  static const Color _accentColor = Color(0xFFF59E0B);
  final String tagText;
  final double bottomPadding;

  const ManageSection({
    super.key,
    required this.tagText,
    required this.bottomPadding,
  });

  static const String _storageUpdateId = 'topScrollWidget';

  @override
  String? get tag => tagText;

  double get _panelSpacing => _moduleGridSpacing;
  double get _levelSectionGap => 26.wMin;
  double get _moduleHeaderGap => 8.wMin;
  double get _moduleGridSpacing => 18.wMin;
  double get _bottomSafeSpace => bottomPadding;
  double get _storageBottomInset => 145.wMin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(90.wMin, 16.wMin, 90.wMin, 0),
      child: LayoutBuilder(
        builder: (context, contentConstraints) {
          final itemWidth =
              (contentConstraints.maxWidth - _moduleGridSpacing - _panelSpacing) / 3;
          final levelWorkspaceWidth = (itemWidth * 2) + _moduleGridSpacing;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: levelWorkspaceWidth,
                child: _buildLevelWorkspace(),
              ),
              SizedBox(width: _panelSpacing),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: _storageBottomInset),
                  child: StorageWorkspace(
                    tagText: tagText,
                    updateId: _storageUpdateId,
                    bottomSafeSpace: _bottomSafeSpace,
                  ),
                ),
              ),
            ],
          );
        },
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
                padding: EdgeInsets.only(bottom: _bottomSafeSpace),
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
        controller.gradesList.length > gradeIndex
            ? controller.gradesList[gradeIndex]
            : <CourseLevelEntityLevelListModuleList?>[];
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(3, (slotIndex) {
                  if (slotIndex == 1) {
                    return SizedBox(width: _moduleGridSpacing);
                  }
                  final int columnIndex = slotIndex ~/ 2;
                  final int overallIndex = rowIndex * 2 + columnIndex;
                  if (overallIndex >= totalCount) {
                    return SizedBox(width: cardWidth);
                  }
                  if (overallIndex == modules.length) {
                    return SizedBox(
                      width: cardWidth,
                      child: _buildAddModuleCard(
                        gradeIndex: gradeIndex,
                        level: level,
                        insertIndex: modules.length,
                        cardWidth: cardWidth,
                      ),
                    );
                  }
                  return SizedBox(
                    width: cardWidth,
                    child: _buildGradeCard(
                      module: modules[overallIndex],
                      gradeIndex: gradeIndex,
                      moduleIndex: overallIndex,
                      cardWidth: cardWidth,
                    ),
                  );
                }),
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
    final Color titleColor =
        StatusUtils.getStudyZoneColor(level?.studyZone) ?? AppTheme.cTextPrimary.color;
    final int? levelId = level?.levelId;
    final bool canDeleteLevel = controller.canDeleteGrade(gradeIndex);

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
                      color: _accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999.wMin),
                      border: Border.all(
                        color: _accentColor.withValues(alpha: 0.2),
                        width: 1.wMin,
                      ),
                    ),
                    child: Text(
                      '推荐起点',
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: _accentColor,
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
            disabled: !canDeleteLevel,
            onTap: () => controller.tryDeleteGrade(gradeIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPill({
    required String title,
    required VoidCallback onTap,
    bool danger = false,
    bool disabled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.wMin,
        padding: EdgeInsets.symmetric(horizontal: 14.wMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: disabled
              ? AppTheme.cTextDisabled.color.withValues(alpha: 0.08)
              : danger
                  ? AppTheme.cFeedbackErrorText.color.withValues(alpha: 0.1)
                  : AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.wMin),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18.wMin,
            color: disabled
                ? AppTheme.cTextDisabled
                : danger
                    ? AppTheme.cFeedbackErrorText.color
                    : AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w500,
          ),
        ),
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
        child: ManageModuleCard(
          module: null,
          isTop: false,
          courseId: controller.courseId,
          tagText: tagText,
          width: cardWidth,
          enableCoverNavigation: false,
        ),
      );
    }

    final bool isDragging = controller.isDraggingItem(
      gradeIndex: gradeIndex,
      itemIndex: moduleIndex,
      fromTop: false,
    );

    return KeyedSubtree(
      key: controller.getModuleCardKey(module.moduleId!),
      child: DragTarget<CourseLevelEntityLevelListModuleList>(
        onAcceptWithDetails: (details) {
          controller.moveToGrade(details.data, gradeIndex, moduleIndex);
        },
        builder: (context, candidateData, rejectedData) {
          return DottedBorder(
            color: candidateData.isNotEmpty ? _accentColor : Colors.transparent,
            strokeWidth: candidateData.isNotEmpty ? 2.wMin : 0,
            dashPattern: const [5, 3],
            borderType: BorderType.RRect,
            radius: Radius.circular(20.wMin),
            child: Opacity(
              opacity: isDragging ? 0 : 1,
              child: LongPressDraggable<CourseLevelEntityLevelListModuleList>(
                data: module,
                delay: _cardLongPressDelay,
                onDragStarted: () {
                  controller.startDrag(
                    gradeIndex: gradeIndex,
                    itemIndex: moduleIndex,
                    fromTop: false,
                  );
                },
                onDragEnd: (_) => controller.clearDragState(),
                onDraggableCanceled: (_, __) => controller.clearDragState(),
                feedback: Material(
                  color: Colors.transparent,
                  child: ManageModuleCard(
                    module: module,
                    isTop: false,
                    courseId: controller.courseId,
                    tagText: tagText,
                    width: cardWidth,
                    enableCoverNavigation: false,
                    dragHandle: _buildDragHandleLabel(active: true),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0,
                  child: ManageModuleCard(
                    module: module,
                    isTop: false,
                    courseId: controller.courseId,
                    tagText: tagText,
                    width: cardWidth,
                    enableCoverNavigation: false,
                    dragHandle: _buildDragHandleLabel(active: true),
                  ),
                ),
                child: ManageModuleCard(
                  key: ValueKey('grade_${gradeIndex}_${module.moduleId}'),
                  module: module,
                  isTop: false,
                  courseId: controller.courseId,
                  tagText: tagText,
                  width: cardWidth,
                  enableCoverNavigation: false,
                  dragHandle: _buildDragHandle(
                    module: module,
                    cardWidth: cardWidth,
                    onDragStarted: () {
                      controller.startDrag(
                        gradeIndex: gradeIndex,
                        itemIndex: moduleIndex,
                        fromTop: false,
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDragHandle({
    required CourseLevelEntityLevelListModuleList module,
    required double cardWidth,
    required VoidCallback onDragStarted,
  }) {
    return Draggable<CourseLevelEntityLevelListModuleList>(
      data: module,
      onDragStarted: onDragStarted,
      onDragEnd: (_) => controller.clearDragState(),
      onDraggableCanceled: (_, __) => controller.clearDragState(),
      feedback: Material(
        color: Colors.transparent,
        child: ManageModuleCard(
          module: module,
          isTop: false,
          courseId: controller.courseId,
          tagText: tagText,
          width: cardWidth,
          enableCoverNavigation: false,
          dragHandle: _buildDragHandleLabel(active: true),
        ),
      ),
      childWhenDragging: _buildDragHandleLabel(active: true),
      child: _buildDragHandleLabel(),
    );
  }

  Widget _buildDragHandleLabel({bool active = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 6.wMin),
      decoration: BoxDecoration(
        color: active
            ? Colors.black.withValues(alpha: 0.6)
            : Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8.wMin),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cBlackAlpha20,
            blurRadius: 8.wMin,
            offset: Offset(0, 4.wMin),
          ),
        ],
      ),
      child: Text(
        '拖动排序',
        style: TextStyle(
          fontSize: 20.wMin,
          color: Colors.white.withValues(alpha: 0.8),
          fontWeight: FontWeight.w500,
          height: 1,
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
            color: candidateData.isNotEmpty ? _accentColor : Colors.transparent,
            strokeWidth: candidateData.isNotEmpty ? 2.wMin : 0,
            dashPattern: const [6, 4],
            borderType: BorderType.RRect,
            radius: Radius.circular(20.wMin),
            child: Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                color: AppTheme.cSurfaceLayerBase2,
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
                        color: _accentColor.withValues(alpha: 0.12),
                        border: Border.all(
                          color: _accentColor.withValues(alpha: 0.20),
                        ),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(22.wMin),
                      child: SvgPicture.asset(
                        Assets.publicIconAdd,
                        colorFilter: ColorFilter.mode(
                          _accentColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Text(
                      '添加教材',
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: _accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.wMin),
                    Text(
                      '拖入教材，或为这个 Level 预留一个新的书位。',
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

  Widget _buildActionButton({
    required String title,
    required VoidCallback onTap,
    double? width,
    bool danger = false,
  }) {
    final backgroundColor = danger
        ? AppTheme.cFeedbackErrorText.color.withValues(alpha: 0.1)
        : AppTheme.cSurfaceLayerElevated.color.withValues(alpha: 0.28);
    final textColor = danger ? AppTheme.cFeedbackErrorText.color : _accentColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 48.wMin,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.wMin),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22.wMin,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
