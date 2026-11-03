import 'dart:io';

import 'package:api/entities/entities.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class ExercisesRequest {
  
  /// 获取题目配置
  static Future<List<ManageLessonQuizTemplateEntity>?> getQuizTemplates(Map<String, dynamic> parameter, Map<String, dynamic> reqData) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameter,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/config/list/v2", 
        Method.post, 
        headers: config.headers, 
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: reqData,
      );
      if(response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if(responseEntity.code != HttpStatus.ok) {
        if(responseEntity.message != null){
          ToastUtils.showManageToast(text: responseEntity.message??"");
        }
        return null;
      }
      if(responseEntity.data == null) return null; 
      List? list = responseEntity.data;
      if(list == null) return null; 
      List<ManageLessonQuizTemplateEntity> resList = [];
      for (var e in list) {
        resList.add(ManageLessonQuizTemplateEntity.fromJson(e));
      }
      return resList; 
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 根据题目查询可发送到课时列表
  static Future<List<ExerciseLessonEntity>?> getExerciseLessonList(Map<String, dynamic> reqData) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/course/unit/lesson/exercise/info", 
        Method.post, 
        headers: config.headers, 
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: reqData,
      );
      if(response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if(responseEntity.code != HttpStatus.ok) {
        if(responseEntity.message != null){
          ToastUtils.showManageToast(text: responseEntity.message??"");
        }
        return null;
      }
      if(responseEntity.data == null) return null; 
      List? list = responseEntity.data;
      if(list == null) return null; 
      List<ExerciseLessonEntity> resList = [];
      for (var e in list) {
        resList.add(ExerciseLessonEntity.fromJson(e));
      }
      return resList; 
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

}