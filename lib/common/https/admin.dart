

import 'package:api/api.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:wise_http/wise_http.dart';

class AdminUtil {
  // 审核人员列表
  static Future<ResponseEntity<ListResponseEntity<ReviewerEntity>>> fetchReviewers(
      {required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/admin/content/review/inspector/list", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ListResponseEntity<ReviewerEntity>>.fromJson(response,
        fromJson: (json) =>
            ListResponseEntity<ReviewerEntity>.fromJson(json, fromJson: (json) => ReviewerEntity.fromJson(json)));
  }

  // 搜索人员列表
  static Future<ResponseEntity<ListResponseEntity<ReviewerEntity>>> search({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/admin/content/review/inspector/search", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ListResponseEntity<ReviewerEntity>>.fromJson(response,
        fromJson: (json) =>
            ListResponseEntity<ReviewerEntity>.fromJson(json, fromJson: (json) => ReviewerEntity.fromJson(json)));
  }

  // 用户审核详情
  static Future<ResponseEntity<ReviewerStatsEntity>> userReviewInfo({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/admin/content/review/inspector/info", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ReviewerStatsEntity>.fromJson(response,
        fromJson: (json) => ReviewerStatsEntity.fromJson(json));
  }

  // 详情
  static Future<ResponseEntity<KnowledgePointDetail>> detail({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/admin/content/review/load/task/detail", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<KnowledgePointDetail>.fromJson(response,
        fromJson: (json) => KnowledgePointDetail.fromJson(json));
  }

  // 简单知识点列表
  static Future<ResponseEntity<ListResponseEntity<KnowledgePoint>>> simplePoints(
      {required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/admin/content/review/simple/list", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);
    return ResponseEntity<ListResponseEntity<KnowledgePoint>>.fromJson(response,
        fromJson: (json) =>
            ListResponseEntity<KnowledgePoint>.fromJson(json, fromJson: (json) => KnowledgePoint.fromJson(json)));
  }

  // 审核
  static Future<ResponseEntity<String>> review({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/admin/content/review/submit/level", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<String>.fromJson(response);
  }

  // 知识点风格图片 KnowledgeAdmerationDetail
  static Future<ResponseEntity<KnowledgeAdmerationDetail>> knowledgeReview({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/admin/content/review/knowledge/images", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<KnowledgeAdmerationDetail>.fromJson(response,
        fromJson: (json) => KnowledgeAdmerationDetail.fromJson(json));
  }

  // 知识点风格图片 KnowledgeAdmerationDetail
  static Future<ResponseEntity<UnitImagePromptDetail>> knowledgePrompt(
      {required int imageUid, required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request(
        "/language-console/admin/content/review/image/$imageUid/prompt", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<UnitImagePromptDetail>.fromJson(response,
        fromJson: (json) => UnitImagePromptDetail.fromJson(json));
  }

  // 重新生成图片
  static Future<ResponseEntity<ImageRegenerationConfig>> regenerateImage({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/admin/content/review/image/regenerate", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<ImageRegenerationConfig>.fromJson(response,
        fromJson: (json) => ImageRegenerationConfig.fromJson(json));
  }

  /// 获取图片重新生成结果
  ///
  /// 用于获取图片重新生成任务的执行结果
  /// [config] 请求配置，包含请求参数、头部信息等
  /// 返回包含重新生成结果的响应实体
  static Future<ResponseEntity<UnitImagePromptDetail>> getRegenerateResult({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request(
        "/language-console/admin/content/review/image/regenerate/result", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<UnitImagePromptDetail>.fromJson(response,
        fromJson: (json) => UnitImagePromptDetail.fromJson(json));
  }

  /// 保存图片审核结果
  ///
  /// 用于保存图片审核的结果数据
  /// [config] 请求配置，包含请求参数、头部信息等
  /// 返回保存操作的响应结果
  static Future<ResponseEntity<String>> saveImageReviewResult({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/admin/content/review/image/result/save", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<String>.fromJson(response);
  }

  /// 加载提示词
  ///
  /// 用于加载内容审核的提示词信息
  /// [config] 请求配置，包含请求参数、头部信息等
  /// 返回包含提示词信息的响应实体
  static Future<ResponseEntity<UnitImagePromptDetail>> loadPrompt({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/language-console/admin/content/review/load/prompt", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<UnitImagePromptDetail>.fromJson(response,
        fromJson: (json) => UnitImagePromptDetail.fromJson(json));
  }
}
