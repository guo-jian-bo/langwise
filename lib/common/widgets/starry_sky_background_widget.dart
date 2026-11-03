import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 星空背景组件
/// 
/// 在随机位置生成随机闪烁的星星，可以通过参数控制星星的大小、颜色、数量和闪烁速度等
class StarrySkyBackgroundWidget extends StatefulWidget {
  /// 子组件
  final Widget? child;
  
  /// 星星的数量
  final int starCount;
  
  /// 星星的最小尺寸
  final double minStarSize;
  
  /// 星星的最大尺寸
  final double maxStarSize;
  
  /// 星星的基础颜色
  final Color starColor;
  
  /// 闪烁的最小速度（每帧亮度变化量）
  final double minTwinkleSpeed;
  
  /// 闪烁的最大速度（每帧亮度变化量）
  final double maxTwinkleSpeed;
  
  /// 星星的最小亮度 (0.0-1.0)
  final double minBrightness;
  
  /// 星星的最大亮度 (0.0-1.0)
  final double maxBrightness;

  const StarrySkyBackgroundWidget({
    super.key, 
    this.child,
    this.starCount = 100,
    this.minStarSize = 1.0,
    this.maxStarSize = 3.0,
    this.starColor = Colors.white,
    this.minTwinkleSpeed = 0.05,
    this.maxTwinkleSpeed = 0.15,
    this.minBrightness = 0.2,
    this.maxBrightness = 1.0,
  });

  @override
  State<StarrySkyBackgroundWidget> createState() => _StarrySkyBackgroundWidgetState();
}

class _StarrySkyBackgroundWidgetState extends State<StarrySkyBackgroundWidget> with SingleTickerProviderStateMixin {
  /// 存储所有星星的信息
  late List<_SimpleStar> _stars;
  
  /// 帧计时器
  late Ticker _ticker;
  
  /// 随机数生成器
  final _random = math.Random();
  
  @override
  void initState() {
    super.initState();
    
    // 初始化星星
    _initStars();
    
    // 创建帧计时器
    _ticker = createTicker(_onTick);
    _ticker.start();
  }
  
  /// 每帧更新
  void _onTick(Duration elapsed) {
    // 强制重绘
    setState(() {
      // 什么也不做，只是触发重绘
    });
  }
  
  @override
  void didUpdateWidget(StarrySkyBackgroundWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.starCount != widget.starCount ||
        oldWidget.minStarSize != widget.minStarSize ||
        oldWidget.maxStarSize != widget.maxStarSize ||
        oldWidget.minTwinkleSpeed != widget.minTwinkleSpeed ||
        oldWidget.maxTwinkleSpeed != widget.maxTwinkleSpeed) {
      _initStars();
    }
  }
  
  @override
  void dispose() {
    // 停止并释放帧计时器
    _ticker.stop();
    _ticker.dispose();
    super.dispose();
  }
  
  /// 初始化星星
  void _initStars() {
    _stars = List.generate(widget.starCount, (_) {
      return _SimpleStar(
        position: Offset(
          _random.nextDouble(),
          _random.nextDouble(),
        ),
        size: widget.minStarSize + _random.nextDouble() * (widget.maxStarSize - widget.minStarSize),
        speed: widget.minTwinkleSpeed + _random.nextDouble() * (widget.maxTwinkleSpeed - widget.minTwinkleSpeed),
        maxBrightness: widget.maxBrightness,
        minBrightness: widget.minBrightness,
        // 随机初始进度，避免所有星星同时闪烁
        progress: _random.nextDouble(),
      );
    });
  }
  
  // 不再需要释放星星资源，因为我们不再使用动画控制器

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 星空层
        CustomPaint(
          painter: _SimpleStarrySkyPainter(
            stars: _stars,
            starColor: widget.starColor,
            random: _random,
          ),
          size: Size.infinite,
        ),
        // 子组件层
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

/// 简化的星星数据模型
class _SimpleStar {
  /// 星星位置 (0.0-1.0)
  Offset position;
  
  /// 星星大小
  final double size;
  
  /// 闪烁速度
  final double speed;
  
  /// 最大亮度
  final double maxBrightness;
  
  /// 最小亮度
  final double minBrightness;
  
  /// 动画进度 (0.0-1.0)
  double progress;

  _SimpleStar({
    required this.position,
    required this.size,
    required this.speed,
    required this.maxBrightness,
    required this.minBrightness,
    required this.progress,
  });
  
  /// 获取当前亮度
  double get brightness {
    // 使用正弦函数计算亮度
    return minBrightness + (maxBrightness - minBrightness) * math.sin(progress * math.pi);
  }
  
  /// 更新星星状态
  void update(math.Random random) {
    // 增加进度
    progress += speed;
    
    // 如果完成一个周期，重新定位
    if (progress >= 1.0) {
      progress = 0.0;
      position = Offset(random.nextDouble(), random.nextDouble());
    }
  }
}

/// 简化的星空绘制器
class _SimpleStarrySkyPainter extends CustomPainter {
  /// 星星列表
  final List<_SimpleStar> stars;
  
  /// 星星颜色
  final Color starColor;
  
  /// 随机数生成器
  final math.Random random;

  _SimpleStarrySkyPainter({
    required this.stars,
    required this.starColor,
    required this.random,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 更新并绘制每颗星星
    for (final star in stars) {
      // 更新星星状态
      star.update(random);
      
      // 计算实际坐标
      final x = star.position.dx * size.width;
      final y = star.position.dy * size.height;
      
      // 根据当前亮度设置颜色
      final paint = Paint()
        ..color = starColor.withOpacity(star.brightness)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      
      // 绘制圆形星星
      canvas.drawCircle(Offset(x, y), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // 始终重绘
  }
}