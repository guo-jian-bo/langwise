import 'dart:io';
import 'package:camera_macos/camera_macos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/camera_courses_book_border_widget.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:wise_camera/photo_capture.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';

class CameraMacosDialog {
  static Future<File?> show({
    required BuildContext context,
    bool isCoursesBook = false,
    bool isCoursesBookFront = false,
  }) async {
    String? deviceId = await selectCamera(context: context);
    if(deviceId == null) return null;
    CameraUtil().deviceId = deviceId;

    return await showCupertinoDialog<File?>(
      context: context,
      builder: (context) => CameraMacosWidget(
          deviceId: CameraUtil().deviceId,
          isCoursesBook: isCoursesBook,
          isCoursesBookFront: isCoursesBookFront),
    );
  }


  /// 选择摄像头
  static Future<String?> selectCamera({
    required BuildContext context,
  }) async {
    List<CameraMacOSDevice> videoDevices = await CameraMacOS.instance.listDevices(deviceType: CameraMacOSDeviceType.video);
    if (videoDevices.isEmpty) {
      ToastUtils.showToast(text: "未检测到可用的摄像头");
      return null;
    }

    if (videoDevices.length == 1) {
      return videoDevices.first.deviceId;
    }

    final CameraDevice? device = await CameraListWidgetManager.showUser(
      context: context,
      title: "选择摄像头",
      devices: videoDevices.map((e) => CameraDevice(
        id: e.deviceId,
        name: e.localizedName,
        position: e.manufacturer,
      )).toList(),
    );
    if (device == null) return null;
    if (device.id == null) return null;
    return device.id;
  }


}

class CameraMacosWidget extends StatefulWidget {
  final String? deviceId;
  final bool? isCoursesBook;
  final bool? isCoursesBookFront;

  const CameraMacosWidget(
      {super.key, this.deviceId, this.isCoursesBook, this.isCoursesBookFront});

  @override
  State<CameraMacosWidget> createState() => _CameraMacosWidgetState();
}

class _CameraMacosWidgetState extends State<CameraMacosWidget> {
  CameraMacOSController? macOSController;

  String? filePath;

  @override
  void dispose() {
    macOSController?.destroy();
    super.dispose();
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
                ? SizedBox.expand(
                  child: CameraMacOSView(
                      cameraMode: CameraMacOSMode.photo,
                      enableAudio: false,
                      deviceId: widget.deviceId,
                      resolution: PictureResolution.max,
                      pictureFormat: PictureFormat.jpg,
                      onCameraInizialized: (CameraMacOSController controller) {
                        macOSController = controller;
                      },
                      isVideoMirrored: false,
                    ),
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
              right: 60.wMin,
              child: TapScaleWidget(
                onTap: () async {
                  CameraMacOSFile? file =
                      await macOSController?.takePicture();
                  if (file == null) return;
                  if (file.bytes == null) return;
                  final tempDir =
                      await Directory.systemTemp.createTemp('take_image');
                  final tempFile = File('${tempDir.path}/take_image.png');
                  await tempFile.writeAsBytes(file.bytes!);
                  filePath = tempFile.path;
                  macOSController?.destroy();
                  if (mounted) setState(() {});
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
                  CameraMacOSFile? file =
                      await macOSController?.takePicture();
                  if (file == null) return;
                  if (file.bytes == null) return;
                  final tempDir =
                      await Directory.systemTemp.createTemp('take_image');
                  final tempFile = File('${tempDir.path}/take_image.png');
                  await tempFile.writeAsBytes(file.bytes!);
                  filePath = tempFile.path;
                  macOSController?.destroy();
                  if (mounted) setState(() {});
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
          )
        ],
      ),
    );
  }
}
