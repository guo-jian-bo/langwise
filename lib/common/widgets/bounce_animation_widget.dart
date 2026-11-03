/// 上下抖动动画组件
///
/// 功能与优点：
/// 1. 提供一个可复用的上下抖动动画效果，支持自定义背景色、边框和圆角
/// 2. 实现交错动画效果：先从顶部滑入，然后再执行自然的抖动动画
/// 3. 使用 TweenSequence 创建多阶段动画，模拟真实物理抖动效果
/// 4. 支持全屏宽度显示，可自定义文本和子组件对齐方式
/// 5. 提供便捷的静态方法显示浮层提示，无需手动管理 OverlayEntry
/// 6. 支持自定义重复次数和动画完成回调
/// 7. 使用 TickerProviderStateMixin 支持多个动画控制器协同工作
///
/// 技术特点：
/// - 采用策略模式配置不同的动画曲线和参数
/// - 使用组合模式将多个简单动画组合成复杂效果
/// - 遵循单一职责原则，每个动画控制器负责一个特定的动画阶段
///
/// 使用场景：
/// - 切换新释义或词性时的提示
/// - 操作成功后的确认反馈（如评分已保存、已添加收藏等）
/// - 需要引起用户注意的UI元素
/// - 错误或警告提示，带有视觉反馈
/// - 强调新功能或更新的内容
///
/// 使用示例：
/// ```dart
/// // 直接使用组件
/// BounceAnimationWidget(
///   child: Text('提示消息'),
///   alignment: Alignment.center,
/// )
/// 
/// // 使用静态方法显示浮层提示
/// BounceAnimationHelper.showBounceMessage(
///   context: context,
///   message: '操作成功',
///   position: position,
///   width: screenWidth,
///   textAlign: TextAlign.center,
/// )
/// ```
///
/// 作者：LangWise Team
/// 最后更新：2025-05-25

import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

