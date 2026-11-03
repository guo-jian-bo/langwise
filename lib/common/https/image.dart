import 'package:api/entities/entities.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:wise_http/wise_http.dart';

class ImageUtil {
  // 获取所有图片
  static Future<ResponseEntity<ResponseWrapper<KnowledgePoint>>> fetchImages({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/languages/content/review/list", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<ResponseWrapper<KnowledgePoint>>.fromJson(
      response,
      fromJson: (json) => ResponseWrapper<KnowledgePoint>.fromJson(
        json,
        fromJson: (json) => KnowledgePoint.fromJson(json),
      ),
    );
  }

  // 搜索指定内容
  static Future<ResponseEntity<ResponseWrapper<KnowledgePoint>>> serach({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/languages//content/review/search/content/list", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<ResponseWrapper<KnowledgePoint>>.fromJson(
      response,
      fromJson: (json) => ResponseWrapper<KnowledgePoint>.fromJson(
        json,
        fromJson: (json) => KnowledgePoint.fromJson(json),
      ),
    );
  }

  // 获取用户审核列表
  static Future<ResponseEntity<ListResponseEntity<KnowledgePoint>>> userReviewImages(
      {required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/languages/content/review/user/list", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<ListResponseEntity<KnowledgePoint>>.fromJson(
      response,
      fromJson: (json) => ListResponseEntity<KnowledgePoint>.fromJson(
        json,
        fromJson: (json) => KnowledgePoint.fromJson(json),
      ),
    );
  }

  // 详情
  static Future<ResponseEntity<KnowledgePointDetail>> detail({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/languages/content/review/load/task/detail", Method.post,
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

  // 审核
  static Future<ResponseEntity<String>> review({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/languages/content/review/submit/level", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<String>.fromJson(response);
  }

  // 图片等级选项
  static Future<ResponseEntity<ResponseWrapper<RatingOption>>> introduce({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/languages/content/review/load/level/introduce", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<ResponseWrapper<RatingOption>>.fromJson(
      response,
      fromJson: (json) => ResponseWrapper<RatingOption>.fromJson(
        json,
        fromJson: (json) => RatingOption.fromJson(json),
      ),
    );
  }

  // 图片风格
  static Future<ResponseEntity<ResponseWrapper<ImageFilterOption>>> styles({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/languages/language/image/style/config/list", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<ResponseWrapper<ImageFilterOption>>.fromJson(
      response,
      fromJson: (json) => ResponseWrapper<ImageFilterOption>.fromJson(
        json,
        fromJson: (json) => ImageFilterOption.fromJson(json),
      ),
    );
  }

  // 图片风格(v2)
  static Future<ResponseEntity<ImageStyleConfigV2ResponseData>> stylesV2({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/languages/language/image/style/config/list/v2", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<ImageStyleConfigV2ResponseData>.fromJson(
      response,
      fromJson: (json) => ImageStyleConfigV2ResponseData.fromJson(json),
    );
  }

  // 排行榜总榜
  static Future<ResponseEntity<ResponseWrapper<RankingResponseEntity>>> leaderboardsTotal(
      {required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/languages/content/review/load/user/leaderboards/total", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<ResponseWrapper<RankingResponseEntity>>.fromJson(
      response,
      fromJson: (json) => ResponseWrapper<RankingResponseEntity>.fromJson(
        json,
        fromJson: (json) => RankingResponseEntity.fromJson(json),
      ),
    );
  }

  // 排行日榜
  static Future<ResponseEntity<ResponseWrapper<RankingResponseEntity>>> leaderboardsDaily(
      {required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/languages/content/review/load/user/leaderboards/daily", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<ResponseWrapper<RankingResponseEntity>>.fromJson(
      response,
      fromJson: (json) => ResponseWrapper<RankingResponseEntity>.fromJson(
        json,
        fromJson: (json) => RankingResponseEntity.fromJson(json),
      ),
    );
  }

  // 用户审核详情
  static Future<ResponseEntity<ReviewerStatsEntity>> userReviewInfo({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/languages/content/review/user/review/info", Method.get,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<ReviewerStatsEntity>.fromJson(
      response,
      fromJson: (json) => ReviewerStatsEntity.fromJson(json),
    );
  }

  // 放弃审核
  static Future<ResponseEntity<String>> abandonReview({required RequestConfig config}) async {
    final rawHeader = config.headers ?? {};
    var response = await WiseHttp().request("/languages/content/review/abandon/current/knowledge", Method.post,
        data: config.data,
        parameters: config.parameters,
        options: config.options,
        cancelToken: config.cancelToken,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        headers: rawHeader);

    return ResponseEntity<String>.fromJson(response);
  }
}
