import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/camera_courses_book_border_widget.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:wise_camera/photo_capture.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:image/image.dart' as img;

import '../../utils/utils.dart';

class CameraWindowsDialog {
  static Future<File?> show({
    required BuildContext context,
    bool isCoursesBook = false,
    bool isCoursesBookFront = false,
  }) async {
    List<CameraDescription> cameras = <CameraDescription>[];

    CameraDescription? cameraDescription;

    try {
      cameras = await CameraPlatform.instance.availableCameras();
      if (cameras.isEmpty) {
        ToastUtils.showToast(text: "未检测到可用的摄像头");
        return null;
      }
      if (cameras.length == 1) {
        cameraDescription = cameras.first;
      } else {
        CameraDevice? device = await CameraListWidgetManager.showUser(
          context: context,
          title: "选择摄像头",
          devices: cameras.map((e) => CameraDevice(name: e.name)).toList(),
        );
        if (device == null) return null;
        cameraDescription = cameras.firstWhere((e) => e.name == device.name);
      }
    } on PlatformException catch (_) {
      ToastUtils.showToast(text: "获取摄像头失败");
      return null;
    }

    return await showCupertinoDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return CameraWindowsWidget(
            cameraDescription: cameraDescription,
            isCoursesBook: isCoursesBook,
            isCoursesBookFront: isCoursesBookFront);
      },
    );
  }
}

class CameraWindowsWidget extends StatefulWidget {
  final CameraDescription? cameraDescription;
  final bool? isCoursesBook;
  final bool? isCoursesBookFront;

  const CameraWindowsWidget(
      {super.key,
      this.cameraDescription,
      this.isCoursesBook,
      this.isCoursesBookFront});

  @override
  State<CameraWindowsWidget> createState() => _CameraWindowsWidgetState();
}

class _CameraWindowsWidgetState extends State<CameraWindowsWidget> {
  int _cameraId = -1;
  bool _initialized = false;
  Size? _previewSize;
  final MediaSettings _mediaSettings = const MediaSettings(
    resolutionPreset: ResolutionPreset.max,
    enableAudio: false,
  );
  StreamSubscription<CameraErrorEvent>? _errorStreamSubscription;

  String? filePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _disposeCurrentCamera();
    _errorStreamSubscription?.cancel();
    _errorStreamSubscription = null;
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (widget.cameraDescription == null) return;

