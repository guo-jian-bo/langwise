import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:api/api.dart';
import 'package:quiz_play/models/models.dart';
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

  /// 获取当前学习单元列表
  static Future<CurrentCoursePlanInfoEntity?> getCurrentCoursePlanInfoList() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/plan/current/course/info/list",
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
      return CurrentCoursePlanInfoEntity.fromJson(responseEntity.data);
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

  /// 获取钻石获得明细
  static Future<TaskDiamondDetailEntity?> getTaskDiamondDetailList() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/task/diamond/detail/list",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return TaskDiamondDetailEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 将钻石明细标为已读
  static Future<bool> readTaskDiamondDetail(List<String> uids) async {
    if (uids.isEmpty) return true;
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {
          "uids": uids,
        },
      );
      dynamic response = await WiseHttp().request(
        "/studies/task/diamond/detail/read",
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
      return true;
    } on FormatException catch (_) {
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 获取任务组列表
  static Future<MissionSpecialV3Entity?> getTaskMissionGroup(String type) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/task/$type/task/list/v3",
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
      return MissionSpecialV3Entity.fromJson(responseEntity.data);
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

  /// 根据选择的内容获取口语-自然拼读题目
  static Future<SpeakingQuizPayloadEntity?> getSpeakingSoundBlockQuizByKnowledgeList(
    List<TaskMissionEntityMissionKnowledgeItem> knowledgeList,
  ) async {
    if (knowledgeList.isEmpty) return null;
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {
          "knowledgeList": knowledgeList.map((item) => item.toJson()).toList(),
        },
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/today/content/speaking/exercise/sound_block/list",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return _parseSpeakingQuizPayload(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 根据选择的内容获取口语-影子跟读题目
  static Future<SpeakingQuizPayloadEntity?> getSpeakingPronunciationQuizByKnowledgeList(
    List<TaskMissionEntityMissionKnowledgeItem> knowledgeList,
  ) async {
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.todayPronunciationList)) {
      ToastUtils.showToast(text: "无权限");
      return null;
    }
    
    if (knowledgeList.isEmpty) return null;
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {
          "knowledgeList": knowledgeList.map((item) => item.toJson()).toList(),
        },
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/today/content/speaking/exercise/pronunciation/list",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return _parseSpeakingQuizPayload(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 上报内容学习记录
  static Future<bool> reportContentLearn(Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/content/learn/upload",
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
      return true;
    } on FormatException catch (_) {
      return false;
    } catch (e) {
      return false;
    }
  }

  static SpeakingQuizPayloadEntity _parseSpeakingQuizPayload(dynamic data) {
    if (data is! Map) return SpeakingQuizPayloadEntity();
    final map = data.cast<String, dynamic>();
    final rawList = map['list'];
    if (rawList is! List) return SpeakingQuizPayloadEntity();

    final quizList = <QuizModel>[];
    final contextByExerciseId = <int, Map<String, dynamic>>{};
    for (final rawItem in rawList) {
      final normalized = _normalizeSpeakingQuizItem(rawItem);
      final quiz = QuizModel.fromJson(normalized);
      if (quiz.uid != null) {
        final context = normalized['context'];
        if (context is Map) {
          contextByExerciseId[quiz.uid!] = Map<String, dynamic>.from(context.cast<String, dynamic>());
        }
      }
      quizList.add(quiz);
    }
    return SpeakingQuizPayloadEntity(
      quizList: quizList,
      contextByExerciseId: contextByExerciseId,
    );
  }

  static Map<String, dynamic> _normalizeSpeakingQuizItem(dynamic raw) {
    if (raw is! Map) return <String, dynamic>{};
    final item = raw.cast<String, dynamic>();
    final exercise = item['exercise'];
    if (exercise is! Map) {
      return Map<String, dynamic>.from(item);
    }

    final normalized = Map<String, dynamic>.from(exercise.cast<String, dynamic>());
    final outerContext = item['context'];
    final innerContext = normalized['context'];
    if (outerContext is Map || innerContext is Map) {
      normalized['context'] = {
        if (outerContext is Map) ...outerContext.cast<String, dynamic>(),
        if (innerContext is Map) ...innerContext.cast<String, dynamic>(),
      };
    }
    return normalized;
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

  /// 获取任务内容详情列表
  static Future<List<UnitKnowledgePointsEntityKnowledgeList>> getMissionContentDetailList(
    List<TaskMissionEntityMissionKnowledgeItem> knowledgeList,
    {String? missionType}
  ) async {
    if (knowledgeList.isEmpty) return <UnitKnowledgePointsEntityKnowledgeList>[];
    try {
      final data = {
        "knowledgeList": knowledgeList.map((item) => item.toJson()).toList(),
        if (missionType != null && missionType.isNotEmpty) "missionType": missionType,
      };
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/course/content/detail/list",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return <UnitKnowledgePointsEntityKnowledgeList>[];
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return <UnitKnowledgePointsEntityKnowledgeList>[];
      }
      final dataMap = responseEntity.data;
      if (dataMap is! Map<String, dynamic>) return <UnitKnowledgePointsEntityKnowledgeList>[];
      final rawList = dataMap['knowledgeList'] ?? dataMap['list'];
      if (rawList is! List) return <UnitKnowledgePointsEntityKnowledgeList>[];
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(UnitKnowledgePointsEntityKnowledgeList.fromJson)
          .toList();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return <UnitKnowledgePointsEntityKnowledgeList>[];
    } catch (e) {
      return <UnitKnowledgePointsEntityKnowledgeList>[];
    }
  }
}
