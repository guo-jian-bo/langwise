import 'dart:io';
import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/camera/index.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 高级跨平台相机预览组件
/// 根据不同平台提供相应的预览UI
class AdvanceCameraPreview extends StatelessWidget {
  /// 相机管理器实例
  final AdvanceCameraManager cameraManager;

  /// 预览框的圆角
  final BorderRadius? borderRadius;

  const AdvanceCameraPreview({
    Key? key,
    required this.cameraManager,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 根据平台返回不同的预览组件
    if (Platform.isAndroid) {
      return _buildAndroidPreview();
    } else if (Platform.isIOS) {
      return _buildIosPreview();
    } else if (Platform.isWindows) {
      return _buildWindowsPreview();
    } else if (Platform.isMacOS) {
      return _buildMacOSPreview();
    } else {
      // 不支持的平台显示一个占位符
      return Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: borderRadius,
        ),
        child: const Center(
          child: Text(
            '当前平台不支持相机预览',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }
  }

  /// 构建移动端(Android)预览
  Widget _buildAndroidPreview() {
    final controller = cameraManager.controller as CameraController?;
    print('[相机预览页面] [$runtimeType] 是否初始化${controller?.value.isInitialized}');

    if (controller == null || !controller.value.isInitialized) {
      return _buildInitializingPreview();
    }

    // 获取预览尺寸
    print('[相机预览页面] [$runtimeType] 宽: ${controller.value.previewSize!.width} '
        '高: ${controller.value.previewSize!.height} 宽高比${controller.value.aspectRatio}');

    return CameraPreview(controller);
  }

  // 构建移动端(iOS)预览
  Widget _buildIosPreview() {
    final controller = cameraManager.controller as CameraController?;
    if (controller == null || !controller.value.isInitialized) {
      return _buildInitializingPreview();
    }

    // 获取预览尺寸
    print('[相机预览页面] [$runtimeType] 宽: ${controller.value.previewSize!.width} '
        '高: ${controller.value.previewSize!.height} 宽高比${controller.value.aspectRatio}');

    return CameraPreview(controller);
  }

  /// 构建Windows平台预览
  Widget _buildWindowsPreview() {
    // Windows相机预览使用控制器中的预览控件
    final controller = cameraManager.controller;
    if (controller == null) {
      return _buildInitializingPreview();
    }

    // 默认相机尺寸
    final size = cameraManager.previewSize ?? const Size(640, 480);

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: SizedBox(
        width: size.width,
        height: size.height,
        // Windows相机预览在这里获取当前预览画面
        child: Container(
          color: Colors.black,
          child: const Center(child: Text('预览加载中...', style: TextStyle(color: Colors.white, fontSize: 18))),
        ),
      ),
    );
  }

  /// 构建macOS平台预览
  Widget _buildMacOSPreview() {
    // 检查相机是否初始化
    if (cameraManager.controller == null) {
      return _buildInitializingPreview();
    }

    // 获取MacOS相机尺寸
    final size = cameraManager.previewSize ?? const Size(640, 480);

    // 获取预览尺寸
    print('[相机预览页面] [$runtimeType] 宽: ${cameraManager.previewSize?.width} '
        '高: ${cameraManager.previewSize?.height} 宽高比${size.width / size.height}');

    return AdvanceCameraMacPreview(
      cameraMacOSController: cameraManager.controller,
      onFocusPointSet: (Offset focusPoint, Size previewSize) async {
        try {
          await cameraManager.setFocusPoint(focusPoint);
        } catch (e) {
          print(e);
        }
      },
    );
  }

  /// 构建初始化中的预览占位
  Widget _buildInitializingPreview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: SizedBox(
          width: 24.ww,
          height: 24.wh,
          child: const CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}
