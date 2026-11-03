import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class StudyAppRequest {
  /// 获取题目数据
  static Future<CourseDirectionExerciseEntity?> getExerciseData({Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(requireToken: true, data: data);
      dynamic response = await WiseHttp().request(
        "/studies/member/course/direction/exercise/category/list",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return CourseDirectionExerciseEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 暂存当前写作任务草稿。
  static Future<ZhenxieTaskDetailsMemberWriting?> saveCompositionTaskDraft({
    required int taskId,
    Map<String, dynamic>? data,
  }) async {
    try {
      RequestConfig config = RequestConfig(requireToken: true, data: data);
      dynamic response = await WiseHttp().request(
        "/studies/composition/tasks/$taskId/draft",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ZhenxieTaskDetailsMemberWriting.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 提交写作任务并触发批改。
  static Future<ZhenxieTaskSubmitResultEntity?> submitCompositionTask({
    required int taskId,
    Map<String, dynamic>? data,
  }) async {
    try {
      RequestConfig config = RequestConfig(requireToken: true, data: data);
      dynamic response = await WiseHttp().request(
        "/studies/composition/tasks/$taskId/submit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ZhenxieTaskSubmitResultEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 对指定习作重新发起批改。
  static Future<ZhenxieTaskSubmitResultEntity?> retryCompositionTaskReview({
    required int taskId,
    required int writingId,
  }) async {
    try {
      RequestConfig config = RequestConfig(requireToken: true);
      dynamic response = await WiseHttp().request(
        "/studies/composition/tasks/$taskId/review/$writingId/retry",
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
      return ZhenxieTaskSubmitResultEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 从批改页进入重写态，并返回当前可继续编辑的草稿。
  static Future<ZhenxieTaskDetailsMemberWriting?> rewriteCompositionTask({
    required int taskId,
  }) async {
    try {
      RequestConfig config = RequestConfig(requireToken: true);
      dynamic response = await WiseHttp().request(
        "/studies/composition/tasks/$taskId/rewrite",
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
      return ZhenxieTaskDetailsMemberWriting.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取指定任务下当前成员的批改历史与选中习作详情。
  static Future<ZhenxieTaskDetailsMemberDetailEntity?> getCompositionTaskMemberDetail({
    required int taskId,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      RequestConfig config = RequestConfig(requireToken: true, parameters: parameters);
      dynamic response = await WiseHttp().request(
        "/studies/composition/tasks/$taskId/member/detail",
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
      return ZhenxieTaskDetailsMemberDetailEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }
}
