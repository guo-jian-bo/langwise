import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';

import 'reorderable_animated_list_base.dart';

class ReorderableAnimatedListImpl<E extends Object> extends ReorderableAnimatedListBase<Widget, E> {
  // 列表视图初始化
  const ReorderableAnimatedListImpl({
    Key? key,
    required List<E> items,
    required ItemBuilder? itemBuilder,
    List<AnimationEffect>? enterTransition,
    List<AnimationEffect>? exitTransition,
    Duration? insertDuration,
    Duration? removeDuration,
    ReorderCallback? onReorder,
    void Function(int)? onReorderStart,
    void Function(int)? onReorderEnd,
    ReorderItemProxyDecorator? proxyDecorator,
    required Axis scrollDirection,
    AnimatedWidgetBuilder? insertItemBuilder,
    AnimatedWidgetBuilder? removeItemBuilder,
    bool? buildDefaultDragHandles,
    bool Function(E a, E b)? isSameItem,
    Duration? dragStartDelay,
    List<E> nonDraggableItems = const [],
    List<E> lockedItems = const [],
    bool enableSwap = true,
    bool canReceiveItem = false,
    bool canDragOutItem = false,
    dynamic containerId,
    ItemDataGetter? itemDataGetter,
    void Function(CrossContainerData containerData)? onDragUpdate,

    /// 拖拽结束回调
    /// 当拖拽位置结束时触发，提供当前的拖拽信息
    /// 主要用于让外部组件根据拖拽位置进行额外操作
    final bool Function(CrossContainerData containerData)? onDragEnd,
  }) : super(
            key: key,
            items: items,
            itemBuilder: itemBuilder,
            enterTransition: enterTransition,
            exitTransition: exitTransition,
            insertDuration: insertDuration,
            removeDuration: removeDuration,
            onReorder: onReorder,
            onReorderStart: onReorderStart,
            onReorderEnd: onReorderEnd,
            proxyDecorator: proxyDecorator,
            scrollDirection: scrollDirection,
            insertItemBuilder: insertItemBuilder,
            removeItemBuilder: removeItemBuilder,
            buildDefaultDragHandles: buildDefaultDragHandles,
            isSameItem: isSameItem,
            dragStartDelay: dragStartDelay,
            nonDraggableItems: nonDraggableItems,
            lockedItems: lockedItems,
            enableSwap: enableSwap,
            canReceiveItem: canReceiveItem,
            canDragOutItem: canDragOutItem,
            containerId: containerId,
            onDragUpdate: onDragUpdate,
            onDragEnd: onDragEnd);

  // 网格视图初始化
  const ReorderableAnimatedListImpl.grid({
    Key? key,
    required List<E> items,
    required SliverGridDelegate sliverGridDelegate,
    required ItemBuilder itemBuilder,
    List<AnimationEffect>? enterTransition,
    List<AnimationEffect>? exitTransition,
    ReorderCallback? onReorder,
    void Function(int)? onReorderStart,
    void Function(int)? onReorderEnd,
    ReorderItemProxyDecorator? proxyDecorator,
    Duration? insertDuration,
    Duration? removeDuration,
    required Axis scrollDirection,
    AnimatedWidgetBuilder? insertItemBuilder,
    AnimatedWidgetBuilder? removeItemBuilder,
    bool? buildDefaultDragHandles,
    bool Function(E a, E b)? isSameItem,
    Duration? dragStartDelay,
    List<E> nonDraggableItems = const [],
    List<E> lockedItems = const [],
    dynamic containerId,
    bool canReceiveItem = false,

    /// 是否能接收来自其他容器的项目
    bool canDragOutItem = false,

    /// 数据获取器回调
    /// 用于获取指定索引处的实际数据模型，而不是 UI 组件
    /// 在跨容器拖拽时用于传递实际数据
    final ItemDataGetter? itemDataGetter,
    final void Function(CrossContainerData containerData)? onDragUpdate,

    /// 拖拽结束回调
    /// 当拖拽位置结束时触发，提供当前的拖拽信息
    /// 主要用于让外部组件根据拖拽位置进行额外操作
    final bool Function(CrossContainerData containerData)? onDragEnd,
    void Function(dynamic, dynamic, int, int, dynamic)? onCrossContainerReorder,
    bool enableSwap = true,
  }) : super(
            key: key,
            items: items,
            itemBuilder: itemBuilder,
            sliverGridDelegate: sliverGridDelegate,
            enterTransition: enterTransition,
            exitTransition: exitTransition,
            insertDuration: insertDuration,
            removeDuration: removeDuration,
            onReorder: onReorder,
            onReorderStart: onReorderStart,
            onReorderEnd: onReorderEnd,
            proxyDecorator: proxyDecorator,
            scrollDirection: scrollDirection,
            insertItemBuilder: insertItemBuilder,
            removeItemBuilder: removeItemBuilder,
            buildDefaultDragHandles: buildDefaultDragHandles,
            isSameItem: isSameItem,
            dragStartDelay: dragStartDelay,
            nonDraggableItems: nonDraggableItems,
            containerId: containerId,
            canReceiveItem: canReceiveItem,
            canDragOutItem: canDragOutItem,
            itemDataGetter: itemDataGetter,
            onDragUpdate: onDragUpdate,
            onDragEnd: onDragEnd,
            lockedItems: lockedItems,
            enableSwap: enableSwap);

  @override
  ReorderableAnimatedListImplState<E> createState() => ReorderableAnimatedListImplState<E>();
}

class ReorderableAnimatedListImplState<E extends Object>
    extends ReorderableAnimatedListBaseState<Widget, ReorderableAnimatedListImpl<E>, E> {
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasOverlay(context));

    // 内部封装真正的list/grid视图
    return ReorderableAnimatedBuilder(
        key: listKey,
        initialCount: oldList.length,
        onReorder: onReorder,
        onReorderStart: onReorderStart,
        onReorderEnd: onReorderEnd,
        proxyDecorator: proxyDecorator,
        insertAnimationBuilder: insertAnimationBuilder,
        removeAnimationBuilder: removeAnimationBuilder,
        itemBuilder: itemBuilder,
        scrollDirection: scrollDirection,
        delegateBuilder: sliverGridDelegate,
        buildDefaultDragHandles: buildDefaultDragHandles,
        dragStartDelay: dragStartDelay,
        nonDraggableIndices: nonDraggableItems,
        lockedIndices: lockedIndices,
        // 添加跨容器拖拽支持
        containerId: widget.containerId,
        canReceiveItem: widget.canReceiveItem,
        canDragOutItem: widget.canDragOutItem,
        itemDataGetter: widget.itemDataGetter,
        onDragUpdate: widget.onDragUpdate,
        onDragEnd: widget.onDragEnd);
  }
}
