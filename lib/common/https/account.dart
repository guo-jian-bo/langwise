import 'dart:io';

import 'package:api/api.dart';
import 'package:wise_http/wise_http.dart';

import '../../utils/utils.dart';
import '../entities/entities.dart';

class AccountUtil {
  // 上传图片/音频token
  static Future<ResponseEntity<ResourceResponseEntity>> fetchToken({required String type}) async {
    return await AccountImpl().token(path: '/accounts/resource/token', config: RequestConfig(requireToken: true, data: {'type': type}));
  }

  // 上传图片/音频token
  static Future<ResponseEntity<ResourceResponseEntity>> fetchModuleToken({required String type, required String module, required String format}) async {
    return await AccountImpl().token(path: '/accounts/resource/console/token', config: RequestConfig(requireToken: true, data: {'type': type, "module": module, "format": format}));
  }

  /// 获取Websocket地址信息
  static Future<WebsockeInfotEntity?> getWebSocketInfo() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp()
          .request(
            "/accounts/authorize/websocket/client/token",
            Method.get,
            headers: config.headers,
            requireToken: config.requireToken,
            requireCache: config.requireCache,
          )
          .catchError((_) {});
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      WebsockeInfotEntity websockeInfotEntity = WebsockeInfotEntity.fromJson(responseEntity.data);
      return websockeInfotEntity;
    } catch (e) {
      return null;
    }
  }

  /// 获取启动时需要处理的消息
  static Future<ListResponseEntity<PushMessageEntity>?> getInitMessageList({Map<String, dynamic>? parameters}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/user/notify/retain/pages",
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
      ListResponseEntity<PushMessageEntity> listResponseEntity = ListResponseEntity<PushMessageEntity>.fromJson(responseEntity.data, fromJson: PushMessageEntity.fromJson);
      return listResponseEntity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取消息列表
  static Future<ListResponseEntity<PushMessageEntity>?> getMessageList({Map<String, dynamic>? parameters}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/user/notify/page",
        Method.get,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: parameters,
      );
      if (response == null) return null;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return null;
      }
      if (responseEntity.data == null) return null;
      ListResponseEntity<PushMessageEntity> listResponseEntity = ListResponseEntity<PushMessageEntity>.fromJson(responseEntity.data, fromJson: PushMessageEntity.fromJson);
      return listResponseEntity;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 读消息
  static Future<bool> readMessage(List<int> ids) async {
    if (ids.isEmpty) return false;
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: {
          "notificationIds": ids,
        },
      );
      dynamic response = await WiseHttp().request(
        "/accounts/user/notify/read",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      if (responseEntity.data == null) return false;
      return true;
    } finally {}
  }

  /// 一键已读
  static Future<bool> readAllMessage({Map<String, dynamic>? data, Map<String, dynamic>? parameters}) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/user/notify/read/all",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
        parameters: config.parameters,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      if (responseEntity.data == null) return false;
      return true;
    } finally {}
  }

  /// 上报已经显示的消息
  static Future<bool> reportAlreadyShowMessage(List<int> notificationIds) async {
    if (notificationIds.isEmpty) return false;
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: {
          "notificationIds": notificationIds,
        },
      );
      dynamic response = await WiseHttp().request(
        "/accounts/user/notify/show",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      if (responseEntity.data == null) return false;
      return true;
    } finally {}
  }

  /// 获取用户信息
  static Future<UserInfoEntity?> getUserInfo() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/user/detail/info",
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
      return UserInfoEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      ToastUtils.showToast(text: "获取用户信息失败");
      return null;
    }
  }

  /// 获取用户信息
  static Future<RolePermissionsEntity?> getUserRolePermissions() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/user/extension/info",
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
      return RolePermissionsEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 注销账户
  static Future<bool> logoff(Map<String, dynamic> reqData) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: reqData,
      );
      final rawHeader = config.headers ?? {};
      final seconds = await GeneralUtil.getSyncDate();
      final signature = AuthImpl().generateSignature(config.appId, config.appSecret, seconds);
      rawHeader['APP-SIGNATURE'] = '$seconds;$signature';
      dynamic response = await WiseHttp().request(
        "/auth/logoff",
        Method.delete,
        headers: rawHeader,
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
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 获取国际区号列表
  static Future<InternationalAreaCodeEntity?> getInternationalAreaCodeList() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/resource/country/callings",
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
      return InternationalAreaCodeEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 上传日志
  static Future<bool> uploadErrorLogs(Map<String, dynamic> reqData) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: reqData,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/user/log/upload",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        data: config.data,
      );
      if (response == null) return false;
      ResponseEntity responseEntity = ResponseEntity.fromJson(response);
      if (responseEntity.code != HttpStatus.ok) {
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 发送设置管理端密码短信
  static Future<bool> setManagePasswordSendSmsCode(Map<String, dynamic> parameters) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        parameters: parameters,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/user/role/reset/password/sms/send",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
        parameters: config.parameters,
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

  /// 设置管理端密码
  static Future<bool> setManagePassword(Map<String, dynamic> data) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/user/role/reset/password/sms/token",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
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

  /// 验证管理密码
  static Future<bool?> verifyManagePassword(String password) async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: {
          "password": password,
        },
      );
      dynamic response = await WiseHttp().request(
        "/accounts/user/role/validate/password",
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
      if (responseEntity.data != 1) {
        ToastUtils.showToast(text: "密码错误");
        return false;
      }
      return true;
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取mqtt连接信息
  static Future<MqttTokenEntity?> getMqttClientToken() async {
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/authorize/mqtt/client/token",
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
      MqttTokenEntity websockeInfotEntity = MqttTokenEntity.fromJson(responseEntity.data);
      return websockeInfotEntity;
    } catch (e) {
      return null;
    }
  }
  
  /// 获取当前资源风格列表
  static Future<TeamStyleEntity?> getTeamStyle() async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/team/style/status/list",
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
      return TeamStyleEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 设置视觉风格
  static Future<bool> teamConfigStyleEdit(Map<String, dynamic> data) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/team/config/style/edit",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
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
  

  /// 获取风格支付详情
  static Future<VisualStylePayInfoEntity?> getVisualStylePayInfo({Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/team/config/style/pay/detail",
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
      return VisualStylePayInfoEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 订阅视觉风格
  static Future<bool> teamStylePay({Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/team/config/style/pay",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
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

  /// 取消订阅
  static Future<bool> teamStyleUnsubscribe({Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/team/config/style/unsubscribe",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
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

  /// 获取重试风格支付详情
  static Future<VisualStylePayInfoEntity?> getVisualStylePayRetryInfo({Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/team/config/style/pay/retry/detail",
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
      return VisualStylePayInfoEntity.fromJson(responseEntity.data);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 风格重试支付
  static Future<bool> teamStylePayRetry({Map<String, dynamic>? data}) async{
    try {
      RequestConfig config = RequestConfig(
        requireToken: true,
        requireCache: true,
        data: data,
      );
      dynamic response = await WiseHttp().request(
        "/accounts/team/config/style/pay/retry",
        Method.post,
        headers: config.headers,
        requireToken: config.requireToken,
        requireCache: config.requireCache,
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

}
