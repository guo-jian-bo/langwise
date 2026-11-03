import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class LanguageConsoleDramaRequest{

  /// 获取人声情绪列表
  static Future<ListResponseEntity<ManageVocalEmotionsEntity>?> getVocalEmotionsList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/voice/emotion/pages",
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
      return ListResponseEntity<ManageVocalEmotionsEntity>.fromJson(responseEntity.data, fromJson: ManageVocalEmotionsEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 新增情绪
  static Future<ManageVocalEmotionsEntity?> addVocalEmotions({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/voice/emotion/create",
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
      return ManageVocalEmotionsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除情绪
  static Future<bool> deleteVocalEmotions(int uid, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/voice/emotion/$uid/delete",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
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

  /// 编辑人声情绪
  static Future<ManageVocalEmotionsEntity?> editVocalEmotions(int uid, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/voice/emotion/$uid/edit",
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
      return ManageVocalEmotionsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 获取人声情绪试听音频列表
  static Future<List<VocalEmotionsAuditionEntity>?> getEmotionsAuditionList({Map<String, dynamic>? parameters, Map<String, dynamic>? data, CancelToken? cancelToken}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
        cancelToken: cancelToken,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/voice/emotion/preview",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
        data: config.data,
        cancelToken: config.cancelToken,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        ToastUtils.showToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      List? list = responseEntity.data;
      if(list == null) return null;
      List<VocalEmotionsAuditionEntity> respList = [];
      for(var item in list){
        respList.add(VocalEmotionsAuditionEntity.fromJson(item));
      }
      return respList;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取人声音色列表
  static Future<ListResponseEntity<ManageVocalTimbreEntity>?> getVocalTimbreList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/voice/timbre/pages",
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
      return ListResponseEntity<ManageVocalTimbreEntity>.fromJson(responseEntity.data, fromJson: ManageVocalTimbreEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 新增人声音色
  static Future<ManageVocalTimbreEntity?> addVocalTimbre({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/voice/timbre/create",
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
      return ManageVocalTimbreEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除人声音色
  static Future<bool> deleteVocalTimbre(int uid, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/voice/timbre/$uid/delete",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
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

  /// 编辑人声音色
  static Future<ManageVocalTimbreEntity?> editVocalTimbre(int uid, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/voice/timbre/$uid/edit",
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
      return ManageVocalTimbreEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 人声音色上传音频
  static Future<ManageVocalTimbreEntityAudioRefsAudio?> uploadVocalTimbreAudio({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/voice/timbre/audio/upload",
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
      return ManageVocalTimbreEntityAudioRefsAudio.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 人声音色生成音频
  static Future<String?> generateVocalTimbreAudio({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/voice/timbre/audio/generate",
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
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 人声音色设计台词
  static Future<String?> designVocalTimbreAudioText({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/voice/timbre/audio_text/design",
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
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  // ==================== 甄读角色 ====================

  /// 获取甄读角色列表
  static Future<ListResponseEntity<MangePersonaEntity>?> getPersonaList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/persona/pages",
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
      return ListResponseEntity<MangePersonaEntity>.fromJson(responseEntity.data, fromJson: MangePersonaEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 新增甄读角色
  static Future<MangePersonaEntity?> addPersona({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/persona/create",
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
      return MangePersonaEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 编辑甄读角色
  static Future<MangePersonaEntity?> editPersona(int uid, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/persona/$uid/edit",
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
      return MangePersonaEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除甄读角色
  static Future<bool> deletePersona(int uid, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/persona/$uid/delete",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
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

  /// 新增甄读角色变体
  static Future<MangePersonaEntityVariants?> addPersonaVariant({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/persona/variant/create",
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
      return MangePersonaEntityVariants.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 编辑甄读角色变体
  static Future<MangePersonaEntityVariants?> editPersonaVariant(int uid, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/persona/variant/$uid/edit",
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
      return MangePersonaEntityVariants.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除甄读角色变体
  static Future<bool> deletePersonaVariant(int uid, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/persona/variant/$uid/delete",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
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


  /// 角色 新增设定图
  static Future<String?> addSettingDiagram({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/persona/variant/image/generate",
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
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  // ==================== 剧本主题 ====================

  /// 获取剧本主题列表
  static Future<List<ManageScriptThemeEntity>?> getScriptThemeList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/theme/list",
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
      List? list = responseEntity.data;
      if(list == null) return null;
      List<ManageScriptThemeEntity> respList = [];
      for (var element in list) {
        respList.add(ManageScriptThemeEntity.fromJson(element));
      }
      return respList;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 新增剧本主题
  static Future<ManageScriptThemeEntity?> addScriptTheme({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/theme/create",
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
      return ManageScriptThemeEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 编辑剧本主题
  static Future<ManageScriptThemeEntity?> editScriptTheme({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/theme/edit",
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
      return ManageScriptThemeEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除剧本主题
  static Future<bool> deleteScriptTheme({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/theme/delete",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
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

  // ==================== 剧本题材 ====================

  /// 获取剧本题材列表
  static Future<List<ManageScriptGenreEntity>?> getScriptGenreList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/genre/list",
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
      List? list = responseEntity.data;
      if(list == null) return null;
      List<ManageScriptGenreEntity> respList = [];
      for (var element in list) {
        respList.add(ManageScriptGenreEntity.fromJson(element));
      }
      return respList;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 新增剧本题材
  static Future<ManageScriptGenreEntity?> addScriptGenre({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/genre/create",
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
      return ManageScriptGenreEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 编辑剧本题材
  static Future<ManageScriptGenreEntity?> editScriptGenre({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/genre/edit",
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
      return ManageScriptGenreEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除剧本题材
  static Future<bool> deleteScriptGenre({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/genre/delete",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
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

  // ==================== 剧本分组 ====================

  /// 获取剧本分组列表（分页）
  static Future<ListResponseEntity<ManageScriptGroupingEntity>?> getScriptGroupPages({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/group/pages",
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
      return ListResponseEntity<ManageScriptGroupingEntity>.fromJson(responseEntity.data, fromJson: ManageScriptGroupingEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 新增剧本分组
  static Future<ManageScriptGroupingEntity?> addScriptGroup({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/group/create",
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
      return ManageScriptGroupingEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 编辑剧本分组
  static Future<ManageScriptGroupingEntity?> editScriptGroup(int uid, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/group/$uid/edit",
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
      return ManageScriptGroupingEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除剧本分组
  static Future<bool> deleteScriptGroup(int uid, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/group/$uid/delete",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
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


  /// 获取剧本列表
  static Future<ListResponseEntity<ManageScriptEntity>?> getScriptList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/pages",
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
      return ListResponseEntity<ManageScriptEntity>.fromJson(responseEntity.data, fromJson: ManageScriptEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 创建单元剧本
  static Future<String?> createUnitScript({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/generate/unit",
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
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 创建词汇剧本
  static Future<String?> createVocabularyScript({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/generate/vocabulary",
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
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 剧本编辑
  static Future<bool> scriptEdit(int uid, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/$uid/edit",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
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


  /// 获取剧本详情
  static Future<ManageScriptDetilEntity?> getScriptDetils(int uid, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/$uid/detail",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageScriptDetilEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 场景编辑
  static Future<ManageScriptDetilEntityScenes?> sceneEdit(int uid, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/scene/$uid/edit",
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
      return ManageScriptDetilEntityScenes.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 场景台词排序
  static Future<bool> sceneDialogueSort(int uid, {Map<String, dynamic>? parameters, List<Map<String, dynamic>>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/scene/$uid/dialogue/sort",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
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

  /// 场景删除台词
  static Future<bool> sceneDialogueDelete(int uid, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/dialogue/$uid/delete",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
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

  /// 场景编辑台词
  static Future<ManageScriptDetilEntityScenesDialogues?> sceneDialogueEdit(int uid, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/dialogue/$uid/edit",
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
      return ManageScriptDetilEntityScenesDialogues.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 场景新增台词
  static Future<ManageScriptDetilEntityScenesDialogues?> sceneDialogueAdd({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/script/dialogue/create",
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
      return ManageScriptDetilEntityScenesDialogues.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 获取音频项目列表
  static Future<ListResponseEntity<ManageAudioProjectEntity>?> getAudioProjectList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/audio/project/pages",
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
      return ListResponseEntity<ManageAudioProjectEntity>.fromJson(responseEntity.data, fromJson: ManageAudioProjectEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除音频项目
  static Future<bool> deleteAudioProject({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/audio/project/delete",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
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


  /// 创建音频项目
  static Future<String?> createAudioProject({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/audio/project/create/from-script",
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
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 获取音频项目详情
  static Future<ManageAudioProjectDetilEntity?> getAudioProjectDetils(int uid, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/audio/project/$uid/detail",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageAudioProjectDetilEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 新建台词音频
  static Future<String?> createDialogueAudio({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/audio/project/voice/dialogue",
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
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 合成音频项目
  static Future<String?> composeAudioProject({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/audio/project/compose",
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
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 获取视觉项目列表
  static Future<ListResponseEntity<ManageVisualProjectEntity>?> getVisualProjectList({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/visual/project/pages",
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
      return ListResponseEntity<ManageVisualProjectEntity>.fromJson(responseEntity.data, fromJson: ManageVisualProjectEntity.fromJson);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

    /// 删除音频项目
  static Future<bool> deleteVisualProject({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/visual/project/delete",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
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

  /// 创建视觉项目
  static Future<String?> createVisualProject({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/visual/project/create",
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
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 获取视觉项目详情
  static Future<ManageVisualProjectEntity?> getVisualProjectDetils(int uid, {Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/visual/project/$uid/detail",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
        return null;
      }
      if (responseEntity.data == null) return null;
      return ManageVisualProjectEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取视觉项目提示词信息
  static Future<ManageVisualProjectPromptEntity?> getVisualProjectPromptInfo({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/visual/project/storyboard/sheet/prompt/view",
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
      return ManageVisualProjectPromptEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 视觉项目 生成提示词
  static Future<String?> createVisualProjectPromptGenerate({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/visual/project/storyboard/sheet/prompt/generate",
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
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 视觉项目 根据提示词生成分镜图
  static Future<String?> createVisualProjectSceneGenerate({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/visual/project/storyboard/sheet/image/task/by/prompt",
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
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 视觉项目 重新裁剪关键帧
  static Future<bool> createVisualProjectSceneCrop({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/visual/project/storyboard/sheet/image/crop",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
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

  /// 视觉项目 上传分镜图
  static Future<bool> visualUpdateSceneImage({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/visual/project/storyboard/sheet/image/import",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
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

  /// 视觉项目 生成场景视频
  static Future<String?> visualGenerateSceneVideo({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/visual/project/generate/video/scene",
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
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 视觉项目 生成场景视频
  static Future<String?> visualGenerateTransitionVideo({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/visual/project/generate/video/between/scenes",
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
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 视觉项目 合成完整视频
  static Future<String?> visualGenerateFullVideo({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/visual/project/video/compose",
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
      return responseEntity.data.toString();
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 视觉项目 获取视觉场景片段视频列表
  static Future<List<ManageVisualSceneVideoEntity>?> getVisualSceneVideo({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/visual/project/video/segments",
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
      List? list = responseEntity.data;
      if(list == null) return null;
      List<ManageVisualSceneVideoEntity> respList = [];
      for (var element in list) {
        respList.add(ManageVisualSceneVideoEntity.fromJson(element));
      }
      return respList;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 视觉项目 删除视频片段
  static Future<bool> visualDeleteVideo({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/visual/project/video/segment/delete",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
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

  /// 视觉项目 删除视频排序
  static Future<bool> visualVideoSort({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/visual/project/video/segment/sort",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
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

  /// 视觉项目 导入完整视频
  static Future<bool> visualImportVideo({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/visual/project/video/import",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
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

  /// 获取视觉项目 字幕映射
  static Future<ManageVisuaAssMappingEntity?> getVisualProjectFrameMappingDetils({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/visual/project/frame/mapping/detail",
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
      return ManageVisuaAssMappingEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 视觉项目 保存当前scene映射
  static Future<bool> visualProjectSaveSceneMapping({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/visual/project/frame/mapping",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
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

  /// 视觉项目 生成关键帧字幕
  static Future<bool> visualGenerateKeyframeSubtitles({Map<String, dynamic>? parameters, Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/language-console/drama/visual/project/frame/ass",
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
        ToastUtils.showToast(text: responseEntity.message ?? "");
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

}
