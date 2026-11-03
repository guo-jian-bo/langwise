import 'dart:io';

import 'package:api/api.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';

class KnowledgeUtil {
  // 知识点单元列表
  static Future<ResponseEntity<ListResponseEntity<Knowledge>>> pages(
      {required unitId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/pages", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<ListResponseEntity<Knowledge>>.fromJson(response,
        fromJson: (json) =>
            ListResponseEntity<Knowledge>.fromJson(json, fromJson: (json) => Knowledge.fromJson(json)));
  }

  // 编辑知识点单元
  static Future<ResponseEntity<UnitResponseEntity>> edit({required unitId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/edit/unit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<UnitResponseEntity>.fromJson(response,
        fromJson: (json) => UnitResponseEntity.fromJson(json));
  }

  // 添加知识点单元
  static Future<ResponseEntity<ListEntity<Knowledge>>> add({required unitId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/unit/$unitId/knowledge/add", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ListEntity<Knowledge>>.fromJson(response,
        fromJson: (json) => ListEntity<Knowledge>.fromJson(json, fromJson: (json) => Knowledge.fromJson(json)));
  }

  // 排序知识点单元
  static Future<ResponseEntity<Knowledge>> order(
      {required unitId, required knowledgeId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request(
        "/course-console/unit/$unitId/knowledge/$knowledgeId/order", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<Knowledge>.fromJson(response, fromJson: (json) => Knowledge.fromJson(json));
  }


  /// 编辑语义
  static Future<bool> editSemantics(int semanticId, Map<String, dynamic> data) async{
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/word/semantic/$semanticId/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      if (responseEntity.data == null) return false;
      return true;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 知识点创建记录
  static Future<ListResponseEntity<KnowledgeCreateHistoryEntity>?> getKnowledgeCreateHistory(Map<String, dynamic> parameters, Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/content/knowledge/create/history",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
    
      return ListResponseEntity<KnowledgeCreateHistoryEntity>.fromJson(responseEntity.data, fromJson: KnowledgeCreateHistoryEntity.fromJson);

    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 获取单词知识点列表
  static Future<ListResponseEntity<EnKnowledgeEntity>?> getEnWordKnowledgeList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/word/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<EnKnowledgeEntity>.fromJson(responseEntity.data, fromJson: EnKnowledgeEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }
  
}