    int cameraId = -1;
    try {
      final CameraDescription camera = widget.cameraDescription!;

      cameraId = await CameraPlatform.instance.createCameraWithSettings(
        camera,
        _mediaSettings,
      );

      unawaited(_errorStreamSubscription?.cancel());
      _errorStreamSubscription = CameraPlatform.instance
          .onCameraError(cameraId)
          .listen(_onCameraError);

      final Future<CameraInitializedEvent> initialized =
          CameraPlatform.instance.onCameraInitialized(cameraId).first;

      await CameraPlatform.instance.initializeCamera(
        cameraId,
      );

      final CameraInitializedEvent event = await initialized;
      _previewSize = Size(
        event.previewWidth,
        event.previewHeight,
      );

      if (mounted) {
        setState(() {
          _initialized = true;
          _cameraId = cameraId;
        });
      }
    } on CameraException catch (_) {
      try {
        if (cameraId >= 0) {
          await CameraPlatform.instance.dispose(cameraId);
        }
      } on CameraException catch (_) {}

      // Reset state.
      if (mounted) {
        setState(() {
          _initialized = false;
          _cameraId = -1;
          _previewSize = null;
        });
      }
    }
  }

  Future<void> _disposeCurrentCamera() async {
    if (_cameraId >= 0 && _initialized) {
      try {
        await CameraPlatform.instance.dispose(_cameraId);

        if (mounted) {
          setState(() {
            _initialized = false;
            _cameraId = -1;
            _previewSize = null;
          });
        }
      } on CameraException catch (_) {}
    }
  }

  void _onCameraError(CameraErrorEvent event) {
    if (mounted) {
      _disposeCurrentCamera();
    }
  }

  Future<void> _takePicture() async {
    final XFile file = await CameraPlatform.instance.takePicture(_cameraId);

    filePath = file.path;
    //_disposeCurrentCamera();
    if (mounted) setState(() {});
  }

  Future<File?> flipHorizontal(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return null;
    final flip = img.flipHorizontal(image);
    final flipBytes = img.encodeJpg(flip);
    return File(file.path).writeAsBytes(flipBytes);
  }

  @override
  Widget build(BuildContext context) {
    Widget buildCameraView() {
      if (filePath != null) {
        return Image.file(
          File(filePath!),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
        );
      }
      if (_initialized && _cameraId > 0 && _previewSize != null) {
        return Transform.flip(
          flipX: true,
          child: CameraPlatform.instance.buildPreview(_cameraId),
        );
      }
      return Container();
    }

    return Material(
      color: AppTheme.cBgPrimary,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              child: buildCameraView(),
            ),
            Visibility(
              visible: filePath == null && widget.isCoursesBook == true,
              child: CameraCoursesBookBorderWidget(
                  isCoursesBookFront: widget.isCoursesBookFront ?? false),
            ),
            Visibility(
              visible: filePath == null && widget.isCoursesBook == true,
              child: Positioned(
                right: 60.wMin,
                child: TapScaleWidget(
                  onTap: () async {
                    _takePicture();
                  },
                  sclae: 1.1,
                  child: SvgPicture.asset(
                    "assets/svg/custom_course/icon_course_photo.svg",
                    width: 50.wMin,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: filePath == null && widget.isCoursesBook == true,
              child: Positioned(
                left: 40.wMin,
                top: 40.wMin,
                child: TapScaleWidget(
                  onTap: () => Get.back(),
                  sclae: 1.1,
                  child: SvgPicture.asset(
                    "assets/svg/custom_course/icon_course_back.svg",
                    width: 50.wMin,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: filePath != null && widget.isCoursesBook == true,
              child: Positioned(
                left: 40.wMin,
                bottom: 50.wMin,
                child: TapScaleWidget(
                  onTap: () {
                    filePath = null;
                    if (mounted) setState(() {});
                  },
                  sclae: 1.1,
                  child: Container(
                    width: 176.wMin,
                    height: 72.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.08),
                      borderRadius: BorderRadius.circular(12.wMin),
                    ),
                    child: Text(
                      '重拍',
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: const Color.fromRGBO(56, 189, 248, 1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: filePath != null && widget.isCoursesBook == true,
              child: Positioned(
                right: 40.wMin,
                bottom: 50.wMin,
                child: TapScaleWidget(
                  onTap: () {
                    if (filePath == null) return;
                    _disposeCurrentCamera();
                    Get.back(result: File(filePath!));
                  },
                  sclae: 1.1,
                  child: Container(
                    width: 176.wMin,
                    height: 72.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(56, 189, 248, 1),
                      borderRadius: BorderRadius.circular(12.wMin),
                    ),
                    child: Text(
                      '确认保存',
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: filePath == null && widget.isCoursesBook == false,
              child: Positioned(
                bottom: 20.wMin,
                child: TapScaleWidget(
                  onTap: () async {
                    _takePicture();
                  },
                  sclae: 0.9,
                  child: Container(
                    width: 120.wMin,
                    height: 120.wMin,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cStaticWhite,
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: filePath != null && widget.isCoursesBook == false,
              child: Positioned(
                bottom: 80.wMin,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    TapScaleWidget(
                      onTap: () {
                        filePath = null;
                        if (mounted) setState(() {});
                      },
                      sclae: 1.1,
                      child: Container(
                        width: 60.wMin,
                        height: 60.wMin,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.cSurfaceTertiary,
                        ),
                        child: SvgPicture.asset(
                          "assets/svg/public/icon_clean.svg",
                          width: 48.wMin,
                        ),
                      ),
                    ),
                    SizedBox(width: 120.wMin),
                    TapScaleWidget(
                      onTap: () {
                        if (filePath == null) return;
                        _disposeCurrentCamera();
                        Get.back(result: File(filePath!));
                      },
                      sclae: 1.1,
                      child: Container(
                        width: 60.wMin,
                        height: 60.wMin,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.cSurfaceTertiary,
                        ),
                        child: SvgPicture.asset(
                          "assets/svg/public/icon_check.svg",
                          width: 48.wMin,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: filePath == null && widget.isCoursesBook == false,
              child: Positioned(
                left: 40.wMin,
                top: 20.wMin,
                child: TapScaleWidget(
                  onTap: () => Get.back(),
                  sclae: 1.1,
                  child: Container(
                    width: 60.wMin,
                    height: 60.wMin,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cSurfaceTertiary,
                    ),
                    child: SvgPicture.asset(
                      "assets/svg/public/icon_back.svg",
                      width: 48.wMin,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
