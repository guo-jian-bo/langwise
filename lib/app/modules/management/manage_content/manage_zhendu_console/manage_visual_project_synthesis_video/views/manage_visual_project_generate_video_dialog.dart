import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../common/commons.dart';
import '../../../../common/image_tool_widgets.dart';
import '../../common/manage_zhendu_widgets.dart';

class ManageVisualProjectGenerateVideoDialog{

  /// 生成场景视频
  static Future<void> generateSceneVideo({
    required BuildContext context,
    required int projectId,
    required ManageVisualProjectEntitySceneRelations sceneRelations,
  }) async{
    
    return await showCupertinoDialog(
      context: context, 
      builder: (context) {
        return ManageVisualProjectGenerateVideoSceneDialogWidget(projectId: projectId, sceneRelations: sceneRelations);
      },
    );
  }

  /// 生成过渡视频
  static Future<void> generateTransitionVideo({
    required BuildContext context,
    required int projectId,
    required ManageVisualProjectEntitySceneRelations scene1,
    required ManageVisualProjectEntitySceneRelations scene2,
  }) async{
    
    return await showCupertinoDialog(
      context: context, 
      builder: (context) {
        return ManageVisualProjectGenerateVideoTransitionDialogWidget(projectId: projectId, scene1: scene1, scene2: scene2);
      },
    );
  }

}

class ManageVisualProjectGenerateVideoSceneDialogWidget extends StatefulWidget {
  /// 项目ID
  final int projectId;

  /// 场景关系
  final ManageVisualProjectEntitySceneRelations sceneRelations;

  const ManageVisualProjectGenerateVideoSceneDialogWidget({super.key, required this.projectId, required this.sceneRelations});

  @override
  State<ManageVisualProjectGenerateVideoSceneDialogWidget> createState() => _ManageVisualProjectGenerateVideoSceneDialogWidgetState();
}

class _ManageVisualProjectGenerateVideoSceneDialogWidgetState extends State<ManageVisualProjectGenerateVideoSceneDialogWidget> {

  /// 1=首帧 2=首尾帧 3=首中尾帧
  int frameMode = 3;

  /// 是否开始分段生成
  bool isSegmentation = true;

  /// 生成数量
  int generateCount = 4;

  /// 导演意图
  TextEditingController directorIntentController = TextEditingController();


