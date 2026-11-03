import 'dart:async';
import 'package:camera_macos/camera_macos.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:langwise/utils/camera/advanced_camera_interface.dart';

/// macOS平台相机实现
class MacOSCameraImplementation implements AdvancedCameraInterface {
  // 相机状态回调函数
  @override
  Function(bool isInitialized)? onInitializedChanged;

  @override
  Function(bool isAvailable)? onAvailabilityChanged;

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

  // 闪光灯状态（macOS不支持控制闪光灯，但保留接口一致性）
  FlashMode _flashMode = FlashMode.off;

  FlashMode get flashMode => _flashMode;

  // 相机列表（内部存储）
  final List<CameraDescription> _cameras = <CameraDescription>[];

  // 对外暴露相机列表
  @override
  List<CameraDescription> get cameras => List.unmodifiable(_cameras);

  // macOS平台相机接口
  CameraMacOSPlatform get _platformInstance => CameraMacOSPlatform.instance;

  // 已选择的相机ID
  String? _activeCameraId;

  String? get activeCameraId => _activeCameraId;

  // macOS相机控制器参数
  CameraMacOSArguments? _cameraArgs;

  CameraMacOSArguments? get cameraArgs => _cameraArgs;

  // macOS相机控制器
  CameraMacOSController? _macOSController;

  // 获取控制器实例（内部使用）
  @override
  CameraMacOSController? get advancedCameraController => _macOSController;

  // 相机设备列表
  final List<CameraMacOSDevice> _macOSCameras = <CameraMacOSDevice>[];

  @override
  Future<bool> initialize() async {
    try {
      // 获取可用相机列表
      final availableCameras = await getCameras();
      if (availableCameras.isEmpty) {
        _setIsAvailable(false);
        return false;
      }

      // 标记相机可用
      _setIsAvailable(true);
      return true;
    } catch (e) {
      print('macOS相机初始化失败: $e');
      _setIsAvailable(false);
      return false;
    }
  }

  @override
  Future<dynamic> getCameras({Object? deviceType}) async {
    try {
      // 使用平台接口获取macOS相机设备列表
      // 处理deviceType参数类型转换
      CameraMacOSDeviceType? macOSDeviceType;

      if (deviceType != null) {
        // 如果是枚举类型，直接转换
        if (deviceType is CameraMacOSDeviceType) {
          macOSDeviceType = deviceType;
        } else {
          // 如果是字符串，则尝试匹配
          if (deviceType is String) {
            final String typeStr = deviceType.toLowerCase();
            if (typeStr.contains('video')) {
              macOSDeviceType = CameraMacOSDeviceType.video;
            } else if (typeStr.contains('audio')) {
              macOSDeviceType = CameraMacOSDeviceType.audio;
            }
          }
        }
      }
      // 如果无法匹配，默认为CameraMacOSDeviceType.video
      macOSDeviceType ??= CameraMacOSDeviceType.video;
      // 获取设备列表
      final List<CameraMacOSDevice> devices = await _platformInstance.listDevices(deviceType: macOSDeviceType);

      // 清空原有列表
      _macOSCameras.clear();

      if (devices.isEmpty) {
        return [];
      }

      // 存储原始的macOS设备列表
      _macOSCameras.addAll(devices);

      // 打印相机信息用于调试
      if (_macOSCameras.isNotEmpty) {
        for (var i = 0; i < _macOSCameras.length; i++) {
          print(
              'macOS相机 $i: ${_macOSCameras[i].deviceId} - 设备信息: ${_macOSCameras[i].localizedName}, 制造商: ${_macOSCameras[i].manufacturer}');
        }
      }

      // 直接返回macOS设备列表，由上层进行转换
      return _macOSCameras.toList();
    } catch (e) {
      print('获取macOS相机列表失败: $e');
      return [];
    }
  }

  @override
  Future<bool> startCamera({
    int? cameraIndex,
    ResolutionPreset resolution = ResolutionPreset.veryHigh,
    PictureResolution macPictureResolution = PictureResolution.veryHigh,
    PhotoFormat photoFormat = PhotoFormat.jpeg,
  }) async {
    try {
      await stopCamera();

      if (_macOSCameras.isEmpty) {
        // 获取macOS相机设备列表
        await getCameras();
        if (_macOSCameras.isEmpty) return false;
      }

      // 选择相机
      final selectedIndex = cameraIndex ?? 0;
      if (selectedIndex >= _macOSCameras.length) return false;

      // 保存设备ID
      _activeCameraId = _macOSCameras[selectedIndex].deviceId;

      // 创建相机参数
      _cameraArgs = await _platformInstance.initialize(
          deviceId: _activeCameraId,
          enableAudio: false,
          resolution: macPictureResolution,
          cameraMacOSMode: CameraMacOSMode.photo,
          pictureFormat: PictureFormat.jpg,
          isVideoMirrored: false,
          orientation: CameraOrientation.orientation0deg);

      // 创建相机控制器
      if (_cameraArgs != null) {
        _macOSController = CameraMacOSController(_cameraArgs!);
      }

      // 创建相机成功
      _setIsInitialized(true);
      return true;
    } catch (e) {
      print('启动macOS相机失败: $e');
      _setIsInitialized(false);
      return false;
    }
  }

