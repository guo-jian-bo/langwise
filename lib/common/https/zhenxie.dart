import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class ZhenxieRequest {
  /// 获取甄写考点首页数据
  static Future<Map<String, dynamic>?> getExamHomeData({Map<String, dynamic>? parameters}) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        "/languages/write/zhenxie/exam/home",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );

      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      final dynamic data = responseEntity.data;
      if (data == null) return <String, dynamic>{};
      if (data is! Map<String, dynamic>) return null;
      return data;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取甄写考点三关对比数据
  static Future<Map<String, dynamic>?> getExamCompareData({
    required String module,
    Map<String, dynamic>? data,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        "/languages/write/zhenxie/exam/compare/$module",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      final dynamic responseData = responseEntity.data;
      if (responseData == null) return <String, dynamic>{};
      if (responseData is! Map<String, dynamic>) return null;
      return responseData;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取甄写考点能力桑基图数据
  static Future<Map<String, dynamic>?> getExamGoalSankeyData({
    Map<String, dynamic>? data,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        "/languages/write/zhenxie/exam/compare/goals/sankey",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      final dynamic responseData = responseEntity.data;
      if (responseData == null) return <String, dynamic>{};
      if (responseData is! Map<String, dynamic>) return null;
      return responseData;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取甄写考点筛选元数据
  static Future<Map<String, dynamic>?> getExamCompareMetaData({Map<String, dynamic>? parameters}) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        "/languages/write/zhenxie/exam/compare/region/group/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );

      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      final dynamic data = responseEntity.data;
      if (data == null) return <String, dynamic>{};
      if (data is! Map<String, dynamic>) return null;
      return data;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取甄写真题列表筛选元数据
  static Future<Map<String, dynamic>?> getExamTaskQueryMetaGroupList({Map<String, dynamic>? parameters}) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        "/languages/write/zhenxie/exam/task/query/meta/group/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      final dynamic data = responseEntity.data;
      if (data == null) return <String, dynamic>{};
      if (data is! Map<String, dynamic>) return null;
      return data;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取甄写真题分页列表
  static Future<Map<String, dynamic>?> getExamTaskPages({
    Map<String, dynamic>? data,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        "/languages/write/zhenxie/exam/task/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      final dynamic responseData = responseEntity.data;
      if (responseData == null) return <String, dynamic>{};
      if (responseData is! Map<String, dynamic>) return null;
      return responseData;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取甄写真题详情
  static Future<Map<String, dynamic>?> getExamTaskDetail({Map<String, dynamic>? parameters}) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        "/languages/write/zhenxie/exam/task/detail",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      final dynamic data = responseEntity.data;
      if (data == null) return <String, dynamic>{};
      if (data is! Map<String, dynamic>) return null;
      return data;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取甄写首页数据
  static Future<Map<String, dynamic>?> getHomeData({Map<String, dynamic>? parameters}) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        "/languages/write/zhenxie/home",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );

      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      final dynamic data = responseEntity.data;
      if (data == null) return <String, dynamic>{};
      if (data is! Map<String, dynamic>) return null;
      return data;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取甄写词法页数据
  static Future<Map<String, dynamic>?> getLexisHomeData({Map<String, dynamic>? parameters}) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        "/languages/write/zhenxie/lexis/home",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );

      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      final dynamic data = responseEntity.data;
      if (data == null) return <String, dynamic>{};
      if (data is! Map<String, dynamic>) return null;
      return data;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取甄写句法页数据
  static Future<Map<String, dynamic>?> getSyntaxHomeData({Map<String, dynamic>? parameters}) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        "/languages/write/zhenxie/syntax/home",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );

      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      final dynamic data = responseEntity.data;
      if (data == null) return <String, dynamic>{};
      if (data is! Map<String, dynamic>) return null;
      return data;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取甄写章法页数据
  static Future<Map<String, dynamic>?> getCompositionDiscourseHome({Map<String, dynamic>? parameters}) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        "/languages/write/zhenxie/composition/discourse/home",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );

      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      final dynamic data = responseEntity.data;
      if (data == null) return <String, dynamic>{};
      if (data is! Map<String, dynamic>) return null;
      return data;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取写作阶梯分页列表
  static Future<Map<String, dynamic>?> getCompositionStagePages({
    Map<String, dynamic>? data,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        "/languages/write/zhenxie/composition/stage/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      final dynamic responseData = responseEntity.data;
      if (responseData == null) return <String, dynamic>{};
      if (responseData is! Map<String, dynamic>) return null;
      return responseData;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取章法蓝图列表
  static Future<Map<String, dynamic>?> getCompositionBlueprintList({
    Map<String, dynamic>? data,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        "/languages/write/zhenxie/composition/blueprint/list",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      final dynamic responseData = responseEntity.data;
      if (responseData == null) return <String, dynamic>{};
      if (responseData is! Map<String, dynamic>) return null;
      return responseData;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 词源记忆列表（一片森林一张卡）
  static Future<ListResponseEntity<ZhenxieEtymologyForestEntity>?> getEtymologyForestPage({
    Map<String, dynamic>? data,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        "/languages/write/zhenxie/word/etymology/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      if (responseEntity.data == null) return null;
      return ListResponseEntity<ZhenxieEtymologyForestEntity>.fromJson(
        responseEntity.data,
        fromJson: ZhenxieEtymologyForestEntity.fromJson,
      );
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 词源记忆筛选元数据
  static Future<ZhenduScriptQueryMetaGroupListEntity?> getEtymologyQueryMetaGroupList() async {
    try {
      final RequestConfig config = RequestConfig(requireToken: true);
      final dynamic response = await WiseHttp().request(
        "/languages/write/zhenxie/word/etymology/query/meta/group/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      if (responseEntity.data == null) return null;
      return ZhenduScriptQueryMetaGroupListEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }
}
