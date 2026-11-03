import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:quiz_play/utils/utils.dart';

class ManageSelectWidget extends StatefulWidget {
  final String? title;
  final String? value;
  final String? hintText;
  final double? width;
  final double? height;
  final Color? backgroundColor;

  /// 焦点顺序
  final double focusOrder;
  final bool readOnly;
  final bool required;
  final TextEditingController? controller;
  final void Function()? onTap;
  final void Function(String value, int index)? onChanged; // 修改回调函数签名
  final List<String> options;

  const ManageSelectWidget(
      {super.key,
      this.title,
      this.value,
      this.hintText,
      this.width,
      this.height,
      this.backgroundColor,
      this.controller,
      this.onChanged,
      this.focusOrder = 0,
      this.onTap,
      this.readOnly = false,
      this.required = false,
      required this.options});

  @override
  State<ManageSelectWidget> createState() => _ManageSelectWidgetState();
}

class _ManageSelectWidgetState extends State<ManageSelectWidget> with SafeSetStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _filteredOptions = [];
  int _selectedIndex = -1;

  bool _isOverlayVisible = false; // 用于跟踪覆盖层是否显示
  final GlobalKey _overlayKey = GlobalKey(); // 用于获取覆盖层的 RenderBox
  final GlobalKey _searchKey = GlobalKey();

  String? _lastSelectedOption;

  final double _overlayMinHeight = 80.wh, _overlayMaxHeight = 280.wh;

  final List<String> _options = [];

  @override
  void initState() {
    super.initState();
    _options
      ..clear()
      ..addAll(widget.options);
    _searchFocusNode.addListener(() {
      print("---选择器hasFocus:${_searchFocusNode.hasFocus}---");
      if (widget.readOnly) {
        // 只读不更新UI
        return;
      }
      if (!_searchFocusNode.hasFocus) {
        _removeOverlay();
      }
      safeSetState(() {});
    });
    // 找到默认值选项在原始列表中的索引
    _selectedIndex = _options.indexOf(widget.value ?? '');
    _searchController.text = widget.value ?? '';
    _lastSelectedOption = widget.value ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      Visibility(
        visible: widget.title != null && widget.title!.trim().isNotEmpty,
        child: Container(
          margin: EdgeInsets.only(bottom: 12.wh),
          child: Text.rich(
            TextSpan(
              children: [
                // 红色星号
                if (widget.required)
                  TextSpan(
                    text: '*',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                TextSpan(
                  text: widget.title ?? "",
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: const Color(0xffEBEEF3),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      GestureDetector(
        onTap: OptimizeUtils.noneThrottle(() {
          if (widget.readOnly) {
            return;
          }
          safeSetState(() {});
          widget.onTap?.call();
        }, 50),
        child: CompositedTransformTarget(
          key: _searchKey,
          link: _layerLink,
          child: AnimatedContainer(
            height: widget.height ?? 50.wMin,
            width: widget.width,
            duration: const Duration(milliseconds: 100),
            padding: EdgeInsets.symmetric(horizontal: 12.ww),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.wMin),
              color: widget.backgroundColor ?? Colors.transparent,
              border: Border.all(
                width: 1.wMin,
                color: _searchFocusNode.hasFocus ? const Color(0xff2388FF) : const Color(0xff4B5268),
              ),
            ),
            alignment: Alignment.center,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  readOnly: widget.readOnly,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    // important 用于编辑框对齐
                    border: InputBorder.none,
                    hintText: widget.hintText ?? '',
                    hintStyle: TextStyle(
                      fontSize: 16.wMin,
                      color: const Color.fromRGBO(255, 255, 255, 0.4),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: const Color(0xffEDF0F4),
                    fontWeight: FontWeight.w400,
                  ),
                  onTap: () {
                    if (widget.readOnly) {
                      return;
                    }
                    _filteredOptions = _options;
                    _updateOverlay();
                    safeSetState(() {});
                  },
                  onChanged: OptimizeUtils.debounce((String value) {
                    if (value.isEmpty) {
                      _filteredOptions = _options;
                    } else {
                      _filteredOptions = _options.where((option) => option.contains(value)).toList();
                      // 自动命中第一个选项
                      if (_filteredOptions.isNotEmpty) {
                        _lastSelectedOption = _filteredOptions.first;
                        // 找到选中的选项在原始列表中的索引
                        _selectedIndex = _options.indexOf(_lastSelectedOption!);
                      }
                    }

                    if (value.isEmpty) {
                      // 文本为空, 重置选项默认状态
                      _selectedIndex = -1;
                      _lastSelectedOption = null;
                    }
                    _updateOverlay();
                    safeSetState(() {});
                    widget.onChanged?.call(_searchController.text, _selectedIndex); // 传递当前索引
                  }),
                  onSubmitted: (String value) {
                    if (value.isEmpty) {
                      _filteredOptions = _options;
                    } else {
                      _filteredOptions = _options.where((option) => option.contains(value)).toList();
                      // 过滤到数据源有多个, 默认取第一个
                      if (_filteredOptions.length > 1) {
                        _filteredOptions = _filteredOptions.sublist(0, 1);
                      }

                      if (_filteredOptions.isNotEmpty) {
                        _lastSelectedOption = _filteredOptions.first;
                        _searchController.text = _lastSelectedOption ?? '';
                        // 找到选中的选项在原始列表中的索引
                        _selectedIndex = _options.indexOf(_lastSelectedOption!);
                      }
                    }

                    _removeOverlay();
                    _searchFocusNode.unfocus();
                    FocusManager.instance.primaryFocus?.unfocus();
                    safeSetState(() {});
                    widget.onChanged?.call(value, _selectedIndex); // 传递当前索引
                  },
                  onTapOutside: (event) {
                    print('选择语言onTapOutside输入框失去焦点_isOverlayVisible:$_isOverlayVisible');
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
                    _searchFocusNode.unfocus();
                    FocusManager.instance.primaryFocus?.unfocus();
                    _removeOverlay();
                    safeSetState(() {});
                  },
                )), // Expanded(
                Gaps.getWidth(10.ww),
                buildImage(Assets.managerSelecctOptionDown, width: 20.wMax, height: 20.wMax),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

// 创建蒙层Overlay
  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!
        ..remove()
        ..dispose();
      _overlayEntry = null;
      _isOverlayVisible = false; // 更新覆盖层状态
    }
  }

  // 创建蒙层Overlay
  void _updateOverlay() {
    _removeOverlay(); // 先移除旧的覆盖层
    _overlayEntry = _createOverlayEntry();
    _isOverlayVisible = true; // 更新覆盖层状态
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry() {
    var record = CommonUtils.getSizeAndPosition(_searchKey);
    var searchBoxHeight = record.size.height;

    // 计算蒙层内容高度
    final itemHeight = 48.wh; // 每个选项的高度
    final paddingHeight = 24.wh; // 蒙层内边距高度
    final contentHeight = _filteredOptions.isEmpty
        ? _overlayMinHeight // 无数据时默认高度
        : (_filteredOptions.length * itemHeight) + paddingHeight;

    // 动态调整蒙层高度
    final overlayHeight = contentHeight.clamp(_overlayMinHeight, _overlayMaxHeight); // 限制蒙层高度在 80.wh 到 280.wh 之间

    // 判断搜索框是否靠近底部
    final screenHeight = MediaQuery.of(context).size.height;
    final searchBoxBottom = record.globalPosition.dy + searchBoxHeight;
    bool isNearBottom = (screenHeight - searchBoxBottom) < overlayHeight;

    // 动态调整蒙层位置
    final overlayOffset = isNearBottom
        ? Offset(0, -overlayHeight) // 蒙层显示在搜索框上方
        : Offset(0, searchBoxHeight); // 蒙层显示在搜索框下方
    return OverlayEntry(
        builder: (context) => Positioned(
              width: record.size.width,
              child: CompositedTransformFollower(
                // 没有链接时, 隐藏
                showWhenUnlinked: false,
                link: _layerLink,
                // 调整偏移量使选项紧贴输入框
                offset: overlayOffset, // 动态调整偏移量
                child: RepaintBoundary(
                  key: _overlayKey,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      constraints: BoxConstraints(maxHeight: _overlayMaxHeight, minHeight: _overlayMinHeight),
                      width: widget.width,
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.5.wMin, color: const Color(0xff666F8D)),
                        borderRadius: BorderRadius.circular(8.wMin),
                        color: const Color(0xff353E5C),
                      ),
                      padding: EdgeInsets.only(left: 16.ww, right: 16.ww, top: 12.wh, bottom: 12.wh),
                      child: AnimationLimiter(
                        child: ListView.separated(
                            padding: EdgeInsets.zero,
                            // 自适应高度
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
                              // 找到选中的选项在 _filteredOptions 中的索引
                              bool isSelected = _filteredOptions[index] == _lastSelectedOption;
                              return GestureDetector(
                                onTap: () {
                                  // 更新选中的索引
                                  _selectedIndex = _options.indexOf(_filteredOptions[index]);
                                  // 更新选中的选项
                                  _lastSelectedOption = _filteredOptions[index];
                                  _searchController.text = _lastSelectedOption!;

                                  _removeOverlay();
                                  _searchFocusNode.unfocus();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  safeSetState(() {});
                                  // 回调选中的值和索引
                                  widget.onChanged?.call(_lastSelectedOption!, _selectedIndex);
                                },
                                child: Container(
                                  padding: EdgeInsets.only(left: 4.ww, right: 4.ww, top: 2.wh, bottom: 2.wh),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.wMin),
                                    color: isSelected ? const Color(0xff49557A) : Colors.transparent,
                                  ),
                                  margin: (index != _filteredOptions.length - 1) ? EdgeInsets.only(bottom: 5.wh) : null,
                                  child: Row(
                                    children: [
                                      Text(
                                        _filteredOptions[index],
                                        style: TextStyle(
                                          fontSize: 16.wMin,
                                          color: const Color(0xffEBEEF3),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const Spacer(),
                                      isSelected ? buildImage(Assets.managerOk, width: 24.wMax, height: 24.wMax) : SizedBox(width: 24.wMax, height: 24.wMax)
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                  ),
                ),
              ),
            ));
  }

  @override
  void didUpdateWidget(covariant ManageSelectWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 引用比较/内容比较
    // 比较新旧widget.options的内容，使用listEquals函数，从而在内容相同的情况下返回false，避免不必要的状态更新。
    if (!listEquals(widget.options, oldWidget.options)) {
      _options
        ..clear()
        ..addAll(widget.options);
      // 找到默认值选项在原始列表中的索引
      _selectedIndex = _options.indexOf(widget.value ?? '');
      _searchController.text = widget.value ?? '';
      _lastSelectedOption = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _selectedIndex = -1;
    _isOverlayVisible = false;
    _lastSelectedOption = null;
    _options.clear();
    _removeOverlay();
  }
}
