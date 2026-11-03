import 'dart:async';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';

/// 照片格式枚举，不同平台可能支持的格式不同
enum PhotoFormat { jpeg, png, raw, yuv, unknown }

/// 多平台通用相机工具
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
/// - getter提供即时状态查询（如`if(camera.isInitialized)`）
/// - 回调提供状态变化监听（如`camera.onInitializedChanged = (v) => update()`）
/// - 支持面向对象和响应式编程两种范式
///
/// 相机接口，定义所有平台通用的相机操作
abstract class AdvancedCameraInterface {
  // 相机状态回调函数
  Function(bool isInitialized)? onInitializedChanged;
  Function(bool isAvailable)? onAvailabilityChanged;

  // 相机状态/是否可用/是否初始化
  bool get isAvailable;

  bool get isInitialized;

  // 获取相机控制器（平台不同实现不同）
  dynamic get advancedCameraController;

  // 已缓存的相机列表（只读）
  // 注意：这是直接返回已缓存的列表，如果要重新扫描相机应使用getCameras方法
  // mac此数据为空,必须重新扫描
  List<CameraDescription> get cameras;

  // 初始化相机
  Future<bool> initialize();

  // 启动相机预览
  Future<bool> startCamera({
    int? cameraIndex,
    ResolutionPreset resolution = ResolutionPreset.veryHigh,
    PhotoFormat photoFormat = PhotoFormat.jpeg,
  });

  // 停止相机
  Future<void> stopCamera();

  // 拍照
  // 返回动态类型，由AdvanceCameraManager处理转换为XFile
  Future<dynamic> takePicture({
    PhotoFormat photoFormat = PhotoFormat.jpeg,
  });

  // 切换相机
  // 如果指定cameraIndex，则切换到指定索引的相机
  // 如果不指定，则循环切换到下一个相机
  Future<bool> switchCamera({int? cameraIndex});

  // 闪光灯控制
  Future<void> setFlashMode(FlashMode mode);

  Future<void> toggleFlash();

  // 对焦控制
  Future<void> setFocusPoint(Offset point);

  // 缩放控制
  Future<void> setZoomLevel(double zoom);

  // 获取相机列表
  // 返回动态类型，由上层AdvanceCameraManager进行正确的类型转换
  // deviceType参数用于过滤设备类型，仅在macOS平台生效
  // 当deviceType为null时，默认为视频设备类型（CameraMacOSDeviceType.video）
  Future<dynamic> getCameras({Object? deviceType});

  /// 锁定相机捕获方向
  /// 该方法允许指定相机应使用的方向
  /// 如果不锁定，相机将根据设备方向自动旋转
  ///
  /// 参数：
  /// - [orientation]: 要锁定的设备方向，例如[DeviceOrientation.landscapeLeft]
  Future<bool> lockCaptureOrientation(DeviceOrientation orientation);

  /// 解除相机捕获方向锁定
  /// 该方法允许相机根据设备物理方向自动旋转
  /// 如果之前调用了lockCaptureOrientation，这个方法将解除该限制
  Future<bool> unlockCaptureOrientation();

  // 释放资源
  void dispose();
}
