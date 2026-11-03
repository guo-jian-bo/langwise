import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/theme/theme.dart';
import 'package:reorderables/reorderables.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ManageAllCoursesLevelSortDialog extends StatefulWidget {
  final List<LevelResponseEntity> initialLevelList;
  final Future<bool> Function(List<LevelResponseEntity> sortedLevelList) onSave;

  const ManageAllCoursesLevelSortDialog({
    super.key,
    required this.initialLevelList,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required List<LevelResponseEntity> initialLevelList,
    required Future<bool> Function(List<LevelResponseEntity> sortedLevelList) onSave,
  }) async {
    await Get.dialog<void>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: 72.wMin,
          vertical: 80.wMin,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 1360.wMin,
          ),
          child: ManageAllCoursesLevelSortDialog(
            initialLevelList: initialLevelList,
            onSave: onSave,
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  State<ManageAllCoursesLevelSortDialog> createState() => _ManageAllCoursesLevelSortDialogState();
}

class _ManageAllCoursesLevelSortDialogState extends State<ManageAllCoursesLevelSortDialog> {
  late final List<LevelResponseEntity> _levelList;
  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _levelList = [...widget.initialLevelList];
  }

  @override
  Widget build(BuildContext context) {
    const int columns = 4;
    final double spacing = 12.wMin;
    return Container(
      height: 800.wMin,
      padding: EdgeInsets.fromLTRB(
        28.wMin,
        24.wMin,
        28.wMin,
        22.wMin,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cEditBookGradeBackground,
        borderRadius: BorderRadius.circular(22.wMin),
        border: Border.all(
          color: AppTheme.cBorderSecondary.withValues(alpha: 0.28),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cStaticBlack.withValues(alpha: 0.24),
            blurRadius: 22.wMin,
            offset: Offset(0, 10.wMin),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 4.wMin,
              right: 18.wMin,
            ),
            child: Column(
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
                  '拖拽卡片调整课程级别顺序',
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
                      final int itemCount = _levelList.length;
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
                          onReorder: _onReorder,
                          children: _levelList
                              .map((item) => _buildItem(item, itemWidth, itemHeight))
                              .toList(),
                        ),
                      );
                    },
                  ),
                ),
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
                      onTap: () => Get.back(),
                    ),
                    SizedBox(width: 12.wMin),
                    _buildFooterButton(
                      title: '保存排序',
                      isPrimary: true,
                      enabled: _hasChanges && !_isSaving,
                      onTap: _onSave,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 44.wMin,
                height: 44.wMin,
                decoration: BoxDecoration(
                  color: AppTheme.cBgTertiary.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 22.wMin,
                  color: AppTheme.cTextSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _levelList.length) return;
    if (newIndex < 0 || newIndex >= _levelList.length) return;
    setState(() {
      final LevelResponseEntity item = _levelList.removeAt(oldIndex);
      _levelList.insert(newIndex, item);
      _hasChanges = true;
    });
  }

  Future<void> _onSave() async {
    if (!_hasChanges || _isSaving) return;
    setState(() {
      _isSaving = true;
    });
    final bool success = await widget.onSave([..._levelList]);
    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });
    if (success) {
      Get.back();
    }
  }

  Widget _buildItem(
    LevelResponseEntity item,
    double width,
    double height,
  ) {
    final int moduleCount = (item.moduleDTOList?.length ?? item.moduleList?.length ?? 0);
    final String moduleCountText = moduleCount > 0 ? '$moduleCount个模块' : '暂无模块';
    final String tierText = item.tier?.toString() ?? '-';
    return Container(
      key: ValueKey('level_sort_${item.uid}'),
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
                  item.name ?? 'Level',
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
            item.name ?? '',
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
            '$tierText · $moduleCountText',
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

  Widget _buildFooterButton({
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
        width: 148.wMin,
        height: 52.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.wMin),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20.wMin,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