  @override
  Future<void> stopCamera() async {
    if (advancedCameraController != null) {
      try {
        // 使用控制器的destroy方法释放相机资源
        await advancedCameraController!.destroy();
      } catch (e) {
        print('停止macOS相机失败: $e');
      } finally {
        _macOSController = null;
        _cameraArgs = null;
        // 更新状态
        _setIsInitialized(false);
        _activeCameraId = null;
      }
    } else if (_cameraArgs != null) {
      // 如果只有参数没有控制器，也尝试释放
      try {
        await _platformInstance.destroy();
      } catch (e) {
        print('停止macOS相机失败: $e');
      } finally {
        _cameraArgs = null;
        _setIsInitialized(false);
        _activeCameraId = null;
      }
    }
  }

  @override
  Future<dynamic> takePicture({
    PhotoFormat photoFormat = PhotoFormat.jpeg,
  }) async {
    if (advancedCameraController == null || !isInitialized || _isTakingPicture) {
      print(
          'macOS拍照失败: 控制器=${advancedCameraController == null ? '未初始化' : '已初始化'}, 初始化=$isInitialized, 正在拍照=$_isTakingPicture');
      return null;
    }

    try {
      _isTakingPicture = true;

      // 使用macOS相机API拍照，返回CameraMacOSFile对象
      // 这将由AdvanceCameraManager转换为XFile
      final CameraMacOSFile? macOSFile = await advancedCameraController!.takePicture();
      return macOSFile;
    } catch (e) {
      print('macOS拍照失败: $e');
      rethrow;
    } finally {
      _isTakingPicture = false;
    }
  }

// 存储当前使用的相机索引
  int _currentCameraIndex = 0;

  @override
  Future<bool> switchCamera({int? cameraIndex}) async {
    try {
      // 获取相机列表
      await getCameras();

      if (cameras.isEmpty) {
        print('macOS相机列表为空，无法切换');
        return false;
      }

      // 如果指定了索引，则使用指定索引
      if (cameraIndex != null) {
        // 验证索引有效性
        if (cameraIndex < 0 || cameraIndex >= cameras.length) {
          print('无效的相机索引: $cameraIndex');
          return false;
        }
        _currentCameraIndex = cameraIndex;
      } else {
        // 否则循环切换到下一个相机
        _currentCameraIndex = (_currentCameraIndex + 1) % cameras.length;
      }

      // 重启相机
      if (isInitialized) {
        await stopCamera();
      }

      // 启动选择的相机
      return await startCamera(cameraIndex: _currentCameraIndex);
    } catch (e) {
      print('切换macOS相机失败: $e');
      return false;
    }
  }

// 以下方法在macOS上可能不支持，保留接口一致性但不实际操作
  @override
  Future<void> setFlashMode(FlashMode mode) async {
    // macOS相机不支持闪光灯控制
    _flashMode = mode;
  }

  @override
  Future<void> toggleFlash() async {
    // macOS相机不支持闪光灯控制
    _flashMode = FlashMode.off;
  }

  @override
  Future<bool> lockCaptureOrientation(DeviceOrientation orientation) async {
    // macOS相机当前不支持固定方向锁定，但保留接口一致性
    print('macOS相机不支持锁定方向: $orientation');
    // 返回true以避免调用者处理额外逻辑
    return true;
  }

  @override
  Future<bool> unlockCaptureOrientation() async {
    // macOS相机当前不支持固定方向锁定
    print('macOS相机不支持解除捕获方向锁定');
    return true;
  }

  @override
  Future<void> setFocusPoint(Offset point) async {
    // macOS相机可能不支持触摸对焦
    // 留空以保持接口一致性
    // 设置相机对焦点
    return advancedCameraController?.setFocusPoint(point);
  }

  @override
  Future<void> setZoomLevel(double zoom) async {
    // macOS相机可能不支持缩放
    // 留空以保持接口一致性
  }

  @override
  void dispose() {
    // 清除回调函数
    onInitializedChanged = null;
    onAvailabilityChanged = null;
    advancedCameraController?.destroy();
    _macOSController = null;
    _cameraArgs = null;
    _setIsAvailable(false);
    _setIsInitialized(false);
    _isTakingPicture = false;
    _activeCameraId = null;
  }
}
