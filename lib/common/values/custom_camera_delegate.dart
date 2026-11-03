import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:langwise/common/widgets/camera_macos_dialog.dart';
import 'package:langwise/common/widgets/camera_video_recording_dialog.dart';
import 'package:langwise/common/widgets/camera_windows_dialog.dart';

/// 桌面端未显式传时，录制页使用较大兜底时长，避免默认被 30 秒截断。
const Duration _desktopFallbackVideoMaxDuration = Duration(seconds: 30);

/// 防止应用重复初始化时反复覆盖 delegate。
bool _hasRegisteredCameraDelegate = false;

/// 为桌面端 `image_picker` 的 `ImageSource.camera` 提供项目内自定义实现。
class CustomCameraDelegate extends ImagePickerCameraDelegate {
  @override
  Future<XFile?> takePhoto({
    ImagePickerCameraDelegateOptions options = const ImagePickerCameraDelegateOptions(),
  }) async {
    final File? file = await _takePhotoFile();
    return _buildXFile(file);
  }

  @override
  Future<XFile?> takeVideo({
    ImagePickerCameraDelegateOptions options = const ImagePickerCameraDelegateOptions(),
  }) async {
    final File? file = await _takeVideoFile(
      maxDuration: options.maxVideoDuration,
    );
    return _buildXFile(file);
  }
}

/// 在应用启动阶段注册桌面端 `cameraDelegate`。
void setUpCameraDelegate() {
  if (_hasRegisteredCameraDelegate) return;
  if (!(Platform.isMacOS || Platform.isWindows)) return;
  final ImagePickerPlatform instance = ImagePickerPlatform.instance;
  if (instance is! CameraDelegatingImagePickerPlatform) return;
  instance.cameraDelegate = CustomCameraDelegate();
  _hasRegisteredCameraDelegate = true;
}

/// 统一获取可用于弹层的全局上下文。
BuildContext? _resolveCameraDialogContext() {
  return Get.context ?? Get.overlayContext;
}

/// 通过项目现有桌面端拍照弹层获取图片文件。
Future<File?> _takePhotoFile() async {
  final BuildContext? context = _resolveCameraDialogContext();
  if (context == null || !context.mounted) return null;

  if (Platform.isMacOS) {
    return CameraMacosDialog.show(context: context);
  }
  if (Platform.isWindows) {
    return CameraWindowsDialog.show(context: context);
  }
  return null;
}

/// 通过项目现有桌面端录制弹层获取视频文件。
Future<File?> _takeVideoFile({
  Duration? maxDuration,
}) async {
  final BuildContext? context = _resolveCameraDialogContext();
  if (context == null || !context.mounted) return null;

  if (!(Platform.isMacOS || Platform.isWindows)) return null;
  return CameraVideoRecordingDialog.show(
    context: context,
    maxDuration: maxDuration ?? _desktopFallbackVideoMaxDuration,
  );
}

/// 把本地文件包装成 `image_picker` 约定返回的 `XFile`。
XFile? _buildXFile(File? file) {
  if (file == null) return null;
  return XFile(file.path);
}
