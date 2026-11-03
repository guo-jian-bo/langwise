import 'package:api/entities/entities.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:wise_http/wise_http.dart';

class TopicUtil {
  // 获取语义标签
  static Future<ResponseEntity<ListResponseEntity<EnEntityTopic>>> fetchPages(
      {required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/semantic/topic/pages", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ListResponseEntity<EnEntityTopic>>.fromJson(response,
        fromJson: (json) =>
            ListResponseEntity<EnEntityTopic>.fromJson(json, fromJson: (json) => EnEntityTopic.fromJson(json)));
  }

  // 创建
  static Future<ResponseEntity<EnEntityTopic?>> create({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/semantic/topic/create", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<EnEntityTopic?>.fromJson(response, fromJson: (json) => EnEntityTopic.fromJson(json));
  }

  // 编辑
  static Future<ResponseEntity<EnEntityTopic?>> edit({required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/semantic/topic/$uid/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<EnEntityTopic?>.fromJson(response, fromJson: (json) => EnEntityTopic.fromJson(json));
  }
}
