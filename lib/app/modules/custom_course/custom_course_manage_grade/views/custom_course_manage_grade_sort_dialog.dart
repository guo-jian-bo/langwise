import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/course_level_entity.dart';
import 'package:langwise/theme/theme.dart';
import 'package:reorderables/reorderables.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../custom_course_manage_grade_sort/controllers/custom_course_manage_grade_sort_controller.dart';

class CustomCourseManageGradeSortDialog extends StatelessWidget {
  final CustomCourseManageGradeSortController controller;
  final bool showFooter;
  final VoidCallback? onClose;
  final Future<void> Function()? onSave;

  const CustomCourseManageGradeSortDialog({
    super.key,
    required this.controller,
    this.showFooter = true,
    this.onClose,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    const int columns = 4;
    final double spacing = 12.wMin;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '级别排序',
          style: TextStyle(
            fontSize: 32.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.wMin),
        Text(
          '拖拽卡片调整教材级别顺序',
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 10.wMin),
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double itemWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Obx(() {
                final int itemCount = controller.levelList.length;
                final int rowCount = itemCount == 0 ? 0 : ((itemCount - 1) ~/ columns) + 1;
                final double itemHeight = 122.wMin;
                final double gridHeight = rowCount == 0
                    ? 0
                    : rowCount * itemHeight + (rowCount - 1) * spacing;
                return SizedBox(
                  height: gridHeight,
                  child: ReorderableWrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    buildDraggableFeedback: (
                      BuildContext feedbackContext,
                      BoxConstraints feedbackConstraints,
                      Widget child,
                    ) {
                      return Material(
                        color: Colors.transparent,
                        child: ConstrainedBox(
                          constraints: BoxConstraints.tightFor(
                            width: itemWidth,
                            height: itemHeight,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.wMin),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.cStaticBlack.withValues(alpha: 0.18),
                                  blurRadius: 16.wMin,
                                  offset: Offset(0, 8.wMin),
                                ),
                              ],
                            ),
                            child: child,
                          ),
                        ),
                      );
                    },
                    children: controller.levelList
                        .map((e) => _buildItem(e, itemWidth, itemHeight))
                        .toList(),
                    onReorder: (int oldIndex, int newIndex) {
                      controller.swap(oldIndex, newIndex);
                    },
                  ),
                );
              });
            },
          ),
        ),
        if (showFooter) ...[
          SizedBox(height: 20.wMin),
          Divider(
            height: 1,
            thickness: 1,
            color: AppTheme.cBorderSecondary.withValues(alpha: 0.35),
          ),
          SizedBox(height: 20.wMin),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildFooterButton(
                title: '取消',
                isPrimary: false,
                onTap: onClose ?? () => Get.back(),
              ),
              SizedBox(width: 12.wMin),
              Obx(() {
                return _buildFooterButton(
                  title: '保存排序',
                  isPrimary: true,
                  enabled: controller.hasChanges.value && !controller.isSaving.value,
                  onTap: () async {
                    if (onSave != null) {
                      await onSave!();
                      return;
                    }
                    final bool success = await controller.saveSort();
                    if (success) {
                      Get.back(result: true);
                    }
                  },
                );
              }),
            ],
          ),
        ],
      ],
    );
  }

  static Widget _buildItem(
    CourseLevelEntityLevelList? item,
    double width,
    double height,
  ) {
    String moduleCount;
    if (item?.moduleList?.isNotEmpty ?? false) {
      moduleCount = '${item?.moduleList?.length ?? 0}本教材';
    } else {
      moduleCount = "暂无教材";
    }
    final String tierText = item?.tierMappings?.firstOrNull?.text?.trim().isNotEmpty == true
        ? item!.tierMappings!.first!.text!.trim()
        : (item?.tier?.toString() ?? 'A1');

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.fromLTRB(
        12.wMin,
        10.wMin,
        12.wMin,
        10.wMin,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceLayerElevated,
        borderRadius: BorderRadius.circular(16.wMin),
        border: Border.all(
          color: AppTheme.cBorderSecondary.withValues(alpha: 0.36),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.wMin,
                  vertical: 4.wMin,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.cBgTertiary.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(7.wMin),
                ),
                child: Text(
                  item?.name ?? 'Level',
                  style: TextStyle(
                    fontSize: 13.wMin,
                    color: AppTheme.cTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.wMin,
                  vertical: 4.wMin,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.cBgTertiary.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(7.wMin),
                ),
                child: Text(
                  '拖动排序',
                  style: TextStyle(
                    fontSize: 13.wMin,
                    color: AppTheme.cTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.wMin),
          Text(
            item?.name ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.wMin),
          Text(
            '$tierText · $moduleCount',
            style: TextStyle(
              fontSize: 15.wMin,
              color: AppTheme.cTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildFooterButton({
    required String title,
    required bool isPrimary,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    final Color backgroundColor = isPrimary
        ? (enabled ? const Color(0xFFF6A609) : const Color(0x66F6A609))
        : AppTheme.cBgTertiary.withValues(alpha: 0.78);
    final Color textColor = isPrimary ? AppTheme.cStaticWhite : AppTheme.cTextPrimary;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 128.wMin,
        height: 46.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10.wMin),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 24.wMin,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
