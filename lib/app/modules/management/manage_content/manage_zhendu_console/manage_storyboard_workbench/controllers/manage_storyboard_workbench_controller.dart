import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resource_cache_package/resource_cache_package.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/mqtt_utils/mqtt_message_services_code.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';
import '../../manage_visual_project_detils/views/manage_visual_import_scene_image_dialog.dart';



class ManageStoryboardWorkbenchController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageStoryboardWorkbenchController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_STORYBOARD_WORKBENCH;

  @override
  String get breadcrumbTitle => '分镜工作台';

  // 传进来的参数
  /// 项目id
  int? projectId;
  /// 场景id
  int? sceneId;

  /// 剧本详情
  final Rx<ManageVisualProjectEntity> detilData = ManageVisualProjectEntity().obs;

  /// 当前场景详情
  final Rx<ManageVisualProjectEntitySceneRelations> sceneData = ManageVisualProjectEntitySceneRelations().obs;

  final TextEditingController promptInput = TextEditingController();

  /// 提示词信息
  final Rx<ManageVisualProjectPromptEntity> promptEntity = ManageVisualProjectPromptEntity().obs;

  /// 是否编辑提示词
  final RxBool isEditPrompt = false.obs;


  /// 裁剪百分比
  final RxInt clipPercent = 2.obs;

  StreamSubscription<PushMessageServiceEnitiy>? _messageSub;


  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
    if (Get.arguments!= null) {
      projectId = Get.arguments['projectId'];
      sceneId = Get.arguments['sceneId'];
      getDetilsData();
    }

    _messageSub = MqttNotificationMessage.instance.listenByCode(
      codes: [
        MqttMessageServicesCode.MESSAGE_STORYBOARD_PROMPT_CREATE,
        MqttMessageServicesCode.MESSAGE_IMAGE_TASK,
      ], 
      onData: (value){
        getDetilsData(showLoading: false, isGetPromptInfo: false);
      },
    );
  }

  Future<void> getDetilsData({bool showLoading = true, bool isGetPromptInfo = true}) async{
    if(projectId == null) return;
    try {
      if(showLoading) ToastUtils.showLoading();

      ManageVisualProjectEntity? res = await LanguageConsoleDramaRequest.getVisualProjectDetils(projectId!);
      if(res == null) return;
      detilData.value = res;

      sceneData.value = res.sceneRelations?.firstWhere((element) => element?.sceneId == sceneId) ?? ManageVisualProjectEntitySceneRelations();
      
      if(isGetPromptInfo) await getPromptInfo();

    } finally{
      if(showLoading) ToastUtils.hideLoading();
    }
  }

  /// 查询提示词信息
  Future<void> getPromptInfo() async{
    if(sceneData.value.promptId == null) return;
    try {
      Map<String, dynamic> reqData = {
        "promptId": sceneData.value.promptId,
      };
      ManageVisualProjectPromptEntity? res = await LanguageConsoleDramaRequest.getVisualProjectPromptInfo(data: reqData);
      if(res == null) return;
      promptEntity.value = res;
      promptInput.text = StringUtils.replaceAllLineBreak(res.prompt ?? '');
    } catch (_) {
      
    }
  }


  /// 保存提示词
  Future<void> savePrompt() async{
    String serverPrompt = StringUtils.replaceAllLineBreak(promptEntity.value.prompt ?? '');
    if(promptInput.text == serverPrompt){
      ToastUtils.showToast(text: "提示词未改变");
      isEditPrompt.value = false;
      return;
    }
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "promptId": sceneData.value.promptId,
        "prompt": promptInput.text,
      };
      bool response = await LanguageConsoleRequest.editImagePrompt(data: reqData);
      if(!response) return;
      ToastUtils.showToast(text: '修改成功', type: ToastType.success);
      promptEntity.value.prompt = promptInput.text;
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 打包下载
  Future<void> downloadPromptImages() async{
    if(promptEntity.value.referenceImages?.isEmpty == true){
      ToastUtils.showToast(text: "暂无可下载资源");
      return;
    }

    String? selectDirectory = await FilePicker.getDirectoryPath();
    if (selectDirectory == null) return;

    String zipPath = "$selectDirectory${Platform.pathSeparator}${getSceneName()}.zip";
    List<ManageVisualProjectPromptEntityReferenceImages?> referenceImages = promptEntity.value.referenceImages ?? [];
    Archive archive = Archive();

    try{
      ToastUtils.showLoading();

      for(final image in referenceImages){
        if(image?.url == null || image!.url!.isEmpty) continue;

        List<int>? bytes = await _loadPromptImageBytes(image);
        if(bytes == null || bytes.isEmpty) continue;

        String imageName = getImageName(image);
        if(imageName.isEmpty) continue;

        archive.addFile(ArchiveFile(imageName, bytes.length, bytes));
      }

      if(archive.files.isEmpty){
        ToastUtils.showToast(text: "图片资源获取失败");
        return;
      }

      List<int> zipBytes = ZipEncoder().encode(archive);
      if(zipBytes.isEmpty){
        ToastUtils.showToast(text: "压缩失败");
        return;
      }

      File zipFile = File(zipPath);
      if(await zipFile.exists()){
        await zipFile.delete();
      }
      await zipFile.writeAsBytes(zipBytes, flush: true);
      ToastUtils.showToast(text: "下载成功", type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }

  }

  /// 获取图片字节：优先读取本地缓存，缓存不存在时回退网络下载
  Future<List<int>?> _loadPromptImageBytes(ManageVisualProjectPromptEntityReferenceImages image) async{
    String? url = image.url;
    if(url == null || url.isEmpty) return null;

    String? localFilePath = await CacheManagerUtils.instance.getFile(url, ResourceType.image);
    if(localFilePath != null){
      File localFile = File(localFilePath);
      if(await localFile.exists()){
        return await localFile.readAsBytes();
      }
    }

    HttpClient httpClient = HttpClient();
    try{
      HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
      HttpClientResponse response = await request.close();
      if(response.statusCode != HttpStatus.ok){
        return null;
      }
      return await response.fold<List<int>>([], (previous, element){
        previous.addAll(element);
        return previous;
      });
    } catch (_) {
      return null;
    } finally{
      httpClient.close(force: true);
    }

  }

  ///获取资源类型后缀
  String getKnowledgePointFileExtension(String url){
    Uri uri = Uri.parse(url);
    return uri.pathSegments.last.split(".").last;
  }

  /// 获取文件夹分镜名称
  String getSceneName(){
    return "${detilData.value.title}_scene${sceneData.value.index??''}";
  }

  /// 获取图片文件名
  String getImageName(ManageVisualProjectPromptEntityReferenceImages? image){
    if(image?.url == null) return "";
    String ext = getKnowledgePointFileExtension(image!.url!);
    return "${getSceneName()}_image${image.refNo??''}.$ext";
  }

  /// 生成提示词
  Future<void> generatePrompt() async{
    if(projectId == null || sceneId == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "projectId": projectId,
        "sceneId": sceneId,
      };
      String? res = await LanguageConsoleDramaRequest.createVisualProjectPromptGenerate(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 生成分镜图
  Future<void> generateImage() async{
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_UNIFIED_IMAGE_CREATE,
      arguments: {
        "uid": sceneData.value.sceneId,
        "type": "SCRIPT_SCENE",
        "styleId": detilData.value.styleId,
        "promptId": promptEntity.value.promptId,
        "sceneType": SceneStoryboardTypeEnum.storyboard_sheet.value,
        "visualProjectId": projectId,
        "jumpCode": AppManageRoutesCode.storyboardWorkbench,
        "params": {
          "projectId": projectId,
          "sceneId": sceneId,
        },
      },
    );
  }

  /// 导入分镜图
  Future<void> showImportImage(BuildContext context) async{
    if(projectId == null) return;
    ManageVisualImportSceneImageDialog.show(
      context: context,
      projectId: projectId!,
      data: sceneData.value,
    );
  }

  /// 确认重新裁剪
  Future<void> reCrop() async{
    if(projectId == null || sceneId == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "projectId": projectId,
        "sceneId": sceneId,
        "marginRatio": clipPercent.value,
      };
      bool response = await LanguageConsoleDramaRequest.createVisualProjectSceneCrop(data: reqData);
      if(!response) return;
      ToastUtils.showToast(text: "裁剪成功", type: ToastType.success);
      getDetilsData();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 查看关键帧大图
  Future<void> showBigImage(BuildContext context, ManageVisualProjectEntitySceneRelationsCompositionImage? item) async{
    if(item?.imageUrl == null) return;
    List<String> imageUrls = [];
    if(sceneData.value.composition?.environment?.imageUrl != null){
      imageUrls.add(sceneData.value.composition!.environment!.imageUrl!);
    }
    if(sceneData.value.composition?.keyframes?.start?.imageUrl != null){
      imageUrls.add(sceneData.value.composition!.keyframes!.start!.imageUrl!);
    }
    if(sceneData.value.composition?.keyframes?.highlight?.imageUrl != null){
      imageUrls.add(sceneData.value.composition!.keyframes!.highlight!.imageUrl!);
    }
    if(sceneData.value.composition?.keyframes?.end?.imageUrl != null){
      imageUrls.add(sceneData.value.composition!.keyframes!.end!.imageUrl!);
    }
    
    ShowBigResourceDialog.showImage(
      context: context, 
      imageUrls: imageUrls,
      index: imageUrls.indexOf(item!.imageUrl!),
    );
  }



  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
    _messageSub?.cancel();
  }
}
