import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/dialog/dialogs.dart';
import 'package:langwise/app/modules/management/utils/manage_auth_utils.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../common/commons.dart';
import 'manage_visual_import_scene_image_dialog.dart';

/// 查看原始分镜弹窗
class ManageVisualViewOriginalSceneDialog{
  static Future<bool?> show({
    required BuildContext context,
    required int projectId,
    required int? imageTaskId,
    required ManageVisualProjectEntitySceneRelations data,
  }) async{
    
    return await showCupertinoDialog(
      context: context,
      builder: (context) {
        return ManageVisualViewOriginalSceneDialogWidget(
          projectId: projectId,
          imageTaskId: imageTaskId,
          data: data,
        );
      },
    );

  }
}

class ManageVisualViewOriginalSceneDialogWidget extends StatefulWidget {
  final int projectId;
  final int? imageTaskId;
  final ManageVisualProjectEntitySceneRelations data;
  const ManageVisualViewOriginalSceneDialogWidget({super.key, required this.projectId, required this.data, this.imageTaskId});

  @override
  State<ManageVisualViewOriginalSceneDialogWidget> createState() => _ManageVisualViewOriginalSceneDialogWidgetState();
}

class _ManageVisualViewOriginalSceneDialogWidgetState extends State<ManageVisualViewOriginalSceneDialogWidget> {

  ManageVisualProjectPromptEntity promptEntity = ManageVisualProjectPromptEntity();

  /// 是否显示裁剪信息
  bool showClipInfo = false;

  /// 裁剪百分比
  int _clipPercent = 2;
  

  @override
  void initState() {
    super.initState();
    getPromptInfo();
  }

