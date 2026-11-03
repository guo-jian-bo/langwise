import 'package:api/api.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:wise_http/wise_http.dart';

class TextUtil {
  // 创建
  static Future<ResponseEntity<EnKnowledgeEntity?>> create({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/text/create", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<EnKnowledgeEntity?>.fromJson(response, fromJson: (json) => EnKnowledgeEntity.fromJson(json));
  }

  // 编辑
  static Future<ResponseEntity<EnKnowledgeEntity?>> edit({required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/text/$uid/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<EnKnowledgeEntity?>.fromJson(response, fromJson: (json) => EnKnowledgeEntity?.fromJson(json));
  }
}
