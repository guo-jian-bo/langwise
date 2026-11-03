import 'dart:io';
import 'package:camera_macos/camera_macos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/customized_courses/custom_course_shoot_words/controllers/custom_course_shoot_words_controller.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:wise_camera/photo_capture.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class CameraMacOSCustomCurseDialog {
  static Future<String?> show({
    required BuildContext context,
  }) async {
    List<CameraMacOSDevice> videoDevices = await CameraMacOS.instance
        .listDevices(deviceType: CameraMacOSDeviceType.video);
    if (videoDevices.isEmpty) {
      ToastUtils.showToast(text: "未检测到可用的摄像头");
      return null;
    }

    if (videoDevices.length == 1) {
      return videoDevices[0].deviceId;
    } else {
      CameraDevice? device = await CameraListWidgetManager.showUser(
        context: context,
        title: "选择摄像头",
        devices: videoDevices
            .map((e) => CameraDevice(
                  id: e.deviceId,
                  name: e.localizedName,
                  position: e.manufacturer,
                ))
            .toList(),
      );
      if (device == null) return null;
      if (device.id == null) return null;
      return device.id;
    }
  }
}

class CameraMacOSCustomCurseWidget extends StatefulWidget {
  final String tagText;
  final String? deviceId;
  final int? moduleId;
  const CameraMacOSCustomCurseWidget({
    super.key,
    required this.tagText,
    this.deviceId,
    this.moduleId,
  });

  @override
  State<CameraMacOSCustomCurseWidget> createState() =>
      _CameraMacOSCustomCurseWidgetState();
}

