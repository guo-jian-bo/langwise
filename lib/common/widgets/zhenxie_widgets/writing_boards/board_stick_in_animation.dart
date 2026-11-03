import 'package:flutter/material.dart';

class BoardStickInAnimation extends StatefulWidget {
  /// 是否显示入场动画
  final bool showAnimation;

  /// 动画延迟时间
  final Duration delay;

  /// 动画总时长
  final Duration duration;

  /// 起始纵向偏移
  final double beginOffsetY;

  /// 起始缩放值
  final double beginScale;

  /// 过渡缩放值
  final double middleScale;

  /// 起始旋转角度
  final double beginRotationAngle;

  /// 最终旋转角度
  final double endRotationAngle;

  /// 动画内容构建器
  final Widget Function(BuildContext context, double rotationAngle) builder;

  /// 贴上去入场动画
  const BoardStickInAnimation({
    super.key,
    required this.builder,
    this.showAnimation = true,
    this.delay = const Duration(milliseconds: 500),
    this.duration = const Duration(milliseconds: 720),
    this.beginOffsetY = -30,
    this.beginScale = 1.08,
    this.middleScale = 0.97,
    this.beginRotationAngle = 0,
    this.endRotationAngle = 0,
  });

  @override
  State<BoardStickInAnimation> createState() => _BoardStickInAnimationState();
}

class _BoardStickInAnimationState extends State<BoardStickInAnimation> with SingleTickerProviderStateMixin {
  /// 入场动画控制器
  late final AnimationController _controller;

  /// 整体下落位移动画
  late Animation<double> _slideAnimation;

  /// 贴上去的缩放动画
  late Animation<double> _scaleAnimation;

  /// 旋转收束动画
  late Animation<double> _rotationAnimation;

  /// 透明度动画
  late Animation<double> _opacityAnimation;

  /// 延迟启动令牌，避免旧回调误触发
  int _delayedForwardToken = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _rebuildAnimations();
    _syncAnimationState(restart: false);
  }

  @override
  void didUpdateWidget(covariant BoardStickInAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) _controller.duration = widget.duration;

    if (_shouldRebuildAnimations(oldWidget)) _rebuildAnimations();
    if (_shouldResyncPlayback(oldWidget)) _syncAnimationState(restart: true);
  }

  /// 判断动画参数是否发生变化
  bool _shouldRebuildAnimations(BoardStickInAnimation oldWidget) {
    return oldWidget.beginOffsetY != widget.beginOffsetY ||
        oldWidget.beginScale != widget.beginScale ||
        oldWidget.middleScale != widget.middleScale ||
        oldWidget.beginRotationAngle != widget.beginRotationAngle ||
        oldWidget.endRotationAngle != widget.endRotationAngle;
  }

  /// 判断是否需要重新同步播放状态
  bool _shouldResyncPlayback(BoardStickInAnimation oldWidget) {
    return oldWidget.showAnimation != widget.showAnimation || oldWidget.delay != widget.delay;
  }

  /// 根据当前参数重建动画轨迹
  void _rebuildAnimations() {
    _slideAnimation = Tween<double>(begin: widget.beginOffsetY, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.82, curve: Curves.easeOutCubic)),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: widget.beginScale, end: widget.middleScale).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 58,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: widget.middleScale, end: 1).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 42,
      ),
    ]).animate(_controller);
    _rotationAnimation = Tween<double>(
      begin: widget.beginRotationAngle,
      end: widget.endRotationAngle,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0, 1, curve: Curves.easeOutBack)));
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.3, curve: Curves.easeOut)),
    );
  }

  /// 同步动画开关和延迟启动状态
  void _syncAnimationState({required bool restart}) {
    _delayedForwardToken++;
    if (!widget.showAnimation) {
      _controller.value = 1;
      return;
    }
    if (restart) _controller.value = 0;
    final int token = _delayedForwardToken;
    Future<void>.delayed(widget.delay, () {
      if (!mounted || token != _delayedForwardToken || !widget.showAnimation) return;
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _delayedForwardToken++;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              alignment: Alignment.topCenter,
              child: widget.builder(context, _rotationAnimation.value),
            ),
          ),
        );
      },
    );
  }
}
