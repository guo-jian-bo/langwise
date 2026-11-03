

import 'dart:async';

import 'package:api/api.dart';
import 'package:get/get.dart' as getx;
import 'package:lib_common/common.dart';
import 'package:login_module/http/http_env.dart';
import 'package:login_module/http/request_model.dart';
import 'package:login_module/login_helper.dart';
import 'package:wise_http/wise_http.dart';

import '../../app/routes/routes.dart';
import '../../common/stores/stores.dart';
import '../../common/values/values.dart';
import '../utils.dart';
import 'dio_interceptor_utils.dart';

// class RequestAuthInterceptorUtils{

//   static Future<AuthInterceptor> auth() async {

//     String buildType = StorageUtil().getString(STORAGE_HTTP_ENV_KEY);
//     if (buildType.isEmpty) buildType = HttpEnvKey.pro;
//     await StorageUtil().setString(STORAGE_HTTP_ENV_KEY, buildType);
//     _logHttpInit("当前HTTP环境:$buildType");

//     final HttpEnv httpEnv = UserStore.to.getHttpEnv();
//     _logHttpInit("HTTP配置读取完成，host:${httpEnv.host}");

//     await LoginHelper().init(httpEnv);
//     _logHttpInit("LoginHelper初始化完成");

//     String deviceId = StorageUtil().getString(STORAGE_DEVICE_ID_KEY);
//     final Uri? hostUri = Uri.tryParse(httpEnv.host);
//     _logHttpInit(
//       "初始化上下文 env:$buildType scheme:${hostUri?.scheme} host:${hostUri?.host} port:${hostUri?.hasPort == true ? hostUri?.port : 443} deviceIdEmpty:${deviceId.isEmpty} deviceIdLength:${deviceId.length} accessTokenEmpty:${UserStore.to.accessToken.isEmpty} refreshTokenEmpty:${UserStore.to.refreshToken.isEmpty} currentRoute:${getx.Get.currentRoute}",
//     );

//     return AuthInterceptor(
//       config: AuthConfig(
//         refreshUrl: Model.refreshToken,
//         request: RefreshRequest(
//           platform: LoginHelper().getPlatform(),
//           platformName: LoginHelper().getPlatformName(),
//           platformId: deviceId,
//           refreshToken: UserStore.to.refreshToken,
//         ),
//         onFetchHeader: () async {
//           var seconds = await GeneralUtil.getSyncDate();
//           final signature = SignatureUtil.generateSignature(httpEnv.appId, httpEnv.appSecret, seconds);
//           return {'APP-SIGNATURE': '$seconds;$signature'};
//         },
//         onFetchAccessToken: () => UserStore.to.accessToken,
//         onAuthSucceed: (dynamic response) async {
//           _logHttpInit("HTTP鉴权成功，收到新的登录态数据");
//           // 更新本地token
//           final userInfo = ResponseEntity<AuthSmsLoginResponseEntity>.fromJson(
//             response,
//             fromJson: (json) => AuthSmsLoginResponseEntity.fromJson(json),
//           );
//           if (userInfo.data != null) {
//             _logHttpInit("HTTP鉴权成功，开始更新本地用户信息和token");
//             UserStore.to.setUserInfo(userInfo.data!);
//             _logHttpInit("HTTP鉴权成功，本地用户信息和token更新完成");
//           } else {
//             _logHttpInit("HTTP鉴权成功但返回数据为空，清理登录态并准备跳转登录页");
//             await UserStore.to.clearUserInfo();
//             if (getx.Get.currentRoute != Routes.SIGN_IN_UP) {
//               _logHttpInit("当前不在登录页，跳转到登录页:${Routes.SIGN_IN_UP}");
//               getx.Get.offAllNamed(Routes.SIGN_IN_UP);
//             }
//           }
          
//         },
//         onAuthError: (err) async {
//           _logHttpInit("HTTP鉴权失败，准备清理登录态，error:${err.message}");
//           _logHttpInitError("HTTP鉴权失败 stack:${err.stackTrace}", err.stackTrace);
//           await UserStore.to.clearUserInfo();
//           if (getx.Get.currentRoute != Routes.SIGN_IN_UP) {
//             _logHttpInit("HTTP鉴权失败，跳转到登录页:${Routes.SIGN_IN_UP}");
//             getx.Get.offAllNamed(Routes.SIGN_IN_UP);
//           }
//         },
//       ),
//     );
//   }

