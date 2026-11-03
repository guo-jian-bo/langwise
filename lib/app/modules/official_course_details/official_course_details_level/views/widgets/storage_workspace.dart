import 'dart:math' as math;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/custom_course/custom_course_manage_grade/controllers/custom_course_manage_grade_controller.dart';
import 'package:langwise/common/entities/course_level_entity.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class StorageWorkspace extends GetView<CustomCourseManageGradeController> {
  static const Duration _cardLongPressDelay = Duration(milliseconds: 350);
  static const Color _accentColor = Color(0xFFF59E0B);
  final String tagText;
  final String updateId;
  final double bottomSafeSpace;

  const StorageWorkspace({
    super.key,
    required this.tagText,
    required this.updateId,
    required this.bottomSafeSpace,
  });

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.wMin,
        20.wMin,
        20.wMin,
        20.wMin,
      ),
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
                  onTap: OptimizeUtils.noneThrottle(() {
                    controller.addGrade();
                  }, 1000),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.wMin),
          Expanded(
            child: GetBuilder<CustomCourseManageGradeController>(
              tag: tagText,
              id: updateId,
              builder: (_) {
                return DragTarget<CourseLevelEntityLevelListModuleList>(
                  onAcceptWithDetails: (details) {
                    controller.moveToTop(details.data, 0);
                  },
                  builder: (context, candidateData, rejectedData) {
                    return SizedBox.expand(
                      child: DottedBorder(
                        color: candidateData.isNotEmpty
                            ? _accentColor
                            : Colors.transparent,
                        strokeWidth: candidateData.isNotEmpty ? 2.wMin : 0,
                        dashPattern: const [5, 3],
                        borderType: BorderType.RRect,
                        radius: Radius.circular(16.wMin),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          padding: EdgeInsets.all(16.wMin),
                          child: controller.topList.isEmpty
                              ? _buildEmptyState()
                              : LayoutBuilder(
                                  builder: (context, constraints) {
                                    final double spacing = 16.wMin;
                                    final double tileWidth =
                                        (constraints.maxWidth - spacing) / 2;
                                    return ScrollConfiguration(
                                      behavior: ScrollConfiguration.of(context)
                                          .copyWith(scrollbars: false),
                                      child: SingleChildScrollView(
                                        padding: EdgeInsets.only(
                                          bottom: bottomSafeSpace),
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
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
      delay: _cardLongPressDelay,
      onDragStarted: () {
        controller.startDrag(itemIndex: index, fromTop: true);
      },
      onDragEnd: (_) => controller.clearDragState(),
      onDraggableCanceled: (_, __) => controller.clearDragState(),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: width,
          child: _buildStorageCoverTile(
            module: module,
            width: width,
            showDragHandle: false,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0,
        child: _buildStorageCoverTile(
          module: module,
          width: width,
          showDragHandle: false,
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
    bool showDragHandle = true,
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
                if (showDragHandle)
                  Positioned(
                    left: 12.wMin,
                    top: 12.wMin,
                    child: _buildDragHandleChip(
                      module: module,
                      width: tileWidth,
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(14.wMin, 12.wMin, 14.wMin, 12.wMin),
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

  Widget _buildDragHandleChip({
    required CourseLevelEntityLevelListModuleList module,
    required double width,
  }) {
    return Draggable<CourseLevelEntityLevelListModuleList>(
      data: module,
      onDragStarted: () {
        final int index = controller.topList.indexOf(module);
        controller.startDrag(itemIndex: index, fromTop: true);
      },
      onDragEnd: (_) => controller.clearDragState(),
      onDraggableCanceled: (_, __) => controller.clearDragState(),
      feedback: Material(
        color: Colors.transparent,
        child: _buildStorageCoverTile(
          module: module,
          width: width,
          showDragHandle: false,
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

  Widget _buildEmptyState() {
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
