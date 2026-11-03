
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/flutter_chart.dart';

typedef RadarChartValue<T> = List<num> Function(T);
typedef RadarValueFormatter<T> = List<dynamic> Function(T);
typedef RadarLegendFormatter = List<dynamic> Function();

// 添加点击详情类
class PointTapDetails {
  final Offset position;    // 点击的实际位置
  final Offset pointCenter; // 点的中心位置
  final BuildContext? context; // 上下文
  
  PointTapDetails({
    required this.position,
    required this.pointCenter,
    this.context,
  });
}

enum RadarBorderStyle {
  polygon, //多边形
  circle, //圆形
}

///雷达图
/// @author JD
class CustomizeRadar<T> extends ChartBodyRender<T> {

  CustomizeRadar({
    required super.data,
    required this.values,
    required this.max,
    this.lineColor = Colors.black12,
    this.direction = RotateDirection.forward,
    this.valueFormatter,
    this.legendFormatter,
    this.colors = colors10,
    this.startAngle = -math.pi / 2,
    this.fillColors,
    this.count = 5,
    
    this.borderStyle = RadarBorderStyle.polygon,
    this.lineWidth = 1.0,
    this.dataLineWidth = 1.0,
    this.lineTextStyle = const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),
    this.legendTextStyle = const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),
    // 添加圆点相关参数
    this.showPoints = false,
    this.pointRadius = 4.0,
    this.pointBorderWidth = 1.0,
    this.pointBorderColor = Colors.white,
    this.onPointData,

  });

  ///开始的方向
  final RotateDirection direction;

  ///最大值
  final num max;

  ///点的位置
  final RadarChartValue<T> values;

  ///值文案格式化 不要使用过于耗时的方法
  final RadarValueFormatter<T>? valueFormatter;

  ///图例文案格式化 不要使用过于耗时的方法
  final RadarLegendFormatter? legendFormatter;

  ///基线的颜色
  final Color lineColor;

  ///值的线颜色
  final List<Color> colors;

  ///值的填充颜色
  final List<Color>? fillColors;

  ///图例样式
  final TextStyle legendTextStyle;

  /// 分割线的文字样式
  final TextStyle lineTextStyle;

  ///开始弧度，可以调整起始位置
  final double startAngle;

  ///分隔线的数量
  final int count;

  final RadarBorderStyle borderStyle;

  /// 分割线的宽度
  final double lineWidth;

  /// 数据线的宽度
  final double dataLineWidth;
  
  /// 是否显示连接点
  final bool showPoints;
  
  /// 连接点的半径
  final double pointRadius;
  
  /// 连接点边框宽度
  final double pointBorderWidth;
  
  /// 连接点边框颜色
  final Color pointBorderColor;

  /// 返回点的数据
  final void Function(List<List<_PointHitArea>> _pointHitAreas)? onPointData;
  


  late double _sweepAngle;
  late final Paint _linePaint = Paint()
    ..strokeWidth = lineWidth
    ..isAntiAlias = true
    ..color = lineColor
    ..style = PaintingStyle.stroke;
  late final Paint _dataLinePaint = Paint()
    ..strokeWidth = dataLineWidth
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke;
  Paint? _fillDataLinePaint;
  
  // 添加点的画笔
  late final Paint _pointPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;
    
  late final Paint _pointBorderPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = pointBorderWidth
    ..color = pointBorderColor;
  
  // 存储点击区域
  final List<List<_PointHitArea>> _pointHitAreas = [];

  @override
  void init(ChartsState state) {
    ChartCircularCoordinateState layout = state.layout as ChartCircularCoordinateState;

    super.init(state);
    _linePathList.clear();
    _borderLinePaths.clear();
    _textPainterList.clear();
    _dataLinePathList.clear();
    _pointHitAreas.clear();

    int itemLength = data.length;
    double percent = 1 / itemLength;
    // 计算出每个数据所占的弧度值
    _sweepAngle = percent * math.pi * 2 * (direction == RotateDirection.forward ? 1 : -1);

    if (fillColors != null) {
      _fillDataLinePaint = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill;
    }

    //图例
    List<dynamic>? legendList = legendFormatter?.call();
    Offset center = layout.center;
    double radius = layout.radius;
    //开始点
    double startAngle = this.startAngle;

    if (borderStyle == RadarBorderStyle.polygon) {
      _borderLinePaths = List.generate(count, (index) => Path());
    }
    double dividerRadius = layout.radius / count;

    for (int i = 0; i < itemLength; i++) {
      T itemData = data[i];
      //画边框
      final x = math.cos(startAngle) * radius + center.dx;
      final y = math.sin(startAngle) * radius + center.dy;
      _linePathList.add(Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(x, y));

      //画分隔线
      if (borderStyle == RadarBorderStyle.polygon) {
        for (int ii = 0; ii < count; ii++) {
          final r = dividerRadius * (ii + 1);
          final x1 = math.cos(startAngle) * r + center.dx;
          final y1 = math.sin(startAngle) * r + center.dy;
          if (i == 0) {
            _borderLinePaths[ii].moveTo(x1, y1);
            
            // 在右上角添加分数文字
            if (startAngle == this.startAngle) { // 只在第一个点时添加文字
              final scoreValue = (max / count * (ii + 1)).round();
              // 使用右上角位置（45度角）
              final scoreX = center.dx + r * math.cos(math.pi/4); // 右上角 X 坐标
              final scoreY = center.dy - r * math.sin(math.pi/4); // 右上角 Y 坐标
              
              TextPainter scoreTextPainter = TextPainter(
                textAlign: TextAlign.left,
                text: TextSpan(
                  text: scoreValue.toString(),
                  style: lineTextStyle,
                ),
                textDirection: TextDirection.ltr,
              )..layout(
                    minWidth: 0,
                    maxWidth: layout.size.width,
                  );
              
              // 将文本绘制器添加到列表中，稍后统一绘制
              _textPainterList.add(RadarTextPainter(
                textPainter: scoreTextPainter, 
                offset: Offset(
                  scoreX - scoreTextPainter.width, 
                  scoreY - scoreTextPainter.height / 2 - (scoreTextPainter.height / 2),
                )
              ));
            }
          } else {
            _borderLinePaths[ii].lineTo(x1, y1);
          }
        }
      }
      if (legendList != null) {
        String legend = legendList[i].toString();
        TextPainter legendTextPainter = TextPainter(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: legend,
            style: legendTextStyle,
          ),
          textDirection: TextDirection.ltr,
        )..layout(
            minWidth: 0,
            maxWidth: layout.size.width,
          );
        bool isLeft = x < center.dx;
        bool isBottom = y >= center.dy;
        Offset textOffset = Offset(isLeft ? (x - legendTextPainter.width) : x, isBottom ? y : y - legendTextPainter.height);
        //最后再绘制，防止被挡住
        _textPainterList.add(RadarTextPainter(textPainter: legendTextPainter, offset: textOffset));
      }

      //画value线
      List<num> pos = values.call(itemData);
      List<dynamic>? valueLegendList = valueFormatter?.call(itemData);
      assert(valueLegendList == null || pos.length == valueLegendList.length);
      
      // 为每个数据系列创建点击区域列表
      if (showPoints) {
        _pointHitAreas.add([]);
      }
      
      for (int j = 0; j < pos.length; j++) {
        Path? dataLinePath = _dataLinePathList[j];
        if (dataLinePath == null) {
          dataLinePath = Path();
          _dataLinePathList[j] = dataLinePath;
        }
        num subPos = pos[j];
        double vp = subPos / max;
        double newRadius = radius * vp;
        final dataX = math.cos(startAngle) * newRadius + center.dx;
        final dataY = math.sin(startAngle) * newRadius + center.dy;
        if (i == 0) {
          dataLinePath.moveTo(dataX, dataY);
        } else {
          dataLinePath.lineTo(dataX, dataY);
        }
        
        // 存储点击区域
        if (showPoints) {
          _pointHitAreas[j].add(_PointHitArea(
            center: Offset(dataX, dataY),
            radius: pointRadius,
            dataIndex: j,
            pointIndex: i,
          ));
        }

        //画文案
        if (valueLegendList != null) {
          String legend = valueLegendList[j].toString();
          TextPainter legendTextPainter = TextPainter(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: legend,
              style: legendTextStyle,
            ),
            textDirection: TextDirection.ltr,
          )..layout(
              minWidth: 0,
              maxWidth: layout.size.width,
            );
          bool isLeft = dataX < center.dx;
          bool isTop = dataY <= (center.dy - radius) && legendList != null;
          Offset textOffset = Offset(isLeft ? (dataX - legendTextPainter.width) : dataX, isTop ? dataY : dataY - legendTextPainter.height - pointRadius - pointBorderWidth);
          //最后再绘制，防止被挡住
          _textPainterList.add(RadarTextPainter(textPainter: legendTextPainter, offset: textOffset));
        }
      }
      //继续下一个
      startAngle = startAngle + _sweepAngle;
    }

    if (borderStyle == RadarBorderStyle.polygon) {
      for (var element in _borderLinePaths) {
        element.close();
      }
    }

    onPointData?.call(_pointHitAreas);
  }

  ///由内向外的线
  final List<Path> _linePathList = [];

  ///外边框
  List<Path> _borderLinePaths = [];

  ///图例 和 value
  final List<RadarTextPainter> _textPainterList = [];

  ///数据相关的path
  final Map<int, Path> _dataLinePathList = {};

  @override
  void draw(Canvas canvas, ChartsState state) {
    ChartCircularCoordinateState layout = state.layout as ChartCircularCoordinateState;
    double dividerRadius = layout.radius / count;
    if (borderStyle == RadarBorderStyle.circle) {
      for (int ii = 0; ii < count; ii++) {
        canvas.drawCircle(layout.center, dividerRadius * (ii + 1), _linePaint);
      }
    } else if (borderStyle == RadarBorderStyle.polygon) {
      //画边框
      for (var element in _borderLinePaths) {
        canvas.drawPath(element, _linePaint);
      }
    }

    for (var element in _linePathList) {
      canvas.drawPath(element, _linePaint);
    }

    //画数据
    int index = 0;
    for (Path dataPath in _dataLinePathList.values) {
      dataPath.close();
      // 设置绘制属性
      _dataLinePaint.color = colors[index];
      canvas.drawPath(dataPath, _dataLinePaint);

      if (fillColors != null) {
        _fillDataLinePaint?.color = fillColors![index];
        canvas.drawPath(dataPath, _fillDataLinePaint!);
      }
      
      // 绘制连接点
      if (showPoints && index < _pointHitAreas.length) {
        _pointPaint.color = colors[index];
        for (var point in _pointHitAreas[index]) {
          // 绘制填充
          canvas.drawCircle(point.center, pointRadius, _pointPaint);
          // 绘制边框
          canvas.drawCircle(point.center, pointRadius, _pointBorderPaint);
        }
      }
      
      index++;
    }
    //最后再绘制，防止被挡住
    for (RadarTextPainter textPainter in _textPainterList) {
      textPainter.textPainter.paint(canvas, textPainter.offset);
    }
  }
}

class RadarTextPainter {
  final TextPainter textPainter;
  final Offset offset;
  RadarTextPainter({required this.textPainter, required this.offset});
}

// 添加点击区域类
class _PointHitArea {
  final Offset center;
  final double radius;
  final int dataIndex;
  final int pointIndex;
  
  _PointHitArea({
    required this.center,
    required this.radius,
    required this.dataIndex,
    required this.pointIndex,
  });
}
