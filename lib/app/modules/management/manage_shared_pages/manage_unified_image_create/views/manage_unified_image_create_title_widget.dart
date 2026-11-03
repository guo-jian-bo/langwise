
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/commons.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../controllers/manage_unified_image_create_controller.dart';

class ManageUnifiedImageCreateTitleWidget extends StatelessWidget {
  final ManageUnifiedImageCreateController controller;
  const ManageUnifiedImageCreateTitleWidget({super.key, required this.controller});



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
            visible: controller.visualProjectId != null,
            child: Container(
              margin: EdgeInsets.only(left: 6.wMin),
              child: ManageTagFS16Widget(
                tag: "projectId: ${controller.visualProjectId??''}",
                bgColor: AppTheme.cSurfaceTertiary.color,
                fontColor: AppTheme.cTextSecondary.color,
              ),
            ),
          ),
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
            visible: controller.selectedStyleId.value != -1,
            child: Container(
              margin: EdgeInsets.only(left: 6.wMin),
              child: ManageTagFS16Widget(
                tag: "styleId: ${controller.selectedStyleId.value}",
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
      int imageCount = controller.generateCount.value;
      Size size = controller.imageOrgSize.value;
      String sizeText = "$imageCount张 · ${size.width.toInt()}x${size.height.toInt()}";

      return Row(
        spacing: 8.wMin,
        children: [
          _buildContentModeItemWidget("当前模式", controller.generationMode.value.name),
          _buildContentModeItemWidget("模式模型", controller.modeModule.value.name),
          _buildContentModeItemWidget("输出", sizeText),
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