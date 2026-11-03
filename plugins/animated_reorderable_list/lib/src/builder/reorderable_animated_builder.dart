/// # 拖拽浮层消失问题解决方案
///
/// ## 问题描述
/// 在拖拽过程中，当新单元进入可视区域时，拖拽浮层会突然消失，导致拖拽操作被中断。
/// 这是由Flutter组件的生命周期机制导致的：新单元加载触发组件树重建，原容器被销毁，
/// 从而导致拖拽状态丢失。
///
/// ## 解决方案
/// 1. **扩大缓存范围**：在CustomScrollView中设置cacheExtent=1000，预加载所有可能
///    进入视图的单元，防止在拖拽过程中触发容器的销毁和重建。
///    ```dart
///    CustomScrollView(
///      cacheExtent: 1000,
///      // 其他属性...
///    )
///    ```
///
/// 2. **项目级保活**：ReorderableAnimatedWidget使用AutomaticKeepAliveClientMixin，
///    确保单个项目不会被回收，保持拖拽过程中的状态一致性。
///    ```dart
///    class ReorderableAnimatedWidgetState extends State<ReorderableAnimatedWidget>
///        with AutomaticKeepAliveClientMixin {
///      @override
///      bool get wantKeepAlive => true;
///    }
///    ```
///
/// 3. **控制拖出行为**：添加canDragOutItem属性，允许控制项目是否可以拖出当前容器，
///    更精细地管理跨容器拖拽行为。
///
/// 4. **详细日志系统**：关键拖拽方法中添加条件日志，便于排查问题。
///
/// 这种多层次的解决方案确保了拖拽操作的流畅性和稳定性，符合项目的架构规范。

import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../component/drag_listener.dart';
import '../model/item_transition_data.dart';
import '../model/cross_container_data.dart';
import 'reorderable_animated_list_base.dart';

part '../component/drag_item.dart';

part '../component/reorderable_animated_widget.dart';

typedef CustomAnimatedWidgetBuilder<E> = Widget Function(
    BuildContext context, Widget child, Animation<double> animation);

class ReorderableAnimatedBuilder<E> extends StatefulWidget {
  final CustomAnimatedWidgetBuilder<E> insertAnimationBuilder;
  final CustomAnimatedWidgetBuilder<E> removeAnimationBuilder;
  final ReorderCallback? onReorder;
  final void Function(int index)? onReorderStart;
  final void Function(int index)? onReorderEnd;

  final ReorderItemProxyDecorator? proxyDecorator;
  final ItemBuilder itemBuilder;
  final int initialCount;
  final Axis scrollDirection;
  final SliverGridDelegate? delegateBuilder;
  final bool buildDefaultDragHandles;
  final Duration dragStartDelay;
  final List<int> nonDraggableIndices;
  final List<int> lockedIndices;

  /// 数据获取器回调
  /// 用于获取指定索引处的实际数据模型，而不是界面组件
  /// 在跨容器拖拽时用于传递实际数据
  final ItemDataGetter? itemDataGetter;

  /// 容器的唯一标识符
  /// 用于在跨容器拖拽时识别源容器和目标容器
  final dynamic containerId;

  /// 是否允许接收跨容器拖拽
  /// 如果为true，则可以接收来自其他容器的项目
  final bool canReceiveItem;

  /// 是否允许项目拖出当前容器
  /// 如果为true，则项目可以被拖出到其他容器
  /// 如果为false，当拖拽结束时，项目会回到原来的位置
  final bool canDragOutItem;

  /// 拖拽更新回调
  /// 当拖拽位置更新时触发，提供当前的拖拽信息
  /// 主要用于让外部组件根据拖拽位置进行额外操作，如水平滚动列表
  final void Function(CrossContainerData containerData)? onDragUpdate;

  /// 拖拽结束回调
  /// 当拖拽位置结束时触发，提供当前的拖拽信息
  /// 主要用于让外部组件根据拖拽位置进行额外操作
  final bool Function(CrossContainerData containerData)? onDragEnd;

  const ReorderableAnimatedBuilder(
      {Key? key,
      required this.itemBuilder,
      required this.insertAnimationBuilder,
      required this.removeAnimationBuilder,
      this.onReorder,
      this.onReorderEnd,
      this.onReorderStart,
      this.proxyDecorator,
      this.initialCount = 0,
      this.delegateBuilder,
      this.scrollDirection = Axis.vertical,
      required this.buildDefaultDragHandles,
      required this.dragStartDelay,
      required this.nonDraggableIndices,
      required this.lockedIndices,
      this.itemDataGetter,
      this.containerId,
      this.canReceiveItem = false,
      this.canDragOutItem = true,
      this.onDragUpdate,
      this.onDragEnd})
      : assert(initialCount >= 0),
        super(key: key);

  @override
  State<ReorderableAnimatedBuilder> createState() => ReorderableAnimatedBuilderState();

  static ReorderableAnimatedBuilderState of(BuildContext context) {
    final ReorderableAnimatedBuilderState? result = context.findAncestorStateOfType<ReorderableAnimatedBuilderState>();
    assert(() {
      if (result == null) {
        throw FlutterError(
          'ReorderableAnimatedBuilderState.of() called with a context that does not contain a ReorderableAnimatedBuilderState.\n'
          'No ReorderableAnimatedBuilderState ancestor could be found starting from the '
          'context that was passed to ReorderableAnimatedBuilderState.of(). This can '
          'happen when the context provided is from the same StatefulWidget that '
          'built the AnimatedList.'
          'The context used was:\n'
          '  $context',
        );
      }
      return true;
    }());
    return result!;
  }

  static ReorderableAnimatedBuilderState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<ReorderableAnimatedBuilderState>();
  }
}

