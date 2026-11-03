import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

class StudyPlanPageviewController {
  _StudyPlanPageviewWidgetState? _state;

  /// 切换到指定页面
  void animateToWidget(int index) {
    _state?.animateToWidget(index);
  }

  void jumpToPage(int index) {
    _state?.jumpToWidget(index);
  }
}

/// 使用自定义滑动手势展示学习计划卡片容器动画。
class StudyPlanPageviewWidget extends StatefulWidget {
  final StudyPlanPageviewController? controller;
  final List<Widget> children;
  final ValueChanged<int>? onPageChanged;
  final double viewportWidth;
  final double viewportHeight;

  const StudyPlanPageviewWidget({
    super.key,
    this.controller,
    required this.children,
    this.onPageChanged,
    required this.viewportWidth,
    required this.viewportHeight,
  });

  @override
  State<StudyPlanPageviewWidget> createState() =>
      _StudyPlanPageviewWidgetState();
}

class _StudyPlanPageviewWidgetState extends State<StudyPlanPageviewWidget>
    with SingleTickerProviderStateMixin {
  static const Duration _animationDuration = Duration(milliseconds: 450);
  static const Duration _wheelLockDuration = Duration(milliseconds: 280);

  late final AnimationController _animationController;

  int _currentIndex = 0;
  double _animationFromIndex = 0;
  double _animationToIndex = 0;

  int? _activePointer;
  Offset? _dragStartOffset;
  Offset? _dragLastOffset;
  bool _wheelLocked = false;
  Timer? _wheelLockTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..addStatusListener(_handleAnimationStatusChanged);
    _bindController(widget.controller);
  }

  /// 切换到指定widget index
  void jumpToWidget(int index) {
    if (widget.children.isEmpty) return;

    final int targetIndex = index.clamp(0, widget.children.length - 1);
    final double targetValue = targetIndex.toDouble();

    if ((_currentAnimatedIndex - targetValue).abs() < 0.001) {
      return;
    }

    setState(() {
      _currentIndex = targetIndex;
      _animationFromIndex = targetValue;
      _animationToIndex = targetValue;
      _animationController.stop();
      _animationController.value = 1;
    });

    widget.onPageChanged?.call(_currentIndex);
  }

  /// 切换到指定widget index
  void animateToWidget(int index) {
    if (widget.children.isEmpty) return;

    final int targetIndex = index.clamp(0, widget.children.length - 1);
    final double animatedIndex = _currentAnimatedIndex;

    if ((animatedIndex - targetIndex).abs() < 0.001) {
      return;
    }

    setState(() {
      _currentIndex = targetIndex;
      _animationFromIndex = animatedIndex;
      _animationToIndex = targetIndex.toDouble();
    });

    _animationController.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant StudyPlanPageviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller?._state == this) {
        oldWidget.controller?._state = null;
      }
      _bindController(widget.controller);
    }

    if (widget.children.isEmpty) {
      _resetIndexes();
      return;
    }

    final int maxIndex = widget.children.length - 1;
    if (_currentIndex > maxIndex) {
      _resetIndexes(targetIndex: maxIndex);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onPageChanged?.call(_currentIndex);
      });
    }
  }

  @override
  void dispose() {
    _wheelLockTimer?.cancel();
    _animationController
      ..removeStatusListener(_handleAnimationStatusChanged)
      ..dispose();
    if (widget.controller?._state == this) {
      widget.controller?._state = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) {
      return const SizedBox.shrink();
    }

    final double viewportWidth = widget.viewportWidth;
    final double viewportHeight = widget.viewportHeight;
    final double sidePadding = 24.wMin;
    final double baseSpacing = 440.wMin;
    final double spacing = math.min(
      baseSpacing,
      math.max(300.wMin, (viewportWidth - sidePadding * 2) * 0.5),
    );

    return SizedBox(
      width: viewportWidth,
      height: viewportHeight,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _handlePointerDown,
        onPointerMove: _handlePointerMove,
        onPointerUp: _handlePointerUp,
        onPointerCancel: _handlePointerCancel,
        onPointerSignal: _handlePointerSignal,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sidePadding,
            vertical: 12.wMin,
          ),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) {
              final double activeIndex = _currentAnimatedIndex;
              final List<_StudyPlanAnimatedItem> items = List.generate(
                widget.children.length,
                (index) => _StudyPlanAnimatedItem(
                  index: index,
                  style: _resolveItemStyle(
                    index: index,
                    activeIndex: activeIndex,
                    spacing: spacing,
                    total: widget.children.length,
                  ),
                ),
              )..sort((a, b) => a.style.zIndex.compareTo(b.style.zIndex));
        
              return Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: items.map((item) {
                  final int index = item.index;
                  final _StudyPlanItemStyle style = item.style;
                  return Positioned.fill(
                    key: ValueKey(index),
                    child: IgnorePointer(
                      ignoring: _animationController.isAnimating,
                      child: Align(
                        alignment: Alignment.center,
                        child: OverflowBox(
                          minWidth: 0,
                          maxWidth: double.infinity,
                          minHeight: 0,
                          maxHeight: double.infinity,
                          alignment: Alignment.topCenter,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: style.transform,
                            child: Opacity(
                              opacity: style.opacity,
                              child: KeyedSubtree(
                                key: ValueKey('study_plan_page_child_$index'),
                                child: widget.children[index],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  void _bindController(StudyPlanPageviewController? controller) {
    controller?._state = this;
  }

  void _resetIndexes({int targetIndex = 0}) {
    final double value = targetIndex.toDouble();
    _currentIndex = targetIndex;
    _animationFromIndex = value;
    _animationToIndex = value;
    _animationController.stop();
  }

  double get _currentAnimatedIndex {
    final double progress =
        Curves.easeInOutCubic.transform(_animationController.value);
    return lerpDouble(_animationFromIndex, _animationToIndex, progress) ??
        _animationToIndex;
  }

  _StudyPlanItemStyle _resolveItemStyle({
    required int index,
    required double activeIndex,
    required double spacing,
    required int total,
  }) {
    final double diff = index - activeIndex;
    final double absDiff = diff.abs();
    final double clampedDiff = absDiff.clamp(0, 2.4);
    final double scaleX = (1 - clampedDiff * 0.16).clamp(0.6, 1.0);
    final double scaleY = (1 - clampedDiff * 0.08).clamp(0.82, 1.0);
    final double opacity = (1 - clampedDiff * 0.4).clamp(0.4, 1.0);
    final double translateX = diff * spacing;
    final double translateZ = absDiff == 0 ? 0 : -60.wMin * clampedDiff.clamp(0, 1);
    final double rotateY = diff * 0.2;
    final int zIndex = total - (absDiff * 10).round();

    final Matrix4 transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..translateByDouble(translateX, 0.0, translateZ, 1)
      ..rotateY(rotateY)
      ..scaleByDouble(scaleX, scaleY, 1, 1);

    return _StudyPlanItemStyle(
      transform: transform,
      opacity: opacity,
      zIndex: zIndex,
    );
  }

  void _handleAnimationStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }

    _animationFromIndex = _animationToIndex;
    widget.onPageChanged?.call(_currentIndex);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_activePointer != null) {
      return;
    }
    _activePointer = event.pointer;
    _dragStartOffset = event.position;
    _dragLastOffset = event.position;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_activePointer != event.pointer) {
      return;
    }
    _dragLastOffset = event.position;
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_activePointer != event.pointer) {
      return;
    }
    _dragLastOffset = event.position;
    _handleDragEnd();
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (_activePointer != event.pointer) {
      return;
    }
    _clearDragState();
  }

  void _handleDragEnd() {
    final Offset? start = _dragStartOffset;
    final Offset? end = _dragLastOffset;
    _clearDragState();

    if (start == null || end == null || widget.children.length <= 1) {
      return;
    }

    final double deltaX = end.dx - start.dx;
    final double absX = deltaX.abs();
    final double absY = (end.dy - start.dy).abs();
    final double threshold = 48.wMin;

    if (absX < threshold || absX <= absY) {
      return;
    }

    if (deltaX > 0) {
      animateToWidget(_currentIndex - 1);
      return;
    }

    animateToWidget(_currentIndex + 1);
  }

  void _clearDragState() {
    _activePointer = null;
    _dragStartOffset = null;
    _dragLastOffset = null;
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent ||
        _wheelLocked ||
        widget.children.length <= 1) {
      return;
    }

    final double deltaX = event.scrollDelta.dx;
    if (deltaX.abs() < 8.wMin) {
      return;
    }

    _wheelLocked = true;
    _wheelLockTimer?.cancel();
    _wheelLockTimer = Timer(_wheelLockDuration, () {
      _wheelLocked = false;
    });

    if (deltaX > 0) {
      animateToWidget(_currentIndex + 1);
      return;
    }

    animateToWidget(_currentIndex - 1);
  }
}

class _StudyPlanItemStyle {
  final Matrix4 transform;
  final double opacity;
  final int zIndex;

  const _StudyPlanItemStyle({
    required this.transform,
    required this.opacity,
    required this.zIndex,
  });
}

class _StudyPlanAnimatedItem {
  final int index;
  final _StudyPlanItemStyle style;

  const _StudyPlanAnimatedItem({
    required this.index,
    required this.style,
  });
}
