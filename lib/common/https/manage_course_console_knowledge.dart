import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../entities/list.dart';
import '../widgets/data_table_widget/data_sources.dart';

class ManageCourseConsoleKnowledgeRequest {
  static Future<ListResponseEntity<T>?> _mapListToListResponse<T extends Dessert>(dynamic response, T Function(Map<String, dynamic>) fromJson) async {
    if (response == null) return null;
    final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
    if (responseEntity.code != HttpStatus.ok) {
      return null;
    }
    if (responseEntity.data == null) return null;

    final Map<String, dynamic> data = Map<String, dynamic>.from(responseEntity.data);
    final Map<String, dynamic> responseData = Map<String, dynamic>.from(data);

    if (responseData['list'] != null) {
      final List list = List.from(responseData['list']);
      for (var i = 0; i < list.length; i++) {
        final subData = Map<String, dynamic>.from(list[i]);
        subData['uid'] = i + 1;
        list[i] = subData;
      }
      responseData['offset'] = list.length;
      responseData['limit'] = 100;
      responseData['count'] = list.length;
      responseData['datas'] = list;
    }

    return ListResponseEntity<T>.fromJson(responseData, fromJson: (json) => fromJson(Map<String, dynamic>.from(json)));
  }

  static Future<ListResponseEntity<T>?> getKnowledgeCourseInfos<T extends Dessert>({
    required int uid,
    required String type,
    int? semanticId,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {
          'uid': uid,
          'type': type,
          'semanticId': semanticId,
        },
      );

      final dynamic response = await WiseHttp().request(
        '/course-console/unit/0/knowledge/course/infos',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
      );

      return _mapListToListResponse<T>(response, fromJson);
    } on FormatException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
