import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class ConfigRequest {

  static Future<ConfigEntity?> getConfig() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/resource/common/config",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
      ).catchError((_) {});
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      ConfigEntity configEntity = ConfigEntity.fromJson(responseEntity.data);
      return configEntity;
    } catch (e) {
      return null;
    }
  }

  /// 获取卡片相关颜色
  static Future<LanguageConfigColorEntity?> getCardColorConfig() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/languages/language/config/color/list",
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
      return LanguageConfigColorEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }


  /// 获取第三方账号
  static Future<String?> getThirdPartyAccount(int timestamp) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: {
          "timestamp": timestamp,
        },
      );
      dynamic response = await WiseHttp().request(
        "/secures/secret/supplier/app",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        parameters: config.parameters,
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


  /// 测试接口
  static Future<void> test() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/studies/page/card/426",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
      );
      if (response == null) return;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return;
      }
      if (responseEntity.data == null) return;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return;
    } catch (e) {
      return;
    }
  }

}