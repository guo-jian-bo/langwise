import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'guide_task_controller.dart';

class GuidePageBoxWidget extends StatefulWidget {
  final String pageCode;
  final Widget child;
  const GuidePageBoxWidget({
    super.key,
    required this.pageCode,
    required this.child,
  });

  @override
  State<GuidePageBoxWidget> createState() => _GuidePageBoxWidgetState();
}

class _GuidePageBoxWidgetState extends State<GuidePageBoxWidget> {
  GuideTaskController? _findController() {
    if (!Get.isRegistered<GuideTaskController>()) {
      return null;
    }
    return GuideTaskController.to;
  }

  @override
  Widget build(BuildContext context) {
    final GuideTaskController? controller = _findController();
    if (controller == null) {
      return widget.child;
    }

    return Obx(() {
      controller.pageProgressMap.length;
      final bool shouldLock = controller.shouldLockPage(widget.pageCode);

      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          widget.child,
          if (shouldLock) _buildLockLayer(),
        ],
      );
    });
  }

  Widget _buildLockLayer() {
    return Positioned.fill(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) {},
        onPointerSignal: (_) {},
        child: const AbsorbPointer(
          absorbing: true,
          child: ColoredBox(color: Colors.transparent),
        ),
      ),
    );
  }

}
