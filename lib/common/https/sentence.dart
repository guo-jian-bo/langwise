import 'package:api/api.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:wise_http/wise_http.dart';

class SentenceUtil {
  // 获取句型
  static Future<ResponseEntity<ListResponseEntity<SentencePatternEntity<ComponentEntity>>>> fetchPatternPages(
      {required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/sentence/pattern/pages", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ListResponseEntity<SentencePatternEntity<ComponentEntity>>>.fromJson(response,
        fromJson: (json) => ListResponseEntity<SentencePatternEntity<ComponentEntity>>.fromJson(json,
            fromJson: (json) => SentencePatternEntity<ComponentEntity>.fromJson(json,
                fromJson: (json) => ComponentEntity.fromJson(json))));
  }

  // 创建
  static Future<ResponseEntity<SentencePatternEntity?>> createPattern({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/sentence/pattern/create", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<SentencePatternEntity?>.fromJson(response,
        fromJson: (json) => SentencePatternEntity.fromJson(json));
  }

  // 编辑句型
  static Future<ResponseEntity<SentencePatternEntity?>> editPattern(
      {required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/sentence/pattern/$uid/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<SentencePatternEntity?>.fromJson(response,
        fromJson: (json) => SentencePatternEntity.fromJson(json));
  }

  // 创建句子
  static Future<ResponseEntity<EnSentenceEntity?>> createSentence({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/sentence/create", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<EnSentenceEntity?>.fromJson(response, fromJson: (json) => EnSentenceEntity.fromJson(json));
  }

  // 编辑句子
  static Future<ResponseEntity<EnSentenceEntity?>> editSentence(
      {required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/sentence/$uid/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<EnSentenceEntity?>.fromJson(response, fromJson: (json) => EnSentenceEntity.fromJson(json));
  }

  // 句子匹配
  static Future<ResponseEntity> match({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/sentence/match/detail", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity.fromJson(response);
  }
}
