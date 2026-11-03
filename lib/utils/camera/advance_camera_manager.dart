import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:camera_macos/camera_macos.dart';
import 'package:langwise/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// 高级相机管理器 - 统一跨平台相机接口
///
/// 主要功能：
/// - 多平台影像采集（支持Android、iOS、macOS及占位Windows实现）
/// - 相机初始化及设备发现
/// - 相机预览及拍照功能
/// - 闪光灯、变焦、缩放控制
/// - 前后置相机切换
///
/// 设计原则：
/// - 状态getter和回调方法并存，兼顶同步和异步两种访问方式
/// - getter提供即时状态查询（如`if(camera.isAvailable)`）
/// - 回调提供状态变化监听（如`camera.onAvailabilityChanged = (v) => update()`）
/// - 支持面向对象和响应式编程两种范式
class AdvanceCameraManager {
  AdvanceCameraManager() {
    // 创建平台相机实现
    _createPlatformImplementation();
    log('创建平台相机实现: ${_implementation.runtimeType}');
    // 设置回调函数
    _setupCallbacks();
  }

  // 平台相机实现
  late final AdvancedCameraInterface _implementation;

  // 状态变量 - 使用普通变量代替Rx
  bool _isAvailable = false;
  bool _isInitialized = false;
  bool _isTakingPicture = false;

  // 状态回调函数
  Function(bool isAvailable)? onAvailabilityChanged;
  Function(bool isInitialized)? onInitializedChanged;
  Function(bool isTakingPicture)? onTakingPictureChanged;

  // 状态getter
  bool get isAvailable => _isAvailable;

  bool get isInitialized => _isInitialized;

  bool get isTakingPicture => _isTakingPicture;

  List<CameraDescription> get cameras => _implementation.cameras;

  Future<void> initialize() async {
    // 初始化相机
    await _implementation.initialize();
  }

  /// 设置回调函数
  void _setupCallbacks() {
    // 同步初始值
    _isAvailable = _implementation.isAvailable;
    _isInitialized = _implementation.isInitialized;

    // 设置相机状态变化回调
    _implementation.onAvailabilityChanged = (bool available) {
      _setAvailability(available);
      log(available ? '相机可用' : '相机不可用');
    };

    _implementation.onInitializedChanged = (bool initialized) {
      _setInitialization(initialized);
      log(initialized ? '相机初始化完成' : '相机未初始化');
    };
  }

  /// 设置可用性状态并触发回调
  void _setAvailability(bool available) {
    if (_isAvailable != available) {
      _isAvailable = available;
      if (onAvailabilityChanged != null) {
        onAvailabilityChanged!(available);
      }
    }
  }

  /// 设置初始化状态并触发回调
  void _setInitialization(bool initialized) {
    if (_isInitialized != initialized) {
      _isInitialized = initialized;
      if (onInitializedChanged != null) {
        onInitializedChanged!(initialized);
      }
    }
  }

  /// 设置拍照状态并触发回调
  void _setTakingPicture(bool taking) {
    if (_isTakingPicture != taking) {
      _isTakingPicture = taking;
      if (onTakingPictureChanged != null) {
        onTakingPictureChanged!(taking);
      }
    }
  }

  /// 处理相机异常情况
  Future<bool> _handleCameraException(String operation, dynamic e) async {
    final errorMessage = '相机$operation失败: $e';
    log(errorMessage);

    // 记录异常类型和堆栈信息
    final errorType = e.runtimeType.toString();
    final stackTrace = e is Error ? e.stackTrace?.toString() : StackTrace.current.toString();
    log('异常类型: $errorType');
    log('堆栈信息: $stackTrace');

    // 分类处理各种异常
    final errorString = e.toString().toLowerCase();

    if (errorString.contains('permission')) {
      // 权限相关错误
      log('相机权限错误: 用户可能需要授权相机访问');
      // TODO: 集成权限引导 UI
    } else if (errorString.contains('unavailable') || errorString.contains('找不到相机')) {
      // 相机不可用
      log('相机不可用错误: 请检查硬件连接或是否被其他程序占用');
    } else if (errorString.contains('timeout') || errorString.contains('超时')) {
      // 操作超时
      log('相机操作超时: 请检查设备性能或网络连接');
    } else if (errorString.contains('format') || errorString.contains('格式')) {
      // 格式错误
      log('相机格式错误: 不支持的图像格式或分辨率');
    } else {
      // 其他未知错误
      log('未分类的相机错误');
    }

    return false;
  }

  /// 初始化平台相机实现
  void _createPlatformImplementation() {
    if (isAndroid() || isIOS()) {
      _implementation = MobileCameraImplementation();
    } else if (isMacOS()) {
      _implementation = MacOSCameraImplementation();
    } else if (isWindows()) {
      _implementation = WindowsCameraImplementation();
    } else {
      // 其他平台默认使用移动端实现
      _implementation = MobileCameraImplementation();
    }
  }