//   static void _logHttpInit(String message) {
//     final log = "[HTTP][INIT] $message";
//     print(log);
//     ErrorLogUtils.to.logInfo(log);
//   }

//   static void _logHttpInitError(String message, [StackTrace? stackTrace]) {
//     final log = "[HTTP][INIT][ERROR] $message";
//     print(log);
//     ErrorLogUtils.to.logError(log, stackTrace);
//   }

// }


/// 标记当前 401 错误已经进入“待重试”状态，供重试拦截器识别。
const String _authRetryPendingExtraKey = '_wise_http_auth_retry_pending';

/// 标记当前请求已经完成过一次 401 重试，避免循环刷新/循环重放。
const String _authRetryAttemptedExtraKey = '_wise_http_auth_retry_attempted';

/// 401 等待队列上限，避免刷新接口异常时无限堆积请求。
const int _maxPendingAuthRequests = 100;

/// 在请求上下文里存放刷新后 accessToken 的 key。
const String _accessTokenExtraKey = 'accessToken';

/// 负责给请求加 token，并在 401 时串行刷新 token。
class RequestAuthInterceptor extends QueuedInterceptorsWrapper {

  /// 绑定主请求使用的 Dio，保证刷新 token 时尽量继承原网络配置。
  Dio? _boundDio;

  /// 保存外部主 Dio，供刷新 token 时复用 adapter / transformer。
  void bindDio(Dio dio) {
    _boundDio = dio;
  }

