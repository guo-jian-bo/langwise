
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../common/image_tool_widgets.dart';
import '../../../../utils/utils.dart';
import '../controllers/manage_storyboard_workbench_controller.dart';

class ManageStoryboardWorkbenchImageWidget extends StatelessWidget {
  final ManageStoryboardWorkbenchController controller;
  const ManageStoryboardWorkbenchImageWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 830.wMin,
      child: Column(
        spacing: 16.wMin,
        children: [

          Container(
            padding: EdgeInsets.all(16.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              color: AppTheme.cSurfacePrimary.color,
            ),
            child: _buildImageWidget(),
          ),

          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                color: AppTheme.cSurfacePrimary.color,
              ),
              child: _buildOperationWidget(context),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildImageWidget(){
    return Column(
      children: [
        Row(
          children: [
            Text(
              "当前分镜图",
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            const Spacer(),
            ManageTagFS16Widget(
              tag: "storyboard_sheet · 分镜图",
              bgColor: AppTheme.cSurfaceTertiary.color,
              fontColor: AppTheme.cTextSecondary.color,
            ),
          ],
        ),

        SizedBox(height: 8.wMin),

        AspectRatio(
          aspectRatio: 16/9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.wMin),
            child: Obx((){
              ManageVisualProjectEntitySceneRelations scene = controller.sceneData.value;
              return Stack(
                children: [
                  Positioned.fill(
                    child: CachedImageWidget(
                      controller.sceneData.value.imageUrl??"",
                      fit: BoxFit.cover,
                      placeholder: buildEmptyWidget(fit: BoxFit.cover),
                      errorWidget: buildEmptyWidget(fit: BoxFit.cover),
                    ),
                  ),

                  Positioned(
                    top: 6.wMin,
                    left: 6.wMin,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 6.wMin,
                      children: [
                        ManageTagFS16Widget(
                          tag: SceneStoryboardTypeEnum.storyboard_sheet.name,
                          bgColor: AppTheme.cSurfaceSecondary.color,
                          fontColor: AppTheme.cTextPrimary.color,
                        ),
                        ManageTagFS16Widget(
                          tag: "uid: ${scene.imageId??''}",
                          bgColor: AppTheme.cSurfaceSecondary.color,
                          fontColor: AppTheme.cTextPrimary.color,
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    right: 6.wMin,
                    top: 6.wMin,
                    child: Row(
                      children: [
                        ManageImageToolEditWidgets(
                          jumpCode: AppManageRoutesCode.storyboardWorkbench,
                          params: {
                            "projectId": controller.detilData.value.uid,
                            "sceneId": scene.sceneId,
                          },
                          showLockButton: false,
                          showCropButton: false,
                          showEditButton: false,
                          imageTaskId: scene.imageTaskId,
                          uid: scene.sceneId,
                          type: "SCRIPT_SCENE",
                          imageIds: scene.imageId == null ? null : [scene.imageId!],
                          styleId: controller.detilData.value.styleId,
                          promptId: scene.promptId,
                          visualProjectId: controller.detilData.value.uid,
                          sceneType: SceneStoryboardTypeEnum.storyboard_sheet,
                          onRefresh: () async{
                            controller.getDetilsData();
                          },
                        ),

                      ],
                    ),
                  ),

                  Positioned(
                    right: 6.wMin,
                    bottom: 6.wMin,
                    child: ManageImageToolBRWidgets(
                      imageUrl: scene.imageUrl,
                      onRefresh: () async{
                        controller.getDetilsData();
                      },
                    ),
                  ),

                ],
              );
            }),
          ),
        ),

      ],
    );
  }


  /// 操作区
  Widget _buildOperationWidget(BuildContext context){
    return Column(
      children: [

        Row(
          children: [
            Text(
              "操作区",
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            const Spacer(),
            ManageTagFS16Widget(
              tag: "固定Pro",
              bgColor: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
              fontColor: AppTheme.cSurfaceWarning.color,
            ),
          ],
        ),

        SizedBox(height: 8.wMin),

        Row(
          spacing: 24.wMin,
          children: [

            Expanded(
              child: ManageAuthBoxWidget(
                authCodes: const [ManageAuthCode.contentReviewImageCreateInfo],
                child: ButtonWidget(
                  text: "生成分镜图",
                  padding: EdgeInsets.symmetric(horizontal: 48.wMin, vertical: 8.wMin),
                  borderRadius: 8.wMin,
                  sclae: 1.03,
                  color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                  border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color),
                  fontColor: AppTheme.cSurfaceBrand.color,
                  fontSize: 20.wMin,
                  onTap: OptimizeUtils.noneThrottle(() {
                    controller.generateImage();
                  }, 300),
                ),
              ),
            ),

            Expanded(
              child: ManageAuthBoxWidget(
                authCodes: const [ManageAuthCode.dramaVisualProjectStoryboardSheetImageImport],
                child: ButtonWidget(
                  text: "导入分镜图",
                  padding: EdgeInsets.symmetric(horizontal: 48.wMin, vertical: 8.wMin),
                  borderRadius: 8.wMin,
                  sclae: 1.03,
                  color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2),
                  border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceSuccess.color),
                  fontColor: AppTheme.cSurfaceSuccess.color,
                  fontSize: 20.wMin,
                  onTap: OptimizeUtils.noneThrottle(() {
                    controller.showImportImage(context);
                  }, 300),
                ),
              ),
            ),

          ],
        ),

        SizedBox(height: 10.wMin),
        Container(
          height: 1.wMin,
          color: AppTheme.cBorderSecondary.color,
        ),
        SizedBox(height: 10.wMin),

        Row(
          children: [

            Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "裁切边框安全边距",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  "margin_ratio：裁切时每侧裁掉的安全边距百分比",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),

              ],
            ),
          ),

          SizedBox(width: 10.wMin),

            TapScaleWidget(
              onTap: () {
                if(controller.clipPercent.value > 0) controller.clipPercent.value--;
              },
              sclae: 1.03,
              child: Container(
                width: 48.wMin,
                height: 48.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.wMin),
                  color: AppTheme.cSurfaceQuaternary.color,
                ),
                child: Icon(
                  Icons.remove,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
            ),

            Container(
              width: 100.wMin,
              alignment: Alignment.center,
              child: Obx((){
                return Text(
                  "${controller.clipPercent.value}%",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w500,
                  ),
                );
              })
            ),

            TapScaleWidget(
              onTap: () {
                if(controller.clipPercent.value < 20) controller.clipPercent.value++;
              },
              sclae: 1.03,
              child: Container(
                width: 48.wMin,
                height: 48.wMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.wMin),
                  color: AppTheme.cSurfaceQuaternary.color,
                ),
                child: Icon(
                  Icons.add,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
            ),

            SizedBox(width: 40.wMin),

            ButtonWidget(
              text: "重新裁切",
              height: 48.wMin,
              padding: EdgeInsets.symmetric(horizontal: 20.wMin),
              borderRadius: 8.wMin,
              sclae: 1.03,
              color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
              border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceWarning.color),
              fontColor: AppTheme.cSurfaceWarning.color,
              fontSize: 20.wMin,
              onTap: OptimizeUtils.noneThrottle(() {
                controller.reCrop();
              }, 300),
            ),

          ],
        ),


      ],
    );
  }



}