import 'package:camera_macos/camera_macos.dart';
import 'package:camera_macos/camera_macos_method_channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 高级macOS相机预览组件
///
/// 与普通CameraMacOSView不同，此组件不在initState中初始化相机
/// 而是依赖外部传入已初始化的相机控制器
class AdvanceCameraMacPreview extends StatefulWidget {
  /// 相机控制器，必须在外部通过MacOSCameraImplementation初始化
  final CameraMacOSController cameraMacOSController;

  /// 适配模式
  final BoxFit fit;

  /// 是否使用平台视图
  final bool usePlatformView;

  /// 相机就绪回调
  final Function(CameraMacOSController)? onCameraReady;

  /// 相机加载中组件构建器
  final Widget Function(Object? error)? onCameraLoading;

  /// 相机销毁时组件构建器
  final Widget Function()? onCameraDestroyed;

  /// 点击屏幕设置对焦点时的回调
  final Function(Offset focusPoint, Size previewSize)? onFocusPointSet;

  const AdvanceCameraMacPreview({
    Key? key,
    required this.cameraMacOSController,
    this.fit = BoxFit.contain,
    this.usePlatformView = false,
    this.onCameraReady,
    this.onCameraLoading,
    this.onCameraDestroyed,
    this.onFocusPointSet,
  }) : super(key: key);

  @override
  State<AdvanceCameraMacPreview> createState() => _AdvanceCameraMacPreviewState();
}

class _AdvanceCameraMacPreviewState extends State<AdvanceCameraMacPreview> {
  /// 存储相机参数
  CameraMacOSArguments? _cameraArgs;

  @override
  void initState() {
    super.initState();

    // 获取相机参数而不是初始化相机
    _cameraArgs = widget.cameraMacOSController.args;

    // 如果传入了相机就绪回调，调用它
    if (widget.onCameraReady != null) {
      widget.onCameraReady!(widget.cameraMacOSController);
    }
  }

  @override
  Widget build(BuildContext context) {
    /// 构建相机预览界面
    // 检查相机是否初始化
    if (_cameraArgs?.textureId == null) {
      return Container();
    }

    // 检查相机是否被销毁
    if (CameraMacOSPlatform.instance is MethodChannelCameraMacOS &&
        (CameraMacOSPlatform.instance as MethodChannelCameraMacOS).isDestroyed) {
      if (widget.onCameraDestroyed != null) {
        return widget.onCameraDestroyed!();
      } else {
        return Container();
      }
    }

    // 获取相机尺寸
    double cameraWidth = _cameraArgs!.size.width;
    double cameraHeight = _cameraArgs!.size.height;

    // 创建平台视图参数
    final Map<String, dynamic> creationParams = <String, dynamic>{
      "width": cameraWidth,
      "height": cameraHeight,
    };

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: FittedBox(
        fit: widget.fit,
        child: SizedBox(
          width: cameraWidth,
          height: cameraHeight,
          child: GestureDetector(
              onTapUp: (details) => _setFocusPoint(
                    details,
                    cameraWidth,
                    cameraHeight,
                  ),
              child: widget.usePlatformView
                  ? UiKitView(
                      viewType: "camera_macos_view",
                      onPlatformViewCreated: (id) {
                        debugPrint("相机平台视图创建完成，ID: $id");
                      },
                      creationParams: creationParams,
                      creationParamsCodec: const StandardMessageCodec(),
                    )
                  : Texture(
                      textureId: _cameraArgs!.textureId!,
                    )),
        ),
      ),
    );
  }

  /// 根据点击位置设置相机对焦点
  void _setFocusPoint(
    TapUpDetails details,
    double cameraWidth,
    double cameraHeight,
  ) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    // 计算相对位置
    final double dx = details.localPosition.dx / size.width;
    final double dy = details.localPosition.dy / size.height;

    // 将相对位置转换为预览尺寸上的位置
    final Offset focusPoint = Offset(dx * cameraWidth, dy * cameraHeight);
    final Size previewSize = Size(cameraWidth, cameraHeight);

    // 调用外部对焦点设置回调
    if (widget.onFocusPointSet != null) {
      widget.onFocusPointSet!(focusPoint, previewSize);
    }
  }

  @override
  void didUpdateWidget(AdvanceCameraMacPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果控制器不同，更新相机参数
    if (oldWidget.cameraMacOSController != widget.cameraMacOSController) {
      _cameraArgs = widget.cameraMacOSController.args;
      if (mounted) {
        setState(() {});
      }
    }
  }
}