  /// 确认生成
  Future<void> confirmGenerate() async{
    
    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "projectId": widget.projectId,
        "sceneId": widget.sceneRelations.sceneId,
        "numberOfVideos": generateCount,
        "relayEnable": isSegmentation,
        "frames": frameMode,
        "directorialIntent": directorIntentController.text,
      };
      String? res = await LanguageConsoleDramaRequest.visualGenerateSceneVideo(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }

  }

  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "配置场景视频生成",
      width: 1000.wMin,
      cancelText: "关闭",
      onCancel: () => Get.back(),
      confirmText: "确认生成",
      onConfirm: () {
        confirmGenerate();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        height: 800.wMin,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleWidget(),
              SizedBox(height: 16.wMin),
              Container(height: 1.wMin, color: AppTheme.cBorderSecondary.color),
              SizedBox(height: 16.wMin),
              _buildModeWidget(),
              SizedBox(height: 24.wMin),
              _buildPreviewWidget(context),
              SizedBox(height: 24.wMin),
              _buildSegmentationWidget(),
              SizedBox(height: 24.wMin),
              _buildGenerateWidget(),
              SizedBox(height: 24.wMin),
              _buildDirectorWidget(),
          
              SizedBox(height: 24.wMin),
              Container(height: 1.wMin, color: AppTheme.cBorderSecondary.color),
          
          
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWidget(){
    int sceneIndex = widget.sceneRelations.index??0;
    String sceneTitle = widget.sceneRelations.sceneTitle ?? "";
    return SelectableText(
      "Scene: Scene $sceneIndex - $sceneTitle",
      style: TextStyle(
        fontSize: 16.wMin,
        fontWeight: FontWeight.w400,
        color: AppTheme.cTextTertiary.color,
      ),
    );
  }


  Widget _buildModeWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SelectableText(
          "关键帧模式",
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),

        SizedBox(height: 6.wMin),

        IntrinsicHeight(
          child: Row(
            spacing: 16.wMin,
            children: [
              _buildModeItemWidget(1),
              _buildModeItemWidget(2),
              _buildModeItemWidget(3),
            ],
          ),
        ),

      ],
    );
  }

  Widget _buildModeItemWidget(int mode){
    bool isSelected = mode == frameMode;

    String name = "$mode. 首帧";
    String desc = "只使用 start_frame，适合轻动作延展。";
    if(mode == 2){
      name = "$mode. 首尾帧";
      desc = "使用 start_frame + end_frame，默认推荐。";
    }else if(mode == 3){
      name = "$mode. 首中尾帧";
      desc = "使用 start_frame + highlight_frame + end_frame，适合更完整的表演段落。";
    }


    return Expanded(
      child: TapScaleWidget(
        onTap: () {
          setState(() {
            frameMode = mode;
          });
        },
        sclae: 1.01,
        child: Container(
          padding: EdgeInsets.all(16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            color: isSelected? AppTheme.cSurfaceBrand.withValues(alpha: 0.2) : AppTheme.cSurfaceTertiary.color,
            border: Border.all(
              color: isSelected? AppTheme.cSurfaceBrand.color : AppTheme.cBorderSecondary.color,
              width: 1.wMin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        
              Text(
                name,
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
              ),
        
            ],
          ),
        ),
      ),
    );
  }

  /// 关键帧预览
  Widget _buildPreviewWidget(BuildContext context){

    List<Widget> list = [];
    if(frameMode == 1){
      list.add(_buildPreviewItemWidget(widget.sceneRelations.composition?.keyframes?.start, SceneStoryboardTypeEnum.start_frame));
    }else if(frameMode == 2){
      list.add(_buildPreviewItemWidget(widget.sceneRelations.composition?.keyframes?.start, SceneStoryboardTypeEnum.start_frame));
      list.add(_buildPreviewItemWidget(widget.sceneRelations.composition?.keyframes?.end, SceneStoryboardTypeEnum.end_frame));
    }else if(frameMode == 3){
      list.add(_buildPreviewItemWidget(widget.sceneRelations.composition?.keyframes?.start, SceneStoryboardTypeEnum.start_frame));
      list.add(_buildPreviewItemWidget(widget.sceneRelations.composition?.keyframes?.highlight, SceneStoryboardTypeEnum.highlight_frame));
      list.add(_buildPreviewItemWidget(widget.sceneRelations.composition?.keyframes?.end, SceneStoryboardTypeEnum.end_frame));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          "关键帧预览",
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SelectableText(
          "下方只显示当前模式会实际使用到的图片。点击图片可放大。",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),

        SizedBox(height: 6.wMin),

        Row(
          spacing: 16.wMin,
          children: list,
        ),
      ],
    );
  }

  Widget _buildPreviewItemWidget(ManageVisualProjectEntitySceneRelationsCompositionImage? image, SceneStoryboardTypeEnum type){
    List<String> imageUrls = [];
    if(frameMode == 1){
      if(widget.sceneRelations.composition?.keyframes?.start?.imageUrl != null){
        imageUrls.add(widget.sceneRelations.composition?.keyframes?.start?.imageUrl??"");
      }
    }else if(frameMode == 2){
      if(widget.sceneRelations.composition?.keyframes?.end?.imageUrl != null){
        imageUrls.add(widget.sceneRelations.composition?.keyframes?.start?.imageUrl??"");
      }
      if(widget.sceneRelations.composition?.keyframes?.end?.imageUrl != null){
        imageUrls.add(widget.sceneRelations.composition?.keyframes?.end?.imageUrl??"");
      }
    }else if(frameMode == 3){
      if(widget.sceneRelations.composition?.keyframes?.start?.imageUrl != null){
        imageUrls.add(widget.sceneRelations.composition?.keyframes?.start?.imageUrl??"");
      }
      if(widget.sceneRelations.composition?.keyframes?.highlight?.imageUrl != null){
        imageUrls.add(widget.sceneRelations.composition?.keyframes?.highlight?.imageUrl??"");
      }
      if(widget.sceneRelations.composition?.keyframes?.end?.imageUrl != null){
        imageUrls.add(widget.sceneRelations.composition?.keyframes?.end?.imageUrl??"");
      }
    }

    return Expanded(
      child: TapScaleWidget(
        onTap: () {
          if(image?.imageUrl == null) return;
          ShowBigResourceDialog.showImage(
            context: context, 
            imageUrls: imageUrls,
            index: imageUrls.indexOf(image?.imageUrl??""),
          );
        },
        sclae: 1.01,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.wMin),
          child: Container(
            color: AppTheme.cSurfaceTertiary.color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CachedImageWidget(
                            image?.imageUrl??"",
                            fit: BoxFit.cover,
                            placeholder: buildEmptyWidget(fit: BoxFit.cover),
                            errorWidget: buildEmptyWidget(fit: BoxFit.cover),
                          ),
                        ),
            
                        Positioned(
                          right: 10.wMin,
                          bottom: 10.wMin,
                          child: ManageImageToolBRWidgets(
                            imageUrl: image?.imageUrl,
                          ),
                        ),
            
                      ],
                    ),
                  ),
            
                  SizedBox(height: 8.wMin),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    child: SelectableText(
                      type.name,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.wMin),
            
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSegmentationWidget(){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SelectableText(
                  "开启分段生成",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),

                SelectableText(
                  "对应接口字段 `relay_enable`。开启后会走分段生成策略，默认开启。",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
                  ),
                ),
              ],
            ),
          ),

          CardSwitchWidget(
            width: 60.wMin,
            height: 32.wMin,
            value: isSegmentation,
            onChanged: (value) {
              setState(() {
                isSegmentation = value;
              });
            },
          )

        ],
      ),
    );
  }


  /// 生成数量
  Widget _buildGenerateWidget(){
    return Row(
      spacing: 16.wMin,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [

        Expanded(
          child: ManageZhenduDropdownWidget(
            title: "生成数量",
            selectValue: generateCount,
            items: List.generate(4, (index){
              return IconDropdownCheckData<int>(
                title: "${index+1}",
                value: index+1,
              );
            }),
            onChanged: (choiceData, index) {
              setState(() {
                generateCount = choiceData.value;
              });
            },
          ),
        ),

        // Expanded(
        //   child: Container(
        //     padding: EdgeInsets.all(16.wMin),
        //     decoration: BoxDecoration(
        //       borderRadius: BorderRadius.circular(16.wMin),
        //       color: AppTheme.cSurfaceTertiary.color,
        //     ),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         SelectableText(
        //           "当前默认组合",
        //           style: TextStyle(
        //             fontSize: 18.wMin,
        //             fontWeight: FontWeight.w400,
        //             color: AppTheme.cTextPrimary.color,
        //           ),
        //         ),
        //         SizedBox(height: 4.wMin),
        //         SelectableText(
        //           "默认推荐 `frames=2`（首尾帧） + `relay_enable=true`（开启分段生成）。",
        //           style: TextStyle(
        //             fontSize: 16.wMin,
        //             fontWeight: FontWeight.w400,
        //             color: AppTheme.cTextTertiary.color,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),

      ],
    );
  }

  /// 导演意图
  Widget _buildDirectorWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          "导演意图 (可选)",
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SizedBox(height: 6.wMin),
        ManageZhenduInputHeightWidget(
          controller: directorIntentController,
          maxLines: 10,
          hintText: "例如：Slow push-in with gentle emotional pause",
          height: 100.wMin,
        ),
      ],
    );
  }


}



