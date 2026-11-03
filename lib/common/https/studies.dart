import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';


class StudiesRequest {

  /// 获取规划步骤列表
  static Future<LearningSettingStepEntity?> getPlanGuideStep() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/page/card/member/guide/step",
        Method.get,
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
      return LearningSettingStepEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取用户超记统计
  static Future<MemberStatisticsEntity?> getMemberStatistics() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/supermemo/summary",
        Method.get,
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
      return MemberStatisticsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// 获取用户学习天数
  static Future<LearningStatisticsEntity?> getUserStudyDays({bool showToast = true}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/study/info",
        Method.get,
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
      return LearningStatisticsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      if(showToast) ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取计划进度信息
  static Future<PlanEntityPlanPathCoursesStudyPlanStartUnitInfo?> getPlanProgress(int courseId, {Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/plan/course/$courseId/start/preview",
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
      return PlanEntityPlanPathCoursesStudyPlanStartUnitInfo.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 查询今日任务计算的状态
  static Future<MissionAsyncStatusEntity?> getTodayTaskStatus() async{
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseTodayTaskMissionAsyncStatus)) return null;
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/today/task/mission/async/status",
        Method.get,
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
      return MissionAsyncStatusEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<ResponseEntity?> getTodayTaskStatusResponseEntity() async{
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseTodayTaskMissionAsyncStatus)) return null;
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/today/task/mission/async/status",
        Method.get,
        headers: config.headers,
        requireToken: true,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      return ResponseEntity.fromJson(response);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

}
