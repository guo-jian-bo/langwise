import 'dart:io';

import 'package:api/entities/config.dart';
import 'package:api/entities/response.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:wise_http/wise_http.dart';
import '../../app/modules/management/models/manage_create_quiz_model.dart';
import '../entities/entities.dart';

class ManageEnglishContentManagementSongRequest {
  /// 获取歌曲的筛选信息
  static Future<ManageCreateQuizModel?> getSongFilter() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/theme/list/song",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageCreateQuizModel.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取歌曲列表
  static Future<ListResponseEntity<ManageEnglishContentManagementSongModel>?> getSongList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/song/pages",
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<ManageEnglishContentManagementSongModel>.fromJson(responseEntity.data, fromJson: ManageEnglishContentManagementSongModel.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除歌曲
  static Future<ResponseEntity?> deleteSong(int knowledgeId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/song/$knowledgeId/delete",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取内容知识点信息
  static Future<ManageEnglishContentManagementSongKnowledgeStatisticsModel?> getContentKnowledge({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/content/knowledge/list",
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageEnglishContentManagementSongKnowledgeStatisticsModel.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除/增加知识点
  static Future<ResponseEntity?> deleteKnowledge(String opration, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/content/knowledge/$opration",
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
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 编辑歌曲
  static Future<EnKnowledgeEntity?> editSong({required String uid, required RequestConfig config}) async {
    try {
      final rawHeader = config.headers ?? {};
      var response = await WiseHttp().request("/language-console/en/song/$uid/edit", Method.post,
          data: config.data,
          parameters: config.parameters,
          options: config.options,
          cancelToken: config.cancelToken,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          headers: rawHeader);
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      return EnKnowledgeEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }
}
