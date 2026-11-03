import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:langwise/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiz_play/models/models.dart';
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

  Future<String?> getFile(String? url, ResourceType type) async {
    try {
      if (url == null || url.isEmpty) return null;

      File chacheFile = await ResourceCacheManager.instance.getOrDownload(url, type);

      return chacheFile.path;
    } catch (e) {
      ErrorLogUtils.to.logError("[CacheManagerUtils] ${e.toString()}", null);
      return null;
    }
  }

  /// 缓存题目资源
  Future<void> cacheQuizAssets(List<QuizModel> data, {int? exerciseCurrentId}) async {
    try {
      if (data.isEmpty) return;

      // 进入做题页前只等待当前题；如果没有当前题 id，则回退等待第一题，
      // 这样既能保证首屏资源可用，又不会被整组题目的预缓存阻塞。
      final int waitCacheIndex = data.indexWhere((item) => item.uid == exerciseCurrentId);
      final int targetIndex = waitCacheIndex >= 0 ? waitCacheIndex : 0;

      _cacheQuizImgAudio(data[targetIndex]);

      for (int i = 0; i < data.length; i++) {
        if (i == targetIndex) continue;
        // 剩余题目改为后台缓存，避免进入页面时串行等待。
        unawaited(_cacheQuizImgAudio(data[i]));
      }
    } catch (e) {
      ErrorLogUtils.to.logError("[CacheManagerUtils] ${e.toString()}", null);
    }
  }

  /// 兼容旧调用名，当前策略已统一为：
  /// 只同步缓存当前题或第一题，其余题目后台缓存。
  Future<void> cacheQuizAssetsFirstTwo(List<QuizModel> data, {int? exerciseCurrentId}) async {
    await cacheQuizAssets(data, exerciseCurrentId: exerciseCurrentId);
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

  Future<QuizModel> _cacheQuizImgAudio(QuizModel data) async {
    List<QuizModelStems?> itemStems = data.stems ?? [];
    for (QuizModelStems? stems in itemStems) {
      if (stems == null) continue;
      _cacheImageInBackground(stems.imageUrl, (filePath) {
        stems.imageFileUrl = filePath;
      });
      stems.audioFileUrl = await getFile(stems.audioUrl, ResourceType.audio);
      stems.video?.videoUrl = await getFile(stems.video?.videoUrl, ResourceType.video);
    }

    List<QuizModelOptions?> options = data.options ?? [];
    for (QuizModelOptions? option in options) {
      if (option == null) continue;
      _cacheImageInBackground(option.imageUrl, (filePath) {
        option.imageFileUrl = filePath;
      });
      option.audioFileUrl = await getFile(option.audioUrl, ResourceType.audio);
    }

    List<QuizModelQuestions?> questions = data.questions ?? [];
    for (QuizModelQuestions? question in questions) {
      if (question == null) continue;
      _cacheImageInBackground(question.imageUrl, (filePath) {
        question.imageFileUrl = filePath;
      });
      question.audioFileUrl = await getFile(question.audioUrl, ResourceType.audio);

      List<QuizModelQuestionsOptions?> questionOptions = question.options ?? [];
      for (QuizModelQuestionsOptions? option in questionOptions) {
        if (option == null) continue;
        option.audioFileUrl = await getFile(option.audioUrl, ResourceType.audio);
      }
    }

    return data;
  }

  /// 图片缓存不阻塞做题页进入，完成后再异步回填本地文件路径。
  void _cacheImageInBackground(String? url, void Function(String? filePath) onComplete) {
    unawaited(() async {
      final String? filePath = await getFile(url, ResourceType.image);
      onComplete(filePath);
    }());
  }
}
