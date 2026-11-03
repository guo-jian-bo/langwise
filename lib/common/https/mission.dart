import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:api/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class MissionRequest {

  /// 获取今日任务mission列表
  static Future<TaskMissionEntity?> getMissionList(int review) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: {
          "review": review,
        },
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/today/task/mission/list",
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
      return TaskMissionEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 获取mission的题目列表
  static Future<TaskMissionEntity?> getMissionQuizList(int missionId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/today/mission/$missionId/exercise/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      log('111sndfiasnifanifnas');
      log(jsonEncode(response),level: 1000);
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return TaskMissionEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }
  
  static Future<TaskMissionEntity?> getTaskMission(int review) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: {
          "review": review,
        },
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
      return TaskMissionEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取mission结果
  static Future<TaskMissionCompleteEntity?> getMissionResult(int missionId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/today/mission/$missionId/result",
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
      return TaskMissionCompleteEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  
  }


  /// 小任务完成
  static Future<bool> minMissionComplete(int missionId) async{
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {
          "missionId": missionId,
        },
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/today/mission/finish",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
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


  /// 获取任务菜单列表
  static Future<TaskMissionMenuEntity?> getTaskMissionMenu() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/task/today/group/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return TaskMissionMenuEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取任务组列表
  static Future<TaskMissionMenuListEntity?> getTaskMissionGroup(String type) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/task/$type/task/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return TaskMissionMenuListEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 已读任务
  static Future<bool> readTask(int uid) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/task/$uid/status/finish",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      if (responseEntity.data == null) return false;
      return true;
    } on FormatException catch (_) {
      return false;
    } catch (e) {
      return false;
    }
  }


  /// 获取今日学习过的知识点列表
  static Future<TodayKnowledgeEntity?> getTodayKnowledge() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/today/learn/content/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return TodayKnowledgeEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取今日新学的知识点列表
  static Future<TodayKnowledgeEntity?> getTodayNewKnowledge() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/today/new/content/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return TodayKnowledgeEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取今日新学的知识点题目列表
  static Future<QuizListEntity?> getTodayNewKnowledgeQuiz() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/today/new/content/speaking/exercise/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return QuizListEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取今日所有的知识点题目列表
  static Future<QuizListEntity?> getTodayKnowledgeQuiz() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/today/learn/content/speaking/exercise/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return QuizListEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 获取单元测试题目
  static Future<TaskMissionUnitTestEntity?> getTestMissionExercises(int targetId, {int restart = 1}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: {
          "restart": restart,
        },
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/plan/test/mission/$targetId/exercises",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      TaskMissionUnitTestEntity taskMissionUnitTestEntity = TaskMissionUnitTestEntity.fromJson(responseEntity.data);
      return taskMissionUnitTestEntity;
    } on FormatException catch (e) {
      int code = e.source.code;
      if(code == 20001){ // 代表没有题目
        TaskMissionUnitTestEntity taskMissionUnitTestEntity = TaskMissionUnitTestEntity();
        taskMissionUnitTestEntity.hasExercises = false;
        return taskMissionUnitTestEntity;
      }else{
        ToastUtils.showToast(text: e.source.message);
      }
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 获取测试结果
  static Future<MissionTestResultEntity?> getTestMissionResult(int unitTestRecordId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/plan/test/mission/record/$unitTestRecordId/final",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return MissionTestResultEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取测试记录
  static Future<MissionTestResultEntity?> getTestMissionRecord(int unitTestId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/plan/test/mission/$unitTestId/final",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return MissionTestResultEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


}