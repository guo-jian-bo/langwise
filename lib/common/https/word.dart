

import 'package:api/api.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:wise_http/wise_http.dart';

class WordUtil {
  // 创建
  static Future<ResponseEntity<EnWordEntity?>> create({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/word/create", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<EnWordEntity?>.fromJson(response, fromJson: (json) => EnWordEntity.fromJson(json));
  }

  // 单词匹配
  static Future<ResponseEntity> match({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/word/match/detail", Method.post,
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
  static Future<ResponseEntity<EnWordEntity?>> edit({required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/word/$uid/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<EnWordEntity?>.fromJson(response, fromJson: (json) => EnWordEntity.fromJson(json));
  }

  // 语义列表
  static Future<ResponseEntity<List<EnEntitySemantics>>> semanticList({required RequestConfig config, required int semanticId}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/word/$semanticId/semantic/list", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<List<EnEntitySemantics>>.fromJson(
      response,
      fromJson: (json) {
        final list = <EnEntitySemantics>[];
        if (json is List) {
          for (final e in json) {
            if (e is Map<String, dynamic>) {
              list.add(EnEntitySemantics.fromJson(e));
            }
          }
        }
        return list;
      },
    );
  }

  // 新语义列表
  static Future<ResponseEntity<List<EnEntitySemantics>>> semanticListNew({required RequestConfig config, required int uid, required String type}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/en/content/semantic/list", Method.post,
        data: {
          'uid': uid,
          'type': type,
        },
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<List<EnEntitySemantics>>.fromJson(
      response,
      fromJson: (json) {
        final list = <EnEntitySemantics>[];
        if (json is List) {
          for (final e in json) {
            if (e is Map<String, dynamic>) {
              list.add(EnEntitySemantics.fromJson(e));
            }
          }
        }
        return list;
      },
    );
  }
}
