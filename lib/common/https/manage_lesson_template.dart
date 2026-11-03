
import 'dart:io';

import 'package:api/api.dart';
import 'package:langwise/utils/utils.dart';
import 'package:wise_http/wise_http.dart';

import '../entities/entities.dart';

class ManageLessonTemplateRequest{

  static Future<ResponseEntity?> createLessonTemplate(Map<String, dynamic> data) async{
    RequestConfig config = RequestConfig(
      requireToken: true,
      data: data,
    );
    try {
      dynamic response = await WiseHttp().request(
        "/course-console/course/lesson/template/create", 
        Method.post, 
        headers: config.headers, 
        data: config.data,
        requireToken: config.requireToken,
      );
      if(response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if(responseEntity.code != HttpStatus.ok) {
        if(responseEntity.message != null){
          ToastUtils.showManageToast(text: responseEntity.message??"");
        }
        return null;
      }
      return responseEntity;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  

  static Future<bool> sortLessonTemplateQuiz(Map<String, dynamic> data, int templateId) async{
    RequestConfig config = RequestConfig(
      requireToken: true,
      data: data,
    );
    
    try {
      dynamic response = await WiseHttp().request(
        "/course-console/course/lesson/template/$templateId/config/sort", 
        Method.post, 
        headers: config.headers, 
        data: config.data,
        requireToken: config.requireToken,
      );
      if(response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if(responseEntity.code != HttpStatus.ok) {
        if(responseEntity.message != null){
          ToastUtils.showManageToast(text: responseEntity.message??"");
        }
        return false;
      }
      if(responseEntity.data == null) return false;
      return true;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return false;
    } catch (e) {
      return false;
    }
  }



  static Future<ResponseEntity?> editLessonTemplate(Map<String, dynamic> data, int uid) async{
    RequestConfig config = RequestConfig(
      requireToken: true,
      data: data,
    );
    
    try {
      dynamic response = await WiseHttp().request(
        "/course-console/course/lesson/template/$uid/edit", 
        Method.post, 
        headers: config.headers, 
        data: config.data,
        requireToken: config.requireToken,
      );
      if(response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if(responseEntity.code != HttpStatus.ok) {
        if(responseEntity.message != null){
          ToastUtils.showManageToast(text: responseEntity.message??"");
        }
        return null;
      }
      return responseEntity;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 列表
  static Future<ManageLessonTemplateEntity?> getLessonTemplateData(Map<String, dynamic> data, Map<String, dynamic> parame) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parame,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/course/lesson/template/pages", 
        Method.post, 
        headers: config.headers, 
        data: config.data,
        parameters: config.parameters,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );
      if(response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if(responseEntity.code != HttpStatus.ok) {
        if(responseEntity.message != null){
          ToastUtils.showManageToast(text: responseEntity.message??"");
        }
        return null;
      }
      return ManageLessonTemplateEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 课时模版题目列表查询
  static Future<List<ManageLessonQuizTemplateEntity>?> getLessonQuizList(int uid) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: {
          "config": true,
        },
      );
      dynamic response = await WiseHttp().request(
        "/course-console/course/lesson/template/$uid/exercise/template/list", 
        Method.post, 
        headers: config.headers, 
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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
      List? list = responseEntity.data['list'];
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

}