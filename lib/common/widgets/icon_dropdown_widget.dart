
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

  Future<void> showCheck(BuildContext ctx) async{
    if(widget.items.isEmpty) return;

    if(Platform.isIOS && widget.isIosAwait){
      await Future.delayed(const Duration(milliseconds: 350));
    }

    final RenderBox button = ctx.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(ctx).context.findRenderObject() as RenderBox;
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
          enabled: widget.selectIndex != index && widget.items[index].isEnable,
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
                  visible: widget.selectIndex == index,
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
  final double? itemHeight;
  final double? menuHeight;
  final double? width;
  final double? itemFontSize;
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
    this.itemHeight,
    this.menuHeight,
    this.width,
    this.itemFontSize,
    this.onChanged,
  });

  @override
  State<IconDropdownSelectWidget> createState() => _IconDropdownSelectWidgetState();
}

class _IconDropdownSelectWidgetState extends State<IconDropdownSelectWidget> {
  @override
  Widget build(BuildContext context) {

    IconDropdownCheckData? selectData;

    int selectIndex = widget.items.indexWhere((element) => element.value == widget.selectValue);

    if(selectIndex != -1){
      selectData = widget.items[selectIndex];
    }

    return IconDropdownCheckWidget(
      items: widget.items,
      selectIndex: selectIndex,
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
        padding: EdgeInsets.symmetric(horizontal: 16.wMin),
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
              visible: selectData != null,
              child: Expanded(
                child: Text(
                  selectData?.title??"",
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
              visible: selectData == null,
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