class _CameraMacOSCustomCurseWidgetState
    extends State<CameraMacOSCustomCurseWidget> {
  //摄像头控制器
  CameraMacOSController? macOSController;

  //裁剪控制器
  final CropController cropController = CropController();
  //拍摄好还未裁剪的图片数据
  Uint8List? imageData;

  //裁剪后的图片数据
  Uint8List? leftImageBytes;
  Uint8List? rightImageBytes;

  //结束拍摄
  bool isFinish = false;

  //是否弹出过提示框
  bool isShowTipPop = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    macOSController?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String tip1 = '请将蓝色辅助线对准书本的中缝，确保两页内容都清晰完整。';
    String tip2 = '请将中心蓝线对准书本中缝，然后拖拽四个圆点，使选框正好框住书页。';

    return Material(
      color: AppTheme.cBgPrimary,
      child: Stack(
        children: [
          imageData == null ? _photoWidget() : _cropPhotoWidget(),
          Positioned(
            top: 20.wMin,
            right: 20.wMin,
            child: Row(
              children: [
                Text(
                  imageData == null ? tip1 : tip2,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextPrimary,
                  ),
                ),
                SvgPicture.asset(
                  "assets/svg/custom_course/icon_course_tip.svg",
                  width: 26.wMin,
                  height: 26.wMin,
                  colorFilter: ColorFilter.mode(
                    AppTheme.cTextPrimary.color,
                    BlendMode.srcIn,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoWidget() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
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
        ),
        Positioned(
          left: 40.wMin,
          top: 40.wMin,
          child: TapScaleWidget(
            onTap: () {
              final controller = Get.find<CustomCourseShootWordsController>(tag: widget.tagText);
              if (!controller.isShownTip.value) {
                return;
              }
              controller.back();
            },
            sclae: 1.1,
            child: SvgPicture.asset(
              "assets/svg/custom_course/icon_course_back.svg",
              width: 60.wMin,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10.0.wMin),
          child: Center(
            child: SizedBox(
              width: 4.wMin,
              height: double.infinity,
              child: CustomPaint(
                painter: DashedLinePainter(
                  color: AppTheme.cTextBrand,
                  strokeWidth: 2.wMin,
                  dashLength: 8.wMin,
                  gapLength: 6.wMin,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 60.wMin,
          child: TapScaleWidget(
            onTap: () async {
              final controller = Get.find<CustomCourseShootWordsController>(tag: widget.tagText);
              if (!controller.isShownTip.value) {
                return;
              }

              CameraMacOSFile? file = await macOSController?.takePicture();
              if (file == null) return;
              imageData = file.bytes;
              macOSController?.destroy();
              if (mounted) setState(() {});
            },
            sclae: 1.1,
            child: SvgPicture.asset(
              "assets/svg/custom_course/icon_course_photo.svg",
              width: 70.wMin,
            ),
          ),
        ),
      ],
    );
  }

  Widget _cropPhotoWidget() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TapScaleWidget(
                onTap: () {
                  final controller = Get.find<CustomCourseShootWordsController>(tag: widget.tagText);
                  controller.back();
                },
                sclae: 1.1,
                child: SvgPicture.asset(
                  "assets/svg/custom_course/icon_course_back.svg",
                  width: 60.wMin,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 200.wMin, right: 200.wMin),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _cropWidget(),
                    Padding(
                      padding: EdgeInsets.all(10.0.wMin),
                      child: Center(
                        child: SizedBox(
                          width: 4.wMin,
                          height: double.infinity,
                          child: CustomPaint(
                            painter: DashedLinePainter(
                              color: AppTheme.cTextBrand,
                              strokeWidth: 2.wMin,
                              dashLength: 8.wMin,
                              gapLength: 6.wMin,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 152.wMin,
              color: AppTheme.cBgPrimary,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TapScaleWidget(
                      onTap: () {
                        imageData = null;
                        if (mounted) setState(() {});
                      },
                      sclae: 1.1,
                      child: Container(
                        width: 176.wMin,
                        height: 72.wMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.cBgQuaternary,
                          borderRadius: BorderRadius.circular(12.wMin),
                        ),
                        child: Text(
                          '重拍这张',
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cFeedbackErrorBorder,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        TapScaleWidget(
                          onTap: () {
                            isFinish = true;
                            cropController.crop();
                          },
                          sclae: 1.1,
                          child: Container(
                            width: 176.wMin,
                            height: 72.wMin,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppTheme.cBgQuaternary,
                              borderRadius: BorderRadius.circular(12.wMin),
                            ),
                            child: Text(
                              '已拍完',
                              style: TextStyle(
                                fontSize: 24.wMin,
                                color: AppTheme.cTextBrand,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 15.wMin,
                        ),
                        TapScaleWidget(
                          onTap: () {
                            cropController.crop();
                          },
                          sclae: 1.1,
                          child: Container(
                            width: 176.wMin,
                            height: 72.wMin,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppTheme.cTextBrand,
                              borderRadius: BorderRadius.circular(12.wMin),
                            ),
                            child: Text(
                              '继续添加',
                              style: TextStyle(
                                fontSize: 24.wMin,
                                color: AppTheme.cTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _cropWidget() {
    return LayoutBuilder(builder: (context, constraints) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Crop(
          key: ValueKey(
              'crop_${constraints.maxWidth.toInt()}_${constraints.maxHeight.toInt()}'),
          image: imageData!,
          clipBehavior: Clip.none,
          controller: cropController,
          interactive: true,
          baseColor: Colors.transparent,
          maskColor: AppTheme.cOverlayBackground,
          filterQuality: FilterQuality.high,
          fixCropRect: false,
          initialRectBuilder: InitialRectBuilder.withSizeAndRatio(
            size: 1,
            aspectRatio: 4 / 3,
          ),
          progressIndicator: Center(
            child: SpinKitFadingCircle(
              color: AppTheme.cBgBrand,
              size: 100.wMin,
            ),
          ),
          onStatusChanged: (value) {
            if (value == CropStatus.cropping) {
              ToastUtils.showLoading();
            }
          },
          onCropped: (result) async {
            if (result is CropSuccess) {
              try {
                Uint8List cropData = result.croppedImage;

                // 使用image库解码图片
                final img.Image? originalImage = img.decodeImage(cropData);

                if (originalImage != null) {
                  final int width = originalImage.width;
                  final int height = originalImage.height;
                  final int halfWidth = width ~/ 2;

                  // 创建左半部分图像
                  final img.Image leftImage = img.copyCrop(
                    originalImage,
                    x: 0,
                    y: 0,
                    width: halfWidth,
                    height: height,
                  );

                  // 创建右半部分图像
                  final img.Image rightImage = img.copyCrop(
                    originalImage,
                    x: halfWidth,
                    y: 0,
                    width: width - halfWidth,
                    height: height,
                  );

                  // 将裁剪后的图片保存为临时文件
                  final Uint8List leftBytes =
                      Uint8List.fromList(img.encodePng(leftImage));
                  final Uint8List rightBytes =
                      Uint8List.fromList(img.encodePng(rightImage));

                  final tempDir =
                      await Directory.systemTemp.createTemp('crop_image');
                  final leftTempFile = File(
                      '${tempDir.path}/cropped_image${DateTime.now().millisecondsSinceEpoch.toString()}.jpg');
                  await leftTempFile.writeAsBytes(leftBytes);
                  Get.find<CustomCourseShootWordsController>(tag: widget.tagText).addImage(leftTempFile.path);

                  final rightTempFile = File(
                      '${tempDir.path}/cropped_image${DateTime.now().millisecondsSinceEpoch.toString()}.jpg');
                  await rightTempFile.writeAsBytes(rightBytes);
                  Get.find<CustomCourseShootWordsController>(tag: widget.tagText).addImage(rightTempFile.path);

                  imageData = null;
                  if (isFinish) {
                    //结束拍摄
                    Get.find<CustomCourseShootWordsController>(tag: widget.tagText).navigateToManagePhotos();
                  } else {
                    //继续拍摄
                    if (mounted) setState(() {});
                  }
                }
              } finally {
                ToastUtils.hideLoading();
              }
            } else if (result is CropFailure) {
              ToastUtils.hideLoading();
              ToastUtils.showToast(text: "裁剪失败");
            }
          },
        ),
      );
    });
  }
}

//虚线
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashLength),
        paint,
      );
      startY += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
