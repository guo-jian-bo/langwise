import 'package:flutter/material.dart';

/// 每个字母
class DecodingGradingLetterModel{
  /// 字母
  String letter;
  GlobalKey key;
  
  DecodingGradingLetterModel({
    required this.letter,
    required this.key,
  });
}



class DecodingGradingPainter extends CustomPainter{
  final List<DecodingGradingLetterModel> models;
  final List<List<int?>> positions;
  final Color color;
  final double strokeWidth;
  /// 距离字母的下方高度
  final double letterBottomHeight;
  /// 弧线弯曲
  final double curveRadius;
  /// 内边距
  final EdgeInsets padding;
  
  /// 自然拼读解码分级
  DecodingGradingPainter({
    required this.models, 
    required this.positions,
    this.color = Colors.orange,
    this.strokeWidth = 2,
    this.curveRadius = 20,
    this.letterBottomHeight = 0,
    this.padding = EdgeInsets.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    /// 这里画字母下面的 点/下划线/下弧线
    /// 这里的点/下划线/下弧线 是根据 positions 来画的
    /// positions 是一个数组，数组的每个元素是一个整数，整数表示字母的位置
    /// 例如：positions = [[0, 1, 2, 3], [4, 5]]
    /// 如果是 positions[i] = [0, 1] 说明是下划线 从第0个字母的下方的中心画到第1个字母下方的的中心
    /// 如果是 positions[i] = [0, 2] 说明是下弧线 从第0个字母的下方的中心画到第2个字母下方的的中心
    /// 如果是 positions[i] = [1] 说明是点 在这个字母下方画一个圆点
    
    // 如果positions为空，则不需要绘制
    if (positions.isEmpty) return;
    
    // 获取字母位置信息
    List<Offset> letterCenters = [];
    
    // 获取CustomPainter所在的RenderBox，用于坐标转换
    RenderBox? painterBox;
    if (models.isNotEmpty && models[0].key.currentContext != null) {
      // 假设所有字母都在同一个坐标系中，取第一个字母的context的祖先作为参考
      painterBox = models[0].key.currentContext!.findRenderObject()?.parent as RenderBox?;
    }
    
    for (var model in models) {
      final RenderBox? renderBox = model.key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;
        
        // 计算字母底部中心点（全局坐标）
        final globalCenterBottom = Offset(
          position.dx + size.width / 2 + padding.left,
          position.dy + size.height + letterBottomHeight, // 字母下方5像素处
        );
        
        // 将全局坐标转换为CustomPainter的本地坐标
        Offset centerBottom;
        if (painterBox != null) {
          centerBottom = painterBox.globalToLocal(globalCenterBottom);
        } else {
          // 如果无法获取painterBox，则使用全局坐标（可能不准确）
          centerBottom = globalCenterBottom;
        }
        
        letterCenters.add(centerBottom);
      } 
    }
    
    // 遍历每组positions，分别绘制
    for (var posGroup in positions) {
      if (posGroup.isEmpty) continue;
      
      if (posGroup.length == 1) {
        // 绘制点
        int index = posGroup[0] ?? 0;
        if (index < letterCenters.length) {
          canvas.drawCircle(letterCenters[index], strokeWidth, paint..style = PaintingStyle.fill);
        }
      } else if (posGroup.length == 2) {
        int startIndex = posGroup[0] ?? 0;
        int endIndex = posGroup[1] ?? 0;
        
        if (startIndex < letterCenters.length && endIndex < letterCenters.length) {
          Offset start = letterCenters[startIndex];
          Offset end = letterCenters[endIndex];
          
          if (endIndex - startIndex == 1) {
            // 相邻字母，绘制下划线
            canvas.drawLine(start, end, paint);
          } else {
            // 非相邻字母，绘制下弧线
            final controlPoint = Offset(
              (start.dx + end.dx) / 2,
              start.dy + curveRadius, // 控制点下移x像素形成弧度
            );
            
            final path = Path();
            path.moveTo(start.dx, start.dy);
            path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);
            canvas.drawPath(path, paint..style = PaintingStyle.stroke);
          }
        }
      } else {
        // 处理多个点的情况，可以绘制连续的线段
        for (int i = 0; i < posGroup.length - 1; i++) {
          int startIndex = posGroup[i] ?? 0;
          int endIndex = posGroup[i + 1] ?? 0;
          
          if (startIndex < letterCenters.length && endIndex < letterCenters.length) {
            Offset start = letterCenters[startIndex];
            Offset end = letterCenters[endIndex];
            
            if (endIndex - startIndex == 1) {
              // 相邻字母，绘制直线
              canvas.drawLine(start, end, paint..style = PaintingStyle.stroke);
            } else {
              // 非相邻字母，绘制弧线
              final controlPoint = Offset(
                (start.dx + end.dx) / 2,
                start.dy + curveRadius, // 控制点下移s像素形成弧度
              );
              
              final path = Path();
              path.moveTo(start.dx, start.dy);
              path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);
              canvas.drawPath(path, paint..style = PaintingStyle.stroke);
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}