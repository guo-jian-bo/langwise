import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiz_play/models/models.dart';
import 'package:quiz_play/utils/utils.dart';
import 'package:resource_cache_package/resource_cache_package.dart';

import '../common/entities/entities.dart';

class CacheManagerUtils {
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
  Future<String> getShareDirPath() async {
    final tempDir = await getApplicationCacheDirectory();
    final tempDirPath = Directory('${tempDir.path}${Platform.pathSeparator}$shareDirName');
    if (!tempDirPath.existsSync()) {
      tempDirPath.createSync(recursive: true);
    }
    return tempDirPath.path;
  }

  /// 清理分享临时文件
  Future<void> clearShareDir() async {
    final tempDir = await getApplicationCacheDirectory();
    final tempDirPath = Directory('${tempDir.path}${Platform.pathSeparator}$shareDirName');
    if (tempDirPath.existsSync()) {
      tempDirPath.deleteSync(recursive: true);
    }
  }

  /// 清除资源缓存
  Future<void> clearCache() async {
    final before = await ResourceCacheManager.instance.getAllCacheSizeBytes();
    log("清理前 ${before / 1024 / 1024}MB");

    await ResourceCacheManager.instance.clearAll();

    final after = await ResourceCacheManager.instance.getAllCacheSizeBytes();
    log("清理后 ${after / 1024 / 1024}MB");
  }

  /// [timeoutMilliseconds] 超时时长，如果为 null 则一直等待
  Future<String?> getFile(String? url, ResourceType type, {int? timeoutMilliseconds}) async {
    try {
      if (url == null || url.isEmpty) return null;
      if (!GetUtils.isURL(url)) return null;

      final ResourceCacheManager manager = ResourceCacheManager.instance;
      final bool isAlreadyCached = await manager.isCachedByUrl(url, type);
      final Stopwatch stopwatch = Stopwatch()..start();
      final Future<File> cacheFuture = manager.getOrDownload(url, type);
      final File cacheFile;
      if (timeoutMilliseconds != null && timeoutMilliseconds > 0) {
        cacheFile = await cacheFuture.timeout(Duration(milliseconds: timeoutMilliseconds));
      } else {
        cacheFile = await cacheFuture;
      }
      stopwatch.stop();
      if (!isAlreadyCached) {
        ErrorLogUtils.to.logInfo("[CacheManagerUtils] cached url:$url duration:${stopwatch.elapsed.inMilliseconds}ms");
      }

      return cacheFile.path;
    } on TimeoutException {
      ErrorLogUtils.to.logInfo("[CacheManagerUtils] timeout url:$url wait:${timeoutMilliseconds ?? 0}ms");
      return null;
    } catch (e) {
      ErrorLogUtils.to.logError("[CacheManagerUtils] fail url:$url err:${e.toString()}", null);
      return null;
    }
  }

  /// 缓存题目资源
  Future<void> cacheQuizAssets(List<QuizModel> data, {int? exerciseCurrentId, bool isQueue = false}) async {
    ErrorLogUtils.to.logInfo("[CacheManagerUtils] ${data.length} currentId:$exerciseCurrentId");
    try {
      if (data.isEmpty) return;

      // 优先缓存当前题资源
      final int waitCacheIndex = data.indexWhere((item) => item.uid == exerciseCurrentId);
      final int targetIndex = waitCacheIndex >= 0 ? waitCacheIndex : 0;

      await _cacheQuizImgAudio(data[targetIndex], isQueue: isQueue);

      for (int i = 0; i < data.length; i++) {
        if (i == targetIndex) continue;
        // 剩余题目改为后台缓存，避免进入页面时串行等待。
        if(isQueue){
          await _cacheQuizImgAudio(data[i], isQueue: isQueue);
        }else{
          unawaited(_cacheQuizImgAudio(data[i], isQueue: isQueue));
        }
      }
    } catch (e) {
      ErrorLogUtils.to.logError("[CacheManagerUtils] ${e.toString()}", null);
    }
  }