/// ReorderableAnimatedBuilderState 类是 ReorderableAnimatedBuilder 的状态类，
/// 负责管理可重新排序的动画列表/网格的核心功能。
///
/// 该类实现了以下核心功能：
/// 1. 项目的拖拽与重新排序
/// 2. 项目的添加和移除动画
/// 3. 自动滚动以支持长列表的拖拽
/// 4. 拖拽时的视觉反馈
/// 5. 锁定特定项目使其不可拖拽
///
class ReorderableAnimatedBuilderState extends State<ReorderableAnimatedBuilder>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  /// 跨容器通信器，用于在容器之间传递拖拽事件
  final CrossContainerCommunicator _communicator = CrossContainerCommunicator();

  /// 跨容器事件订阅
  StreamSubscription<CrossContainerEvent>? _crossContainerSubscription;

  /// 正在进入视图的项目列表，用于管理添加动画
  final List<_ActiveItem> _incomingItems = <_ActiveItem>[];

  /// 正在离开视图的项目列表，用于管理移除动画
  final List<_ActiveItem> _outgoingItems = <_ActiveItem>[];

  /// 当前列表中的项目总数
  int _itemsCount = 0;

  /// 存储每个索引位置的项目过渡数据，包括动画状态
  Map<int, ItemTransitionData> childrenMap = <int, ItemTransitionData>{};

  /// 存储当前可见项目的状态对象，键为项目索引
  final Map<int, ReorderableAnimatedWidgetState> _items = <int, ReorderableAnimatedWidgetState>{};

  /// 拖拽时显示的悬浮项目的覆盖条目
  OverlayEntry? _overlayEntry;

  /// 当前被拖拽项目的索引
  int? _dragIndex;

  /// 包含拖拽相关信息的对象，如位置、大小等
  DragInfo? _dragInfo;

  /// 拖拽项目将被插入的目标索引位置
  int? _insertIndex;

  /// 拖拽结束时项目的最终放置位置
  Offset? _finalDropPosition;

  /// 用于识别拖拽手势的识别器
  MultiDragGestureRecognizer? _recognizer;

  /// 当前拖拽手势的指针ID
  int? _recognizerPointer;

  /// 用于在拖拽到视图边缘时自动滚动的控制器
  EdgeDraggingAutoScroller? _autoScroller;

  /// 与此构建器关联的可滚动视图的状态
  late ScrollableState _scrollable;

  /// 标记是否正在进行拖拽操作
  bool _isDragging = false;

  /// 标记是否正在进行自动滚动
  bool autoScrolling = false;

  /// 获取当前滚动方向（水平或垂直）
  /// 基于关联的可滚动视图的轴方向
  Axis get scrollDirection => axisDirectionToAxis(_scrollable.axisDirection);

  /// 判断滚动方向是否是反向的
  /// 当滚动方向为向上或向左时为 true
  bool get _reverse => _scrollable.axisDirection == AxisDirection.up || _scrollable.axisDirection == AxisDirection.left;

  /// 判断当前视图是否是网格视图
  /// 当有委托构建器时表示这是一个网格视图
  bool get isGrid => widget.delegateBuilder != null;

  /// 控制此状态对象是否应该在不可见时保持活动
  /// 对于此组件返回 false，表示当不可见时可以释放资源
  @override
  bool get wantKeepAlive => false;

  /// 初始化状态
  /// 设置初始项目数量并为每个项目创建过渡数据
  @override
  void initState() {
    // 设置项目总数为初始数量
    _itemsCount = widget.initialCount;

    // 为每个初始项目创建过渡数据对象
    for (int i = 0; i < widget.initialCount; i++) {
      childrenMap[i] = ItemTransitionData();
    }

    // 初始化跨容器事件监听
    // 注意：无论 canReceiveItem 的值如何，都需要初始化通信器
    // 这样才能允许将项目拖到其他容器，即使当前容器不接收外部项目
    // canReceiveItem 仅控制当前容器是否接收外部项目
    _crossContainerSubscription = _communicator.listenToContainer(
      containerId: widget.containerId,
      onEvent: _handleCrossContainerEvent,
    );

    print('✅[$runtimeType]【initState】，是否接受外部数据: ${widget.canReceiveItem}, 当前容器containerId: ${widget.containerId}');

    super.initState();
  }

  /// 当依赖项变化时调用
  /// 获取与此构建器关联的可滚动视图状态
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 获取关联的可滚动视图状态，用于后续的滚动操作
    _scrollable = Scrollable.of(context);
  }

  /// 当小部件配置更新时调用
  /// 处理项目数量变化的情况
  @override
  void didUpdateWidget(covariant ReorderableAnimatedBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果项目数量发生变化，取消当前的重排序操作
    if (widget.initialCount != oldWidget.initialCount) {
      // 打印日志查看是否在拖拽过程中更新了组件
      if (kDebugMode) {
        print(
            '⚠️[$runtimeType]【didUpdateWidget】，项目数量变化：${oldWidget.initialCount} -> ${widget.initialCount}，当前拖拽状态：${_dragIndex != null ? "正在拖拽索引$_dragIndex" : "未拖拽"}');
      }
      cancelReorder();
    }
  }

  /// 启动项目的拖拽重排序操作
  ///
  /// 该方法处理拖拽操作的初始化，设置拖拽识别器并准备拖拽状态。
  /// 它确保只有一个项目可以同时被拖拽，并处理各种边界情况。
  ///
  /// 参数：
  /// * index - 要拖拽的项目索引
  /// * event - 触发拖拽的指针事件
  /// * recognizer - 用于识别拖拽手势的识别器
  void startItemDragReorder(
      {required int index, required PointerDownEvent event, required MultiDragGestureRecognizer recognizer}) {
    // 确保索引在有效范围内
    assert(0 <= index && index < _itemsCount);

    setState(() {
      // 如果已经有正在进行的拖拽，则取消它
      if (_dragInfo != null) {
        cancelReorder();
      }
      // 如果已有识别器但指针不同，则释放旧识别器
      else if (_recognizer != null && _recognizerPointer != event.pointer) {
        _recognizer!.dispose();
        _recognizer = null;
        _recognizerPointer = null;
      }

      // 如果项目在当前可见项目列表中，则设置拖拽状态
      if (_items.containsKey(index)) {
        // 记录当前拖拽项目的索引
        _dragIndex = index;
        print('[$runtimeType]【拖拽初始化】开始拖拽重排序，项目索引index: $index, _dragIndex: $_dragIndex');

        // 设置识别器并注册对指针事件的兴趣
        _recognizer = recognizer
          // 设置拖拽开始时的回调函数，但此时不会立即执行
          ..onStart = _dragStart
          // 在 ReorderableAnimatedBuilder 的拖拽实现中，addPointer 是启动整个拖拽过程的关键步骤：
          // 1. 当用户触摸到一个可拖拽项时，ReorderableGridDragStartListener 检测到 onPointerDown 事件
          // 2. 它创建一个 MultiDragGestureRecognizer（通常是 ImmediateMultiDragGestureRecognizer）
          // 3. 然后通过 startItemDragReorder 方法将这个识别器和指针事件传递给 ReorderableAnimatedBuilderState
          // 4. ReorderableAnimatedBuilderState 设置识别器的回调并调用 addPointer
          // 5. 一旦调用了 addPointer，Flutter 的手势系统就会开始跟踪这个指针，并在适当的时候调用 onStart 回调（即 _dragStart 方法）
          // 如果没有 addPointer(event) 这一步，识别器就不会接收到后续的指针事件，整个拖拽过程就无法启动。
          // 这就像是向 Flutter 手势系统“注册”了这个识别器对该指针的兴趣，是整个拖拽机制的起点。
          // 这种设计使得 Flutter 的手势系统非常灵活，能够处理复杂的手势交互，包括多个手势识别器对同一指针事件的竞争情况。
          ..addPointer(event);
        // 记录当前指针ID，用于后续识别
        _recognizerPointer = event.pointer;
      } else {
        // 如果尝试拖拽不可见的项目，抛出异常
        print('[$runtimeType]【拖拽初始化】错误: 尝试拖拽不可见的项目，索引: $index');
        throw Exception("Attempting ro start drag on a non-visible item");
      }
    });
  }

  /// 当拖拽手势开始时调用的方法
  /// 初始化拖拽状态并创建悬浮代理元素
  ///
  /// 该方法完成以下关键步骤：
  /// 1. 设置被拖拽项目的状态
  /// 2. 创建拖拽信息对象
  /// 3. 创建并插入悬浮代理元素
  /// 4. 更新其他项目的状态
  ///
  /// 参数：
  /// * position - 拖拽开始的初始位置
  ///
  /// 返回：
  /// * 创建的拖拽对象，用于后续的拖拽操作
  Drag? _dragStart(Offset position) {
    // 确保当前没有正在进行的拖拽
    assert(_dragInfo == null);

    // 获取被拖拽项目的状态
    final ReorderableAnimatedWidgetState item = _items[_dragIndex]!;
    _isDragging = true;

    print('[$runtimeType]【拖拽开始】设置项目索引 ${_dragIndex} 为拖拽状态, 全局坐标位置: $position');

    // 获取当前拖拽的实际数据模型(如果可用)
    final dynamic draggedItemData = widget.itemDataGetter?.call(_dragIndex!);
    // 设置项目为拖拽状态并触发重排序开始回调
    item.dragging = true;
    widget.onReorderStart?.call(_dragIndex!);
    item.rebuild();

    // 初始化插入索引为当前项目的索引
    _insertIndex = item.index;
    print(
        '[$runtimeType]【拖拽开始】触发重排序开始回调，项目索引_dragIndex: ${_dragIndex}, 插入索引_insertIndex: $_insertIndex, 数据: $draggedItemData');

    // 创建拖拽信息对象，包含所有拖拽相关的回调和状态
    _dragInfo = DragInfo(
        item: item,
        initialPosition: position,
        scrollDirection: scrollDirection,
        gridView: isGrid,
        onUpdate: _dragUpdate,
        onCancel: _dragCancel,
        onEnd: _dragEnd,
        onDragCompleted: _dropCompleted,
        proxyDecorator: widget.proxyDecorator,
        draggedItemData: draggedItemData,
        tickerProvider: this);
    // print('[$runtimeType]【拖拽开始】创建拖拽信息对象, 滚动方向: $scrollDirection, 是否网格视图: $isGrid');

    // 启动拖拽并设置项目的拖拽大小
    _dragInfo!.startDrag();
    item.dragSize = _dragInfo!.itemSize;
    print('[$runtimeType]【拖拽开始】启动拖拽操作，项目大小: ${_dragInfo!.itemSize}');

    // 创建并插入悬浮代理元素，用于显示拖拽中的项目
    final OverlayState overlay = Overlay.of(context, debugRequiredFor: widget);
    assert(_overlayEntry == null);
    _overlayEntry = OverlayEntry(builder: _dragInfo!.createProxy);
    overlay.insert(_overlayEntry!);
    print('[$runtimeType]【拖拽开始】创建并插入悬浮代理元素到Overlay}');

    // 更新其他项目的状态，为拖拽操作做准备
    int updatedItems = 0;
    for (final ReorderableAnimatedWidgetState childItem in _items.values) {
      if (childItem == item || !childItem.mounted) {
        continue;
      }
      item.updateForGap(false);
      updatedItems++;
    }
    print('[$runtimeType]【拖拽开始】更新了 $updatedItems 个其他项目的状态');

    // 返回拖拽对象
    print('[$runtimeType]【拖拽开始】拖拽初始化完成，返回拖拽对象类型: ${_dragInfo.runtimeType}');
    return _dragInfo;
  }

  /// 在拖拽过程中更新项目位置时调用的方法
  /// 处理拖拽中的位置更新、项目重排序和自动滚动
  ///
  /// 此方法执行以下操作：
  /// 1. 更新悬浮代理元素的显示
  /// 2. 更新列表中项目的排序状态
  /// 3. 如果需要，触发自动滚动
  ///
  /// 参数：
  /// * item - 正在拖拽的项目信息
  /// * position - 当前拖拽位置
  /// * delta - 与上次位置的位移量
  void _dragUpdate(DragInfo item, Offset position, Offset delta) {
    // 添加容器ID到日志，更清晰地跟踪拖拽过程
    print(
        '✨[$runtimeType]【拖拽更新】容器ID: ${widget.containerId}, 拖拽索引: $_dragIndex, 插入索引: $_insertIndex, 当前位置: $position, 位移量: $delta');

    // 调用拖拽更新回调，提供当前的DragInfo给外部使用
    // 这对于需要根据拖拽位置执行额外操作的场景很有用，如水平滚动列表
    widget.onDragUpdate
        ?.call(CrossContainerData(fromContainerId: widget.containerId, fromIndex: _dragIndex!, dragInfo: item));

    setState(() {
      // 标记悬浮代理元素需要重建，以反映新位置
      _overlayEntry?.markNeedsBuild();

      // 更新列表中项目的排序状态
      _dragUpdateItems();

      // 如果需要，触发自动滚动
      _autoScrollIfNecessary();
    });
  }

  /// 当拖拽被取消时调用的方法
  /// 重置拖拽状态并清理相关资源
  ///
  /// 此方法在用户取消拖拽操作时调用，例如当用户在拖拽过程中松开手指而不是完成拖拽时。
  ///
  /// 参数：
  /// * item - 被取消拖拽的项目信息
  void _dragCancel(DragInfo item) {
    // 添加日志，包含容器ID和调用栈
    print(
        '💫[$runtimeType]【_dragCancel】容器ID: ${widget.containerId}, 拖拽索引: $_dragIndex, 插入索引: $_insertIndex, 调用栈: ${StackTrace.current}');

    setState(() {
      // 重置所有拖拽相关的状态和资源
      _dragReset();
    });
    // 清除拖拽标志
    _isDragging = false;
  }

  /// 在拖拽时处理自动滚动的方法
  /// 当拖拽项目接近滚动视图边缘时，自动滚动视图以便继续拖拽
  ///
  /// 此方法执行以下操作：
  /// 1. 检测拖拽项目是否接近滚动视图边缘
  /// 2. 根据项目与边缘的距离计算滚动速度
  /// 3. 平滑地滚动视图以便继续拖拽
  /// 4. 完成滚动后更新项目状态
  Future<void> _autoScrollIfNecessary() async {
    // 如果已经在自动滚动中或没有拖拽信息，则返回
    if (autoScrolling || _dragInfo == null || _dragInfo!.scrollable == null) {
      return;
    }

    // 获取滚动位置控制器
    final position = _dragInfo!.scrollable!.position;
    double? newOffset;

    // 设置滚动参数，包括持续时间、滚动步长和超出边界的最大值
    const duration = Duration(milliseconds: 14);
    const step = 1.0;
    const overDragMax = 20.0;
    const overDragCoef = 10;

    // 确定滚动方向是垂直还是水平
    final isVertical = widget.scrollDirection == Axis.vertical;

    final scrollRenderBox = _dragInfo!.scrollable!.context.findRenderObject()! as RenderBox;
    final Offset scrollPosition = scrollRenderBox.localToGlobal(Offset.zero);

    double scrollWindowStart = isVertical ? scrollPosition.dy : scrollPosition.dx;
    double scrollWindowEnd =
        scrollWindowStart + (isVertical ? scrollRenderBox.size.height : scrollRenderBox.size.width);

    final proxyObjectPosition = _dragInfo!.dragPosition - _dragInfo!.dragOffset;

    double proxyObjectStart = isVertical ? proxyObjectPosition.dy : proxyObjectPosition.dx;
    double proxyObjectEnd = proxyObjectStart + (isVertical ? _dragInfo!.itemSize.height : _dragInfo!.itemSize.width);

    if (!_reverse) {
      if (proxyObjectStart < scrollWindowStart && position.pixels > position.minScrollExtent) {
        final overDrag = max(scrollWindowStart - proxyObjectStart, overDragMax);
        newOffset = max(position.minScrollExtent, position.pixels - step * overDrag / overDragCoef);
      } else if (proxyObjectEnd > scrollWindowEnd && position.pixels < position.maxScrollExtent) {
        final overDrag = max(proxyObjectEnd - scrollWindowEnd, overDragMax);
        newOffset = min(position.maxScrollExtent, position.pixels + step * overDrag / overDragCoef);
      }
    } else {
      if (proxyObjectStart < scrollWindowStart && position.pixels < position.maxScrollExtent) {
        final overDrag = max(scrollWindowStart - proxyObjectStart, overDragMax);
        newOffset = max(position.minScrollExtent, position.pixels + step * overDrag / overDragCoef);
      } else if (proxyObjectEnd > scrollWindowEnd && position.pixels > position.minScrollExtent) {
        final overDrag = max(proxyObjectEnd - scrollWindowEnd, overDragMax);
        newOffset = min(position.maxScrollExtent, position.pixels - step * overDrag / overDragCoef);
      }
    }

    if (newOffset != null && (newOffset - position.pixels).abs() >= 1.0) {
      autoScrolling = true;
      await position.animateTo(
        newOffset,
        duration: duration,
        curve: Curves.linear,
      );
      autoScrolling = false;
      if (_dragInfo != null) {
        _dragUpdateItems();
        _autoScrollIfNecessary();
      }
    }
  }

  /// 当拖拽结束时调用的方法
  /// 计算项目的最终放置位置并触发重排序结束回调
  ///
  /// 此方法根据以下因素计算最终放置位置：
  /// 1. 插入索引与原始索引是否相同
  /// 2. 是否为网格视图
  /// 3. 滚动方向是否反向
  /// 4. 插入位置是否在列表的边界
  /// 5. 是否有锁定的项目影响放置位置
  ///
  /// 参数：
  /// * item - 拖拽结束的项目信息
  ///
  void _dragEnd(DragInfo item) {
    // 原来逻辑
    void handleOriginalPositionWhileDragging() {
      setState(() {
        // 如果插入索引与原项目索引相同或者是网格视图，直接使用项目当前偏移量
        if (_insertIndex == item.index || isGrid) {
          _finalDropPosition = _itemOffsetAt(_insertIndex!);
        }
        // 如果滚动方向是反向的（向上或向左）
        else if (_reverse) {
          // 如果插入位置在列表结尾
          if (_insertIndex! >= _items.length - 1) {
            _finalDropPosition =
                _itemStartOffsetAt(_items.length - 1) - _extentOffset(item.itemExtent, scrollDirection);
          } else {
            // 计算放置索引，考虑拖拽方向
            int atIndex = _dragIndex! < _insertIndex! ? _insertIndex! + 1 : _insertIndex!;

            // 处理锁定项目的特殊情况
            if (_dragIndex! > _insertIndex! && widget.lockedIndices.isNotEmpty) {
              atIndex = _insertIndex! + 1;
              if (!widget.lockedIndices.contains(atIndex)) {
                atIndex = _insertIndex!;
              }
            }

            // 计算最终放置位置
            _finalDropPosition = _itemStartOffsetAt(atIndex) + _extentOffset(_itemExtent(atIndex), scrollDirection);
          }
        }
        // 滚动方向是正向的（向下或向右）
        else {
          // 如果插入位置在列表开头
          if (_insertIndex! == 0) {
            _finalDropPosition = _itemStartOffsetAt(0) - _extentOffset(item.itemExtent, scrollDirection);
          } else {
            // 计算放置索引，考虑拖拽方向
            int atIndex = _dragIndex! < _insertIndex! ? _insertIndex! : _insertIndex! - 1;
            // 处理锁定项目的特殊情况
            if (_dragIndex! < _insertIndex! && widget.lockedIndices.isNotEmpty) {
              atIndex = _insertIndex! - 1;
              if (!widget.lockedIndices.contains(atIndex)) {
                atIndex = _insertIndex!;
              }
            }

            // 计算最终放置位置
            _finalDropPosition = _itemStartOffsetAt(atIndex) + _extentOffset(_itemExtent(atIndex), scrollDirection);
          }
        }
      });
    }

    // 新逻辑
    void handleNewPosition() {
      // 1. 不计算 _finalDropPosition，让其保持为 null。
      //    这样，当 _dragReset 移除 _overlayEntry 时，拖拽代理会直接消失，
      //    不会有动画返回到源列表的某个位置。

      // 2. 在源容器中以动画方式移除被拖拽的项。
      //    这会触发 _onItemRemoved，更新 childrenMap 和 _itemsCount，
      //    并让列表中的其他项目动画填充空隙。
      if (_dragIndex! >= 0 && _dragIndex! < _itemsCount) {
        // // 使用 Future.delayed 尝试将 removeItem 推迟到下一帧，
        // // 以期望拖拽代理的清理已经完成。
        // Future.delayed(Duration.zero, () {
        //   if (mounted) {
        //     // 始终检查 mounted
        //     // 再次检查索引的有效性，因为 _itemsCount 可能在 Future.delayed 期间改变
        //     if (_dragIndex! >= 0 && _dragIndex! < _itemsCount) {
        //       removeItem(_dragIndex!, removeItemDuration: kAnimationDuration);
        //     } else {
        //       if (kDebugMode) {
        //         print(
        //             '⚠️[$runtimeType]【handleNewPositionRevised】异步执行 removeItem 时，索引 $_dragIndex 不再有效 (当前 _itemsCount: $_itemsCount)。');
        //       }
        //     }
        //   }
        // });
      } else {
        if (kDebugMode) {
          print('⚠️[$runtimeType]【拖拽结束】跨容器拖拽：尝试从源容器移除的索引 $_dragIndex 超出范围 [0, $_itemsCount). 可能已被移除或状态不同步。');
        }
      }
    }

    // 只有当允许拖出时才发送跨容器拖拽事件
    if (widget.canDragOutItem) {
      // 拖拽结束后,是否在本容器内
      final bool? isSelfContainer = widget.onDragEnd
          ?.call(CrossContainerData(fromContainerId: widget.containerId, fromIndex: _dragIndex!, dragInfo: item));
      if (isSelfContainer == null || isSelfContainer) {
        // 在本容器内,执行原逻辑
        handleOriginalPositionWhileDragging();
      } else {
        // todo 在外容器,直接将空出来的占位符移除, 占位符后面的卡片动画
        handleNewPosition();
      }

      // _communicator.sendEvent(CrossContainerEvent(
      //   type: CrossContainerEventType.itemDraggedToContainer,
      //   data: CrossContainerData(fromContainerId: widget.containerId, fromIndex: _dragIndex!, itemData: item),
      // ));

      if (kDebugMode) {
        print(
            '✅[$runtimeType]【拖拽结束】发送跨容器事件，源容器ID: ${widget.containerId}, 允许拖出: ${widget.canDragOutItem}, isSelfContainer: $isSelfContainer');
      }
    } else {
      // 如果不允许拖出，执行原逻辑, 记录日志
      if (kDebugMode) {
        print('❎[$runtimeType]【拖拽结束】不允许拖出当前容器，容器ID: ${widget.containerId}');
      }
      handleOriginalPositionWhileDragging();
    }

    // 触发重排序结束回调
    widget.onReorderEnd?.call(_insertIndex!);
  }

  /// 当拖拽项目放置完成时调用的方法
  /// 处理重排序回调并重置拖拽状态
  ///
  /// 此方法执行以下操作：
  /// 1. 检查源索引和目标索引是否不同
  /// 2. 如果索引不同，触发重排序回调
  /// 3. 重置所有拖拽相关的状态
  void _dropCompleted() {
    // 获取源和目标索引
    final int fromIndex = _dragIndex!;
    final int toIndex = _insertIndex!;

    // 如果索引不同，触发重排序回调
    if (fromIndex != toIndex) {
      widget.onReorder?.call(fromIndex, toIndex);
    }

    setState(() {
      // 重置所有拖拽相关的状态
      _dragReset();
    });
  }

  /// 处理跨容器事件
  void _handleCrossContainerEvent(CrossContainerEvent event) {
    // 如果不允许跨容器拖拽，则忽略来自其他容器的事件
    if (!widget.canReceiveItem) {
      if (kDebugMode) {
        print('当前容器${widget.containerId}不接受外部项目，忽略事件');
      }
      return;
    }

    print("【$runtimeType】处理跨容器事件, event: $event");
  }

  void cancelReorder() {
    // 添加日志，包含容器ID和上下文信息
    print('⚠️[$runtimeType]【cancelReorder】，容器ID: ${widget.containerId}, 拖拽索引: $_dragIndex, 插入索引: $_insertIndex');

    setState(() {
      _dragReset();
    });
    _isDragging = false;
  }

  void _dragReset() {
    // 记录拖拽重置的调用栈，帮助跟踪谁调用了这个方法
    // 只在调试模式下打印详细日志，包含调用栈
    if (kDebugMode) {
      // 调用栈: ${StackTrace.current}
      print('💥[$runtimeType]【_dragReset】容器ID: ${widget.containerId}, 拖拽索引: $_dragIndex, 插入索引: $_insertIndex');
    }

    if (_dragInfo != null) {
      if (_dragIndex != null && _items.containsKey(_dragIndex)) {
        final ReorderableAnimatedWidgetState dragItem = _items[_dragIndex]!;
        dragItem.dragging = false;
        dragItem.dragSize = Size.zero;
        dragItem.rebuild();
        _dragIndex = null;
      }
      _dragInfo?.dispose();
      _dragInfo = null;
      _autoScroller?.stopAutoScroll();
      _resetItemGap();
      _recognizer?.dispose();
      _recognizer = null;

      // 移除浮层前打印日志，只在调试模式下执行
      assert(() {
        print('💀[$runtimeType]【移除拖拽浮层】容器ID: ${widget.containerId}, 拖拽浮层存在: ${_overlayEntry != null}');
        return true;
      }());
      _overlayEntry?.remove();
      _overlayEntry?.dispose();
      _overlayEntry = null;
      _finalDropPosition = null;
    }
  }

  void _resetItemGap() {
    for (final ReorderableAnimatedWidgetState item in _items.values) {
      item.resetGap();
    }
  }

  /// 拖拽过程中更新项目位置的核心方法
  /// 该方法实现了拖拽时其他项目的位置动画更新，主要步骤如下：
  /// 1. 确定拖动项的中心点位置
  /// 2. 检测该中心点是否位于某个项目的几何区域内
  /// 3. 如果是，则将该项目的索引设为新的插入位置
  /// 4. 如果插入位置发生变化，则触发所有受影响项目的位置更新动画
  ///
  /// 动画更新原理：
  /// - 当拖动项移动到新位置时，需要为其腾出空间
  /// - 受影响的项目（位于拖动起始位置和目标位置之间的项目）会通过动画移动位置
  /// - 移动方向取决于拖动的方向（向前拖动时后面的项目向前移，向后拖动时前面的项目向后移）
  /// - 每个项目的具体偏移量由calculateNextDragOffset方法计算
  void _dragUpdateItems() {
    assert(_dragInfo != null);

    int newIndex = _insertIndex!;

    // 计算拖动项的中心点位置，这是确定新插入位置的关键
    final dragCenter = _dragInfo!.itemSize.center(_dragInfo!.dragPosition - _dragInfo!.dragOffset);

    // 遍历所有可见项目，检查拖动中心点是否在某个项目的几何区域内
    for (final ReorderableAnimatedWidgetState item in _items.values) {
      if (!item.mounted) continue;
      final Rect geometry = item.targetGeometryNonOffset();
      if (widget.lockedIndices.contains(item.index)) {
        continue; // 跳过锁定的项目
      }
      if (geometry.contains(dragCenter)) {
        newIndex = item.index; // 找到新的插入位置
        break;
      }
    }

    // 如果插入位置没有变化，则不需要更新
    if (newIndex == _insertIndex) return;
    _insertIndex = newIndex;

    // 更新所有受影响项目的位置（除了被拖动的项目和锁定的项目）
    // 这里的updateForGap(true)会触发动画过渡到新位置
    for (final ReorderableAnimatedWidgetState item in _items.values) {
      if (item.index == _dragIndex || widget.lockedIndices.contains(item.index)) {
        continue;
      }
      item.updateForGap(true); // 使用动画更新位置
    }
  }

  /// 计算拖拽过程中每个项目应该移动的偏移量
  /// 这是实现拖拽动画的核心计算方法，根据项目的索引位置和拖动方向，
  /// 计算出项目应该移动到的新位置，主要步骤如下：
  ///
  /// 1. 确定受影响的索引范围（拖动起始索引和目标索引之间的项目）
  /// 2. 确定移动方向（向前或向后）
  /// 3. 计算目标偏移量，考虑特殊情况（网格视图、反向滚动等）
  ///
  /// 偏移量计算原理：
  /// - 只有位于拖动起始位置和目标位置之间的项目需要移动
  /// - 移动方向由拖动方向决定（向前拖动时为负，向后拖动时为正）
  /// - 网格视图需要考虑二维布局，直接计算目标位置和当前位置的差值
  /// - 列表视图则根据项目大小和滚动方向计算偏移量
  /// - 锁定项目会被跳过，后续项目的偏移量会相应增加
  Offset calculateNextDragOffset(int index) {
    // 确定受影响的索引范围
    int minPos = min(_dragIndex!, _insertIndex!);
    int maxPos = max(_dragIndex!, _insertIndex!);
    if (_dragIndex == null || _insertIndex == null) return Offset.zero;

    // 如果项目不在受影响范围内，则不需要移动
    if (index < minPos || index > maxPos) return Offset.zero;

    // 确定移动方向：
    // 如果插入位置大于拖动位置（向后拖），方向为-1（前面的项目向前移）
    // 如果插入位置小于拖动位置（向前拖），方向为1（后面的项目向后移）
    int direction = _insertIndex! > _dragIndex! ? -1 : 1;

    // 计算目标索引位置
    int targetIndex = index + direction;

    // 初始化偏移量，基于项目大小和滚动方向
    Offset targetOffset = _extentOffset(_dragInfo!.itemExtent, scrollDirection);

    // 处理锁定项目：如果目标位置是锁定项目，则继续向前/后移动
    // 这确保了锁定项目不会被移动，而其他项目会跳过锁定项目
    while (widget.lockedIndices.contains(targetIndex)) {
      targetIndex += direction;
      targetOffset += _extentOffset(_dragInfo!.itemExtent, scrollDirection);
    }

    // 网格视图和列表视图的偏移量计算方式不同
    if (isGrid) {
      // 网格视图：直接计算目标位置和当前位置的差值
      return _itemOffsetAt(targetIndex) - _itemOffsetAt(index);
    } else {
      // 列表视图：根据滚动方向和拖动方向计算偏移量
      if (_reverse) {
        // 反向滚动（向上或向左）
        return _insertIndex! > _dragIndex! ? targetOffset : -targetOffset;
      } else {
        // 正向滚动（向下或向右）
        return _insertIndex! > _dragIndex! ? -targetOffset : targetOffset;
      }
    }
  }

  void registerItem(ReorderableAnimatedWidgetState item) {
    if (_dragInfo != null && _items[item.index] != item) {
      item.updateForGap(false);
    }
    _items[item.index] = item;
    if (item.index == _dragInfo?.index) {
      item.dragging = true;
      item.dragSize = _dragInfo!.itemSize;
      item.rebuild();
    }
  }

  void unregisterItem(int index, ReorderableAnimatedWidgetState item) {
    final ReorderableAnimatedWidgetState? currentItem = _items[index];
    if (currentItem == item) {
      _items.remove(index);
    }
  }

  @override
  void dispose() {
    // 添加容器销毁的日志，跟踪组件生命周期
    print(
        '🗑️[$runtimeType]【dispose】容器ID: ${widget.containerId}, 元素数量: ${widget.initialCount}, 活动元素: 进入=${_incomingItems.length}, 离开=${_outgoingItems.length}');

    // 销毁所有元素的动画控制器
    for (final _ActiveItem item in _incomingItems.followedBy(_outgoingItems)) {
      item.controller?.dispose();
    }
    // 移除跨容器事件监听
    _crossContainerSubscription?.cancel();
    _communicator.dispose();
    _dragReset();
    super.dispose();

    print('🗑️[$runtimeType]【dispose】容器ID: ${widget.containerId}, 销毁完成');
  }

  _ActiveItem? _removeActiveItemAt(List<_ActiveItem> items, int itemIndex) {
    final int i = binarySearch(items, _ActiveItem.index(itemIndex));
    return i == -1 ? null : items.removeAt(i);
  }

  _ActiveItem? _activeItemAt(List<_ActiveItem> items, int itemIndex) {
    final int i = binarySearch(items, _ActiveItem.index(itemIndex));
    return i == -1 ? null : items[i];
  }

  int _indexToItemIndex(int index) {
    int itemIndex = index;
    for (final _ActiveItem item in _outgoingItems) {
      if (item.itemIndex <= itemIndex) {
        itemIndex += 1;
      } else {
        break;
      }
    }
    return itemIndex;
  }

  /// 将内部项目索引转换为外部可见索引
  ///
  /// 工作原理：
  /// 1. 当项目被删除时，它们不会立即从视图中消失，而是会经历一个淡出动画
  /// 2. 在动画过程中，这些项目仍然占据着内部索引位置，但对外部来说已经“不存在”
  /// 3. 因此需要调整索引，使得外部索引是连续的，没有“空洞”
  ///
  /// 举例说明：
  /// 假设有一个列表 [A, B, C, D, E]，内部索引分别为 [0, 1, 2, 3, 4]
  /// 如果删除了项目 B（索引1），它会进入 _outgoingItems 列表，执行淡出动画
  /// 此时：
  /// - 内部列表仍然是 [A, B, C, D, E]，内部索引仍然是 [0, 1, 2, 3, 4]
  /// - 但外部看到的列表应该是 [A, C, D, E]，外部索引应该是 [0, 1, 2, 3]
  ///
  /// 当构建项目 C 时：
  /// 1. 传入的 index 是 2（内部索引）
  /// 2. 调用 _itemIndexToIndex(2)
  /// 3. 方法会检查 _outgoingItems 列表，发现索引 1 的项目 B 正在移除
  /// 4. 由于 1 < 2，所以 index 减1，变成 1
  /// 5. 返回 1，这就是项目 C 的外部索引
  ///
  /// @param itemIndex 内部项目索引
  /// @return 转换后的外部索引
  int _itemIndexToIndex(int itemIndex) {
    // 初始化返回索引为内部索引
    int index = itemIndex;

    // 遍历所有正在移除的项目
    for (final _ActiveItem item in _outgoingItems) {
      // 确保当前项目不是正在移除的项目
      assert(item.itemIndex != itemIndex);

      // 如果正在移除的项目索引小于当前项目索引
      // 说明这个正在移除的项目在当前项目之前
      if (item.itemIndex < itemIndex) {
        // 外部索引需要减1，因为从外部看这个项目已经“不存在”
        index -= 1;
      } else {
        // 如果正在移除的项目索引大于等于当前项目索引
        // 则不会影响当前项目的外部索引，可以跳出循环
        break;
      }
    }

    // 返回调整后的外部索引
    return index;
  }

  void insertItem(int index, {required Duration insertDuration}) {
    assert(index >= 0);
    final int itemIndex = _indexToItemIndex(index);
    assert(itemIndex >= 0 && itemIndex <= _itemsCount);

    for (final _ActiveItem item in _incomingItems) {
      if (item.itemIndex >= itemIndex) item.itemIndex += 1;
    }
    for (final _ActiveItem item in _outgoingItems) {
      if (item.itemIndex >= itemIndex) item.itemIndex += 1;
    }

    final AnimationController controller = AnimationController(
      duration: insertDuration,
      vsync: this,
    );
    final AnimationController sizeController = AnimationController(
      duration: kAnimationDuration,
      vsync: this,
    );

    final _ActiveItem incomingItem = _ActiveItem.animation(
      controller,
      itemIndex,
      sizeController,
    );

    _incomingItems
      ..add(incomingItem)
      ..sort();

    final updatedChildrenMap = <int, ItemTransitionData>{};

    if (childrenMap.containsKey(itemIndex)) {
      for (final entry in childrenMap.entries) {
        if (entry.key == itemIndex) {
          updatedChildrenMap[itemIndex] = ItemTransitionData(visible: false);
          updatedChildrenMap[entry.key + 1] = entry.value
              .copyWith(startOffset: _itemOffsetAt(entry.key), endOffset: _itemNextOffset(entry.key), animate: isGrid);
        } else if (entry.key > itemIndex) {
          updatedChildrenMap[entry.key + 1] = entry.value
              .copyWith(startOffset: _itemOffsetAt(entry.key), endOffset: _itemNextOffset(entry.key), animate: isGrid);
        } else {
          updatedChildrenMap[entry.key] = entry.value;
        }
      }
      childrenMap.clear();
      childrenMap.addAll(updatedChildrenMap);
      sizeController.forward().then((value) {
        controller.forward().then<void>((_) {
          _removeActiveItemAt(_incomingItems, incomingItem.itemIndex)!.controller!.dispose();
        });
      });
    } else {
      childrenMap[itemIndex] = ItemTransitionData();
      sizeController.value = kAlwaysCompleteAnimation.value;
      controller.forward().then<void>((_) {
        _removeActiveItemAt(_incomingItems, incomingItem.itemIndex)!.controller!.dispose();
      });
    }
    setState(() {
      _itemsCount += 1;
    });
  }

  void removeItem(int index, {required Duration removeItemDuration}) {
    assert(index >= 0);
    final int itemIndex = _indexToItemIndex(index);
    if (itemIndex < 0 || itemIndex >= _itemsCount) {
      return;
    }
    assert(itemIndex >= 0 && itemIndex < _itemsCount);

    assert(_activeItemAt(_outgoingItems, itemIndex) == null);

    if (childrenMap.containsKey(index)) {
      final _ActiveItem? incomingItem = _removeActiveItemAt(_incomingItems, itemIndex);

      final AnimationController sizeController =
          incomingItem?.sizeAnimation ?? AnimationController(vsync: this, duration: kAnimationDuration, value: 1.0);
      final AnimationController controller =
          incomingItem?.controller ?? AnimationController(duration: removeItemDuration, value: 1.0, vsync: this)
            ..addStatusListener((status) => ());
      final _ActiveItem outgoingItem = _ActiveItem.animation(controller, itemIndex, sizeController);

      _outgoingItems
        ..add(outgoingItem)
        ..sort();

      controller.reverse().then<void>((void value) {
        if (controller.status == AnimationStatus.dismissed) {
          if (childrenMap.containsKey(index)) {
            childrenMap.update(index, (value) => value.copyWith(visible: false));
          }
          sizeController.reverse(from: 1.0).then((value) {
            final removedItem = _removeActiveItemAt(_outgoingItems, outgoingItem.itemIndex)!;
            removedItem.controller!.dispose();
            removedItem.sizeAnimation!.dispose();

            // Decrement the incoming and outgoing item indices to account
            // for the removal.
            for (final _ActiveItem item in _incomingItems) {
              if (item.itemIndex > outgoingItem.itemIndex) item.itemIndex -= 1;
            }
            for (final _ActiveItem item in _outgoingItems) {
              if (item.itemIndex > outgoingItem.itemIndex) item.itemIndex -= 1;
            }
            _onItemRemoved(index, removeItemDuration);
          });
        }
      });
    }
  }

  void moveItem(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) return;
    if (!childrenMap.containsKey(fromIndex) || !childrenMap.containsKey(toIndex)) {
      return;
    }
    if (_dragInfo != null || _isDragging) return;

    final fromOffset = _itemOffsetAt(fromIndex);
    final toOffset = _itemOffsetAt(toIndex);
    childrenMap[toIndex] =
        childrenMap[fromIndex]!.copyWith(startOffset: fromOffset, endOffset: toOffset, animate: !_isDragging);
    childrenMap[fromIndex] =
        childrenMap[toIndex]!.copyWith(startOffset: toOffset, endOffset: fromOffset, animate: !_isDragging);
  }

  void _onItemRemoved(int itemIndex, Duration removeDuration) {
    final updatedChildrenMap = <int, ItemTransitionData>{};
    if (childrenMap.containsKey(itemIndex)) {
      for (final entry in childrenMap.entries) {
        if (entry.key < itemIndex) {
          updatedChildrenMap[entry.key] = childrenMap[entry.key]!;
        } else if (entry.key == itemIndex) {
          continue;
        } else {
          updatedChildrenMap[entry.key - 1] = childrenMap[entry.key]!.copyWith(
              startOffset: _itemOffsetAt(entry.key), endOffset: _itemOffsetAt(entry.key - 1), animate: isGrid);
        }
      }
    }
    childrenMap.clear();
    childrenMap.addAll(updatedChildrenMap);

    setState(() => _itemsCount -= 1);
  }

  Offset _itemOffsetAt(int index) {
    final itemRenderBox = _items[index]?.context.findRenderObject() as RenderBox?;
    if (itemRenderBox == null) return Offset.zero;
    return itemRenderBox.localToGlobal(Offset.zero);
  }

  Offset _itemStartOffsetAt(int index) {
    if (!_items.containsKey(index)) return Offset.zero;
    return _items[index]!.targetGeometry().topLeft;
  }

  double _itemExtent(int index) {
    if (!_items.containsKey(index)) return 0;
    return _sizeExtent(_items[index]!.targetGeometry().size, scrollDirection);
  }

  bool _dragEnabled(int index) =>
      widget.onReorder != null && !widget.nonDraggableIndices.contains(index) && !widget.lockedIndices.contains(index);

  double childCrossAxisExtent = 0.0;
  double childMainAxisExtent = 0.0;
  int crossAxisCount = 0;
  double crossAxisSpacing = 0.0;

  void _updateChildExtent(SliverConstraints constraints) {
    if (widget.delegateBuilder == null) return;
    if (widget.delegateBuilder is SliverGridDelegateWithFixedCrossAxisCount) {
      final delegateBuilder = widget.delegateBuilder as SliverGridDelegateWithFixedCrossAxisCount;
      crossAxisCount = delegateBuilder.crossAxisCount;
      crossAxisSpacing = delegateBuilder.crossAxisSpacing;
      final childAspectRatio = delegateBuilder.childAspectRatio;
      final usableCrossAxisCount = max(0.0, constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1));

      childCrossAxisExtent = usableCrossAxisCount / crossAxisCount;
      childMainAxisExtent = childCrossAxisExtent / childAspectRatio;
    }
    if (widget.delegateBuilder is SliverGridDelegateWithMaxCrossAxisExtent) {
      final delegateBuilder = widget.delegateBuilder as SliverGridDelegateWithMaxCrossAxisExtent;
      crossAxisSpacing = delegateBuilder.crossAxisSpacing;

      int childCrossAxisCount =
          (constraints.crossAxisExtent / (delegateBuilder.maxCrossAxisExtent + crossAxisSpacing)).ceil();

      // Ensure a minimum count of 1, can be zero and result in an infinite extent
      // below when the window size is 0.
      crossAxisCount = max(1, childCrossAxisCount);
      final double usableCrossAxisExtent = max(
        0.0,
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1),
      );
      childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
      childMainAxisExtent = delegateBuilder.mainAxisExtent ?? childCrossAxisExtent / delegateBuilder.childAspectRatio;
    }
  }

  Offset _itemNextOffset(int index) {
    final currentOffset = _itemOffsetAt(index);
    if (!isGrid) {
      return currentOffset;
    }

    final int col = index % crossAxisCount;
    final crossAxisStart = crossAxisSpacing;

    if (col == crossAxisCount - 1) {
      return Offset(crossAxisStart, currentOffset.dy + childMainAxisExtent);
    } else {
      return Offset(currentOffset.dx + childCrossAxisExtent, currentOffset.dy);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.delegateBuilder != null
        ? SliverLayoutBuilder(builder: (context, constraints) {
            _updateChildExtent(constraints);
            return SliverGrid(gridDelegate: widget.delegateBuilder!, delegate: _createDelegate());
          })
        : SliverList(delegate: _createDelegate());
  }

  /// 构建列表/网格中的单个项目，处理动画和拖拽状态
  Widget _itemBuilder(BuildContext context, int index) {
    // 检查是否有正在移除的项目
    final _ActiveItem? outgoingItem = _activeItemAt(_outgoingItems, index);
    // 检查是否有正在插入的项目
    final _ActiveItem? incomingItem = _activeItemAt(_incomingItems, index);

    // 处理正在移除的项目
    if (outgoingItem != null) {
      final item = _items[index];
      if (item == null) return const SizedBox();

      final child = item.widget;
      return _removeItemBuilder(outgoingItem, child);
    }
    // 处理拖拽占位符
    if (_dragInfo != null && index >= _itemsCount) {
      return SizedBox.fromSize(size: _dragInfo!.itemSize);
    }

    // 将内部索引转换为外部索引
    final itemIndex = _itemIndexToIndex(index);

    // 根据项目是否可拖拽选择构建方式
    final Widget child =
        _dragEnabled(itemIndex) ? reorderableItemBuilder(context, itemIndex) : widget.itemBuilder(context, itemIndex);

    // 确保每个项目都有唯一的key
    assert(() {
      if (child.key == null) {
        throw FlutterError(
          'Every item of AnimatedReorderableList must have a unique key.',
        );
      }
      return true;
    }());

    // 创建全局唯一键
    final Key itemGlobalKey = _MotionBuilderItemGlobalKey(child.key!, this);
    // 应用插入动画
    final Widget builder = _insertItemBuilder(incomingItem, child);

    // 获取项目的过渡数据
    final ItemTransitionData? transitionData = childrenMap[index];
    if (transitionData == null) return builder;
    // 获取Overlay状态
    final OverlayState overlay = Overlay.of(context, debugRequiredFor: widget);

    // 包装在ReorderableAnimatedWidget中处理动画和拖拽
    return ReorderableAnimatedWidget(
      index: index,
      key: itemGlobalKey,
      transitionData: transitionData,
      updateItemPosition: () {
        // 更新项目位置信息
        final itemOffset = _itemOffsetAt(index);
        childrenMap[index] =
            ItemTransitionData(startOffset: itemOffset, endOffset: itemOffset, visible: true, animate: false);
      },
      // 捕获主题以保持样式一致性
      capturedThemes: InheritedTheme.capture(from: context, to: overlay.context),
      child: builder,
    );
  }

  SliverChildDelegate _createDelegate() {
    return SliverChildBuilderDelegate(_itemBuilder, childCount: _itemsCount);
  }

  Widget reorderableItemBuilder(BuildContext context, int index) {
    final Widget item = widget.itemBuilder(context, index);
    final Widget itemWithSemantics = _wrapWithSemantics(item, index);

    assert(() {
      if (item.key == null) {
        throw FlutterError(
          'Every item of AnimatedReorderableList must have a key.',
        );
      }
      return true;
    }());
    final Key itemGlobalKey = _MotionBuilderItemGlobalKey(item.key!, this);
    if (widget.buildDefaultDragHandles) {
      switch (Theme.of(context).platform) {
        case TargetPlatform.linux:
        case TargetPlatform.macOS:
        case TargetPlatform.windows:
          switch (widget.scrollDirection) {
            case Axis.horizontal:
              return Stack(
                key: itemGlobalKey,
                children: <Widget>[
                  itemWithSemantics,
                  Positioned.directional(
                      textDirection: Directionality.of(context),
                      start: 0,
                      end: 0,
                      bottom: 8,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: ReorderableGridDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_handle),
                        ),
                      ))
                ],
              );
            case Axis.vertical:
              return Stack(
                key: itemGlobalKey,
                children: <Widget>[
                  itemWithSemantics,
                  Positioned.directional(
                      textDirection: Directionality.of(context),
                      top: 0,
                      bottom: 0,
                      end: 8,
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: ReorderableGridDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_handle),
                        ),
                      ))
                ],
              );
          }
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.iOS:
          return ReorderableGridDelayedDragStartListener(
              dragStartDelay: widget.dragStartDelay, key: itemGlobalKey, index: index, child: item);
      }
    }

    const bool enable = true;
    return ReorderableGridDelayedDragStartListener(
      dragStartDelay: widget.dragStartDelay,
      key: itemGlobalKey,
      index: index,
      enabled: enable,
      child: itemWithSemantics,
    );
  }

  Widget _wrapWithSemantics(Widget child, int index) {
    void reorder(int startIndex, int endIndex) {
      if (startIndex != endIndex) {
        widget.onReorder?.call(startIndex, endIndex);
      }
    }

    // First, determine which semantics actions apply.
    final Map<CustomSemanticsAction, VoidCallback> semanticsActions = <CustomSemanticsAction, VoidCallback>{};

    // Create the appropriate semantics actions.
    void moveToStart() => reorder(index, 0);
    void moveToEnd() => reorder(index, _itemsCount);
    void moveBefore() => reorder(index, index - 1);
    // To move after, we go to index+2 because we are moving it to the space
    // before index+2, which is after the space at index+1.
    void moveAfter() => reorder(index, index + 2);

    final WidgetsLocalizations localizations = WidgetsLocalizations.of(context);

    // If the item can move to before its current position in the grid.
    if (index > 0) {
      semanticsActions[CustomSemanticsAction(label: localizations.reorderItemToStart)] = moveToStart;
      String reorderItemBefore = localizations.reorderItemUp;
      if (widget.scrollDirection == Axis.horizontal) {
        reorderItemBefore = Directionality.of(context) == TextDirection.ltr
            ? localizations.reorderItemLeft
            : localizations.reorderItemRight;
      }
      semanticsActions[CustomSemanticsAction(label: reorderItemBefore)] = moveBefore;
    }

    // If the item can move to after its current position in the grid.
    if (index < _itemsCount - 1) {
      String reorderItemAfter = localizations.reorderItemDown;
      if (widget.scrollDirection == Axis.horizontal) {
        reorderItemAfter = Directionality.of(context) == TextDirection.ltr
            ? localizations.reorderItemRight
            : localizations.reorderItemLeft;
      }
      semanticsActions[CustomSemanticsAction(label: reorderItemAfter)] = moveAfter;
      semanticsActions[CustomSemanticsAction(label: localizations.reorderItemToEnd)] = moveToEnd;
    }

    // We pass toWrap with a GlobalKey into the item so that when it
    // gets dragged, the accessibility framework can preserve the selected
    // state of the dragging item.
    //
    // We also apply the relevant custom accessibility actions for moving the item
    // up, down, to the start, and to the end of the grid.
    return MergeSemantics(
      child: Semantics(
        customSemanticsActions: semanticsActions,
        child: child,
      ),
    );
  }

  Widget _removeItemBuilder(_ActiveItem? outgoingItem, Widget child) {
    // 防止原始动画控制器出现NaN值
    Animation<double> animation;
    if (outgoingItem?.controller == null) {
      animation = kAlwaysCompleteAnimation;
    } else {
      // 检查并处理可能出现的NaN值
      final originalAnimation = outgoingItem!.controller!;
      if (originalAnimation.value.isNaN) {
        if (kDebugMode) {
          print('⚠️[$runtimeType]【异常】移除项动画值为NaN');
        }
        // 创建安全的动画包装器
        animation = const AlwaysStoppedAnimation<double>(1.0);
      } else {
        animation = originalAnimation;
      }
    }

    // 添加防护措施，确保sizeAnimation不会为NaN
    Animation<double> sizeAnimation;
    if (outgoingItem?.sizeAnimation == null) {
      sizeAnimation = kAlwaysCompleteAnimation;
    } else {
      // 检查原始动画值是否为NaN
      final originalSizeAnimation = outgoingItem!.sizeAnimation!;
      if (originalSizeAnimation.value.isNaN) {
        if (kDebugMode) {
          print('⚠️[$runtimeType]【异常】移除项尺寸动画值为NaN');
        }
        // 使用安全的默认值
        sizeAnimation = const AlwaysStoppedAnimation<double>(1.0);
      } else {
        // 创建一个防护包装器，确保动画值始终合法
        sizeAnimation = CurveTween(
          curve: const Interval(0.0, 1.0),
        ).animate(originalSizeAnimation);
      }
    }
    return SizeTransition(
        axis: widget.scrollDirection,
        sizeFactor: sizeAnimation,
        child: widget.removeAnimationBuilder(context, child, animation));
  }

  Widget _insertItemBuilder(_ActiveItem? incomingItem, Widget child) {
    // 防止原始动画控制器出现NaN值
    Animation<double> animation;
    if (incomingItem?.controller == null) {
      animation = kAlwaysCompleteAnimation;
    } else {
      // 检查并处理可能出现的NaN值
      final originalAnimation = incomingItem!.controller!;
      if (originalAnimation.value.isNaN) {
        if (kDebugMode) {
          print('⚠️[$runtimeType]【异常】插入项动画值为NaN');
        }
        // 创建安全的动画包装器
        animation = const AlwaysStoppedAnimation<double>(1.0);
      } else {
        animation = originalAnimation;
      }
    }

    // 添加防护措施，确保sizeAnimation不会为NaN
    Animation<double> sizeAnimation;
    if (incomingItem?.sizeAnimation == null) {
      sizeAnimation = kAlwaysCompleteAnimation;
    } else {
      // 检查原始动画值是否为NaN
      final originalSizeAnimation = incomingItem!.sizeAnimation!;
      if (originalSizeAnimation.value.isNaN) {
        if (kDebugMode) {
          print('⚠️[$runtimeType]【异常】插入项尺寸动画值为NaN');
        }
        // 使用安全的默认值
        sizeAnimation = const AlwaysStoppedAnimation<double>(1.0);
      } else {
        // 创建一个防护包装器，确保动画值始终合法
        sizeAnimation = CurveTween(
          curve: const Interval(0.0, 1.0),
        ).animate(originalSizeAnimation);
      }
    }

    return SizeTransition(
        axis: widget.scrollDirection,
        sizeFactor: sizeAnimation,
        child: widget.insertAnimationBuilder(context, child, animation));
  }
}

Offset _extentOffset(double extent, Axis scrollDirection) {
  switch (scrollDirection) {
    case Axis.horizontal:
      return Offset(extent, 0.0);
    case Axis.vertical:
      return Offset(0.0, extent);
  }
}

@optionalTypeArgs
class _MotionBuilderItemGlobalKey extends GlobalObjectKey {
  const _MotionBuilderItemGlobalKey(this.subKey, this.state) : super(subKey);

  final Key subKey;
  final State state;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _MotionBuilderItemGlobalKey && other.subKey == subKey && other.state == state;
  }

  @override
  int get hashCode => Object.hash(
        subKey,
        state,
      );
}

class _ActiveItem implements Comparable<_ActiveItem> {
  _ActiveItem.animation(this.controller, this.itemIndex, this.sizeAnimation);

  _ActiveItem.index(this.itemIndex)
      : controller = null,
        sizeAnimation = null;

  final AnimationController? controller;
  final AnimationController? sizeAnimation;
  int itemIndex;

  @override
  int compareTo(_ActiveItem other) => itemIndex - other.itemIndex;
}
