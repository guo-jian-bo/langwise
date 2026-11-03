import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';

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

  /// 去审核字幕
  Future<void> toReviewAssPage() async{
    List<int?> assTaskIds = detilData.value.videoInfo?.assTaskIds ?? [];
    if(assTaskIds.isEmpty) return ToastUtils.showToast(text: "暂无待审核字幕");
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_ASS,
      arguments: {
        "taskIds": assTaskIds,
      },
    );
    getDetilsData();
  }

  /// 生成字幕
  Future<void> generateKeyframeSubtitles(BuildContext context) async{
    if(detilData.value.videoInfo?.videoId == null) return ToastUtils.showToast(text: "缺少videoId，无成品视频");

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "videoUid": detilData.value.videoInfo?.videoId,
      };
      String? res = await LanguageConsoleRequest.assReviewCreateVideoAlign(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 去编辑字幕页面
  Future<void> toEditAssPage() async{
    if(detilData.value.videoInfo?.assId == null) return ToastUtils.showToast(text: "缺少assId");
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_ASS_DETILS,
      arguments: {
        "assId": detilData.value.videoInfo?.assId,
      },
    );
    getDetilsData();
  }

  /// 去编辑翻译页面
  Future<void> toEditTranslatePage() async{
    if(detilData.value.videoInfo?.assId == null) return ToastUtils.showToast(text: "缺少assId");
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_ASS_TRANSLATE,
      arguments: {
        "assId": detilData.value.videoInfo?.assId,
      },
    );
    getDetilsData();
  }

  /// 生成翻译
  Future<void> generateKeyframeTranslate() async{
    if(detilData.value.videoInfo?.assId == null) return ToastUtils.showToast(text: "缺少assId");
    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "assId": detilData.value.videoInfo?.assId,
      };
      String? res = await LanguageConsoleRequest.assReviewCreateTranslate(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
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
        ass: detilData.value.videoInfo?.ass,
        translate: detilData.value.videoInfo?.translate,
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
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_SUBTITLE_MAPPING,
      arguments: {
        'projectId': projectId,
        'projectName': detilData.value.title,
        
      },
    );
    getDetilsData();
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


  /// 分镜工作台
  Future<void> toStoryboardWorkbench(ManageVisualProjectEntitySceneRelations scene) async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_STORYBOARD_WORKBENCH,
      arguments: {
        'projectId': projectId,
        'sceneId': scene.sceneId,
      },
    );
    getDetilsData();
  }



  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
