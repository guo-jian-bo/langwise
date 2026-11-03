import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class OfficialCourseDetailsLevelRequest {
  static Future<CourseLevelEntity?> getCourseLevelList(int courseId,
      {Map<String, dynamic>? parameters}) async {
    RequestConfig config = RequestConfig(
      requireToken: true,
      parameters: parameters,
    );

    try {
      dynamic response = await WiseHttp().request(
        "/course/course/$courseId/level/list",
        Method.get,
        headers: config.headers,
        requireToken: true,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showToast(text: responseEntity.message ?? "");
        }
        return null;
      }
      if (responseEntity.data == null) return null;
      CourseLevelEntity? entity =
          CourseLevelEntity.fromJson(responseEntity.data);
      return entity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取课程等级-模块-单元树
  static Future<CourseLevelTreeEntity?> getCourseLevelModuleUnitTree(
      int courseId,
      {Map<String, dynamic>? parameters}) async {
    RequestConfig config = RequestConfig(
      requireToken: true,
      parameters: parameters,
      requireCache: true,
    );
    try {
      dynamic response = await WiseHttp().request(
        "/course/course/$courseId/level/module/unit/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showToast(text: responseEntity.message ?? "");
        }
        return null;
      }
      if (responseEntity.data == null) return null;
      CourseLevelTreeEntity entity =
          CourseLevelTreeEntity.fromJson(responseEntity.data);
      return entity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取课程模块单元列表
  static Future<CourseLevelModuleUnitEntity?> getCourseLevelModuleUnitList(
      int courseId, int levelId, int moduleId) async {
    RequestConfig config = RequestConfig(
      requireToken: true,
      requireCache: true,
    );

    try {
      dynamic response = await WiseHttp().request(
        "/course/course/$courseId/level/$levelId/module/$moduleId/unit/simaple/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (responseEntity.message != null) {
          ToastUtils.showToast(text: responseEntity.message ?? "");
        }
        return null;
      }
      if (responseEntity.data == null) return null;
      CourseLevelModuleUnitEntity? entity =
          CourseLevelModuleUnitEntity.fromJson(responseEntity.data);
      return entity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }
}
