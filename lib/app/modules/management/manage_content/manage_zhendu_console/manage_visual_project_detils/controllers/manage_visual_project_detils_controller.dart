import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../routes/routes.dart';
import '../../enums/manage_visual_image_status_enum.dart';
import '../../../../utils/utils.dart';
import '../views/manage_visual_view_original_scene_dialog.dart';
import '../views/manage_visual_view_prompt_dialog.dart';

class ManageVisualProjectDetilsController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageVisualProjectDetilsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_VISUAL_PROJECT_DETILS;

  @override
  String get breadcrumbTitle => '视觉项详情目';

  /// 传进来的参数
  int? projectId;


  final Rx<ManageVisualProjectEntity> detilData = ManageVisualProjectEntity().obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
    if(Get.arguments != null){
      projectId = Get.arguments['projectId'];
      getDetilsData();
    }
  }

  Future<void> getDetilsData() async{
    if(projectId == null) return;
    try {
      ToastUtils.showLoading();

      ManageVisualProjectEntity? res = await LanguageConsoleDramaRequest.getVisualProjectDetils(projectId!);
      if(res == null) return;
      detilData.value = res;

    } finally{
      ToastUtils.hideLoading();
    }
  }


  /// 播放成品视频
  Future<void> playCompletedVideo(BuildContext context) async{
    if(detilData.value.videoInfo?.videoUrl == null) return;
    ShowBigResourceDialog.showVideo(
      context: context,
      aspectRatio: 16 / 9,
      relationVideo: EnKnowledgeEntityRelationVideo(
        videoId: detilData.value.videoInfo?.videoId,
        videoUrl: detilData.value.videoInfo?.videoUrl,
        duration: detilData.value.videoInfo?.duration,
      ),
    );
  }


  /// 查看大图
  Future<void> showBigImage(BuildContext context, ManageVisualProjectEntitySceneRelationsCompositionImage? item) async{
    if(item?.imageUrl == null) return;
    ShowBigResourceDialog.showImage(context: context, imageUrls: [item!.imageUrl!]);
  }

  /// 字幕映射
  Future<void> subtitleMapping() async{
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_SUBTITLE_MAPPING,
      arguments: {
        'projectId': projectId,
        'projectName': detilData.value.title,
        
      },
    );
  }


  /// 生成视频
  Future<void> generateVideo() async {
    ManagePageRegistry.jumpTo(
      Routes.MANAGE_VISUAL_PROJECT_SYNTHESIS_VIDEO,
      arguments: {
        'projectId': projectId,
      },
    );
  }

  /// 查看prompt
  Future<void> viewPrompt(BuildContext context, ManageVisualProjectEntitySceneRelations data) async {
    if(detilData.value.uid == null) return;
    ManageVisualViewPromptDialog.show(
      context: context, 
      projectId: detilData.value.uid!,
      data: data,
    );
  }

  /// 仅当上一个场景已审核时展示“分镜提示词”按钮
  bool canShowPromptButton(int currentIndex) {
    if (currentIndex <= 0) return true;
    final List<ManageVisualProjectEntitySceneRelations?>? sceneRelations = detilData.value.sceneRelations;
    if (sceneRelations == null || currentIndex >= sceneRelations.length) return false;
    final ManageVisualImageStatusEnum? previousStatus = sceneRelations[currentIndex - 1]?.statusEnum;
    return previousStatus == ManageVisualImageStatusEnum.image_checked ||
        previousStatus == ManageVisualImageStatusEnum.checked;
  }

  /// 查看原始分镜
  Future<void> viewOriginalSceneImage(BuildContext context, ManageVisualProjectEntitySceneRelations data) async {
    if(detilData.value.uid == null) return;
    bool? res = await ManageVisualViewOriginalSceneDialog.show(
      context: context,
      projectId: detilData.value.uid!,
      imageTaskId: data.imageTaskId,
      data: data,
    );
    if(res == true){
      getDetilsData();
    }
  }

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
