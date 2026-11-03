import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

import '../builder/reorderable_animated_builder.dart';

class ReorderableGridDragStartListener extends StatelessWidget {
  /// 创建一个监听器，用于在指定子部件上检测到指针按下事件后立即进行拖动。
  ///
  /// 这通常用于包装网格项目的一部分，例如拖动手柄。
  const ReorderableGridDragStartListener({
    Key? key,
    required this.child,
    required this.index,
    this.enabled = true,
  }) : super(key: key);

  /// 应用程序希望通过在可重新排序的网格上启动重新排序拖动来响应点击和拖动手势的部件。
  final Widget child;

  /// 将在网格中被拖动的关联项目的索引。
  final int index;

  /// 确定 [child] 项目是否可以在网格中被拖动和移动。
  ///
  /// 如果为 true，则当用户点击子部件时，项目可以被移动到网格中的其他位置。
  /// 如果为 false，则点击子部件将被忽略。
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: enabled ? (PointerDownEvent event) => _startDragging(context, event) : null,
      child: child,
    );
  }

  /// 提供用于指示重新排序拖动操作开始的手势识别器。
  ///
  /// 默认情况下，这会返回 [ImmediateMultiDragGestureRecognizer]，
  /// 但子类可以使用此方法自定义拖动开始手势。
  @protected
  MultiDragGestureRecognizer createRecognizer() {
    return ImmediateMultiDragGestureRecognizer(debugOwner: this);
  }

  void _startDragging(BuildContext context, PointerDownEvent event) {
    // 注意：event.position 是全局坐标（相对于整个屏幕的位置），而非局部坐标
    // 这对于跨容器拖拽至关重要，因为无论组件嵌套多深，全局坐标都是一致的参考系
    // 如果需要局部坐标，需要使用 context.findRenderObject().globalToLocal(event.position)
    print('[$runtimeType]【拖拽监听】开始拖拽操作，索引: $index, 【全局坐标日志】位置: ${event.position}');
    // 获取手势设置
    final DeviceGestureSettings? gestureSettings = MediaQuery.maybeGestureSettingsOf(context);
    final ReorderableAnimatedBuilderState? list = ReorderableAnimatedBuilder.maybeOf(context);

    // 启动拖拽重排序
    list?.startItemDragReorder(
      index: index,
      event: event, // 传递原始事件，保留全局坐标信息
      recognizer: createRecognizer()..gestureSettings = gestureSettings,
    );
  }
}

/// 一个包装部件，它通过寻找长按事件来识别拖动操作的开始。
/// 一旦识别出长按，它将在可重新排序的网格中的包装项目上开始拖动操作。
///
/// 另请参阅:
///
///  * [ReorderableGridDragStartListener]，一个类似的包装器，它将在指针按下事件后立即识别拖动的开始。
///  * [ReorderableGrid]，一个允许用户重新排序其项目的部件网格。
///  * [SliverReorderableGrid]，一个允许用户重新排序其项目的sliver网格。
///  * [ReorderableGridView]，一个允许用户重新排序其项目的Material设计网格。
class ReorderableGridDelayedDragStartListener extends ReorderableGridDragStartListener {
  final Duration dragStartDelay;

  /// 创建一个监听器，用于在指定子部件上长按后进行拖动。
  ///
  /// 这通常用于包装可重新排序网格中的整个网格项目。
  /// 使用长按触发拖拽对于跨容器拖拽特别有用，因为用户有足够时间准备拖动操作。
  const ReorderableGridDelayedDragStartListener({
    Key? key,
    required Widget child,
    required int index,
    required this.dragStartDelay,
    bool enabled = true,
  }) : super(key: key, child: child, index: index, enabled: enabled);

  @override
  MultiDragGestureRecognizer createRecognizer() {
    // print('[$runtimeType]【延迟拖拽监听】创建延迟手势识别器, 延迟时间: $dragStartDelay');
    return DelayedMultiDragGestureRecognizer(delay: dragStartDelay, debugOwner: this);
  }
}
