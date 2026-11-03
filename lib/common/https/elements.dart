import 'dart:io';

import 'package:api/api.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class ElementsRequest {
  /// 获取要素页面 tab
  static Future<ElementsTabEntity?> getTab() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/languages/content/card/type/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ElementsTabEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取卡片列表
  static Future<ElementsCardEntity?> getCardList(
      Map<String, dynamic>? parameters, Map<String, dynamic>? reqData) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/languages/content/card/page",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: reqData,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ElementsCardEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取词典筛选/排序元数据
  static Future<ZhenduScriptQueryMetaGroupListEntity?>
      getCardQueryMetaGroupList({
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        "/languages/content/card/query/meta/group/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return ZhenduScriptQueryMetaGroupListEntity.fromJson(
        responseEntity.data as Map<String, dynamic>,
      );
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取单词卡片详情
  static Future<CardWordDetilsEntity?> getWordDetils(
    int contentId, {
    List<int?>? semanticIds,
    String? module,
    String? style,
    int? mediaMode,
  }) async {
    try {
      Map<String, dynamic> parameters = {
        "contentId": contentId,
      };
      if ((style ?? '').isNotEmpty) {
        parameters["style"] = style;
      }
      if (mediaMode != null) {
        parameters["mediaMode"] = mediaMode;
      }
      if (semanticIds != null) {
        parameters["semanticIds"] = semanticIds.join(",");
      }
      if (module != null) {
        parameters["module"] = module;
      }
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/languages/content/card/en/word/detail",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return CardWordDetilsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取短语详情
  static Future<CardWordDetilsEntity?> getPhraseDetils(
    int contentId, {
    List<int?>? semanticIds,
    String? module,
    String? style,
    int? mediaMode,
  }) async {
    try {
      Map<String, dynamic> parameters = {
        "contentId": contentId,
      };
      if ((style ?? '').isNotEmpty) {
        parameters["style"] = style;
      }
      if (mediaMode != null) {
        parameters["mediaMode"] = mediaMode;
      }
      if (semanticIds != null) {
        parameters["semanticIds"] = semanticIds.join(",");
      }
      if (module != null) {
        parameters["module"] = module;
      }
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/languages/content/card/en/phrase/detail",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return CardWordDetilsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取单词卡片语义详情（新接口）
  static Future<CardWordSemanticDetilsEntity?> getWordSemanticDetils(
    int contentId, {
    int? semanticId,
    String? style,
    int? mediaMode,
  }) async {
    try {
      final Map<String, dynamic> parameters = <String, dynamic>{
        'contentId': contentId,
      };
      if ((style ?? '').isNotEmpty) {
        parameters['style'] = style;
      }
      if (mediaMode != null) {
        parameters['mediaMode'] = mediaMode;
      }
      if (semanticId != null) {
        parameters['semanticIds'] = semanticId.toString();
      }
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: false,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        '/languages/content/card/en/word/semantic/detail',
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      if (responseEntity.data == null) return null;
      return CardWordSemanticDetilsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取短语卡片语义详情（新接口）
  static Future<CardWordSemanticDetilsEntity?> getPhraseSemanticDetils(
    int contentId, {
    int? semanticId,
    String? style,
    int? mediaMode,
  }) async {
    try {
      final Map<String, dynamic> parameters = <String, dynamic>{
        'contentId': contentId,
      };
      if ((style ?? '').isNotEmpty) {
        parameters['style'] = style;
      }
      if (mediaMode != null) {
        parameters['mediaMode'] = mediaMode;
      }
      if (semanticId != null) {
        parameters['semanticIds'] = semanticId.toString();
      }
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: false,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        '/languages/content/card/en/phrase/semantic/detail',
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      if (responseEntity.data == null) return null;
      return CardWordSemanticDetilsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取模块详情（按需加载）
  static Future<CardContentModuleDetilsEntity?> getContentModuleDetils({
    required String module,
    required String contentType,
    required int contentId,
    required int semanticId,
    String? style,
    int? mediaMode,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: false,
        parameters: <String, dynamic>{
          'module': module,
          'contentType': contentType,
          'contentId': contentId,
          'semanticId': semanticId,
          if ((style ?? '').isNotEmpty) 'style': style,
          if (mediaMode != null) 'mediaMode': mediaMode,
        },
      );
      final dynamic response = await WiseHttp().request(
        '/languages/content/card/en/content/module/detail',
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      if (responseEntity.data == null) return null;
      return CardContentModuleDetilsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取句子详情
  static Future<CardSentencesDetilsEntity?> getSentencesDetils(
    int contentId, {
    List<int?>? semanticIds,
    String? module,
    String? style,
    int? mediaMode,
  }) async {
    try {
      Map<String, dynamic> parameters = {
        "contentId": contentId,
      };
      if ((style ?? '').isNotEmpty) {
        parameters["style"] = style;
      }
      if (mediaMode != null) {
        parameters["mediaMode"] = mediaMode;
      }
      if (semanticIds != null) {
        parameters["semanticIds"] = semanticIds.join(",");
      }
      if (module != null) {
        parameters["module"] = module;
      }
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/languages/content/card/en/sentence/detail",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return CardSentencesDetilsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取词素详情
  static Future<CardMorphemeDetilsEntity?> getMorphemeDetils(
      Map<String, dynamic> parameters) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/languages/content/card/en/morpheme/detail",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return CardMorphemeDetilsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取词素单词列表
  static Future<CardMorphemeWordEntity?> getMorphemeWordList(
      Map<String, dynamic> parameters) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/languages/content/card/en/morpheme/content/page",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return CardMorphemeWordEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取词典模式信息
  static Future<CardDictModeEntity?> getDictMode() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/languages/content/card/already/study/mode",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return CardDictModeEntity.fromJson(responseEntity.data);
    } on FormatException catch (_) {
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取升级的卡片列表
  static Future<List<ElementsCardEntityDatas>?> getUpdateCardList() async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.contentCardMemberUpdateShowList)) return null;
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/languages/content/card/member/update/show/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      List? list = responseEntity.data['list'];
      if (list == null) return null;
      List<ElementsCardEntityDatas> respList = [];
      for (int i = 0; i < list.length; i++) {
        respList.add(ElementsCardEntityDatas.fromJson(list[i]));
      }
      return respList;
    } on FormatException catch (_) {
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 升级收集卡片的已读
  static Future<bool> cuCardAlready(List<Map<String, dynamic>> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/studies/member/content/study/already/show/list",
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
    } on FormatException catch (_) {
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 删除卡片
  static Future<bool> deleteCard(Map<String, dynamic> reqData) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/languages/content/card/member/content/remove",
        Method.delete,
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

  /// 获取评测题目数据
  static Future<List<QuizModel>?> getReviewExercise(
      String? contentType, int? contentId, String? national) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: {
          "contentType": contentType,
          "contentId": contentId,
          "national": national,
        },
      );
      dynamic response = await WiseHttp().request(
        "/languages/content/card/en/content/voice/evaluation/exercises",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      List? list = responseEntity.data['list'];
      if (list == null) return null;
      List<QuizModel> respList = [];
      for (int i = 0; i < list.length; i++) {
        respList.add(QuizModel.fromJson(list[i]));
      }
      return respList;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }
}
