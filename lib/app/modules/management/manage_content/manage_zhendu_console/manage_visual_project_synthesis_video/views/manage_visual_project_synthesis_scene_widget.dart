
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_tag_widget.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../theme/theme.dart';
import '../controllers/manage_visual_project_synthesis_video_controller.dart';

class ManageVisualProjectSynthesisSceneWidget extends StatelessWidget {
  final ManageVisualProjectSynthesisVideoController controller;
  final ManageVisualProjectEntitySceneRelations? scene;
  const ManageVisualProjectSynthesisSceneWidget({super.key, required this.controller, this.scene});

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: () {
        controller.selectScene(scene?.sceneId);
      },
      sclae: 1.005,
      child: Obx((){
        bool selected = controller.selectedSceneIds.contains(scene?.sceneId);
        return Container(
          width: 400.wMin,
          padding: EdgeInsets.all(10.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            color: AppTheme.cSurfaceTertiary.color,
            border: Border.all(
              width: 1.wMin,
              color: AppTheme.cSurfaceBrand.color.withValues(alpha: selected ? 1 : 0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleWidget(),
              SizedBox(height: 12.wMin),
              _buildImageListWidget(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTitleWidget(){
    bool selected = controller.selectedSceneIds.contains(scene?.sceneId);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4.wMin,
            children: [
              SelectableText(
                "Scene ${scene?.index??''} - ${scene?.sceneTitle??''}",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              SelectableText(
                "scene_uid: ${scene?.sceneId??''}",
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),

            ],
          ),
        ),
        SvgPicture.asset(
          selected ? "assets/svg/public/icon_check_box.svg" : "assets/svg/public/icon_uncheck_box.svg",
          width: 24.wMin,
          height: 24.wMin,
        ),
      ],
    );
  }

  Widget _buildImageListWidget(BuildContext context){
    
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.wMin,
        crossAxisSpacing: 10.wMin,
        childAspectRatio: 16 / 9,
      ),
      children: [
        _buildImageItemWidget(context, scene?.composition?.environment, "环境图"),
        _buildImageItemWidget(context, scene?.composition?.keyframes?.start, "起始帧"),
        _buildImageItemWidget(context, scene?.composition?.keyframes?.highlight, "高亮帧"),
        _buildImageItemWidget(context, scene?.composition?.keyframes?.end, "结束帧"),
      ],
    );
  }

  Widget _buildImageItemWidget(BuildContext context, ManageVisualProjectEntitySceneRelationsCompositionImage? image, String name){
    return ClipRRect(
      borderRadius: BorderRadius.circular(4.wMin),
      child: Stack(
        children: [
          Positioned.fill(
            child: TapScaleWidget(
              onTap: () {
                if(image?.imageUrl == null) return;
                ShowBigResourceDialog.showImage(context: context, imageUrls: [image!.imageUrl!]); 
              },
              sclae: 1,
              child: CachedImageWidget(
                image?.imageUrl??"",
                fit: BoxFit.cover,
                placeholder: buildEmptyWidget(fit: BoxFit.cover),
                errorWidget: buildEmptyWidget(fit: BoxFit.cover),
              ),
            ),
          ),
          Positioned(
            bottom: 4.wMin,
            left: 4.wMin,
            child: ManageTagFS14Widget(
              tag: name,
              bgColor: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }


}