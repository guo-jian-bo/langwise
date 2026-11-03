
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../theme/theme.dart';
import '../../../../common/commons.dart';
import '../controllers/manage_storyboard_workbench_controller.dart';

class ManageStoryboardWorkbenchTitleWidget extends StatelessWidget {
  final ManageStoryboardWorkbenchController controller;
  const ManageStoryboardWorkbenchTitleWidget({super.key, required this.controller});

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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
          
              ManageTagFS16Widget(
                tag: "视觉项目场景",
                bgColor: AppTheme.cSurfaceTertiary.color,
                fontColor: AppTheme.cTextSecondary.color,
              ),
              SizedBox(width: 6.wMin),
              ManageTagFS16Widget(
                tag: controller.detilData.value.title ??"",
                bgColor: Colors.transparent,
                fontColor: AppTheme.cTextSecondary.color,
              ),
          
              
              const Spacer(),
          
              ManageTagFS16Widget(
                tag: controller.sceneData.value.statusEnum?.name,
                bgColor: controller.sceneData.value.statusEnum?.bg,
                fontColor: controller.sceneData.value.statusEnum?.font??AppTheme.cTextSecondary.color,
              ),
          
              Container(
                margin: EdgeInsets.only(left: 6.wMin),
                child: ManageTagFS16Widget(
                  tag: "project_uid: ${controller.projectId}",
                  bgColor: AppTheme.cSurfaceTertiary.color,
                  fontColor: AppTheme.cTextSecondary.color,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 6.wMin),
                child: ManageTagFS16Widget(
                  tag: "scene_uid: ${controller.sceneId}",
                  bgColor: AppTheme.cSurfaceTertiary.color,
                  fontColor: AppTheme.cTextSecondary.color,
                ),
              ),
          
              Container(
                margin: EdgeInsets.only(left: 6.wMin),
                child: ManageTagFS16Widget(
                  tag: "分镜图",
                  bgColor: AppTheme.cSurfaceTertiary.color,
                  fontColor: AppTheme.cTextSecondary.color,
                ),
              ),
          
              Container(
                margin: EdgeInsets.only(left: 6.wMin),
                child: ManageTagFS16Widget(
                  tag: controller.detilData.value.styleTitle ?? "",
                  bgColor: AppTheme.cSurfaceTertiary.color,
                  fontColor: AppTheme.cTextSecondary.color,
                ),
              ),
          
              Container(
                margin: EdgeInsets.only(left: 6.wMin),
                child: ManageTagFS16Widget(
                  tag: controller.detilData.value.locale ?? "",
                  bgColor: AppTheme.cSurfaceTertiary.color,
                  fontColor: AppTheme.cTextSecondary.color,
                ),
              ),
            ],
          ),
          Visibility(
            visible: controller.sceneData.value.errorMessage != null && controller.sceneData.value.errorMessage != "",
            child: SelectableText(
              "失败原因: ${controller.sceneData.value.errorMessage??''}",
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cSurfaceError.color,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildContentWidget(){
    return Obx((){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            "Scene ${controller.sceneData.value.index??''} - ${controller.sceneData.value.sceneTitle??''}",
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SelectableText(
            controller.sceneData.value.setting ?? "",
            maxLines: 3,
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
      return Row(
        spacing: 8.wMin,
        children: [
          _buildContentModeItemWidget("prompt_uid", "${controller.promptEntity.value.promptId??''}"),
          _buildContentModeItemWidget("参考图", "${controller.promptEntity.value.referenceImages?.length ?? 0} 张"),
          _buildContentModeItemWidget("模型模式", "Pro"),
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