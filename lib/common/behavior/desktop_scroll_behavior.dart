import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 桌面端滚动行为配置。
///
/// 作用：
/// 1. 允许鼠标、触控板、触控笔等设备通过拖拽触发滚动；
/// 2. 在 Windows/macOS/Linux 上为可滚动组件自动包裹 `Scrollbar`，
///    提供更符合桌面端习惯的滚动条交互。
class DesktopScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch, //触摸
        PointerDeviceKind.mouse, //鼠标
        PointerDeviceKind.trackpad, //触控板
        PointerDeviceKind.invertedStylus, //触控笔倒置
        PointerDeviceKind.stylus, //触控笔指针
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    if (Platform.isMacOS) {
      return const _MacScrollPhysics();
    }
    return super.getScrollPhysics(context);
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return Scrollbar(
        controller: details.controller,
        child: child,
      );
    }
    return child;
  }
}

/// macOS 端滚动物理参数，仅限幅异常尖峰位移，尽量保持原生滚动手感。
class _MacScrollPhysics extends ClampingScrollPhysics {
  const _MacScrollPhysics({super.parent});

  static const double _maxUserOffsetPerFrame = 80;

  @override
  _MacScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _MacScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    final userOffset = super.applyPhysicsToUserOffset(position, offset);
    if (userOffset > _maxUserOffsetPerFrame) {
      return _maxUserOffsetPerFrame;
    }
    if (userOffset < -_maxUserOffsetPerFrame) {
      return -_maxUserOffsetPerFrame;
    }
    return userOffset;
  }

}
