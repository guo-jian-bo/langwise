import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/common/widgets/build_image.dart';
import 'package:langwise/generated/assets.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';

class DropdownWidget extends StatefulWidget {
  final Widget child;
  final double sclae;
  final double itemSclae;
  final double spacing;
  final EdgeInsets? dropPadding;
  final EdgeInsets? itemPadding;
  final double? itemBorderRadius;
  final List<String> children;
  final Color backgroundColor;
  final int selectedIndex;
  final Color? itemBorderColor;
  final Color boxBorderColor;
  final TextStyle? textStyle;
  final void Function()? onShow;
  final void Function()? onHide;
  final void Function(int index)? onTap;

  const DropdownWidget({
    super.key,
    required this.child,
    required this.children,
    this.sclae = 1.05,
    this.itemSclae = 1.05,
    this.dropPadding,
    this.itemPadding,
    this.itemBorderRadius,
    this.spacing = 0,
    this.backgroundColor = const Color(0xff262F38),
    this.selectedIndex = -1,
    this.textStyle,
    this.onTap, 
    this.itemBorderColor,
    this.boxBorderColor = Colors.transparent, 
    this.onShow, 
    this.onHide,
  });

  @override
  State<DropdownWidget> createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> with WidgetsBindingObserver {
  GlobalKey childKey = GlobalKey();

  OverlayEntry? currentOverlayEntry;

  bool show = false;

  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    selectedIndex = widget.selectedIndex;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      show = false;
      widget.onHide?.call();
      if (mounted) setState(() {});
      if (currentOverlayEntry != null) {
        currentOverlayEntry?.remove();
        currentOverlayEntry = null;
      }
    }
  }

  @override
  void didUpdateWidget(covariant DropdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    selectedIndex = widget.selectedIndex;
  }

  Future<void> showDrop() async {
    RenderBox? mainRender = context.findRenderObject() as RenderBox?;
    RenderBox? renderBox = childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || mainRender == null) return;
    
    // 获取全局坐标
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        renderBox.localToGlobal(Offset.zero, ancestor: overlay),
        renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    
    Size size = renderBox.size;
    MediaQueryData main = MediaQuery.of(context);

    currentOverlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: hideDrop,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  left: position.left,
                  top: position.top + size.height,
                  child: Container(
                    width: renderBox.size.width,
                    constraints: BoxConstraints(
                      maxHeight: main.size.height - position.top - size.height - main.padding.bottom - 80.wMin,
                    ),
                    child: listWidget(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(currentOverlayEntry!);
    await Future.delayed(const Duration(milliseconds: 100));
    show = true;
    widget.onShow?.call();
    currentOverlayEntry?.markNeedsBuild();
    if (mounted) setState(() {});
  }

  Future<void> hideDrop() async {
    show = false;
    widget.onHide?.call();
    if (mounted) setState(() {});
    currentOverlayEntry?.markNeedsBuild();
    await Future.delayed(const Duration(milliseconds: 100));
    currentOverlayEntry?.remove();
    currentOverlayEntry = null;
  }

  Widget listWidget() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.wMin),
        border: Border.all(width: 0.5.wMin, color: widget.boxBorderColor),
        color: widget.backgroundColor,
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 100),
        alignment: Alignment.topCenter,
        child: Container(
          height: show ? null : 0,
          padding: widget.dropPadding ?? EdgeInsets.symmetric(horizontal: 20.ww, vertical: 20.wh),
          child: AnimationLimiter(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.children.length, (index) {
                  return AnimationConfiguration.staggeredList(
                    duration: const Duration(milliseconds: 200),
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: TapScaleWidget(
                          sclae: widget.itemSclae,
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: index == widget.children.length - 1 ? 0 : widget.spacing,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding:
                                  widget.itemPadding ?? EdgeInsets.symmetric(horizontal: 20.ww, vertical: 10.wh),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(widget.itemBorderRadius ?? 10.wMin),
                                color: const Color(0xffC2E6FF).withValues(
                                  alpha: selectedIndex == index ? 0.1 : 0,
                                ),
                                border: Border.all(
                                  width: 1.wMin, 
                                  color: widget.itemBorderColor??const Color(0xffE5F5FF).withValues(alpha: 0.28),
                                ),
                              ),
                              child: AutoSizeText(
                                widget.children[index],
                                maxLines: 1,
                                minFontSize: 6,
                                style: widget.textStyle ??
                                    TextStyle(
                                      fontSize: 28.wMin,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ),
                          onTap: widget.onTap == null
                              ? null
                              : () async {
                                  selectedIndex = index;
                                  currentOverlayEntry?.markNeedsBuild();
                                  await Future.delayed(const Duration(milliseconds: 200));
                                  // selectedIndex = -1;
                                  widget.onTap?.call(index);
                                  hideDrop();
                                },
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: childKey,
      child: TapScaleWidget(
        sclae: widget.sclae,
        child: widget.child,
        onTap: widget.children.isEmpty ? null : () => showDrop(),
      ),
    );
  }
}

class DropdownPopData {
  bool show;
  String name;
  int index;
  String? svgPath;

  DropdownPopData({
    this.show = true,
    required this.name,
    required this.index,
    this.svgPath,
  });
}

class DropdownPop {
  static Future<DropdownPopData?> show({
    required BuildContext context,
    required GlobalKey globalKey,
    Widget? child,
    double menuItemWidth = 150,
    required List<DropdownPopData> list,
  }) async {
    return await showDialog<DropdownPopData?>(
      context: globalKey.currentContext!,
      useSafeArea: false,
      useRootNavigator: true,
      builder: (context) {
        return Material(
          color: const Color(0xff141828).withValues(alpha: 0.7),
          child: Center(
            child: DropdownContentWidget(
              list: list,
              globalKey: globalKey,
              child: child,
              menuItemWidth: menuItemWidth,
            ),
          ),
        );
      },
    );
  }
}

class DropdownContentWidget extends StatefulWidget {
  final GlobalKey globalKey;
  final List<DropdownPopData> list;
  final Widget? child;
  final double menuItemWidth;

  const DropdownContentWidget({
    super.key,
    required this.list,
    this.child,
    required this.globalKey,
    required this.menuItemWidth,
  });

  @override
  State<DropdownContentWidget> createState() => _DropdownContentWidgetState();
}

class _DropdownContentWidgetState extends State<DropdownContentWidget> with WidgetsBindingObserver {
  final double childScale = 1.1;
  Offset childOffset = Offset.zero;
  Size childSize = Size.zero;
  int? selectIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    RenderBox? childRen = widget.globalKey.currentContext?.findRenderObject() as RenderBox?;
    if (childRen != null) {
      childOffset = childRen.localToGlobal(Offset.zero);
      childSize = childRen.size;
    }
    showMenu();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      BotToast.cleanAll();
    }
  }

  void showMenu() {
    BotToast.showAttachedWidget(
      targetContext: widget.globalKey.currentContext,
      preferDirection: PreferDirection.rightTop,
      horizontalOffset: 40.ww,
      animationDuration: Duration.zero,
      animationReverseDuration: Duration.zero,
      attachedBuilder: (closeBotToast) {
        double scaledHeight = childSize.height * childScale;
        double topOffset = (scaledHeight - childSize.height) / 2;

        return Transform.translate(
          offset: Offset(0, -topOffset),
          child: _DropdownContentWidgetMenu(
            list: widget.list,
            menuItemWidth: widget.menuItemWidth,
            onTap: (index) {
              selectIndex = index;
              closeBotToast();
            },
          ),
        );
      },
      onClose: () {
        if (selectIndex != null) {
          Navigator.pop(context, widget.list[selectIndex!]);
        } else {
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      width: double.infinity,
      height: double.infinity,
      child: Transform.translate(
        offset: childOffset,
        child: Transform.scale(
          scale: childScale,
          child: SizedBox(
            width: childSize.width,
            height: childSize.height,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _DropdownContentWidgetMenu extends StatefulWidget {
  final List<DropdownPopData> list;
  final double menuItemWidth;
  final void Function(int)? onTap;

  const _DropdownContentWidgetMenu({
    required this.list,
    required this.menuItemWidth,
    this.onTap,
  });

  @override
  State<_DropdownContentWidgetMenu> createState() => __DropdownContentWidgetMenuState();
}

class __DropdownContentWidgetMenuState extends State<_DropdownContentWidgetMenu> with SafeSetStateMixin {
  int selectIndex = -1;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.wMin),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xff2F364C),
          
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.list.length, (index) {
            if (!widget.list[index].show) return Container(width: 0);
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              onHover: (event) {
                safeSetState(() {
                  selectIndex = index;
                });
              },
              onExit: (event) {
                safeSetState(() {
                  selectIndex = -1;
                });
              },
              child: GestureDetector(
                onTapDown: (details) {
                  safeSetState(() {
                    selectIndex = index;
                  });
                },
                onTapCancel: () {
                  safeSetState(() {
                    selectIndex = -1;
                  });
                },
                onTapUp: (details) {
                  widget.onTap?.call(index);
                },
                child: Container(
                  width: widget.menuItemWidth,
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 12.wMin),
                  decoration: BoxDecoration(
                      color: selectIndex == index ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
                      border: index == widget.list.length - 1
                          ? null
                          : Border(
                              bottom: BorderSide(
                                width: 1.wh,
                                color: const Color(0xff444B5F),
                              ),
                            )),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.list[index].name,
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: Colors.white,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      buildImage(Assets.managerDropdownMenu, width: 24.wMax, height: 24.wMax)
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class DropdownFloat {
  static void show({
    required BuildContext context,
    required List<String> list,
    int initIndex = 0,
    void Function(int index)? onTap,
  }) {
    BotToast.showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.rightTop,
      animationDuration: Duration.zero,
      animationReverseDuration: Duration.zero,
      horizontalOffset: 14.0.ww,
      allowClick: false,
      attachedBuilder: (closeBotToast) {
        return _DropdownFloatWidget(
          list: list,
          initIndex: initIndex,
          onTap: (index) {
            closeBotToast();
            onTap?.call(index);
          },
        );
      },
    );
  }
}

class _DropdownFloatWidget extends StatefulWidget {
  final List<String> list;
  final int initIndex;
  final void Function(int index)? onTap;

  const _DropdownFloatWidget({required this.list, required this.initIndex, this.onTap});

  @override
  State<_DropdownFloatWidget> createState() => __DropdownFloatWidgetState();
}

class __DropdownFloatWidgetState extends State<_DropdownFloatWidget> {
  int hoverIndex = -1;

  int selectIndex = 0;

  @override
  void initState() {
    super.initState();
    selectIndex = widget.initIndex;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.wMin),
      child: Container(
        width: 188.ww,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: const Color(0xff303650),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.list.length, (index) {
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              onHover: (event) {
                hoverIndex = index;
                if (mounted) setState(() {});
              },
              onExit: (event) {
                hoverIndex = -1;
                if (mounted) setState(() {});
              },
              child: GestureDetector(
                onTapDown: (details) {
                  hoverIndex = index;
                  if (mounted) setState(() {});
                },
                onTapCancel: () {
                  hoverIndex = -1;
                  if (mounted) setState(() {});
                },
                onTapUp: (details) {
                  selectIndex = index;
                  widget.onTap?.call(index);
                },
                child: Container(
                  height: 44.wh,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 16.ww),
                  decoration: BoxDecoration(
                    color: hoverIndex == index ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
                    border: index == widget.list.length - 1
                        ? null
                        : Border(
                            bottom: BorderSide(
                              width: 1.wh,
                              color: const Color(0xff19213D).withValues(alpha: 0.65),
                            ),
                          ),
                  ),
                  child: Row(
                    children: [
                      Opacity(
                        opacity: selectIndex == index ? 1 : 0,
                        child: SvgPicture.asset("assets/svg/manage/icon_check.svg", width: 16.ww),
                      ),
                      SizedBox(width: 16.ww),
                      Text(
                        widget.list[index],
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: selectIndex == index ? Colors.white : const Color(0xffCFD5DF),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