  /// 查询提示词信息
  Future<void> getPromptInfo() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "promptId": widget.data.promptId,
      };
      ManageVisualProjectPromptEntity? res = await LanguageConsoleDramaRequest.getVisualProjectPromptInfo(data: reqData);
      if(res == null) return;
      promptEntity = res;
      if(mounted) setState(() {});
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 导入图片
  Future<void> showImportImage() async{
    ManageVisualImportSceneImageDialog.show(
      context: context,
      projectId: widget.projectId,
      data: widget.data,
    );
  }

  /// 生成图片
  Future<void> generateImage() async{
    String? inputRes = await PromptInputDialog.show(
      context: context, 
      prompt: promptEntity.prompt,
      confirmColor: AppTheme.cSurfaceBrand.color,
      confirmText: "根据提示词生成分镜图",
    );
    if(inputRes == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "visualProjectId": widget.projectId,
        "promptId": widget.data.promptId,
        "prompt": inputRes,
      };
      String? response = await LanguageConsoleDramaRequest.createVisualProjectSceneGenerate(data: reqData);
      if(response == null) return;
      ToastUtils.showToast(text: response, type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 审核图片
  Future<void> reviewImages() async{
    if(widget.data.imageId == null || widget.imageTaskId == null) return;
    try {
      ToastUtils.showLoading();
      var res = await ContentReviewImageUtil.approve(
        imageId: widget.data.imageId!,
        taskId: widget.imageTaskId!,
      );
      if(res == null) return;
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 确认重新裁剪
  Future<void> reCrop() async{
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "projectId": widget.projectId,
        "sceneId": widget.data.sceneId,
        "marginRatio": _clipPercent,
      };
      bool response = await LanguageConsoleDramaRequest.createVisualProjectSceneCrop(data: reqData);
      if(!response) return;
      ToastUtils.showToast(text: "裁剪成功", type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }


  @override
  Widget build(BuildContext context) {
    return ManageDialogBoxWidget(
      title: "原始分镜表 · Scene ${widget.data.index??''} - ${widget.data.sceneTitle??""}",
      width: 1300.wMin,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIdsWidget(),

            SizedBox(height: 16.wMin),

            _buildImageWidget(),

            SizedBox(height: 16.wMin),

            _buildClipInfoWidget(),

            SizedBox(height: 16.wMin),

            _buildButtonsWidget(),

            SizedBox(height: 16.wMin),
            
        
          ],
        ),
      ),
    );
  }

  Widget _buildIdsWidget(){
    return Row(
      spacing: 16.wMin,
      children: [
        SelectableText(
          "scene_uid: ${widget.data.sceneId??''}",
          style: TextStyle(
            fontSize: 18.wMin,
            color: AppTheme.cTextTertiary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
        ManageTagFS16Widget(
          tag: widget.data.statusEnum?.name,
          bgColor: widget.data.statusEnum?.bg,
          fontColor: widget.data.statusEnum?.font??AppTheme.cTextSecondary.color,
        ),
      ],
    );
  }

  Widget _buildImageWidget(){
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: SizedBox(
        width: double.infinity,
        child: TapScaleWidget(
          onTap: () {
            if(widget.data.imageUrl == null) return;
            ShowBigResourceDialog.showImage(context: context, imageUrls: [widget.data.imageUrl!]);
          },
          sclae: 1,
          child: CachedImageWidget(
            widget.data.imageUrl??"",
            fit: BoxFit.contain,
            placeholder: buildEmptyWidget(fit: BoxFit.cover),
            errorWidget: buildEmptyWidget(fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _buildClipInfoWidget(){
    if(!showClipInfo) return Container();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceTertiary.color,
      ),
      child: Row(
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6.wMin,
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
              
              if(_clipPercent > 0) _clipPercent--;
              if(mounted) setState(() {});

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
            child: Text(
              "$_clipPercent%",
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          TapScaleWidget(
            onTap: () {
              if(_clipPercent < 20) _clipPercent++;
              if(mounted) setState(() {});
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
            text: "确认裁剪",
            padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 8.wMin),
            borderRadius: 8.wMin,
            sclae: 1.03,
            color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
            border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceWarning.color),
            fontColor: AppTheme.cSurfaceWarning.color,
            fontSize: 20.wMin,
            onTap: OptimizeUtils.noneThrottle(() {
              reCrop();
            }, 300),
          ),

        ],
      ),
    );
  }

  Widget _buildButtonsWidget(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [

        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaVisualProjectStoryboardSheetImageImport],
          margin: EdgeInsets.only(right: 24.wMin),
          child: ButtonWidget(
            text: "导入",
            padding: EdgeInsets.symmetric(horizontal: 48.wMin, vertical: 8.wMin),
            borderRadius: 8.wMin,
            sclae: 1.03,
            color: AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2),
            border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceSuccess.color),
            fontColor: AppTheme.cSurfaceSuccess.color,
            fontSize: 20.wMin,
            onTap: OptimizeUtils.noneThrottle(() {
              showImportImage();
            }, 300),
          ),
        ),

        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaVisualProjectStoryboardSheetImageTaskByPrompt],
          margin: EdgeInsets.only(right: 24.wMin),
          child: ButtonWidget(
            text: "生成",
            padding: EdgeInsets.symmetric(horizontal: 48.wMin, vertical: 8.wMin),
            borderRadius: 8.wMin,
            sclae: 1.03,
            color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
            border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceBrand.color),
            fontColor: AppTheme.cSurfaceBrand.color,
            fontSize: 20.wMin,
            onTap: OptimizeUtils.noneThrottle(() {
              generateImage();
            }, 300),
          ),
        ),

        Visibility(
          visible: widget.imageTaskId != null,
          child: Container(
            margin: EdgeInsets.only(right: 24.wMin),
            child: ButtonWidget(
              text: "审核通过",
              padding: EdgeInsets.symmetric(horizontal: 48.wMin, vertical: 8.wMin),
              borderRadius: 8.wMin,
              sclae: 1.03,
              color: AppTheme.cFeedbackInfoText.color.withValues(alpha: 0.2),
              border: Border.all(width: 1.wMin, color: AppTheme.cFeedbackInfoText.color),
              fontColor: AppTheme.cFeedbackInfoText.color,
              fontSize: 20.wMin,
              onTap: OptimizeUtils.noneThrottle(() {
                reviewImages();
              }, 300),
            ),
          ),
        ),

        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaVisualProjectStoryboardSheetImageCrop],
          margin: EdgeInsets.only(right: 24.wMin),
          child: ButtonWidget(
            text: "裁剪关键帧",
            padding: EdgeInsets.symmetric(horizontal: 48.wMin, vertical: 8.wMin),
            borderRadius: 8.wMin,
            sclae: 1.03,
            color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
            border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceWarning.color),
            fontColor: AppTheme.cSurfaceWarning.color,
            fontSize: 20.wMin,
            onTap: OptimizeUtils.noneThrottle(() {
              showClipInfo = true;
              if(mounted) setState(() {});
            }, 300),
          ),
        ),

        ButtonWidget(
          text: "关闭",
          padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 8.wMin),
          onTap: () => Get.back(),
          borderRadius: 8.wMin,
          sclae: 1.05,
          color: Colors.transparent,
          border: Border.all(width: 2.wMin, color: AppTheme.cBorderPrimary.color),
          fontColor: AppTheme.cTextSecondary.color,
          fontSize: 20.wMin,
        ),

      ],
    );
  }

  
}