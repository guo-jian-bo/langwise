import 'dart:io';
import 'package:api/api.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:wise_http/wise_http.dart';

class ContentReviewImageUtil {
  //获取知识点图片
  static Future<ResponseEntity<ContentReviewKnowledgeImagesResponseData>?> fetchKnowledgeImages(String type, int? semanticId, int uid, int styleId) async {
    try {
      var data;
      if (type == "EN_WORD" || type == "EN_PHRASE") {
        data = {"type": type, "semanticId": semanticId, "uid": uid};
      } else {
        data = {"type": type, "uid": uid};
      }

      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: {
          "style": styleId,
        },
      );

      var response = await WiseHttp().request(
        "/language-console/admin/content/review/knowledge/images",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ResponseEntity<ContentReviewKnowledgeImagesResponseData>.fromJson(
        response,
        fromJson: (json) => ContentReviewKnowledgeImagesResponseData.fromJson(json),
      );
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  //转化图片
  static Future<ResponseEntity<ContentReviewImageConvertResponseData>?> convert(int promptId, List<int> styleId, int numberOfImages) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {"promptId": promptId, "styleIds": styleId, "numberOfImages": numberOfImages},
        parameters: {},
      );

      var response = await WiseHttp().request(
        "/language-console/admin/content/review/image/convert",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
        parameters: config.parameters,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;

      return ResponseEntity<ContentReviewImageConvertResponseData>.fromJson(
        response,
        fromJson: (json) => ContentReviewImageConvertResponseData.fromJson(json),
      );
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  //新建图片
  static Future<ResponseEntity<String>?> createImage({
    List<int>? styleIds, 
    int? numberOfImages, 
    String? type, 
    int? semanticId, 
    int? uid,
    int? taskId,
  }) async {
    try {

      Map<String, dynamic> data = {};
      if (styleIds != null) {
        data["styleIds"] = styleIds;
      }
      if (numberOfImages != null) {
        data["numberOfImages"] = numberOfImages;
      }
      if (type != null) {
        data["subContent"] = {"type": type, "semanticId": semanticId, "uid": uid};
      }
      if (taskId != null) {
        data["taskId"] = taskId;
      }



      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: {},
      );

      var response = await WiseHttp().request(
        "/language-console/admin/content/review/image/create",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
        parameters: config.parameters,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ResponseEntity<String>.fromJson(response);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  //新建图片
  static Future<ResponseEntity<String>?> createImageByPrompt(List<int> styleIds, int numberOfImages, String type, int? semanticId, int uid, String prompt) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {
          "styleIds": styleIds,
          "numberOfImages": numberOfImages,
          "subContent": {"type": type, "semanticId": semanticId, "uid": uid},
          "prompt": prompt
        },
        parameters: {},
      );

      var response = await WiseHttp().request(
        "/language-console/admin/content/review/image/create/by/prompt",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
        parameters: config.parameters,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ResponseEntity<String>.fromJson(response);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  //下架图片
  static Future<ResponseEntity<String>?> takedown(int relationUid) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: {'relationUid': relationUid},
      );

      var response = await WiseHttp().request(
        "/language-console/admin/content/review/image/takedown",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
        parameters: config.parameters,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ResponseEntity<String>.fromJson(response);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  ///待审核列表
  static Future<ResponseEntity<ContentReviewImagesReviewedListResponseData>?> reviewedList({String? content, List<int>? taskIds, Map<String, dynamic>? subContent}) async {
    try {
      Map<String, dynamic> reqData = {};
      if(content != null && content.isNotEmpty) {
        reqData["content"] = content;
      }
      if(taskIds != null && taskIds.isNotEmpty) {
        reqData["taskIds"] = taskIds;
      }
      if(subContent != null && subContent.isNotEmpty) {
        reqData["subContent"] = subContent;
      }

      RequestConfig config = RequestConfig(
        requireToken: true,
        data: reqData,
        parameters: {},
      );

      var response = await WiseHttp().request(
        "/languages/user/content/review/images/reviewed/list",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
        parameters: config.parameters,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;

      return ResponseEntity<ContentReviewImagesReviewedListResponseData>.fromJson(
        response,
        fromJson: (json) => ContentReviewImagesReviewedListResponseData.fromJson(json),
      );
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  //重新生成prompt
  static Future<ResponseEntity<ContentReviewLoadPromptResponseData>?> loadPromptV3({
    required int relationUid,
    required int promptId,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {
          "promptId": promptId,
        },
        parameters: {
          'relationUid': relationUid,
        },
      );

      var response = await WiseHttp().request(
        "/language-console/admin/content/review/load/prompt/v3",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
        parameters: config.parameters,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;

      return ResponseEntity<ContentReviewLoadPromptResponseData>.fromJson(
        response,
        fromJson: (json) => ContentReviewLoadPromptResponseData.fromJson(json),
      );
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  //重新生成图片
  static Future<ResponseEntity<dynamic>?> regenerateV2({required int taskId, required String prompt}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {"taskId": taskId, "prompt": prompt},
      );

      var response = await WiseHttp().request(
        "/language-console/admin/content/review/image/regenerate/v2",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
        parameters: config.parameters,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ResponseEntity<dynamic>.fromJson(response);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  //审核历史
  static Future<ResponseEntity<ContentReviewImageAuditHistoryResponseData>?> auditHistory({
    String content = "",
    String startDate = '',
    String endDate = '',
    int? userId,
    int offset = 0,
    int limit = 30,
  }) async {
    try {
      RequestConfig config = RequestConfig(requireToken: true, data: {
        "content": content.isEmpty ? null : content,
        "startDate": startDate.isEmpty ? null : startDate,
        "endDate": endDate.isEmpty ? null : endDate,
        "userId": userId,
      }, parameters: {
        'offset': offset,
        'limit': limit
      });

      var response = await WiseHttp().request(
        "/languages/user/content/review/image/audit/history",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
        parameters: config.parameters,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;

      return ResponseEntity<ContentReviewImageAuditHistoryResponseData>.fromJson(
        response,
        fromJson: (json) => ContentReviewImageAuditHistoryResponseData.fromJson(json),
      );
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 管理端审核历史
  static Future<ResponseEntity<ContentReviewImageAuditHistoryResponseData>?> adminAuditHistory({
    String content = "",
    String startDate = '',
    String endDate = '',
    int? userId,
    int offset = 0,
    int limit = 30,
  }) async {
    try {
      RequestConfig config = RequestConfig(requireToken: true, data: {
        "content": content.isEmpty ? null : content,
        "startDate": startDate.isEmpty ? null : startDate,
        "endDate": endDate.isEmpty ? null : endDate,
        "userId": userId,
      }, parameters: {
        'offset': offset,
        'limit': limit
      });

      var response = await WiseHttp().request(
        "/language-console/admin/content/review/image/audit/history",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
        parameters: config.parameters,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;

      return ResponseEntity<ContentReviewImageAuditHistoryResponseData>.fromJson(
        response,
        fromJson: (json) => ContentReviewImageAuditHistoryResponseData.fromJson(json),
      );
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<ResponseEntity<List<ContentReviewReviewerEntity>>?> reviewerList() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: {},
      );

      var response = await WiseHttp().request(
        "/languages/user/content/review/inspector/reviewer/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
        parameters: config.parameters,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;

      return ResponseEntity<List<ContentReviewReviewerEntity>>.fromJson(
        response,
        fromJson: (json) {
          final list = <ContentReviewReviewerEntity>[];
          if (json is List) {
            for (final e in json) {
              if (e is Map<String, dynamic>) {
                list.add(ContentReviewReviewerEntity.fromJson(e));
              }
            }
          }
          return list;
        },
      );
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  //再来一批
  static Future<ResponseEntity<ContentReviewImagesReviewedListResponseData>?> distributeTask() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );

      var response = await WiseHttp().request(
        "/languages/user/content/review/image/task/distribute",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
        parameters: config.parameters,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;

      return ResponseEntity<ContentReviewImagesReviewedListResponseData>.fromJson(
        response,
        fromJson: (json) => ContentReviewImagesReviewedListResponseData.fromJson(json),
      );
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  //图片审核统计
  static Future<ResponseEntity<ContentReviewImageAuditStatisticsResponseData>?> auditStatistics({
    String startDate = '',
    String endDate = '',
    int? userId,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {
          'startDate': startDate.isEmpty ? null : startDate,
          'endDate': endDate.isEmpty ? null : endDate,
          'userId': userId,
        },
        parameters: parameters,
      );

      var response = await WiseHttp().request(
        "/language-console/admin/content/review/image/audit/statistics",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
        parameters: config.parameters,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;

      return ResponseEntity<ContentReviewImageAuditStatisticsResponseData>.fromJson(
        response,
        fromJson: (json) => ContentReviewImageAuditStatisticsResponseData.fromJson(json),
      );
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  //已审核通过的图片列表
  static Future<ResponseEntity<List<ContentReviewApprovedImage>>?> approvedList(int taskId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {'taskId': taskId},
      );

      var response = await WiseHttp().request(
        "/languages/user/content/review/image/review/approved/list",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
        parameters: config.parameters,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;

      return ResponseEntity<List<ContentReviewApprovedImage>>.fromJson(
        response,
        fromJson: (json) => (json as List).map((e) => ContentReviewApprovedImage.fromJson(e)).toList(),
      );
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  //审核通过
  static Future<ResponseEntity<String>?> approve({
    int? relationUid,
    required int taskId,
    required int imageId,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {"taskId": taskId, "imageId": imageId},
        parameters: {'relationUid': relationUid},
      );

      var response = await WiseHttp().request(
        "/languages/user/content/review/image/review/approve",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
        parameters: config.parameters,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ResponseEntity<String>.fromJson(response);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<ResponseEntity<String>?> abandon({
    required int taskId,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {
          'taskId': taskId,
        },
      );

      var response = await WiseHttp().request(
        "/languages/user/content/review/image/review/abandon",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
        parameters: config.parameters,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return ResponseEntity<String>.fromJson(response);
      }
      if (responseEntity.data == null) return null;
      return ResponseEntity<String>.fromJson(response);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<ResponseEntity<String>?> delete({
    required int taskId,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: {
          'taskId': taskId,
        },
      );

      var response = await WiseHttp().request(
        "/language-console/admin/content/review/image/task/fail",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        data: config.data,
        parameters: config.parameters,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return ResponseEntity<String>.fromJson(response);
      }
      if (responseEntity.data == null) return null;
      return ResponseEntity<String>.fromJson(response);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }
}