  /// 获取相机列表
  /// 支持可选的deviceType参数过滤设备类型（仅macOS平台生效）
  Future<List<CameraDescription>> getCameras({Object? deviceType}) async {
    try {
      // 获取动态类型结果
      final dynamic result = await _implementation.getCameras(deviceType: deviceType);

      // 简单判断result类型
      if (result == null) {
        print('获取相机列表返回了null');
        return [];
      }

      // 如果已经是CameraDescription列表，打印信息后返回
      if (result is List<CameraDescription>) {
        // 打印相机信息
        for (var i = 0; i < result.length; i++) {
          final camera = result[i];
          log('  相机[$i]: 名称=${camera.name}, 方向=${camera.lensDirection}, 方向值=${camera.sensorOrientation}');
        }
        return result;
      }

      // 如果是普通列表，尝试转换
      if (result is List<CameraMacOSDevice>) {
        final cameraList = <CameraDescription>[];

        // 尝试遍历列表并转换元素
        for (final CameraMacOSDevice device in result) {
          // macOS平台特殊处理
          final deviceName = device.localizedName ?? '';
          final name = deviceName.toLowerCase();

          // 判断相机方向
          CameraLensDirection lensDirection = CameraLensDirection.external;
          if (name.contains('front') || name.contains('facetime')) {
            lensDirection = CameraLensDirection.front;
          } else if (name.contains('back') || name.contains('rear')) {
            lensDirection = CameraLensDirection.back;
          }

          cameraList.add(CameraDescription(
            // todo 返回名字/相机唯一标识也要返回deviceId/name
            name: device.deviceId,
            lensDirection: lensDirection,
            sensorOrientation: 0,
          ));
        }

        if (cameraList.isNotEmpty) {
          // macOS 相机特殊处理后的相机列表信息
          for (var i = 0; i < cameraList.length; i++) {
            final camera = cameraList[i];
            log('  相机[$i]: 名称=${camera.name}, 方向=${camera.lensDirection}, 方向值=${camera.sensorOrientation}');
          }
          return cameraList;
        }
      }

      // 如果无法处理，返回空列表
      print('无法识别相机列表类型: ${result.runtimeType}');
      return [];
    } catch (e) {
      print('获取相机列表异常: $e');
      return [];
    }
  }

  /// 启动相机预览
  Future<bool> startCamera({
    int? cameraIndex,
    ResolutionPreset resolution = ResolutionPreset.veryHigh,
    PhotoFormat photoFormat = PhotoFormat.jpeg,
  }) async {
    try {
      return await _implementation.startCamera(
        cameraIndex: cameraIndex,
        resolution: resolution,
        photoFormat: photoFormat,
      );
    } catch (e) {
      return await _handleCameraException('启动', e);
    }
  }

  /// 停止相机
  Future<void> stopCamera() async {
    try {
      await _implementation.stopCamera();
      _setInitialization(false);
      log('停止相机成功');
    } catch (e) {
      await _handleCameraException('停止', e);
    }
  }

  /// 锁定相机捕获方向
  /// 该方法允许外部代码指定相机应使用的方向
  /// 如果不锁定，相机将根据设备方向自动旋转
  ///
  /// 参数：
  /// - [orientation]: 要锁定的设备方向，例如[DeviceOrientation.landscapeLeft]
  ///
  /// 返回：
  /// - 如果成功设置方向锁定，返回true
  /// - 如果方向锁定失败，返回false
  Future<bool> lockCaptureOrientation(DeviceOrientation orientation) async {
    try {
      // 调用平台实现的方法
      final result = await _implementation.lockCaptureOrientation(orientation);
      if (result) {
        print('成功锁定相机捕获方向: $orientation');
      } else {
        print('锁定相机捕获方向失败: $orientation');
      }
      return result;
    } catch (e) {
      await _handleCameraException('锁定方向', e);
      return false;
    }
  }

  /// 解除相机捕获方向锁定
  /// 该方法允许相机根据设备物理方向自动旋转
  /// 如果之前调用了lockCaptureOrientation，这个方法将解除该限制
  ///
  /// 返回：
  /// - 如果成功解除方向锁定，返回true
  /// - 如果解除锁定失败，返回false
  Future<bool> unlockCaptureOrientation() async {
    try {
      // 使用底层实现的方法
      final result = await _implementation.unlockCaptureOrientation();
      if (result) {
        print('成功解除相机捕获方向锁定');
      } else {
        print('解除相机捕获方向锁定失败');
      }
      return result;
    } catch (e) {
      await _handleCameraException('解除方向锁定', e);
      return false;
    }
  }

