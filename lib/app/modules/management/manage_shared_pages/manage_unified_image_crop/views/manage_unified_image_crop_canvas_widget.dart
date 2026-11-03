

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../theme/theme.dart';
import '../controllers/manage_unified_image_crop_controller.dart';

class ManageUnifiedImageCropCanvasWidget extends StatelessWidget {
  final ManageUnifiedImageCropController controller;
  const ManageUnifiedImageCropCanvasWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget(context),
          SizedBox(height: 16.wMin),
          Expanded(child: _buildCanvasWidget()),
        ],
      ),
    );
  }


  Widget _buildTitleWidget(BuildContext context){
    return Row(
      children: [
        SelectableText(
          "裁剪画布",
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SizedBox(width: 8.wMin),
        SelectableText(
          controller.isFixedAspectRatio.value ? "固定比例，只能等比例缩放并拖动裁剪框。" : "可自由裁剪，也可快速切到常见比例。",
          style: TextStyle(
            fontSize: 14.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
        const Spacer(),

        ButtonWidget(
          text: "查看原图",
          height: 36.wMin,
          padding: EdgeInsets.symmetric(horizontal: 10.wMin),
          color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
          border: Border.all(width: 1.wMin, color: AppTheme.cBorderBrand.color),
          borderRadius: 6.wMin,
          fontSize: 16.wMin,
          fontColor: AppTheme.cTextBrand.color,
          fontWeight: FontWeight.w500,
          sclae: 1.03,
          leftIcon: Container(
            margin: EdgeInsets.only(right: 4.wMin),
            child: Icon(
              Icons.fullscreen,
              size: 20.wMin,
              color: AppTheme.cTextBrand.color,
            ),
          ),
          onTap: () {
            controller.viewOriginalImage(context);
          },
        ),

      ],
    );
  }

  Widget _buildCanvasWidget(){

    return Obx((){
      final double? aspectRatio = controller.aspectRatio.value == null
          ? null
          : controller.aspectRatio.value!.width / controller.aspectRatio.value!.height;

      if (controller.croppedImageData.value == null) {
        return Container();
      }

      return Container( 
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cBgPrimary.color,
        ),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Crop(
            key: ValueKey<String>('crop_${controller.aspectRatio.value?.name ?? "any"}'),
            image: controller.croppedImageData.value!,
            clipBehavior: Clip.none,
            controller: controller.cropController,
            aspectRatio: aspectRatio,
            baseColor: AppTheme.cBgPrimary.color,
            maskColor: Colors.black.withValues(alpha: 0.5),
            filterQuality: FilterQuality.high,
            willUpdateScale: (newScale) => false,
            progressIndicator: const Center(
              child: CircularProgressIndicator(),
            ),
            onMoved: (viewportRect, imageRect) {
              controller.cropRectChanged(viewportRect, imageRect);
            },
            onStatusChanged: controller.onCropStatusChanged,
            onCropped: (result) async {},
          ),
        ),
      );
    });
  }


}
