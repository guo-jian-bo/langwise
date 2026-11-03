import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:quiz_play/component/tap_scale_widget.dart';
import 'package:wise_camera/photo_capture.dart';
import 'package:wise_camera/wise_camera_platform_interface.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'camera_dotted_line_Painter.dart';
import 'photo_edit_page.dart';

class MacosCameraManager {
  static Future<bool?>? show({required BuildContext context, final Function(ui.Image, ui.Image)? onContinueTap}) {
    return Get.dialog<bool?>(
      MacosCameraWidget(
        onContinueTap: onContinueTap,
      ),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    ).then((value) {
      print('---扫描/相机弹框消失,value:$value---');
      return value;
    });
  }
}

class MacosCameraWidget extends StatefulWidget {
  const MacosCameraWidget({
    this.onPhotoError = _onPhotoErrorHandler,
    this.fit = BoxFit.cover,
    this.overlayBuilder,
    this.onContinueTap,
    this.placeholderBuilder,
    super.key,
  });

  final void Function(Object error, StackTrace stackTrace) onPhotoError;

  final BoxFit fit;

  final LayoutWidgetBuilder? overlayBuilder;

  final Function(ui.Image, ui.Image)? onContinueTap;

  final Widget Function(BuildContext, Widget?)? placeholderBuilder;

  @override
  State<MacosCameraWidget> createState() => _MacosCameraWidgetState();

  static void _onPhotoErrorHandler(Object error, StackTrace stackTrace) {
    // Do nothing.
  }
}

class _MacosCameraWidgetState extends State<MacosCameraWidget> with WidgetsBindingObserver, SafeSetStateMixin {
  StreamSubscription<PhotoCapture?>? _photosSubscription;

  PhotoCapture? _photo;

  String? get _filePath => _photo?.filePath;

  bool get hasFilePath => _filePath != null && _filePath!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    CameraUtil().camera?.start(deviceId: CameraUtil().deviceId).then((value) {
      print('---开始CameraWidget，value: $value---');
      safeSetState(() {});
    }).catchError((e) {
      print('---CameraWidget，e: $e---');
      if (e is PlatformException) {
        ToastUtils.showManageToast(text: "未连接到相机");
      } else {
        ToastUtils.showManageToast(text: e.toString());
      }

      CameraUtil().dispose();
      Get.back();
    }).whenComplete(() {
      safeSetState(() {});
    });

    _setupListeners();
  }

  void _setupListeners() {
    _photosSubscription = WiseCameraPlatform.instance.photosStream.listen(
      (PhotoCapture? photo) {
        print('---接收拍摄的照片:${photo?.filePath}---');
        _photo = photo;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PhotoEditPage(
              filePath: photo?.filePath,
              onContinueTap: (ui.Image v1, ui.Image v2) {
                if (hasFilePath) {
                  File(_filePath!).deleteSync();
                  print('删除原图成功:$_filePath');
                }
                _photo = null;
                widget.onContinueTap?.call(v1, v2);
              },
              onCancelTap: () {
                if (hasFilePath) {
                  File(_filePath!).deleteSync();
                  debugPrint('删除原图成功:$_filePath');
                }
                _photo = null;
                Get.back(result: true);
              },
            ),
          ),
        );
      },
      onError: (Object error) {
        safeSetState(() {});
      },
      cancelOnError: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('---CameraWidget, textureId: ${WiseCameraPlatform.instance.textureId ?? 0}---');
    if ((WiseCameraPlatform.instance.textureId ?? 0) == 0) {
      return const SizedBox();
    }

    return Material(
      color: Colors.transparent,
      child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xff040712).withValues(alpha: 0.8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                // width: MediaQuery.of(context).size.width - 100,
                // height: MediaQuery.of(context).size.height - 100,
                child: WiseCameraPlatform.instance.buildCameraView(),
              ),
              Positioned(
                  bottom: 70.wh,
                  right: 340.ww,
                  child: TapScaleWidget(
                    onTap: OptimizeUtils.noneThrottle(() {
                      CameraUtil().dispose();
                      Get.back(result: true);
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
                  right: 241.ww,
                  child: TapScaleWidget(
                    onTap: OptimizeUtils.noneThrottle(() {
                      CameraUtil().camera?.takePhoto();
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
              Positioned(
                  top: 0,
                  bottom: 0,
                  child: CustomPaint(
                    painter: CameraDottedLinePainter(0, MediaQuery.of(context).size.height, 0.5),
                  ))
            ],
          )),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _photosSubscription?.cancel();
    _photosSubscription = null;
    CameraUtil().dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
