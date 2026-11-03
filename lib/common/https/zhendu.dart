import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class ZhenduRequest {
  static Future<ZhenduCategoryListEntity?> getCategoryList({Map<String, dynamic>? parameters}) async {
    try {
      final config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      final response = await WiseHttp().request(
        "/languages/script/zhendu/category/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );

      if (response == null) return null;
      final responseEntity = ResponseEntity.fromJson(response);
      
      if (responseEntity.code != HttpStatus.ok) {
           ToastUtils.showManageToast(
            text: responseEntity.message ?? '',
            type: ManageToastType.error,
          );
        // ToastUtils.showToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return ZhenduCategoryListEntity.fromJson(responseEntity.data as Map<String, dynamic>);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<ZhenduCategoryContentV2PagesEntity?> getCategoryContentPages({
    required String category,
    int? offset,
    int? limit,
    String? query,
    List<Map<String, dynamic>>? filters,
    String? order,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final data = <String, dynamic>{
        'category': category,
      };
      if (query != null && query.trim().isNotEmpty) {
        data['content'] = query.trim();
      }
      if (filters != null && filters.isNotEmpty) data['filters'] = filters;
      final requestParameters = <String, dynamic>{
        ...?parameters,
      };
      if (offset != null) {
        requestParameters['offset'] = offset;
      }
      if (limit != null) {
        requestParameters['limit'] = limit;
      }
      if (order != null && order.trim().isNotEmpty) {
        requestParameters['order'] = order.trim();
      }

      final config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: requestParameters.isEmpty ? null : requestParameters,
        data: data,
      );
      final response = await WiseHttp().request(
        "/languages/script/zhendu/category/content/v2/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );

      if (response == null) return null;
      final responseEntity = ResponseEntity.fromJson(response);

          
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return ZhenduCategoryContentV2PagesEntity.fromJson(
          responseEntity.data as Map<String, dynamic>);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<ZhenduScriptQueryMetaGroupListEntity?>
      getScriptQueryMetaGroupList({
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      final response = await WiseHttp().request(
        "/languages/script/query/meta/group/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );

      if (response == null) return null;
      final responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return ZhenduScriptQueryMetaGroupListEntity.fromJson(
        responseEntity.data as Map<String, dynamic>,
      );
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<ZhenduScriptDetailEntity?> getScriptDetail({
    required int uid,
    int? collectionId,
    int? difficulty,
    String? traceAdminHeader,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (collectionId != null) data['collectionId'] = collectionId;
      if (difficulty != null) data['difficulty'] = difficulty;

      final config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data.isEmpty ? null : data,
        headers: {
          'trace-admin': traceAdminHeader,
        },
      );

      final response = await WiseHttp().request(
        "/languages/script/zhendu/script/$uid/detail",
        config.data == null ? Method.get : Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );

      if (response == null) return null;
      final responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return ZhenduScriptDetailEntity.fromJson(responseEntity.data as Map<String, dynamic>);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }
}
