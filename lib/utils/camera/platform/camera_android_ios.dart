import 'dart:async';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:langwise/utils/camera/advanced_camera_interface.dart';

/// 移动端(Android/iOS)相机实现
class MobileCameraImplementation implements AdvancedCameraInterface {
  // 相机状态回调函数
  @override
  Function(bool isInitialized)? onInitializedChanged;

  @override
  Function(bool isAvailable)? onAvailabilityChanged;

  // 状态变量
  bool _isAvailable = false;
  bool _isInitialized = false;
  bool _isTakingPicture = false;

  // 更新状态并触发回调
  void _setIsInitialized(bool value) {
    if (_isInitialized != value) {
      _isInitialized = value;
      onInitializedChanged?.call(value);
    }
  }

  void _setIsAvailable(bool value) {
    if (_isAvailable != value) {
      _isAvailable = value;
      onAvailabilityChanged?.call(value);
    }
  }

  @override
  bool get isAvailable => _isAvailable;

  @override
  bool get isInitialized => _isInitialized;

  // 闪光灯状态
  FlashMode _flashMode = FlashMode.off;

  FlashMode get flashMode => _flashMode;

  // 内部存储相机列表
  final List<CameraDescription> _cameras = <CameraDescription>[];

  // 对外暴露相机列表
  @override
  List<CameraDescription> get cameras => List.unmodifiable(_cameras);

  // 相机控制器
  CameraController? _controller;

  /// 获取控制器
  @override
  CameraController? get advancedCameraController => _controller;

  // 存储当前使用的相机索引
  int _currentCameraIndex = 0;

  /// 获取图像格式组
  ImageFormatGroup _getImageFormatGroup(PhotoFormat format) {
    switch (format) {
      case PhotoFormat.jpeg:
        return ImageFormatGroup.jpeg;
      case PhotoFormat.yuv:
        return ImageFormatGroup.yuv420;
      case PhotoFormat.raw:
        return ImageFormatGroup.bgra8888;
      default:
        return ImageFormatGroup.unknown;
    }
  }

  @override
  Future<bool> initialize() async {
    try {
      final availableCameras = await getCameras();
      if (availableCameras.isEmpty) {
        _setIsAvailable(false);
        return false;
      }

      _setIsAvailable(true);
      return true;
    } catch (e) {
      print('[相机工具] [$runtimeType] 初始化失败: $e');
      _setIsAvailable(false);
      return false;
    }
  }

  @override
  Future<List<CameraDescription>> getCameras({Object? deviceType}) async {
    try {
      // 如果已有缓存，则直接返回
      if (_cameras.isNotEmpty) {
        return _cameras;
      }

      // 使用camera包提供的方法获取相机列表
      final List<CameraDescription> availableCameraList = await availableCameras();

      // 打印相机信息以进行调试
      print('[移动端相机] 获取到 ${availableCameraList.length} 个相机');
      for (var i = 0; i < availableCameraList.length; i++) {
        final camera = availableCameraList[i];
        print('  相机[$i]: 名称=${camera.name}, 方向=${camera.lensDirection}, 方向值=${camera.sensorOrientation}');
      }

      // 更新内部列表
      _cameras.clear();
      _cameras.addAll(availableCameraList);

      return _cameras;
    } catch (e) {
      print('获取移动端相机列表失败: $e');
      return [];
    }
  }

  @override
  Future<bool> startCamera({
    int? cameraIndex,
    ResolutionPreset resolution = ResolutionPreset.veryHigh,
    PhotoFormat photoFormat = PhotoFormat.jpeg,
  }) async {
    try {
      // 先停止当前相机
      await stopCamera();

      // 确保相机列表已加载
      if (_cameras.isEmpty) {
        await getCameras();
        if (_cameras.isEmpty) {
          _setIsInitialized(false);
          return false;
        }
      }

      // 设置当前相机索引
      _currentCameraIndex = cameraIndex ?? 0;
      if (_currentCameraIndex >= _cameras.length) {
        _currentCameraIndex = 0;
      }

      // 获取相机描述
      final cameraDescription = _cameras[_currentCameraIndex];

      // 创建相机控制器
      final cameraController = CameraController(
        cameraDescription,
        resolution,
        enableAudio: false,
        imageFormatGroup: _getImageFormatGroup(photoFormat),
      );

      // 设置控制器
      _controller = cameraController;

      // 初始化相机
      await cameraController.initialize();

      // 添加监听器处理控制器状态变化
      cameraController.addListener(_onCameraControllerChanged);

      // 设置闪光灯模式
      await cameraController.setFlashMode(_flashMode);

      // 更新初始化状态
      _setIsInitialized(true);

      return true;
    } catch (e) {
      print('[相机工具] [$runtimeType] 启动移动端相机失败: $e');
      _setIsInitialized(false);
      return false;
    }
  }

