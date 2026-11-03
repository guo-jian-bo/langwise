import 'dart:convert';
import 'dart:developer';
import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/user_center/common/create_student_dialog.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/guide_engine/guide_manager.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/common.dart';
import 'package:login_module/http/http_env.dart';
import 'package:login_module/login_helper.dart';

import '../../theme/theme_utils.dart';

class UserStore extends GetxController with UserStoreListenersMixin {
  static UserStore get to => Get.find<UserStore>();

  // accessToken
  final RxString _accessToken = ''.obs;

  String get accessToken => _accessToken.value;

  // refreshToken
  String _refreshToken = '';

  String get refreshToken => _refreshToken;

  bool get isLogin => accessToken.isNotEmpty;

  // 用户 实体信息
  final _profile = AuthSmsLoginResponseEntity().obs;

  AuthSmsLoginResponseEntity get profile {
    if (ObjectUtil.isEmpty(_profile.value.accessToken)) {
      _profile(parseUserInfo() ?? AuthSmsLoginResponseEntity());
    }
    return _profile.value;
  }

  // 用户ID
  String get userId => "${profile.userId ?? ''}";

  final Rx<UserInfoEntity> userInfo = UserInfoEntity().obs;

  /// 用户权限
  final Rx<RolePermissionsEntity> rolePermissions = RolePermissionsEntity().obs;

  @override
  void onInit() {
    super.onInit();
    _profile(parseUserInfo());
    if (kDebugMode) {
      print('---user info:${profile.toJson()}---');
    }
    _accessToken(StorageUtil().getString(STORAGE_USER_TOKEN_KEY));
    _refreshToken = StorageUtil().getString(STORAGE_REFRESH_TOKEN_KEY);
  }

  // 发送验证码
  Future<ResponseEntity<String>> sendSms(String callingCode, String phoneNumber) async {
    return await LoginHelper().sendSms(callingCode: callingCode, phoneNumber: phoneNumber);
  }

  // 登录
  Future<ResponseEntity<AuthSmsLoginResponseEntity<ListEntity<PlatformResponseEntity>>>> onLogin(String code, String callingCode, String phoneNumber, {String? platformId}) async {
    var response = await LoginHelper().smsLogin(code: code, callingCode: callingCode, phoneNumber: phoneNumber, platformId: platformId);
    if (CommonUtil.isSuccess(response.code) && ObjectUtil.isNotEmpty(response.data?.accessToken)) {
      // 缓存loginInfo、token、refreshToken到本地
      await _setUserInfo(response.data!);
      await _setAccessToken(response.data!.accessToken!);
      await _setRefreshToken(response.data!.refreshToken!);
      _cacheTokenExpiredTime(response.data);
    }
    return response;
  }

  // jwt登录
  // 拿到refreshToken, 去重新获取新的accessToken
  Future<void> onRefreshToken() async {
    try {
      if (refreshToken.isEmpty) {
        log('refresh token is null');
        return;
      }
      String deviceId = StorageUtil().getString(STORAGE_DEVICE_ID_KEY);
      var response = await LoginHelper().refreshToken(refreshToken, deviceId);
      if (CommonUtil.isSuccess(response.code) && ObjectUtil.isNotEmpty(response.data?.accessToken)) {
        await _setBeijingTime();
        // 缓存loginInfo、token、refreshToken到本地
        await _setUserInfo(response.data!);
        await _setAccessToken(response.data!.accessToken!);
        await _setRefreshToken(response.data!.refreshToken!);
        isRefreshAccessToken();
      }
    } catch (_) {}
  }

  /// 获取用户信息
  Future<void> getUserInfo({bool showLoading = false, bool isInit = false}) async {
    try {
      if (showLoading) ToastUtils.showLoading();
      final UserInfoEntity? user = await AccountUtil.getUserInfo();
      if (user == null) return;
      userInfo.value = user;
      if (user.memberBirthday == null) {
        if (showLoading) ToastUtils.hideLoading();
        bool res = await CreateStudentDialog.show(Get.context!,
            showCancel: false,
            editData: UserTeamEntityMembers(
              memberId: user.memberId,
              nickname: user.nickname,
              birthday: user.memberBirthday,
              avatarUrl: user.avatarUrl,
              addressCode: user.addressCode,
              address: user.address,
              grade: user.memberGrade.toString(),
            ));
        if (!res) {
          return;
        }else{
        }
      } else {
        if (isInit) {}
      }

      if (user.config?.theme?.isNotEmpty ?? false) {
        ThemeUtils.changeTheme(user.config!.theme!);
      }
    } finally {
      if (showLoading) ToastUtils.hideLoading();
    }
  }

