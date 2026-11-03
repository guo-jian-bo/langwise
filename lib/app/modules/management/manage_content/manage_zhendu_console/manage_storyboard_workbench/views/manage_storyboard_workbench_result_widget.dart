
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../common/commons.dart';
import '../../../../common/image_tool_widgets.dart';
import '../../enums/manage_visual_image_status_enum.dart';
import '../controllers/manage_storyboard_workbench_controller.dart';

class ManageStoryboardWorkbenchResultWidget extends StatelessWidget {
  final ManageStoryboardWorkbenchController controller;
  const ManageStoryboardWorkbenchResultWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        children: [

          Text(
            "当前关键帧结果",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary.color,
            ),
          ),

          SizedBox(height: 8.wMin),

          Obx((){
            ManageVisualProjectEntitySceneRelations data = controller.sceneData.value;
            return GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16.wMin,
                crossAxisSpacing: 16.wMin,
                childAspectRatio: 16 / 9,
              ),
              children: [
                _buildImageItemImageWidget(context, data, data.composition?.environment, SceneStoryboardTypeEnum.environment),
                _buildImageItemImageWidget(context, data, data.composition?.keyframes?.start, SceneStoryboardTypeEnum.start_frame),
                _buildImageItemImageWidget(context, data, data.composition?.keyframes?.highlight, SceneStoryboardTypeEnum.highlight_frame),
                _buildImageItemImageWidget(context, data, data.composition?.keyframes?.end, SceneStoryboardTypeEnum.end_frame),
              ],
            );
          }),

        ],
      ),
      
    );
  }

  Widget _buildImageItemImageWidget(BuildContext context, ManageVisualProjectEntitySceneRelations data, ManageVisualProjectEntitySceneRelationsCompositionImage? item, SceneStoryboardTypeEnum type){
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.wMin),
      child: Stack(
        children: [

          Positioned.fill(
            child: TapScaleWidget(
              onTap: () {
                controller.showBigImage(context, item);
              },
              sclae: 1,
              child: CachedImageWidget(
                item?.imageUrl??"",
                fit: BoxFit.cover,
                placeholder: buildEmptyWidget(fit: BoxFit.cover),
                errorWidget: buildEmptyWidget(fit: BoxFit.cover),
              ),
            ),
          ),

          Positioned(
            top: 10.wMin,
            left: 10.wMin,
            child: Column(
              spacing: 8.wMin,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ManageTagFS16Widget(
                  tag: type.name,
                  bgColor: AppTheme.cSurfaceSecondary.color,
                  fontColor: AppTheme.cTextPrimary.color,
                ),
                ManageTagFS16Widget(
                  tag: "uid: ${item?.imageId??''}",
                  bgColor: AppTheme.cSurfaceSecondary.color,
                  fontColor: AppTheme.cTextPrimary.color,
                ),
                ManageTagFS16Widget(
                  tag: item?.status??"",
                  bgColor: item?.statusEnum?.bg ?? AppTheme.cSurfaceSecondary.color.withValues(alpha: 1),
                ),
              ],
            ),
          ),

          Positioned(
            right: 10.wMin,
            top: 10.wMin,
            child: Row(
              children: [

                ManageImageToolEditWidgets(
                  showLockButton: false,
                  
                  imageTaskId: item?.statusEnum == ManageVisualImageStatusEnum.checked ? null : item?.imageTaskId,

                  uid: data.sceneId,
                  type: "SCRIPT_SCENE",
                  imageIds: item?.imageId == null ? null : [item!.imageId!],
                  styleId: controller.detilData.value.styleId,
                  visualProjectId: controller.detilData.value.uid,
                  sceneType: type,
                  onRefresh: () async{
                    controller.getDetilsData();
                  },
                ),

              ],
            ),
          ),

          Positioned(
            right: 10.wMin,
            bottom: 10.wMin,
            child: ManageImageToolBRWidgets(
              imageUrl: item?.imageUrl,
              onRefresh: () async{
                controller.getDetilsData();
              },
            ),
          ),

        ],
      ),
    );
  }

  



}