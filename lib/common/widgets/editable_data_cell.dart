/*
 * EditTableTextCell - 表格可编辑文本单元格组件
 * 
 * 功能：
 * 1. 交互式表格单元格编辑，支持点击和键盘操作
 * 2. 单击高亮，再次点击进入编辑，符合直觉操作
 * 3. 全局单一高亮监控，保证同一时间只有一个单元格处于高亮状态
 * 4. 多行文本支持，自动换行显示和编辑
 * 5. Enter 键提交数据，ESC 键取消编辑或高亮
 * 6. 智能点击响应，点击表格其他位置自动清除高亮状态
 * 
 * 优点：
 * 1. 代码量少，设计简洁，使用方便
 * 2. 自适应布局，在高亮状态下充满整列，非高亮状态下保持边距
 * 3. 全方位交互监测，点击外部、ESC 键、Enter 键均有相应处理
 * 4. 使用 TapRegion 检测单元格外部点击，自动清除高亮状态
 * 5. 利用 AutoSizeTextField 的 onTapOutside 回调，点击外部自动提交编辑内容
 * 6. 由于全局状态管理，避免了多单元格同时高亮的混乱现象
 * 7. 与 Langwise 应用中所有表格风格一致，维持统一的视觉设计
 * 8. 使用自动缩放文本控件，文本始终清晰可见
 * 9. 支持自定义行数，可根据不同列内容需求调整
 * 
 * 使用示例：
 * ```dart
 * DataCell(
 *   EditTableTextCell(
 *     initialValue: dessert.description ?? '',
 *     maxLines: 3,
 *     onValueChanged: (String newValue) {
 *       controller.onEditItem(dessert, newDescription: newValue);
 *     },
 *   ),
 * ),
 * ```
 * 
 * 适用场景：
 * 1. 管理页面的表格中需要内联编辑的列（名称、描述等）
 * 2. 用户需要频繁编辑少量文本的场景
 * 3. 应用于 ManageLevelPage、ManageModulePage、ManageLessonTemplatePage 等多个管理页面
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';

class EditTableTextCell extends StatefulWidget {
  final bool readOnly;
  final String initialValue;
  final ValueChanged<String>? onValueChanged;
  final int maxLines;

  const EditTableTextCell({
    Key? key,
    required this.initialValue,
    this.readOnly = false,
    this.onValueChanged,
    this.maxLines = 3,
  }) : super(key: key);

  @override
  _EditTableTextCellState createState() => _EditTableTextCellState();
}

// 全局单例管理类，管理所有单元格的高亮状态
class EditTableTextCellManager {
  static _EditTableTextCellState? _activeCell;

  static void setActiveCell(_EditTableTextCellState cell) {
    // 如果有其他激活的单元格，先清除其高亮状态
    if (_activeCell != null && _activeCell != cell) {
      _activeCell!.clearHighlight();
    }
    _activeCell = cell;
  }

  static void clearActiveCell(_EditTableTextCellState cell) {
    if (_activeCell == cell) {
      _activeCell = null;
    }
  }
}

class _EditTableTextCellState extends State<EditTableTextCell> with SafeSetStateMixin {
  late String _currentValue;
  bool _isEditing = false;
  bool _isHighlighted = false;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _controller = TextEditingController(text: _currentValue);
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      if (_isEditing) {
        _submitValue(_controller.text);
      }
      // 当失去焦点时移除高亮并通知管理器
      safeSetState(() {
        _isHighlighted = false;
      });
      EditTableTextCellManager.clearActiveCell(this);
    }
  }

  // 取消编辑，不提交数据
  void _cancelEditing() {
    safeSetState(() {
      _isEditing = false;
      // 不更新 _currentValue，恢复原始值
      _controller.text = _currentValue;
      // 清除高亮状态
      _isHighlighted = false;
    });

    EditTableTextCellManager.clearActiveCell(this);
  }

  // 清除高亮状态
  void clearHighlight() {
    if (_isHighlighted || _isEditing) {
      safeSetState(() {
        _isHighlighted = false;
        _isEditing = false;
      });
    }
  }

  void _handleTap() {
    if (widget.readOnly) {
      return;
    }

    // 设置当前单元格为激活状态
    EditTableTextCellManager.setActiveCell(this);

    if (_isHighlighted) {
      // 已经高亮，切换到编辑模式，但保持高亮状态
      safeSetState(() {
        _isEditing = true;
        _controller.text = _currentValue;
      });

      // 确保在第二次点击时获得焦点
      Future.microtask(() => _focusNode.requestFocus());
    } else {
      // 首次点击，进入高亮状态
      safeSetState(() {
        _isHighlighted = true;
      });
    }
  }

  void _submitValue(String value) {
    safeSetState(() {
      _isEditing = false;
      _isHighlighted = false;  // 同时清除高亮状态
      _currentValue = value;
    });
    widget.onValueChanged?.call(value);
    EditTableTextCellManager.clearActiveCell(this);  // 通知管理器清除激活单元格
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      // 当点击单元格外部区域时，清除高亮状态
      onTapOutside: (PointerDownEvent event) {
        if (_isHighlighted && !_isEditing) {
          clearHighlight();
        }
      },
      child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (KeyEvent event) {
            // 检测 ESC 键按下
            if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
              if (_isEditing) {
                // 如果在编辑模式，取消编辑
                _cancelEditing();
              } else if (_isHighlighted) {
                // 如果只是高亮状态，取消高亮
                clearHighlight();
              }
            }
          },
          child: GestureDetector(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                border: (_isHighlighted || _isEditing)
                    ? Border.all(color: const Color(0xff2388FF), width: 1.wMin)
                    : null,
                borderRadius: (_isHighlighted || _isEditing) ? BorderRadius.circular(2.wMin) : null,
              ),
              // 在非高亮状态下添加边距，保持与 DataGeneralColumnWidget 一致
              padding: (_isHighlighted || _isEditing)
                  ? EdgeInsets.symmetric(horizontal: 8.ww)
                  : EdgeInsets.only(left: 24.ww, right: 24.ww),
              alignment: Alignment.centerLeft,
              child: _isEditing
                  ? AutoSizeTextField(
                      controller: _controller,
                      autofocus: true,
                      focusNode: _focusNode,
                      maxLines: widget.maxLines,
                      cursorColor: const Color(0xff2388FF),
                      // 使用固定值
                      minFontSize: 18,
                      // 确保步进粒度为整数
                      stepGranularity: 1.0,
                      textAlign: TextAlign.left,
                      keyboardType: TextInputType.multiline,
                      // 使用 Enter 键提交数据
                      textInputAction: TextInputAction.done,
                      onSubmitted: _submitValue,
                      onTapOutside: (PointerDownEvent event) {
                        // 点击输入框外部时提交数据
                        _submitValue(_controller.text);
                      },
                      style: TextStyle(
                        color: const Color(0xffEBEEF3),
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        // important 用于编辑框对齐
                        border: InputBorder.none,
                        hintText: '',
                        hintStyle: TextStyle(
                            fontSize: 18.wMin,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFACB4C0),
                            textBaseline: TextBaseline.alphabetic),
                      ),
                    )
                  : Text(
                      _currentValue,
                      style: TextStyle(
                        color: const Color(0xffEBEEF3),
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                      ),
                      softWrap: true,
                      maxLines: widget.maxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            onTap: _handleTap,
          )),
    );
  }

  @override
  void didUpdateWidget(covariant EditTableTextCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _currentValue = widget.initialValue;
    }
  }

  @override
  void dispose() {
    // 在组件销毁时清除对当前单元格的引用
    EditTableTextCellManager.clearActiveCell(this);
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }
}
