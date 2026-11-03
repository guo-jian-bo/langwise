import 'dart:io';

import 'package:api/api.dart';
import 'package:langwise/common/entities/activity_tags_entities.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:wise_http/wise_http.dart';

class ActivityTagsUtil {
  static Future<List<ActivityTagParamEntity>?> paramsList() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );

      var response = await WiseHttp().request(
        '/activity-console/api/tags/params/list',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
        parameters: config.parameters,
      );

      if (response == null) return null;

      if (response is List) {
        return response
            .whereType<Map<String, dynamic>>()
            .map((e) => ActivityTagParamEntity.fromJson(e))
            .toList();
      }

      if (response is Map<String, dynamic>) {
        // Some backends may still wrap with {code,data}
        if (response.containsKey('code')) {
          final entity = ResponseEntity.fromJson(response);
          if (entity.code != HttpStatus.ok) return null;
          final data = entity.data;
          if (data is List) {
            return data
                .whereType<Map<String, dynamic>>()
                .map((e) => ActivityTagParamEntity.fromJson(e))
                .toList();
          }
          return null;
        }
      }

      return null;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<ResponseEntity<ActivityTagPageDataEntity>?> tagsPage({
    required int offset,
    required int limit,
    Map<String, dynamic>? body,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: body ?? {},
        parameters: {
          'offset': offset,
          'limit': limit,
        },
      );

      var response = await WiseHttp().request(
        '/activity-console/api/tags/page',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
        parameters: config.parameters,
      );

      if (response == null) return null;

      return ResponseEntity<ActivityTagPageDataEntity>.fromJson(
        response,
        fromJson: (json) => ActivityTagPageDataEntity.fromJson(json),
      );
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<ResponseEntity<dynamic>?> createTag(Map<String, dynamic> body) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: body,
      );

      var response = await WiseHttp().request(
        '/activity-console/api/tags/create/tag',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
        parameters: config.parameters,
      );

      if (response == null) return null;
      return ResponseEntity<dynamic>.fromJson(response);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }
}
