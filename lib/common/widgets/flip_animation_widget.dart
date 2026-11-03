import 'dart:math';
import 'package:flutter/material.dart';

/// 通用翻转动画组件
///
/// 支持前后两个组件之间的3D翻转动画效果，可用于组件间的切换过渡
///
/// 使用示例:
/// ```dart
/// FlipAnimationWidget(
///   isFlipped: _isFlipped,  // 控制是否翻转的状态变量
///   duration: const Duration(milliseconds: 500),  // 动画持续时间
///   frontWidget: Container(color: Colors.blue, child: Text('正面')),  // 正面显示的组件
///   backWidget: Container(color: Colors.red, child: Text('背面')),  // 背面显示的组件
/// )
/// ```
class FlipAnimationWidget extends StatefulWidget {
  /// 是否处于翻转状态
  final bool isFlipped;

  /// 翻转动画持续时间
  final Duration duration;

  /// 正面显示的组件
  final Widget frontWidget;

  /// 背面显示的组件
  final Widget backWidget;

  /// 翻转方向，默认为水平方向翻转
  final Axis direction;

  const FlipAnimationWidget({
    Key? key,
    required this.isFlipped,
    this.duration = const Duration(milliseconds: 500),
    required this.frontWidget,
    required this.backWidget,
    this.direction = Axis.horizontal,
  }) : super(key: key);

  @override
  State<FlipAnimationWidget> createState() => _FlipAnimationWidgetState();
}

class _FlipAnimationWidgetState extends State<FlipAnimationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // 如果初始状态就是翻转的，则立即设置动画到最终状态
    if (widget.isFlipped) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(FlipAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 当isFlipped状态变化时执行动画
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final isShowingBack = _animation.value >= 0.5;

        // 计算当前的翻转角度
        final value = isShowingBack ? _animation.value * pi : _animation.value * pi;

        return Transform(
          // 设置变换原点为中心
          alignment: Alignment.center,
          // 使用Matrix4进行3D变换
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // 添加透视效果
            ..rotateY(widget.direction == Axis.horizontal ? value : 0)
            ..rotateX(widget.direction == Axis.vertical ? value : 0),
          child: isShowingBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(widget.direction == Axis.horizontal ? pi : 0)
                    ..rotateX(widget.direction == Axis.vertical ? pi : 0),
                  child: widget.backWidget,
                )
              : widget.frontWidget,
        );
      },
    );
  }
}
