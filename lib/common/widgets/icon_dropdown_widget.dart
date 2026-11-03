
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'widgets.dart';

class IconDropdownCheckData<T>{
  
  String title;
  String? iconSvg;
  String? subtitle;
  bool isEnable;
  T? value;
  Color? selectedBackgroundColor;
  Color? selectedBorderColor;
  TextStyle? selectedTextStyle;
  IconDropdownCheckData({
    required this.title,
    this.subtitle,
    this.value,
    this.iconSvg,
    this.isEnable = true,
    this.selectedBackgroundColor,
    this.selectedBorderColor,
    this.selectedTextStyle,
  });
}

class IconDropdownIconData<T>{
  String title;
  String? iconSvg;
  Color color;
  int? index;
  T? value;
  IconDropdownIconData({
    required this.title,
    this.iconSvg,
    this.index,
    this.color = const Color(0xffF2F4F9),
    this.value,
  });
}


class IconDropdownMenuWidget extends StatefulWidget {
  final Widget child;
  final List<IconDropdownIconData> items;
  final double? itemHeight;
  final double? menuHeight;
  final double? width;
  final double sclae;
  final double left;
  final double top;
  final TextStyle? textStyle;
  final void Function(IconDropdownIconData data, int index)? onTap;
  const IconDropdownMenuWidget({
    super.key, 
    required this.items, 
    this.itemHeight, 
    this.menuHeight, 
    this.width, 
    this.onTap, 
    required this.child, 
    this.sclae = 1.1, 
    this.left = 0, 
    this.top = 0,
    this.textStyle,
  });

  @override
  State<IconDropdownMenuWidget> createState() => _IconDropdownMenuWidgetState();
}

class _IconDropdownMenuWidgetState extends State<IconDropdownMenuWidget> {

  Future<int?> showIconMenu(BuildContext ctx) async{
    final RenderBox button = ctx.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(ctx).context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero, ancestor: overlay);