class ManageVisualProjectGenerateVideoTransitionDialogWidget extends StatefulWidget {
  /// 项目ID
  final int projectId;

  /// 场景关系
  final ManageVisualProjectEntitySceneRelations scene1;
  final ManageVisualProjectEntitySceneRelations scene2;

  const ManageVisualProjectGenerateVideoTransitionDialogWidget({
    required this.projectId,
    required this.scene1,
    required this.scene2,
    super.key,
  });

  @override
  State<ManageVisualProjectGenerateVideoTransitionDialogWidget> createState() => _ManageVisualProjectGenerateVideoTransitionDialogWidgetState();
}

class _ManageVisualProjectGenerateVideoTransitionDialogWidgetState extends State<ManageVisualProjectGenerateVideoTransitionDialogWidget> {

  /// 是否开始分段生成
  bool isSegmentation = true;

  /// 生成数量
  int generateCount = 4;

  /// 导演意图
  TextEditingController directorIntentController = TextEditingController();

  /// 确认生成
  Future<void> confirmGenerate() async{
    
    try {
      ToastUtils.showLoading();

      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "projectId": widget.projectId,
        "sceneIds": [widget.scene1.sceneId, widget.scene2.sceneId],
        "numberOfVideos": generateCount,
        "relayEnable": isSegmentation,
        "frames": 2,
        "directorialIntent": directorIntentController.text,
      };
      String? res = await LanguageConsoleDramaRequest.visualGenerateTransitionVideo(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
      Get.back();
    } finally{
      ToastUtils.hideLoading();
    }

  }

  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "配置场景视频生成",
      width: 1000.wMin,
      cancelText: "关闭",
      onCancel: () => Get.back(),
      confirmText: "确认生成",
      onConfirm: () {
        confirmGenerate();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        height: 800.wMin,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleWidget(),
              SizedBox(height: 16.wMin),
              Container(height: 1.wMin, color: AppTheme.cBorderSecondary.color),
              SizedBox(height: 16.wMin),
              _buildModeWidget(),
              SizedBox(height: 24.wMin),
              _buildPreviewWidget(context),
              SizedBox(height: 24.wMin),
              _buildSegmentationWidget(),
              SizedBox(height: 24.wMin),
              _buildGenerateWidget(),
              SizedBox(height: 24.wMin),
              _buildDirectorWidget(),
          
              SizedBox(height: 24.wMin),
              Container(height: 1.wMin, color: AppTheme.cBorderSecondary.color),
          
          
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWidget(){
    int sceneIndex1 = widget.scene1.index??0;
    String sceneTitle1 = widget.scene1.sceneTitle ?? "";

    int sceneIndex2 = widget.scene2.index??0;
    String sceneTitle2 = widget.scene2.sceneTitle ?? "";

    return SelectableText(
      "Scene: Scene $sceneIndex1 - $sceneTitle1 → $sceneIndex2 - $sceneTitle2",
      style: TextStyle(
        fontSize: 16.wMin,
        fontWeight: FontWeight.w400,
        color: AppTheme.cTextTertiary.color,
      ),
    );
  }

  Widget _buildModeWidget(){

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceBrand.withValues(alpha: 0.2),
        border: Border.all(
          color: AppTheme.cSurfaceBrand.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    
          Text(
            "关键帧模式",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          Text(
            "过渡视频固定使用 `frames=2`，即“首尾帧模式”：以前一场 `end_frame` 作为首帧，后一场 `start_frame` 作为尾帧。",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
    
        ],
      ),
    );
  }

  /// 关键帧预览
  Widget _buildPreviewWidget(BuildContext context){

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          "关键帧预览",
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),

        SizedBox(height: 6.wMin),

        Row(
          spacing: 16.wMin,
          children: [

            _buildPreviewItemWidget(
              widget.scene1, 
              SceneStoryboardTypeEnum.end_frame,
            ),
            _buildPreviewItemWidget(
              widget.scene2, 
              SceneStoryboardTypeEnum.start_frame,
            ),

          ],
        ),
      ],
    );
  }

  Widget _buildPreviewItemWidget(ManageVisualProjectEntitySceneRelations scene, SceneStoryboardTypeEnum type){
    List<String> imageUrls = [];

    if(scene.composition?.keyframes?.end?.imageUrl != null){
      imageUrls.add(scene.composition?.keyframes?.end?.imageUrl??"");
    }

    if(scene.composition?.keyframes?.start?.imageUrl != null){
      imageUrls.add(scene.composition?.keyframes?.start?.imageUrl??"");
    }

    ManageVisualProjectEntitySceneRelationsCompositionImage? image = scene.composition?.keyframes?.end;
    if(type == SceneStoryboardTypeEnum.start_frame){
      image = scene.composition?.keyframes?.start;
    }

    return Expanded(
      child: TapScaleWidget(
        onTap: () {
          if(image?.imageUrl == null) return;
          ShowBigResourceDialog.showImage(
            context: context, 
            imageUrls: imageUrls,
            index: imageUrls.indexOf(image?.imageUrl??""),
          );
        },
        sclae: 1.01,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.wMin),
          child: Container(
            color: AppTheme.cSurfaceTertiary.color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CachedImageWidget(
                            image?.imageUrl??"",
                            fit: BoxFit.cover,
                            placeholder: buildEmptyWidget(fit: BoxFit.cover),
                            errorWidget: buildEmptyWidget(fit: BoxFit.cover),
                          ),
                        ),
            
                        Positioned(
                          right: 10.wMin,
                          bottom: 10.wMin,
                          child: ManageImageToolBRWidgets(
                            imageUrl: image?.imageUrl,
                          ),
                        ),
            
                      ],
                    ),
                  ),
            
                  SizedBox(height: 8.wMin),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          type.name,
                          style: TextStyle(
                            fontSize: 18.wMin,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.cTextPrimary.color,
                          ),
                        ),
                        SelectableText(
                          "Scene: ${scene.index??''} - ${scene.sceneTitle??''}",
                          style: TextStyle(
                            fontSize: 16.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextTertiary.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.wMin),
            
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentationWidget(){
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SelectableText(
                  "开启分段生成",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),

                SelectableText(
                  "对应接口字段 `relay_enable`。开启后会走分段生成策略，默认开启。",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
                  ),
                ),
              ],
            ),
          ),

          CardSwitchWidget(
            width: 60.wMin,
            height: 32.wMin,
            value: isSegmentation,
            onChanged: (value) {
              setState(() {
                isSegmentation = value;
              });
            },
          )

        ],
      ),
    );
  }


  /// 生成数量
  Widget _buildGenerateWidget(){
    return Row(
      spacing: 16.wMin,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [

        Expanded(
          child: ManageZhenduDropdownWidget(
            title: "生成数量",
            selectValue: generateCount,
            items: List.generate(4, (index){
              return IconDropdownCheckData<int>(
                title: "${index+1}",
                value: index+1,
              );
            }),
            onChanged: (choiceData, index) {
              setState(() {
                generateCount = choiceData.value;
              });
            },
          ),
        ),

        // Expanded(
        //   child: Container(
        //     padding: EdgeInsets.all(16.wMin),
        //     decoration: BoxDecoration(
        //       borderRadius: BorderRadius.circular(16.wMin),
        //       color: AppTheme.cSurfaceTertiary.color,
        //     ),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         SelectableText(
        //           "当前默认组合",
        //           style: TextStyle(
        //             fontSize: 18.wMin,
        //             fontWeight: FontWeight.w400,
        //             color: AppTheme.cTextPrimary.color,
        //           ),
        //         ),
        //         SizedBox(height: 4.wMin),
        //         SelectableText(
        //           "默认推荐 `frames=2`（首尾帧） + `relay_enable=true`（开启分段生成）。",
        //           style: TextStyle(
        //             fontSize: 16.wMin,
        //             fontWeight: FontWeight.w400,
        //             color: AppTheme.cTextTertiary.color,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),

      ],
    );
  }

  /// 导演意图
  Widget _buildDirectorWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          "导演意图 (可选)",
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SizedBox(height: 6.wMin),
        ManageZhenduInputHeightWidget(
          controller: directorIntentController,
          maxLines: 10,
          hintText: "例如：Slow push-in with gentle emotional pause",
          height: 100.wMin,
        ),
      ],
    );
  }


}