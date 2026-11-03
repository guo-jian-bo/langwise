import 'package:api/api.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:wise_http/wise_http.dart';

class LessonTemplateUtil {
  // 获取LessonTemplate
  static Future<ResponseEntity<ListResponseEntity<LessonTemplateResponseEntity>>> fetchPages(
      {required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/lesson/template/pages", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ListResponseEntity<LessonTemplateResponseEntity>>.fromJson(response,
        fromJson: (json) => ListResponseEntity<LessonTemplateResponseEntity>.fromJson(json,
            fromJson: (json) => LessonTemplateResponseEntity.fromJson(json)));
  }

  // 创建
  static Future<ResponseEntity<LessonTemplateResponseEntity?>> create({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/lesson/template/create", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<LessonTemplateResponseEntity?>.fromJson(response,
        fromJson: (json) => LessonTemplateResponseEntity.fromJson(json));
  }

  // 复制
  static Future<ResponseEntity<LessonTemplateResponseEntity?>> copy(
      {required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/lesson/template/$uid/copy", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<LessonTemplateResponseEntity?>.fromJson(response,
        fromJson: (json) => LessonTemplateResponseEntity.fromJson(json));
  }

  // 编辑
  static Future<ResponseEntity<LessonTemplateResponseEntity?>> edit(
      {required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/lesson/template/$uid/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<LessonTemplateResponseEntity?>.fromJson(response,
        fromJson: (json) => LessonTemplateResponseEntity.fromJson(json));
  }
}
