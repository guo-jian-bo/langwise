import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import '../values/values.dart';

/// 图片风格选择对话框
class ImageStyleSelectorDialog {
  /// 显示图片风格选择对话框
  ///
  /// [context] 上下文
  /// [title] 对话框标题
  /// [items] 数据源列表
  /// [onItemSelected] 选择回调
  /// [itemBuilder] 自定义item构建器，接收索引和实体T，返回Widget
  /// [selectedItem] 当前选中的项目
  ///
  /// 返回选中的项目，如果取消则返回null
  static Future<T?> show<T>({
    required BuildContext context,
    String title = '选择图片风格',
    required List<T> items,
    void Function(T item)? onItemSelected,
    required Widget Function(int index, T item) itemBuilder,
    T? selectedItem,
  }) async {
    return await Get.dialog<T>(
      ImageStyleSelectorWidget<T>(
        title: title,
        items: items,
        onItemSelected: onItemSelected,
        itemBuilder: itemBuilder,
        selectedItem: selectedItem,
      ),
      barrierDismissible: true,
    );
  }
}

/// 图片风格选择组件
class ImageStyleSelectorWidget<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final void Function(T item)? onItemSelected;
  final Widget Function(int index, T item) itemBuilder;
  final T? selectedItem;

  const ImageStyleSelectorWidget({
    super.key,
    required this.title,
    required this.items,
    this.onItemSelected,
    required this.itemBuilder,
    this.selectedItem,
  });

  @override
  State<ImageStyleSelectorWidget<T>> createState() => _ImageStyleSelectorWidgetState<T>();
}

class _ImageStyleSelectorWidgetState<T> extends State<ImageStyleSelectorWidget<T>> with SafeSetStateMixin {
  T? _selectedItem;
  int? _hoveredIndex;

  /// 自动滚动控制器
  late AutoScrollController _autoScrollController;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedItem;
    _autoScrollController = AutoScrollController();

    // 如果有选中项，延迟滚动到对应位置
    if (_selectedItem != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedItem();
      });
    }
  }

  @override
  void dispose() {
    _autoScrollController.dispose();
    super.dispose();
  }

  /// 滚动到选中项
  void _scrollToSelectedItem() {
    final selectedIndex = widget.items.indexOf(_selectedItem as T);
    if (selectedIndex != -1) {
      _autoScrollController.scrollToIndex(
        selectedIndex,
        duration: const Duration(milliseconds: 300),
        preferPosition: AutoScrollPosition.middle,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 640.ww,
          height: 458.wh,
          padding: EdgeInsets.all(24.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: color_1E2939,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "选择图片风格",
                style: TextStyle(fontSize: 20.wMin, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              Gaps.getHeight(16.wh),
              _buildItemList(),
              Gaps.getHeight(16.wh),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 确定按钮
                  GestureDetector(
                    onTap: OptimizeUtils.noneThrottle(() {
                      if (_selectedItem != null) {
                        Navigator.of(context).pop(_selectedItem);
                        widget.onItemSelected?.call(_selectedItem!);
                      }
                    }, 200),
                    child: Container(
                      padding: EdgeInsets.only(left: 16.ww, right: 16.ww, top: 8.wh, bottom: 8.wh),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.wMin),
                        color: _selectedItem != null ? color_155DFC : color_364153,
                      ),
                      child: Text(
                        "确定",
                        style: TextStyle(
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w400,
                          color: _selectedItem != null ? Colors.white : Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  Gaps.getWidth(12.ww),
                  // 关闭按钮
                  GestureDetector(
                    onTap: OptimizeUtils.noneThrottle(() {
                      Navigator.of(context).pop();
                    }, 200),
                    child: Container(
                      padding: EdgeInsets.only(left: 16.ww, right: 16.ww, top: 8.wh, bottom: 8.wh),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.wMin),
                        color: color_364153,
                      ),
                      child: Text(
                        "关闭",
                        style: TextStyle(fontSize: 16.wMin, fontWeight: FontWeight.w400, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /// 构建默认的项目组件
  Widget _buildDefaultItem(int index, T item, bool isSelected, bool isHovered) {
    return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 24.wMin, right: 24.wMin, top: 16.wh, bottom: 16.wh),
        decoration: BoxDecoration(
          color: isHovered
              ? Colors.white.withValues(alpha: 0.3)
              : isSelected
                  ? color_495366
                  : color_364153,
          borderRadius: BorderRadius.circular(8.wMin),
        ),
        child: Row(
          children: [
            // 使用自定义构建器来构建项目内容
            widget.itemBuilder(index, item),
            const Spacer(),
            isSelected
                ? buildImage(Assets.managerOk, width: 24.wMax, height: 24.wMax)
                : SizedBox(width: 24.wMax, height: 24.wMax)
          ],
        ));
  }

  /// 构建项目列表
  Widget _buildItemList() {
    return Expanded(
      child: ListView.separated(
        controller: _autoScrollController,
        itemCount: widget.items.length,
        padding: EdgeInsets.zero,
        separatorBuilder: (context, index) => SizedBox(height: 16.wMin),
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final isSelected = _selectedItem == item;
          final isHovered = _hoveredIndex == index;

          // 使用 AutoScrollTag 包装每个项目
          return AutoScrollTag(
            key: ValueKey(index),
            controller: _autoScrollController,
            index: index,
            child: TapScaleWidget(
              onTap: () => _handleItemTap(item),
              sclae: 1.02,
              child: MouseRegion(
                onEnter: (_) => _handleMouseEnter(index),
                onExit: (_) => _handleMouseExit(),
                child: _buildDefaultItem(index, item, isSelected, isHovered),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 处理项目选择
  void _handleItemTap(T item) {
    safeSetState(() {
      _selectedItem = item;
    });
  }

  /// 处理鼠标进入
  void _handleMouseEnter(int index) {
    safeSetState(() {
      _hoveredIndex = index;
    });
  }

  /// 处理鼠标离开
  void _handleMouseExit() {
    safeSetState(() {
      _hoveredIndex = null;
    });
  }
}
