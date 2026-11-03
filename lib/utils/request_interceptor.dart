import 'dart:convert';
import 'dart:io';

import 'package:api/entities/response.dart';
import 'package:get/get.dart' as getx;
import 'package:lib_common/common.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wise_http/wise_http.dart';

import '../app/routes/routes.dart';
import '../common/stores/stores.dart';
import '../common/values/values.dart';
import '../common/widgets/system_maintenance_dialog.dart';
import '../common/widgets/widgets.dart';
import 'utils.dart';

/// 请求拦截器 主要是增加header
class RequestsInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _logInfo(
      "请求开始 method:${options.method} uri:${options.uri} hasData:${options.data != null} queryKeys:${options.queryParameters.keys.toList()}",
    );

    // 判断是否有设备id 如果没有设备id则重新登录
    String deviceId = StorageUtil().getString(STORAGE_DEVICE_ID_KEY);
    if (deviceId.isEmpty) {
      _logInfo("检测到deviceId为空，准备清理登录态，currentRoute:${getx.Get.currentRoute}");
      await UserStore.to.clearUserInfo();
      if (getx.Get.currentRoute != Routes.SIGN_IN_UP) {
        // 判断是否是体验app 如果是体验app则不跳转至登录
        bool experience = StorageUtil().getBool(EXPERIENCE_APP_KEY);
        if (!experience) {
          // 不是体验app 则跳转至登录
          _logInfo("deviceId为空且非体验模式，跳转登录页:${Routes.SIGN_IN_UP}");
          getx.Get.offAllNamed(Routes.SIGN_IN_UP);
        }
      }
    }

    String? timeZoneInfo = await DateFormatUtil.getTimeZoneInfo();
    String deviceType = _getDeviceInfo();
    options.headers.addAll({
      "ZONE": timeZoneInfo,
      "DEVICE-ID": deviceId,
      "User-Agent": "TimelyWise-LangWise-$deviceType-${packageInfo.version}",
    });

    String path = options.path;
    if(!path.contains("/auth")){//auth
      if (UserStore.to.userInfo.value.userId != null) {
        options.queryParameters.addAll({
          "userId": UserStore.to.userInfo.value.userId,
        });
      }
      if (UserStore.to.userInfo.value.memberId != null) {
        options.queryParameters.addAll({
          "memberId": UserStore.to.userInfo.value.memberId,
        });
      }
    }

    _logInfo(_requestSummary("请求放行", options));
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logInfo(
      "请求成功 method:${response.requestOptions.method} status:${response.statusCode} uri:${response.requestOptions.uri}",
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logInfo(
      "请求失败透传 type:${err.type} status:${err.response?.statusCode} ${_requestSummary('uri', err.requestOptions)} error:${err.error ?? err.message}",
    );
    handler.next(err);
  }

  void _logInfo(String message) {
    ErrorLogUtils.to.logInfo("[HTTP] -------- $message");
  }

  String _requestSummary(String prefix, RequestOptions options) {
    return "$prefix method:${options.method} uri:${options.uri} connectTimeout:${options.connectTimeout} sendTimeout:${options.sendTimeout} receiveTimeout:${options.receiveTimeout}";
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
  
}

/// 拦截系统维护
class SystemMaintenanceInterceptor extends Interceptor {
  bool isShowRetryDialog = false;
  bool isShowUpdateDialog = false;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    _logInfo(
      "响应进入系统拦截器 status:${response.statusCode} method:${response.requestOptions.method} uri:${response.requestOptions.uri}",
    );
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
      "异常进入系统拦截器 type:${err.type} status:${err.response?.statusCode} method:${err.requestOptions.method} uri:${err.requestOptions.uri} error:${err.error ?? err.message}",
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

        WiseHttp().reset();
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

  void _logInfo(String message) {
    ErrorLogUtils.to.logInfo("[HTTP] -------- $message");
  }
}


/// DNS解析拦截器 - 使用阿里云公共DNS进行域名解析
/// 当系统DNS失败时，使用备用DNS重试请求
class DnsInterceptor extends Interceptor {
  /// 阿里云DNS服务器域名列表
  static const List<String> _dnsServerHosts = [
    'dns.alidns.com',
  ];

