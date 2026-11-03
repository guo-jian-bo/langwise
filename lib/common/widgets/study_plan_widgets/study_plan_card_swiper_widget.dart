import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

/// 只负责卡片堆叠切换动画的通用组件。
///
/// 外部只需要传入卡片 UI，组件内部负责：
/// 1. 识别上下滑手势
/// 2. 在松手后执行一次完整切换动画
/// 3. 按层规则自动生成卡片的层级、透明度和缩放
class StudyPlanCardSwiperWidget extends StatefulWidget {
  /// 需要参与轮播的卡片列表。
  ///
  /// 可传入任意数量，组件会按卡片数量循环展示。
  final List<Widget> cards;

  /// 数组为空的情况下 自定义卡片
  final Widget? customEmptyCard;

  /// 每层之间的纵向偏移步长。
  ///
  /// 例如设置为 `80` 时，第 0/1/2/3 层的偏移分别为 `0/80/160/240`。
  final double layerOffsetStep;

  /// 顶层卡片的最大缩放。
  final double maxScale;

  /// 最底层卡片的最小缩放。
  final double minScale;

  /// 顶层卡片的最大透明度。
  final double maxOpacity;

  /// 最底层卡片的最小透明度。
  final double minOpacity;

  /// 触发切换所需的最小滑动距离。
  ///
  /// 如果滑动距离不足，但速度足够大，仍然会触发切换。
  final double swipeThreshold;

  /// 单次切换动画时长。
  final Duration animationDuration;

  /// 每次切换完成后，回调当前位于最上层的卡片下标。
  final ValueChanged<int>? onIndexChanged;

  /// 初始化卡片的下标。
  final int initIndex;

  const StudyPlanCardSwiperWidget({
    super.key,
    required this.cards,
    this.customEmptyCard,
    this.layerOffsetStep = 80,
    this.maxScale = 1,
    this.minScale = 0.92,
    this.maxOpacity = 1,
    this.minOpacity = 0.48,
    this.swipeThreshold = 24,
    this.animationDuration = const Duration(milliseconds: 200),
    this.onIndexChanged,
    this.initIndex = 0,
  })  : assert(layerOffsetStep >= 0, 'layerOffsetStep must be >= 0'),
        assert(maxScale > 0, 'maxScale must be > 0'),
        assert(minScale > 0, 'minScale must be > 0'),
        assert(maxScale >= minScale, 'maxScale must be >= minScale'),
        assert(maxOpacity >= minOpacity, 'maxOpacity must be >= minOpacity');

  @override
  State<StudyPlanCardSwiperWidget> createState() =>
      _StudyPlanCardSwiperWidgetState();
}

class _StudyPlanCardSwiperWidgetState extends State<StudyPlanCardSwiperWidget> {
  /// 当前位于最上层的卡片下标。
  int _topIndex = 0;

  /// 本次手势累计的纵向位移，用于在松手时判断切换方向。
  double _dragDy = 0;

  /// 鼠标滚轮或触控板累计的纵向滚动距离。
  double _scrollDy = 0;

  /// 滚轮/触控板切换比拖拽更容易误触，单独提高触发阈值。
  double get _scrollThreshold => widget.swipeThreshold * 2;

  /// 标记当前是否正处于切换动画中，避免重复触发。
  bool _isAnimating = false;

  /// 记录顶层卡片的实际尺寸，用于决定整个堆叠容器的宽高。
  Size? _cardSize;

  /// 本次切换动画的方向。
  _StudyPlanCardSwipeDirection _direction = _StudyPlanCardSwipeDirection.none;

  /// 卡片总数。
  int get _cardCount => widget.cards.length;

  /// 实际参与堆叠展示的层数，直接跟随 cards 数量。
  int get _visibleCount => _cardCount;

  /// 由于底部卡片会向下露出，所以容器需要额外预留的高度。
  double get _extraBottomSpace =>
      _visibleCount <= 1 ? 0 : _offsetFor(_visibleCount - 1);

