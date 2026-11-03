import 'package:api/entities/entities.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:wise_http/wise_http.dart';

class PhonicsUtil {
  // 获取自拼
  static Future<ResponseEntity<ListResponseEntity<PhonicsResponseEntity>>> fetchPages(
      {required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/phonics/rule/pages", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ListResponseEntity<PhonicsResponseEntity>>.fromJson(response,
        fromJson: (json) => ListResponseEntity<PhonicsResponseEntity>.fromJson(json,
            fromJson: (json) => PhonicsResponseEntity.fromJson(json)));
  }

  // 创建
  static Future<ResponseEntity<PhonicsResponseEntity?>> create({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/phonics/rule/create", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<PhonicsResponseEntity?>.fromJson(response,
        fromJson: (json) => PhonicsResponseEntity.fromJson(json));
  }

  // 编辑
  static Future<ResponseEntity<PhonicsResponseEntity?>> edit(
      {required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/phonics/rule/$uid/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<PhonicsResponseEntity?>.fromJson(response,
        fromJson: (json) => PhonicsResponseEntity?.fromJson(json));
  }
}
