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

  /// 获取词典卡片列表 v2
  static Future<Map<String, dynamic>?> getCardListV2(
      Map<String, dynamic>? parameters, Map<String, dynamic>? reqData) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/languages/content/card/v2/page",
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
      return Map<String, dynamic>.from(responseEntity.data);
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
        '/languages/content/card/en/word/semantic/detail/v3',
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

  /// 获取词源记忆详情
  /// semanticId 可选，为空时不传该参数，由服务端返回默认义项
  static Future<CardContentEtymologyDetailEntity?> getContentEtymologyDetail({
    required String contentType,
    required int contentId,
    int? semanticId,
    String? style,
    int? mediaMode,
  }) async {
    try {
      final Map<String, dynamic> parameters = <String, dynamic>{
        'contentType': contentType,
        'contentId': contentId,
      };
      if (semanticId != null) parameters['semanticId'] = semanticId;
      if ((style ?? '').isNotEmpty) parameters['style'] = style;
      if (mediaMode != null) parameters['mediaMode'] = mediaMode;
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: false,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        '/languages/content/card/en/content/etymology/detail',
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
      return CardContentEtymologyDetailEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取同义反义详情
  static Future<LexicalDetailEntity?> getLexicalDetail({
    required String contentType,
    required int contentId,
    int? semanticId,
  }) async {
    try {
      final Map<String, dynamic> parameters = <String, dynamic>{
        'contentType': contentType,
        'contentId': contentId,
      };
      if (semanticId != null) parameters['semanticId'] = semanticId;
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: false,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        '/languages/write/zhenxie/lexical/detail',
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
      return LexicalDetailEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取单词构词树
  static Future<WordMorphologyTreeEntity?> getWordMorphologyTree({
    required int key,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: <String, dynamic>{
          'key': key,
        },
      );
      final dynamic response = await WiseHttp().request(
        '/languages/content/card/en/word/morphology/tree',
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return WordMorphologyTreeEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取词根成员词卡页
  static Future<WordMorphologyWordsPageEntity?> getWordMorphologyRootMemberPage({
    required String key,
    Map<String, dynamic>? parameters,
    String? style,
    int? mediaMode,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: <String, dynamic>{
          'key': key,
          ...?parameters,
          if ((style ?? '').isNotEmpty) 'style': style,
          if (mediaMode != null) 'mediaMode': mediaMode,
        },
      );
      final dynamic response = await WiseHttp().request(
        '/languages/content/card/en/word/morphology/root/member/page',
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
      return WordMorphologyWordsPageEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取词素成员词卡页
  static Future<WordMorphologyWordsPageEntity?> getWordMorphologyMorphemeMemberPage({
    required String morphemeNid,
    Map<String, dynamic>? parameters,
    String? style,
    int? mediaMode,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: <String, dynamic>{
          'morphemeNid': morphemeNid,
          ...?parameters,
          if ((style ?? '').isNotEmpty) 'style': style,
          if (mediaMode != null) 'mediaMode': mediaMode,
        },
      );
      final dynamic response = await WiseHttp().request(
        '/languages/content/card/en/word/morphology/morpheme/member/page',
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
      return WordMorphologyWordsPageEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取词根词缀列表
  static Future<WordMorphologyPageEntity?> queryMorphemeList({
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? data,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      final dynamic response = await WiseHttp().request(
        '/languages/content/card/en/morpheme/v2/pages',
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      if (responseEntity.data == null) return null;
      return WordMorphologyPageEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取词根词缀筛选元数据
  static Future<FiltersGroupEntity?> getMorphemeFilters() async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      final dynamic response = await WiseHttp().request(
        '/languages/content/card/en/morpheme/query/meta/group/list',
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) return null;
      if (responseEntity.data == null) return null;
      return FiltersGroupEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取单词曲折变化详情
  static Future<WordInflectionDetailEntity?> getWordInflectionDetail({
    required String familyKey,
    required int semanticId,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: <String, dynamic>{
          'familyKey': familyKey,
          'semanticId': semanticId,
        },
      );
      final dynamic response = await WiseHttp().request(
        '/languages/content/card/en/word/inflection/detail',
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
      return WordInflectionDetailEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 获取短语卡片语义详情（新接口）
  static Future<CardPhraseSemanticDetilsEntity?> getPhraseSemanticDetils(
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
        '/languages/content/card/en/phrase/semantic/detail/v3',
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
      return CardPhraseSemanticDetilsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取短语关联详情
  static Future<CardPhraseRelationDetailEntity?> getPhraseRelationDetils(
    int contentId,
  ) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: false,
        parameters: <String, dynamic>{
          'contentId': contentId,
        },
      );
      final dynamic response = await WiseHttp().request(
        '/languages/content/card/en/phrase/relation/detail',
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
      return CardPhraseRelationDetailEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取用户端短语对照详情
  static Future<PhraseParadigmEntity?> getPhraseParadigmDetils(
    String nid,
  ) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: false,
        parameters: <String, dynamic>{
          'nid': nid,
        },
      );
      final dynamic response = await WiseHttp().request(
        '/languages/content/write/en/phrase/paradigm/detail',
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
      return PhraseParadigmEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取用户端短语配对详情
  static Future<PhrasePairEntity?> getPhrasePairDetils(
    String nid,
  ) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: false,
        parameters: <String, dynamic>{
          'nid': nid,
        },
      );
      final dynamic response = await WiseHttp().request(
        '/languages/content/write/en/phrase/pair/detail',
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
      return PhrasePairEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取用户端短语搭配组详情
  static Future<PhraseMatchEntity?> getPhraseMatchDetils(
    String nid,
  ) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: false,
        parameters: <String, dynamic>{
          'nid': nid,
        },
      );
      final dynamic response = await WiseHttp().request(
        '/languages/content/write/en/phrase/cluster/detail',
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
      return PhraseMatchEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<CardWordAnalysisCardsPageEntity?> getWordSentenceCardsPage(
    int contentId, {
    required int semanticId,
    required int offset,
    required int limit,
    String? style,
    int? mediaMode,
  }) async {
    return _getWordAnalysisCardsPage(
      '/languages/content/card/en/word/sentence/page',
      contentId: contentId,
      semanticId: semanticId,
      offset: offset,
      limit: limit,
      style: style,
      mediaMode: mediaMode,
    );
  }

  static Future<CardWordAnalysisCardsPageEntity?> getWordPhraseCardsPage(
    int contentId, {
    required int semanticId,
    required int offset,
    required int limit,
    String? style,
    int? mediaMode,
  }) async {
    return _getWordAnalysisCardsPage(
      '/languages/content/card/en/word/phrase/page',
      contentId: contentId,
      semanticId: semanticId,
      offset: offset,
      limit: limit,
      style: style,
      mediaMode: mediaMode,
    );
  }

  static Future<CardPhraseSentenceCardsPageEntity?> getPhraseSentenceCardsPage(
    int contentId, {
    required int semanticId,
    required int offset,
    required int limit,
    String? style,
    int? mediaMode,
  }) async {
    try {
      final Map<String, dynamic> parameters = <String, dynamic>{
        'contentId': contentId,
        'semanticId': semanticId,
        'offset': offset,
        'limit': limit,
      };
      if ((style ?? '').isNotEmpty) {
        parameters['style'] = style;
      }
      if (mediaMode != null) {
        parameters['mediaMode'] = mediaMode;
      }
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: false,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        '/languages/content/card/en/phrase/sentence/page',
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
      return CardPhraseSentenceCardsPageEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<CardWordAnalysisCardsPageEntity?> getWordSynonymCardsPage({
    required int semanticId,
    required String contentType,
    required int offset,
    required int limit,
    String? style,
    int? mediaMode,
  }) async {
    return _getWordAnalysisCardsPage(
      '/languages/content/card/en/content/synonym/list',
      semanticId: semanticId,
      contentType: contentType,
      offset: offset,
      limit: limit,
      style: style,
      mediaMode: mediaMode,
    );
  }

  static Future<CardWordAnalysisCardsPageEntity?> _getWordAnalysisCardsPage(
    String path, {
    int? contentId,
    required int semanticId,
    String? contentType,
    required int offset,
    required int limit,
    String? style,
    int? mediaMode,
  }) async {
    try {
      final Map<String, dynamic> parameters = <String, dynamic>{
        'semanticId': semanticId,
        'offset': offset,
        'limit': limit,
      };
      if (contentId != null) {
        parameters['contentId'] = contentId;
      }
      if ((contentType ?? '').isNotEmpty) {
        parameters['contentType'] = contentType;
      }
      if ((style ?? '').isNotEmpty) {
        parameters['style'] = style;
      }
      if (mediaMode != null) {
        parameters['mediaMode'] = mediaMode;
      }
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: false,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        path,
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
      return CardWordAnalysisCardsPageEntity.fromJson(responseEntity.data);
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

  /// 获取句子详情 V2
  static Future<EnSentenceDetailV2Entity?> getSentencesDetilsV2(
    int contentId, {
    String? module,
    String? layer,
    String? style,
    int? mediaMode,
  }) async {
    try {
      final Map<String, dynamic> parameters = {
        "contentId": contentId,
      };
      if ((style ?? '').isNotEmpty) {
        parameters["style"] = style;
      }
      if (mediaMode != null) {
        parameters["mediaMode"] = mediaMode;
      }
      if ((module ?? '').isNotEmpty) {
        parameters["module"] = module;
      }
      if ((layer ?? '').isNotEmpty) {
        parameters["layer"] = layer;
      }
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      final dynamic response = await WiseHttp().request(
        "/languages/content/card/en/sentence/detail/v2",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return EnSentenceDetailV2Entity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取句子结构分析详情
  static Future<EnSentenceStructureDetailEntity?> getSentenceStructureDetils(
    int contentId,
  ) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: false,
        parameters: {
          "contentId": contentId,
        },
      );
      final dynamic response = await WiseHttp().request(
        "/languages/content/card/en/sentence/structure/detail",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return EnSentenceStructureDetailEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取短语结构详情
  static Future<PhraseStructureEntity?> getPhraseStructureDetils(
    int contentId, {
    String? style,
    int? mediaMode,
  }) async {
    try {
      final RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: {
          "contentId": contentId,
          if ((style ?? '').isNotEmpty) "style": style,
          if (mediaMode != null) "mediaMode": mediaMode,
        },
      );
      final dynamic response = await WiseHttp().request(
        "/languages/content/card/en/phrase/structure/detail",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      final ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return PhraseStructureEntity.fromJson(responseEntity.data);
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

  /// 获取升级的卡片列表 v2
  static Future<List<KnowledgeCommonEntityList>?> getUpdateCardList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    if (!HttpAuthUtils.instance.isAuth(HttpAuthCodes.contentCardMemberUpdateShowList)) return null;
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/languages/content/card/member/update/show/list/v2",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      List? list = responseEntity.data['list'];
      if (list == null) return null;
      List<KnowledgeCommonEntityList> respList = [];
      for (int i = 0; i < list.length; i++) {
        respList.add(KnowledgeCommonEntityList.fromJson(Map<String, dynamic>.from(list[i])));
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
      String? contentType, int? contentId, int? semanticId, String? national, {
        String? exerciseType,
      }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: {
          "contentType": contentType,
          "contentId": contentId,
          "semanticId": semanticId,
          "national": national,
          "exerciseType": exerciseType,
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
