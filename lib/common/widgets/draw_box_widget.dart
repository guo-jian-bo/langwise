
import 'package:flutter/material.dart';

class DrawBoxWidget extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final double? aspectRatio;
  final Rect initRect;
  final Function(Rect rect)? onBoxChanged;
  /// DrawBoxWidget 组件说明：
  /// 
  /// 这是一个可以用鼠标或手指在界面上画矩形框的组件。主要功能和使用方法如下：
  /// 
  /// 1. 基本功能：
  ///    - 可以在界面上通过拖拽画出一个矩形框
  ///    - 画出的矩形框可以调整大小和位置
  ///    - 可以限制矩形框的宽高比例
  ///    - 可以实时获取矩形框的位置和大小信息
  /// 
  /// 2. 交互方式：
  ///    - 创建矩形框：在空白处按下并拖动即可画出矩形
  ///    - 调整大小：鼠标移到四个角的白色圆点上，按住拖动可以改变大小
  ///    - 移动位置：鼠标移到矩形框内部，按住拖动可以改变位置
  ///    - 鼠标样式：移到边角会显示调整大小的光标，移到内部会显示移动的光标
  /// 
  /// 3. 使用限制：
  ///    - 矩形框不能超出容器范围（由width和height参数决定）
  ///    - 如果设置了aspectRatio，矩形框会保持固定的宽高比
  ///    - 初始创建或大小小于1像素时不能移动位置
  /// 
  /// 4. 主要参数说明：
  ///    - child: 显示在背景的Widget，比如图片
  ///    - width/height: 限制矩形框活动的范围
  ///    - aspectRatio: 宽高比例，为null时可以自由调整，不为null时会保持固定比例
  ///    - onBoxChanged: 矩形框发生变化时的回调函数，参数为Rect类型，包含位置和大小信息
  /// 
  /// 使用示例：
  /// ```dart
  /// DrawBoxWidget(
  ///   child: Image.asset('background.png'),
  ///   width: 300,
  ///   height: 200,
  ///   aspectRatio: 16/9,  // 可选，设置固定宽高比
  ///   onBoxChanged: (rect) {
  ///     print('矩形框位置：${rect.left}, ${rect.top}');
  ///     print('矩形框大小：${rect.width} x ${rect.height}');
  ///   },
  /// )
  /// ```
  const DrawBoxWidget({
    super.key, 
    required this.child, 
    required this.width, 
    required this.height, 
    this.aspectRatio, 
    this.onBoxChanged, 
    this.initRect = Rect.zero,
  });

  @override
  State<DrawBoxWidget> createState() => _DrawBoxWidgetState();
}

class _DrawBoxWidgetState extends State<DrawBoxWidget> {
 bool _isDragging = false;
  bool _isResizing = false;
  Offset? _startPoint;
  Rect? _boxRect;
  int? _activeCorner = 3; // 0: 左上, 1: 右上, 2: 左下, 3: 右下
  bool isFist = true;

  bool cursorsMoveFlag = false;

  @override
  void initState() {
    super.initState();
    _boxRect = widget.initRect;
    if(widget.initRect != Rect.zero){
      isFist = false;
      cursorsMoveFlag = true;
    }
  }