    return await showMenu<int?>(
      context: ctx, 
      menuPadding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      popUpAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 200),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      color: AppTheme.cBgTertiary,
      constraints: BoxConstraints(
        maxWidth: widget.width??260.wMin,
        maxHeight: widget.menuHeight?? (double.infinity),
      ),
      position: RelativeRect.fromLTRB(
        offset.dx - (widget.width??260.wMin) + button.size.width + widget.left, 
        offset.dy + button.size.height + 5 + widget.top, 
        offset.dx + button.size.width, 
        offset.dy + button.size.height,
      ), 
      items: List.generate(widget.items.length, (index){
        return PopupMenuItem(
          value: index,
          padding: EdgeInsets.zero,
          height: widget.itemHeight??64.wMin,
          onTap: () => widget.onTap?.call(widget.items[index], index),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            width: widget.width??260.wMin,
            height: widget.itemHeight??64.wMin,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: index == widget.items.length - 1? Colors.transparent : AppTheme.cBorderPrimary,
                  width: 1.wMin,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.items[index].title,
                    style: widget.textStyle ?? TextStyle(
                      color: AppTheme.cTextPrimary,
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.items[index].iconSvg != null && widget.items[index].iconSvg != "",
                  child: SvgPicture.asset(
                    widget.items[index].iconSvg??"",
                    width: 24.wMin,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: AppTheme.cBgActive,
        hoverColor: AppTheme.cBgActive,
      ),
      child: Builder(
        builder: (ctx) {
          return TapScaleWidget(
            onTap: () {
              showIconMenu(ctx);
            },
            sclae: widget.sclae,
            child: widget.child,
          );
        }
      ),
    );
  }
}

class IconDropdownCheckWidget extends StatefulWidget {
  final Widget child;
  final List<IconDropdownCheckData> items;
  final int selectIndex;
  final Set<int>? selectIndexes;
  final bool multiSelect;
  final double? itemHeight;
  final double? menuHeight;
  final double? width;
  final void Function(IconDropdownCheckData data, int index)? onTap;
  final double sclae;
  final double left;
  final double top;
  final Color backColor;
  final Color borderolor;
  final Color highlightColor;
  final Color hoverColor;
  final double? fontSize;
  final Color fontColor;
  final Color dividerColor;
  final void Function()? onShowMenu;
  final void Function()? onHideMenu;
  final bool isIosAwait;
  final bool alignRight;
  const IconDropdownCheckWidget({
    super.key, 
    required this.items,
    this.selectIndex = 0,
    this.selectIndexes,
    this.multiSelect = false,
    this.itemHeight, 
    this.menuHeight,
    this.onTap, 
    required this.child, 
    this.sclae = 1.1, 
    this.left = 0,
    this.top = 0, 
    this.width, 
    this.fontSize, 
    this.fontColor = AppTheme.cTextPrimary,
    this.backColor = AppTheme.cBgTertiary,
    this.highlightColor = AppTheme.cBgActive,
    this.hoverColor = AppTheme.cBgActive,
    this.dividerColor = AppTheme.cBorderPrimary,
    this.borderolor = Colors.transparent, 
    this.onShowMenu, 
    this.onHideMenu,
    this.isIosAwait = false,
    this.alignRight = false,
    });

  @override
  State<IconDropdownCheckWidget> createState() => _IconDropdownCheckWidgetState();
}

class _IconDropdownCheckWidgetState extends State<IconDropdownCheckWidget> {
  OverlayEntry? _multiOverlayEntry;
  bool _multiOverlayVisible = false;

  @override
  void didUpdateWidget(covariant IconDropdownCheckWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_multiOverlayVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_multiOverlayVisible) return;
        _multiOverlayEntry?.markNeedsBuild();
      });
    }
  }

  @override
  void dispose() {
    _hideMultiSelectOverlay();
    super.dispose();
  }

  Future<void> showCheck(BuildContext ctx) async{
    if(widget.items.isEmpty) return;

    if(Platform.isIOS && widget.isIosAwait){
      Future.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        if (!ctx.mounted) return;
        _showCheckInternal(ctx);
      });
      return;
    }

    await _showCheckInternal(ctx);
  }

  Future<void> _showCheckInternal(BuildContext ctx) async {
    if (!ctx.mounted) return;

    if (widget.multiSelect) {
      if (_multiOverlayVisible) {
        _hideMultiSelectOverlay();
      } else {
        _showMultiSelectOverlay(ctx);
      }
      return;
    }

    final OverlayState? overlayState = Overlay.of(ctx);
    if (overlayState == null) return;
    final RenderBox button = ctx.findRenderObject() as RenderBox;
    final RenderBox overlay = overlayState.context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero, ancestor: overlay);

    double buttonWidth = widget.width??button.size.width;
    widget.onShowMenu?.call();
    await showMenu<int?>(
      context: ctx, 
      menuPadding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      initialValue: widget.selectIndex,
      popUpAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 200),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.wMin),
        side: BorderSide(width: 1.wMin, color: widget.borderolor),
      ),
      color: widget.backColor,
      constraints: BoxConstraints(
        maxWidth: buttonWidth,
        maxHeight: widget.menuHeight?? ((widget.itemHeight??64.wMin) * 5),
      ),
      position: () {
        double left = offset.dx + widget.left;
        double right = offset.dx + buttonWidth;

        if (widget.alignRight) {
          left = offset.dx + button.size.width - buttonWidth + widget.left;
          right = offset.dx + button.size.width;
        }

        return RelativeRect.fromLTRB(
          left,
          offset.dy + button.size.height + 5 + widget.top,
          right,
          offset.dy + button.size.height,
        );
      }(), 
      items: List.generate(widget.items.length, (index){
        return PopupMenuItem(
          value: index,
          enabled: widget.multiSelect ? widget.items[index].isEnable : (widget.selectIndex != index && widget.items[index].isEnable),
          padding: EdgeInsets.zero,
          height: widget.itemHeight??64.wMin,
          onTap: () {
            widget.onTap?.call(widget.items[index], index);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.wMin),
            width: buttonWidth,
            height: widget.itemHeight??64.wMin,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: index == widget.items.length - 1 ? Colors.transparent : widget.dividerColor,
                  width: 1.wMin,
                ),
              ),
            ),
            child: Row(
              children: [
                Visibility(
                  visible: widget.items[index].iconSvg != null,
                  child: Container(
                    margin: EdgeInsets.only(right: 6.wMin),
                    child: SvgPicture.asset(
                      widget.items[index].iconSvg??"",
                      width: 24.wMin,
                      height: 24.wMin,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.items[index].title,
                        style: TextStyle(
                          color: widget.items[index].isEnable ? (widget.selectIndex == index ? AppTheme.cTextPrimary : widget.fontColor) : AppTheme.cTextDisabled,
                          fontSize: widget.fontSize??20.wMin,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Visibility(
                        visible: widget.items[index].subtitle != null,
                        child: Text(
                          widget.items[index].subtitle??"",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.cTextSecondary,
                            fontSize: 14.wMin,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.multiSelect ? (widget.selectIndexes?.contains(index) ?? false) : (widget.selectIndex == index),
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_check.svg",
                    width: 24.wMin,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );

    widget.onHideMenu?.call();

  }

  void _hideMultiSelectOverlay() {
    if (!_multiOverlayVisible) return;
    _multiOverlayEntry?.remove();
    _multiOverlayEntry = null;
    _multiOverlayVisible = false;
    widget.onHideMenu?.call();
  }

  void _showMultiSelectOverlay(BuildContext ctx) {
    if (_multiOverlayVisible) return;
    final RenderBox button = ctx.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(ctx).context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero, ancestor: overlay);
    final double buttonWidth = widget.width ?? button.size.width;
    final double itemHeight = widget.itemHeight ?? 64.wMin;
    final double maxMenuHeight = widget.menuHeight ?? (itemHeight * 5);

    double left = offset.dx + widget.left;
    if (widget.alignRight) {
      left = offset.dx + button.size.width - buttonWidth + widget.left;
    }
    final double top = offset.dy + button.size.height + 5 + widget.top;

    widget.onShowMenu?.call();
    _multiOverlayVisible = true;

    _multiOverlayEntry = OverlayEntry(
      builder: (_) {
        return Positioned.fill(
          child: GestureDetector(
            onTap: _hideMultiSelectOverlay,
            behavior: HitTestBehavior.translucent,
            child: Stack(
              children: [
                Positioned(
                  left: left,
                  top: top,
                  width: buttonWidth,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: maxMenuHeight,
                        maxWidth: buttonWidth,
                      ),
                      decoration: BoxDecoration(
                        color: widget.backColor,
                        borderRadius: BorderRadius.circular(12.wMin),
                        border: Border.all(
                          width: 1.wMin,
                          color: widget.borderolor,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: widget.items.length,
                        itemBuilder: (context, index) {
                          final item = widget.items[index];
                          final bool selected = widget.selectIndexes?.contains(index) ?? false;
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: item.isEnable
                                  ? () {
                                      widget.onTap?.call(item, index);
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        _multiOverlayEntry?.markNeedsBuild();
                                      });
                                    }
                                  : null,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                                width: buttonWidth,
                                height: itemHeight,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: index == widget.items.length - 1 ? Colors.transparent : widget.dividerColor,
                                      width: 1.wMin,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Visibility(
                                      visible: item.iconSvg != null,
                                      child: Container(
                                        margin: EdgeInsets.only(right: 6.wMin),
                                        child: SvgPicture.asset(
                                          item.iconSvg ?? "",
                                          width: 24.wMin,
                                          height: 24.wMin,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            item.title,
                                            style: TextStyle(
                                              color: item.isEnable ? widget.fontColor : AppTheme.cTextDisabled,
                                              fontSize: widget.fontSize ?? 20.wMin,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Visibility(
                                            visible: item.subtitle != null,
                                            child: Text(
                                              item.subtitle ?? "",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: AppTheme.cTextSecondary,
                                                fontSize: 14.wMin,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: selected,
                                      child: SvgPicture.asset(
                                        "assets/svg/public/icon_check.svg",
                                        width: 24.wMin,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Overlay.of(ctx).insert(_multiOverlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: widget.highlightColor,
        hoverColor: widget.hoverColor,
      ),
      child: Builder(
        builder: (ctx) {
          return TapScaleWidget(
            onTap: widget.onTap != null ? () {
              FocusScope.of(context).requestFocus(FocusNode());
              showCheck(ctx);
            } : null,
            sclae: widget.sclae,
            child: widget.child,
          );
        }
      ),
    );
  }
}

class IconDropdownDialog{

  static Future<int?> showCheck({
    required BuildContext context,
    required List<IconDropdownCheckData> items,
    int selectIndex = 0,
    double? itemHeight,
    double? width,
    void Function(IconDropdownCheckData data, int index)? onTap,
  }) async{

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero, ancestor: overlay);

    double buttonWidth = width??button.size.width;

    return await showMenu<int?>(
      context: context, 
      menuPadding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      initialValue: selectIndex,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.wMin),
      ),
      color: AppTheme.cBgTertiary,
      popUpAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 200),
      ),
      constraints: BoxConstraints(
        maxWidth: buttonWidth,
      ),
      position: RelativeRect.fromLTRB(
        offset.dx, 
        offset.dy + button.size.height + 5, 
        offset.dx + buttonWidth, 
        offset.dy + button.size.height,
      ), 
      items: List.generate(items.length, (index){
        final bool isSelected = selectIndex == index;
        return PopupMenuItem(
          enabled: selectIndex != index,
          value: index,
          padding: EdgeInsets.zero,
          height: itemHeight??64.wMin,
          onTap: () => onTap?.call(items[index], index),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.wMin),
            width: buttonWidth,
            height: itemHeight??64.wMin,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: index == items.length - 1? Colors.transparent : AppTheme.cBorderPrimary,
                  width: 1.wMin,
                ),
              ),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.wMin),
              height: itemHeight??64.wMin,
              decoration: BoxDecoration(
                color: isSelected ? items[index].selectedBackgroundColor : Colors.transparent,
                borderRadius: BorderRadius.circular(10.wMin),
                border: isSelected && items[index].selectedBorderColor != null
                    ? Border.all(color: items[index].selectedBorderColor!, width: 2.wMin)
                    : null,
              ),
              child: Row(
                children: [
                  Visibility(
                    visible: items[index].iconSvg != null,
                    child: Container(
                      margin: EdgeInsets.only(right: 6.wMin),
                      child: SvgPicture.asset(
                        items[index].iconSvg??"",
                        width: 24.wMin,
                        height: 24.wMin,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          items[index].title,
                          style: isSelected && items[index].selectedTextStyle != null
                              ? items[index].selectedTextStyle
                              : TextStyle(
                                  color: AppTheme.cTextPrimary,
                                  fontSize: 20.wMin,
                                  fontWeight: FontWeight.w400,
                                ),
                        ),
                        Visibility(
                          visible: items[index].subtitle != null,
                          child: Text(
                            items[index].subtitle??"",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme.cTextSecondary,
                              fontSize: 14.wMin,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: isSelected,
                    child: SvgPicture.asset(
                      "assets/svg/public/icon_check.svg",
                      width: 24.wMin,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );

  }

  

}



class IconDropdownSelectWidget extends StatefulWidget {
  final String? hintText;
  final Color fillColor;
  final Color borderColor;
  final BorderRadius? borderRadius;
  final TextInputType? keyboardType;
  final double? height;
  final TextStyle? valueStyle;
  final TextStyle? hintStyle;

  final List<IconDropdownCheckData> items;
  final dynamic selectValue;
  final List<dynamic>? selectValues;
  final bool multiSelect;
  final double? itemHeight;
  final double? menuHeight;
  final double? width;
  final double? itemFontSize;
  final EdgeInsetsGeometry? padding;
  final void Function(IconDropdownCheckData data, int index)? onChanged;

  const IconDropdownSelectWidget({
    super.key,
    this.hintText,
    this.fillColor = AppTheme.cSurfaceTertiary,
    this.borderColor = AppTheme.cBorderSecondary,
    this.borderRadius,
    this.keyboardType,
    this.height,
    this.valueStyle,
    this.hintStyle,
    required this.items,
    this.selectValue,
    this.selectValues,
    this.multiSelect = false,
    this.itemHeight,
    this.menuHeight,
    this.width,
    this.itemFontSize,
    this.padding,
    this.onChanged,
  });

  @override
  State<IconDropdownSelectWidget> createState() => _IconDropdownSelectWidgetState();
}

class _IconDropdownSelectWidgetState extends State<IconDropdownSelectWidget> {
  @override
  Widget build(BuildContext context) {

    IconDropdownCheckData? selectData;
    String? selectText;
    int selectIndex = widget.items.indexWhere((element) => element.value == widget.selectValue);
    Set<int>? selectIndexes;

    if (widget.multiSelect) {
      final List<dynamic> values = widget.selectValues ?? [];
      final List<String> titles = [];
      final Set<int> indexes = {};
      for (int i = 0; i < widget.items.length; i++) {
        final item = widget.items[i];
        if (values.contains(item.value)) {
          indexes.add(i);
          titles.add(item.title);
        }
      }
      selectIndexes = indexes;
      selectText = titles.join(' ').trim();
      if (selectIndex == -1 && selectIndexes.isNotEmpty) {
        selectIndex = selectIndexes.first;
      }
    } else {
      if(selectIndex != -1){
        selectData = widget.items[selectIndex];
      }
    }

    return IconDropdownCheckWidget(
      items: widget.items,
      selectIndex: selectIndex,
      selectIndexes: selectIndexes,
      multiSelect: widget.multiSelect,
      itemHeight: widget.itemHeight,
      width: widget.width,
      menuHeight: widget.menuHeight,
      sclae: 1,
      fontSize: widget.itemFontSize,
      onTap: (data, index){
        widget.onChanged?.call(data, index);
      },
      child: Container(
        width: widget.width?? double.infinity,
        height: widget.height??72.wMin,
        padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 16.wMin),
        decoration: BoxDecoration(
          color: widget.fillColor,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12.wMin),
          border: Border.all(
            color: widget.borderColor,
            width: 1.wMin,
          ),
        ),
        child: Row(
          children: [
            Visibility(
              visible: widget.multiSelect ? ((selectText ?? '').isNotEmpty) : (selectData != null),
              child: Expanded(
                child: Text(
                  widget.multiSelect ? (selectText ?? '') : (selectData?.title??""),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: widget.valueStyle ?? TextStyle(
                    fontSize: 28.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: widget.multiSelect ? ((selectText ?? '').isEmpty) : (selectData == null),
              child: Expanded(
                child: Text(
                  widget.hintText??"",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: widget.hintStyle ?? TextStyle(
                    fontSize: 28.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),

            SvgPicture.asset(
              "assets/svg/public/icon_caret_down.svg",
              width: 24.wMin,
            ),
          ],
        ),

      ),
    );
  }
}

/// 嵌套下拉菜单数据。
/// 使用 [children] 表示多级菜单结构，叶子节点通过 [value] 参与选中匹配。
class IconDropdownNestedData<T> {
  String title;
  String? iconSvg;
  String? subtitle;
  bool isEnable;
  T? value;
  List<IconDropdownNestedData<T>> children;

  IconDropdownNestedData({
    required this.title,
    this.subtitle,
    this.value,
    this.iconSvg,
    this.isEnable = true,
    List<IconDropdownNestedData<T>>? children,
  }) : children = children ?? <IconDropdownNestedData<T>>[];

  bool get hasChildren => children.isNotEmpty;
}

class _IconDropdownNestedMatch<T> {
  final IconDropdownNestedData<T> data;
  final List<int> indexes;

  const _IconDropdownNestedMatch({
    required this.data,
    required this.indexes,
  });
}

/// 基于 [MenuAnchor] 的嵌套下拉选择器。
/// 外层选择框视觉与 [IconDropdownSelectWidget] 保持一致，适合多级菜单场景。
class IconDropdownNestedSelectWidget<T> extends StatelessWidget {
  final String? hintText;
  final Color fillColor;
  final Color borderColor;
  final BorderRadius? borderRadius;
  final double? height;
  final TextStyle? valueStyle;
  final TextStyle? hintStyle;

  final List<IconDropdownNestedData<T>> items;
  final T? selectValue;
  final double? itemHeight;
  final double? menuHeight;
  final double? width;
  final double? itemFontSize;
  final void Function(IconDropdownNestedData<T> data, List<int> indexes)? onChanged;

  const IconDropdownNestedSelectWidget({
    super.key,
    this.hintText,
    this.fillColor = AppTheme.cSurfaceTertiary,
    this.borderColor = AppTheme.cBorderSecondary,
    this.borderRadius,
    this.height,
    this.valueStyle,
    this.hintStyle,
    required this.items,
    this.selectValue,
    this.itemHeight,
    this.menuHeight,
    this.width,
    this.itemFontSize,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final _IconDropdownNestedMatch<T>? selectMatch = _findSelectedData(
      items: items,
      selectValue: selectValue,
    );
    final double menuWidth = width ?? 260.wMin;
    final double currentItemHeight = itemHeight ?? 64.wMin;
    final double currentMenuHeight = menuHeight ?? (currentItemHeight * 5);

    return MenuAnchor(
      crossAxisUnconstrained: false,
      alignmentOffset: Offset(0, 5.wMin),
      style: _buildRootMenuStyle(
        menuWidth: menuWidth,
        menuHeight: currentMenuHeight,
      ),
      menuChildren: _buildMenuChildren(
        items: items,
        parentIndexes: const <int>[],
        menuWidth: menuWidth,
        itemHeight: currentItemHeight,
        menuHeight: currentMenuHeight,
      ),
      child: _buildSelectChild(selectData: selectMatch?.data),
      builder: (BuildContext context, MenuController controller, Widget? child) {
        return TapScaleWidget(
          sclae: 1,
          onTap: items.isEmpty ? null : () {
            FocusScope.of(context).requestFocus(FocusNode());
            if (controller.isOpen) {
              controller.close();
              return;
            }
            controller.open();
          },
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  MenuStyle _buildRootMenuStyle({
    required double menuWidth,
    required double menuHeight,
  }) {
    return MenuStyle(
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.zero),
      backgroundColor: WidgetStatePropertyAll<Color>(AppTheme.cBgTertiary),
      surfaceTintColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
      shadowColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
      elevation: const WidgetStatePropertyAll<double>(0),
      fixedSize: WidgetStatePropertyAll<Size>(Size.fromWidth(menuWidth)),
      side: WidgetStatePropertyAll<BorderSide>(
        BorderSide(
          color: AppTheme.cBorderPrimary,
          width: 1.wMin,
        ),
      ),
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.wMin),
        ),
      ),
      alignment: AlignmentDirectional.bottomStart,
    );
  }

  MenuStyle _buildSubMenuStyle({
    required double menuWidth,
    required double menuHeight,
  }) {
    return MenuStyle(
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.zero),
      backgroundColor: WidgetStatePropertyAll<Color>(AppTheme.cBgTertiary),
      surfaceTintColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
      shadowColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
      elevation: const WidgetStatePropertyAll<double>(0),
      fixedSize: WidgetStatePropertyAll<Size>(Size.fromWidth(menuWidth)),
      side: WidgetStatePropertyAll<BorderSide>(
        BorderSide(
          color: AppTheme.cBorderPrimary,
          width: 1.wMin,
        ),
      ),
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.wMin),
        ),
      ),
      alignment: AlignmentDirectional.topEnd,
    );
  }

  ButtonStyle _buildMenuButtonStyle(double itemHeight) {
    return ButtonStyle(
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.zero),
      minimumSize: WidgetStatePropertyAll<Size>(Size(0, itemHeight)),
      maximumSize: const WidgetStatePropertyAll<Size>(Size.infinite),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused) ||
            states.contains(WidgetState.pressed)) {
          return AppTheme.cSurfaceTertiary.color;
        }
        return Colors.transparent;
      }),
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.wMin),
        ),
      ),
    );
  }

  List<Widget> _buildMenuChildren({
    required List<IconDropdownNestedData<T>> items,
    required List<int> parentIndexes,
    required double menuWidth,
    required double itemHeight,
    required double menuHeight,
  }) {
    return List<Widget>.generate(items.length, (int index) {
      final IconDropdownNestedData<T> item = items[index];
      final List<int> currentIndexes = <int>[...parentIndexes, index];
      final bool isLast = index == items.length - 1;
      final bool isSelectedLeaf = !item.hasChildren && item.value == selectValue;
      final Widget itemChild = _IconDropdownNestedMenuTile<T>(
        data: item,
        itemHeight: itemHeight,
        fontSize: itemFontSize,
        showDivider: !isLast,
        isSelected: isSelectedLeaf,
        trailing: item.hasChildren
            ? Icon(
                Icons.keyboard_arrow_right_rounded,
                size: 28.wMin,
                color: AppTheme.cTextTertiary,
              )
            : (isSelectedLeaf
                ? SvgPicture.asset(
                    "assets/svg/public/icon_check.svg",
                    width: 24.wMin,
                    height: 24.wMin,
                  )
                : null),
      );

      if (item.hasChildren) {
        return SubmenuButton(
          style: _buildMenuButtonStyle(itemHeight),
          menuStyle: _buildSubMenuStyle(
            menuWidth: menuWidth,
            menuHeight: menuHeight,
          ),
          alignmentOffset: Offset(4.wMin, 0),
          submenuIcon: const WidgetStatePropertyAll<Widget?>(
            SizedBox.shrink(),
          ),
          menuChildren: _buildMenuChildren(
            items: item.children,
            parentIndexes: currentIndexes,
            menuWidth: menuWidth,
            itemHeight: itemHeight,
            menuHeight: menuHeight,
          ),
          child: itemChild,
        );
      }

      return MenuItemButton(
        style: _buildMenuButtonStyle(itemHeight),
        closeOnActivate: true,
        onPressed: item.isEnable
            ? () {
                onChanged?.call(item, currentIndexes);
              }
            : null,
        child: itemChild,
      );
    });
  }

  _IconDropdownNestedMatch<T>? _findSelectedData({
    required List<IconDropdownNestedData<T>> items,
    required T? selectValue,
    List<int> parentIndexes = const <int>[],
  }) {
    for (int index = 0; index < items.length; index++) {
      final IconDropdownNestedData<T> item = items[index];
      final List<int> currentIndexes = <int>[...parentIndexes, index];

      if (!item.hasChildren && item.value == selectValue) {
        return _IconDropdownNestedMatch<T>(
          data: item,
          indexes: currentIndexes,
        );
      }

      if (!item.hasChildren) {
        continue;
      }

      final _IconDropdownNestedMatch<T>? childMatch = _findSelectedData(
        items: item.children,
        selectValue: selectValue,
        parentIndexes: currentIndexes,
      );

      if (childMatch != null) {
        return childMatch;
      }
    }

    return null;
  }

  Widget _buildSelectChild({
    required IconDropdownNestedData<T>? selectData,
  }) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 72.wMin,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: borderRadius ?? BorderRadius.circular(12.wMin),
        border: Border.all(
          color: borderColor,
          width: 1.wMin,
        ),
      ),
      child: Row(
        children: [
          Visibility(
            visible: selectData != null,
            child: Expanded(
              child: Text(
                selectData?.title ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: valueStyle ??
                    TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ),
          Visibility(
            visible: selectData == null,
            child: Expanded(
              child: Text(
                hintText ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: hintStyle ??
                    TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextTertiary.color,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ),
          ),
          SvgPicture.asset(
            "assets/svg/public/icon_caret_down.svg",
            width: 24.wMin,
          ),
        ],
      ),
    );
  }
}

class _IconDropdownNestedMenuTile<T> extends StatefulWidget {
  final IconDropdownNestedData<T> data;
  final double itemHeight;
  final double? fontSize;
  final bool showDivider;
  final bool isSelected;
  final Widget? trailing;

  const _IconDropdownNestedMenuTile({
    required this.data,
    required this.itemHeight,
    required this.fontSize,
    required this.showDivider,
    required this.isSelected,
    this.trailing,
  });

  @override
  State<_IconDropdownNestedMenuTile<T>> createState() => _IconDropdownNestedMenuTileState<T>();
}

class _IconDropdownNestedMenuTileState<T> extends State<_IconDropdownNestedMenuTile<T>> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color titleColor = widget.data.isEnable
        ? AppTheme.cTextPrimary
        : AppTheme.cTextDisabled;
    return MouseRegion(
      cursor: widget.data.isEnable ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) {
        if (!_isHovered) {
          setState(() {
            _isHovered = true;
          });
        }
      },
      onExit: (_) {
        if (_isHovered) {
          setState(() {
            _isHovered = false;
          });
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        height: widget.itemHeight,
        decoration: BoxDecoration(
          color: _isHovered ? AppTheme.cSurfaceTertiary.color : Colors.transparent,
          borderRadius: BorderRadius.circular(10.wMin),
          border: Border(
            bottom: BorderSide(
              color: widget.showDivider ? AppTheme.cBorderPrimary : Colors.transparent,
              width: 1.wMin,
            ),
          ),
        ),
        child: Row(
          children: [
            Visibility(
              visible: widget.data.iconSvg != null && widget.data.iconSvg != "",
              child: Container(
                margin: EdgeInsets.only(right: 6.wMin),
                child: SvgPicture.asset(
                  widget.data.iconSvg ?? "",
                  width: 24.wMin,
                  height: 24.wMin,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: widget.fontSize ?? 20.wMin,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Visibility(
                    visible: widget.data.subtitle != null && widget.data.subtitle != "",
                    child: Text(
                      widget.data.subtitle ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.cTextSecondary,
                        fontSize: 14.wMin,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: widget.trailing != null,
              child: Container(
                margin: EdgeInsets.only(left: 8.wMin),
                child: widget.trailing ?? const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
