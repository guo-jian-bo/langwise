import 'package:flutter/material.dart';

enum JigsawPuzzleBoxType{
  /// 无
  none,
  /// 左凹
  leftConcaave,
  /// 左凸
  leftConvex,
  /// 右凹
  rightConcaave,
  /// 右凸
  rightConvex,
  /// 两边凹
  bothConcaave,
  /// 两边凸
  bothConvex,
  /// 左凸右凹
  leftConvexRightConcaave,
  /// 左凹右凸
  leftConcaaveRightConvex,
}

class JigsawPuzzleBoxPainter extends CustomPainter{
  /// 拼图类型
  final JigsawPuzzleBoxType type;
  /// 外层圆角
  final double radius;
  /// 背景色
  final Color color;
  /// 凹凸的宽度
  final double exWidth;
  /// 凹凸的高度
  final double exHeight;
  /// 凹凸的圆角
  final double exRadius;
  JigsawPuzzleBoxPainter({
    required this.type, 
    required this.radius, 
    required this.color, 
    required this.exWidth, 
    required this.exHeight,
    required this.exRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    // 获取尺寸
    final width = size.width;
    final height = size.height;
    
    // 根据不同类型绘制不同的路径
    switch (type) {
      case JigsawPuzzleBoxType.none:
        _drawNone(path, width, height);
        break;
      case JigsawPuzzleBoxType.leftConcaave:
        _drawLeftConcave(path, width, height);
        break;
      case JigsawPuzzleBoxType.leftConvex:
        _drawLeftConvex(path, width, height);
        break;
      case JigsawPuzzleBoxType.rightConcaave:
        _drawRightConcave(path, width, height);
        break;
      case JigsawPuzzleBoxType.rightConvex:
        _drawRightConvex(path, width, height);
        break;
      case JigsawPuzzleBoxType.bothConcaave:
        _drawBothConcave(path, width, height);
        break;
      case JigsawPuzzleBoxType.bothConvex:
        _drawBothConvex(path, width, height);
        break;
      case JigsawPuzzleBoxType.leftConvexRightConcaave:
        _drawLeftConvexRightConcave(path, width, height);
        break;
      case JigsawPuzzleBoxType.leftConcaaveRightConvex:
        _drawLeftConcaveRightConvex(path, width, height);
        break;
    }
    
    // 绘制路径
    canvas.drawPath(path, paint);
  }

  /// 绘制无
  void _drawNone(Path path, double width, double height){
    // 起始点（右上角）
    path.moveTo(width - radius, 0);
    
    // 右上角圆角
    path.quadraticBezierTo(width, 0, width, radius);
    
    // 右边直线
    path.lineTo(width, height - radius);
    
    // 右下角圆角
    path.quadraticBezierTo(width, height, width - radius, height);
    
    // 底边直线
    path.lineTo(radius, height);
    
    // 左下角圆角
    path.quadraticBezierTo(0, height, 0, height - radius);
    
    // 左边直线到左上角
    path.lineTo(0, radius);
    
    // 左上角圆角
    path.quadraticBezierTo(0, 0, radius, 0);
    
    // 顶边直线
    path.lineTo(width - radius, 0);
    
    // 闭合路径
    path.close();
  }
  
  /// 绘制左凹路径
  void _drawLeftConcave(Path path, double width, double height) {
    // 起始点（右上角）
    path.moveTo(width - radius, 0);
    
    // 右上角圆角
    path.quadraticBezierTo(width, 0, width, radius);
    
    // 右边直线
    path.lineTo(width, height - radius);
    
    // 右下角圆角
    path.quadraticBezierTo(width, height, width - radius, height);
    
    // 底边直线
    path.lineTo(radius, height);
    
    // 左下角圆角
    path.quadraticBezierTo(0, height, 0, height - radius);
    
    // 左边直线到凹槽位置
    path.lineTo(0, height / 2 + exHeight / 2);
    
    // 绘制凹槽（矩形）
    path.lineTo(exWidth, height / 2 + exHeight / 2);
    path.lineTo(exWidth, height / 2 - exHeight / 2);
    path.lineTo(0, height / 2 - exHeight / 2);
    
    // 左边直线到左上角
    path.lineTo(0, radius);
    
    // 左上角圆角
    path.quadraticBezierTo(0, 0, radius, 0);
    
    // 顶边直线
    path.lineTo(width - radius, 0);
    
    // 闭合路径
    path.close();
  }
  
  /// 绘制左凸路径
  void _drawLeftConvex(Path path, double width, double height) {
    // 起始点（右上角）
    path.moveTo(width - radius, 0);
    
    // 右上角圆角
    path.quadraticBezierTo(width, 0, width, radius);
    
    // 右边直线
    path.lineTo(width, height - radius);
    
    // 右下角圆角
    path.quadraticBezierTo(width, height, width - radius, height);
    
    // 底边直线
    path.lineTo(radius, height);
    
    // 左下角圆角
    path.quadraticBezierTo(0, height, 0, height - radius);
    
    // 左边直线到凸起位置
    path.lineTo(0, height / 2 + exHeight / 2);
    
    // 绘制凸起（矩形）
    path.lineTo(-exWidth, height / 2 + exHeight / 2);
    path.lineTo(-exWidth, height / 2 - exHeight / 2);
    path.lineTo(0, height / 2 - exHeight / 2);
    
    // 左边直线到左上角
    path.lineTo(0, radius);
    
    // 左上角圆角
    path.quadraticBezierTo(0, 0, radius, 0);
    
    // 顶边直线
    path.lineTo(width - radius, 0);
    
    // 闭合路径
    path.close();
  }
  
  /// 绘制右凹路径
  void _drawRightConcave(Path path, double width, double height) {
    // 起始点（左上角）
    path.moveTo(radius, 0);
    
    // 顶边直线
    path.lineTo(width - radius, 0);
    
    // 右上角圆角
    path.quadraticBezierTo(width, 0, width, radius);
    
    // 右边直线到凹槽位置
    path.lineTo(width, height / 2 - exHeight / 2);
    
    // 绘制凹槽（矩形）
    path.lineTo(width - exWidth, height / 2 - exHeight / 2);
    path.lineTo(width - exWidth, height / 2 + exHeight / 2);
    path.lineTo(width, height / 2 + exHeight / 2);
    
    // 右边直线到右下角
    path.lineTo(width, height - radius);
    
    // 右下角圆角
    path.quadraticBezierTo(width, height, width - radius, height);
    
    // 底边直线
    path.lineTo(radius, height);
    
    // 左下角圆角
    path.quadraticBezierTo(0, height, 0, height - radius);
    
    // 左边直线
    path.lineTo(0, radius);
    
    // 左上角圆角
    path.quadraticBezierTo(0, 0, radius, 0);
    
    // 闭合路径
    path.close();
  }
  
  /// 绘制右凸路径
  void _drawRightConvex(Path path, double width, double height) {
    // 起始点（左上角）
    path.moveTo(radius, 0);
    
    // 顶边直线
    path.lineTo(width - radius, 0);
    
    // 右上角圆角
    path.quadraticBezierTo(width, 0, width, radius);
    
    // 右边直线到凸起位置
    path.lineTo(width, height / 2 - exHeight / 2);
    
    // 绘制凸起（矩形）
    path.lineTo(width + exWidth, height / 2 - exHeight / 2);
    path.lineTo(width + exWidth, height / 2 + exHeight / 2);
    path.lineTo(width, height / 2 + exHeight / 2);
    
    // 右边直线到右下角
    path.lineTo(width, height - radius);
    
    // 右下角圆角
    path.quadraticBezierTo(width, height, width - radius, height);
    
    // 底边直线
    path.lineTo(radius, height);
    
    // 左下角圆角
    path.quadraticBezierTo(0, height, 0, height - radius);
    
    // 左边直线
    path.lineTo(0, radius);
    
    // 左上角圆角
    path.quadraticBezierTo(0, 0, radius, 0);
    
    // 闭合路径
    path.close();
  }
  
  /// 绘制两边凹路径
  void _drawBothConcave(Path path, double width, double height) {
    // 起始点（右上角）
    path.moveTo(width - radius, 0);
    
    // 右上角圆角
    path.quadraticBezierTo(width, 0, width, radius);
    
    // 右边直线到凹槽位置
    path.lineTo(width, height / 2 - exHeight / 2);
    
    // 绘制右边凹槽（矩形）
    path.lineTo(width - exWidth, height / 2 - exHeight / 2);
    path.lineTo(width - exWidth, height / 2 + exHeight / 2);
    path.lineTo(width, height / 2 + exHeight / 2);
    
    // 右边直线到右下角
    path.lineTo(width, height - radius);
    
    // 右下角圆角
    path.quadraticBezierTo(width, height, width - radius, height);
    
    // 底边直线
    path.lineTo(radius, height);
    
    // 左下角圆角
    path.quadraticBezierTo(0, height, 0, height - radius);
    
    // 左边直线到凹槽位置
    path.lineTo(0, height / 2 + exHeight / 2);
    
    // 绘制左边凹槽（矩形）
    path.lineTo(exWidth, height / 2 + exHeight / 2);
    path.lineTo(exWidth, height / 2 - exHeight / 2);
    path.lineTo(0, height / 2 - exHeight / 2);
    
    // 左边直线到左上角
    path.lineTo(0, radius);
    
    // 左上角圆角
    path.quadraticBezierTo(0, 0, radius, 0);
    
    // 顶边直线
    path.lineTo(width - radius, 0);
    
    // 闭合路径
    path.close();
  }
  
  /// 绘制两边凸路径
  void _drawBothConvex(Path path, double width, double height) {
    // 起始点（右上角）
    path.moveTo(width - radius, 0);
    
    // 右上角圆角
    path.quadraticBezierTo(width, 0, width, radius);
    
    // 右边直线到凸起位置
    path.lineTo(width, height / 2 - exHeight / 2);
    
    // 绘制右边凸起（矩形）
    path.lineTo(width + exWidth, height / 2 - exHeight / 2);
    path.lineTo(width + exWidth, height / 2 + exHeight / 2);
    path.lineTo(width, height / 2 + exHeight / 2);
    
    // 右边直线到右下角
    path.lineTo(width, height - radius);
    
    // 右下角圆角
    path.quadraticBezierTo(width, height, width - radius, height);
    
    // 底边直线
    path.lineTo(radius, height);
    
    // 左下角圆角
    path.quadraticBezierTo(0, height, 0, height - radius);
    
    // 左边直线到凸起位置
    path.lineTo(0, height / 2 + exHeight / 2);
    
    // 绘制左边凸起（矩形）
    path.lineTo(-exWidth, height / 2 + exHeight / 2);
    path.lineTo(-exWidth, height / 2 - exHeight / 2);
    path.lineTo(0, height / 2 - exHeight / 2);
    
    // 左边直线到左上角
    path.lineTo(0, radius);
    
    // 左上角圆角
    path.quadraticBezierTo(0, 0, radius, 0);
    
    // 顶边直线
    path.lineTo(width - radius, 0);
    
    // 闭合路径
    path.close();
  }

  /// 绘制左凸右凹路径
  void _drawLeftConvexRightConcave(Path path, double width, double height) {
    // 起始点（右上角）
    path.moveTo(width - radius, 0);
    
    // 右上角圆角
    path.quadraticBezierTo(width, 0, width, radius);
    
    // 右边直线到凹槽位置
    path.lineTo(width, height / 2 - exHeight / 2);
    
    // 绘制右边凹槽（矩形）
    path.lineTo(width - exWidth, height / 2 - exHeight / 2);
    path.lineTo(width - exWidth, height / 2 + exHeight / 2);
    path.lineTo(width, height / 2 + exHeight / 2);
    
    // 右边直线到右下角
    path.lineTo(width, height - radius);
    
    // 右下角圆角
    path.quadraticBezierTo(width, height, width - radius, height);
    
    // 底边直线
    path.lineTo(radius, height);
    
    // 左下角圆角
    path.quadraticBezierTo(0, height, 0, height - radius);
    
    // 左边直线到凸起位置
    path.lineTo(0, height / 2 + exHeight / 2);
    
    // 绘制左边凸起（矩形）
    path.lineTo(-exWidth, height / 2 + exHeight / 2);
    path.lineTo(-exWidth, height / 2 - exHeight / 2);
    path.lineTo(0, height / 2 - exHeight / 2);
    
    // 左边直线到左上角
    path.lineTo(0, radius);
    
    // 左上角圆角
    path.quadraticBezierTo(0, 0, radius, 0);
    
    // 顶边直线
    path.lineTo(width - radius, 0);
    
    // 闭合路径
    path.close();
  }
  
  /// 绘制左凹右凸路径
  void _drawLeftConcaveRightConvex(Path path, double width, double height) {
    // 起始点（右上角）
    path.moveTo(width - radius, 0);
    
    // 右上角圆角
    path.quadraticBezierTo(width, 0, width, radius);
    
    // 右边直线到凸起位置
    path.lineTo(width, height / 2 - exHeight / 2);
    
    // 绘制右边凸起（矩形）
    path.lineTo(width + exWidth, height / 2 - exHeight / 2);
    path.lineTo(width + exWidth, height / 2 + exHeight / 2);
    path.lineTo(width, height / 2 + exHeight / 2);
    
    // 右边直线到右下角
    path.lineTo(width, height - radius);
    
    // 右下角圆角
    path.quadraticBezierTo(width, height, width - radius, height);
    
    // 底边直线
    path.lineTo(radius, height);
    
    // 左下角圆角
    path.quadraticBezierTo(0, height, 0, height - radius);
    
    // 左边直线到凹槽位置
    path.lineTo(0, height / 2 + exHeight / 2);
    
    // 绘制左边凹槽（矩形）
    path.lineTo(exWidth, height / 2 + exHeight / 2);
    path.lineTo(exWidth, height / 2 - exHeight / 2);
    path.lineTo(0, height / 2 - exHeight / 2);
    
    // 左边直线到左上角
    path.lineTo(0, radius);
    
    // 左上角圆角
    path.quadraticBezierTo(0, 0, radius, 0);
    
    // 顶边直线
    path.lineTo(width - radius, 0);
    
    // 闭合路径
    path.close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}