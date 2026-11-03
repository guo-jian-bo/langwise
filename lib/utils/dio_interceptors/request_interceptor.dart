import 'dart:convert';
import 'dart:io';

import 'package:api/entities/response.dart';
import 'package:get/get.dart' as getx;
import 'package:lib_common/common.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wise_http/wise_http.dart';

import '../../app/routes/routes.dart';
import '../../common/stores/stores.dart';
import '../../common/values/values.dart';
import '../../common/widgets/system_maintenance_dialog.dart';
import '../../common/widgets/widgets.dart';
import '../utils.dart';
import 'dio_interceptor_utils.dart';

/// 请求拦截器 主要是增加header
class RequestsInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    Map<String, dynamic> headers = await getUserHeaders();
    options.headers.addAll(headers);

    Map<String, dynamic> queryParameters = getUserQueryParameters(options);
    options.queryParameters.addAll(queryParameters);

    String params = ErrorLogUtils.to.toSingleLineJsonSafe(options.queryParameters);
    String data = ErrorLogUtils.to.toSingleLineJsonSafe(options.data);
    _logInfo(
      "request method:${options.method} uri:${options.uri} params:$params data:$data",
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {

    String params = ErrorLogUtils.to.toSingleLineJsonSafe(response.requestOptions.queryParameters);
    String data = ErrorLogUtils.to.toSingleLineJsonSafe(response.requestOptions.data);
    final int startTime = response.requestOptions.extra['performanceTraceStart'] as int? ?? 0;
    // 从发送请求到响应的时长
    int duration = DateTime.now().millisecondsSinceEpoch - startTime;
    _logInfo(
      "response status:${response.statusCode} method:${response.requestOptions.method} duration:$duration uri:${response.requestOptions.uri} params:$params data:$data",
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }

  /// 获取默认请求头
  Future<Map<String, dynamic>> getUserHeaders() async{

    // 判断是否有设备id 如果没有设备id则重新登录
    String deviceId = StorageUtil().getString(STORAGE_DEVICE_ID_KEY);
    if (deviceId.isEmpty) {
      await UserStore.to.clearUserInfo();
      if (getx.Get.currentRoute != Routes.SIGN_IN_UP) {
        // 判断是否是体验app 如果是体验app则不跳转至登录
        bool experience = StorageUtil().getBool(EXPERIENCE_APP_KEY);
        if (!experience) {
          // 不是体验app 则跳转至登录
          getx.Get.offAllNamed(Routes.SIGN_IN_UP);
        }
      }
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String? timeZoneInfo = await DateFormatUtil.getTimeZoneInfo();
    String deviceType = _getDeviceInfo();

    return {
      "ZONE": timeZoneInfo,
      "DEVICE-ID": deviceId,
      "User-Agent": "TimelyWise-LangWise-$deviceType-${packageInfo.version}",
    };
  }

  /// 获取默认query参数
  Map<String, dynamic> getUserQueryParameters(RequestOptions options) {
    Map<String, dynamic> queryParameters = {};
    String path = options.path;

    if(!path.contains("/auth")){//auth
      // 如果是管理伪装 则需要替换userId和memberId
      int? userId = DioInterceptorUtils.getUserId(path);
      int? memberId = DioInterceptorUtils.getMemberId(path);
      
      if (userId != null) {
        queryParameters['userId'] = userId;
      }
      if (memberId != null) {
        queryParameters['memberId'] = memberId;
      }
    }

    /// 管理伪装操作员的用户id actorId
    int? actorId = DioInterceptorUtils.getActorId(path);
    if (actorId != null) {
      queryParameters['actorId'] = actorId;
    }

    /// 如果设置了视觉风格过滤 则不添加参数
    bool visualStyleExtra = options.extra[DioInterceptorUtils.visualStyleExtraKey] ?? false;
    if(!visualStyleExtra){
      /// 视觉风格参数
      Map<String, dynamic> visualGlobalSettingParams = DioInterceptorUtils.getVisualStyleRequestParams(path);
      queryParameters.addAll(visualGlobalSettingParams);
    }
   
  
    return queryParameters;
  }

  /// 是否是管理端的接口
  bool isManageRequest(String path){
    if(path.isEmpty) return false;
    String substr = path.substring(1);
    List<String> paths = substr.split("/");
    if(paths.isEmpty) return false;
    String firstPath = paths.first;
    if(firstPath.contains("console")){
      return true;
    }

    return false;
  }



  String _getDeviceInfo() {
    if(Platform.isAndroid){
      return "ANDROID";
    }else if(Platform.isIOS) {
      return "IOS";
    }else if(Platform.isMacOS){
      return "MACOS";
    }else if(Platform.isWindows){
      return "WINDOWS";
    }else if(Platform.isLinux){
      return "LINUX";
    } else {
      return "OTHER";
    }
  }

  void _logInfo(String message) {
    ErrorLogUtils.to.logInfo("[HTTP] -------- $message");
  }

  
}

/// 拦截系统维护
class SystemMaintenanceInterceptor extends Interceptor {
  static const String _socketAutoRecoverAttemptedKey =
      '_socket_auto_recover_attempted';
  bool isShowRetryDialog = false;
  bool isShowUpdateDialog = false;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.data != null) {
      try {
        ResponseEntity responseEntity = ResponseEntity.fromJson(response.data);
        if (responseEntity.code == 426) {
          _logInfo("响应体业务码426，准备弹出升级提示 uri:${response.requestOptions.uri}");
          if (isShowUpdateDialog) return;
          isShowUpdateDialog = true;
          // 表示需要升级APP 弹出升级弹窗
          await SystemPromptDialog.show(
            message: responseEntity.message,
          );
          AppCheckVersionDialog.checkVersion(checkTodayShow: false);
          isShowUpdateDialog = false;
          return;
        }
      } catch (_) {}
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    _logInfo(
      "error type:${err.type} status:${err.response?.statusCode} method:${err.requestOptions.method} uri:${err.requestOptions.uri} error:${err.error ?? err.message}",
    );
    if (err.response?.statusCode == 555) {
      ToastUtils.hideLoading();
      _logInfo("命中系统维护状态码555 uri:${err.requestOptions.uri}");
      // 系统维护中，提示用户
      dynamic data = json.decode(err.response?.data);
      int? time = data['data']['time']?.toInt();
      String? message = data['message']?.toString();
      SystemMaintenanceDialog.show(
        time: time,
        message: message,
      );
      // handler.next(err);
      return;
    } else if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      if (await _tryAutoRecoverSocketError(err, handler)) {
        return;
      }
      _logInfo(
        "命中网络异常重试分支 type:${err.type} uri:${err.requestOptions.uri} isDnsError:${_isDnsLikeError(err)}",
      );
      ErrorLogUtils.to.logError("path：${err.requestOptions.path} err：${err.toString()}", null);
      ToastUtils.hideLoading();
      _retryUntilNetworkAvailable(err, handler);
      return;
    } else if (err.response?.statusCode == 426) {
      // 表示需要升级APP 提示升级
      try {
        _logInfo("命中HTTP状态码426，准备弹出升级提示 uri:${err.requestOptions.uri}");
        dynamic data = err.response?.data;
        String? message = data['message']?.toString();
        if (isShowUpdateDialog) return;
        isShowUpdateDialog = true;
        await SystemPromptDialog.show(
          message: message,
        );
        AppCheckVersionDialog.checkVersion(checkTodayShow: false);
        isShowUpdateDialog = false;
      } catch (_) {}
      return;
    }else if(err.response?.statusCode == 403){
      _logInfo("命中HTTP状态码403，无权限访问 uri:${err.requestOptions.uri}");
      if(getx.Get.context != null){
        AskDialog.showUserAsk(
          context: getx.Get.context!,
          title: "温馨提示",
          content: "当前您没有权限访问",
          showCancel: false,
          define: "我知道了",
        );
      }
      
    }

    handler.next(err);
  }

  Future<bool> _tryAutoRecoverSocketError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldAutoRecoverSocketError(err)) {
      return false;
    }

    final Map<String, dynamic> extra =
        Map<String, dynamic>.from(err.requestOptions.extra);
    if (extra[_socketAutoRecoverAttemptedKey] == true) {
      _logInfo(
        "疑似连接池异常已执行过自动恢复，跳过重复恢复 uri:${err.requestOptions.uri}",
      );
      return false;
    }

    try {
      _logInfo(
        "检测到疑似连接池失效错误，准备自动重置WiseHttp并重试 uri:${err.requestOptions.uri}",
      );
      DioInterceptorUtils.reset();

      final retryOptions = err.requestOptions.copyWith(
        extra: extra
          ..[_socketAutoRecoverAttemptedKey] = true
          ..remove('ro_attempt')
          ..remove('ro_disable_retry'),
      );

      final Response<dynamic> response = await WiseHttp().fetch(retryOptions);
      _logInfo(
        "连接池自动恢复成功 status:${response.statusCode} method:${response.requestOptions.method} uri:${response.requestOptions.uri}",
      );
      handler.resolve(response);
      return true;
    } catch (recoverError, stackTrace) {
      _logInfo(
        "连接池自动恢复失败 uri:${err.requestOptions.uri} error:$recoverError",
      );
      ErrorLogUtils.to.logError(
        "[HTTP] -------- 连接池自动恢复失败 uri:${err.requestOptions.uri} error:$recoverError",
        stackTrace,
      );
      return false;
    }
  }

  /// 持续重试直到网络可用
  Future<void> _retryUntilNetworkAvailable(DioException err, ErrorInterceptorHandler handler) async {
    if (isShowRetryDialog) {
      _logInfo("已有网络重试弹窗在展示，本次异常直接透传 uri:${err.requestOptions.uri}");
      handler.next(err);
      return;
    }
    isShowRetryDialog = true;
    int retryCount = 0;
    while (true) {
      retryCount++;
      _logInfo(
        "开始第$retryCount次网络恢复重试，展示重试弹窗 method:${err.requestOptions.method} uri:${err.requestOptions.uri}",
      );
      // 显示网络错误对话框，让用户选择是否重试
      bool isRetry = await HttpErrorDialog.show();
      isShowRetryDialog = false;
      _logInfo("第$retryCount次重试弹窗结果 isRetry:$isRetry uri:${err.requestOptions.uri}");

      if (!isRetry) {
        // 用户选择不重试，传递错误
        _logInfo("用户取消网络重试，异常继续向下传递 uri:${err.requestOptions.uri}");
        handler.next(err);
        return;
      }

      try {
        ToastUtils.showLoading();
        _logInfo("用户确认重试，开始重置HTTP环境 uri:${err.requestOptions.uri}");

        DioInterceptorUtils.reset();
        _logInfo("网络重试前已执行WiseHttp.reset()");
        // await initHttp();
        _logInfo("网络重试前HTTP环境重新初始化完成");
        final retryOptions = err.requestOptions.copyWith(
          extra: Map<String, dynamic>.from(err.requestOptions.extra)
            ..remove('ro_attempt')
            ..remove('ro_disable_retry'),
        );

        final response = await WiseHttp().fetch(retryOptions);
        ToastUtils.hideLoading();
        _logInfo(
          "网络重试成功 status:${response.statusCode} method:${response.requestOptions.method} uri:${response.requestOptions.uri}",
        );
        // 请求成功，需要构造Response对象
        final successResponse = response;
        handler.resolve(successResponse);
        return;
      } catch (retryError) {
        ToastUtils.hideLoading();
        _logInfo("网络重试失败 retryCount:$retryCount uri:${err.requestOptions.uri} error:$retryError");
        ErrorLogUtils.to.logError(
          "[HTTP] -------- 网络重试失败 uri:${err.requestOptions.uri} error:$retryError",
          StackTrace.current,
        );
        // 重试失败后，继续循环让用户重新选择
        // 这里不需要额外处理，while循环会重新弹出选择弹窗
        isShowRetryDialog = true;
      }
    }
  }

  bool _isDnsLikeError(DioException err) {
    final error = err.error;
    if (error is! SocketException) return false;
    final message = error.message.toLowerCase();
    return message.contains('failed host lookup') ||
        message.contains('no address associated') ||
        message.contains('name or service not known') ||
        message.contains('nodename nor servname provided') ||
        message.contains('getaddrinfo failed');
  }

  bool _shouldAutoRecoverSocketError(DioException err) {
    if (err.type != DioExceptionType.connectionError) {
      return false;
    }
    final Object? error = err.error;
    if (error is! SocketException) {
      return false;
    }

    final int? errorCode = error.osError?.errorCode;
    if (errorCode == 49) {
      return true;
    }

    final String message = error.message.toLowerCase();
    return message.contains("can't assign requested address");
  }

  void _logInfo(String message) {
    ErrorLogUtils.to.logInfo("[HTTP] -------- $message");
  }
}

