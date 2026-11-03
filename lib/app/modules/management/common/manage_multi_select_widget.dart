/// ManageMultiSelectWidget 多选选择器组件
///
/// 功能特色：
/// 1. 实时过滤搜索
///    - 输入文本时立即过滤显示匹配选项
///    - 搜索结果按选中状态排序（未选中的在前，已选中的在后）
///    - 使用防抖（debounce）技术避免频繁更新
///
/// 2. 智能的选择机制
///    - 点击选项后保持蒙层打开，允许连续选择
///    - 选中选项后输入框自动清空，方便继续搜索
///    - 已选中的选项显示对勾标记
///    - 按Enter键可选择第一个未选中的选项，或取消第一个已选中的选项
///
/// 3. 自动滚动到最新标签
///    - 使用ScrollController控制水平滚动
///    - 每次添加新标签后自动滚动到末尾
///    - 延迟执行确保布局完成后再滚动
///
/// 4. 删除键快捷操作
///    - 支持使用键盘删除键快速移除最后一个选中标签
///    - 在输入框为空时生效，确保用户可以连续删除标签
///
/// 5. 预设选中项支持
///    - 可通过selectedValues参数初始化已选中的标签
///    - 自动过滤无效选项，确保数据完整性
///
/// 6. 状态同步
///    - 删除标签时同步更新蒙层中选项的选中状态
///    - 点击外部区域关闭蒙层
///    - 在各种操作后保持UI状态一致
///
/// 7. 蒙层更新优化
///    - 使用SchedulerBinding.instance.addPostFrameCallback延迟蒙层更新
///    - 解决在构建阶段更新蒙层导致的「This Overlay widget cannot be marked as needing to build」错误
///    - 在didUpdateWidget周期中安全地处理蒙层状态变化
///    - 确保在组件仍然挂载(mounted)时才更新蒙层

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:quiz_play/utils/utils.dart';

// 导入标签组件
import 'tag_item.dart';

/// 多选选择器组件
class ManageMultiSelectWidget extends StatefulWidget {
  final String? title;
  final List<String>? selectedValues;
  final String? hintText;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final bool required;
  final bool readOnly;
  final void Function()? onTap;
  final void Function(List<int> indexes)? onChanged;
  final List<String> options;

  const ManageMultiSelectWidget({
    super.key,
    this.title,
    this.selectedValues,
    this.hintText,
    this.width,
    this.height,
    this.backgroundColor,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.required = false,
    required this.options,
  });

  @override
  State<ManageMultiSelectWidget> createState() => _ManageMultiSelectWidgetState();
}

