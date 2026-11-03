part of '../builder/reorderable_animated_builder.dart';

/// ReorderableAnimatedWidget 是可重新排序动画列表/网格中的核心内容组件，
/// 负责处理单个项目的动画、拖拽状态和位置更新。
///
/// 该组件实现了以下功能：
/// 1. 管理项目在拖拽过程中的位置偏移动画
/// 2. 处理项目的可见性状态（正常显示或作为拖拽代理）
/// 3. 在拖拽排序过程中平滑过渡到新位置
/// 4. 与父级ReorderableAnimatedBuilder协调工作，实现整体拖拽排序效果
///
/// 工作原理：
/// - 每个列表/网格项都被包装在此组件中
/// - 当拖拽发生时，组件通过Transform.translate实现位置偏移
/// - 偏移量由父级ReorderableAnimatedBuilder计算，基于拖拽方向和目标位置
/// - 使用AnimationController实现平滑的位置过渡动画
///
class ReorderableAnimatedWidget extends StatefulWidget {
  /// 项目在列表/网格中的索引位置
  final int index;

  /// 项目的过渡数据，包含动画状态、起始和结束位置等信息
  final ItemTransitionData transitionData;

  /// 要显示的子组件（实际内容）
  final Widget child;

  /// 更新项目位置的回调函数，通常在布局完成后调用
  final Function()? updateItemPosition;

  /// 捕获的主题，用于在Overlay中保持一致的主题样式
  final CapturedThemes? capturedThemes;

  const ReorderableAnimatedWidget({
    Key? key,
    required this.index,
    required this.transitionData,
    required this.child,
    this.updateItemPosition,
    required this.capturedThemes,
  }) : super(key: key);

  @override
  State<ReorderableAnimatedWidget> createState() => ReorderableAnimatedWidgetState();
}