  /// 获取用户权限
  Future<void> getUserRolePermissions() async {
    if (!isLogin) return;
    RolePermissionsEntity? rolePermissionsEntity = await AccountUtil.getUserRolePermissions();
    if (rolePermissionsEntity == null) return;
    rolePermissions.value = rolePermissionsEntity;
    // rolePermissions.value.isAdmin = false;
  }

  /// 踢掉设备
  Future<ResponseEntity<AuthSmsLoginResponseEntity>> removeDeviceList({
    required String platform,
    required String platformId,
    required String platformName,
    required String requestId,
  }) async {
    var response = await LoginHelper().removeDeviceList(platform: platform, platformId: platformId, platformName: platformName, requestId: requestId);
    if (CommonUtil.isSuccess(response.code) && ObjectUtil.isNotEmpty(response.data?.accessToken)) {
      await _setBeijingTime();
      // 缓存loginInfo、token、refreshToken到本地
      await _setUserInfo(response.data!);
      await _setAccessToken(response.data!.accessToken!);
      await _setRefreshToken(response.data!.refreshToken!);
      isRefreshAccessToken();
    }

    return response;
  }

  // 退出登录
  Future<void> onLogout(String phoneNumber) async {
    try {
      String deviceId = StorageUtil().getString(STORAGE_DEVICE_ID_KEY);
      await LoginHelper().logout(
        phoneNumber,
        platformId: deviceId,
        requireToken: true,
        token: accessToken,
        refreshToken: refreshToken,
      );
      JPushUtils.instance.logout();
      await _clearUserInfo();
      await removeRefreshToken();
      await removeAccessToken();
      await StorageUtil().remove(NOT_REMIND_COURSE_KEY);
      await StorageUtil().remove(STORAGE_IAP_PENDING_PURCHASES_KEY);
      await StorageUtil().remove(STORAGE_PARENT_PASSWORD_ERROR_COUNT_KEY);
      await StorageUtil().remove(EXPERIENCE_APP_KEY);
      await StorageUtil().remove(NOT_REMIND_COURSE_KEY);
      await StorageUtil().remove(HOME_REFRESH_DATE_KEY);
      await StorageUtil().remove(STORAGE_LANGUAGE_CODE);
      await StorageUtil().remove(STORAGE_PARENT_PASSWORD_FREE_KEY);
      userInfo.value = UserInfoEntity();
    } catch (e) {
      print("退出登录异常 $e");
    }
  }

  // 解析磁盘数据到内存
  AuthSmsLoginResponseEntity? parseUserInfo() {
    AuthSmsLoginResponseEntity? userInfoData;
    final String env = getEnv();
    if (kDebugMode) {
      print(" >>>>> env = $env");
    }
    try {
      final String userInfo = StorageUtil().getString(STORAGE_USER_INFO_KEY + "_" + env);
      if (kDebugMode) {
        print(" >>>>> userInfo = $userInfo");
      }
      if (ObjectUtil.isNotEmpty(userInfo)) {
        final Map<String, dynamic> map = jsonDecode(userInfo);
        if (kDebugMode) {
          print("parse user info map = $map");
        }
        userInfoData = AuthSmsLoginResponseEntity.fromJson(map);
      }
      if (userInfoData?.platformId != null) {
        String deviceId = StorageUtil().getString(STORAGE_DEVICE_ID_KEY);
        if (deviceId.isEmpty) {
          StorageUtil().setString(STORAGE_DEVICE_ID_KEY, userInfoData!.platformId!);
        }
      }

      return userInfoData;
    } catch (e) {
      if (kDebugMode) {
        print("init get user info err = $e");
      }
    }
    return null;
  }

  // 外部刷新数据
  void setUserInfo(AuthSmsLoginResponseEntity data, {bool notify = true, bool save = true}) async {
    _profile(data);
    if (save) {
      await _setBeijingTime();
      // 缓存loginInfo、token、refreshToken到本地
      await _setUserInfo(data);
      await _setAccessToken(data.accessToken!);
      await _setRefreshToken(data.refreshToken!);
      isRefreshAccessToken();
    }
    if (notify) {
      notifyListeners();
    }
  }

  /// 缓存token过期时间
  void _cacheTokenExpiredTime(AuthSmsLoginResponseEntity? data) {
    if (data == null) return;
    if (data.refreshTokenExpired != null) {
      StorageUtil().setString(STORAGE_REFRESH_TOKEN_EXPIRED_KEY, data.refreshTokenExpired!);
    }
    if (data.accessTokenExpired != null) {
      StorageUtil().setString(STORAGE_ACCESS_TOKEN_EXPIRED_KEY, data.accessTokenExpired!);
    }
  }

