import 'package:api/api.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:wise_http/wise_http.dart';

class WordPronounceUtil {
  // 获取
  static Future<ResponseEntity<ListResponseEntity<EnWordPronounceEntity>>> fetchPages(
      {required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/word/pron/pages", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ListResponseEntity<EnWordPronounceEntity>>.fromJson(response,
        fromJson: (json) => ListResponseEntity<EnWordPronounceEntity>.fromJson(json,
            fromJson: (json) => EnWordPronounceEntity.fromJson(json)));
  }

  // 编辑
  static Future<ResponseEntity<EnWordPronounceEntity?>> edit(
      {required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/word/pron/$uid/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<EnWordPronounceEntity?>.fromJson(response,
        fromJson: (json) => EnWordPronounceEntity.fromJson(json));
  }
}
