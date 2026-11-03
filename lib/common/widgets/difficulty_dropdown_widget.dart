import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:collection/collection.dart';

import '../../theme/theme.dart';

/// 难度等级下拉选择组件
///
/// 该组件专门用于显示和选择难度等级，UI样式与设计图保持一致
/// 支持显示难度等级列表，选中状态标识，以及回调处理
class DifficultyDropdownWidget extends StatefulWidget {
  /// 当前选中的难度等级索引
  final int? selectedIndex;

  /// 难度等级列表
  final List<DifficultieEntity> difficulties;

  /// 选择回调函数，返回选中的索引和难度等级对象
  final Function(int index, DifficultieEntity difficulty)? onSelected;

  /// 占位符文本
  final String placeholder;

  const DifficultyDropdownWidget({
    super.key,
    this.selectedIndex,
    required this.difficulties,
    this.onSelected,
    this.placeholder = '选择难度水平',
  });

  @override
  State<DifficultyDropdownWidget> createState() => _DifficultyDropdownWidgetState();
}

class _DifficultyDropdownWidgetState extends State<DifficultyDropdownWidget> {
  final GlobalKey _dropdownKey = GlobalKey();
  bool _isMenuOpen = false;

  /// 显示下拉菜单
  void _showDropdownMenu() {
    if (widget.difficulties.isEmpty || _isMenuOpen) return;

    _isMenuOpen = true;

    showCupertinoDialog<String?>(
        context: context,
        builder: (BuildContext context) {
          return SelectDifficultyDialogWidget(
            difficulties: widget.difficulties,
            selectedIndex: widget.selectedIndex,
            onSelected: widget.onSelected,
          );
        }).then((value) {
      _isMenuOpen = false;
    });
  }

  /// 关闭下拉菜单
  void _closeDropdownMenu() {
    _isMenuOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前选中的难度等级文本
    final displayText = widget.selectedIndex != null && widget.selectedIndex! < widget.difficulties.length
        ? widget.difficulties[widget.selectedIndex!].name?.text ?? widget.placeholder
        : widget.placeholder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "难度水平",
          style: TextStyle(
            fontSize: 28.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.wMin),
        TapScaleWidget(
          key: _dropdownKey,
          onTap: _showDropdownMenu,
          sclae: 1.02,
          child: Container(
            height: 64.wMin,
            padding: EdgeInsets.symmetric(horizontal: 24.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.wMin),
              color: AppTheme.cBgTertiary,
              border: Border.all(
                width: 1.wMin,
                color: AppTheme.cBorderPrimary,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 左侧内容（图标 + 文本）
                // AppTheme.cTextTertiary : AppTheme.cTextDisabled : AppTheme.cTextPrimary
                // 显示文本
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 右侧下拉箭头
                Container(
                  padding: EdgeInsets.only(left: 12.wMin),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 28.wMin,
                    color: AppTheme.cTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _closeDropdownMenu();
    super.dispose();
  }
}

class SelectDifficultyDialogWidget extends StatefulWidget {
  /// 当前选中的难度等级索引
  final int? selectedIndex;

  /// 难度等级列表
  final List<DifficultieEntity> difficulties;

  /// 选择回调函数，返回选中的索引和难度等级对象
  final Function(int index, DifficultieEntity difficulty)? onSelected;

  const SelectDifficultyDialogWidget({super.key, this.selectedIndex, required this.difficulties, this.onSelected});

  @override
  State<SelectDifficultyDialogWidget> createState() => _SelectDifficultyDialogWidgetState();
}

class _SelectDifficultyDialogWidgetState extends State<SelectDifficultyDialogWidget> with SafeSetStateMixin {
  int? _hoverIndex;

  /// 当前选中的难度等级索引
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return CardDialogBoxWidget(
      title: "选择难度水平",
      onCancel: () => Get.back(),
      onConfirm: () {
        if (ObjectUtil.isEmpty(selectedIndex)) {
          return;
        }
        widget.onSelected?.call(selectedIndex!, widget.difficulties[selectedIndex!]);
        Navigator.of(context).pop();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.wMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Gaps.getHeight(40.wMin),
            // 难度选项列表
            ...widget.difficulties.mapIndexed((index, difficulty) {
              final isSelected = index == selectedIndex;
              final isHovered = index == _hoverIndex;
              return MouseRegion(
                onEnter: (_) => safeSetState(() => _hoverIndex = index),
                onExit: (_) => safeSetState(() => _hoverIndex = null),
                child: _buildDifficultyItem(
                  difficulty: difficulty,
                  isSelected: isSelected,
                  isHovered: isHovered,
                  onTap: () {
                    safeSetState(() {
                      selectedIndex = index;
                    });
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// 构建单个难度选项
  Widget _buildDifficultyItem(
      {required DifficultieEntity difficulty,
      required bool isSelected,
      required VoidCallback onTap,
      required bool isHovered}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 16.wMin,
          vertical: 12.wMin,
        ),
        decoration: BoxDecoration(
          color: isHovered ? AppTheme.cBgHover : (isSelected ? AppTheme.cBgActive : Colors.transparent),
          borderRadius: BorderRadius.circular(4.ww),
        ),
        margin: EdgeInsets.symmetric(horizontal: 4.ww, vertical: 2.wh),
        child: Row(
          children: [
            // 难度等级文本
            Expanded(
              child: Text(
                "${difficulty.name?.text??''}",
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: isSelected || isHovered ? AppTheme.cTextBrand : AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            SizedBox(
              width: 24.ww,
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: AppTheme.cTextBrand,
                      size: 24.ww,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
