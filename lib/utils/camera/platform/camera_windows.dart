import 'dart:async';
import 'package:flutter/services.dart'; // 导入DeviceOrientation
import 'package:langwise/utils/camera/index.dart'; // 导入CameraWindows类

/// Windows平台相机实现
  /// Windows平台相机实现，使用 [CameraWindows] 控制器
  ///
  /// 该实现类提供了基本的相机控制接口，包括
  ///
  ///  - [isAvailable]：检查相机是否可用
  ///  - [isInitialized]：检查相机是否已经初始化
  ///  - [cameras]：获取可用相机列表
  ///  - [startCamera]：启动指定的相机
  ///  - [stopCamera]：停止当前的相机
  ///  - [takePicture]：拍照
  ///  - [switchCamera]：切换到下一个相机
class WindowsCameraImplementation implements AdvancedCameraInterface {
  // 状态变量
  bool _isAvailable = false;
  bool _isInitialized = false;
  bool _isTakingPicture = false; // 内部使用，不暴露

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

  @override
  Function(bool isAvailable)? onAvailabilityChanged;

  @override
  Function(bool isAvailable)? onInitializedChanged;

  // 闪光灯状态（Windows可能不支持控制闪光灯，但保留接口一致性）
  FlashMode _flashMode = FlashMode.off;

  FlashMode get flashMode => _flashMode;

  // 内部存储相机列表
  final List<CameraDescription> _cameras = <CameraDescription>[];

  // 寴外暴露相机列表
  @override
  List<CameraDescription> get cameras => List.unmodifiable(_cameras);

  // Windows特有的相机控制器
  CameraWindows? _windowsController;

  // 存储当前活动相机的ID
  int? _activeCameraId;

  // 相机预览尺寸
  Size? _previewSize;

  Size? get previewSize => _previewSize;

  @override
  CameraWindows? get advancedCameraController => _windowsController;

  @override
  Future<bool> initialize() async {
    try {
      final availableCameras = await getCameras();
      if (availableCameras.isEmpty) {
        _setIsAvailable(false);
        return false;
      }

      // 创建Windows相机控制器
      _windowsController = CameraWindows();

      _setIsAvailable(true);
      return true;
    } catch (e) {
      print('Windows相机初始化失败: $e');
      _setIsAvailable(false);
      return false;
    }
  }

  @override
  Future<dynamic> getCameras({Object? deviceType}) async {
    if (cameras.isEmpty) {
      try {
        // 确保控制器已创建
        if (advancedCameraController == null) {
          _windowsController = CameraWindows();
        }

        // 通过控制器对象获取相机列表
        // Windows平台忽略deviceType参数，因为其API与macOS不兼容
        final currentController = advancedCameraController!;
        final availableWindowsCameras = await currentController.availableCameras();

        // 将获取到的相机列表存储在_cameras变量中
        _cameras.clear();
        _cameras.addAll(availableWindowsCameras);

        // 打印相机信息用于调试
        if (cameras.isNotEmpty) {
          for (var i = 0; i < cameras.length; i++) {
            print('Windows相机 $i: ${cameras[i].name} (${cameras[i].lensDirection})');
          }
        }
      } catch (e) {
        print('获取Windows相机列表失败: $e');
      }
    }
    return cameras;
  }

  @override
  Future<bool> startCamera({
    int? cameraIndex,
    ResolutionPreset resolution = ResolutionPreset.veryHigh,
    PhotoFormat photoFormat = PhotoFormat.jpeg,
  }) async {
    try {
      await stopCamera();

      if (cameras.isEmpty) {
        await getCameras();
        if (cameras.isEmpty) return false;
      }

      // 选择相机
      final selectedIndex = cameraIndex ?? 0;
      if (selectedIndex >= cameras.length) return false;

      final CameraDescription selectedCamera = cameras[selectedIndex];

      // 使用传入的分辨率参数
      // startCamera方法的参数中已经指定默认值为ResolutionPreset.veryHigh
      // 使用非空断言运算符(!)保证类型安全
      final ResolutionPreset actualResolution = resolution;

      // 创建并初始化控制器
      final currentController = advancedCameraController;
      if (currentController == null) {
        return false;
      }

      // 初始化相机 - Windows相机流程按官方文档实现
      // 1. 调用createCamera并获取相机ID
      try {
        // createCamera返回相机ID，需要存储起来
        _activeCameraId = await currentController.createCamera(
          // 传递完整的CameraDescription对象
          selectedCamera,
          actualResolution,
        );
      } catch (e) {
        return false;
      }

      // 检查是否成功获取相机ID
      if (_activeCameraId == null || _activeCameraId! <= 0) {
        return false;
      }

      print('成功创建Windows相机，ID: $_activeCameraId');

      // 2. 调用initializeCamera初始化相机预览
      try {
        // 初始化相机并获取预览尺寸
        try {
          // 首先获取初始化事件通知
          // 用dynamic类型代替CameraInitializedEvent来提高兼容性
          final Future<dynamic> initialized = currentController.onCameraInitialized(_activeCameraId!).first;

          // 然后初始化相机
          await currentController.initializeCamera(_activeCameraId!, imageFormatGroup: ImageFormatGroup.jpeg);

          // 等待初始化事件
          final dynamic event = await initialized;

          // 设置预览尺寸
          if (event != null) {
            print('相机初始化完成，预览尺寸：${event.previewWidth} x ${event.previewHeight}');
            _previewSize = Size(
              event.previewWidth.toDouble(),
              event.previewHeight.toDouble(),
            );
          }
          // 如果无法获取相机尺寸，保持为null
        } catch (e) {
          print('无法获取相机初始化事件: $e');
          // 无法获取相机尺寸，保持为null
        }
      } catch (e) {
        // 尝试清理资源
        try {
          if (_activeCameraId != null) {
            await currentController.dispose(_activeCameraId!);
          }
        } catch (disposeError) {
          print('释放Windows相机资源失败: $disposeError');
        }

        _setIsInitialized(false);
        return false;
      }

      print('成功初始化Windows相机预览');
      _setIsInitialized(true);
      return true;
    } catch (e) {
      print('启动Windows相机失败: $e');
      _setIsInitialized(false);
      return false;
    }
  }

