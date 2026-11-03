import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:quiz_play/component/tap_scale_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'camera_dotted_line_Painter.dart';

class PhotoEditPage extends StatefulWidget {
  final String? filePath;
  final Function(ui.Image, ui.Image)? onContinueTap;
  final VoidCallback? onCancelTap;

  const PhotoEditPage(
      {super.key, this.filePath, this.onContinueTap, this.onCancelTap});

  @override
  State<PhotoEditPage> createState() => _PhotoEditPageState();
}

class _PhotoEditPageState extends State<PhotoEditPage> with SafeSetStateMixin {
  String? _filePath;

  bool get hasFilePath => _filePath != null && _filePath!.isNotEmpty;

  // 矩形裁剪区域
  Rect _cropRect = Rect.zero;

  Offset _startDragPoint = Offset.zero;
  final double _splitLinePosition = 0.5;
  final GlobalKey _imageKey = GlobalKey();

  ui.Image? _image;

  _CornerType _draggedCorner = _CornerType.none;

  double imageScale = 0;
  Offset imageOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _filePath = widget.filePath;
    loadImageFromFile();
  }

  Future<ui.Image?> loadImageFromFile() async {
    if (hasFilePath) {
      try {
        // 1. 读取文件字节数据
        final Uint8List bytes = File(_filePath!).readAsBytesSync();

        // 2. 解码图片
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);

        // 3. 获取图片帧
        final ui.FrameInfo frameInfo = await codec.getNextFrame();

        safeSetState(() {
          _image = frameInfo.image;
        });
        if (_image != null) {
          _initializeCropRect();
        }
        print('⚠️ 图片加载成功, width: ${_image?.width}, height: ${_image?.height},');

        return frameInfo.image;
      } catch (e) {
        print('⚠️ 图片加载失败: $e');
        return null;
      }
    }
    return null;
  }

  // 图片加载完成后初始化裁剪区域
  void _initializeCropRect() {
    final imageWidth = _image!.width.toDouble();
    final imageHeight = _image!.height.toDouble();

    // 默认占图片80%区域，居中显示
    const scaleFactor = 0.75;
    final defaultWidth = imageWidth * scaleFactor;
    final defaultHeight = imageHeight * scaleFactor;

    safeSetState(() {
      // 初始化裁剪区域（基于原始图片坐标系）
      _cropRect = Rect.fromCenter(
        center: Offset(imageWidth / 2, imageHeight / 2),
        width: defaultWidth,
        height: defaultHeight,
      );
    });
  }

  // 坐标转换方法（关键修复）
  Offset _convertToImageCoordinates(Offset localPosition) {
    // 将控件坐标转换为绘制区域内的相对坐标
    final imagePos = Offset(
      (localPosition.dx - imageOffset.dx) / imageScale,
      (localPosition.dy - imageOffset.dy) / imageScale,
    );

    // 添加边界约束
    return Offset(
      imagePos.dx.clamp(0, _image!.width.toDouble()),
      imagePos.dy.clamp(0, _image!.height.toDouble()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            color: Colors.black,
            alignment: Alignment.center,
            child: _image != null
                ? _buildInteractiveImage()
                : const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildInteractiveImage() {
    return Stack(
      children: [
        _buildImageCanvas(),
        _buildCropControls(),
        ..._buildTakeWidget()
      ],
    );
  }

  Widget _buildImageCanvas() {
    return LayoutBuilder(builder: (context, constraints) {
      imageScale = _calculateImageScale();
      imageOffset = Offset(
        (constraints.maxWidth - _image!.width * imageScale) / 2,
        (constraints.maxHeight - _image!.height * imageScale) / 2,
      );
      return AspectRatio(
        key: _imageKey,
        aspectRatio: _image!.width / _image!.height,
        child: CustomPaint(
          painter: ImagePainter(
            _image!,
            _cropRect,
            _splitLinePosition,
            _calculateImageScale(),
            imageOffset,
          ),
        ),
      );
    });
  }

  Widget _buildCropControls() {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      behavior: HitTestBehavior.translucent,
    );
  }

  List<Widget> _buildTakeWidget() {
    return [
      Positioned(
          bottom: 70.wh,
          right: 150.ww,
          child: TapScaleWidget(
            onTap: OptimizeUtils.noneThrottle(() {
              Navigator.pop(context);
              widget.onCancelTap?.call();
            }, 300),
            child: Container(
              width: 80.ww,
              height: 40.wh,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xff040712).withValues(alpha: 0.8),
                border: Border.all(
                  color: const Color(0xff666F8D),
                  width: 0.5.wMin,
                ),
                borderRadius: BorderRadius.circular(6.wMin),
              ),
              child: Text(
                "取消",
                style: TextStyle(
                  color: Colours.blue_E5F5FF,
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
              ),
            ),
          )),
      Positioned(
          bottom: 70.wh,
          right: 60.ww,
          child: TapScaleWidget(
            onTap: OptimizeUtils.noneThrottle(() {
              _processImage();
            }, 300),
            child: Container(
              width: 80.ww,
              height: 40.wh,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xff2388FF),
                borderRadius: BorderRadius.circular(6.wMin),
              ),
              child: Text(
                "下一步",
                style: TextStyle(
                  color: Colours.blue_E5F5FF,
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
              ),
            ),
          )),
    ];
  }

  // 2. 碰撞检测方法
  _CornerType _detectCornerType(Offset localPosition) {
    final imagePos = _convertToImageCoordinates(localPosition);
    print('---检测坐标转换 | 控件坐标: $localPosition → 图片坐标: $imagePos');
    print('---检测坐标转换 | _cropRect: $_cropRect');
    // 动态计算有效点击范围
    final effectiveRadius = 30.0 / imageScale; // 根据缩放比例调整
    final corners = {
      _CornerType.topLeft: _cropRect.topLeft,
      _CornerType.topRight: _cropRect.topRight,
      _CornerType.bottomLeft: _cropRect.bottomLeft,
      _CornerType.bottomRight: _cropRect.bottomRight,
    };

    for (final entry in corners.entries) {
      if ((imagePos - entry.value).distance < effectiveRadius) {
        print('✅ 命中顶点: ${entry.key}');
        return entry.key;
      }
    }
    print('❌ 未命中任何顶点');
    return _CornerType.none;
  }

  // 添加坐标转换方法
  double _calculateImageScale() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    print(
        '--_image!.width:${_image!.width}, _image!.height:${_image!.height}, screenWidth:$screenWidth, screenHeight: $screenHeight---');
    return min(
      screenWidth / _image!.width,
      screenHeight / _image!.height,
    );
  }

  // 3. 拖动起始记录
  void _onPanStart(DragStartDetails details) {
    final renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    safeSetState(() {
      _draggedCorner = _detectCornerType(localPosition);
      print(
          '---_onPanStart, localPosition:$localPosition, _draggedCorner:$_draggedCorner,_cropRect:$_cropRect---');
      _startDragPoint = localPosition;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_draggedCorner == _CornerType.none) return;
    final renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    safeSetState(() {
      _cropRect = _calculateNewRect(localPosition);
      print(
          '---当前有效区域_onPanUpdate, localPosition:$localPosition, _draggedCorner:$_draggedCorner,_cropRect:$_cropRect---');
    });
  }

  // 4. 矩形计算逻辑
  Rect _calculateNewRect(Offset currentPosition) {
    // 根据拖动方向计算新矩形
    final imagePos = _convertToImageCoordinates(currentPosition);
    final startImagePos = _convertToImageCoordinates(_startDragPoint);
    final delta = imagePos - startImagePos;

    final maxWidth = _image!.width.toDouble();
    final maxHeight = _image!.height.toDouble();
    const minSize = 100.0; // 最小尺寸限制

    Rect newRect = _cropRect;
    switch (_draggedCorner) {
      case _CornerType.topLeft:
        newRect = Rect.fromLTRB(
          (_cropRect.left + delta.dx).clamp(0, _cropRect.right - minSize),
          (_cropRect.top + delta.dy).clamp(0, _cropRect.bottom - minSize),
          _cropRect.right,
          _cropRect.bottom,
        );
        break;
      case _CornerType.topRight:
        newRect = Rect.fromLTRB(
          _cropRect.left,
          (_cropRect.top + delta.dy).clamp(0, _cropRect.bottom - minSize),
          (_cropRect.right + delta.dx)
              .clamp(_cropRect.left + minSize, maxWidth),
          _cropRect.bottom,
        );
        break;
      case _CornerType.bottomLeft:
        newRect = Rect.fromLTRB(
          (_cropRect.left + delta.dx).clamp(0, _cropRect.right - minSize),
          _cropRect.top,
          _cropRect.right,
          (_cropRect.bottom + delta.dy)
              .clamp(_cropRect.top + minSize, maxHeight),
        );
        break;
      case _CornerType.bottomRight:
        newRect = Rect.fromLTRB(
          _cropRect.left,
          _cropRect.top,
          (_cropRect.right + delta.dx)
              .clamp(_cropRect.left + minSize, maxWidth),
          (_cropRect.bottom + delta.dy)
              .clamp(_cropRect.top + minSize, maxHeight),
        );
        break;
      default:
        return _cropRect;
    }

    // 更新基准点为当前屏幕坐标（避免累积误差）
    _startDragPoint = currentPosition;
    return newRect;
  }

  double _imageCenterX = 0; // 图片中间线在图片坐标系中的X坐标

  // 在状态类中添加图片处理逻辑
  Future<void> _processImage() async {
    if (_image == null || _cropRect.isEmpty) return;

    // 1. 图片中间线在图片坐标系中的X坐标
    _imageCenterX = _image!.width / 2;

    // 2. 计算分割位置/始终使用图片中间坐标
    final splitX = _imageCenterX;

    // 3. 分割左右图片
    if (_cropRect.left > splitX) {
      ToastUtils.showManageToast(text: "中间线需要在矩形区域内");
      return;
    }

    // 3、创建动态裁剪区域（结合裁剪框边界）
    final leftRect = Rect.fromLTRB(
      _cropRect.left.clamp(0, splitX), // 左边界不超过中间线
      _cropRect.top,
      splitX.clamp(_cropRect.left, _cropRect.right), // 右边界限制在裁剪框内
      _cropRect.bottom,
    );

    if (_cropRect.right < splitX) {
      ToastUtils.showManageToast(text: "中间线需要在矩形区域内");
      return;
    }

    final rightRect = Rect.fromLTRB(
      splitX.clamp(_cropRect.left, _cropRect.right), // 左边界限制在裁剪框内
      _cropRect.top,
      _cropRect.right.clamp(splitX, _image!.width.toDouble()), // 右边界不低于中间线
      _cropRect.bottom,
    );

    // 添加1像素重叠防止白边
    final adjustedLeftRect = leftRect.expandToInclude(Rect.fromLTRB(
        leftRect.left, leftRect.top, leftRect.right + 1, leftRect.bottom));

    final adjustedRightRect = rightRect.expandToInclude(Rect.fromLTRB(
        rightRect.left - 1, rightRect.top, rightRect.right, rightRect.bottom));
    final leftImage = await _cropImage(adjustedLeftRect);
    final rightImage = await _cropImage(adjustedRightRect);
    widget.onContinueTap?.call(leftImage, rightImage);
  }

// 核心裁剪方法
  Future<ui.Image> _cropImage(Rect rect) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 计算实际绘制参数
    final srcRect = Rect.fromLTWH(
      rect.left,
      rect.top,
      rect.width,
      rect.height,
    );

    final dstRect = Rect.fromLTWH(
      0,
      0,
      rect.width,
      rect.height,
    );

    // 绘制裁剪区域
    canvas.drawImageRect(
      _image!,
      srcRect,
      dstRect,
      Paint()
        ..filterQuality = FilterQuality.high
        ..isAntiAlias = true,
    );

    final picture = recorder.endRecording();
    return await picture.toImage(
      rect.width.toInt(),
      rect.height.toInt(),
    );
  }
}

// 1. 在状态类中添加顶点类型枚举
enum _CornerType { topLeft, topRight, bottomLeft, bottomRight, none }
