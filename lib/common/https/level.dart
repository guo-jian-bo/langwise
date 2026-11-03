import 'package:api/api.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:wise_http/wise_http.dart';

class LevelUtil {
  // 获取module
  static Future<ResponseEntity<ListResponseEntity<LevelResponseEntity<ModuleResponseEntity>>>> fetchPages(
      {required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/level/pages", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ListResponseEntity<LevelResponseEntity<ModuleResponseEntity>>>.fromJson(response,
        fromJson: (json) => ListResponseEntity<LevelResponseEntity<ModuleResponseEntity>>.fromJson(json,
            fromJson: (json) => LevelResponseEntity<ModuleResponseEntity>.fromJson(json,
                fromJson: (json) => ModuleResponseEntity.fromJson(json))));
  }

  // 创建
  static Future<ResponseEntity<LevelResponseEntity?>> create({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/level/create", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<LevelResponseEntity?>.fromJson(response,
        fromJson: (json) => LevelResponseEntity.fromJson(json));
  }

  // 复制
  static Future<ResponseEntity<LevelResponseEntity?>> copy({required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/level/$uid/copy", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<LevelResponseEntity?>.fromJson(response,
        fromJson: (json) => LevelResponseEntity.fromJson(json));
  }

  // 编辑
  static Future<ResponseEntity<LevelResponseEntity?>> edit({required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/level/$uid/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<LevelResponseEntity?>.fromJson(response,
        fromJson: (json) => LevelResponseEntity.fromJson(json));
  }

  // 关联模块
  static Future<ResponseEntity<ListEntity<ModuleResponseEntity>>> relation(
      {required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/level/$uid/relation/module", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ListEntity<ModuleResponseEntity>>.fromJson(response,
        fromJson: (json) =>
            ListEntity<ModuleResponseEntity>.fromJson(json, fromJson: (json) => ModuleResponseEntity.fromJson(json)));
  }

  // 等级模块列表
  static Future<ResponseEntity<LevelResponseEntity<ModuleResponseEntity>?>> moduleList(
      {required levelId, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course-console/course/level/$levelId/module/list", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<LevelResponseEntity<ModuleResponseEntity>?>.fromJson(response,
        fromJson: (json) => LevelResponseEntity<ModuleResponseEntity>.fromJson(json,
            fromJson: (json) => ModuleResponseEntity.fromJson(json)));
  }
}

class LevelAppUtil {
  // 创建
  static Future<ResponseEntity<LevelResponseEntity?>> create({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/course/level/create", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<LevelResponseEntity?>.fromJson(response,
        fromJson: (json) => LevelResponseEntity.fromJson(json));
  }

  // 编辑
  static Future<ResponseEntity<LevelResponseEntity?>> edit({required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/course/level/$uid/edit", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<LevelResponseEntity?>.fromJson(response,
        fromJson: (json) => LevelResponseEntity.fromJson(json));
  }

  /// 排序级别
  /// 用于调整自定义课程中级别的显示顺序
  static Future<ResponseEntity<String>> order({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/course/order", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<String>.fromJson(response);
  }

  /// 切换级别状态
  /// 用于切换自定义课程级别的启用/禁用状态
  static Future<ResponseEntity<String?>> statusSwitch({required String uid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/course/user/custom/course/level/$uid/status/switch", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<String?>.fromJson(response);
  }
}
