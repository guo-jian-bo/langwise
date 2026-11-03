import 'dart:async';

import 'package:flutter/material.dart';

/// 创建简单而美观的微光动画效果
///
/// Shimmer（微光效果）在开发社区中被广泛用作骨架加载器或占位符小部件的默认动画。
/// 因此，拥有一个易于使用且可自定义的小部件，可用于Android、iOS和Web，使开发人员能够专注于实际功能，让微光效果使加载体验更加流畅。
///
/// 默认情况下，该小部件将选择预设配置，但可以轻松自定义，如下所示：
///
/// - @required [child] : 接受一个子 [Widget]，动画将显示在其上
/// - [color] : 接受一个 [Color] 并设置动画覆盖层的颜色。默认值为 [Colors.white]
/// - [colorOpacity] : 接受一个 [double] 并设置动画覆盖层颜色的不透明度。默认值为 [0.3]
/// - [enabled] : 接受一个 [bool]，用于开启/关闭动画。默认值为 [true]
/// - [duration] : 接受一个 [Duration]，表示动画的时间周期。默认值为 [Duration(seconds: 3)]
/// - [interval] : 接受一个 [Duration]，表示重复动画之间的间隔。默认值为 [Duration(seconds: 0)]
/// - [direction] : 接受一个 [ShimmerDirection] 并相应地对齐动画。默认值为 [ShimmerDirection.fromLBRT()]
class ShimmerWidget extends StatelessWidget {
  /// 接受一个子 [Widget]，动画将显示在其上
  final Widget child;

  /// 接受一个 [bool]，用于开启/关闭动画。默认值为 [true]
  final bool enabled;

  /// 接受一个 [Color] 类型的参数并设置动画覆盖层的颜色。默认值为 [Colors.white]
  final Color color;

  /// 接受一个 [double] 类型的参数并设置动画覆盖层颜色的不透明度。默认值为 [0.3]
  final double colorOpacity;

  /// 接受一个 [Duration]，表示动画的时间周期。默认值为 [Duration(seconds: 3)]
  final Duration duration;

  /// 接受一个 [Duration]，表示重复动画之间的间隔。默认值为 [Duration(seconds: 0)]，即无间隔
  final Duration interval;

  /// 接受一个 [ShimmerDirection] 并相应地对齐动画。默认值为 [ShimmerDirection.fromLTRB()]
  final ShimmerDirection direction;

  const ShimmerWidget({
    super.key,
    required this.child,
    this.enabled = true,
    this.color = Colors.white,
    this.colorOpacity = 0.3,
    this.duration = const Duration(seconds: 3),
    this.interval = const Duration(seconds: 0),
    this.direction = const ShimmerDirection.fromLTRB(),
  });

  @override
  Widget build(BuildContext context) {
    if (enabled) {
      return ShimmerAnimator(
        child: child,
        color: color,
        opacity: colorOpacity,
        duration: duration,
        interval: interval,
        direction: direction,
      );
    } else {
      return child;
    }
  }
}

/// 微光动画将沿其移动的方向
///
///
/// 微光动画可以沿6个可能的方向移动：
///
/// 对角线方向：
/// - [ShimmerDirection.fromLTRB] : 动画从左上角开始，向右下角移动。如果未指定方向，这也是默认行为。
/// - [ShimmerDirection.fromRTLB] : 动画从右上角开始，向左下角移动
/// - [ShimmerDirection.fromLBRT] : 动画从左下角开始，向右上角移动
/// - [ShimmerDirection.fromRBLT] : 动画从右下角开始，向左上角移动
///
/// 沿轴线的方向：
/// - [ShimmerDirection.fromLeftToRight] : 动画从左中心开始，向右中心移动
/// - [ShimmerDirection.fromRightToLeft] : 动画从右中心开始，向左中心移动
class ShimmerDirection {
  final Alignment begin, end;

  const ShimmerDirection._fromLTRB({
    this.begin = Alignment.topLeft,
    this.end = Alignment.centerRight,
  });

  const ShimmerDirection._fromRTLB({
    this.begin = Alignment.centerRight,
    this.end = Alignment.topLeft,
  });

