import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:quiz_play/models/models.dart';
import 'package:resource_cache_package/resource_cache_package.dart';

import '../common/entities/entities.dart';

class CacheManagerUtils{

  factory CacheManagerUtils() => _getInstance();

  static CacheManagerUtils get instance => _getInstance();

  static ResourceCacheManager get resourceCacheManager => ResourceCacheManager.instance;

  static CacheManagerUtils? _instance;

  static CacheManagerUtils _getInstance() {
    _instance ??= CacheManagerUtils._internal();
    return _instance!;
  }

  CacheManagerUtils._internal();

  /// 分享 临时文件夹名称
  final String shareDirName = "share_temp";

  /// 分享 评测等级图片文件名
  final String evalLevelFileName = "eval_level.png";


  /// 获取分享临时目录
  Future<String> getShareDirPath() async{
    final tempDir = await getApplicationCacheDirectory();
    final tempDirPath = Directory('${tempDir.path}${Platform.pathSeparator}$shareDirName');
    if(!tempDirPath.existsSync()){
      tempDirPath.createSync(recursive: true);
    }
    return tempDirPath.path;
  }

  /// 清理分享临时文件
  Future<void> clearShareDir() async{
    final tempDir = await getApplicationCacheDirectory();
    final tempDirPath = Directory('${tempDir.path}${Platform.pathSeparator}$shareDirName');
    if(tempDirPath.existsSync()){
      tempDirPath.deleteSync(recursive: true);
    }
  }

  /// 清除资源缓存
  Future<void> clearCache() async{

    final before = await ResourceCacheManager.instance.getAllCacheSizeBytes();
    log("清理前 ${before / 1024 / 1024}MB");
    
    await ResourceCacheManager.instance.clearAll();

    final after = await ResourceCacheManager.instance.getAllCacheSizeBytes();
    log("清理后 ${after / 1024 / 1024}MB");
  }



  Future<String?> getFile(String? url, ResourceType type) async{
    try {
      if(url == null || url.isEmpty) return null;

      File chacheFile = await ResourceCacheManager.instance.getOrDownload(url, type);

      return chacheFile.path;
    } catch (e) {
      return null;
    }
  }

  /// 缓存题目资源
  Future<void> cacheQuizAssets(List<QuizModel> data, {int? exerciseCurrentId}) async{
    for(int i = 0; i < data.length; i++){
      if(exerciseCurrentId != null){
        if(data[i].uid == exerciseCurrentId){//缓存当前做到的题目
          await _cacheQuizImgAudio(data[i]);
        }
      }
      if(i == 0) {
        await _cacheQuizImgAudio(data[i]);
      }else{
        _cacheQuizImgAudio(data[i]);
      }
    }
  }

  /// 获取列表的前两个题目进行缓存
  Future<void> cacheQuizAssetsFirstTwo(List<QuizModel> data, {int? exerciseCurrentId}) async{
    if(data.isEmpty) return;
    await cacheQuizAssets([data[0]]);
    if(data.length > 1){
      await cacheQuizAssets([data[1]]);
    }
    for(int i = 2; i < data.length; i++){
      if(exerciseCurrentId == data[i].uid){
        await cacheQuizAssets([data[i]]);
        break;
      }
    }
  }

   /// 缓存字母资源
  Future<List<QuizLettersModel>?> cacheLetterAssets(List<ConfigEntityLetters?>? letters) async{
    if(letters == null) return null;
    List<QuizLettersModel> lettersReslut = [];

    for(int i = 0; i < letters.length; i++){
      if(letters[i] == null) continue;
      lettersReslut.add(QuizLettersModel(
        letter: letters[i]!.letter,
        imageUrl: letters[i]!.imageUrl,
        audioUrl: letters[i]!.audioUrl,
        audioFileUrl: await getFile(letters[i]!.audioUrl, ResourceType.audio)
      ));
    }

    return lettersReslut;
  }

  
  Future<QuizModel> _cacheQuizImgAudio(QuizModel data) async{

    List<QuizModelStems?> itemStems = data.stems??[];
    for(QuizModelStems? stems in itemStems){
      if(stems == null) continue;
      stems.imageFileUrl = await getFile(stems.imageUrl, ResourceType.image);
      stems.audioFileUrl = await getFile(stems.audioUrl, ResourceType.audio);
    }

    List<QuizModelOptions?> options = data.options??[];
    for(QuizModelOptions? option in options){
      if(option == null) continue;
      option.imageFileUrl = await getFile(option.imageUrl, ResourceType.image);
      option.audioFileUrl = await getFile(option.audioUrl, ResourceType.audio);
    }

    List<QuizModelQuestions?> questions = data.questions??[];
    for(QuizModelQuestions? question in questions){
      if(question == null) continue;
      question.imageFileUrl = await getFile(question.imageUrl, ResourceType.image);
      question.audioFileUrl = await getFile(question.audioUrl, ResourceType.audio);
    }

    return data;

  }

  

}