  /// 监听相机控制器状态变化
  void _onCameraControllerChanged() {
    final controller = _controller;
    if (controller != null) {
      // 更新初始化状态
      _setIsInitialized(controller.value.isInitialized);
    }
  }

  @override
  Future<void> stopCamera() async {
    if (advancedCameraController != null) {
      // 移除监听器
      advancedCameraController!.removeListener(_onCameraControllerChanged);

      if (advancedCameraController!.value.isInitialized) {
        try {
          await unlockCaptureOrientation();
          await advancedCameraController!.dispose();
        } catch (e) {
          print('释放相机失败: $e');
        }
      }

      _controller = null;
      _setIsInitialized(false);
    }
  }

  @override
  Future<XFile?> takePicture({
    PhotoFormat photoFormat = PhotoFormat.jpeg,
  }) async {
    if (advancedCameraController == null || !_isInitialized || _isTakingPicture) {
      print(
          '移动端拍照失败: 控制器=${advancedCameraController == null ? '未初始化' : '已初始化'}, 初始化=$_isInitialized, 正在拍照=$_isTakingPicture');
      return null;
    }

    try {
      _isTakingPicture = true;
      final image = await advancedCameraController!.takePicture();
      return image;
    } catch (e) {
      print('移动端拍照失败: $e');
      rethrow;
    } finally {
      _isTakingPicture = false;
    }
  }

  @override
  Future<bool> switchCamera({int? cameraIndex}) async {
    try {
      if (_cameras.isEmpty) {
        print('移动端相机列表为空，无法切换');
        return false;
      }

      // 确定要切换到的相机索引
      int newIndex;
      if (cameraIndex != null) {
        // 切换到指定索引
        newIndex = cameraIndex;
      } else {
        // 循环切换到下一个相机
        newIndex = (_currentCameraIndex + 1) % _cameras.length;
      }

      // 确保索引有效
      if (newIndex >= _cameras.length) {
        newIndex = 0;
      }

      // 记录新的索引并启动相机
      _currentCameraIndex = newIndex;
      return await startCamera(cameraIndex: newIndex);
    } catch (e) {
      print('切换相机失败: $e');
      return false;
    }
  }

  @override
  Future<void> setFlashMode(FlashMode mode) async {
    try {
      // 更新闪光灯模式
      _flashMode = mode;

      // 如果相机已初始化，则立即应用设置
      final currentController = _controller;
      if (currentController != null && _isInitialized) {
        await currentController.setFlashMode(mode);
      }
    } catch (e) {
      print('设置闪光灯模式失败: $e');
    }
  }

  @override
  Future<void> toggleFlash() async {
    // 切换闪光灯模式
    FlashMode newMode;

    switch (_flashMode) {
      case FlashMode.off:
        newMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        newMode = FlashMode.always;
        break;
      case FlashMode.always:
        newMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        newMode = FlashMode.off;
        break;
    }

    await setFlashMode(newMode);
  }

  @override
  Future<bool> lockCaptureOrientation(DeviceOrientation orientation) async {
    try {
      final controller = advancedCameraController;
      if (controller == null || !_isInitialized) {
        print('无法锁定移动端相机方向: 相机未初始化');
        return false;
      }

      // 锁定相机捕获方向
      await controller.lockCaptureOrientation(orientation);
      print('成功锁定移动端相机捕获方向: $orientation');
      return true;
    } catch (e) {
      print('锁定移动端相机方向失败: $e');
      return false;
    }
  }

  @override
  Future<bool> unlockCaptureOrientation() async {
    try {
      final controller = advancedCameraController;
      if (controller == null || !_isInitialized) {
        print('无法解除移动端相机方向锁定: 相机未初始化');
        return false;
      }

      // 解除相机捕获方向锁定
      await controller.unlockCaptureOrientation();
      print('解除移动端相机方向锁定成功');
      return true;
    } catch (e) {
      print('解除移动端相机方向锁定失败: $e');
      return false;
    }
  }

  @override
  Future<void> setFocusPoint(Offset point) async {
    try {
      final currentController = _controller;
      if (currentController != null && _isInitialized) {
        await currentController.setFocusPoint(point);
        await currentController.setExposurePoint(point);
      }
    } catch (e) {
      print('设置对焦点失败: $e');
    }
  }

  @override
  Future<void> setZoomLevel(double zoom) async {
    try {
      final currentController = _controller;
      if (currentController != null && _isInitialized) {
        // 确保缩放值在有效范围内
        final minZoom = await currentController.getMinZoomLevel();
        final maxZoom = await currentController.getMaxZoomLevel();

        final validZoom = zoom.clamp(minZoom, maxZoom);
        await currentController.setZoomLevel(validZoom);
      }
    } catch (e) {
      print('设置缩放级别失败: $e');
    }
  }

  @override
  void dispose() {
    // 清除回调函数
    onInitializedChanged = null;
    onAvailabilityChanged = null;
    stopCamera();
  }
}
