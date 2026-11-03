import 'package:api/api.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:wise_http/wise_http.dart';

class LessonUtil {
  // 获取Lesson
  static Future<ResponseEntity<ListResponseEntity<LessonResponseEntity>>> fetchPages(
      {required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/lesson/pages", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ListResponseEntity<LessonResponseEntity>>.fromJson(response,
        fromJson: (json) => ListResponseEntity<LessonResponseEntity>.fromJson(json,
            fromJson: (json) => LessonResponseEntity.fromJson(json)));
  }

  // 创建
  static Future<ResponseEntity<LessonResponseEntity?>> create({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/lesson/create", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<LessonResponseEntity?>.fromJson(response,
        fromJson: (json) => LessonResponseEntity.fromJson(json));
  }

  // 复制
  static Future<ResponseEntity<LessonResponseEntity?>> copy(
      {required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/lesson/$uid/copy", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<LessonResponseEntity?>.fromJson(response,
        fromJson: (json) => LessonResponseEntity.fromJson(json));
  }

  // 编辑
  static Future<ResponseEntity<LessonResponseEntity?>> edit(
      {required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/lesson/$uid/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<LessonResponseEntity?>.fromJson(response,
        fromJson: (json) => LessonResponseEntity.fromJson(json));
  }
}
