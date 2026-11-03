import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 可拖拽网格视图
/// 
/// 支持子视图全屏幕拖拽，手指放开后回到原位置
/// 手指滑动一定距离后可删除子视图，并伴随动画效果

/// 自定义拖拽处理器
class _CustomDrag extends Drag {
  /// 更新回调
  final Function(Offset position) onUpdate;
  
  /// 结束回调
  final Function(Velocity velocity) onEnd;
  
  /// 取消回调
  final VoidCallback onCancel;
  
  _CustomDrag({
    required this.onUpdate,
    required this.onEnd,
    required this.onCancel,
  });
  
  @override
  void update(DragUpdateDetails details) {
    onUpdate(details.globalPosition);
  }
  
  @override
  void end(DragEndDetails details) {
    onEnd(details.velocity);
  }
  
  @override
  void cancel() {
    onCancel();
  }
}
class DraggableGridView extends StatefulWidget {
  /// 子视图列表
  final List<Widget> children;
  
  /// 横向子视图数量
  final int crossAxisCount;
  
  /// 子视图宽度
  final double itemWidth;
  
  /// 子视图高度
  final double itemHeight;
  
  /// 水平间距
  final double horizontalSpacing;
  
  /// 垂直间距
  final double verticalSpacing;
  
  /// 删除阈值（手指滑动距离超过此值时触发删除）
  final double deleteThreshold;
  
  /// 删除回调
  final Function(int index)? onDelete;
  
  /// 拖拽过程中实时位置回调
  final Function(int index, Offset position)? onDragUpdate;

  const DraggableGridView({
    Key? key,
    required this.children,
    this.crossAxisCount = 4,
    required this.itemWidth,
    required this.itemHeight,
    this.horizontalSpacing = 10.0,
    this.verticalSpacing = 10.0,
    this.deleteThreshold = 100.0,
    this.onDelete,
    this.onDragUpdate,
  }) : super(key: key);

  @override
  State<DraggableGridView> createState() => _DraggableGridViewState();
}

class _DraggableGridViewState extends State<DraggableGridView> with SingleTickerProviderStateMixin {
  /// 当前拖拽的子视图索引
  int? _dragIndex;
  
  /// 拖拽偏移量
  Offset _dragOffset = Offset.zero;
  
  /// 拖拽开始位置
  Offset _dragStartPosition = Offset.zero;
  
  /// 拖拽当前全局位置
  Offset _currentGlobalPosition = Offset.zero;
  
  /// 动画控制器
  late AnimationController _animationController;
  
  /// 动画
  late Animation<Offset> _animation;
  
  /// 是否正在执行删除动画
  bool _isDeleting = false;
  
  /// 多拖拽手势识别器
  late MultiDragGestureRecognizer _recognizer;
  
  /// 当前活动的拖拽
  Drag? _currentDrag;

