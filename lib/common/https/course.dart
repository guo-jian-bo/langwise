import 'dart:io';

import 'package:api/api.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:wise_http/wise_http.dart';

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
    var response = await WiseHttp().request("/course-console/course/$uid/level/module/list", Method.post,
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
}