class BounceAnimationWidget extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 背景颜色，默认淡黄色
  final Color backgroundColor;

  /// 边框颜色，默认深黄色
  final Color borderColor;

  /// 边框宽度
  final double borderWidth;

  /// 圆角半径
  final double borderRadius;

  /// 内边距
  final EdgeInsetsGeometry padding;

  /// 子组件对齐方式
  final Alignment alignment;

  /// 是否自动播放动画
  final bool autoPlay;

  /// 动画持续时间
  final Duration duration;

  /// 动画重复次数，设置为0表示无限循环
  final int repeatCount;

  /// 动画完成回调
  final VoidCallback? onAnimationComplete;

  const BounceAnimationWidget({
    Key? key,
    required this.child,
    this.backgroundColor = const Color(0xFFFFF9E6), // 淡黄色背景
    this.borderColor = const Color(0xFFFFD54F), // 深黄色边框
    this.borderWidth = 1.5,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.alignment = Alignment.centerLeft, // 默认居中左对齐
    this.autoPlay = true,
    this.duration = const Duration(milliseconds: 300),
    this.repeatCount = 3,
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<BounceAnimationWidget> createState() => _BounceAnimationWidgetState();
}

class _BounceAnimationWidgetState extends State<BounceAnimationWidget>
    with TickerProviderStateMixin, SafeSetStateMixin {
  /// 滑入动画控制器
  late AnimationController _slideController;

  /// 抖动动画控制器
  late AnimationController _bounceController;

  /// 滑入动画
  late Animation<Offset> _slideAnimation;

  /// 抖动动画
  late Animation<Offset> _bounceAnimation;

  /// 当前重复次数
  int _currentRepeatCount = 0;

  /// 动画阶段
  bool _isSlideCompleted = false;

  @override
  void initState() {
    super.initState();

    // 初始化滑入动画控制器
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 初始化抖动动画控制器
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // 增加时长使抖动更自然
    );

    // 创建从顶部滑入的动画
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0), // 从屏幕顶部外开始
      end: const Offset(0, 0), // 滑动到目标位置
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutQuart, // 使用缓出曲线，模拟物理滑动
      ),
    );

    // 创建上下抖动的位移动画，使用正弦曲线实现更自然的抖动
    _bounceAnimation = TweenSequence<Offset>([
      // 先缓慢向上移动
      TweenSequenceItem<Offset>(
        tween: Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, -6),
        ).chain(CurveTween(curve: Curves.easeOutSine)),
        weight: 25.0,
      ),
      // 然后向下移动超过起始位置
      TweenSequenceItem<Offset>(
        tween: Tween<Offset>(
          begin: const Offset(0, -6),
          end: const Offset(0, 2),
        ).chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 25.0,
      ),
      // 再向上移动但幅度减小
      TweenSequenceItem<Offset>(
        tween: Tween<Offset>(
          begin: const Offset(0, 2),
          end: const Offset(0, -3),
        ).chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 25.0,
      ),
      // 最后回到起始位置
      TweenSequenceItem<Offset>(
        tween: Tween<Offset>(
          begin: const Offset(0, -3),
          end: const Offset(0, 0),
        ).chain(CurveTween(curve: Curves.easeOutSine)),
        weight: 25.0,
      ),
    ]).animate(_bounceController);

    // 添加动画状态监听
    _slideController.addStatusListener(_handleSlideAnimationStatus);
    _bounceController.addStatusListener(_handleBounceAnimationStatus);

    // 如果设置为自动播放，则启动动画
    if (widget.autoPlay) {
      _playAnimation();
    }
  }

  /// 处理滑入动画状态变化
  void _handleSlideAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // 滑入完成后，开始抖动动画
      setState(() {
        _isSlideCompleted = true;
      });
      _bounceController.forward();
    }
  }

  /// 处理抖动动画状态变化
  void _handleBounceAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // 动画完成后，判断是否需要继续播放
      _currentRepeatCount++;

      // 如果重复次数为0或者未达到指定次数，继续播放
      if (widget.repeatCount == 0 || _currentRepeatCount < widget.repeatCount) {
        // 重新开始动画而不是反向播放，这样抖动更自然
        _bounceController.reset();
        _bounceController.forward();
      } else {
        // 达到指定重复次数，调用完成回调
        if (widget.onAnimationComplete != null) {
          widget.onAnimationComplete!();
        }
      }
    }
  }

  /// 手动播放动画
  void playAnimation() {
    _currentRepeatCount = 0;
    _isSlideCompleted = false;
    _playAnimation();
  }

  /// 内部播放动画方法
  void _playAnimation() {
    // 重置所有动画控制器
    _slideController.reset();
    _bounceController.reset();

    // 先播放滑入动画
    _slideController.forward();
  }

  @override
  void dispose() {
    // 移除监听并释放控制器
    _slideController.removeStatusListener(_handleSlideAnimationStatus);
    _bounceController.removeStatusListener(_handleBounceAnimationStatus);
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: AnimatedBuilder(
        animation: _bounceController,
        builder: (context, child) {
          // 只有在滑入完成后才应用抖动动画
          final offset = _isSlideCompleted ? _bounceAnimation.value : const Offset(0, 0);

          return Transform.translate(
            offset: Offset(0, offset.dy),
            child: child,
          );
        },
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius.ww),
            border: Border.all(
              color: widget.borderColor,
              width: widget.borderWidth.wMin,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: widget.alignment, // 使用指定的对齐方式
          child: widget.child,
        ),
      ),
    );
  }
}

/// 便捷方法：显示抖动提示
class BounceAnimationHelper {
  /// 在指定位置显示抖动提示
  static OverlayEntry? showBounceMessage({
    required BuildContext context,
    required String message,
    required Offset position,
    TextStyle? textStyle,
    Duration displayDuration = const Duration(seconds: 3), // 增加显示时间以适应交错动画
    VoidCallback? onDismissed,
    double? width, // 动画组件宽度，为空时自适应
    TextAlign textAlign = TextAlign.start, // 文本对齐方式
    Alignment alignment = Alignment.center, // 子组件对齐方式
    // 重复次数
    int repeatCount = 3,
  }) {
    // 创建一个OverlayEntry
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy,
        width: width, // 设置宽度，如果提供了的话
        child: Material(
          color: Colors.transparent,
          child: BounceAnimationWidget(
            repeatCount: repeatCount,
            alignment: alignment, // 设置子组件对齐方式
            child: Text(
              message,
              textAlign: textAlign, // 设置文本对齐方式
              style: textStyle ??
                  TextStyle(
                    fontSize: 14.wMin,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
            ),
            onAnimationComplete: () {
              // 动画完成后延迟关闭
              Future.delayed(displayDuration, () {
                // 添加安全检查，确保Overlay仍然存在再移除
                if (entry.mounted) {
                  try {
                    entry.remove();
                  } catch (e) {
                    print("BounceAnimationHelper: 移除Overlay时发生异常 - $e");
                  }
                }
                
                if (onDismissed != null) {
                  onDismissed();
                }
              });
            },
          ),
        ),
      ),
    );

    // 将OverlayEntry添加到Overlay中
    Overlay.of(context).insert(entry);

    return entry;
  }
}
