import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:themed/themed.dart';

class TapScaleWidget extends StatefulWidget {
  final Widget child;
  final double sclae;
  final int milliseconds;
  final HitTestBehavior? behavior;
  final Color? backColor;
  final double borderRadius;
  final void Function()? onTap;
  final void Function()? onLongPress;
  /// 点击放大的按钮
  const TapScaleWidget({
    super.key, 
    required this.child, 
    this.sclae = 1.2, 
    this.onTap, 
    this.milliseconds = 100, 
    this.backColor, 
    this.behavior, 
    this.onLongPress, 
    this.borderRadius = 0,
  });

  @override
  State<TapScaleWidget> createState() => _TapScaleWidgetState();
}

class _TapScaleWidgetState extends State<TapScaleWidget> {
  bool isTap = false;
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    if(widget.onTap == null && widget.onLongPress == null){
      return widget.child;
    }

    return MouseRegion(
      cursor: widget.onTap == null ? MouseCursor.uncontrolled : SystemMouseCursors.click,
      onEnter: (e){
        isHover = true;
        if(mounted) setState(() {});
      },
      onExit: (e){
        isHover = false;
        if(mounted) setState(() {});
      },
      child: GestureDetector(
        behavior: widget.behavior,
        onTapDown: widget.onTap == null ? null : (details) {
          if(widget.onTap == null) return;
          isTap = true;
          if(mounted) setState(() {});
        },
        onTapCancel: widget.onTap == null ? null : () {
          Future.delayed(Duration(milliseconds: widget.milliseconds), (){
            isTap = false;
            if(mounted) setState(() {});
          });
        },
        onTapUp: widget.onTap == null ? null : (details) {
          Future.delayed(Duration(milliseconds: widget.milliseconds), (){
            isTap = false;
            if(mounted) setState(() {});
          });
          widget.onTap?.call();
        },
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: isTap ? widget.sclae : 1,
          duration: Duration(milliseconds: widget.milliseconds),
          child: AnimatedContainer(
            duration: Duration(milliseconds: widget.milliseconds),
            decoration: BoxDecoration(
              color: widget.backColor?.addOpacity(isTap || isHover ? 1 : 0),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class TapScaleLongRightWidget extends StatefulWidget {
  final Widget child;
  final double sclae;
  final int milliseconds;
  final HitTestBehavior? behavior;
  final void Function(Offset globalPosition, Offset localPosition)? onLongSecondaryTap;
  final void Function()? onTap;
  /// onLongSecondaryTap 移动端是长按 pc端是鼠标右键
  const TapScaleLongRightWidget({
    super.key, 
    required this.child, 
    this.sclae = 1.2, 
    this.onLongSecondaryTap, 
    this.milliseconds = 100, 
    this.behavior, 
    this.onTap,
  });

  @override
  State<TapScaleLongRightWidget> createState() => _TapScaleLongRightWidgetState();
}

class _TapScaleLongRightWidgetState extends State<TapScaleLongRightWidget> {
  bool isTap = false;
  Offset globalPosition = Offset.zero;
  Offset localPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    bool isMobile = Platform.isAndroid || Platform.isIOS;

    Widget bodyWidget = AnimatedScale(
      scale: isTap ? widget.sclae : 1,
      duration: Duration(milliseconds: widget.milliseconds),
      child: widget.child,
    );

    if(isMobile){
      return GestureDetector(
        behavior: widget.behavior,
        onTap: widget.onTap,
        onLongPressDown: widget.onLongSecondaryTap == null ? null : (details) {
          if(widget.onLongSecondaryTap == null) return;
          isTap = true;
          globalPosition = details.globalPosition;
          localPosition = details.localPosition;
          if(mounted) setState(() {});
        },
        onLongPressCancel: widget.onLongSecondaryTap == null ? null : () {
          Future.delayed(Duration(milliseconds: widget.milliseconds), (){
            isTap = false;
            if(mounted) setState(() {});
          });
        },
        onLongPressStart:  widget.onLongSecondaryTap == null ? null : (details) {
          isTap = false;
          if(mounted) setState(() {});
          widget.onLongSecondaryTap?.call(details.globalPosition, details.localPosition);
        },
        child: bodyWidget,
      );
    }

    return MouseRegion(
      cursor: widget.onLongSecondaryTap == null ? MouseCursor.uncontrolled : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: widget.behavior,
        onTap: widget.onTap,
        onSecondaryTapDown: widget.onLongSecondaryTap == null ? null : (details) {
          if(widget.onLongSecondaryTap == null) return;
          isTap = true;
          if(mounted) setState(() {});
        },
        onSecondaryTapCancel: widget.onLongSecondaryTap == null ? null : () {
          Future.delayed(Duration(milliseconds: widget.milliseconds), (){
            isTap = false;
            if(mounted) setState(() {});
          });
        },
        onSecondaryTapUp: widget.onLongSecondaryTap == null ? null : (TapUpDetails details) {
          Future.delayed(Duration(milliseconds: widget.milliseconds), (){
            isTap = false;
            if(mounted) setState(() {});
          });
          widget.onLongSecondaryTap?.call(details.globalPosition, details.localPosition);
        },
        child: bodyWidget,
      ),
    );
  }
}


class TapScaleLongHoverWidget extends StatefulWidget {
  final Widget child;
  final double sclae;
  final HitTestBehavior? behavior;
  final void Function(LongPressStartDetails details, BuildContext context)? onLongPressStart;
  final void Function(LongPressEndDetails details, BuildContext context)? onLongPressEnd;
  final void Function()? onLongPressCancel;
  final void Function(PointerEnterEvent event, BuildContext context)? onEnter;
  final void Function(PointerExitEvent event, BuildContext context)? onExit;

  /// pc端是悬浮 移动端是长按
  const TapScaleLongHoverWidget({
    super.key,
    required this.child,
    this.sclae = 1,
    this.behavior,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.onLongPressCancel,
    this.onEnter,
    this.onExit,
  });

  @override
  State<TapScaleLongHoverWidget> createState() => _TapScaleLongHoverWidgetState();
}

class _TapScaleLongHoverWidgetState extends State<TapScaleLongHoverWidget> {
  bool isTap = false;

  @override
  Widget build(BuildContext context) {
    bool isMobile = Platform.isAndroid || Platform.isIOS;

    Widget bodyWidget = AnimatedScale(
      scale: isTap ? widget.sclae : 1,
      duration: const Duration(milliseconds: 100),
      child: widget.child,
    );

    return Builder(
      builder: (ctx) {
        if(isMobile){
          return GestureDetector(
            behavior: widget.behavior,
            onLongPressStart: (details) => widget.onLongPressStart?.call(details, ctx),
            onLongPressEnd: (details) => widget.onLongPressEnd?.call(details, ctx),
            onLongPressCancel: widget.onLongPressCancel,
            child: bodyWidget,
          );
        }

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (event) => widget.onEnter?.call(event, ctx),
          onExit: (event) => widget.onExit?.call(event, ctx),
          child: bodyWidget,
        );
      },
    );
  }
}
