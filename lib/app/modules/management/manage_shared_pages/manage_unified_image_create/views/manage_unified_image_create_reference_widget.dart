
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/commons.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../theme/theme.dart';
import '../controllers/manage_unified_image_create_controller.dart';
import '../enums/manage_unified_image_create_enums.dart';

class ManageUnifiedImageCreateReferenceWidget extends StatelessWidget {
  final ManageUnifiedImageCreateController controller;
  const ManageUnifiedImageCreateReferenceWidget({super.key, required this.controller});

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
          SizedBox(height: 12.wMin),
          _buildImageListWidget(context),
        ],
      ),
    );
  }

  Widget _buildTitleWidget(BuildContext context){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              "参考图片",
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            Obx((){
              return SelectableText(
                "当前${controller.referenceImages.length}张",
                style: TextStyle(
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              );
            }),

          ],
        ),

        const Spacer(),

        ButtonWidget(
          text: "输入UID",
          padding: EdgeInsets.all(8.wMin),
          borderRadius: 6.wMin,
          color: AppTheme.cSurfaceLayerElevated.color,
          border: Border.all(
            color: AppTheme.cBorderDefault.color,
            width: 1.wMin,
          ),
          fontSize: 18.wMin,
          fontWeight: FontWeight.w500,
          fontColor: AppTheme.cTextPrimary.color,
          sclae: 1.03,
          onTap: () {
            controller.selectImageUid(context);
          },
        ),

        SizedBox(width: 12.wMin),

        ButtonWidget(
          text: "上传图片",
          padding: EdgeInsets.all(8.wMin),
          borderRadius: 6.wMin,
          color: AppTheme.cSurfaceLayerElevated.color,
          border: Border.all(
            color: AppTheme.cBorderDefault.color,
            width: 1.wMin,
          ),
          fontSize: 18.wMin,
          fontWeight: FontWeight.w500,
          fontColor: AppTheme.cTextPrimary.color,
          sclae: 1.03,
          onTap: () {
            controller.uploadImage(context);
          },
        ),

      ],
    );
  }

  Widget _buildImageListWidget(BuildContext context){
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx((){
        return Row(
          spacing: 12.wMin,
          children: List.generate(controller.referenceImages.length, (index){
            return _buildImageItemWidget(context, controller.referenceImages[index], index);
          }),
        );
      }),
    );
  }

  Widget _buildImageItemWidget(BuildContext context, ManageCreateImageInfoEntityImages image, int index){
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.wMin),
      child: Container(
        width: 250.wMin,
        height: 250.wMin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: AppTheme.cSurfaceLayerElevated.color,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: TapScaleWidget(
                sclae: 1,
                onTap: () {
                  controller.showImageDetail(context, index);
                },
                child: CachedImageWidget(
                  image.imageUrl ?? "",
                  fit: BoxFit.contain,
                  errorWidget: buildLoadingWidget(),
                  placeholder: buildLoadingWidget(),
                ),
              ),
            ),
            
            Positioned(
              top: 4.wMin,
              left: 4.wMin,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4.wMin,
                children: [
                  ManageTagFS16Widget(
                    tag: "参考图${index + 1}",
                    bgColor: AppTheme.cSurfaceTertiary.color,
                    fontColor: AppTheme.cTextSecondary.color,
                  ),
                  ManageTagFS16Widget(
                    tag: "uid: ${image.imageId??''}",
                    bgColor: AppTheme.cSurfaceTertiary.color,
                    fontColor: AppTheme.cTextSecondary.color,
                  ),
      
                ],
              ),
            ),

            Positioned(
              right: 4.wMin,
              top: 4.wMin,
              child: Visibility(
                visible: image.isDefault == false || controller.generationMode.value == GenerationModeEnum.imageEdit, // 图片编辑模式下可以删除默认图片
                child: TapScaleWidget(
                  sclae: 1.03,
                  onTap: () {
                    controller.deleteImage(index);
                  },
                  child: Container(
                    width: 38.wMin,
                    height: 38.wMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cSurfaceTertiary.color,
                    ),
                    child: SvgPicture.asset(
                      "assets/svg/public/x.svg",
                      width: 24.wMin,
                      height: 24.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
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