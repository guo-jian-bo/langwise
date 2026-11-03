
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../theme/theme.dart';
import '../controllers/manage_subtitle_mapping_controller.dart';

class ManageSubtitleMappingSceneListWidget extends StatelessWidget {
  final ManageSubtitleMappingController controller;
  const ManageSubtitleMappingSceneListWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450.wMin,
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceSecondary.color,
        borderRadius: BorderRadius.circular(10.wMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.wMin),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            child: Text(
              "场景列表",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 8.wMin),
          Expanded(
            child: Obx((){
              return ListView.separated(
                itemCount: controller.scenesList.length,
                padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 10.wMin),
                separatorBuilder: (context, index) => SizedBox(height: 10.wMin),
                itemBuilder: (context, index) {
                  return _buildSceneItemWidget(controller.scenesList[index], index);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getSceneStartEndStr(ManageVisuaAssMappingEntityScenes scene){
    String startEnd = "未选择字幕";
    List<int?> sAssDialogueList = scene.composition?.keyframes?.start?.mappings?.assDialogueList??[];
    List<int?> hAssDialogueList = scene.composition?.keyframes?.highlight?.mappings?.assDialogueList??[];
    List<int?> eAssDialogueList = scene.composition?.keyframes?.end?.mappings?.assDialogueList??[];
    
    if(sAssDialogueList.isEmpty && hAssDialogueList.isEmpty && eAssDialogueList.isEmpty){
      return startEnd;
    }

    int? start;
    int? end;
    if(sAssDialogueList.isNotEmpty){
      start = sAssDialogueList.first??0;
    }
    if(start == null && hAssDialogueList.isNotEmpty){
      start = hAssDialogueList.first??0;
    }
    if(start == null && eAssDialogueList.isNotEmpty){
      start = eAssDialogueList.first??0;
    }
    
    if(eAssDialogueList.isNotEmpty){
      end = eAssDialogueList.last??0;
    }
    if(end == null && hAssDialogueList.isNotEmpty){
      end = hAssDialogueList.last??0;
    }
    if(end == null && sAssDialogueList.isNotEmpty){
      end = sAssDialogueList.last??0;
    }

    return "#${start??0} - #${end??0}";

  }

  Widget _buildSceneItemWidget(ManageVisuaAssMappingEntityScenes scene, int index){

    bool isSave = controller.isSceneMappingSaved(scene);

    return TapScaleWidget(
      onTap: () {
        controller.selectScene(index);
      },
      sclae: 1,
      child: Obx((){
        bool selected = controller.currentSceneIndex.value == index;
      
        return Container(
          padding: EdgeInsets.all(10.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.wMin),
            color: AppTheme.cSurfacePrimary.color,
            border: Border.all(
              width: 1.wMin,
              color: selected ? AppTheme.cBorderBrand.color : AppTheme.cBorderPrimary.color,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "scene ${scene.index??''}",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: AppTheme.cTextTertiary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  ButtonWidget(
                    text: isSave ? "已保存" : "未保存",
                    padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 2.wMin),
                    color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2),
                    fontColor: isSave ? AppTheme.cSurfaceSuccess.color : AppTheme.cTextTertiary.color,
                    fontSize: 14.wMin,
                  ),
                ],
              ),
              SizedBox(height: 6.wMin),
              Text(
                scene.title??"",
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 6.wMin),
              Row(
                children: [
                  Text(
                    "${scene.dialogues?.length??0} 句script",
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: AppTheme.cTextTertiary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _getSceneStartEndStr(scene),
                    style: TextStyle(
                      fontSize: 18.wMin,
                      color: AppTheme.cTextTertiary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
      
            ],
          ),
        );
      }),
    );
  }

}