  const ShimmerDirection._fromLBRT({
    this.begin = Alignment.bottomLeft,
    this.end = Alignment.centerRight,
  });

  const ShimmerDirection._fromRBLT({
    this.begin = Alignment.topRight,
    this.end = Alignment.centerLeft,
  });

  const ShimmerDirection._fromLeftToRight({
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
  });

  const ShimmerDirection._fromRightToLeft({
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
  });

  const ShimmerDirection._fromAlignment({
    required this.begin,
    required this.end,
  });
    
  factory ShimmerDirection.fromAlignment({
    required Alignment begin,
    required Alignment end,
  }) {
    return ShimmerDirection._fromAlignment(begin: begin, end: end);
  }

  const factory ShimmerDirection() = ShimmerDirection._fromLTRB;

  /// 动画从左上角开始，向右下角移动
  const factory ShimmerDirection.fromLTRB() = ShimmerDirection._fromLTRB;

  /// 动画从右上角开始，向左下角移动
  const factory ShimmerDirection.fromRTLB() = ShimmerDirection._fromRTLB;

  /// 动画从左下角开始，向右上角移动
  const factory ShimmerDirection.fromLBRT() = ShimmerDirection._fromLBRT;

  /// 动画从右下角开始，向左上角移动
  const factory ShimmerDirection.fromRBLT() = ShimmerDirection._fromRBLT;

  /// 动画从左中心开始，向右中心移动
  const factory ShimmerDirection.fromLeftToRight() =
      ShimmerDirection._fromLeftToRight;

  /// 动画从右中心开始，向左中心移动
  const factory ShimmerDirection.fromRightToLeft() =
      ShimmerDirection._fromRightToLeft;
}


class CustomSplashAnimation extends CustomPainter {
  final BuildContext context;
  double position, opacity;
  double width = 0.2;
  final Color color;
  final Alignment begin, end;

  CustomSplashAnimation({
    required this.context,
    required this.position,
    required this.color,
    required this.opacity,
    required this.begin,
    required this.end,
  });

  //自定义画笔用于绘制动画的一帧。这在循环中被调用以实现动画效果
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    var stops = [
      0.0,
      position,
      (position + width) > 1 ? 1.0 : position + width,
      (position + (width * 2)) > 1 ? 1.0 : position + (width * 2),
      1.0
    ];
    // position = 0.7;
    paint.style = PaintingStyle.fill;
    paint.shader = LinearGradient(
      tileMode: TileMode.decal,
      begin: begin,
      end: end,
      stops: stops,
      colors: [
        Colors.transparent,
        (color).withValues(alpha: 0.05),
        (color).withValues(alpha: opacity),
        (color).withValues(alpha: 0.05),
        Colors.transparent
      ],
    ).createShader(
      Rect.fromLTRB(
          size.width * -0.5,
          (size.height > size.width) ? 0 : size.height * -0.5,
          size.width * 1.5,
          size.height * 1.5),
    );
    var path = Path();

    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class ShimmerAnimator extends StatefulWidget {
  final Color color;
  final double opacity;
  final Duration duration;
  final Duration interval;
  final ShimmerDirection direction;
  final Widget child;

  const ShimmerAnimator({
    super.key,
    required this.child,
    required this.color,
    required this.opacity,
    required this.duration,
    required this.interval,
    required this.direction,
  });

  @override
  State<ShimmerAnimator> createState() => _ShimmerAnimatorState();
}

//Animator状态控制动画使用所有定义的参数
class _ShimmerAnimatorState extends State<ShimmerAnimator>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: widget.duration);
    animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: controller,
      curve: const Interval(0, 0.6, curve: Curves.decelerate),
    ))
      ..addListener(() async {
        if (controller.isCompleted) {
          timer = Timer(widget.interval,
              () => mounted ? controller.forward(from: 0) : null);
        }
        setState(() {});
      });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: CustomSplashAnimation(
        context: context,
        position: animation.value,
        color: widget.color,
        opacity: widget.opacity,
        begin: widget.direction.begin,
        end: widget.direction.end,
      ),
      child: widget.child,
    );
  }
}