  @override
  Future<void> stopCamera() async {
    if (advancedCameraController != null && isInitialized && _activeCameraId != null) {
      try {
        // 按照官方文档，释放相机资源，需要传入相机ID
        await advancedCameraController!.dispose(_activeCameraId!);
        _activeCameraId = null;
        _previewSize = null;
        _setIsAvailable(false);
        _setIsInitialized(false);
        _isTakingPicture = false;
      } catch (e) {
        print('停止Windows相机失败: $e');
      }
    }
  }

  @override
  Future<dynamic> takePicture({
    PhotoFormat photoFormat = PhotoFormat.jpeg,
  }) async {
    if (advancedCameraController == null || !isInitialized || _isTakingPicture || _activeCameraId == null) {
      print(
          'Windows拍照失败: 控制器=${advancedCameraController == null ? '未初始化' : '已初始化'}, 初始化=$isInitialized, 正在拍照=$_isTakingPicture, 相机ID=${_activeCameraId ?? '无效'}');
      return null;
    }

    try {
      _isTakingPicture = true;
      // 使用Windows相机API拍照，需要传入相机ID
      final image = await advancedCameraController!.takePicture(_activeCameraId!);
      return image;
    } catch (e) {
      rethrow;
    } finally {
      _isTakingPicture = false;
    }
  }

  // 存储当前使用的相机索引
  int _cameraIndex = 0;

  @override
  Future<bool> switchCamera({int? cameraIndex}) async {
    try {
      if (cameras.isEmpty) {
        print('Windows相机列表为空，无法切换');
        return false;
      }

      // 如果传入了相机索引，则切换到指定索引的相机
      // 否则循环切换到下一个相机
      if (cameraIndex != null) {
        // 验证索引是否有效
        if (cameraIndex < 0 || cameraIndex >= cameras.length) {
          print('无效的相机索引: $cameraIndex');
          return false;
        }
        _cameraIndex = cameraIndex;
      } else {
        // 选择下一个相机索引（循环选择）
        _cameraIndex = (_cameraIndex + 1) % cameras.length;
      }

      // 如果已初始化且有有效的相机ID
      if (isInitialized && _activeCameraId != null) {
        // 先释放当前相机资源
        await stopCamera();

        // 重新获取相机列表，确保列表是最新的
        await getCameras();

        // 确保还有相机可用
        if (cameras.isNotEmpty) {
          // 启动新选择的相机
          return await startCamera(cameraIndex: _cameraIndex);
        }
        return false;
      } else {
        // 如果相机还未初始化，只更新索引
        await getCameras(); // 确保列表最新
        return true;
      }
    } catch (e) {
      print('切换Windows相机失败: $e');
      return false;
    }
  }

  // 以下方法在Windows上可能不支持或有限支持，保留接口一致性

  // Windows当前不支持设置曝光模式
  Future<bool> setExposureMode(ExposureMode exposureMode) async {
    // 注意：该方法不在接口中定义，仅为了保持平台实现的一致性
    return true;
  }

  /// 锁定相机捕获方向
  @override
  Future<bool> lockCaptureOrientation(DeviceOrientation orientation) async {
    // Windows相机当前不支持固定方向锁定
    print('Windows相机不支持锁定捕获方向');
    return true;
  }

  /// 解除相机捕获方向锁定
  @override
  Future<bool> unlockCaptureOrientation() async {
    // Windows相机当前不支持固定方向锁定
    print('Windows相机不支持解除捕获方向锁定');
    return true;
  }

  @override
  Future<void> setFlashMode(FlashMode mode) async {
    // Windows相机可能不支持闪光灯控制
    _flashMode = mode;
  }

  @override
  Future<void> toggleFlash() async {
    // Windows相机可能不支持闪光灯控制
    _flashMode = FlashMode.off;
  }

  @override
  Future<void> setFocusPoint(Offset point) async {
    // Windows相机API可能不支持触摸对焦
    // 留空以保持接口一致性
  }

  @override
  Future<void> setZoomLevel(double zoom) async {
    // Windows相机API可能不支持缩放控制
    // 留空以保持接口一致性
  }

  @override
  void dispose() {
    // 清除回调函数
    onInitializedChanged = null;
    onAvailabilityChanged = null;
    // 停止相机
    stopCamera();
  }
}
