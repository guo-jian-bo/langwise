import 'dart:io';

import 'package:api/api.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/dio_interceptors/dio_interceptor_utils.dart';
import '../../utils/utils.dart';

class CourseUtil {


  /// 获取course module的信息
  static Future<List<PlanEntityPlanPathCoursesStudyPlanStartUnitInfo>?> getCourseModuleInfo({Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/course/module/unit/lesson/infos",
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
      if(list == null) return null;
      List<PlanEntityPlanPathCoursesStudyPlanStartUnitInfo> respList = [];
      for (var element in list) {
        PlanEntityPlanPathCoursesStudyPlanStartUnitInfo info = PlanEntityPlanPathCoursesStudyPlanStartUnitInfo.fromJson(element);
        respList.add(info);
      }
      return respList;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

 
  // 获取courses
  static Future<ResponseEntity<ListResponseEntity<CourseResponseEntity>>> fetchCourses(
      {required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/pages", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ListResponseEntity<CourseResponseEntity>>.fromJson(response,
        fromJson: (json) => ListResponseEntity<CourseResponseEntity>.fromJson(json,
            fromJson: (json) => CourseResponseEntity.fromJson(json)));
  }

  // 创建
  static Future<ResponseEntity<CourseResponseEntity?>> create({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/create", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<CourseResponseEntity?>.fromJson(response,
        fromJson: (json) => CourseResponseEntity.fromJson(json));
  }

  // 复制
  static Future<ResponseEntity<CourseResponseEntity?>> copy(
      {required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/$uid/copy", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<CourseResponseEntity?>.fromJson(response,
        fromJson: (json) => CourseResponseEntity.fromJson(json));
  }

  // 编辑
  static Future<ResponseEntity<CourseResponseEntity?>> edit(
      {required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/$uid/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<CourseResponseEntity?>.fromJson(response,
        fromJson: (json) => CourseResponseEntity.fromJson(json));
  }

  // 课程排序
  static Future<ResponseEntity<String?>> order({required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/$uid/order", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<String?>.fromJson(response);
  }

  // 课程等级及模块查询
  static Future<
          ResponseEntity<CourseInfoResponseEntity<CourseResponseEntity, LevelResponseEntity<ModuleResponseEntity>>>>
      levelModules({required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/$uid/level/module/list/v2", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<
            CourseInfoResponseEntity<CourseResponseEntity, LevelResponseEntity<ModuleResponseEntity>>>.fromJson(
        response,
        fromJson: (json) => CourseInfoResponseEntity.fromJson(json,
            buildCourseInfo: (json) => CourseResponseEntity.fromJson(json),
            buildCourseLevel: (json) => LevelResponseEntity<ModuleResponseEntity>.fromJson(json,
                fromJson: (json) => ModuleResponseEntity.fromJson(json))));
  }

  // 关联模块
  static Future<ResponseEntity<ListEntity<LevelResponseEntity>>> relation(
      {required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/$uid/relation/level", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ListEntity<LevelResponseEntity>>.fromJson(response,
        fromJson: (json) =>
            ListEntity<LevelResponseEntity>.fromJson(json, fromJson: (json) => LevelResponseEntity.fromJson(json)));
  }
}

// APP端
class CourseAppUtil {
  // 创建
  static Future<ResponseEntity<AppCourseInfoResponseEntity?>> create({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/course/create", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<AppCourseInfoResponseEntity?>.fromJson(response,
        fromJson: (json) => AppCourseInfoResponseEntity.fromJson(json));
  }

  // 编辑
  static Future<ResponseEntity<AppCourseInfoResponseEntity?>> edit(
      {required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/course/$uid/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<AppCourseInfoResponseEntity?>.fromJson(response,
        fromJson: (json) => AppCourseInfoResponseEntity.fromJson(json));
  }

  // 课程等级模块列表
  static Future<
          ResponseEntity<ListEntity<AppCourseInfoResponseEntity<LevelResponseEntity<AppCourseModuleResponseEntity>>>>>
      courseLevelModules({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/course/level/module/list", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<
            ListEntity<AppCourseInfoResponseEntity<LevelResponseEntity<AppCourseModuleResponseEntity>>>>.fromJson(
        response,
        fromJson: (json) =>
            ListEntity<AppCourseInfoResponseEntity<LevelResponseEntity<AppCourseModuleResponseEntity>>>.fromJson(
                json["list"],
                fromJson: (json) =>
                    AppCourseInfoResponseEntity<LevelResponseEntity<AppCourseModuleResponseEntity>>.fromJson(json,
                        fromJson: (json) => LevelResponseEntity<AppCourseModuleResponseEntity>.fromJson(json,
                            fromJson: (json) => AppCourseModuleResponseEntity.fromJson(json)))));
  }

  /// 批量查询写作语法 Target 轻量信息。
  static Future<List<CourseWriteTargetItemEntity>?> getCourseWriteTargetList({
    Map<String, dynamic>? data,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course/course/write/target/list",
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
      if (responseEntity.data == null || responseEntity.data is! List) return null;
      return (responseEntity.data as List).map((item) {
        return CourseWriteTargetItemEntity.fromJson(item);
      }).toList();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取用户端范文练习列表。
  static Future<ZhenxieTaskExerciseEntity?> getWritingExemplarExerciseList({
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
        "/course/course/write/writing/exemplar/exercise/list",
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
    } catch (e) {
      return null;
    }
  }

  /// 复用其他词汇知识点到当前课程
  ///
  /// 调用API复用其他课程的词汇知识点到当前课程
  /// [config] 请求配置信息
  /// 返回包含复用结果的响应实体
  static Future<ResponseEntity<ReuseVocabularyKnowledgeResponseEntity?>> reuseVocabularyKnowledge({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/v2/reuse/other/vocabulary", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ReuseVocabularyKnowledgeResponseEntity?>.fromJson(response,
        fromJson: (json) => ReuseVocabularyKnowledgeResponseEntity.fromJson(json));
  }

  /// 获取用户自定义课程知识信息
  ///
  /// 获取用户添加的知识信息页面数据
  static Future<ResponseEntity<dynamic>> getUserCustomKnowledgeInfo({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/add/knowledge/info/page", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<dynamic>.fromJson(response);
  }

  /// 获取课程生成状态信息
  ///
  /// 根据任务ID获取课程创建/生成的状态信息
  ///
  /// 参数:
  /// - [config]: 请求配置信息
  ///
  /// 返回值:
  /// - 包含课程生成状态信息的响应实体
  static Future<ResponseEntity<CourseGenerateStatusResponseEntity?>> getGenerateStatusInfo(
      {required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request(
      "/course/user/custom/load/generate/status/info",
      Method.get,
      data: config.data,
      parameters: config.parameters,
      options: config.options,
      cancelToken: config.cancelToken,
      requireToken: config.requireToken,
      requireCache: config.requireCache,
      headers: rawHeader,
    );

    return ResponseEntity<CourseGenerateStatusResponseEntity?>.fromJson(response,
        fromJson: (json) => CourseGenerateStatusResponseEntity.fromJson(json));
  }

  /// 获取用户自定义课程进度级别
  ///
  /// 获取指定用户和课程的进度级别信息
  ///
  /// 参数:
  /// - [config]: 请求配置信息
  ///
  /// 返回值:
  /// - 包含课程进度级别信息的响应实体
  static Future<ResponseEntity<String>> getUserCustomCourseProgressLevel({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request(
      "/course/user/custom/course/progress/level",
      Method.post,
      data: config.data,
      parameters: config.parameters,
      options: config.options,
      cancelToken: config.cancelToken,
      requireToken: config.requireToken,
      requireCache: config.requireCache,
      headers: rawHeader,
    );

    return ResponseEntity<String>.fromJson(response);
  }

  /// 获取用户自定义课程进度模块
  ///
  /// 获取指定用户和课程的进度模块信息
  ///
  /// 参数:
  /// - [config]: 请求配置信息
  ///
  /// 返回值:
  /// - 包含课程进度模块信息的响应实体
  static Future<ResponseEntity<dynamic>> getUserCustomCourseProgressModule({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request(
      "/course/user/custom/course/progress/module",
      Method.post,
      data: config.data,
      parameters: config.parameters,
      options: config.options,
      cancelToken: config.cancelToken,
      requireToken: config.requireToken,
      requireCache: config.requireCache,
      headers: rawHeader,
    );

    return ResponseEntity<dynamic>.fromJson(response);
  }

  /// 获取用户自定义课程级别模块列表
  ///
  /// 获取指定用户自定义课程的级别和模块列表信息
  ///
  /// 参数:
  /// - [config]: 请求配置信息
  ///
  /// 返回值:
  /// - 包含课程级别模块列表信息的响应实体

  // 课程等级模块列表
  static Future<
          ResponseEntity<ListEntity<AppCourseInfoResponseEntity<LevelResponseEntity<AppCourseModuleResponseEntity>>>>>
      getUserCustomCourseLevelModuleListInfo({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/course/level/module/list/info", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<
            ListEntity<AppCourseInfoResponseEntity<LevelResponseEntity<AppCourseModuleResponseEntity>>>>.fromJson(
        response,
        fromJson: (json) =>
            ListEntity<AppCourseInfoResponseEntity<LevelResponseEntity<AppCourseModuleResponseEntity>>>.fromJson(
                json["list"],
                fromJson: (json) =>
                    AppCourseInfoResponseEntity<LevelResponseEntity<AppCourseModuleResponseEntity>>.fromJson(json,
                        fromJson: (json) => LevelResponseEntity<AppCourseModuleResponseEntity>.fromJson(json,
                            fromJson: (json) => AppCourseModuleResponseEntity.fromJson(json)))));
  }

  /// 获取lession题目列表
  static Future<List<PlanQuizEntityExercises>?> getCourseLessonExerciseList({
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
  }) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: params,
        data: data,
        options: Options(
          extra: {
            DioInterceptorUtils.visualStyleExtraKey: true,
          },
        ),
      );
      dynamic response = await WiseHttp().request(
        "/course/course/lesson/exercise/all/list",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
        options: config.options,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      List? list = responseEntity.data['list'];
      if (list == null) return null;
      return list.map((item) => PlanQuizEntityExercises.fromJson(item)).toList();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取单元目标列表
  static Future<CourseUnitTargetEntity?> getCourseUnitTargetList({
    required int courseId,
    required int moduleId,
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
        "/course/course/$courseId/module/$moduleId/unit/$unitId/knowledge/list/v2",
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
        "/course/course/unit/$unitId/knowledge/grammar/list",
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
        "/course/unit/$unitId/knowledge/grammar/targets/detail",
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

  /// 获取单元目标句法统计
  static Future<UnitTargetSyntaxStatisticsEntity?> getCourseUnitTargetSyntaxStatistics({
    required int unitId,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/course/course/unit/$unitId/knowledge/grammar/summary",
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

  /// 获取单元句子的句组列表
  static Future<ListResponseEntity<CourseUnitTargetSentenceGrammarGroupEntity>?> getUnitSentenceGrammarList({
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
        "/course/course/unit/$unitId/knowledge/grammar/sentence/realization/set/unified/pages",
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
      return ListResponseEntity<CourseUnitTargetSentenceGrammarGroupEntity>.fromJson(responseEntity.data,
          fromJson: CourseUnitTargetSentenceGrammarGroupEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取单元语法详情页底部签发组列表。
  static Future<List<CourseUnitTargetSentenceGrammarGroupEntity>?> getCourseUnitGrammarDetailsGroupList({
    required int unitId,
    required int targetUid,
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
        "/course/course/write/unit/$unitId/target/$targetUid/sentence/realization/set/unified/list",
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
    } catch (e) {
      return null;
    }
  }



}