/// ReorderableAnimatedWidgetState 是 ReorderableAnimatedWidget 的状态类，
/// 负责实现单个项目在拖拽排序过程中的动画和位置更新。
///
/// 该类实现了以下核心功能：
/// 1. 使用动画控制器管理项目的位置过渡
/// 2. 跟踪项目的拖拽状态和目标位置
/// 3. 处理项目在拖拽过程中的可见性
/// 4. 与父级 ReorderableAnimatedBuilderState 协同工作，实现整体拖拽效果
///
/// 位置更新原理：
/// - 当拖拽发生时，每个受影响的项目会计算新的目标位置
/// - 使用 AnimationController 创建从当前位置到目标位置的平滑过渡
/// - 通过 Transform.translate 实现实际的位置偏移
/// - 当动画完成后，更新起始位置并释放动画资源
///
class ReorderableAnimatedWidgetState extends State<ReorderableAnimatedWidget>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  /// 父级列表/网格的状态对象，用于协调拖拽操作
  late ReorderableAnimatedBuilderState listState;

  /// 项目的目标偏移量，表示需要移动到的最终位置
  Offset _targetOffset = Offset.zero;

  /// 项目的起始偏移量，表示动画开始时的位置
  Offset _startOffset = Offset.zero;

  /// 用于控制项目位置过渡动画的控制器
  AnimationController? _offsetAnimation;

  /// 内部拖拽状态标志
  bool _dragging = false;

  /// 获取项目当前的拖拽状态
  bool get dragging => _dragging;

  /// 设置项目的拖拽状态，并触发重建
  set dragging(bool dragging) {
    if (mounted) {
      setState(() {
        _dragging = dragging;
      });
    }
  }

  /// 拖拽时项目的大小，用于创建占位空间
  Size _dragSize = Size.zero;

  /// 设置项目的拖拽大小，并触发重建
  set dragSize(Size itemSize) {
    if (mounted) {
      setState(() {
        _dragSize = itemSize;
      });
    }
  }

  /// 获取项目的索引位置
  int get index => widget.index;

  /// 项目的可见性状态
  bool visible = true;

  /// 初始化状态
  /// 在组件创建时执行以下操作：
  /// 1. 获取父级列表状态并注册当前项目
  /// 2. 设置初始可见性状态
  /// 3. 更新项目位置
  /// 4. 延迟后确保项目可见并触发重建
  @override
  void initState() {
    // 获取父级ReorderableAnimatedBuilder的状态引用
    listState = ReorderableAnimatedBuilder.of(context);
    // 在父级状态中注册此项目
    listState.registerItem(this);
    // 设置初始可见性状态
    visible = widget.transitionData.visible;

    // 更新项目位置
    _updateItemPosition();

    // 延迟一个动画周期后确保项目可见
    Future.delayed(kAnimationDuration).then((value) {
      visible = true;
      rebuild();
    });
    super.initState();
  }

  /// 当组件更新时调用
  /// 处理索引变化和位置更新
  /// 主要完成以下任务：
  /// 1. 如果索引变化，重新注册项目
  /// 2. 根据情况更新动画或位置
  @override
  void didUpdateWidget(covariant ReorderableAnimatedWidget oldWidget) {
    // 如果索引发生变化，需要重新注册项目
    if (oldWidget.index != widget.index) {
      listState.unregisterItem(oldWidget.index, this);
      listState.registerItem(this);
    }
    if (oldWidget.index != widget.index && !_dragging) {
      // 拖拽完成并且项目重新排序后，重置拖拽标志
      listState._isDragging = false;
      // 更新动画过渡
      _updateAnimationTranslation();
    } else {
      // 正常更新项目位置
      _updateItemPosition();
    }
    super.didUpdateWidget(oldWidget);
  }

  /// 更新项目的动画过渡
  /// 当项目位置需要动画过渡时（如重排序后），计算并应用动画
  /// 主要步骤：
  /// 1. 计算当前位置与目标位置的差值
  /// 2. 创建或重用动画控制器
  /// 3. 设置动画完成后的回调
  void _updateAnimationTranslation() {
    // 只有当需要动画时才执行
    if (widget.transitionData.animate) {
      // 计算当前位置与目标位置的差值
      Offset offsetDiff = (widget.transitionData.startOffset + offset) - widget.transitionData.endOffset;
      _startOffset = offsetDiff;
      // 只有当有实际偏移时才创建动画
      if (offsetDiff.dx != 0 || offsetDiff.dy != 0) {
        if (_offsetAnimation == null) {
          // 创建新的动画控制器
          _offsetAnimation = AnimationController(
            vsync: listState,
            duration: kAnimationDuration,
          )
            ..addListener(rebuild) // 每帧触发重建
            ..addStatusListener((AnimationStatus status) {
              if (status == AnimationStatus.completed) {
                // 动画完成后更新项目位置
                widget.updateItemPosition?.call();
                _startOffset = _targetOffset;
                // 释放动画资源
                _offsetAnimation!.dispose();
                _offsetAnimation = null;
              }
            })
            ..forward();
        } else {
          // 如果已有动画控制器，重置起始位置并重新开始
          _startOffset = offsetDiff;
          _offsetAnimation!.forward(from: 0.0);
        }
      }
    }
  }

  /// 获取项目当前的偏移量，考虑动画进度
  /// 如果动画正在进行，返回插值计算的中间值
  /// 如果没有动画，直接返回目标偏移量
  Offset get offset {
    if (_offsetAnimation != null) {
      // 如果有动画正在运行，计算当前插值位置
      final Offset offset = Offset.lerp(_startOffset, _targetOffset, _offsetAnimation!.value)!;
      return offset;
    }
    return _targetOffset;
  }

  /// 当拖拽过程中需要为拖拽项目腾出空间时，更新项目的位置
  /// 这是实现拖拽时其他项目移动的核心方法
  ///
  /// 参数：
  /// * animate - 是否使用动画过渡到新位置，如果为false则立即移动
  ///
  /// 工作原理：
  /// 1. 从父级列表状态获取计算出的新目标偏移量
  /// 2. 如果需要动画，创建或重用动画控制器
  /// 3. 设置动画完成后的回调，更新起始位置并释放资源
  /// 4. 触发重建以应用新的位置
  void updateForGap(bool animate) {
    if (!mounted) return;
    // 从父级列表状态获取计算出的新目标偏移量
    final Offset newTargetOffset = listState.calculateNextDragOffset(index);
    if (newTargetOffset == _targetOffset) return;
    _targetOffset = newTargetOffset;

    if (animate) {
      // 如果需要动画过渡，创建或重用动画控制器
      if (_offsetAnimation == null) {
        _offsetAnimation = AnimationController(
          vsync: listState,
          duration: const Duration(milliseconds: 250), // 动画持续250毫秒 / Animation lasts 250ms
        )
          ..addListener(rebuild) // 每帧触发重建 / Trigger rebuild on each frame
          ..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              // 动画完成后更新起始位置并释放资源
              // After animation completes, update start position and release resources
              _startOffset = _targetOffset;
              _offsetAnimation!.dispose();
              _offsetAnimation = null;
            }
          })
          ..forward();
      } else {
        // 如果已有动画正在运行，重置并重新开始
        _startOffset = offset;
        _offsetAnimation!.forward(from: 0.0);
      }
    } else {
      // 如果不需要动画，直接设置新位置
      if (_offsetAnimation != null) {
        _offsetAnimation!.dispose();
        _offsetAnimation = null;
      }
      _startOffset = _targetOffset;
    }
    rebuild();
  }

  /// 更新项目位置
  /// 在下一帧渲染后调用项目位置更新回调
  /// 确保布局完成后再更新位置信息
  void _updateItemPosition() {
    // 添加到下一帧回调队列，确保布局完成后执行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // 调用位置更新回调
        widget.updateItemPosition?.call();
      }
    });
  }

  /// 构建项目的可见表示，应用当前的位置偏移和可见性状态
  /// 当项目被拖拽时，显示一个占位大小的空间
  /// 当项目正常显示时，应用位置偏移并显示实际内容
  @override
  Widget build(BuildContext context) {
    super.build(context);
    // 在父级列表状态中注册这个项目
    listState.registerItem(this);
    return Visibility(
      // 即使不可见也保持大小、动画和状态，确保布局稳定
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      // 只有在非拖拽状态且设置为可见时才显示
      // Only visible when not in dragging state and set to be visible
      visible: visible && !_dragging,
      child: Transform.translate(
          // 应用当前的位置偏移
          offset: offset,
          child:
              // 如果不在拖拽状态，显示实际内容，否则显示占位大小
              !_dragging ? widget.child : SizedBox.fromSize(size: _dragSize)),
    );
  }

  /// 重置项目的位置偏移，通常在拖拽操作结束或取消时调用
  /// 清理所有动画资源并将位置重置为零
  void resetGap() {
    // 清理动画控制器
    // Clean up animation controller
    if (_offsetAnimation != null) {
      _offsetAnimation!.dispose();
      _offsetAnimation = null;
    }
    // 重置位置偏移
    // Reset position offsets
    _startOffset = Offset.zero;
    _targetOffset = Offset.zero;
    rebuild();
  }

  /// 获取项目的原始几何区域（不考虑偏移）
  /// 这用于在拖拽过程中确定项目的实际位置和大小
  Rect targetGeometryNonOffset() {
    // 获取项目的渲染对象
    final RenderBox itemRenderBox = context.findRenderObject()! as RenderBox;
    // 计算项目在全局坐标系中的位置
    final Offset itemPosition = itemRenderBox.localToGlobal(Offset.zero);
    // 返回包含位置和大小的矩形
    return itemPosition & itemRenderBox.size;
  }

  Rect targetGeometry() {
    final RenderBox itemRenderBox = context.findRenderObject()! as RenderBox;
    final Offset itemPosition = itemRenderBox.localToGlobal(Offset.zero) + _targetOffset;
    return itemPosition & itemRenderBox.size;
  }

  /// 触发组件重建
  /// 简单的辅助方法，用于在需要时触发状态更新
  void rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    listState.unregisterItem(index, this);
    _offsetAnimation?.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    listState.unregisterItem(index, this);
    super.deactivate();
  }

  @override
  bool get wantKeepAlive => true;
}
