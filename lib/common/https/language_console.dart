import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class LanguageConsoleRequest {

  /// 获取单词知识点列表
  static Future<ListResponseEntity<EnKnowledgeEntity>?> getEnWordKnowledgeList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/word/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<EnKnowledgeEntity>.fromJson(responseEntity.data, fromJson: EnKnowledgeEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

    /// 获取短语知识点列表
  static Future<ListResponseEntity<EnKnowledgeEntity>?> getEnPhraseKnowledgeList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/phrase/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message ?? "", type: ToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<EnKnowledgeEntity>.fromJson(responseEntity.data, fromJson: EnKnowledgeEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message, type: ToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取句子知识点列表
  static Future<ListResponseEntity<EnKnowledgeEntity>?> getEnSentenceKnowledgeList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message ?? "", type: ToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<EnKnowledgeEntity>.fromJson(responseEntity.data, fromJson: EnKnowledgeEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message, type: ToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取文章知识点列表
  static Future<ListResponseEntity<EnKnowledgeEntity>?> getEnArticleKnowledgeList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/text/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message ?? "", type: ToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<EnKnowledgeEntity>.fromJson(responseEntity.data, fromJson: EnKnowledgeEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message, type: ToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取歌曲知识点列表
  static Future<ListResponseEntity<EnKnowledgeEntity>?> getEnSongKnowledgeList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/song/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message ?? "", type: ToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<EnKnowledgeEntity>.fromJson(responseEntity.data, fromJson: EnKnowledgeEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message, type: ToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// 获取生成文章的主题题材列表
  static Future<TextSubjectThemeEntity?> getThemeList() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/theme/list",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return TextSubjectThemeEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取音色列表
  static Future<List<ManageEnglishContentManagementAccentModel>?> getAccentList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/accent/list",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message ?? "",);
        return null;
      }
      if (responseEntity.data == null) return null;
      List<dynamic> list = responseEntity.data;
      List<ManageEnglishContentManagementAccentModel> responseList = list.map((e) => ManageEnglishContentManagementAccentModel.fromJson(e)).toList();
      return responseList;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除单词
  static Future<bool> deleteWord(int knowledgeId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/word/$knowledgeId/delete",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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

  /// 删除短语
  static Future<bool> deletePhrase(int knowledgeId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/phrase/$knowledgeId/delete",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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

  /// 删除句子
  static Future<bool> deleteSentence(int knowledgeId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/$knowledgeId/delete",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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

  /// 删除文章
  static Future<bool> deleteArticle(int knowledgeId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/text/$knowledgeId/delete",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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
      ToastUtils.showToast(text: e.source.message, type: ToastType.error);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 编辑文章
  static Future<EnKnowledgeEntity?> editArticle(int knowledgeId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/text/$knowledgeId/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return EnKnowledgeEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message, type: ToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除歌曲
  static Future<bool> deleteSong(int knowledgeId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/song/$knowledgeId/delete",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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
      ToastUtils.showToast(text: e.source.message, type: ToastType.error);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 编辑歌曲
  static Future<EnKnowledgeEntity?> editSong(int knowledgeId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/song/$knowledgeId/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return EnKnowledgeEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message, type: ToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除单词语义
  static Future<bool> deleteWordSemantic(int semanticId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/word/semantic/$semanticId/delete",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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

    /// 删除短语语义
  static Future<bool> deletePhraseSemantic(int semanticId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/phrase/semantic/$semanticId/delete",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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

  /// 知识点上传音频
  static Future<bool> uploadKnowledgeAudio({Map<String, dynamic>? data}) async{
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/audio/review/audio/upload",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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

  /// 图片定稿
  static Future<bool> finalDraftImage({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/content/review/image/lock",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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


  /// 图片取消定稿
  static Future<bool> unlockDraftImage({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/content/review/image/unlock",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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
      ToastUtils.showToast(text: e.source.message, milliseconds: 3000);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 知识点上传图片
  static Future<bool> knowledgeUploadImage({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/content/review/image/upload",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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

  /// 视频定稿
  static Future<bool> finalDraftVideo({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/video/review/video/lock",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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

  /// 视频取消定稿
  static Future<bool> unlockDraftVideo({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/video/review/video/unlock",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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
      ToastUtils.showToast(text: e.source.message, milliseconds: 3000);
      return false;
    } catch (e) {
      return false;
    }
  }
  

  /// 下架视频
  static Future<bool> downVideo({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/video/review/video/takedown",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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
      ToastUtils.showToast(text: e.source.message, milliseconds: 3000);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 获取词性列表
  static Future<List<PosResponseEntity>?> getPosList() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/language/pos/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message ?? "",);
        return null;
      }
      if (responseEntity.data == null) return null;
      List<dynamic> list = responseEntity.data;
      List<PosResponseEntity> responseList = list.map((e) => PosResponseEntity.fromJson(e)).toList();
      return responseList;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取语法形式列表
  static Future<List<FormResponseEntity>?> getFormList() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/language/form/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message ?? "",);
        return null;
      }
      if (responseEntity.data == null) return null;
      List<dynamic> list = responseEntity.data;
      List<FormResponseEntity> responseList = list.map((e) => FormResponseEntity.fromJson(e)).toList();
      return responseList;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 创建或匹配单词
  static Future<String?> wordMath({Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/word/match/detail",
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
      return responseEntity.data?.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message, milliseconds: 3000);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 编辑单词
  static Future<EnKnowledgeEntity?> editWord(int uid, {Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/word/$uid/edit",
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
      return EnKnowledgeEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message, milliseconds: 3000);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 编辑短语
  static Future<EnKnowledgeEntity?> editPhrase(int uid, {Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/phrase/$uid/edit",
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
      return EnKnowledgeEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message, milliseconds: 3000);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 创建或匹配短语 /language-console/en/phrase/match/detail
  static Future<String?> phraseMath({Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/phrase/match/detail",
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
      return responseEntity.data?.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message, milliseconds: 3000);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 创建或匹配句子
  static Future<String?> sentenceMath({Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/match/detail",
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
      return responseEntity.data?.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message, milliseconds: 3000);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取语义列表
  static Future<ListResponseEntity<EnKnowledgeEntitySemantics>?> getSemanticList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/semantic/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<EnKnowledgeEntitySemantics>.fromJson(responseEntity.data, fromJson: EnKnowledgeEntitySemantics.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message, milliseconds: 3000);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 单词关联语义
  static Future<bool> wordSemanticBind(int contentId, {Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/word/$contentId/semantic/add",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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
      ToastUtils.showToast(text: e.source.message, milliseconds: 3000);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 短语关联语义
  static Future<bool> phraseSemanticBind(int contentId, {Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/phrase/$contentId/semantic/add",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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
      ToastUtils.showToast(text: e.source.message, milliseconds: 3000);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 生成单词、短语、句子、文章的AI音频
  static Future<ResponseEntity?> generateAiAudio({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/audio/generate",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 获取知识点视频列表
  static Future<EnKnowledgeVideoEntity?> getKnowledgeVideo({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/video/review/knowledge/videos",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return EnKnowledgeVideoEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  

  /// 视频审核-升级为首尾帧模式
  static Future<String?> upgradeToFirstLastFrameMode({Map<String, dynamic>? data}) async {
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/video/review/task/upgrade/start_end_frames",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 修改图片提示词
  static Future<bool> editImagePrompt({Map<String, dynamic>? data}) async {
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/content/review/prompt/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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

  /// 重新生成提示词和图片
  static Future<String?> reGenerateImagePrompt({Map<String, dynamic>? data}) async {
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/video/review/task/retry/image/prompt",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 用提示词重新生成图片
  static Future<String?> reGenerateImage({Map<String, dynamic>? data}) async {
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/video/review/task/retry/image/generate",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  ///审核视频 删除任务
  static Future<bool> deleteVideoTask({Map<String, dynamic>? data}) async {
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/video/review/video/task/fail",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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


  /// 修改视频提示词
  static Future<bool> updateVideoPrompt({Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/video/review/prompt/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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


  /// 重新生成提示词和视频
  static Future<bool> regeneratePromptAndVideos({Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/video/review/task/retry/video/prompt",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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

  /// 用提示词重新生成视频
  static Future<bool> usePromptRegenerateTheVideo({Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/video/review/task/retry/video/generate",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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
  
  /// 修改视频信息
  static Future<bool> updateVideoInfo({Map<String, dynamic>? data}) async{
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/video/review/video/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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

  /// 音频增强
  static Future<bool> audioEnhancement({Map<String, dynamic>? data}) async{
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/video/review/video/audio/enhance",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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


  /// 视频 - 首帧生成
  static Future<String?> videoGenerateFrameStart({Map<String, dynamic>? data}) async{

    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/video/review/generate/frame_start",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity.data?.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }

  }

  /// 视频 - 首尾帧生成
  static Future<String?> videoGenerateFrameStartEnd({Map<String, dynamic>? data}) async{

    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/video/review/generate/start_end_frames",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity.data?.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }

  }

  /// 根据已有提示词生成视频
  static Future<String?> createVideoByPrompt({Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/video/review/generate/by/prompt",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity.data?.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 查询视频审核历史
  static Future<ListResponseEntity<VideoTaskEntityList>?> getVideoReviewHistoryList(Map<String, dynamic> params, Map<String, dynamic> data) async{
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
        parameters: params,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/video/review/video/audit/history",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity.fromJson(responseEntity.data, fromJson: VideoTaskEntityList.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取视频统计数据
  static Future<VideoReviewStatisticsEntity?>  getVideoReviewStatistics(Map<String, dynamic> data) async{

    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/video/review/audit/statistics",
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
      return VideoReviewStatisticsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 查询字幕任务详情
  static Future<AssTaskEntityList?> getAssDatils({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/ass/review/ass/detail",
        Method.post,
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
      return AssTaskEntityList.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 审核字幕 删除任务
  static Future<bool> assReviewDeleteTask({Map<String, dynamic>? data}) async{
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/ass/review/ass/task/delete",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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

  /// 创建音频字幕对齐任务
  static Future<String?> assReviewCreateAudioAlign({Map<String, dynamic>? data}) async{
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/ass/review/task/align/audio/create",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 创建视频字幕对齐任务
  static Future<String?> assReviewCreateVideoAlign({Map<String, dynamic>? data}) async{
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/ass/review/task/align/video/create",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 创建字幕翻译任务
  static Future<String?> assReviewCreateTranslate({Map<String, dynamic>? data}) async{
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/ass/review/task/translate/create",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 查询字幕审核历史
  static Future<ListResponseEntity<AssTaskEntityList>?> getAssReviewHistoryList(Map<String, dynamic> params, Map<String, dynamic> data) async{
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
        parameters: params,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/ass/review/ass/audit/history",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity.fromJson(responseEntity.data, fromJson: AssTaskEntityList.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 获取字幕统计数据
  static Future<AssReviewStatisticsEntity?> getAssReviewStatistics(Map<String, dynamic> data) async{

    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/ass/review/ass/audit/statistics",
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
      return AssReviewStatisticsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 审核音频 删除任务
  static Future<bool> aduioReviewDeleteTask({Map<String, dynamic>? data}) async{
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/audio/review/task/delete",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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
  

  /// 查询音频审核历史
  static Future<ListResponseEntity<AudioReviewEntityList>?> getAudioReviewHistoryList(Map<String, dynamic> params, Map<String, dynamic> data) async{
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
        parameters: params,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/audio/review/audit/history",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity.fromJson(responseEntity.data, fromJson: AudioReviewEntityList.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 用提示词重新生成音频
  static Future<String?> audioPromptGenerate({Map<String, dynamic>? data}) async{
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/audio/review/task/retry/prompt/generate",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 用提示词重新生成音频
  static Future<String?> audioPromptRegenerate({Map<String, dynamic>? data}) async{
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/audio/review/task/retry/prompt/regenerate",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }


  /// 获取音频统计数据
  static Future<AudioReviewStatisticsEntity?> getAudioReviewStatistics(Map<String, dynamic> data) async{

    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/audio/review/audit/statistics",
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
      return AudioReviewStatisticsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// ass定稿
  static Future<bool> finalDraftAss({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/ass/review/ass/lock",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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

  /// ass取消定稿
  static Future<bool> unlockDraftAss({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/ass/review/ass/unlock",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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
      ToastUtils.showToast(text: e.source.message, milliseconds: 3000);
      return false;
    } catch (e) {
      return false;
    }
  }


  /// 音频定稿
  static Future<bool> finalDraftAudio({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/audio/review/audio/lock",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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

  /// 音频取消定稿
  static Future<bool> unlockDraftAudio({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/audio/review/audio/unlock",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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
      ToastUtils.showToast(text: e.source.message, milliseconds: 3000);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 创建 短语/句子/文字 音频
  static Future<String?> audioReviewTaskVoiceSegmentCreate({Map<String, dynamic>? data}) async{
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/audio/review/task/voice/segment/create",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 创建 歌曲/甄听 音频
  static Future<String?> audioReviewTaskMusicMinimaxCreate({Map<String, dynamic>? data}) async{
    
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/audio/review/task/music/minimax/create",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }


  /// 查询创建图片页信息
  static Future<ManageCreateImageInfoEntity?> queryCreateImageInfo({Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/content/review/image/create/page/info",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageCreateImageInfoEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 统一新建图片任务
  static Future<String?> createImageTask({Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/content/review/image/task/create",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 根据图片id查询图片信息
  static Future<ManageImageInfoEntity?> queryImageInfo({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/content/review/image/query",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageImageInfoEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 保存一张图片
  static Future<ManageImageInfoEntity?> saveImage({Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/content/review/image/save",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageImageInfoEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 统一裁剪
  static Future<String?> cropImage({Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/content/review/image/crop",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 撤销裁剪
  static Future<String?> undoCropImage({Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/admin/content/review/image/crop/undo",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 曲折变化列表
  static Future<ListResponseEntity<WordInflectionListItemEntity>?> queryWordInflectionList({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/write/word/inflection/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<WordInflectionListItemEntity>.fromJson(
        responseEntity.data,
        fromJson: WordInflectionListItemEntity.fromJson,
      );
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 词根词缀列表
  static Future<ListResponseEntity<WordMorphologyListItemEntity>?> queryWordMorphologyList({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/write/word/morphology/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<WordMorphologyListItemEntity>.fromJson(
        responseEntity.data,
        fromJson: WordMorphologyListItemEntity.fromJson,
      );
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 词根词缀筛选元数据
  static Future<FiltersGroupEntity?> getWordMorphologyFilters() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/write/word/morphology/query/meta/group/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return FiltersGroupEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 词根词缀顶部总览
  static Future<WordMorphologySummaryEntity?> getWordMorphologySummary({Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/write/word/morphology/summary",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return WordMorphologySummaryEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 词根词缀词卡页
  static Future<WordMorphologyWordsPageEntity?> queryWordMorphologyWordsPage({
    required String morphemeNid,
    Map<String, dynamic>? parameters,
  }) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: {
          "morphemeNid": morphemeNid,
          ...?parameters,
        },
      );
      dynamic response = await WiseHttp().request(
        "/language-console/write/word/morphology/morpheme/member/page",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return WordMorphologyWordsPageEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

    /// 词根成员词卡页
    static Future<WordMorphologyWordsPageEntity?> queryWordMorphologyRootMemberPage({
      required String key,
      Map<String, dynamic>? parameters,
    }) async{
      try {
        RequestConfig config = RequestConfig(
          requireToken: true,
          requireCache: true,
          parameters: {
            "key": key,
            ...?parameters,
          },
        );
        dynamic response = await WiseHttp().request(
          "/language-console/write/word/morphology/root/member/page",
          Method.post,
          headers: config.headers,
          requireToken: config.requireToken,
          requireCache: config.requireCache,
          parameters: config.parameters,
          data: config.data,
        );
        if (response == null) return null;
        ResponseEntity responseEntity = ResponseEntity.fromJson(response);
        if (responseEntity.code != HttpStatus.ok) {
          return null;
        }
        if (responseEntity.data == null) return null;
        return WordMorphologyWordsPageEntity.fromJson(responseEntity.data);
      } on FormatException catch (e) {
        ToastUtils.showToast(text: e.source.message);
        return null;
      } catch (e) {
        return null;
      }
    }

  /// 构词树
  static Future<WordMorphologyTreeEntity?> queryWordMorphologyTree({
    required String morphemeNid,
    required int key,
  }) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: {
          "morphemeNid": morphemeNid,
          "key": key,
        },
      );
      dynamic response = await WiseHttp().request(
        "/language-console/write/word/morphology/tree",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return WordMorphologyTreeEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 曲折变化筛选元数据
  static Future<FiltersGroupEntity?> getWordInflectionFilters() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/write/word/inflection/query/meta/group/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return FiltersGroupEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 曲折变化详情
  static Future<WordInflectionDetailEntity?> queryWordInflectionDetail(String familyKey, {Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: {
          "familyKey": familyKey,
          ...?parameters,
        },
      );
      dynamic response = await WiseHttp().request(
        "/language-console/write/word/inflection/detail",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return WordInflectionDetailEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 句子蓝图列表
  static Future<ListResponseEntity<PatternBlueprintEntity>?> queryPatternBlueprintList({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/pattern/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<PatternBlueprintEntity>.fromJson(responseEntity.data, fromJson: PatternBlueprintEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 查询句子蓝图详情
  static Future<PatternBlueprintEntity?> queryPatternBlueprint(String nid, {Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/pattern/$nid/detail",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return PatternBlueprintEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 查询句子蓝图例句列表
  static Future<ListResponseEntity<PatternBlueprintExampleEntity>?> queryPatternBlueprintExample({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/pattern/realization/set/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<PatternBlueprintExampleEntity>.fromJson(responseEntity.data, fromJson: PatternBlueprintExampleEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  } 

  /// 句子蓝图筛选的数据
  static Future<FiltersGroupEntity?> getPatternBlueprintFilters() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/pattern/query/meta/group/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return FiltersGroupEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 甄写例句句子上下架/删除
  static Future<bool> zhenxieExampleAccess({required int uid, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/realization-set/$uid/access/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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

  /// 句子蓝图编辑
  static Future<PatternBlueprintEntity?> editPatternBlueprint({required String nid, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/pattern/$nid/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return PatternBlueprintEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 查询句子池
  static Future<ListResponseEntity<EnKnowledgeEntity>?> queryPatternBlueprintSentencePool({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/pattern/simple/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<EnKnowledgeEntity>.fromJson(responseEntity.data, fromJson: EnKnowledgeEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 蓝图详情编辑代表句
  static Future<PatternBlueprintEntity?> editPatternBlueprintRepresent({required String nid, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/pattern/$nid/sentence/realizations/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return PatternBlueprintEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 查询句型对照列表
  static Future<ListResponseEntity<SentencePatternCompareEntity>?> querySentencePatternCompareList({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/paradigm/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<SentencePatternCompareEntity>.fromJson(responseEntity.data, fromJson: SentencePatternCompareEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 句型对照详情
  static Future<SentencePatternCompareEntity?> getSentencePatternCompareDetails(String nid, {Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/paradigm/$nid/detail",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return SentencePatternCompareEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 句型对照筛选的数据
  static Future<FiltersGroupEntity?> getSentencePatternCompareFilters() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/paradigm/query/meta/group/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return FiltersGroupEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }


  /// 句型对照编辑
  static Future<SentencePatternCompareEntity?> editSentencePatternCompare({required String nid, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/paradigm/$nid/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return SentencePatternCompareEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 句型对照-例句 AI 创建
  static Future<SentencePatternCompareAiCreateEntity?> createSentencePatternCompareAiTask({
    required String nid,
    Map<String, dynamic>? data,
  }) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/paradigm/$nid/sentence/realization/ai/create",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return SentencePatternCompareAiCreateEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 查询句间配对列表
  static Future<ListResponseEntity<SentencePairEntity>?> querySentencePairList({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/pair/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<SentencePairEntity>.fromJson(responseEntity.data, fromJson: SentencePairEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 查询句间配对详情
  static Future<SentencePairEntity?> getSentencePairDetails(String nid) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/pair/$nid/detail",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return SentencePairEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 查询句间配对分叉详情
  static Future<SentenceForkEntity?> getSentenceForkDetails(String nid) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/pair/fork/$nid/detail",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return SentenceForkEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 查询句间分叉列表
  static Future<ListResponseEntity<SentenceForkEntity>?> querySentenceForkList({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/pair/fork/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<SentenceForkEntity>.fromJson(responseEntity.data, fromJson: SentenceForkEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 配对筛选数据
  static Future<FiltersGroupEntity?> getPairFiltersGroup() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/pair/query/meta/group/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return FiltersGroupEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 分叉筛选数据
  static Future<FiltersGroupEntity?> getForkFiltersGroup() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/pair/fork/query/meta/group/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return FiltersGroupEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }


  /// 句间配链编辑
  static Future<SentencePairEntity?> editSentencePair({required String nid, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/pair/$nid/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return SentencePairEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }


  /// 获取语法全景列表
  static Future<ListResponseEntity<ManageGrammarPanoramaEntity>?> getManageGrammarPanoramaList({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/grid/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<ManageGrammarPanoramaEntity>.fromJson(responseEntity.data, fromJson: ManageGrammarPanoramaEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 查询语法全景例句列表
  static Future<ListResponseEntity<GrammarPanoramaExampleEntity>?> getManageGrammarPanoramatExample({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/grid/realization/set/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<GrammarPanoramaExampleEntity>.fromJson(responseEntity.data, fromJson: GrammarPanoramaExampleEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 语法全景编辑
  static Future<ManageGrammarPanoramaEntity?> editManageGrammarPanorama({required String nid, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/grid/$nid/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageGrammarPanoramaEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 语法全景筛选数据
  static Future<FiltersGroupEntity?> getGrammarPanoramaFiltersGroup() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/sentence/grid/query/meta/group/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return FiltersGroupEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 甄写筛选数据
  static Future<FiltersGroupEntity?> getWriteFilterData(String type) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/write/phrase/$type/query/meta/group/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return FiltersGroupEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  } 

  /// 短语对照列表
  static Future<ListResponseEntity<PhraseParadigmEntity>?> getWritePhraseParadigmPage({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/write/phrase/paradigm/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<PhraseParadigmEntity>.fromJson(responseEntity.data, fromJson: PhraseParadigmEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 短语对照详情
  static Future<PhraseParadigmEntity?> getWritePhraseParadigmDetail({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/write/phrase/paradigm/detail",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return PhraseParadigmEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 短语配对列表
  static Future<ListResponseEntity<PhrasePairEntity>?> getWritePhrasePairPage({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/write/phrase/pair/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<PhrasePairEntity>.fromJson(responseEntity.data, fromJson: PhrasePairEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 短语配对详情
  static Future<PhrasePairEntity?> getWritePhrasePairDetail({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/write/phrase/pair/detail",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return PhrasePairEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

  /// 短语搭配组列表
  static Future<ListResponseEntity<PhraseMatchEntity>?> getWritePhraseMatchPage({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/write/phrase/cluster/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<PhraseMatchEntity>.fromJson(responseEntity.data, fromJson: PhraseMatchEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 短语搭配组详情
  static Future<PhraseMatchEntity?> getWritePhraseMatchDetail({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/write/phrase/cluster/detail",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return PhraseMatchEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }


  /// 短语结构列表
  static Future<ListResponseEntity<PhraseStructureEntity>?> getWritePhraseStructurePage({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/write/phrase/structure/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<PhraseStructureEntity>.fromJson(responseEntity.data, fromJson: PhraseStructureEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 短语结构详情
  static Future<PhraseStructureEntity?> getWritePhraseStructureDetail({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/write/phrase/structure/detail",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
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


  /// 短语入句画像列表
  static Future<ListResponseEntity<EnterSentenceEntity>?> getWriteEnterSentencePage({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/write/phrase/profile/pages",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<EnterSentenceEntity>.fromJson(responseEntity.data, fromJson: EnterSentenceEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 短语入句画像详情
  static Future<EnterSentenceEntity?> getWriteEnterSentenceDetail({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/write/phrase/profile/detail",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return EnterSentenceEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;  
    }
  }

}
