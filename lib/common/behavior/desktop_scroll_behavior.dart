import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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
