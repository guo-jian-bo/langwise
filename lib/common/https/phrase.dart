import 'package:api/api.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:wise_http/wise_http.dart';

class PhraseUtil {
  // 创建
  static Future<ResponseEntity<EnPhraseEntity?>> create({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/phrase/create", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<EnPhraseEntity?>.fromJson(response, fromJson: (json) => EnPhraseEntity.fromJson(json));
  }

  // 短语匹配
  static Future<ResponseEntity> match({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/phrase/match/detail", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity.fromJson(response);
  }

  // 编辑
  static Future<ResponseEntity<EnPhraseEntity?>> edit({required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/phrase/$uid/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<EnPhraseEntity?>.fromJson(response, fromJson: (json) => EnPhraseEntity?.fromJson(json));
  }
}