  /// 缓存字母资源
  Future<List<QuizLettersModel>?> cacheLetterAssets(List<ConfigEntityLetters?>? letters) async {
    if (letters == null) return null;
    List<QuizLettersModel> lettersReslut = [];

    for (int i = 0; i < letters.length; i++) {
      if (letters[i] == null) continue;
      lettersReslut.add(QuizLettersModel(
        letter: letters[i]!.letter,
        imageUrl: letters[i]!.imageUrl,
        audioUrl: letters[i]!.audioUrl,
        audioFileUrl: await getFile(letters[i]!.audioUrl, ResourceType.audio),
      ));
    }

    return lettersReslut;
  }

  Future<QuizModel?> _cacheQuizImgAudio(QuizModel data, {bool isQueue = false}) async {
    try {
      // 题干音频缓存超时时长
      int audioTimeoutMilliseconds = 3000;
      if(data.type == ExerciseType.CLOZE_TEST || data.type == ExerciseType.CLOZE_TEST_B
        || data.type == ExerciseType.CONTEXT_CHOICE || data.type == ExerciseType.CONTEXT_CHOICE_B){
        audioTimeoutMilliseconds = 10000; // 文章题目的音频
      }else if(data.type == ExerciseType.SENTENCE_CLOZE || data.type == ExerciseType.CONTRAST_CLOZE){
        audioTimeoutMilliseconds = 5000; // 句子
      }

      List<QuizModelStems?> itemStems = data.stems ?? [];
      for (QuizModelStems? stems in itemStems) {
        if (stems == null) continue;
        if(isQueue){
          stems.imageFileUrl = await getFile(stems.imageUrl, ResourceType.image, timeoutMilliseconds: 2000);
        }else{
          getFile(stems.imageUrl, ResourceType.image, timeoutMilliseconds: 2000).then((value){
            stems.imageFileUrl = value;
          });
        }
        stems.audioFileUrl = await getFile(stems.audioUrl, ResourceType.audio, timeoutMilliseconds: audioTimeoutMilliseconds);
        stems.video?.videoFileUrl = await getFile(stems.video?.videoUrl, ResourceType.video, timeoutMilliseconds: 3000);
      }

      List<QuizModelOptions?> options = data.options ?? [];
      for (QuizModelOptions? option in options) {
        if (option == null) continue;
        if(isQueue){
          option.imageFileUrl = await getFile(option.imageUrl, ResourceType.image, timeoutMilliseconds: 2000);
        }else{
          getFile(option.imageUrl, ResourceType.image, timeoutMilliseconds: 2000).then((value){
            option.imageFileUrl = value;
          });
        }
        option.audioFileUrl = await getFile(option.audioUrl, ResourceType.audio, timeoutMilliseconds: 3000);
        option.video?.videoFileUrl = await getFile(option.video?.videoUrl, ResourceType.video, timeoutMilliseconds: 3000);
      }

      List<QuizModelQuestions?> questions = data.questions ?? [];
      for (QuizModelQuestions? question in questions) {
        if (question == null) continue;
        if(isQueue){
          question.imageFileUrl = await getFile(question.imageUrl, ResourceType.image, timeoutMilliseconds: 2000);
        }else{
          getFile(question.imageUrl, ResourceType.image, timeoutMilliseconds: 2000).then((value){
            question.imageFileUrl = value;
          });
        }
        question.audioFileUrl = await getFile(question.audioUrl, ResourceType.audio, timeoutMilliseconds: 3000);
        question.video?.videoFileUrl = await getFile(question.video?.videoUrl, ResourceType.video, timeoutMilliseconds: 3000);

        List<QuizModelQuestionsOptions?> questionOptions = question.options ?? [];
        for (QuizModelQuestionsOptions? option in questionOptions) {
          if (option == null) continue;
          option.audioFileUrl = await getFile(option.audioUrl, ResourceType.audio, timeoutMilliseconds: 3000);
          option.video?.videoFileUrl = await getFile(option.video?.videoUrl, ResourceType.video, timeoutMilliseconds: 3000);
        }
      }

      return data;
    } catch (e) {
      ErrorLogUtils.to.logError("[CacheManagerUtils] quizId:${data.uid} ${e.toString()}", null);
      return null;
    }
  }

}