  @override
  void initState() {
    super.initState();
    
    // 初始化动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // 初始化动画
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // 添加动画状态监听
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_isDeleting) {
          // 删除动画完成后，更新状态
          setState(() {
            _isDeleting = false;
            _dragIndex = null;
            _dragOffset = Offset.zero;
          });
        }
      }
    });
    
    // 初始化多拖拽手势识别器
    _recognizer = ImmediateMultiDragGestureRecognizer(debugOwner: this)
      ..onStart = _onDragStart;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: _calculateTotalWidth(widget.children.length),
            child: Stack(
              children: [
                // 网格布局
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.crossAxisCount,
                    childAspectRatio: widget.itemWidth / widget.itemHeight,
                    crossAxisSpacing: widget.horizontalSpacing,
                    mainAxisSpacing: widget.verticalSpacing,
                  ),
                  itemCount: widget.children.length,
                  itemBuilder: (context, index) {
                    // 如果当前索引正在拖拽，则显示占位视图
                    if (_dragIndex == index) {
                      return const SizedBox();
                    }
                    
                    // 构建可拖拽子视图
                    return _buildDraggableItem(index);
                  },
                ),
                
                // 拖拽中的视图
                if (_dragIndex != null)
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      // 计算当前位置
                      final Offset position = _isDeleting 
                          ? _animation.value 
                          : _getItemPosition(_dragIndex!) + _dragOffset;
                      
                      return Positioned(
                        left: position.dx,
                        top: position.dy,
                        width: widget.itemWidth,
                        height: widget.itemHeight,
                        child: child!,
                      );
                    },
                    child: Opacity(
                      opacity: 0.8,
                      child: widget.children[_dragIndex!],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建可拖拽子视图
  Widget _buildDraggableItem(int index) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        MultiDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<MultiDragGestureRecognizer>(
          () => _recognizer,
          (MultiDragGestureRecognizer instance) {},
        ),
      },
      child: Listener(
        onPointerDown: (PointerDownEvent event) {
          // 保存当前索引，供拖拽开始时使用
          _dragIndex = index;
        },
        child: widget.children[index],
      ),
    );
  }
  
  /// 当拖拽开始时调用
  Drag? _onDragStart(Offset position) {
    if (_dragIndex == null) return null;
    
    if (kDebugMode) {
      print('🔍[$runtimeType]【_onDragStart】开始拖拽索引: $_dragIndex');
    }
    
    setState(() {
      _dragStartPosition = position;
      _currentGlobalPosition = position;
      _dragOffset = Offset.zero;
    });
    
    // 创建一个拖拽实例
    _currentDrag = _CustomDrag(
      onUpdate: _handleDragUpdate,
      onEnd: _handleDragEnd,
      onCancel: _handleDragCancel,
    );
    
    return _currentDrag;
  }

  /// 处理拖拽更新
  void _handleDragUpdate(Offset position) {
    if (_dragIndex == null) return;
    
    setState(() {
      _dragOffset = position - _dragStartPosition;
      _currentGlobalPosition = position;
    });
    
    // 回调当前拖拽位置
    widget.onDragUpdate?.call(_dragIndex!, _currentGlobalPosition);
  }

  /// 处理拖拽结束
  void _handleDragEnd(Velocity velocity) {
    if (_dragIndex == null) return;
    
    if (kDebugMode) {
      print('🔄[$runtimeType]【_handleDragEnd】结束拖拽索引: $_dragIndex, 偏移: $_dragOffset');
    }
    
    // 如果拖拽距离超过阈值，触发删除
    if (_dragOffset.dx.abs() > widget.deleteThreshold || _dragOffset.dy.abs() > widget.deleteThreshold) {
      _deleteItem(_dragIndex!);
    } else {
      // 否则回到原位置
      _resetDragPosition();
    }
  }
  
  /// 处理拖拽取消
  void _handleDragCancel() {
    if (_dragIndex == null) return;
    
    if (kDebugMode) {
      print('🚫[$runtimeType]【_handleDragCancel】取消拖拽索引: $_dragIndex');
    }
    
    // 回到原位置
    _resetDragPosition();
  }

  /// 重置拖拽位置
  void _resetDragPosition() {
    if (_dragIndex == null) return;
    
    // 设置动画
    _animation = Tween<Offset>(
      begin: _getItemPosition(_dragIndex!) + _dragOffset,
      end: _getItemPosition(_dragIndex!),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // 重置动画控制器并开始动画
    _animationController.reset();
    _animationController.forward().then((_) {
      setState(() {
        _dragIndex = null;
        _dragOffset = Offset.zero;
      });
    });
  }

  /// 删除子视图
  void _deleteItem(int index) {
    if (kDebugMode) {
      print('🗑️[$runtimeType]【_deleteItem】删除索引: $index');
    }
    
    // 设置删除动画
    final Offset currentPosition = _getItemPosition(index) + _dragOffset;
    final Offset targetPosition = Offset(
      currentPosition.dx + widget.itemWidth * (_dragOffset.dx > 0 ? 1 : -1) * 2,
      currentPosition.dy,
    );
    
    _animation = Tween<Offset>(
      begin: currentPosition,
      end: targetPosition,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInCubic,
    ));
    
    // 标记正在删除
    _isDeleting = true;
    
    // 重置动画控制器并开始动画
    _animationController.reset();
    _animationController.forward().then((_) {
      // 调用删除回调
      widget.onDelete?.call(index);
    });
  }

  /// 获取子视图位置
  Offset _getItemPosition(int index) {
    // 计算行列索引
    final int row = index ~/ widget.crossAxisCount;
    final int col = index % widget.crossAxisCount;
    
    // 计算位置
    final double x = col * (widget.itemWidth + widget.horizontalSpacing);
    final double y = row * (widget.itemHeight + widget.verticalSpacing);
    
    return Offset(x, y);
  }

  /// 计算总宽度
  double _calculateTotalWidth(int itemCount) {
    // 计算列数
    final int columns = (itemCount / widget.crossAxisCount).ceil();
    
    // 计算总宽度
    return columns * (widget.itemWidth + widget.horizontalSpacing) - widget.horizontalSpacing;
  }
}
