import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/delete_dialog.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:resource_cache_package/resource_cache_package.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';
import '../views/manage_visual_project_import_video_dialog.dart';

class ManageVisualProjectSynthesisVideoController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageVisualProjectSynthesisVideoController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_VISUAL_PROJECT_SYNTHESIS_VIDEO;

  @override
  String get breadcrumbTitle => '视频合成';

  /// 传进来的参数
  int? projectId;

  /// 项目详情
  final Rx<ManageVisualProjectEntity> detilData = ManageVisualProjectEntity().obs;

  /// 选择的场景id
  final RxList<int> selectedSceneIds = <int>[].obs;

  /// 视频片段列表
  final RxList<ManageVisualSceneVideoEntity> sceneVideoList = <ManageVisualSceneVideoEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
    if(Get.arguments != null){
      projectId = Get.arguments['projectId'];
      initData();
    }
  }

  Future<void> initData() async{
    if(projectId == null) return;
    try {
      ToastUtils.showLoading();
      await getProjectDetail();
      await getSceneVideoList();
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 获取项目详情
  Future<void> getProjectDetail() async{
    if(projectId == null) return;
    try {
      ManageVisualProjectEntity? res = await LanguageConsoleDramaRequest.getVisualProjectDetils(projectId!);
      if(res == null) return;
      detilData.value = res;
    } finally{}
  }

  /// 获取片段视频列表
  Future<void> getSceneVideoList() async{
    if(projectId == null) return;
    try {
      Map<String, dynamic> reqData = {
        "projectId": projectId,
      };
      List<ManageVisualSceneVideoEntity>? res = await LanguageConsoleDramaRequest.getVisualSceneVideo(data: reqData);
      if(res == null) return;
      sceneVideoList.value = res;
    } finally{}
  }

  /// 选择场景
  void selectScene(int? sceneId){
    if(sceneId == null) return;
    if(selectedSceneIds.contains(sceneId)){
      selectedSceneIds.remove(sceneId);
    } else{
      // 最多只能选择两个
      if(selectedSceneIds.length >= 2){
        selectedSceneIds.clear();
      }
      // 只能选择前后相邻的场景
      if(selectedSceneIds.isNotEmpty){
        if(selectedSceneIds.last != sceneId - 1 && selectedSceneIds.last != sceneId + 1){
          ToastUtils.showToast(text: "只能选择相邻的两个场景来生成过渡视频");
          return;
        }
      }
      selectedSceneIds.add(sceneId);
    }
  }


  /// 获取打包下载zip名称
  String getDownloadZipName(){
    return "${detilData.value.title ?? ""}_video_segments.zip";
  }

  /// 打包下载视频
  Future<void> downloadVideoZip() async{
    List<ManageVisualSceneVideoEntity> list = [];
    for (var element in sceneVideoList) {
      if(element.video?.videoUrl == null) continue;
      list.add(element);
    }
    if(list.isEmpty){
      return ToastUtils.showToast(text: "暂无可下载资源");
    }
    String? selectDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectDirectory == null) return;
    String zipPath = "$selectDirectory${Platform.pathSeparator}${getDownloadZipName()}";
    
    Archive archive = Archive();

    try{
      ToastUtils.showLoading();

      for(int i = 0; i < list.length; i++){
        if(list[i].video?.videoUrl == null) continue;

        List<int>? bytes = await _loadPromptVideoBytes(list[i]);
        if(bytes == null || bytes.isEmpty) continue;

        Uri uri = Uri.parse(list[i].video!.videoUrl!);
        String suff = uri.pathSegments.last.split(".").last;
        String numberStr = i.toString().padLeft(3, '0');
        String sceneIdsStr = list[i].sceneUids?.join('_') ?? '';

        String videoName = "${numberStr}_${list[i].type}_$sceneIdsStr.$suff";
        if(videoName.isEmpty) continue;

        archive.addFile(ArchiveFile(videoName, bytes.length, bytes));
      }

      if(archive.files.isEmpty){
        ToastUtils.showToast(text: "视频资源获取失败");
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

  /// 获取视频字节：优先读取本地缓存，缓存不存在时回退网络下载
  Future<List<int>?> _loadPromptVideoBytes(ManageVisualSceneVideoEntity video) async{
    String? url = video.video?.videoUrl;
    if(url == null || url.isEmpty) return null;

    String? localFilePath = await CacheManagerUtils.instance.getFile(url, ResourceType.video);
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

  /// 删除片段视频
  Future<void> deleteVideo(BuildContext context, ManageVisualSceneVideoEntity data) async{
    bool deleteRes = await DeleteDialog.show(
      context: context, 
      title: "删除视频片段",
      content: "确定要删除 uid:${data.uid??''} 视频片段吗？",
      showCountdown: false,
    );
    if(!deleteRes) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "uid": data.uid,
      };
      bool res = await LanguageConsoleDramaRequest.visualDeleteVideo(parameters: parameters);
      if(!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      sceneVideoList.removeWhere((e) => e.uid == data.uid);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 视频片段排序
  Future<void> sortVideo(int index, int newIndex) async{
    try {
      ToastUtils.showLoading();
      ManageVisualSceneVideoEntity data = sceneVideoList.removeAt(index);
      sceneVideoList.insert(newIndex, data);

      Map<String, dynamic> reqData = {
        "uid": data.uid,
        "index": newIndex + 1,
      };
      bool res = await LanguageConsoleDramaRequest.visualVideoSort(data: reqData);
      if(!res) {
        getSceneVideoList();
        return;
      }
      ToastUtils.showToast(text: "排序成功", type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 待审核视频片段
  Future<void> toReviewVideo(ManageVisualSceneVideoEntity data) async{
    if(data.videoTaskId == null) return;
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_REVIEW_VIDEO_DETILS,
      arguments: {
        "videoTaskId": data.videoTaskId,
      },
    );
    getSceneVideoList();
  }

  /// 播放视频
  Future<void> showPlayVideo(BuildContext context, ManageVisualSceneVideoEntity data) async{
    ShowBigResourceDialog.showVideo(
      context: context, 
      aspectRatio: 16 / 9,
      relationVideo: EnKnowledgeEntityRelationVideo(
        videoUrl: data.video?.videoUrl,
        duration: data.video?.duration,
        firstImageUrl: data.scenes?.first?.startFrameUrl,
      ),
    );
  }


  /// 生成场景视频
  Future<void> generateSceneVideo() async{
    if(projectId == null) return;
    if(selectedSceneIds.isEmpty){
      ToastUtils.showToast(text: "请选择场景");
      return;
    }
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "projectId": projectId,
        "sceneId": selectedSceneIds.first,
      };
      String? res = await LanguageConsoleDramaRequest.visualGenerateSceneVideo(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 生成过渡视频
  Future<void> generateTransitionVideo() async{
    if(projectId == null) return;
    if(selectedSceneIds.isEmpty){
      ToastUtils.showToast(text: "请选择场景");
      return;
    }
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "projectId": projectId,
        "sceneIds": selectedSceneIds.toList(),
      };
      String? res = await LanguageConsoleDramaRequest.visualGenerateTransitionVideo(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 导入完整视频
  Future<void> importCompleteVideo(BuildContext context) async{
    if(projectId == null) return;
    ManageVisualProjectImportVideoDialog.show(
      context: context, 
      projectId: projectId!,
    );
  }

  /// 合成完整视频
  Future<void> generateFullVideo() async{
    if(projectId == null) return;
    if(selectedSceneIds.isEmpty){
      ToastUtils.showToast(text: "请选择场景");
      return;
    }
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "projectId": projectId,
      };
      String? res = await LanguageConsoleDramaRequest.visualGenerateFullVideo(data: reqData);
      if(res == null) return;
      ToastUtils.showToast(text: res, type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }


  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