  // 保存 token
  Future<void> _setAccessToken(String value) async {
    _accessToken(value);
    await StorageUtil().setString(STORAGE_USER_TOKEN_KEY, value);
  }

  // 移除 access_token
  Future<void> removeAccessToken() async {
    _accessToken('');
    await StorageUtil().remove(STORAGE_USER_TOKEN_KEY);
  }

  // 保存 refreshToken
  Future<void> _setRefreshToken(String value) async {
    _refreshToken = value;
    await StorageUtil().setString(STORAGE_REFRESH_TOKEN_KEY, value);
  }

  // 移除 refreshToken
  Future<void> removeRefreshToken() async {
    _refreshToken = '';
    await StorageUtil().remove(STORAGE_REFRESH_TOKEN_KEY);
  }

  // 保存 userInfo
  Future<void> _setUserInfo(AuthSmsLoginResponseEntity value) async {
    final String env = getEnv();
    if (kDebugMode) {
      print(" >>>>> env = $env");
    }
    _profile(value);
    if (profile.platformId != null) {
      String deviceId = StorageUtil().getString(STORAGE_DEVICE_ID_KEY);
      if (deviceId.isEmpty) {
        StorageUtil().setString(STORAGE_DEVICE_ID_KEY, profile.platformId!);
      }
    }
    await StorageUtil().setString(STORAGE_USER_INFO_KEY + "_" + env, jsonEncode(value));
  }

  // 保存 刷新token后的北京时间
  Future<void> _setBeijingTime() async {
    var beijingTime = DateFormatUtil.getBeijingTime();
    await StorageUtil().setString(LoginConstant.KEY_LAST_REFRESH_TOKEN, beijingTime);
  }

  // 清除用户信息
  Future<void> clearUserInfo() async {
    await _clearUserInfo();
    await removeRefreshToken();
    await removeAccessToken();
  }

  Future<void> _clearUserInfo() async {
    _profile(AuthSmsLoginResponseEntity());
    final String env = getEnv();
    await StorageUtil().remove(STORAGE_USER_INFO_KEY + "_" + env);
  }

  String getEnv() {
    return StorageUtil().getString(STORAGE_HTTP_ENV_KEY);
  }

  HttpEnv getHttpEnv() {
    String dev = getEnv();
    if (dev == HttpEnvKey.dev) {
      // return const HttpEnv('dev', 'http://192.168.58.63:8018', LoginConstant.devAppId, LoginConstant.devAppSecret);
      return const HttpEnv('dev', 'https://api-demo.timelywise.cn', LoginConstant.devAppId, LoginConstant.devAppSecret);
    } else if (dev == HttpEnvKey.beta) {
      return const HttpEnv('beta', 'https://api-beta-test.timelywise.cn', LoginConstant.proAppId, LoginConstant.proAppSecret);
    } else {
      return const HttpEnv('pro', 'https://api-lw.timelywise.cn', LoginConstant.proAppId, LoginConstant.proAppSecret);
    }
  }

  /// 判断是否需要刷新token
  /// 一天刷新一次
  ///
  bool isRefreshAccessToken() {
    if (!isLogin) return false;
    var userInfo = _profile.value;
    if (ObjectUtil.isNotEmpty(userInfo.refreshToken)) {
      /// 获取上次请求时的东八区时间
      var lastRefreshTime = StorageUtil().getString(LoginConstant.KEY_LAST_REFRESH_TOKEN);
      var todayState = DateFormatUtil.getTodayState(lastRefreshTime, offset: const Duration(hours: 8));
      if (todayState != 0) {
        return true;
      }
    }
    return false;
  }

  // 是否首次登陆过(默认false)
  bool get hasLoggedInBefore {
    return StorageUtil().getBool(STORAGE_USER_FIRST_LOGIN_KEY);
  }

  // 设置用户首次登陆
  Future<bool> setHasLoggedInBefore(bool value) async {
    return await StorageUtil().setBool(STORAGE_USER_FIRST_LOGIN_KEY, value);
  }
}

mixin UserStoreListenersMixin {
  final ObserverList<VoidCallback> _listeners = ObserverList<VoidCallback>();

  void registerListener(VoidCallback listener) {
    log("userinfo store add listener = $listener");
    _listeners.add(listener);
  }

  void unRegisterListener(VoidCallback listener) {
    final bool removed = _listeners.remove(listener);
    log("userinfo store remove listener = $listener, removed: $removed");
  }

  void clearListeners() {
    _listeners.clear();
  }

  void notifyListeners() {
    final List<VoidCallback> localListeners = _listeners.toList(growable: false);
    for (final VoidCallback listener in localListeners) {
      if (_listeners.contains(listener)) {
        log("通知刷新");
        listener();
      }
    }
  }
}