  @override
  void initState(){
    super.initState();
    _topIndex = widget.initIndex;
  }
  
  @override
  void didUpdateWidget(covariant StudyPlanCardSwiperWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 当外部 cards 数量变化时，修正当前索引，避免数组越界。
    if (_cardCount == 0) {
      _topIndex = 0;
      return;
    }
    if (_topIndex >= _cardCount) {
      _topIndex = _cardCount - 1;
    }
  }

  /// 更新顶层卡片尺寸。
  ///
  /// 尺寸变化通常来自：
  /// 1. 首次测量
  /// 2. 顶层卡片内容变化
  /// 3. 外部布局变化
  void _updateCardSize(Size size) {
    if (_cardSize == size) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _cardSize = size;
      });
    });
  }

  /// 把当前顶层下标同步给外部。
  void _notifyIndexChanged() {
    widget.onIndexChanged?.call(_topIndex);
  }

  /// 点击某张卡片时，将其提升到最上层，并通过 onIndexChanged 同步索引。
  void _handleCardTap(int cardIndex) {
    if (_isAnimating || cardIndex < 0 || cardIndex >= _cardCount) return;

    final didChangeTop = _topIndex != cardIndex;
    if (didChangeTop && mounted) {
      setState(() {
        _topIndex = cardIndex;
        _dragDy = 0;
        _direction = _StudyPlanCardSwipeDirection.none;
      });
      _notifyIndexChanged();
    }
  }

  /// 根据方向执行一次完整切换动画。
  Future<void> _animateToDirection(
      _StudyPlanCardSwipeDirection nextDirection) async {
    if (_isAnimating ||
        _cardCount <= 1 ||
        nextDirection == _StudyPlanCardSwipeDirection.none) {
      return;
    }

    setState(() {
      _direction = nextDirection;
      _isAnimating = true;
      _dragDy = 0;
      _scrollDy = 0;
    });

    await Future.delayed(widget.animationDuration);
    if (!mounted) return;

    setState(() {
      if (_direction == _StudyPlanCardSwipeDirection.up) {
        _topIndex = (_topIndex + 1) % _cardCount;
      } else if (_direction == _StudyPlanCardSwipeDirection.down) {
        _topIndex = (_topIndex - 1 + _cardCount) % _cardCount;
      }
      _isAnimating = false;
      _direction = _StudyPlanCardSwipeDirection.none;
    });
    _notifyIndexChanged();
  }

  /// 处理鼠标滚轮和触控板的纵向滚动切卡。
  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || _cardCount <= 1) return;

    GestureBinding.instance.pointerSignalResolver.register(event, (resolved) {
      if (resolved is PointerScrollEvent) {
        _handleResolvedPointerScroll(resolved);
      }
    });
  }

  /// 通过 PointerSignalResolver 抢占滚轮信号，避免被外层 Scrollable 消耗。
  void _handleResolvedPointerScroll(PointerScrollEvent event) {
    final deltaY = event.scrollDelta.dy;
    final deltaX = event.scrollDelta.dx;
    if (deltaY == 0 || deltaY.abs() < deltaX.abs()) return;
    if (_isAnimating) return;

    final isReverseDirection = _scrollDy != 0 && _scrollDy.sign != deltaY.sign;
    _scrollDy = isReverseDirection ? deltaY : _scrollDy + deltaY;

    if (_scrollDy.abs() < _scrollThreshold) return;

    final nextDirection = _scrollDy < 0
        ? _StudyPlanCardSwipeDirection.down
        : _StudyPlanCardSwipeDirection.up;
    _animateToDirection(nextDirection);
  }

  /// 在手势结束后决定是否触发切换动画。
  ///
  /// 这里不会跟手实时改变 UI，而是只在松手时统一判断：
  /// - 距离够不够
  /// - 速度够不够
  /// - 方向是向上还是向下
  Future<void> _handleDragEnd(double velocity) async {
    if (_isAnimating || _cardCount <= 1) return;

    final shouldSwipe =
        _dragDy.abs() >= widget.swipeThreshold || velocity.abs() >= 700;
    if (!shouldSwipe) {
      _resetGesture();
      return;
    }

    final nextDirection = _resolveDirection(velocity: velocity);
    if (nextDirection == _StudyPlanCardSwipeDirection.none) {
      _resetGesture();
      return;
    }

    await _animateToDirection(nextDirection);
  }

  /// 根据手势速度和累计位移计算本次切换方向。
  _StudyPlanCardSwipeDirection _resolveDirection({required double velocity}) {
    if (velocity.abs() >= 700) {
      return velocity < 0
          ? _StudyPlanCardSwipeDirection.up
          : _StudyPlanCardSwipeDirection.down;
    }

    if (_dragDy.abs() < widget.swipeThreshold) {
      return _StudyPlanCardSwipeDirection.none;
    }

    return _dragDy < 0
        ? _StudyPlanCardSwipeDirection.up
        : _StudyPlanCardSwipeDirection.down;
  }

  /// 重置当前这次手势的临时状态。
  void _resetGesture() {
    if (!mounted) return;
    setState(() {
      _direction = _StudyPlanCardSwipeDirection.none;
      _isAnimating = false;
      _dragDy = 0;
      _scrollDy = 0;
    });
  }

  /// 根据“第几层”返回这层卡片应该处于的视觉状态。
  ///
  /// 这里统一管理三种信息：
  /// - top: 纵向位置
  /// - opacity: 透明度
  /// - scale: 缩放比例
  _CardLayerState _layerStateFor(int position) {
    final progress = _visibleCount <= 1 ? 0.0 : position / (_visibleCount - 1);
    return _CardLayerState(
      top: _offsetFor(position),
      opacity: _lerp(widget.maxOpacity, widget.minOpacity, progress),
      scale: _lerp(widget.maxScale, widget.minScale, progress),
    );
  }

  /// 计算某一层距离顶部的纵向偏移。
  double _offsetFor(int position) {
    return widget.layerOffsetStep * position;
  }

  /// 在最大值和最小值之间按层级进度均匀插值。
  double _lerp(double max, double min, double progress) {
    return max + (min - max) * progress;
  }

  /// 构建当前这一帧需要显示的卡片层级配置。
  ///
  /// 返回列表顺序同时决定了 Stack 内的绘制顺序。
  List<_CardLayerConfig> _buildLayerConfigs() {
    if (_cardCount == 0) return const [];

    final layers = List<_CardLayerConfig>.generate(_visibleCount, (position) {
      final cardIndex = (_topIndex + position) % _cardCount;
      final targetPosition = _targetPositionFor(position);
      return _CardLayerConfig(
        cardIndex: cardIndex,
        position: targetPosition,
        state: _layerStateFor(targetPosition),
      );
    });

    layers.sort((a, b) => b.position.compareTo(a.position));
    return layers;
  }

  /// 计算某张卡片在当前这一帧应该落到哪一层。
  ///
  /// 例如向上切换时：
  /// - 原第 0 层移动到最后一层
  /// - 其余层整体向前补位
  int _targetPositionFor(int position) {
    if (!_isAnimating || _visibleCount <= 1) return position;

    if (_direction == _StudyPlanCardSwipeDirection.up) {
      if (position == 0) return _visibleCount - 1;
      return position - 1;
    }

    if (_direction == _StudyPlanCardSwipeDirection.down) {
      if (position == _visibleCount - 1) return 0;
      return position + 1;
    }

    return position;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return widget.customEmptyCard ?? SizedBox.shrink();
    }

    // 首次渲染时先测量一张卡片，拿到尺寸后再构建真正的堆叠区域。
    if (_cardSize == null) return _buildMeasureLayout();

    final layers = _buildLayerConfigs();

    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: (_) {
          _dragDy = 0;
        },
        onVerticalDragUpdate: (details) {
          _dragDy += details.delta.dy;
        },
        onVerticalDragEnd: (details) {
          _handleDragEnd(details.primaryVelocity ?? 0);
        },
        onVerticalDragCancel: _resetGesture,
        child: SizedBox(
          width: _cardSize!.width,
          height: _cardSize!.height + _extraBottomSpace,
          child: ColoredBox(
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.topCenter,
              child: Stack(
                clipBehavior: Clip.none,
                children: layers
                    .map(
                      (layer) => _buildCardLayer(
                        cardIndex: layer.cardIndex,
                        state: layer.state,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 用第一张卡片先做一次离屏测量，得到基础尺寸。
  Widget _buildMeasureLayout() {
    return UnconstrainedBox(
      constrainedAxis: Axis.vertical,
      alignment: Alignment.topCenter,
      child: _MeasureSize(
        onChange: _updateCardSize,
        child: KeyedSubtree(
          key: const ValueKey('measure_card'),
          child: widget.cards.first,
        ),
      ),
    );
  }

  /// 构建单层卡片。
  ///
  /// 每一层都通过以下三个动画共同形成层叠效果：
  /// - AnimatedPositioned: 上下移动
  /// - AnimatedScale: 前后层级的缩放差异
  /// - AnimatedOpacity: 深浅层次过渡
  Widget _buildCardLayer({
    required int cardIndex,
    required _CardLayerState state,
  }) {
    return AnimatedPositioned(
      key: ValueKey(cardIndex),
      duration: widget.animationDuration,
      curve: Curves.linear,
      top: state.top,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedScale(
          duration: widget.animationDuration,
          curve: Curves.linear,
          scale: state.scale,
          alignment: Alignment.topCenter,
          child: AnimatedOpacity(
            duration: widget.animationDuration,
            curve: Curves.linear,
            opacity: state.opacity.clamp(0.0, 1.0),
            child: UnconstrainedBox(
              constrainedAxis: Axis.vertical,
              alignment: Alignment.topCenter,
              child: _MeasureSize(
                onChange: (size) {
                  if (cardIndex == _topIndex && !_isAnimating) {
                    _updateCardSize(size);
                  }
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => _handleCardTap(cardIndex),
                  child: KeyedSubtree(
                    key: ValueKey('card_$cardIndex'),
                    child: widget.cards[cardIndex],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _StudyPlanCardSwipeDirection {
  none,
  up,
  down,
}

/// 描述某一层当前应该显示哪张卡片，以及这张卡片的视觉状态。
class _CardLayerConfig {
  const _CardLayerConfig({
    required this.cardIndex,
    required this.position,
    required this.state,
  });

  final int cardIndex;
  final int position;
  final _CardLayerState state;
}

/// 某一层卡片的视觉表现。
class _CardLayerState {
  const _CardLayerState({
    required this.top,
    required this.opacity,
    required this.scale,
  });

  final double top;
  final double opacity;
  final double scale;
}

/// 用于测量 child 实际渲染尺寸的轻量组件。
class _MeasureSize extends SingleChildRenderObjectWidget {
  final ValueChanged<Size> onChange;

  const _MeasureSize({
    required this.onChange,
    required super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _MeasureSizeRenderObject(onChange);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _MeasureSizeRenderObject renderObject) {
    renderObject.onChange = onChange;
  }
}

/// 尺寸测量对应的 RenderObject。
class _MeasureSizeRenderObject extends RenderProxyBox {
  _MeasureSizeRenderObject(this.onChange);

  ValueChanged<Size> onChange;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    final newSize = child?.size;
    if (newSize == null || newSize == _oldSize) return;
    _oldSize = newSize;

    // 放到下一帧回调，避免在布局阶段直接触发 setState。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}
