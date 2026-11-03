import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../utils/utils.dart';

class ShowCropDialog {
  static Future<File?> show({
    required BuildContext context,
    required String imageFilePath,
    double? cropAspectRatio,
    bool withCircleUi = false,
    bool isCoursesBook = false,
  }) async {
    File? res = await showCupertinoDialog(
      context: context,
      builder: (context) {
        return ShowCropDialogWidget(
          isCoursesBook: isCoursesBook,
          imageFilePath: imageFilePath,
          withCircleUi: withCircleUi,
          cropAspectRatio: cropAspectRatio,
        );
      },
    );
    return res;
  }
}

class ShowCropDialogWidget extends StatefulWidget {
  final bool isCoursesBook;
  final String imageFilePath;
  final double? cropAspectRatio;
  final bool withCircleUi;
  const ShowCropDialogWidget({
    super.key,
    required this.isCoursesBook,
    required this.imageFilePath,
    this.cropAspectRatio,
    this.withCircleUi = false,
  });

  @override
  State<ShowCropDialogWidget> createState() => _ShowCropDialogWidgetState();
}

class _ShowCropDialogWidgetState extends State<ShowCropDialogWidget> {
  final CropController cropController = CropController();
  Uint8List? imageData;
  bool _isInitScale = true;

  bool hideWidget = false;

  @override
  void initState() {
    super.initState();
    File(widget.imageFilePath).readAsBytes().then((val) {
      imageData = val;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Column(
        children: [
          SizedBox(
              height: MediaQuery.of(context).padding.top + 64.wMin,
              width: double.infinity),
          Expanded(
            child: buildCropWidget(),
          ),
          SizedBox(height: 24.wMin),
          Row(
            spacing: 56.wMin,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonWidget(
                text: "取消",
                height: 64.wMin,
                width: 240.wMin,
                borderRadius: 12.wMin,
                color: AppTheme.cBgTertiary,
                fontColor: AppTheme.cTextBrand,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
                sclae: 1.05,
                onTap: () {
                  hideWidget = true;
                  if (mounted) setState(() {});
                  Get.back();
                },
              ),
              ButtonWidget(
                text: "确定",
                height: 64.wMin,
                width: 240.wMin,
                borderRadius: 12.wMin,
                color: AppTheme.cSurfaceBrand,
                fontColor: AppTheme.cStaticWhite,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
                sclae: 1.05,
                onTap: () {
                  cropController.crop();
                },
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 64.wMin),
        ],
      ),
    );
  }

  Widget buildCropWidget() {
    if (hideWidget) return Container();
    if (imageData == null) {
      return Center(
        child: SpinKitFadingCircle(
          color: AppTheme.cBgBrand,
          size: 100.wMin,
        ),
      );
    } 
    // else {
    //   if (widget.isCoursesBook) {
    //     final image = img.decodeImage(imageData!);
    //     if (Platform.isIOS || Platform.isAndroid) {
    //       //将横版照片变为竖版照片
    //       if (image!.width > image.height) {
    //         final rotatedImage = img.copyRotate(image, angle: 90);
    //         imageData = Uint8List.fromList(img.encodePng(rotatedImage));
    //       }
    //     }
    //   }
    // }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Crop(
        key: ValueKey(MediaQuery.of(context).size),
        image: imageData!,
        clipBehavior: Clip.none,
        controller: cropController,
        interactive: true,
        // fixCropRect: true,
        withCircleUi: widget.withCircleUi,
        aspectRatio: widget.cropAspectRatio ?? 1,
        baseColor: Colors.transparent,
        maskColor: AppTheme.cOverlayBackground,
        filterQuality: FilterQuality.high,
        willUpdateScale: (newScale) {
          if (_isInitScale) {
            _isInitScale = false;
            return false;
          }
          _isInitScale = false;

          return true;
        },
        initialRectBuilder:
            InitialRectBuilder.withBuilder((viewportRect, imageRect) {
          final aspectRatio = widget.cropAspectRatio ?? 1;
          final padding = 0.wMin;

          // 计算可用区域
          final availableWidth = imageRect.width - (padding * 2);
          final availableHeight = imageRect.height - (padding * 2);

          double cropWidth, cropHeight;

          // 根据宽高比计算裁剪框尺寸
          if (availableWidth / availableHeight > aspectRatio) {
            // 以高度为基准
            cropHeight = availableHeight;
            cropWidth = cropHeight * aspectRatio;
          } else {
            // 以宽度为基准
            cropWidth = availableWidth;
            cropHeight = cropWidth / aspectRatio;
          }

          // 计算居中位置
          final centerX = imageRect.left + imageRect.width / 2;
          final centerY = imageRect.top + imageRect.height / 2;

          return Rect.fromCenter(
            center: Offset(centerX, centerY),
            width: cropWidth,
            height: cropHeight,
          );
        }),
        cornerDotBuilder: (size, edgeAlignment) {
          return Container(
            width: 32.wMin,
            height: 32.wMin,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 5,
                ),
              ],
            ),
          );
        },
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
              // 将裁剪后的图片保存为临时文件
              final tempDir =
                  await Directory.systemTemp.createTemp('crop_image');
              final tempFile = File('${tempDir.path}/cropped_image.jpg');
              await tempFile.writeAsBytes(cropData);
              String croppedImagePath = tempFile.path;
              hideWidget = true;
              if (mounted) setState(() {});
              Get.back(result: File(croppedImagePath));
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
  }
}
