import 'dart:io';

import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:wise_http/wise_http.dart';

import '../../common/entities/entities.dart';
import '../utils.dart';

class DowmloadKnowledgeProgress{
  int audio = 0;
  int image = 0;
  int subtitle = 0;

  DowmloadKnowledgeProgress({
    this.audio = 0,
    this.image = 0,
    this.subtitle = 0,
  });
}

class DownloadKnowledgeUtils{

  /// 下载知识点资源
  static Future<bool> downloadKnowledgePoints({
    required List<UnitKnowledgePointsEntityKnowledgeList> knowledgeList,
    required String savePath,
    bool isDownloadSubtitle = true,
    bool isDownloadAudio = true,
    bool isDownloadImage = true,
    void Function(DowmloadKnowledgeProgress progress)? onProgress,
  }) async{

    try {
      /// 检查下载目录是否存在
      if(!await Directory(savePath).exists()){
        await Directory(savePath).create(recursive: true);
      }else{
        await Directory(savePath).delete(recursive: true);
      }
    

      int audioDownloaded = 0;
      int imageDownloaded = 0;
      int subtitleDownloaded = 0;

      int wordIndexNo = 0;
      int phraseIndexNo = 0;
      int sentenceIndexNo = 0;
      int textIndexNo = 0;
      int songIndexNo = 0;

      /// 下载资源
      for(int i = 0; i < knowledgeList.length; i++){
        UnitKnowledgePointsEntityKnowledgeList item = knowledgeList[i];

        int indexNo = 0;

        if(item.isWord){
          indexNo = wordIndexNo++;
        } else if(item.isPhrase){
          indexNo = phraseIndexNo++;
        } else if(item.isSentence){
          indexNo = sentenceIndexNo++;
        } else if(item.isText){
          indexNo = textIndexNo++;
        } else if(item.isSong){
          indexNo = songIndexNo++;
        }

        await downloadSingleKnowledgePoint(
          indexNo: indexNo,
          item: item,
          downloadFolderPath: savePath,
          isDownloadSubtitle: isDownloadSubtitle,
          isDownloadAudio: isDownloadAudio,
          isDownloadImage: isDownloadImage,
          onAudioCompleted: (audioCompleted) {
            if(audioCompleted){
              audioDownloaded++;
            }else{
              print("下载失败 音频 ${item.contentId}");
            }
          },
          onImageCompleted: (imageCompleted) {
            if(imageCompleted){
              imageDownloaded++;
            }else{
              print("下载失败 图片 ${item.contentId}");
            }
          },
          onSubtitleCompleted: (subtitleCompleted) {
            if(subtitleCompleted){
              subtitleDownloaded++;
            }else{
              print("下载失败 字幕 ${item.contentId}");
            }
          },
        );
        await Future.delayed(const Duration(milliseconds: 50));
        onProgress?.call(DowmloadKnowledgeProgress(
          audio: audioDownloaded,
          image: imageDownloaded,
          subtitle: subtitleDownloaded,
        ));
      }

      await Future.delayed(const Duration(seconds: 1));

      return true;

    } catch (e) {
      print("下载知识点资源失败: $e");
      return false;
    } 
  }

  /// 下载单个知识点资源
  static Future<bool> downloadSingleKnowledgePoint({
    required int indexNo,
    required UnitKnowledgePointsEntityKnowledgeList item,
    required String downloadFolderPath,
    bool isDownloadSubtitle = true,
    bool isDownloadAudio = true,
    bool isDownloadImage = true,
    void Function(bool audioCompleted)? onAudioCompleted,
    void Function(bool imageCompleted)? onImageCompleted,
    void Function(bool subtitleCompleted)? onSubtitleCompleted,
  }) async{
    
    try {
      // 资源类型文件夹
      String? savePath = await getKnowledgePointFolderName(
        item: item,
        downloadFolderPath: downloadFolderPath,
      );
      if(savePath == null) return false;

      // 资源名称
      String? name = getKnowledgePointDownloadName(item: item);
      if(name == null) return false;
      name = "${(indexNo + 1).toString().padLeft(3, '0')}-$name";
      if(isDownloadAudio){
        bool res = await downloadSingleResource(
          orgUrl: item.audioUrl,
          savePath: savePath,
          name: name,
          defaultType: "mp3",
        );
        onAudioCompleted?.call(res);
      }
      if(isDownloadImage){
        bool res = await downloadSingleResource(
          orgUrl: item.imageUrl,
          savePath: savePath,
          name: name,
          defaultType: "webp",
        );
        onImageCompleted?.call(res);
      }
      if(isDownloadSubtitle){
        await downloadSingleSubtitle(
          lrcStr: item.audioLrc,
          savePath: savePath,
          name: name,
          defaultType: "txt",
        );
        bool res = await downloadSingleSubtitle(
          lrcStr: item.audioLrc,
          savePath: savePath,
          name: name,
          defaultType: "lrc",
        );
        onSubtitleCompleted?.call(res);
      }
      return true;
    } catch (e) {
      return false;
    }
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



  ///获取资源类型后缀
  static String? getKnowledgePointFileExtension({
    required String? url,
  }){
    if(url == null) return null;
    Uri uri = Uri.parse(url);
    return uri.pathSegments.last.split(".").last;
  }

  /// 获取这个知识点的下载名称
  static String? getKnowledgePointDownloadName({
    required UnitKnowledgePointsEntityKnowledgeList item,
  }){
    String? name;
    if(item.isWord){
      name = item.content;
    }else if(item.isPhrase){
      name = item.content;
    }else if(item.isSentence){
      // 句子最多10个单词
      name = item.content?.split(" ").take(20).join(" ");
    }else if(item.isText){
      name = item.title;
    }else if(item.isSong){
      name = item.title;
    }
    return name == null ? null : FileUtils.sanitizePathSegment(name);
  }



  /// 下载知识点获取对应资源的文件夹名称
  static Future<String?> getKnowledgePointFolderName({
    required UnitKnowledgePointsEntityKnowledgeList item,
    required String downloadFolderPath,
  }) async{
    String? folderName = item.contentTypeTitle;
    if(folderName == null) return null;
    folderName = FileUtils.sanitizePathSegment(folderName);
    // 检查文件夹是否存在
    String folderPath = "$downloadFolderPath${Platform.pathSeparator}$folderName";
    if(!await Directory(folderPath).exists()){
      await Directory(folderPath).create(recursive: true);
    }
    
    return folderPath;
  }
  
  

}