  @override
  void didUpdateWidget(covariant DrawBoxWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.initRect != oldWidget.initRect){
      _boxRect = widget.initRect;
    }
  }
  
  void _handleDragStart(DragStartDetails details) {
    final touchPoint = details.localPosition;
    
    if (_boxRect != null) {
      // 检查是否点击了控制点
      final corners = _getCornerPoints();
      for (int i = 0; i < corners.length; i++) {
        if ((touchPoint - corners[i]).distance < 20) {
          setState(() {
            _isResizing = true;
            _isDragging = false;
            _activeCorner = i;
            _startPoint = touchPoint;
          });
          return;
        }
      }
      
      // 检查是否在框内，只有非初始状态且点击在框内时才允许移动
      if (_boxRect!.contains(touchPoint) && !isFist && _boxRect!.width > 1 && _boxRect!.height > 1) {
        setState(() {
          _isDragging = true;
          _isResizing = false;
          _startPoint = touchPoint;
        });
        return;
      }
    }
    
    // 开始新框选或重新画框，此时只允许放大缩小
    setState(() {
      _isDragging = false;
      _isResizing = true;
      _startPoint = details.localPosition;
      _boxRect = Rect.fromLTWH(
        details.localPosition.dx,
        details.localPosition.dy,
        1,
        1
      );
      isFist = false;
      
      // 通知位置变化
      if (widget.onBoxChanged != null) {
        widget.onBoxChanged!(_boxRect!);
      }
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_startPoint == null) return;
    
    setState(() {
      final currentPoint = details.localPosition;
      
      if (_isResizing && _boxRect != null && _activeCorner != null) {
        // 调整大小
        double newLeft = _boxRect!.left;
        double newTop = _boxRect!.top;
        double newWidth = _boxRect!.width;
        double newHeight = _boxRect!.height;
        
        switch (_activeCorner) {
          case 0: // 左上
            newLeft = currentPoint.dx;
            newTop = currentPoint.dy;
            newWidth = _boxRect!.right - newLeft;
            newHeight = widget.aspectRatio != null ? newWidth / widget.aspectRatio! : _boxRect!.bottom - newTop;
            break;
          case 1: // 右上
            newTop = currentPoint.dy;
            newWidth = currentPoint.dx - _boxRect!.left;
            newHeight = widget.aspectRatio != null ? newWidth / widget.aspectRatio! : _boxRect!.bottom - newTop;
            break;
          case 2: // 左下
            newLeft = currentPoint.dx;
            newWidth = _boxRect!.right - newLeft;
            newHeight = widget.aspectRatio != null ? newWidth / widget.aspectRatio! : currentPoint.dy - _boxRect!.top;
            break;
          case 3: // 右下
            newWidth = currentPoint.dx - _boxRect!.left;
            newHeight = widget.aspectRatio != null ? newWidth / widget.aspectRatio! : currentPoint.dy - _boxRect!.top;
            break;
        }
        
        // 确保矩形框不超出容器范围
        if (newWidth > 0 && newHeight > 0) {
          // 根据拖动的角点，限制宽高和位置
          switch (_activeCorner) {
            case 0: // 左上
              newLeft = newLeft.clamp(0, _boxRect!.right);
              newTop = newTop.clamp(0, _boxRect!.bottom);
              newWidth = _boxRect!.right - newLeft;
              newHeight = widget.aspectRatio != null ? newWidth / widget.aspectRatio! : _boxRect!.bottom - newTop;
              break;
            case 1: // 右上
              newWidth = (currentPoint.dx - _boxRect!.left).clamp(0, widget.width - _boxRect!.left);
              newTop = newTop.clamp(0, _boxRect!.bottom);
              newHeight = widget.aspectRatio != null ? newWidth / widget.aspectRatio! : _boxRect!.bottom - newTop;
              break;
            case 2: // 左下
              newLeft = newLeft.clamp(0, _boxRect!.right);
              newWidth = _boxRect!.right - newLeft;
              newHeight = (currentPoint.dy - _boxRect!.top).clamp(0, widget.height - _boxRect!.top);
              if (widget.aspectRatio != null) {
                newHeight = newWidth / widget.aspectRatio!;
              }
              break;
            case 3: // 右下
              newWidth = (currentPoint.dx - _boxRect!.left).clamp(0, widget.width - _boxRect!.left);
              newHeight = (currentPoint.dy - _boxRect!.top).clamp(0, widget.height - _boxRect!.top);
              if (widget.aspectRatio != null) {
                newHeight = newWidth / widget.aspectRatio!;
              }
              break;
          }
          
          _boxRect = Rect.fromLTWH(newLeft, newTop, newWidth, newHeight);
        }
      } else if (_isDragging) {
        if (_boxRect != null && _startPoint != null && _boxRect!.width > 1 && _boxRect!.height > 1) {
          // 只有当矩形框大于初始大小时才允许移动
          final offset = currentPoint - _startPoint!;
          // 分别处理水平和垂直方向的移动
          double newLeft = _boxRect!.left;
          double newTop = _boxRect!.top;
          
          // 水平方向移动
          if ((_boxRect!.left + offset.dx) >= 0 && (_boxRect!.right + offset.dx) <= widget.width) {
            newLeft += offset.dx;
          }
          
          // 垂直方向移动
          if ((_boxRect!.top + offset.dy) >= 0 && (_boxRect!.bottom + offset.dy) <= widget.height) {
            newTop += offset.dy;
          }
          
          _boxRect = Rect.fromLTWH(newLeft, newTop, _boxRect!.width, _boxRect!.height);
          _startPoint = currentPoint;
        } else {
          // 创建新框或调整大小
          double width = (currentPoint.dx - _startPoint!.dx).abs();
          double height = widget.aspectRatio != null ? width / widget.aspectRatio! : (currentPoint.dy - _startPoint!.dy).abs();
          
          double left = currentPoint.dx < _startPoint!.dx ? currentPoint.dx : _startPoint!.dx;
          double top = currentPoint.dy < _startPoint!.dy ? currentPoint.dy : _startPoint!.dy;
          
          if (widget.aspectRatio != null && currentPoint.dy < _startPoint!.dy) {
            top = _startPoint!.dy - height;
          }
          
          // 确保新创建的矩形框不超出容器范围
          left = left.clamp(0, widget.width - width);
          top = top.clamp(0, widget.height - height);
          width = width.clamp(0, widget.width - left);
          height = height.clamp(0, widget.height - top);
          _boxRect = Rect.fromLTWH(left, top, width, height);
        }
      }
      
      // 通知位置变化
      if (_boxRect != null && widget.onBoxChanged != null) {
        widget.onBoxChanged!(_boxRect!);
      }
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      cursorsMoveFlag = false;
      _isDragging = false;
      _isResizing = false;
      _startPoint = null;
      _activeCorner = 3;
    });
  }
  
  List<Offset> _getCornerPoints() {
    if (_boxRect == null) return [];
    return [
      _boxRect!.topLeft,
      _boxRect!.topRight,
      _boxRect!.bottomLeft,
      _boxRect!.bottomRight,
    ];
  }
  
  MouseCursor _getMouseCursor() {
    final mousePosition = _startPoint;
    if (mousePosition == null) return SystemMouseCursors.precise;
    
    final corners = _getCornerPoints();
    for (int i = 0; i < corners.length; i++) {
      if ((mousePosition - corners[i]).distance < 20) {
        return SystemMouseCursors.basic;
      }
    }
    
    return SystemMouseCursors.precise;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _getMouseCursor(),
      onHover: (event) {
        setState(() {
          _startPoint = event.localPosition;
        });
      },
      child: GestureDetector(
        onPanStart: _handleDragStart,
        onPanUpdate: _handleDragUpdate,
        onPanEnd: _handleDragEnd,
        onPanDown: (details) {
          cursorsMoveFlag = true;
          if(mounted) setState(() {});
        },
        onPanCancel: () {
          cursorsMoveFlag = false;
          if(mounted) setState(() {});
        },
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.child,
              if (_boxRect != null)
                Positioned(
                  left: _boxRect!.left,
                  top: _boxRect!.top,
                  width: _boxRect!.width,
                  height: _boxRect!.height,
                  child: MouseRegion(
                    cursor: !cursorsMoveFlag ? SystemMouseCursors.grab : SystemMouseCursors.grabbing,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ..._getCornerPoints().map((corner) {
                          return Positioned(
                            left: corner.dx - _boxRect!.left - 5,
                            top: corner.dy - _boxRect!.top - 5,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}