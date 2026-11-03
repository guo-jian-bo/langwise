import 'dart:io';

import 'package:api/api.dart';
import 'package:get/get.dart';
import 'package:quiz_play/models/models.dart';
import 'package:quiz_play/models/quiz_operation_steps_model.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';
import '../widgets/widgets.dart';

class PracticeQuestionsReqest {
  /// 上报题目记录
  static Future<List<QuestionReportResultEntity>?> reportQuestion(Map<String, dynamic> data) async {
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/studies/exercise/record/submit",
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
      List? list = responseEntity.data['list'];
      if (list == null) return null;
      List<QuestionReportResultEntity> resList = [];
      for (var item in list) {
        if (item == null) continue;
        resList.add(QuestionReportResultEntity.fromJson(item));
      }
      return resList;
    } on FormatException catch (_) {
      // ToastUtils.showToast(text: e.source.message);
      ToastUtils.showToast(text: "评分失败");
      return null;
    } catch (e) {
      ToastUtils.showToast(text: "评分失败！");
      return null;
    }
  }

  /// 获取最后一次的评测状态 如果为空 说明没有评测 就调用开始评测接口 如果有评测 那么调用继续评测接口
  static Future<AssessmentLastResponseEntity?> getLastAssessment() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/assessment/last/status",
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
      if (responseEntity.data == null) return AssessmentLastResponseEntity();
      return AssessmentLastResponseEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 开始评测Ai 获取题目数据
  static Future<AssessmentQuizEntity?> getStartAssessmentAiData(Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/assessment/start/ai",
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
      return AssessmentQuizEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      if (Get.context == null) {
        ToastUtils.showToast(text: e.source.message);
        return null;
      }
      Future.delayed(const Duration(milliseconds: 300), () async {
        await AskDialog.showUserAsk(
          context: Get.context!,
          title: "温馨提示",
          content: e.source.message,
          showCancel: false,
        );
      });
      return null;
    } catch (e) {
      Future.delayed(const Duration(milliseconds: 300), () async {
        await AskDialog.showUserAsk(
          context: Get.context!,
          title: "温馨提示",
          content: "请求失败，请稍后再试",
          showCancel: false,
        );
      });
      return null;
    }
  }

  /// 获取评测历史
  static Future<AssessmentHistoryPageEntity?> getAssessmentHistory(int offset, int limit) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request("/studies/member/assessment/history/pages", Method.get,
          headers: config.headers,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          parameters: {
            "offset": offset,
            "limit": limit,
          });
      if (response == null) return null;
      return AssessmentHistoryPageEntity.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// 继续评测 获取题目数据
  static Future<AssessmentQuizEntity?> getContinueAssessmentData(int assessmentId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/assessment/$assessmentId/continue",
        Method.post,
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
      return AssessmentQuizEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      if (Get.context == null) {
        ToastUtils.showToast(text: e.source.message);
        return null;
      }
      Future.delayed(const Duration(milliseconds: 800), () async {
        await AskDialog.showUserAsk(
          context: Get.context!,
          title: "温馨提示",
          content: e.source.message,
          showCancel: false,
        );
        Get.back();
      });
      return null;
    } catch (e) {
      Future.delayed(const Duration(milliseconds: 800), () async {
        await AskDialog.showUserAsk(
          context: Get.context!,
          title: "温馨提示",
          content: "请求失败，请稍后再试",
          showCancel: false,
        );
        Get.back();
      });
      return null;
    }
  }

  /// 提交评测
  static Future<AssessmentQuizEntity?> submitAssessment(Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/assessment/exercise/submit",
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
      return AssessmentQuizEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 组装上报数据
  static Map<String, dynamic> getSubmitData(
    QuizModel quizModel,
    int quizDuration,
    QuizLogModel log,
    String startTime,
    {Map<String, dynamic>? extraContext}
  ) {
    final mergedContext = <String, dynamic>{...?quizModel.context?.toJson(), ...?extraContext};
    List<Map<String, dynamic>> contentList = [];
    if (quizModel.contentList != null) {
      for (var item in quizModel.contentList!) {
        if (item == null) continue;
        contentList.add(item.toJson());
      }
    }

    List<Map<String, dynamic>> stepList = [];

    for (QuizLogStepModel item in log.steps) {
      double durationDouble = item.durationUtc.inMilliseconds / 1000;

      stepList.add({
        "startTime": item.startTime != null ? DateFormatUtil.toUtcTime(item.startTime!).toIso8601String() : null,
        "duration": durationDouble,
        "trigger": item.trigger,
        "details": {
          "target": item.details?.target,
          "match": item.details?.match,
          "similarity": item.details?.similarity != null ? ((item.details?.similarity ?? 0) / 100) : null,
          "pool": item.details?.pool,
        },
      });
    }

    Map<String, dynamic> record = {
      "type": quizModel.testType,
      "exerciseType": quizModel.type,
      "exerciseId": quizModel.uid,
      "purpose": quizModel.purpose,
      "mode": log.mode,
      "status": log.status,
      "startTime": startTime,
      "duration": quizDuration,
      "context": mergedContext.isEmpty ? null : mergedContext,
      "contentList": contentList,
      "steps": stepList,
    };

    Map<String, dynamic> data = {
      "records": [record],
    };
    return data;
  }

  /// 评测结果详情
  static Future<AssessmentResultDetailEntity?> getAssessmentResultDetail(int assessmentId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/assessment/$assessmentId/result",
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
      return AssessmentResultDetailEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 评测结果详情Ai
  static Future<AiAssessmentResultDetailEntity?> getAiAssessmentResultDetail(int assessmentId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/assessment/$assessmentId/result/plan/v2",
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
      return AiAssessmentResultDetailEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 用户评测结果详情
  static Future<AssessmentResultDetailEntity?> getUserAssessmentResultDetail() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/assessment/detail",
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
      return AssessmentResultDetailEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 用户Ai评测结果详情
  static Future<AiAssessmentResultDetailEntity?> getUserAiAssessmentResultDetail() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/assessment/detail/plan/v2",
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
      return AiAssessmentResultDetailEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 记录提醒规划
  static Future<void> updateAssessmentStatus(int assessmentId) async {
     try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      await WiseHttp().request(
        "/studies/member/assessment/$assessmentId/show/update/status",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );
     
    } on FormatException catch (e) {
      print(e.source.message);
    } catch (e) {
      print(e.toString());
    }
  }

  /// 获取口语评测单词信息
  static Future<EvalWordsResultModel?> getAssessmentWord(EvalWordsRequestParameterModel reqData, {String? national}) async {
    try {
      Map<String, dynamic> parameters = {};
      if(national != null){
        parameters['national'] = national;
      }

      Map<String, dynamic> reqDataMap = reqData.toJson();
      RequestConfig config = RequestConfig(
        requireToken: true, 
        requireCache: true, 
        data: reqDataMap,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/languages/en/content/sentence/content/ipa/list",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: reqDataMap,
        parameters: parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return EvalWordsResultModel.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }
}
