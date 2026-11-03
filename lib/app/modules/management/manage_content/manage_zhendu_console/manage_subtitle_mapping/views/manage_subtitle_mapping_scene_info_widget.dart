
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../controllers/manage_subtitle_mapping_controller.dart';

class ManageSubtitleMappingSceneInfoWidget extends StatelessWidget {
  final ManageSubtitleMappingController controller;
  const ManageSubtitleMappingSceneInfoWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceSecondary.color,
        borderRadius: BorderRadius.circular(10.wMin),
      ),
      child: Obx((){
        int sceneIndex = controller.currentSceneIndex.value;
        ManageVisuaAssMappingEntityScenes? scene;
        if(controller.scenesList.length > sceneIndex){
          scene = controller.scenesList[sceneIndex];
        }

        if(scene == null) return Container();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Scene ${scene.index??''} - ${scene.title??''}",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.wMin),

            Row(
              spacing: 6.wMin,
              children: [
                _buildSceneImageWidget(scene.composition?.keyframes?.start, SceneTypeEnum.start_frame),
                _buildSceneImageWidget(scene.composition?.keyframes?.highlight, SceneTypeEnum.highlight_frame),
                _buildSceneImageWidget(scene.composition?.keyframes?.end, SceneTypeEnum.end_frame),
              ],
            ),

            SizedBox(height: 16.wMin),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cSurfacePrimary.color,
                  borderRadius: BorderRadius.circular(10.wMin),
                ),
                child: ListView.separated(
                  itemCount: scene.dialogues?.length??0,
                  padding: EdgeInsets.all(16.wMin),
                  separatorBuilder: (context, index) => SizedBox(height: 10.wMin),
                  itemBuilder: (context, index) {
                    return _buildPersonaWidget(scene!, scene.dialogues?[index]);
                  },
                ),
              ),
            ),

            SizedBox(height: 24.wMin),

            _buildButtonsWidget(),
            
          ],
        );
      }),
    );
  }

  Widget _buildSceneImageWidget(ManageVisuaAssMappingEntityScenesCompositionKeyframe? keyframe, SceneTypeEnum sceneType){

    List<int?>? assDialogueList = keyframe?.mappings?.assDialogueList??[];
    String startEnd = "尚未选择字幕";
    if(assDialogueList.isNotEmpty){
      startEnd = "已选 # ${assDialogueList.first??0} - ${assDialogueList.last??0}";
    }

    return Expanded(
      child: TapScaleWidget(
        onTap: () {
          controller.selectSceneTypeEnum(sceneType);
        },
        sclae: 1,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Obx((){
            bool isSelected = controller.currentSceneTypeEnum.value == sceneType;
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 4.wMin, 
                  color: AppTheme.cBorderBrand.color.withValues(alpha: isSelected ? 1 : 0),
                ),
                borderRadius: BorderRadius.circular(10.wMin),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.wMin),
                child: Stack(
                  children: [
                
                    Positioned.fill(
                      child: CachedImageWidget(
                        keyframe?.imageUrl??"",
                        placeholder: buildEmptyWidget(fit: BoxFit.cover),
                        errorWidget: buildEmptyWidget(fit: BoxFit.cover),
                      ),
                    ),
                      
                    Positioned(
                      bottom: 4.wMin,
                      left: 4.wMin,
                      child: ManageTagFS16Widget(
                        tag: sceneType.label,
                        bgColor: Colors.black45,
                      ),
                    ),
                      
                    Positioned(
                      bottom: 4.wMin,
                      right: 4.wMin,
                      child: ManageTagFS16Widget(
                        tag: startEnd,
                        bgColor: Colors.black45,
                      ),
                    ),
                      
                    Positioned(
                      top: 4.wMin,
                      right: 4.wMin,
                      child: Visibility(
                        visible: isSelected,
                        child: ManageTagFS16Widget(
                          tag: "当前编辑",
                          bgColor: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPersonaWidget(ManageVisuaAssMappingEntityScenes scene, ManageVisuaAssMappingEntityScenesDialogues? dialogue){
    if(dialogue == null){
      return Container();
    }

    return Container(
      padding: EdgeInsets.all(10.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceTertiary.color,
        borderRadius: BorderRadius.circular(10.wMin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(
            width: 100.wMin,
            height: 100.wMin,
            child: CachedImageWidget(
              dialogue.imageUrl??"",
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              placeholder: buildEmptyWidget(fit: BoxFit.cover),
              errorWidget: buildEmptyWidget(fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 10.wMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  dialogue.speaker??"",
                  style: TextStyle(
                    fontSize: 22.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
                SelectableText(
                  "dialogue_uid: ${dialogue.uid?.toString()??''}",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
                  ),
                ),
                SelectableText(
                  dialogue.text??"",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextSecondary.color,
                  ),
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }


  Widget _buildButtonsWidget(){
    return Row(
      spacing: 16.wMin,
      children: [
        Expanded(
          child: ButtonWidget(
            text: "清空当前scene",
            color: AppTheme.cSurfaceQuaternary.color,
            height: 44.wMin,
            borderRadius: 10.wMin,
            fontColor: AppTheme.cTextSecondary.color,
            fontSize: 20.wMin,
            sclae: 1.03,
            onTap: () {
              controller.clearCurrentSceneMapping();
            },
          ),
        ),
        Expanded(
          child: ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.dramaVisualProjectFrameMapping],
            child: ButtonWidget(
              text: "保存当前 scene 映射",
              color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
              height: 44.wMin,
              borderRadius: 10.wMin,
              fontColor: AppTheme.cSurfaceBrand.color,
              border: Border.all(
                width: 1.wMin,
                color: AppTheme.cSurfaceBrand.color,
              ),
              fontSize: 20.wMin,
              sclae: 1.03,
              onTap: () {
                controller.saveSceneMapping();
              },
            ),
          ),
        ),
      ],
    );
  }

}
