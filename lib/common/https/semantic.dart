import 'package:api/entities/entities.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:wise_http/wise_http.dart';

class SemanticUtil {
  // 获取语义
  static Future<ResponseEntity<ListResponseEntity<EnEntitySemantics>>> fetchPages(
      {required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/semantic/pages", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ListResponseEntity<EnEntitySemantics>>.fromJson(response,
        fromJson: (json) => ListResponseEntity<EnEntitySemantics>.fromJson(json,
            fromJson: (json) => EnEntitySemantics.fromJson(json)));
  }

  // 创建
  static Future<ResponseEntity<EnEntitySemantics?>> create({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/semantic/create", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<EnEntitySemantics?>.fromJson(response,
        fromJson: (json) => EnEntitySemantics.fromJson(json));
  }

  // 编辑
  static Future<ResponseEntity<EnEntitySemantics?>> edit(
      {required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/semantic/$uid/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<EnEntitySemantics?>.fromJson(response,
        fromJson: (json) => EnEntitySemantics.fromJson(json));
  }
}