  /// 拍照
  /// 返回 XFile 对象或 null（如果拍照失败）
  /// 这将各平台返回的不同类型统一转换为 XFile
  Future<XFile?> takePicture({
    PhotoFormat photoFormat = PhotoFormat.jpeg,
  }) async {
    try {
      // 设置拍照状态
      _setTakingPicture(true);
      log('开始拍照...');

      // 调用平台实现，获取动态类型结果
      final dynamic result = await _implementation.takePicture(photoFormat: photoFormat);

      // 处理不同平台返回的结果类型
      if (result == null) {
        log('拍照失败: 结果为null');
        return null;
      }

      // 返回结果是 XFile 类型
      if (result is XFile) {
        log('拍照成功: ${result.path}');
        return result;
      }

      // 结果是路径字符串
      if (result is String) {
        // 创建新的 XFile 对象
        return XFile(result);
      }

      // 处理 macOS 特有的 CameraMacOSFile 对象
      try {
        final dynamic macFile = result;

        // 检查是否有 url 属性
        if (macFile.url != null && macFile.url is String) {
          return XFile(macFile.url as String, bytes: macFile.bytes);
        }

        // 如果有字节数组但没有URL，则创建内存XFile
        if (macFile.bytes != null && macFile.bytes is Uint8List) {
          // 生成UUID
          final uuid = const Uuid().v6();
          // 保存到临时文件
          final tempDir = await getTemporaryDirectory();
          final fileName = '$uuid.jpg';
          final tempFile = File(path.join(tempDir.path, fileName));
          tempFile.createSync(recursive: true);
          tempFile.writeAsBytesSync(macFile.bytes as Uint8List);
          return XFile(tempFile.path, bytes: macFile.bytes);
        }
      } catch (_) {}

      // 最后尝试将对象转为字符串
      try {
        return XFile(result.toString());
      } catch (e) {
        log('无法将拍照结果转换为 XFile: $e');
        _setTakingPicture(false);
        return null;
      }
    } catch (e) {
      await _handleCameraException('拍照', e);
      _setTakingPicture(false);
      return null;
    } finally {
      // 无论成功失败都将状态设回false
      _setTakingPicture(false);
    }
  }

  /// 切换相机
  Future<bool> switchCamera({int? cameraIndex}) async {
    try {
      return await _implementation.switchCamera(cameraIndex: cameraIndex);
    } catch (e) {
      return await _handleCameraException('切换', e);
    }
  }

  /// 设置闪光灯模式
  Future<void> setFlashMode(FlashMode mode) {
    return _implementation.setFlashMode(mode);
  }

  /// 切换闪光灯模式
  Future<void> toggleFlash() {
    return _implementation.toggleFlash();
  }

  /// 设置对焦点
  Future<void> setFocusPoint(Offset point) {
    return _implementation.setFocusPoint(point);
  }

  /// 设置缩放级别
  Future<void> setZoomLevel(double zoom) {
    return _implementation.setZoomLevel(zoom);
  }

  /// 获取原生相机控制器
  dynamic get controller => _implementation.advancedCameraController;

  /// 获取可用相机列表
  List<CameraDescription> get availableCameras => _implementation.cameras.toList();

  /// 设置对焦点
  /// 获取预览尺寸（不同平台可能实现不同）
  Size? get previewSize {
    final controller = _implementation.advancedCameraController;

    // Windows平台特殊处理
    if (isWindows()) {
      final windowsImpl = _implementation as WindowsCameraImplementation;
      return windowsImpl.previewSize;
    }

    // 移动端平台从相机控制器中获取
    if (isAndroid() || isIOS()) {
      final mobileController = controller as CameraController?;
      if (mobileController != null && mobileController.value.isInitialized) {
        return Size(
          mobileController.value.previewSize!.width,
          mobileController.value.previewSize!.height,
        );
      }
    }

    // macOS平台根据分辨率返回大致尺寸
    if (isMacOS()) {
      final macosImpl = _implementation as MacOSCameraImplementation;
      return macosImpl.cameraArgs?.size;
    }

    // 如果无法获取尺寸信息，返回null
    return null;
  }

  /// 记录日志，添加类名前缀
  void log(String message) {
    print('[相机工具] [$runtimeType] $message');
  }

  /// 确保协调多平台相机适配
  bool isAndroid() => Platform.isAndroid;

  bool isIOS() => Platform.isIOS;

  bool isMacOS() => Platform.isMacOS;

  bool isWindows() => Platform.isWindows;

  bool isLinux() => Platform.isLinux;

  /// 检查是否是移动端
  bool get isMobile => isAndroid() || isIOS();

  /// 检查是否是桌面端
  bool get isDesktop => isWindows() || isMacOS() || isLinux();

  /// 在页面关闭时调用该方法释放相机资源
  void dispose() {
    // 清除回调
    onAvailabilityChanged = null;
    onInitializedChanged = null;
    onTakingPictureChanged = null;
    // 释放相机实现类资源
    _implementation.dispose();
    print('[相机工具] [$runtimeType] 相机资源已释放');
  }
}