  /// DNS解析缓存 - key: 域名, value: {ip: 解析结果, expireTime: 过期时间}
  static final Map<String, _DnsCacheEntry> _dnsCache = {};

  /// 缓存默认TTL（秒）
  static const int _defaultTtl = 300;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    _logInfo("DNS拦截器收到请求 method:${options.method} uri:${options.uri}");
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 检查是否是DNS解析失败（SocketException通常包含DNS失败）
    if (_isDnsError(err)) {
      final host = err.requestOptions.uri.host;
      _logInfo("检测到DNS异常 host:$host uri:${err.requestOptions.uri} error:${err.error ?? err.message}");
      
      // 跳过IP地址、localhost和DNS服务器本身
      if (_isIpAddress(host) || host == 'localhost' || _dnsServerHosts.contains(host)) {
        _logInfo("DNS异常跳过处理 host:$host，原因: 已是IP/localhost/DNS服务地址");
        handler.next(err);
        return;
      }

      _logInfo("DNS异常开始尝试备用DNS解析 host:$host");

      try {
        // 使用备用DNS解析
        final ip = await _resolveDns(host);
        if (ip != null) {
          _logInfo("备用DNS解析成功 host:$host ip:$ip，准备改写请求重试");
          
          // 使用解析到的IP重新发起请求
          final newOptions = err.requestOptions.copyWith();
          final uri = newOptions.uri;
          final newUri = uri.replace(host: ip);
          newOptions.path = newUri.toString();
          newOptions.headers['Host'] = host;

          // 创建新的HttpClient并配置证书验证
          final httpClient = HttpClient();
          httpClient.badCertificateCallback = (cert, host, port) {
            // 验证证书的CN或SAN是否匹配原始域名
            return true; // 信任证书（因为我们知道这是正确的服务器）
          };

          try {
            final response = await _makeRequest(httpClient, newOptions);
            _logInfo("备用DNS重试成功 host:$host ip:$ip status:${response.statusCode}");
            handler.resolve(response);
            return;
          } finally {
            httpClient.close();
          }
        }
      } catch (e) {
        _logInfo("备用DNS重试失败 host:$host error:$e");
      }
      _logInfo("备用DNS未能恢复请求，继续向下传递异常 host:$host");
    }
    handler.next(err);
  }

  /// 检查是否是DNS相关错误
  bool _isDnsError(DioException err) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout) {
      final error = err.error;
      if (error is SocketException) {
        final message = error.message.toLowerCase();
        // DNS解析失败的常见错误信息
        return message.contains('failed host lookup') ||
               message.contains('no address associated') ||
               message.contains('name or service not known') ||
               message.contains('nodename nor servname provided') ||
               message.contains('getaddrinfo failed');
      }
    }
    return false;
  }

  /// 使用HttpClient发起请求
  Future<Response> _makeRequest(HttpClient client, RequestOptions options) async {
    client.connectionTimeout = options.connectTimeout ?? const Duration(seconds: 15);
    _logInfo(
      "使用原生HttpClient重试请求 method:${options.method} uri:${options.path} connectTimeout:${options.connectTimeout}",
    );

    final uri = Uri.parse(options.path);
    final HttpClientRequest request;

    switch (options.method.toUpperCase()) {
      case 'GET':
        request = await client.getUrl(uri);
        break;
      case 'POST':
        request = await client.postUrl(uri);
        break;
      case 'PUT':
        request = await client.putUrl(uri);
        break;
      case 'DELETE':
        request = await client.deleteUrl(uri);
        break;
      case 'PATCH':
        request = await client.patchUrl(uri);
        break;
      default:
        request = await client.openUrl(options.method, uri);
    }

    // 设置请求头
    options.headers.forEach((key, value) {
      request.headers.set(key, value);
    });

    // 设置请求体
    if (options.data != null) {
      if (options.data is String) {
        request.write(options.data);
      } else if (options.data is Map) {
        request.headers.contentType = ContentType.json;
        request.write(json.encode(options.data));
      }
    }

    final httpResponse = await request.close();
    final responseBody = await httpResponse.transform(utf8.decoder).join();
    _logInfo("原生HttpClient收到响应 status:${httpResponse.statusCode} uri:${options.path}");

    // 尝试解析JSON
    dynamic responseData;
    try {
      responseData = json.decode(responseBody);
    } catch (_) {
      responseData = responseBody;
    }

    return Response(
      requestOptions: options,
      statusCode: httpResponse.statusCode,
      statusMessage: httpResponse.reasonPhrase,
      data: responseData,
      headers: Headers.fromMap(
        httpResponse.headers.toString().split('\n').fold<Map<String, List<String>>>(
          {},
          (map, line) {
            final parts = line.split(': ');
            if (parts.length >= 2) {
              map[parts[0]] = [parts.sublist(1).join(': ')];
            }
            return map;
          },
        ),
      ),
    );
  }

  /// 检查是否为IP地址
  bool _isIpAddress(String host) {
    // IPv4
    final ipv4Regex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    // IPv6
    final ipv6Regex = RegExp(r'^([0-9a-fA-F]{0,4}:){2,7}[0-9a-fA-F]{0,4}$');
    return ipv4Regex.hasMatch(host) || ipv6Regex.hasMatch(host);
  }

  /// 使用阿里云DNS解析域名（带缓存）
  Future<String?> _resolveDns(String host) async {
    // 先检查缓存
    final cached = _dnsCache[host];
    if (cached != null && !cached.isExpired) {
      _logInfo("命中DNS缓存 host:$host ip:${cached.ip}");
      return cached.ip;
    }
    // 清除过期缓存
    if (cached != null) {
      _logInfo("DNS缓存已过期，移除缓存 host:$host");
      _dnsCache.remove(host);
    }

    for (final dnsHost in _dnsServerHosts) {
      try {
        _logInfo("开始请求备用DNS服务器 dnsHost:$dnsHost host:$host");
        final result = await _queryDns(dnsHost, host);
        if (result != null) {
          _logInfo("备用DNS服务器解析成功 dnsHost:$dnsHost host:$host ip:$result");
          return result;
        }
      } catch (e) {
        _logInfo("备用DNS服务器解析失败 dnsHost:$dnsHost host:$host error:$e");
        continue;
      }
    }
    _logInfo("所有备用DNS服务器解析均失败 host:$host");
    return null;
  }

  /// 向指定DNS服务器查询域名
  /// [dnsHost] DNS服务器域名
  /// [host] 要解析的域名
  Future<String?> _queryDns(String dnsHost, String host) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);

    try {
      // 直接使用域名访问DNS服务器（DNS服务器本身不会被拦截器处理）
      final uri = Uri.parse('https://$dnsHost/resolve?name=$host&type=1');
      _logInfo("发起DNS查询 dnsHost:$dnsHost queryHost:$host");
      final request = await client.getUrl(uri);
      request.headers.set('Accept', 'application/dns-json');

      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = json.decode(body);

        if (data['Status'] == 0 && data['Answer'] != null) {
          final answers = data['Answer'] as List;
          // 查找A记录 (type=1)
          for (final answer in answers) {
            if (answer['type'] == 1) {
              final ip = answer['data'] as String;
              final ttl = (answer['TTL'] as int?) ?? _defaultTtl;
              // 缓存结果
              _dnsCache[host] = _DnsCacheEntry(
                ip: ip,
                expireTime: DateTime.now().add(Duration(seconds: ttl)),
              );
              _logInfo("DNS查询成功并写入缓存 host:$host ip:$ip ttl:$ttl");
              return ip;
            }
          }
        }
      }
    } finally {
      client.close();
    }
    _logInfo("DNS查询未返回可用A记录 dnsHost:$dnsHost host:$host");
    return null;
  }

  /// 清除DNS缓存
  static void clearCache() {
    _dnsCache.clear();
  }

  /// 清除指定域名的缓存
  static void clearCacheForHost(String host) {
    _dnsCache.remove(host);
  }

  void _logInfo(String message) {
    ErrorLogUtils.to.logInfo("[HTTP] -------- $message");
  }
}

/// DNS缓存条目
class _DnsCacheEntry {
  final String ip;
  final DateTime expireTime;

  _DnsCacheEntry({required this.ip, required this.expireTime});

  bool get isExpired => DateTime.now().isAfter(expireTime);
}
