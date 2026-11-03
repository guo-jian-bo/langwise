import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiz_play/component/tap_scale_widget.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'camera_dotted_line_Painter.dart';
import 'photo_edit_page.dart';

class MobileCameraManager {
  static Future<bool?>? show({required BuildContext context, final Function(ui.Image, ui.Image)? onContinueTap}) {
    return showDialog<bool?>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (BuildContext c) {
          return MobileCameraWidget(
            onContinueTap: onContinueTap,
          );
        }).then((value) {
      print('---移动端相机页面关闭，照片路径: $value---');
      return value;
    });
    // return Get.dialog<bool?>(
    //   MobileCameraWidget(
    //     onContinueTap: onContinueTap,
    //   ),
    //   barrierDismissible: false,
    //   barrierColor: Colors.transparent,
    // ).then((value) {
    //   print('---相机页面关闭，照片路径: $value---');
    //   return value;
    // });
  }
}

class MobileCameraWidget extends StatefulWidget {
  final Function(ui.Image, ui.Image)? onContinueTap;

  const MobileCameraWidget({super.key, this.onContinueTap});

  @override
  State<MobileCameraWidget> createState() => _MobileCameraWidgetState();
}

class _MobileCameraWidgetState extends State<MobileCameraWidget> with WidgetsBindingObserver, SafeSetStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 应用生命周期变化时处理相机
    final CameraController? cameraController = _cameraController;

    // 应用进入后台
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      // 获取可用相机列表
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        ToastUtils.showManageToast(text: '未检测到可用的相机');
        return;
      }

      // 默认使用后置相机
      CameraDescription camera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      // 初始化相机控制器
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      safeSetState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('相机初始化错误: $e');
      ToastUtils.showManageToast(text: '相机初始化失败');
    }
  }

  Future<void> _takePicture() async {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized || _isTakingPicture) {
      return;
    }

    try {
      safeSetState(() {
        _isTakingPicture = true;
      });

      // 拍照
      final XFile file = await cameraController.takePicture();

      // 创建临时文件保存
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final directory = await getApplicationSupportDirectory();
      final String filePath = '${directory.path}/image_$timestamp.jpg';

      // 复制图片到应用目录
      await File(file.path).copy(filePath);

      // 获取拍摄的图片并进入编辑页面
      _openPhotoEditPage(filePath);
    } catch (e) {
      print('拍照错误: $e');
      ToastUtils.showManageToast(text: '拍照失败');
    } finally {
      safeSetState(() {
        _isTakingPicture = false;
      });
    }
  }

  // 打开图片编辑页面
  void _openPhotoEditPage(String filePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhotoEditPage(
          filePath: filePath,
          onContinueTap: (ui.Image v1, ui.Image v2) {
            // 删除原始文件
            try {
              File(filePath).deleteSync();
              print('删除原图成功: $filePath');
            } catch (e) {
              print('删除原图失败: $e');
            }

            widget.onContinueTap?.call(v1, v2);
          },
          onCancelTap: () {
            // 删除原始文件
            try {
              File(filePath).deleteSync();
              print('删除原图成功: $filePath');
            } catch (e) {
              print('删除原图失败: $e');
            }

            Get.back(result: true);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xff040712).withOpacity(0.8),
        child: Stack(
          children: [
            // 相机预览
            _isInitialized
                ? _buildCameraPreview()
                : const Center(
                    child: CircularProgressIndicator(),
                  ),

            // 取消按钮
            Positioned(
              bottom: 70.wh,
              right: 340.ww,
              child: TapScaleWidget(
                onTap: OptimizeUtils.noneThrottle(() {
                  Get.back(result: true);
                }, 300),
                child: Container(
                  width: 80.ww,
                  height: 40.wh,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xff040712).withOpacity(0.8),
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
              ),
            ),

            // 拍照按钮
            Positioned(
              bottom: 70.wh,
              right: 241.ww,
              child: TapScaleWidget(
                onTap: OptimizeUtils.noneThrottle(() {
                  if (!_isTakingPicture) {
                    _takePicture();
                  }
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
              ),
            ),

            Positioned(
                top: 0,
                bottom: 0,
                child: CustomPaint(
                  painter: CameraDottedLinePainter(0, MediaQuery.of(context).size.height, 0.5),
                ))
          ],
        ),
      ),
    );
  }

  // 构建相机预览，保持宽高比并拖转设备方向
  Widget _buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // 获取相机传感器信息
    final CameraValue cameraValue = _cameraController!.value;

    // 获取屏幕尺寸和方向
    final Size screenSize = MediaQuery.of(context).size;
    final Orientation orientation = MediaQuery.of(context).orientation;

    // 根据屏幕方向计算宽高比
    final Size previewSize = cameraValue.previewSize!;

    print("相机原始尺寸: $previewSize");
    print("当前设备方向: $orientation");

    // 根据设备方向计算正确的相机预览宽高比
    double aspectRatio;
    if (orientation == Orientation.portrait) {
      // 竖屏模式，需要交换宽高
      aspectRatio = previewSize.width / previewSize.height;
      print("竖屏模式宽高比: $aspectRatio");
    } else {
      // 横屏模式，使用原始宽高比
      aspectRatio = previewSize.height / previewSize.width;
      print("横屏模式宽高比: $aspectRatio");
    }

    // 计算适合的尺寸，确保相机预览填满可用空间
    double width, height;
    if (orientation == Orientation.portrait) {
      // 竖屏模式
      width = screenSize.width;
      height = screenSize.width / aspectRatio;
    } else {
      // 横屏模式
      height = screenSize.height;
      width = screenSize.height * aspectRatio;
    }

    print("计算的预览尺寸: 宽=$width, 高=$height");

    // 构建相机预览
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.wMin),
        child: SizedBox(
          width: width,
          height: height,
          child: CameraPreview(_cameraController!),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }
}
