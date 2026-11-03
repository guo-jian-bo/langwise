import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class CourseConsoleRequest {

  /// 获取单元写作管线详情
  static Future<CourseUnitWritingDetailEntity?> getUnitWritingDetail(int unitId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/writing/stage/detail",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return CourseUnitWritingDetailEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 保存单元写作挂载
  static Future<CourseUnitWritingDetailEntity?> saveUnitWritingMount(int unitId, Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/writing/mount/save",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return CourseUnitWritingDetailEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取单元写作任务列表
  static Future<CourseUnitWritingTaskListEntity?> getUnitWritingTaskList(int unitId, {bool isManagement = true}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      final String path = isManagement
          ? "/course-console/unit/$unitId/writing/task/list"
          : "/course/course/write/unit/$unitId/writing/task/list";
      dynamic response = await WiseHttp().request(
        path,
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        if (isManagement) {
          ToastUtils.showManageToast(text: responseEntity.message ?? "");
        } else {
          ToastUtils.showToast(text: responseEntity.message ?? "");
        }
        return null;
      }
      if (responseEntity.data == null) return null;
      return CourseUnitWritingTaskListEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      if (isManagement) {
        ToastUtils.showManageToast(text: e.source.message);
      } else {
        ToastUtils.showToast(text: e.source.message);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取单元写作任务编辑页初始化数据
  static Future<CourseUnitWritingTaskEditorPageEntity?> getUnitWritingTaskEditor(int unitId, {int? taskId}) async {
    try {
      final Map<String, dynamic> parameters = <String, dynamic>{};
      if (taskId != null) {
        parameters["taskId"] = taskId;
      }
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/writing/task/editor",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return CourseUnitWritingTaskEditorPageEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 新建单元写作任务
  static Future<CourseUnitWritingEditorTaskEntity?> createUnitWritingTask(int unitId, Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/writing/task/create",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return CourseUnitWritingEditorTaskEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 编辑单元写作任务
  static Future<CourseUnitWritingEditorTaskEntity?> editUnitWritingTask(int unitId, Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/writing/task/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return CourseUnitWritingEditorTaskEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 编辑单元写作范文上下架状态
  static Future<bool> editUnitWritingTaskExemplarAccess(
    int unitId, {
    required int compositionId,
    required String access,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: <String, dynamic>{
          "compositionId": compositionId,
          "access": access,
        },
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/writing/task/exemplar/access",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message ?? "");
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 从当前单元移除写作任务
  static Future<bool> removeUnitWritingTask(int unitId, int taskId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: <String, dynamic>{
          "taskId": taskId,
        },
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/writing/task/remove",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        parameters: config.parameters,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "");
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// AI 写文字范文
  static Future<String?> generateUnitWritingTaskExemplar(int unitId, Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/writing/task/exemplar/generate",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "");
        return null;
      }
      return responseEntity.data?.toString();
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 反向处理文字范文
  static Future<String?> structureUnitWritingTaskExemplar(int unitId, Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/writing/task/exemplar/structure",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "");
        return null;
      }
      return responseEntity.data?.toString();
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取管理端范文练习列表。
  static Future<ZhenxieTaskExerciseEntity?> getUnitWritingExemplarExerciseList({
    required int unitId,
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: params,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/writing/exemplar/exercise/list",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return ZhenxieTaskExerciseEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

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


  /// 获取单元目标列表
  static Future<CourseUnitTargetEntity?> getCourseUnitTargetList({
    required int unitId,
    Map<String, dynamic>? params, 
    Map<String, dynamic>? data,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: params,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/knowledge/list/v2",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return CourseUnitTargetEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取单元目标语法列表 /unit/{unitId}/knowledge/grammar/goals/sentence`
  static Future<CourseUnitTargetSentenceGrammarEntity?> getCourseUnitTargetSentenceGrammarList({
    required int unitId,
    Map<String, dynamic>? params, 
    Map<String, dynamic>? data,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: params,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/knowledge/grammar/goals/sentence",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return CourseUnitTargetSentenceGrammarEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取“添加语法”页首屏数据 /unit/{unitId}/knowledge/grammar/goals/add-page`
  static Future<CourseUnitTargetSentenceGrammarEntity?> getCourseUnitTargetGrammarAddPage({
    required int unitId,
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: params,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/knowledge/grammar/goals/add-page",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return CourseUnitTargetSentenceGrammarEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 从已选句子与句组召回可追加的语法资产。
  static Future<CourseUnitTargetAddGrammarRecallEntity?> recallCourseUnitTargetGrammarFromMaterials({
    required int unitId,
    required List<int> knowledgeUids,
    required List<int> setUids,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {
          "knowledgeUids": knowledgeUids,
          "setUids": setUids,
        },
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/knowledge/grammar/goals/sentence/grammar/recall",
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return CourseUnitTargetAddGrammarRecallEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 将手选语法资产异步追加到当前单元。
  static Future<CourseUnitTargetAddGrammarTaskStartEntity?> appendCourseUnitTargetGrammarFromMaterials({
    required int unitId,
    required List<int> knowledgeUids,
    required List<int> setUids,
    required List<Map<String, String>> assetRefs,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {
          "knowledgeUids": knowledgeUids,
          "setUids": setUids,
          "assetRefs": assetRefs,
        },
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/knowledge/grammar/goals/sentence/grammar/from-materials",
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return CourseUnitTargetAddGrammarTaskStartEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 查询算法任务状态。
  static Future<CourseUnitTargetAddGrammarTaskStatusEntity?> getAlgorithmTaskStatus({
    required int taskId,
    int limit = 200,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: {
          "limit": limit,
        },
      );
      dynamic response = await WiseHttp().request(
        "/course-console/algorithm/task/status/$taskId",
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return CourseUnitTargetAddGrammarTaskStatusEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 查询课程语法target详情
  static Future<ManageUnitGrammarTargetDetailEntity?> getManageUnitGrammarTargetDetail({
    required int unitId,
    Map<String, dynamic>? params, 
    Map<String, dynamic>? data,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: params,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/knowledge/grammar/targets/detail",
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageUnitGrammarTargetDetailEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取管理端语法详情页底部签发组列表。
  static Future<List<CourseUnitTargetSentenceGrammarGroupEntity>?> getCourseUnitGrammarDetailsGroupList({
    required int unitId,
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: params,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/knowledge/grammar/target/sentence/realization/set/unified/list",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
        return null;
      }
      List? list = responseEntity.data['list'];
      if (list == null) return null;
      return list.map((item) {
        return CourseUnitTargetSentenceGrammarGroupEntity.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取单元目标句法统计
  static Future<UnitTargetSyntaxStatisticsEntity?> getCourseUnitTargetSyntaxStatistics({
    required int unitId,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/knowledge/grammar/summary",
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return UnitTargetSyntaxStatisticsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 同步知识点内容
  static Future<String?> syncKnowledgeContent({
    required Map<String, dynamic> data,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/course-unit-knowledge-sync/knowledge/content",
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取单元下已有句子结构列表
  static Future<List<PatternBlueprintSentenceBriefEntity>?> getUnitSentenceStructureBlueprintList({
    required int unitId,
    required int targetId,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/knowledge/grammar/target/$targetId/sentence/all/struct/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showToast(
          text: responseEntity.message ?? "",
        );
        return null;
      }
      if (responseEntity.data == null) return null;
      List<dynamic> list = responseEntity.data['list'];
      List<PatternBlueprintSentenceBriefEntity> responseList = list.map((e) => PatternBlueprintSentenceBriefEntity.fromJson(e)).toList();
      return responseList;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

}
