import 'dart:io';

import 'package:api/api.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class HomeRequest{

  /// 获取首页卡片列表
  static Future<HomeCardEntity?> getHomeCardList() async{
    RequestConfig config = RequestConfig(
      requireToken: true,
    );
    try {
      dynamic response = await WiseHttp().request(
        "/studies/page/card/code/home", 
        Method.get, 
        headers: config.headers,
        requireToken: true,
      );
      if(response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if(responseEntity.code != HttpStatus.ok) return null;
      HomeCardEntity? homeCardEntity = HomeCardEntity.fromJson(responseEntity.data);
      return homeCardEntity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      return null;
    }
  }

  /// 获取已加入的课程
  static Future<List<BabyCourseEntity>?> getJoinedalreadyData() async{
    RequestConfig config = RequestConfig(
      requireToken: true,
    );
    dynamic response = await WiseHttp().request("/course/course/baby/list", Method.get, headers: config.headers, requireToken: true).catchError((_){});
    if(response == null) return null;
    ResponseEntity responseEntity = ResponseEntity.fromJson(response);
    if(responseEntity.code != HttpStatus.ok) return null;
    List? list = responseEntity.data;
    if(list == null) return null;
    List<BabyCourseEntity> modelList = [];
    for (var item in list) {
      modelList.add(BabyCourseEntity.fromJson(item));
    }
    return modelList;
  }

  /// 获取官方课程
  static Future<List<OfficialCourseEntity>?> getofficialCourseData() async{
    RequestConfig config = RequestConfig(
      requireToken: true,
    );
    dynamic response = await WiseHttp().request("/course/course/official/list", Method.get, headers: config.headers, requireToken: true).catchError((_){});
    if(response == null) return null;
    ResponseEntity responseEntity = ResponseEntity.fromJson(response);
    if(responseEntity.code != HttpStatus.ok) return null;
    List? list = responseEntity.data;
    if(list == null) return null;
    List<OfficialCourseEntity> modelList = [];
    for (var item in list) {
      modelList.add(OfficialCourseEntity.fromJson(item));
    }
    return modelList;
  }


  /// 获取今日任务(测试)id列表
  /// 获取课时下已经保存的题目列表ids
  static Future<List<int>?> getLessonQuizList(int lessonId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/course/course/unit/exercise/ids",
        //  "/course/course/lesson/$lessonId/exercise/ids",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      List? list = responseEntity.data;
      if (list == null) return null;
      List<int> result = [];
      for (var item in list) {
        result.add(item);
      }
      return result;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 根据ids获取题目详情列表
  static Future<List<QuizModel>?> getQuizListByIds(List<int> exerciseIds, {Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: exerciseIds,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/course/exercise/list/by/uids",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if(response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if(responseEntity.code!= HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message??"");
        return null;
      }
      if(responseEntity.data == null) return null;
      List? list = responseEntity.data['list'];
      if(list == null) return null;
      List<QuizModel> result = [];
      for(var item in list){
        result.add(QuizModel.fromJson(item));
      }
      return result;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<ContentExerciseDetailEntity?> getQuizListByContentExerciseDetail({
    String? type,
    int? contentId,
    Map<String, dynamic>? parameters,
    String? traceAdminHeader,
  }) async {
    try {
      final data = <String, dynamic>{
        'contents': [
          {'type': type, 'uid': contentId.toString()},
        ],
      };
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
        parameters: parameters,
        headers: {
          "trace-admin": traceAdminHeader,
        },
      );
      dynamic response = await WiseHttp().request(
        "/languages/content/exercise/detail",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return ContentExerciseDetailEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取今日任务id等信息列表
  static Future<TodayTaskInfoEntity?> getTodayTaskInfo({Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/today/task/exercise",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return TodayTaskInfoEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  } 

  /// 开始备考练习 获取题目数据
  static Future<PlanQuizEntity?> getExamPreparationData(int examId, Map<String, dynamic>? parameters) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/studies/plan/exam/$examId/exercise/start",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return PlanQuizEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

}
