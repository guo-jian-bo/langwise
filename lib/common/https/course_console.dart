import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';
import '../entities/manage_exercise_filter_model.dart';

class CourseConsoleRequest {

  /// 生成remix文章
  static Future<String?> generateRemixArticle(int unitId, Map<String, dynamic> data) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/course/unit/$unitId/text/remix",
        Method.post,
        headers: config.headers,
        requireToken: true,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity.data;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取config题目列表
  static Future<ListResponseEntity<ManageLessonQuizTemplateEntity>?> getConfigExercises(Map<String, dynamic> parameters, Map<String, dynamic> reqData) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/course/lesson/template/config/pages",
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
      return ListResponseEntity<ManageLessonQuizTemplateEntity>.fromJson(responseEntity.data, fromJson: ManageLessonQuizTemplateEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取题目列表的筛选信息
  static Future<ManageExerciseFilterModel?> getExerciseFilter() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/exerciseType/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageExerciseFilterModel.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 删除题目模版配置
  static Future<bool> deleteConfigExercise(Map<String, dynamic> parameters) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/course/lesson/template/config/delete",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        parameters: config.parameters,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      if (responseEntity.data == null) return false;
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  } 

  /// 创建题目模版配置
  static Future<bool> createConfigExercise(Map<String, dynamic> reqData) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/course/lesson/template/config/create",
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
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  } 


  /// 编辑题目配置
  static Future<bool> editConfigExercise(Map<String, dynamic> parameters, Map<String, dynamic> reqData) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/course/lesson/template/config/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        parameters: config.parameters,
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
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  } 


  /// 课时模版绑定题目配置
  static Future<bool> lessonTemplateBindConfig(int lessonTemplateUid, Map<String, dynamic> reqData) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/course/lesson/template/$lessonTemplateUid/config/bind/v2",
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
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }


  /// 编辑课时模版
  static Future<bool> editLessonTemplateConfig(int lessonTemplateUid, Map<String, dynamic> reqData) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/course/lesson/template/$lessonTemplateUid/edit",
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
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }


  /// 获取题目审核历史
  static Future<ListResponseEntity<ExerciseReviewEntityList>?> getExerciseReviewHistoryList(Map<String, dynamic> params, Map<String, dynamic> data) async{
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
        parameters: params,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/review/history",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity.fromJson(responseEntity.data, fromJson: ExerciseReviewEntityList.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

}