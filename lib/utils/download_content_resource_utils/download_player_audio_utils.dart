import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:langwise/utils/utils.dart';
import 'package:open_file/open_file.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:wise_http/wise_http.dart';

import '../../app/routes/routes.dart';
import '../../app/routes/tag_routes.dart';
import '../../common/entities/entities.dart';
import '../../common/enum/enum.dart';
import '../../common/https/https.dart';
import '../../common/widgets/widgets.dart';
import 'course_details_target_download_pay_dialog.dart';

class DownloadPlayerAudioUtils{
  
  static Future<void> downloadAudio({
    required BuildContext context,
    required ZhenduDetilEntity? song,
  }) async{
    if(Platform.isAndroid || Platform.isIOS){
      ToastUtils.showToast(text: "请在电脑端(Windows/MacOS)打开并下载资源");
      return;
    }
    if(song == null) return;
    
    await getSelectedDownloadPrice(context: context, song: song);
  }

  /// 获取选中资源的价格信息
  static Future<void> getSelectedDownloadPrice({
    required BuildContext context,
    required ZhenduDetilEntity song,
  }) async {
    try {
      List<Map<String, dynamic>> selectedKnowledgeList = [{
        "type": song.contentType,
        "uid": song.contentInfo?.contentId,
      }];

      List<String> selectedDownloadList = [
        KnowledgeResourceType.audio.value,
        KnowledgeResourceType.lrc.value,
      ];

      Map<String, dynamic> reqData = {
        "contentList": selectedKnowledgeList,
        "resources": selectedDownloadList,
      };

      ToastUtils.showLoading();
      KnowledgeDownloadInfoEntity? entity = await OfficialCourseDetailsRequest.getKnowledgePrice(data: reqData);
      if (entity == null) return;

      CourseDetailsTargetDownloadPayDialogAction res = await CourseDetailsTargetDownloadPayDialog.show(
        context: context,
        entity: entity,
      );
      if (res == CourseDetailsTargetDownloadPayDialogAction.cancel) return;
      if (res == CourseDetailsTargetDownloadPayDialogAction.goToRecharge) {
        dynamic result = await TagRoutes.toNamed(
          Routes.RECHARGE_NAIBI,
          arguments: {
            "pageType": 1,
          },
        );
        if (result == null) return;
        if (result != true) return;
        return await getSelectedDownloadPrice(context: context, song: song);
      }
      if (res == CourseDetailsTargetDownloadPayDialogAction.confirmPay) {
        getKnowledgeDownloadInfo(context, reqData);
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  // 请求知识点下载信息
  static Future<void> getKnowledgeDownloadInfo(BuildContext context, Map<String, dynamic>? reqData) async {
    String? selectDirectory = await FilePicker.getDirectoryPath();
    if (selectDirectory == null) return;

    try {
      ToastUtils.showLoading();
      TodayKnowledgeEntity? res = await OfficialCourseDetailsRequest.getKnowledgeDownloadInfo(
        data: reqData,
      );
      if (res == null) return;
      startDownload(context, res, selectDirectory);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  static Future<void> startDownload(BuildContext context, TodayKnowledgeEntity entity, String selectDirectory) async{
    List<UnitKnowledgePointsEntityKnowledgeList?>? knowledgeList = entity.list;
    if (knowledgeList == null || knowledgeList.isEmpty) return;

    List<UnitKnowledgePointsEntityKnowledgeList> downloadDatas = [];
    for (var item in knowledgeList) {
      if (item == null) continue;
      downloadDatas.add(item);
    }

    String title =  knowledgeList.first?.title?? DateTime.now().millisecondsSinceEpoch.toString();
    title = FileUtils.sanitizePathSegment(title);

    String savePath = "$selectDirectory${Platform.pathSeparator}$title";

    String? audioLrc = knowledgeList.first?.audioLrc;
    String? audioUrl = knowledgeList.first?.audioUrl;

    if(audioUrl == null && audioLrc == null) return ToastUtils.showToast(text: "音频资源不存在");
    
    try {
      ToastUtils.showLoading();

        bool isDownloaded = false;
        if(audioLrc != null){
          await downloadSingleSubtitle(
            lrcStr: audioLrc,
            savePath: savePath,
            name: title,
            defaultType: "txt",
          );
          isDownloaded = await downloadSingleSubtitle(
            lrcStr: audioLrc,
            savePath: savePath,
            name: title,
            defaultType: "lrc",
          );
        }

        isDownloaded = await downloadSingleResource(
          orgUrl: audioUrl,
          savePath: savePath,
          name: title,
          defaultType: "mp3",
        );

        if(isDownloaded){
          if(!context.mounted){
            return ToastUtils.showToast(text: "下载完成", type: ToastType.success);
          }
          bool ask = await AskDialog.showUserAsk(
            context: context,
            title: "下载完成",
            content: "是否打开文件所在目录？",
          );
          if (!ask) return;
          OpenFile.open(savePath);
        } else {
          ToastUtils.showToast(text: "音频下载失败");
        }


    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 下载单个url资源
  static Future<bool> downloadSingleResource({
    required String? orgUrl,
    required String savePath,
    required String name,
    required String defaultType,
  }) async{
    try {
      if(orgUrl == null) return false;
      // 先检查本地有没有音频资源 如果有就直接复制到下载目录
      String? localFilePath = await CacheManagerUtils.instance.getFile(orgUrl, ResourceType.audio);
      String audioExtension = getKnowledgePointFileExtension(url: orgUrl)??defaultType;
      String saveFilePath = "$savePath${Platform.pathSeparator}$name.$audioExtension";
      if(await File(saveFilePath).exists()){
        return true;
      }
      if(localFilePath != null){
        await File(localFilePath).copy(saveFilePath);
        return true;
      }
      // 本地没有资源 就从网络下载
      Response response = await WiseHttp().download(
        orgUrl,
        saveFilePath,
      );
      if(response.statusCode != 200) return false;
      return true;
    } catch (e) {
      print("下载资源失败: $e");
    }

    return false;
  }

  /// 下载字幕
  static Future<bool> downloadSingleSubtitle({
    required String? lrcStr,
    required String savePath,
    required String name,
    required String defaultType,
  }) async{
    if(lrcStr == null) return false;
    String saveFilePath = "$savePath${Platform.pathSeparator}$name.$defaultType";
    // 判断文件是否存在 不存在就创建
    if(!await File(saveFilePath).exists()){
      await File(saveFilePath).create(recursive: true);
    }else{
      return true;
    }
    await File(saveFilePath).writeAsString(lrcStr);
    return true;
  }

  ///获取资源类型后缀
  static String? getKnowledgePointFileExtension({
    required String? url,
  }){
    if(url == null) return null;
    Uri uri = Uri.parse(url);
    return uri.pathSegments.last.split(".").last;
  }

}