  /// 在网络层重置时清空等待中的鉴权状态，避免旧请求继续干扰新连接。
  void resetState() {
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      _refreshCompleter!.completeError(StateError('WiseHttp reset'));
    }
    _refreshCompleter = null;
    _requestQueue.clear();
    _boundDio = null;
  }

  /// 存储等待刷新完成后再继续处理的 401 请求。
  final List<({DioException err, ErrorInterceptorHandler handler})> _requestQueue = <({DioException err, ErrorInterceptorHandler handler})>[];

  /// 当前是否已经有一个刷新 token 的任务在执行。
  Completer<RefreshResult?>? _refreshCompleter;

  /// 判断当前请求是否已经做过一次认证重试，避免死循环。
  bool _hasRetried(RequestOptions options) => options.extra[_authRetryAttemptedExtraKey] == true;

  /// 将 401 失败请求放入等待队列。
  ///
  /// 当队列超过阈值时直接失败，避免刷新接口异常时请求无限堆积。
  bool _enqueueFailedRequest(DioException err, ErrorInterceptorHandler handler) {
    // 队列已满时直接拒绝，避免内存上涨和大量请求堆积。
    if (_requestQueue.length >= _maxPendingAuthRequests) {
      handler.reject(err.copyWith(message: 'Too many pending auth requests, skip token refresh retry.'));
      return false;
    }
    _requestQueue.add((err: err, handler: handler));
    return true;
  }

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 显式标记不需要 token 的请求直接放行。
    if (options.extra['require-token'] == 'false') {
      return handler.next(options);
    }

    // 为所有需要鉴权的请求补充 Authorization。
    final token = DioInterceptorUtils.getAccessToken(options.path);
    options.headers.addAll({'Authorization': 'Bearer $token'});
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 响应不做额外处理，直接透传。
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 没有响应对象通常是网络层错误，这里不参与 token 刷新，继续向下传递。
    if (err.response == null) return handler.next(err);

    if (err.response?.statusCode == 401) {
      // 已经重试过一次仍然 401，就不要再次刷新了，避免死循环。
      if (_hasRetried(err.requestOptions)) {
        return handler.next(err);
      }

      // 先入队，后续等刷新结果统一处理。
      if (!_enqueueFailedRequest(err, handler)) return;

      try {
        // 同一时刻只允许一个刷新任务执行，其他请求等待同一个 future。
        final RefreshResult? result = await _refreshTokenOnce(err);
        if (result?.accessToken != null) {
          // 刷新成功，批量恢复队列中的 401 请求。
          _processRequestQueue(newAccessToken: result!.accessToken);
        } else {
          throw StateError('Token refresh failed');
        }
      } catch (_) {
        // 刷新失败，统一让等待中的请求失败返回。
        _processRequestQueue(errorMessage: 'Token refresh failed');
      }
      return;
    }

    // 非 401 错误不做认证层处理。
    return handler.next(err);
  }

  /// 串行刷新 token。
  ///
  /// 如果已经有刷新任务在执行，后续请求直接等待同一个 future。
  Future<RefreshResult?> _refreshTokenOnce(DioException err) async {
    if (_refreshCompleter != null) return _refreshCompleter!.future;

    RefreshResult? result;
    _refreshCompleter = Completer<RefreshResult?>();
    try {
      result = await _refreshToken(err);
      if (result?.accessToken != null) {
        // 刷新成功后通知业务侧持久化新的 token。
        onAuthSucceed(result!.response);
        _refreshCompleter!.complete(result);
      } else {
        throw StateError('Token refresh failed');
      }
    } catch (e) {
      result = null;
      // 刷新失败后回调业务侧，比如触发退出登录。
      onAuthError(err);
      _refreshCompleter!.completeError(e);
    } finally {
      // 本轮刷新结束后清空 completer，下次 401 才会重新发起刷新。
      _refreshCompleter = null;
    }

    return result;
  }

  Future<void> onAuthError(DioException err) async{
    _logHttpInit("HTTP鉴权失败，准备清理登录态，error:${err.message}");
    _logHttpInitError("HTTP鉴权失败 stack:${err.stackTrace}", err.stackTrace);
    await UserStore.to.clearUserInfo();
    if (getx.Get.currentRoute != Routes.SIGN_IN_UP) {
      _logHttpInit("HTTP鉴权失败，跳转到登录页:${Routes.SIGN_IN_UP}");
      getx.Get.offAllNamed(Routes.SIGN_IN_UP);
    }
  }

  Future<void> onAuthSucceed(dynamic response) async{
    _logHttpInit("HTTP鉴权成功，收到新的登录态数据");
    // 更新本地token
    final userInfo = ResponseEntity<AuthSmsLoginResponseEntity>.fromJson(
      response,
      fromJson: (json) => AuthSmsLoginResponseEntity.fromJson(json),
    );
    if (userInfo.data != null) {
      _logHttpInit("HTTP鉴权成功，开始更新本地用户信息和token");
      UserStore.to.setUserInfo(userInfo.data!);
      _logHttpInit("HTTP鉴权成功，本地用户信息和token更新完成");
    } else {
      _logHttpInit("HTTP鉴权成功但返回数据为空，清理登录态并准备跳转登录页");
      await UserStore.to.clearUserInfo();
      if (getx.Get.currentRoute != Routes.SIGN_IN_UP) {
        _logHttpInit("当前不在登录页，跳转到登录页:${Routes.SIGN_IN_UP}");
        getx.Get.offAllNamed(Routes.SIGN_IN_UP);
      }
    }
  }

  Future<Map<String, dynamic>> onFetchHeader() async{
    final HttpEnv httpEnv = UserStore.to.getHttpEnv();
    var seconds = await GeneralUtil.getSyncDate();
    final signature = SignatureUtil.generateSignature(httpEnv.appId, httpEnv.appSecret, seconds);
    return {'APP-SIGNATURE': '$seconds;$signature'};
  }

  /// 调用刷新 token 接口。
  ///
  /// 这里会尽量继承原请求所在 Dio 的网络层配置，避免刷新链路与主链路行为不一致。
  Future<RefreshResult?> _refreshToken(DioException err) async {
    try {
      final tokenDio = _createDerivedDio(err.requestOptions, sourceDio: _boundDio);
      final Map<String, dynamic> rawHeader = Map<String, dynamic>.from(err.requestOptions.headers);

      // 动态 header 最后追加，便于覆盖前面的同名字段。
      final hd = await onFetchHeader();
      if (hd.isNotEmpty) rawHeader.addAll(hd);

      String deviceId = StorageUtil().getString(STORAGE_DEVICE_ID_KEY);

      final response = await tokenDio.fetch(
        RequestOptions(
          baseUrl: err.requestOptions.baseUrl,
          path: Model.refreshToken,
          method: Method.post,
          data: {
            "platform": LoginHelper().getPlatform(),
            "platformName": LoginHelper().getPlatformName(),
            "platformId": deviceId,
            "refreshToken": UserStore.to.refreshToken,
          },
          headers: rawHeader,
        ),
      );

      // 刷新接口必须返回 2xx，其他状态都按失败处理。
      if (response.statusCode == null || response.statusCode! ~/ 100 != 2) {
        throw DioException(requestOptions: response.requestOptions);
      }

      String? accessToken;
      final responseData = response.data;

      // 兼容现有返回结构：从 data.accessToken 中提取新 token。
      if (responseData is Map && responseData['data'] is Map) {
        final dynamic newData = responseData['data'];
        if (newData is Map && newData.containsKey('accessToken') && newData['accessToken'] != null) {
          accessToken = newData['accessToken'].toString();
        }
      }

      return RefreshResult(accessToken: accessToken, response: response.data);
    } on DioException {
      rethrow;
    } catch (_) {
      return null;
    }
  }

  /// 统一处理等待队列中的 401 请求。
  ///
  /// 刷新成功时给每个请求补上新 token 和重试标记；
  /// 刷新失败时统一 reject，保持现有调用方的异常接收方式不变。
  void _processRequestQueue({String? newAccessToken, String? errorMessage}) {
    final List<({DioException err, ErrorInterceptorHandler handler})> oldState = [..._requestQueue];
    _requestQueue.clear();

    if (newAccessToken != null) {
      for (final ({DioException err, ErrorInterceptorHandler handler}) element in oldState) {
        // 只补充认证重试相关字段，不覆盖原 extra，保留业务上下文。
        final extra = Map<String, dynamic>.from(element.err.requestOptions.extra);
        extra[_accessTokenExtraKey] = newAccessToken;
        extra[_authRetryPendingExtraKey] = true;
        element.err.requestOptions.extra = extra;
        element.handler.next(element.err);
      }
      return;
    }

    for (final ({DioException err, ErrorInterceptorHandler handler}) element in oldState) {
      element.handler.reject(
        element.err.copyWith(
          message: errorMessage ?? 'Token refresh failed',
        ),
      );
    }
  }


  /// 基于原请求配置派生一个新的 Dio。
  ///
  /// 这样做的目的是让“刷新 token / 重放原请求”尽量继承原始网络配置，
  /// 减少和主请求链路之间的行为差异。
  Dio _createDerivedDio(RequestOptions requestOptions, {Dio? sourceDio}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: requestOptions.baseUrl,
        method: requestOptions.method,
        connectTimeout: requestOptions.connectTimeout,
        sendTimeout: requestOptions.sendTimeout,
        receiveTimeout: requestOptions.receiveTimeout,
        headers: Map<String, dynamic>.from(requestOptions.headers),
        extra: Map<String, dynamic>.from(requestOptions.extra),
        queryParameters: Map<String, dynamic>.from(requestOptions.queryParameters),
        contentType: requestOptions.contentType,
        responseType: requestOptions.responseType,
        followRedirects: requestOptions.followRedirects,
        receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
        validateStatus: requestOptions.validateStatus,
        persistentConnection: requestOptions.persistentConnection,
        maxRedirects: requestOptions.maxRedirects,
        listFormat: requestOptions.listFormat,
      ),
    );

    // 如果外部主 Dio 可用，则复用其 transformer，避免把旧连接池状态带到新请求里。
    if (sourceDio != null) {
      dio.transformer = sourceDio.transformer;
    }
    return dio;
  }


  static void _logHttpInit(String message) {
    final log = "[HTTP][INIT] $message";
    print(log);
    ErrorLogUtils.to.logInfo(log);
  }

  static void _logHttpInitError(String message, [StackTrace? stackTrace]) {
    final log = "[HTTP][INIT][ERROR] $message";
    print(log);
    ErrorLogUtils.to.logError(log, stackTrace);
  }


}
