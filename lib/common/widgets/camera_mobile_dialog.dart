import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/camera_courses_book_border_widget.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class CameraMobileWidget extends StatefulWidget {
  final bool? isCoursesBook;
  final bool? isCoursesBookFront;
  const CameraMobileWidget({
    super.key,
    this.isCoursesBook,
    this.isCoursesBookFront,
  });

  @override
  State<CameraMobileWidget> createState() => _CameraMobileWidgetState();
}

class _CameraMobileWidgetState extends State<CameraMobileWidget> {
  CameraController? _controller;
  String? filePath;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.max,
      enableAudio: false,
    );
    _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);
    _controller!.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cBgPrimary,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: filePath == null
                ? (_controller != null && _controller!.value.isInitialized)
                    ? CameraPreview(_controller!)
                    : const Center(
                        child: CircularProgressIndicator(),
                      )
                : Image.file(
                    File(filePath!),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                  ),
          ),
          Visibility(
            visible: filePath == null && widget.isCoursesBook == true,
            child: CameraCoursesBookBorderWidget(
                isCoursesBookFront: widget.isCoursesBookFront ?? false),
          ),
          Visibility(
            visible: filePath == null && widget.isCoursesBook == true,
            child: Positioned(
              bottom: 60.wMin,
              child: TapScaleWidget(
                onTap: () async {
                  if (_controller == null) return;
                  final file = await _controller!.takePicture();
                  filePath = file.path;
                  if (mounted) setState(() {});
                },
                sclae: 1.1,
                child: SvgPicture.asset(
                  "assets/svg/custom_course/icon_course_photo.svg",
                  width: 100.wMin,
                ),
              ),
            ),
          ),
          Visibility(
            visible: filePath == null && widget.isCoursesBook == true,
            child: Positioned(
              left: 50.wMin,
              top: 50.wMin,
              child: TapScaleWidget(
                onTap: () => Get.back(),
                sclae: 1.1,
                child: SvgPicture.asset(
                  "assets/svg/custom_course/icon_course_back.svg",
                  width: 80.wMin,
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller?.dispose();
    super.dispose();
  }
}
