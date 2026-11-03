import 'dart:io';

import 'package:api/entities/config.dart';
import 'package:api/entities/response.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:wise_http/wise_http.dart';

import '../../app/modules/management/models/manage_exercise_course_affiliation_model.dart';
import '../../app/modules/management/models/manage_exercise_quiz_model.dart';
import '../entities/entities.dart';

class ManageExerciseRequest {

  /// 获取题目类型列表 
  static Future<List<ExerciseTypeListEntity>?> getExerciseTypeList(Map<String, dynamic> data, {Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/type/list",
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
      List? list = responseEntity.data;
      if(list == null) return null;
      return list.map((e) => ExerciseTypeListEntity.fromJson(e)).toList();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 分页查询题目列表
  static Future<ListResponseEntity<QuizModel>?> getExerciseList(Map<String, dynamic> params, Map<String, dynamic> data) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
        parameters: params,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/page",
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
      return ListResponseEntity.fromJson(responseEntity.data, fromJson: QuizModel.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  
  /// 获取题目列表
  static Future<ListResponseEntity<ManageExerciseQuizModel>?> getQuizList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/page",
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
      return ListResponseEntity<ManageExerciseQuizModel>.fromJson(responseEntity.data, fromJson: ManageExerciseQuizModel.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageExerciseFilterModel.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除题目
  static Future<ResponseEntity?> deleteQuiz(String operation, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/operation/$operation",
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

  /// 获取题目对应的单元列表
  static Future<ListResponseEntity<ManageExerciseCourseAffiliationModel>?> getQuizCourseList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/exercise/course/infos",
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;

      // 将 list 字段转换为 datas
      final responseData = Map<String, dynamic>.from(responseEntity.data);
      if (responseData['list'] != null) {
        for (var i = 0; i < responseData['list'].length; i++) {
          final subData = Map<String, dynamic>.from(responseData['list'][i]);
          subData['uid'] = i + 1;
          responseData['list'][i] = subData;
        }
        responseData['offset'] = responseData['list'].length;
        responseData['limit'] = 100;
        responseData['count'] = responseData['list'].length;
        responseData['datas'] = responseData['list'];
      }

      return ListResponseEntity<ManageExerciseCourseAffiliationModel>.fromJson(responseData, fromJson: ManageExerciseCourseAffiliationModel.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }
}
