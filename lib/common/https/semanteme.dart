import 'package:api/entities/entities.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:wise_http/wise_http.dart';

class SemantemeUtil {
  // 获取自拼
  static Future<ResponseEntity<ListResponseEntity<SemantemeResponseEntity>>> fetchPages(
      {required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/morpheme/pages", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ListResponseEntity<SemantemeResponseEntity>>.fromJson(response,
        fromJson: (json) => ListResponseEntity<SemantemeResponseEntity>.fromJson(json,
            fromJson: (json) => SemantemeResponseEntity.fromJson(json)));
  }

  // 创建
  static Future<ResponseEntity<SemantemeResponseEntity?>> create({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/morpheme/create", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<SemantemeResponseEntity?>.fromJson(response,
        fromJson: (json) => SemantemeResponseEntity.fromJson(json));
  }

  // 编辑
  static Future<ResponseEntity<SemantemeResponseEntity?>> edit(
      {required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/morpheme/$uid/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<SemantemeResponseEntity?>.fromJson(response,
        fromJson: (json) => SemantemeResponseEntity?.fromJson(json));
  }
}
