import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:quiz_play/utils/utils.dart';

/// 知识点选择组件
class ManageSelectWidget2 extends StatefulWidget {
  final String? title;
  final String? value;
  final String? hintText;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final bool required;
  final bool readOnly;
  final TextEditingController? controller;
  final void Function()? onTap;
  final void Function(String value, int index)? onChanged;
  final List<String> options;

  const ManageSelectWidget2({
    super.key,
    this.title,
    this.value,
    this.hintText,
    this.width,
    this.height,
    this.backgroundColor,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.required = false,
    required this.options,
  });

  @override
  State<ManageSelectWidget2> createState() => _ManageSelectWidget2State();
}

class _ManageSelectWidget2State extends State<ManageSelectWidget2> with SafeSetStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  List<String> _filteredOptions = [];
  int _selectedIndex = -1;
  bool _isOverlayVisible = false;
  final GlobalKey _overlayKey = GlobalKey();
  final GlobalKey _selectKey = GlobalKey();

  String? _lastSelectedOption;
  final double _overlayMinHeight = 80.wh, _overlayMaxHeight = 280.wh;
  final List<String> _options = [];

  @override
  void initState() {
    super.initState();
    _options
      ..clear()
      ..addAll(widget.options);

    _focusNode.addListener(() {
      if (widget.readOnly) {
        return;
      }
      if (!_focusNode.hasFocus) {
        _removeOverlay();
      }
      safeSetState(() {});
    });

    // 找到默认值选项在原始列表中的索引
    _selectedIndex = _options.indexOf(widget.value ?? '');
    _textController.text = widget.value ?? '';
    _lastSelectedOption = widget.value ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
      }, 50),
      child: CompositedTransformTarget(
        key: _selectKey,
        link: _layerLink,
        child: Container(
          height: widget.height ?? 50.wh,
          width: widget.width,
          padding: EdgeInsets.symmetric(horizontal: 12.ww),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.wMin),
            color: widget.backgroundColor ?? Colors.transparent,
            border: Border.all(
              width: 1.wMin,
              color: _focusNode.hasFocus ? const Color(0xff2388FF) : const Color(0xff4B5268),
            ),
          ),
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
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  textAlign: TextAlign.end,
                  readOnly: widget.readOnly,
                  // 始终设为只读，由下拉菜单控制
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    border: InputBorder.none,
                    hintText: widget.hintText ?? '请选择',
                    hintStyle: TextStyle(
                        fontSize: 16.wMin,
                        color: const Color.fromRGBO(255, 255, 255, 0.4),
                        fontWeight: FontWeight.w400,
                        height: 1.0),
                  ),
                  style: TextStyle(
                      fontSize: 16.wMin, color: const Color(0xffEDF0F4), fontWeight: FontWeight.w400, height: 1.0),
                  onTap: () {
                    print("点击输入框");
                    if (widget.readOnly) return;
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
                    widget.onChanged?.call(_textController.text, _selectedIndex); // 传递当前索引
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
                        _textController.text = _lastSelectedOption ?? '';
                        // 找到选中的选项在原始列表中的索引
                        _selectedIndex = _options.indexOf(_lastSelectedOption!);
                      }
                    }

                    _removeOverlay();
                    _focusNode.unfocus();
                    FocusManager.instance.primaryFocus?.unfocus();
                    safeSetState(() {});
                    widget.onChanged?.call(value, _selectedIndex); // 传递当前索引
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
              Gaps.getWidth(10.ww),
              buildImage(Assets.managerSelecctOptionDown, width: 20.wMax, height: 20.wMax),
            ],
          ),
        ),
      ),
    );
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
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    _isOverlayVisible = true;
    Overlay.of(context).insert(_overlayEntry!);
  }

  // 创建蒙层Overlay
  OverlayEntry _createOverlayEntry() {
    var record = CommonUtils.getSizeAndPosition(_selectKey);
    var selectBoxHeight = record.size.height;

    // 计算蒙层内容高度
    final itemHeight = 48.wh; // 每个选项的高度
    final paddingHeight = 24.wh; // 蒙层内边距高度
    final contentHeight = _filteredOptions.isEmpty
        ? _overlayMinHeight // 无数据时默认高度
        : (_filteredOptions.length * itemHeight) + paddingHeight;

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

                      bool isSelected = _filteredOptions[index] == _lastSelectedOption;
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 300),
                        child: SlideAnimation(
                          child: FadeInAnimation(
                            child: GestureDetector(
                              onTap: () {
                                // 更新选中的索引
                                _selectedIndex = _options.indexOf(_filteredOptions[index]);
                                // 更新选中的选项
                                _lastSelectedOption = _filteredOptions[index];
                                _textController.text = _lastSelectedOption!;

                                _removeOverlay();
                                _focusNode.unfocus();
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
                                margin:
                                    (index != _filteredOptions.length - 1) ? EdgeInsets.only(bottom: 5.wh) : null,
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

  @override
  void didUpdateWidget(covariant ManageSelectWidget2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.options, oldWidget.options)) {
      _options
        ..clear()
        ..addAll(widget.options);
      // 找到默认值选项在原始列表中的索引
      _selectedIndex = _options.indexOf(widget.value ?? '');
      _textController.text = widget.value ?? '';
      _lastSelectedOption = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }
}
