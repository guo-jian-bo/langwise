import 'dart:io';

import 'package:api/api.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';

class ModuleUtil {
  // 获取module
  static Future<ResponseEntity<ListResponseEntity<ModuleResponseEntity<MiniUnitResponseEntity>>>> fetchPages(
      {required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/module/pages", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ListResponseEntity<ModuleResponseEntity<MiniUnitResponseEntity>>>.fromJson(response,
        fromJson: (json) => ListResponseEntity<ModuleResponseEntity<MiniUnitResponseEntity>>.fromJson(json,
            fromJson: (json) => ModuleResponseEntity<MiniUnitResponseEntity>.fromJson(json,
                fromJson: (json) => MiniUnitResponseEntity.fromJson(json))));
  }

  // 创建
  static Future<ResponseEntity<ModuleResponseEntity?>> create({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/module/create", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ModuleResponseEntity?>.fromJson(response,
        fromJson: (json) => ModuleResponseEntity.fromJson(json));
  }

  // 复制
  static Future<ResponseEntity<ModuleResponseEntity?>> copy(
      {required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/module/$uid/copy", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ModuleResponseEntity?>.fromJson(response,
        fromJson: (json) => ModuleResponseEntity.fromJson(json));
  }

  // 编辑
  static Future<ResponseEntity<ModuleResponseEntity?>> edit(
      {required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/module/$uid/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ModuleResponseEntity?>.fromJson(response,
        fromJson: (json) => ModuleResponseEntity.fromJson(json));
  }

  // 获取模块下的知识点
  static Future<ResponseEntity<ListEntity<UnitResponseEntity>>> knowledge(
      {required String moduleId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/module/$moduleId/knowledge/list", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    if (response is Map<String, dynamic>) {
      if (response.containsKey('data')) {
        if (response['data'] is Map<String, dynamic>) {
          if (response['data'].containsKey('list')) {
            response['data'] = response['data']['list'];
          }
        }
      }
    }

    return ResponseEntity<ListEntity<UnitResponseEntity>>.fromJson(response,
        fromJson: (json) =>
            ListEntity<UnitResponseEntity>.fromJson(json, fromJson: (json) => UnitResponseEntity.fromJson(json)));
  }

  // 获取模块下简单单元列表
  static Future<ResponseEntity<ListEntity<UnitResponseEntity>>> simpleUnits(
      {required String moduleId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/module/$moduleId/unit/simple/list", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<ListEntity<UnitResponseEntity>>.fromJson(response,
        fromJson: (json) =>
            ListEntity<UnitResponseEntity>.fromJson(json, fromJson: (json) => UnitResponseEntity.fromJson(json)));
  }

  // 添加模块下的知识点
  static Future<ResponseEntity<String?>> add({required String moduleId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/module/$moduleId/knowledge/add", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<String?>.fromJson(response);
  }

  // 编辑模块下的知识点
  static Future<ResponseEntity<String?>> editKnowledge(
      {required String moduleId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/module/$moduleId/knowledge/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<String?>.fromJson(response);
  }

  // 获取单元课时列表
  static Future<
          ResponseEntity<
              CourseModuleInfoResponseEntity<ModuleResponseEntity, NewUnitResponseEntity<LessonResponseEntity>>>>
      unitLessons({required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/module/$uid/unit/lesson/list", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<
            CourseModuleInfoResponseEntity<ModuleResponseEntity, NewUnitResponseEntity<LessonResponseEntity>>>.fromJson(
        response,
        fromJson: (json) => CourseModuleInfoResponseEntity.fromJson(json,
            buildCourseInfo: (json) => ModuleResponseEntity.fromJson(json),
            buildCourseLevel: (json) => NewUnitResponseEntity<LessonResponseEntity>.fromJson(json,
                fromJson: (json) => LessonResponseEntity.fromJson(json))));
  }

  // 删除知识点单元
  static Future<ResponseEntity<String?>> delete({required moduleId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/module/$moduleId/knowledge/remove", Method.delete,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<String?>.fromJson(response);
  }

  ///创建课时
  static Future<LessonResponseEntity?> createLesson(String? language, int? unitId, int? lessonTemplateId,
      {String? name, String? description}) async {
    try {
      if (language == null || unitId == null || lessonTemplateId == null) return null;
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: {
          "language": language,
          "unitId": unitId,
          "name": name,
          "description": description,
          "lessonTemplateId": lessonTemplateId,
          "type": "LEARN_PRACTICE",
        },
      );
      dynamic response = await WiseHttp()
          .request(
            "/course-console/course/lesson/create",
            Method.post,
            headers: config.headers,
            requireToken: config.requireToken,
            requireCache: config.requireCache,
            parameters: config.parameters,
            data: config.data,
          )
          .catchError((_) {});
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      LessonResponseEntity result = LessonResponseEntity.fromJson(responseEntity.data);
      return result;
    } catch (e) {
      return null;
    }
  }

  /// 获取音标列表
  static Future<PhonicsEntity?> getPhonicsList(Map<String, dynamic> parameters, Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/course/module/phonics/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: data,
        parameters: parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      PhonicsEntity entity = PhonicsEntity.fromJson(responseEntity.data);
      return entity;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

}

class ModuleAppUtil {
  // 编辑
  static Future<ResponseEntity<AppCourseModuleResponseEntity?>> edit(
      {required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/course/module/$uid/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<AppCourseModuleResponseEntity?>.fromJson(response,
        fromJson: (json) => AppCourseModuleResponseEntity.fromJson(json));
  }

  // 切换状态
  static Future<ResponseEntity<String?>> statusSwitch({required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/course/module/$uid/status/switch", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<String?>.fromJson(response);
  }

  // 获取模块下的知识点
  static Future<ResponseEntity<AppModuleResponseEntity<AppUnitResponseEntity<Knowledge>, Knowledge>>> knowledge(
      {required String moduleId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/course/module/$moduleId/knowledge/list", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<AppModuleResponseEntity<AppUnitResponseEntity<Knowledge>, Knowledge>>.fromJson(response,
        fromJson: (json) => AppModuleResponseEntity<AppUnitResponseEntity<Knowledge>, Knowledge>.fromJson(json,
            fromJson: (json) =>
                AppUnitResponseEntity<Knowledge>.fromJson(json, fromJson: (json) => Knowledge.fromJson(json)),
            fromUnGroupedJson: (json) => Knowledge.fromJson(json)));
  }

  

}
