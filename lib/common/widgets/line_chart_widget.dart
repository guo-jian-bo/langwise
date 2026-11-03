import 'dart:math';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:animated_path/animated_path.dart';
import 'package:bubble_box/bubble_box.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class LineChart{
  double x;
  double y;
  LineChart(this.x, this.y);
}

class LineChartWidget extends StatefulWidget {
  final double width;
  final double height;
  final EdgeInsets padding;
  final Size? nowSize;
  final Size? nextSize;
  final double dotSize;
  final double bubbleFontSize;
  final double strokeWidth;
  final Color? strokeColor;
  final Duration? duration;
  final Duration? delay;
  final List<LineChart> lineData;
  final String? nextText;
  final ShapeBorder? shape;
  const LineChartWidget({
    super.key, 
    required this.width, 
    required this.height,
    this.padding = EdgeInsets.zero,
    this.nowSize,
    this.nextSize,
    this.dotSize = 24,
    this.bubbleFontSize = 20,
    this.strokeWidth = 8,
    this.duration,
    this.delay,
    this.nextText,
    this.shape,
    required this.lineData,
    this.strokeColor = AppTheme.cWhiteAlpha20,
  });

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> with SingleTickerProviderStateMixin, WidgetsBindingObserver{
  final List<LineChart> lineData = [
    LineChart(0, 0),//最小
    LineChart(2, 1),
    LineChart(3, 4),
    LineChart(5, 4),
    LineChart(6, 7),
    LineChart(7, 8),
    LineChart(9, 8),
    LineChart(10, 10),//最大
  ];

  late final AnimationController animationController = AnimationController(
    vsync: this,
    duration: widget.duration??const Duration(milliseconds: 500),
  );

  Size mainSize = Size.zero;
  Size nowSize = const Size(64, 68);
  
  List<LineChart> lineScaleData = [];
  double cubicSmoothingFactor = 0.15;
  Path linePath = Path();

  Paint paint = Paint()
      ..color = AppTheme.cBgBrand
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
  

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    paint.strokeWidth = widget.strokeWidth;
    paint.shader = const LinearGradient(
      colors: [
        AppTheme.cBgBrand,
        AppTheme.cBgBrand,
        // Color(0xff60F7FF),
      ],
    ).createShader(Rect.fromLTWH(0, 0, widget.width, widget.height));
    if(widget.nowSize != null){
      nowSize = widget.nowSize!;
    }
    mainSize = Size(
      widget.width - widget.padding.horizontal, 
      widget.height - widget.padding.vertical, 
    );
    scaledData();
    if(widget.delay == null){
      animationController.forward();
    }else{
      Future.delayed(widget.delay!, (){
        if(mounted) animationController.forward();
      });
    }
    
    
  }

  @override
  void didChangeMetrics() {
    paint.strokeWidth = widget.strokeWidth;
    if(widget.nowSize != null){
      nowSize = widget.nowSize!;
    }
    mainSize = Size(
      widget.width - widget.padding.horizontal, 
      widget.height - widget.padding.vertical, 
    );
    scaledData();
    if(mounted) setState(() {});
    // if(widget.delay == null){
    //   animationController.forward();
    // }else{
    //   Future.delayed(widget.delay!, (){
    //     if(mounted) animationController.forward();
    //   });
    // }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    animationController.dispose();
    super.dispose();
  }

  void scaledData(){
    lineScaleData.clear();
    // 计算最大值
    double maxX = lineData.map((e) => e.x).reduce((a, b) => a > b ? a : b);
    double maxY = lineData.map((e) => e.y).reduce((a, b) => a > b ? a : b);

    // 根据目标宽度和高度缩放 X 和 Y
    List<LineChart> scaledData = lineData.map((e) {
      double scaledX = (e.x / maxX) * mainSize.width;  // 缩放 X 值
      double scaledY = (e.y / maxY) * mainSize.height; // 缩放 Y 值
      return LineChart(scaledX, scaledY);
    }).toList();

    // 打印缩放后的数据
    for (var e in scaledData) {
      lineScaleData.add(e);
    }
    linePath = getPath();
  }