class _ManageMultiSelectWidgetState extends State<ManageMultiSelectWidget> with SafeSetStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  // 添加水平滚动控制器用于自动滚动到末尾
  final ScrollController _horizontalScrollController = ScrollController();

  final List<int> _selectedIndexes = [];
  bool _isOverlayVisible = false;
  final GlobalKey _overlayKey = GlobalKey();
  final GlobalKey _selectKey = GlobalKey();

  final double _overlayMinHeight = 80.wh, _overlayMaxHeight = 280.wh;
  final List<String> _options = [];
  List<String> _filteredOptions = []; // 添加过滤后的选项列表

  @override
  void initState() {
    super.initState();
    _options
      ..clear()
      ..addAll(widget.options);

    // 初始化时过滤列表与原始列表相同
    _filteredOptions = List.from(_options);

    // 初始化已选中的选项
    if (widget.selectedValues != null && widget.selectedValues!.isNotEmpty) {
      for (final value in widget.selectedValues!) {
        // 查找每个值在options中的索引
        final index = _options.indexOf(value);
        // 只添加有效的索引（避免添加-1）
        if (index >= 0) {
          _selectedIndexes.add(index);
        }
      }

      // 初始化后延迟滚动到末尾标签
      if (_selectedIndexes.isNotEmpty) {
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          _scrollToLastTag();
        });
      }
    }

    _focusNode.addListener(() {
      if (widget.readOnly) {
        return;
      }
      if (!_focusNode.hasFocus) {
        _removeOverlay();
      }
      safeSetState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (KeyEvent event) {
          // 监听删除键按下事件
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              _textController.text.isEmpty &&
              _selectedIndexes.isNotEmpty &&
              _focusNode.hasFocus) {
            // 获取最后一个选中的标签索引
            final lastIndex = _selectedIndexes.last;

            // 从选中列表中移除该标签
            _selectedIndexes.remove(lastIndex);

            // 滚动到标签末尾
            _scrollToLastTag();

            // 更新UI并同步蒙层状态
            safeSetState(() {
              if (_isOverlayVisible) {
                _filteredOptions = List.from(_options);
                _updateOverlay(); // 重建蒙层以更新选中状态
              }
            });

            // 回调给业务层
            if (widget.onChanged != null) {
              widget.onChanged!(_selectedIndexes);
            }
          }
        },
        child: GestureDetector(
          onTap: OptimizeUtils.noneThrottle(() {
            if (widget.readOnly) {
              return;
            }
            print("点击输入框外部容器");
            widget.onTap?.call();
            _filteredOptions = _options;
            _focusNode.requestFocus();
            _updateOverlay();
            safeSetState(() {});
          }, 100),
          child: CompositedTransformTarget(
            link: _layerLink,
            child: Container(
              key: _selectKey,
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.wMin),
                color: widget.backgroundColor ?? Colors.transparent,
                border: Border.all(
                  width: 1.wMin,
                  color: _focusNode.hasFocus ? const Color(0xff2388FF) : const Color(0xff4B5268),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.ww),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title ?? "",
                    style: TextStyle(
                        fontSize: 16.wMin,
                        color: const Color.fromRGBO(255, 255, 255, 0.4),
                        fontWeight: FontWeight.w400,
                        height: 1.0),
                  ),
                  if (widget.required)
                    Text(
                      ' *',
                      style: TextStyle(
                        fontSize: 14.wMin,
                        color: const Color(0xffFF4D4F),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // 间距
                        if (_selectedIndexes.isNotEmpty) Gaps.getWidth(10.ww),
                        // 标签水平滚动容器 - 没有标签时不占空间
                        if (_selectedIndexes.isNotEmpty)
                          Expanded(
                            flex: 4,
                            child: SingleChildScrollView(
                              controller: _horizontalScrollController, // 添加滚动控制器
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ..._selectedIndexes.map(
                                    (index) => TagItem(
                                      index: index,
                                      value: _options[index],
                                      readOnly: widget.readOnly,
                                      onDelete: (tagIndex) {
                                        if (widget.readOnly) return;

                                        // 从选中列表中移除标签对应的选项
                                        _selectedIndexes.remove(tagIndex);

                                        // 滚动到末尾权柟
                                        _scrollToLastTag();

                                        // 更新状态并重建蒙层，确保蒙层中的选中状态同步更新
                                        safeSetState(() {
                                          // 如果蒙层可见，更新过滤选项列表为原始选项列表
                                          if (_isOverlayVisible) {
                                            _filteredOptions = List.from(_options);
                                            _updateOverlay(); // 重建蒙层更新选中状态
                                          }
                                        });

                                        // 调用回调函数
                                        if (widget.onChanged != null) {
                                          widget.onChanged!(_selectedIndexes);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // 输入框 - 初始填满，选择标签后保持最小宽度
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            enabled: true,
                            style: TextStyle(
                              fontSize: 14.wMin,
                              color: const Color(0xffEDF0F4),
                              height: 1.0,
                            ),
                            textAlign: TextAlign.end,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              border: InputBorder.none,
                              hintText: _selectedIndexes.isEmpty ? (widget.hintText ?? '请选择') : '',
                              hintStyle: TextStyle(
                                fontSize: 14.wMin,
                                color: const Color.fromRGBO(255, 255, 255, 0.4),
                                fontWeight: FontWeight.w400,
                                height: 1.0,
                              ),
                            ),
                            onTap: () {
                              if (widget.readOnly) return;
                              _filteredOptions = _options;
                              _updateOverlay();
                            },
                            onChanged: OptimizeUtils.debounce((String value) {
                              // print("---onChanged: $value---");
                              // 根据输入文本过滤选项列表
                              final searchText = value.trim();
                              if (searchText.isEmpty) {
                                // 如果搜索框为空，显示所有选项
                                _filteredOptions = List.from(_options);
                              } else {
                                // 过滤包含搜索文本的选项
                                _filteredOptions = _options
                                    .where((option) => option.toLowerCase().contains(searchText.toLowerCase()))
                                    .toList();
                              }

                              // 只在搜索框有内容时排序，保持按选中状态排序的行为
                              if (searchText.isNotEmpty) {
                                _filteredOptions.sort((a, b) {
                                  final aIndex = _options.indexOf(a);
                                  final bIndex = _options.indexOf(b);
                                  final aSelected = _selectedIndexes.contains(aIndex);
                                  final bSelected = _selectedIndexes.contains(bIndex);

                                  if (aSelected && !bSelected) return 1; // a选中了，b未选中，a排后面
                                  if (!aSelected && bSelected) return -1; // a未选中，b选中了，a排前面
                                  return 0; // 保持原有顺序
                                });
                              }

                              // 如果正在显示下拉框，更新它
                              if (_isOverlayVisible) {
                                _updateOverlay();
                              } else {
                                // 如果下拉框未显示，则显示它
                                _updateOverlay();
                              }

                              safeSetState(() {});
                            }, const Duration(milliseconds: 100)),
                            // 300ms的防抖时间，避免频繁更新
                            onSubmitted: (value) {
                              if (value.isEmpty) {
                                // 如果为空, 清空输入框
                                _textController.clear();
                                return;
                              }

                              // 查找匹配当前输入文本的选项
                              final matchingOptions = _filteredOptions
                                  .where((option) => option.toLowerCase().contains(value.toLowerCase()))
                                  .toList();

                              if (matchingOptions.isNotEmpty) {
                                // 查找第一个未选中的选项
                                int? indexToToggle;
                                bool allSelected = true;

                                for (final option in matchingOptions) {
                                  final originalIndex = _options.indexOf(option);
                                  if (!_selectedIndexes.contains(originalIndex)) {
                                    // 找到第一个未选中的，选中它
                                    indexToToggle = originalIndex;
                                    allSelected = false;
                                    break;
                                  }
                                }

                                // 如果所有选项都被选中，则取消选中第一个
                                if (allSelected && matchingOptions.isNotEmpty) {
                                  final option = matchingOptions.first;
                                  indexToToggle = _options.indexOf(option);
                                }

                                if (indexToToggle != null) {
                                  if (_selectedIndexes.contains(indexToToggle)) {
                                    // 如果已选中，取消选中
                                    _selectedIndexes.remove(indexToToggle);
                                  } else {
                                    // 如果未选中，选中它
                                    _selectedIndexes.add(indexToToggle);
                                  }

                                  // 最后也要滚动到最后一个标签
                                  _scrollToLastTag();
                                }
                              }

                              // 在处理完后清空输入框
                              _textController.clear();

                              // 按Enter键后，重置过滤选项为原始完整选项列表，不进行排序
                              safeSetState(() {
                                // 将过滤选项重置为完整选项列表
                                _filteredOptions = List.from(_options);
                              });

                              // 重新创建蒙层以刷新对勾显示
                              _updateOverlay();

                              widget.onChanged?.call(_selectedIndexes); // 传递当前索引
                            },
                            onTapOutside: (event) {
                              if (_isOverlayVisible) {
                                // 获取覆盖层的位置和大小
                                var record = CommonUtils.getSizeAndPosition(_overlayKey);
                                // 判断点击事件是否发生在覆盖层内
                                if (event.position.dx >= record.globalPosition.dx &&
                                    event.position.dx <= record.globalPosition.dx + record.size.width &&
                                    event.position.dy >= record.globalPosition.dy &&
                                    event.position.dy <= record.globalPosition.dy + record.size.height) {
                                  // 点击事件发生在覆盖层内，忽略
                                  return;
                                }
                              }

                              // 点击事件发生在覆盖层外，移除覆盖层
                              _focusNode.unfocus();
                              FocusManager.instance.primaryFocus?.unfocus();
                              _removeOverlay();
                              safeSetState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gaps.getWidth(10.ww),
                  buildImage(Assets.managerSelecctOptionDown, width: 20.wMax, height: 20.wMax),
                ],
              ),
            ),
          ),
        ));
  }

// 移除蒙层Overlay
  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!
        ..remove()
        ..dispose();
      _overlayEntry = null;
      _isOverlayVisible = false;
    }
  }

  // 更新蒙层Overlay
  void _updateOverlay() {
    // Defer overlay update to the next frame to avoid build phase conflicts
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _removeOverlay();
        _overlayEntry = _createOverlayEntry();
        _isOverlayVisible = true;
        Overlay.of(context).insert(_overlayEntry!);
      }
    });
  }

  OverlayEntry _createOverlayEntry() {
    var record = CommonUtils.getSizeAndPosition(_selectKey);
    var selectBoxHeight = record.size.height;

    // 计算蒙层内容高度
    final itemHeight = 48.wh; // 每个选项的高度
    final paddingHeight = 24.wh; // 蒙层内边距高度
    final contentHeight = _options.isEmpty
        ? _overlayMinHeight // 无数据时默认高度
        : (_options.length * itemHeight) + paddingHeight;

    // 动态调整蒙层高度
    final overlayHeight = contentHeight.clamp(_overlayMinHeight, _overlayMaxHeight);

    // 判断选择框是否靠近底部
    final screenHeight = MediaQuery.of(context).size.height;
    final selectBoxBottom = record.globalPosition.dy + selectBoxHeight;
    bool isNearBottom = (screenHeight - selectBoxBottom) < overlayHeight;

    // 动态调整蒙层位置
    final overlayOffset = isNearBottom
        ? Offset(0, -overlayHeight) // 蒙层显示在选择框上方
        : Offset(0, selectBoxHeight); // 蒙层显示在选择框下方

    return OverlayEntry(
      builder: (context) => Positioned(
        width: record.size.width,
        child: CompositedTransformFollower(
          showWhenUnlinked: false,
          link: _layerLink,
          offset: overlayOffset,
          child: RepaintBoundary(
            key: _overlayKey,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(maxHeight: _overlayMaxHeight, minHeight: _overlayMinHeight),
                width: record.size.width,
                decoration: BoxDecoration(
                  border: Border.all(width: 0.5.wMin, color: const Color(0xff666F8D)),
                  borderRadius: BorderRadius.circular(8.wMin),
                  color: const Color(0xff353E5C),
                ),
                padding: EdgeInsets.only(left: 16.ww, right: 16.ww, top: 12.wh, bottom: 12.wh),
                child: AnimationLimiter(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _filteredOptions.isEmpty ? 1 : _filteredOptions.length,
                    separatorBuilder: (_, i) => Gaps.getHeight(0),
                    itemBuilder: (_, index) {
                      if (_filteredOptions.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(12.wMin),
                          alignment: Alignment.center,
                          child: const Text('暂无数据', style: TextStyle(color: Color(0xffEDF0F4))),
                        );
                      }

                      // 获取过滤选项对应的原始选项索引
                      final option = _filteredOptions[index];
                      final originalIndex = _options.indexOf(option);
                      bool isSelected = _selectedIndexes.contains(originalIndex);
                      return SelectableOptionItem(
                        index: originalIndex,
                        // 使用原始索引
                        label: option,
                        isSelected: isSelected,
                        isLastItem: index == _filteredOptions.length - 1,
                        onTap: (int optionIndex) {
                          if (isSelected) {
                            _selectedIndexes.remove(optionIndex);
                          } else {
                            _selectedIndexes.add(optionIndex);
                          }

                          // 选项被选中后，清空输入框
                          _textController.clear();

                          // 调用滚动到末尾的方法
                          _scrollToLastTag();

                          // 更新状态
                          safeSetState(() {
                            // 重置为原始选项列表，保持原始顺序
                            _filteredOptions = List.from(_options);
                          });

                          // 重新创建蒙层以刷新对勾显示
                          _updateOverlay();

                          // 调用回调
                          if (widget.onChanged != null) {
                            widget.onChanged!(_selectedIndexes);
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 滚动到最后一个标签的方法
  void _scrollToLastTag() {
    if (_selectedIndexes.isNotEmpty && _horizontalScrollController.hasClients) {
      // 延迟执行确保布局已完成
      Future.delayed(const Duration(milliseconds: 100), () {
        _horizontalScrollController.animateTo(
          _horizontalScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void didUpdateWidget(covariant ManageMultiSelectWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果选项列表发生变化
    if (!listEquals(widget.options, oldWidget.options)) {
      _options
        ..clear()
        ..addAll(widget.options);

      // 同步更新过滤后的选项列表
      if (_textController.text.isEmpty) {
        _filteredOptions = List.from(_options);
      } else {
        // 重新根据当前搜索文本过滤选项
        _filteredOptions =
            _options.where((option) => option.toLowerCase().contains(_textController.text.toLowerCase())).toList();
      }

      // 如果蒙层显示中，更新蒙层
      if (_isOverlayVisible) {
        _updateOverlay();
      }
    }

    // 如果默认选中值发生变化
    if (widget.selectedValues != oldWidget.selectedValues) {
      if (widget.selectedValues != null && widget.selectedValues!.isNotEmpty) {
        // 清空当前选中索引
        _selectedIndexes.clear();

        // 添加新的选中索引
        for (String value in widget.selectedValues!) {
          int index = _options.indexOf(value);
          if (index != -1) {
            _selectedIndexes.add(index);
          }
        }

        // 如果有选中项，滚动到最后一个标签
        if (_selectedIndexes.isNotEmpty) {
          _scrollToLastTag();
        }

        // 如果蒙层显示中，更新蒙层以反映新的选中状态
        if (_isOverlayVisible) {
          _updateOverlay();
        }
      }
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _textController.dispose();
    _focusNode.dispose();
    _horizontalScrollController.dispose(); // 释放滚动控制器
    super.dispose();
  }
}

/// 下拉选项项组件
class SelectableOptionItem extends StatelessWidget {
  final int index;
  final String label;
  final bool isSelected;
  final Function(int) onTap;
  final bool isLastItem;

  const SelectableOptionItem({
    super.key,
    required this.index,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isLastItem,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 300),
      child: SlideAnimation(
        child: FadeInAnimation(
          child: GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              padding: EdgeInsets.only(
                left: 4.ww,
                right: 4.ww,
                top: 2.wh,
                bottom: 2.wh,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.wMin),
                color: isSelected ? const Color(0xff49557A) : Colors.transparent,
              ),
              margin: isLastItem ? null : EdgeInsets.only(bottom: 5.wh),
              child: Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16.wMin,
                      color: const Color(0xffEBEEF3),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  isSelected
                      ? buildImage(Assets.managerOk, width: 24.wMax, height: 24.wMax)
                      : SizedBox(width: 24.wMax, height: 24.wMax)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
