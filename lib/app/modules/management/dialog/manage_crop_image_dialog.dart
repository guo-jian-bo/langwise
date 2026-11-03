import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/utils.dart';

/// 裁剪图片弹窗
class ManageCropImageDialog{
  static Future<String?> show({
    required BuildContext context,
    required String imageFilePath,
  }) async{
    return await showCupertinoDialog<String?>(
      context: context, 
      builder: (context) {
        return ManageCropImageDialogWidget(
          imageFilePath: imageFilePath,
        );
      },
    );
  }
}

class ManageCropImageDialogWidget extends StatefulWidget {
  final String imageFilePath;
  const ManageCropImageDialogWidget({super.key, required this.imageFilePath});

  @override
  State<ManageCropImageDialogWidget> createState() => _ManageCropImageDialogWidgetState();
}

class _ManageCropImageDialogWidgetState extends State<ManageCropImageDialogWidget> {
  final CropController cropController = CropController();
  Uint8List? imageData;

  final GlobalKey dialogKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    File(widget.imageFilePath).readAsBytes().then((val){
      imageData = val;
      if(mounted) setState(() {});
    });
  }


  @override
  Widget build(BuildContext context) {

    Widget buildCropWidget(){
      if(imageData == null){
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Crop(
          image: imageData!,
          clipBehavior: Clip.none,
          controller: cropController,
          interactive: true,
          aspectRatio: 1,
          baseColor: const Color(0xff22293C),
          maskColor: Colors.black.withValues(alpha: 0.5),
          filterQuality: FilterQuality.low,
          initialRectBuilder: InitialRectBuilder.withBuilder((viewportRect, imageRect){
            return Rect.fromLTRB(
              viewportRect.left,
              viewportRect.top,
              viewportRect.right,
              viewportRect.bottom,
            );
          }),
          progressIndicator: const Center(
            child: CircularProgressIndicator(),
          ),
          onCropped: (result) async {
            if (result is CropSuccess) {
              Uint8List cropData = result.croppedImage;
              // 将裁剪后的图片保存为临时文件
              final tempDir = await Directory.systemTemp.createTemp('crop_image');
              final tempFile = File('${tempDir.path}/cropped_image.jpg');
              await tempFile.writeAsBytes(cropData);
              String croppedImagePath = tempFile.path;
              Get.back(result: croppedImagePath);
            } else if (result is CropFailure) {
              ToastUtils.showManageToast(text: "裁剪失败", containerKey: dialogKey);
            }
          },
        ),
      );
    }

    return DialogBoxWidget(
      title: "裁剪图片",
      width: 1080.wMin,
      onCancel: () => Get.back(),
      define: "裁剪",
      onDefine: () {
        cropController.crop();
      },
      child: Container(
        height: 650.wMin,
        width: 650.wMin,
        key: dialogKey,
        margin: EdgeInsets.symmetric(horizontal: 24.wMin),
        color: const Color(0xff22293C),
        child: buildCropWidget(),
      ),
    );
  }
}