  Path getPath(){
    // 定义曲线的路径
    Path path = Path();
    // 确保有足够的点来计算曲线
    if (lineScaleData.length < 2) {
      return path;
    }
    // 数据点的规范化处理
    List<Offset> normalized = lineScaleData.map((e) => Offset(e.x, mainSize.height - e.y)).toList();
    // 计算要显示的点数（通过动画进度来控制）
    path.moveTo(normalized[0].dx, normalized[0].dy);
    Offset a = normalized[0];
    Offset b = normalized[0];
    Offset c = normalized[1];
    for (int i = 1; i < normalized.length; i++) {
      double x1 = (c.dx - a.dx) * cubicSmoothingFactor + b.dx;
      double y1 = (c.dy - a.dy) * cubicSmoothingFactor + b.dy;
      a = b;
      b = c;
      c = normalized[min(normalized.length - 1, i + 1)];
      double x2 = (a.dx - c.dx) * cubicSmoothingFactor + b.dx;
      double y2 = (a.dy - c.dy) * cubicSmoothingFactor + b.dy;
      path.cubicTo(x1, y1, x2, y2, b.dx, b.dy);
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    Size nextSize = widget.nextSize??const Size(112, 68);

    Widget buildCircle(){
      return Container(
        width: widget.dotSize,
        height: widget.dotSize,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppTheme.cBgBrand,
          shape: BoxShape.circle,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: widget.padding.bottom),
              alignment: Alignment.bottomCenter,
              child: CustomPaint(
                size: Size(widget.width, widget.height - widget.padding.bottom),
                painter: LineChartWidgetBackPainter(
                  spring: mainSize.height / lineScaleData.length * 2,
                  strokeColor: widget.strokeColor,
                ),
              ),
            ),
            Container(
              padding: widget.padding,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedPath(
                    size: mainSize,
                    paint: paint,
                    path: linePath,
                    animation: animationController.view,
                    end: Tween(begin: 0.0, end: 1.0),
                  ),
                  Positioned(
                    top: lineScaleData.last.y - widget.dotSize / 2,
                    right: lineScaleData.last.x - widget.dotSize / 2,
                    child: buildCircle(),
                  ),
                  Positioned(
                    top: lineScaleData.first.y - widget.dotSize / 2,
                    right: lineScaleData.first.x - widget.dotSize / 2,
                    child: buildCircle(),
                  ),
                  Positioned(
                    left: -(nowSize.width / 2) - widget.dotSize / 5,
                    bottom: widget.dotSize / 2,
                    child: BubbleBox(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppTheme.cBgBrand,
                      margin: EdgeInsets.zero,
                      shape: widget.shape??BubbleShapeBorder(
                        direction: BubbleDirection.bottom,
                        arrowQuadraticBezierLength: 4.wMin,
                        radius: BorderRadius.circular(10.wMin),
                        arrowHeight: 15.wMin,
                        arrowAngle: 14.wMin,
                        smooth: 0,
                      ),
                      child: Container(
                        height: nowSize.height,
                        width: nowSize.width,
                        alignment: Alignment.center,
                        child: Text(
                          "现在",
                          style: TextStyle(
                            fontSize: widget.bubbleFontSize,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cStaticWhite,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: lineScaleData.first.x - nextSize.width / 2,
                    top: lineScaleData.first.y - nextSize.height - widget.dotSize - 5,
                    child: BubbleBox(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppTheme.cBgBrand,
                      margin: EdgeInsets.zero,
                      shape: widget.shape??BubbleShapeBorder(
                        direction: BubbleDirection.bottom,
                        arrowQuadraticBezierLength: 4.wMin,
                        radius: BorderRadius.circular(10.wMin),
                        arrowHeight: 15.wMin,
                        arrowAngle: 14.wMin,
                        smooth: 0,
                      ),
                      child: Container(
                        height: nextSize.height,
                        width: nextSize.width,
                        alignment: Alignment.center,
                        child: Text(
                          widget.nextText??"下一级别",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: widget.bubbleFontSize,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cStaticWhite,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
    );
  }
}

class LineChartWidgetBackPainter extends CustomPainter {
  final double spring;
  final Color? strokeColor;
  LineChartWidgetBackPainter({this.spring = 50, this.strokeColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor??Colors.white.withValues(alpha: 0.21)
      ..strokeWidth = 0.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (double y = size.height; y >= 0; y -= spring) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}