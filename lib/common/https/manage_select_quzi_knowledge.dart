
import 'dart:io';

import 'package:api/api.dart';
import 'package:langwise/app/modules/management/manage_content/manage_generate_audio/models/manage_english_content_management_audio_model.dart';
import 'package:langwise/utils/utils.dart';
import 'package:quiz_play/models/models.dart';
import 'package:wise_http/wise_http.dart';

import '../../app/modules/management/manage_content/manage_audio_subtitle_editor/models/manage_english_content_management_sentence_audio_model.dart';
import '../../app/modules/management/models/manage_edit_quiz_model.dart';
import '../entities/entities.dart';

class ManageSelectQuziKnowledge {
  /// 根据AI模型获取对应的音色列表
  static Future<ResponseEntity<List<ManageEnglishContentManagementAudioAccentModel>>?> getAudioAccentList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;

      return ResponseEntity<List<ManageEnglishContentManagementAudioAccentModel>>.fromJson(response,
          fromJson: (json) => (json as List).map((e) => ManageEnglishContentManagementAudioAccentModel.fromJson(e)).toList());
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 自定义生成音频
  static Future<ManageEnglishContentManagementAudioModel?> generateAudio({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/audio/custom/generate",
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageEnglishContentManagementAudioModel.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取知识点列表
  static Future<ListResponseEntity<ManageUnitKnowledgeEntity>?> getKnowledgeList(int unitId, Map<String, dynamic> parameters, {Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/unit/$unitId/knowledge/pages",
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;

      return ListResponseEntity.fromJson(responseEntity.data, fromJson: ManageUnitKnowledgeEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取知识点总览
  static Future<ResponseEntity<List<ManageEnglishContentManagementModel>>?> getKnowledgeOverview({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/word/statistics",
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;

      return ResponseEntity<List<ManageEnglishContentManagementModel>>.fromJson(response,
          fromJson: (json) => (json as List).map((e) => ManageEnglishContentManagementModel.fromJson(e)).toList());
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 编辑单词释义
  static Future<ResponseEntity?> editWordInterpretation(int wordId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/word/$wordId/edit",
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
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取单词音频详细信息
  static Future<ResponseEntity<ManageEnglishContentManagementWordAudioModel>?> getWordAudioDetail(int wordId,
      {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/audio/word/$wordId/ipa/query",
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;

      return ResponseEntity<ManageEnglishContentManagementWordAudioModel>.fromJson(response, fromJson: ManageEnglishContentManagementWordAudioModel.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取句子音频详细信息
  static Future<ResponseEntity<ManageEnglishContentManagementSentenceAudioModel>?> getSentenceAudioDetail({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/audio/express/query",
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;

      return ResponseEntity<ManageEnglishContentManagementSentenceAudioModel>.fromJson(response, fromJson: ManageEnglishContentManagementSentenceAudioModel.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  ///AI划分音节、音素
  static Future<ResponseEntity<ManageEnglishContentManagementWordAudioSoundBlockDTOModel>?> aiDivisionSyllablePhoneme(
      {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/audio/sound_blocks",
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
      return ResponseEntity<ManageEnglishContentManagementWordAudioSoundBlockDTOModel>.fromJson(response,
          fromJson: ManageEnglishContentManagementWordAudioSoundBlockDTOModel.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 生成翻译字幕
  static Future<ResponseEntity?> generateTranslateAssString(int audioId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/audio/express/$audioId/ass/translate",
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
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 优化字幕
  static Future<ResponseEntity?> optimizeAss(int audioId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/audio/express/$audioId/ass/refine",
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
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 生成音节、音素AI音频
  static Future<ResponseEntity<ManageEnglishContentManagementWordAudioPhonemeModel>?> generatePhonemeAiAudio({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/audio/phoneme",
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
      return ResponseEntity<ManageEnglishContentManagementWordAudioPhonemeModel>.fromJson(response, fromJson: ManageEnglishContentManagementWordAudioPhonemeModel.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 编辑单词
  static Future<ResponseEntity?> editWord({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/audio/word/edit",
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
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取单词音频对应的题目
  static Future<ResponseEntity<List<QuizModel>>?> getQuizList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/word/exercise/list",
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;

      return ResponseEntity<List<QuizModel>>.fromJson(response, fromJson: (json) => (json as List).map((e) => QuizModel.fromJson(e)).toList());
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 发布单词
  static Future<ResponseEntity?> publishWord(int contentId, int wordId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/audio/word/$contentId/ipa/$wordId/publish",
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
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 无需发布单词
  static Future<ResponseEntity?> noNeedPublishWord({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/audio/word/block/mark",
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
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 编辑音节
  static Future<ResponseEntity?> editSyllable({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/audio/word/block/edit",
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
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 发布音节
  static Future<ResponseEntity?> publishSyllable(int ipaId, int soundBlockId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/audio/word/ipa/$ipaId/block/$soundBlockId/publish",
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
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 修改短语、句子、文章音频信息
  static Future<ResponseEntity?> updateSentenceAudio({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/audio/express/edit",
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
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// AI生成Prompt
  static Future<ResponseEntity?> aiGeneratePrompt({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/audio/prompt",
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
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
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
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 生成音频字幕
  static Future<ResponseEntity?> generateAudioAssString(int audioId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/audio/express/$audioId/ass",
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
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 发布音频
  static Future<ResponseEntity?> publishAudio(int audioId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/audio/express/$audioId/publish",
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
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 发布字幕
  static Future<ResponseEntity?> publishAssString(int audioId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/audio/express/$audioId/publish/ass",
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
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除音频
  static Future<ResponseEntity?> deleteAudio(int audioId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/audio/express/$audioId/delete",
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
      return responseEntity;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除单词
  static Future<ResponseEntity?> deleteWord(int knowledgeId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
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

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除语义
  static Future<ResponseEntity?> deleteSemantic(int semanticId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
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

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除短语语义
  static Future<ResponseEntity?> deletePhraseSemantic(int semanticId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
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

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }
  

  /// 删除短语
  static Future<ResponseEntity?> deletePhrase(int knowledgeId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
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

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除句子
  static Future<ResponseEntity?> deleteSentence(int knowledgeId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
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

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除文章
  static Future<ResponseEntity?> deleteArticle(int knowledgeId, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
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

      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      return responseEntity;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取单词知识点列表
  static Future<ListResponseEntity<EnWordEntity>?> getEnWordKnowledgeList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<EnWordEntity>.fromJson(responseEntity.data, fromJson: EnWordEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取音色列表
  static Future<ResponseEntity<List<ManageEnglishContentManagementAccentModel>>?> getAccentList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;

      return ResponseEntity<List<ManageEnglishContentManagementAccentModel>>.fromJson(response,
          fromJson: (json) => (json as List).map((e) => ManageEnglishContentManagementAccentModel.fromJson(e)).toList());
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取短语知识点列表
  static Future<ListResponseEntity<EnPhraseEntity>?> getEnPhraseKnowledgeList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<EnPhraseEntity>.fromJson(responseEntity.data, fromJson: EnPhraseEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取句子知识点列表
  static Future<ListResponseEntity<EnSentenceEntity>?> getEnSentenceKnowledgeList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<EnSentenceEntity>.fromJson(responseEntity.data, fromJson: EnSentenceEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取文章知识点列表
  static Future<ListResponseEntity<EnTextEntity>?> getEnTextKnowledgeList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<EnTextEntity>.fromJson(responseEntity.data, fromJson: EnTextEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取文章知识点列表
  static Future<ListResponseEntity<EnTextEntity>?> getEnRevealsKnowledgeList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/en/reveals/pages",
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      return ListResponseEntity<EnTextEntity>.fromJson(responseEntity.data, fromJson: EnTextEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// AI生成题目 请求预览
  static Future<bool> requestAiPreviewQuizList(
    List<ManageUnitKnowledgeEntity>? unitKnowledgeList,
    ManageLessonTemplateEntityDatasExerciseConfigs? config,
    String? exerciseType,
    int? difficultyMin,
    int? difficultyMax,
    String? aiCode,
    int? unitId,
    int? lessonId,
    int? templateId,
  ) async {
    if (unitKnowledgeList == null) return false;
    if (unitKnowledgeList.isEmpty) return false;
    if (config == null) return false;
    if (exerciseType == null) return false;
    if (difficultyMin == null) return false;
    if (difficultyMax == null) return false;
    if (aiCode == null) return false;
    if (unitId == null) return false;
    if (lessonId == null) return false;
    if (templateId == null) return false;

    List<Map<String, dynamic>> contents = [];

    for (int i = 0; i < unitKnowledgeList.length; i++) {
      contents.add({
        "contentType": unitKnowledgeList[i].contentType,
        "contentId": unitKnowledgeList[i].contentId,
        "semanticId": unitKnowledgeList[i].semanticId,
      });
    }
    Map<String, dynamic> reqData = {
      "type": exerciseType,
      "config": config.toJson(),
      "contents": contents,
      "difficulty": {
        "min": difficultyMin,
        "max": difficultyMax,
      },
      "suggestCode": aiCode,
      "unitId": unitId,
      "lessonId": lessonId,
      "templateId": templateId,
    };
    try {
      PreviewQuizEntity? previewQuizEntity = await getAiPreviewQuizList(reqData);
      if (previewQuizEntity == null) return false;
      if (previewQuizEntity.async == null) return false;
      if (previewQuizEntity.async == 1) {
        return true; // 需要等待
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 题目预览
  static Future<PreviewQuizEntity?> getAiPreviewQuizList(Map<String, dynamic>? data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
        options: Options(
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/template/preview",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
        cancelToken: config.cancelToken,
        options: config.options,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      PreviewQuizEntity previewQuizEntity = PreviewQuizEntity.fromJson(responseEntity.data);
      return previewQuizEntity;
    } on FormatException catch (e) {
      print(e.source);
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// ai预览题目 wesocket消息回来之后 需要调用此接口 查询题目
  static Future<AiBackPreviewInfoEntity?> getAiBackQuizData(int aiRecordId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: {
          "aiRecordId": aiRecordId,
        },
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/ai/result",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      AiBackPreviewInfoEntity aiBackPreviewInfoEntity = AiBackPreviewInfoEntity.fromJson(responseEntity.data);
      return aiBackPreviewInfoEntity;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取新建题目方式列表
  static Future<List<CreateQuizAiTypeEntity>?> getCreateQuizAiTypeList(String quizType) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: {
          "type": quizType,
        },
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/suggest/type/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      List? list = responseEntity.data['list'];
      if (list == null) return null;
      List<CreateQuizAiTypeEntity> result = [];
      for (var item in list) {
        result.add(CreateQuizAiTypeEntity.fromJson(item));
      }
      return result;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 添加题目
  static Future<bool> addRequest({
    required QuizModel quiz,
    List<ManageUnitKnowledgeEntity>? unitKnowledgeList,
    int? lessonId,
    String? aiCode,
    int? difficultyMin,
    int? difficultyMax,
    String? language,
    int? recordId,
    int? quizId,
    int? configId,
  }) async {
    if (unitKnowledgeList == null) return false;
    try {
      // 知识点列表
      List<Map<String, dynamic>> contentInfos = [];

      for (int i = 0; i < unitKnowledgeList.length; i++) {
        contentInfos.add(unitKnowledgeList[i].toJson());
      }

      List<String> purposes = []; //题目支持类型
      if (quiz.purpose != null) {
        purposes.add(quiz.purpose!);
      }

      List<Map<String, dynamic>> stems = [];
      if (quiz.stems != null) {
        for (int i = 0; i < quiz.stems!.length; i++) {
          if (quiz.stems![i] == null) continue;
          stems.add(quiz.stems![i]!.toJson());
        }
      }

      List<Map<String, dynamic>> options = [];

      if (quiz.options != null) {
        for (int i = 0; i < quiz.options!.length; i++) {
          if (quiz.options![i] == null) continue;
          options.add(quiz.options![i]!.toJson());
        }
      }

      List<Map<String, dynamic>> questions = [];
      if (quiz.questions != null) {
        for (int i = 0; i < quiz.questions!.length; i++) {
          if (quiz.questions![i] == null) continue;
          questions.add(quiz.questions![i]!.toJson());
        }
      }

      Map<String, dynamic> reqData = {
        "lessonId": lessonId, //课时ID
        "contentInfos": contentInfos, // 知识点列表
        "suggestCode": aiCode, //AI方式
        "type": quiz.type, //题目类型
        "difficulty": {
          "min": difficultyMin,
          "max": difficultyMax,
        },
        "language": language,
        "purposes": purposes, //题目支持类型
        "questions": questions,
        "stems": stems,
        "options": options,
        "config": quiz.config?.toJson(),
        "recordId": recordId,
        "exerciseId": quizId,
        "configId": configId,
      };
      List<int>? addRes = await ManageSelectQuziKnowledge.addQuiz(reqData);
      if (addRes == null) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 保存
  static Future<List<int>?> addQuiz(Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/create",
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
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      List? list = responseEntity.data['list'];
      if (list == null) return null;
      List<int> result = [];
      for (var item in list) {
        result.add(item);
      }
      return result;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取课时下已经保存的题目列表ids
  static Future<List<LessonExerciseInfoEntity>?> getLessonQuizList(int lessonId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/lesson/$lessonId/exercise/list",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      List? list = responseEntity.data;
      if (list == null) return null;
      List<LessonExerciseInfoEntity> result = [];
      for (var item in list) {
        result.add(LessonExerciseInfoEntity.fromJson(item));
      }
      return result;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 根据ids获取详细题目
  static Future<List<QuizModel>?> getQuizListByIds(List<int> exerciseIds) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: exerciseIds,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/detail/list",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      List? list = responseEntity.data;
      if (list == null) return null;
      List<QuizModel> result = [];
      for (var item in list) {
        result.add(QuizModel.fromJson(item));
      }
      return result;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 根据id获取详细题目
  static Future<ManageEditQuizModel?> getQuizListById(int quizId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: {},
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/$quizId/detail",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageEditQuizModel.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 保存编辑的题目
  static Future<bool> saveEditQuiz(Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 编辑已经添加题目的顺序 拖动排序(比如说第三条 拖到第一条后面 那么index=2)
  static Future<bool> editQuizOrder(int lessonId, int index, int exerciseId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: {
          "index": index,
          "lessonId": lessonId,
          "exerciseId": exerciseId,
        },
      );
      dynamic response = await WiseHttp().request(
        "/course-console/lesson/exercise/edit/order",
        Method.put,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 题目批量操作接口
  static Future<bool> quizOperation(Map<String, dynamic> data, String method) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/operation/$method",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteQuiz(int lessonId, int exerciseId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: {
          "lessonId": lessonId,
          "exerciseId": exerciseId,
        },
      );
      dynamic response = await WiseHttp().request(
        "/course-console/lesson/exercise/delete",
        Method.delete,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 获取已有题目列表
  static Future<List<QuizModel>?> getExerciseList(Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/list/query/config",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      List? list = responseEntity.data['list'];
      if (list == null) return null;
      List<QuizModel> result = [];
      for (var item in list) {
        QuizModel quizModel = QuizModel.fromJson(item);
        quizModel.reason = quizModel.uid?.toString();
        result.add(quizModel);
      }
      return result;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取标注图片的图片
  static Future<ManageLabelPictureEntity?> getLabelPictureDatas(Map<String, dynamic> parameters) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/load/label/picture/image",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      ManageLabelPictureEntity? result = ManageLabelPictureEntity.fromJson(responseEntity.data);
      return result;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 标注图片 重新生成
  static Future<bool> regenerateLabelPicture(int recordId, Map<String, dynamic> parameters) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/regenerate/ai/record/$recordId",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 重新生成图片的标注
  static Future<ManageLabelPictureEntity?> regenerateLabelPicturTip(int imageId) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: {
          "imageId": imageId,
        },
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/load/label/picture/regenerate/tip",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageLabelPictureEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 绑定题目
  static Future<bool> exerciseLessonBind(Map<String, dynamic> data) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/course-console/exercise/lesson/bind",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showManageToast(text: responseEntity.message ?? "", type: ManageToastType.error);
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showManageToast(text: e.source.message, type: ManageToastType.error);
      return false;
    } catch (e) {
      return false;
    }
  }




}
