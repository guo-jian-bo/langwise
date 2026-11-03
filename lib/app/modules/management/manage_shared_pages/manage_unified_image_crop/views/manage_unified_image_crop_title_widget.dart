
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../../utils/utils.dart';
import '../../../common/commons.dart';
import '../controllers/manage_unified_image_crop_controller.dart';

class ManageUnifiedImageCropTitleWidget extends StatelessWidget {
  final ManageUnifiedImageCropController controller;
  const ManageUnifiedImageCropTitleWidget({super.key, required this.controller});

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
          _buildTitltTagWidget(),
          SizedBox(height: 6.wMin),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildContentWidget(),
                ),
                _buildContentModeWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitltTagWidget(){
    return Obx((){
      return Row(
        children: [

          ManageTagFS16Widget(
            tag: controller.imageDetail.value.typeTitle ?? "",
            bgColor: AppTheme.cSurfaceTertiary.color,
            fontColor: AppTheme.cTextSecondary.color,
          ),
          SizedBox(width: 6.wMin),
          ManageTagFS16Widget(
            tag: "uid: ${controller.imageDetail.value.contentId ?? ""}",
            bgColor: AppTheme.cSurfaceTertiary.color,
            fontColor: AppTheme.cTextSecondary.color,
          ),

          const Spacer(),

          Visibility(
            visible: controller.viewType != null,
            child: Container(
              margin: EdgeInsets.only(left: 6.wMin),
              child: ManageTagFS16Widget(
                tag: controller.viewType?.name ?? "",
                bgColor: AppTheme.cSurfaceTertiary.color,
                fontColor: AppTheme.cTextSecondary.color,
              ),
            ),
          ),
          Visibility(
            visible: controller.sceneType != null,
            child: Container(
              margin: EdgeInsets.only(left: 6.wMin),
              child: ManageTagFS16Widget(
                tag: controller.sceneType?.value ?? "",
                bgColor: AppTheme.cSurfaceTertiary.color,
                fontColor: AppTheme.cTextSecondary.color,
              ),
            ),
          ),

          Visibility(
            visible: controller.styleId != null,
            child: Container(
              margin: EdgeInsets.only(left: 6.wMin),
              child: ManageTagFS16Widget(
                tag: "styleId: ${controller.styleId}",
                bgColor: AppTheme.cSurfaceTertiary.color,
                fontColor: AppTheme.cTextSecondary.color,
              ),
            ),
          ),

          Visibility(
            visible: controller.imageDetail.value.styleTitle != null,
            child: Container(
              margin: EdgeInsets.only(left: 6.wMin),
              child: ManageTagFS16Widget(
                tag: controller.imageDetail.value.styleTitle ?? "",
                bgColor: AppTheme.cSurfaceTertiary.color,
                fontColor: AppTheme.cTextSecondary.color,
              ),
            ),
          ),

          Visibility(
            visible: controller.imageDetail.value.localeTitle != null,
            child: Container(
              margin: EdgeInsets.only(left: 6.wMin),
              child: ManageTagFS16Widget(
                tag: controller.imageDetail.value.localeTitle ?? "",
                bgColor: AppTheme.cSurfaceTertiary.color,
                fontColor: AppTheme.cTextSecondary.color,
              ),
            ),
          ),


        ],
      );
    });
  }

  Widget _buildContentWidget(){
    return Obx((){
      ManageCreateImageInfoEntityDifficulty? difficulty = controller.imageDetail.value.difficulty;
      String? min = DifficultieUtils.getLanguageDifficultieLevel1("en", difficulty?.min)?.name?.text;
      String? max = DifficultieUtils.getLanguageDifficultieLevel1("en", difficulty?.max)?.name?.text;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            controller.imageDetail.value.content ?? "",
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Visibility(
            visible: controller.imageDetail.value.posTitle != null && min != null && max != null,
            child: SelectableText(
              "${controller.imageDetail.value.posTitle??''} · $min - $max",
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SelectableText(
            controller.imageDetail.value.definition??"",
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          SelectableText(
            controller.imageDetail.value.description??"",
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w400,
            ),
          ),

        ],
      );
    });
  }

  Widget _buildContentModeWidget(){
    return Obx((){
      String aspectRatioText = controller.aspectRatio.value?.name ?? "Any";
      Size size = controller.actualUpscaleSize.value;

      return Row(
        spacing: 8.wMin,
        children: [
          _buildContentModeItemWidget("裁剪模式", controller.isFixedAspectRatio.value ? "固定比例" : "自由比例"),
          _buildContentModeItemWidget("比例", aspectRatioText),
          _buildContentModeItemWidget("输出", "${size.width.toInt()}x${size.height.toInt()}"),
        ],
      );
    });
  }

  Widget _buildContentModeItemWidget(String name, String value){
    return Container(
      width: 200.wMin,
      padding: EdgeInsets.all(8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceTertiary.color,
        border: Border.all(
          color: AppTheme.cBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4.wMin,
        children: [
          SelectableText(
            name,
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextTertiary.color,
              fontWeight: FontWeight.w400,
            ),
          ),
          SelectableText(
            value,
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }



}
