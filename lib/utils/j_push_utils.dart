import 'dart:convert';
import 'dart:io';

import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:jpush_flutter/jpush_interface.dart';
import 'package:langwise/log_widget.dart';
import 'package:lib_common/common.dart';

import '../common/entities/entities.dart';
import '../common/stores/user.dart';
import '../common/values/values.dart';
import '../config.dart';
import 'utils.dart';

class JPushUtils {
  factory JPushUtils() => _getInstance();

  static JPushUtils get instance => _getInstance();

  static JPushUtils? _instance;

  // 单例模式实现
  static JPushUtils _getInstance() {
    _instance ??= JPushUtils._internal();
    return _instance!;
  }

  JPushUtils._internal();

  final JPushFlutterInterface jpush = JPush.newJPush();

  final String EXTRA_EXTRA = "cn.jpush.android.EXTRA";

  Future<void> initJPush() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    // 如果没有同意协议则不初始化
    bool agreePrivacy = StorageUtil().getBool(STORAGE_USER_AGREE_PRIVACY_KEY);
    if (!agreePrivacy) return;

    print("极光推送 开始初始化");

    try {
      jpush.addEventHandler(
        // 接收通知回调方法。
        onReceiveNotification: (Map<String, dynamic> message) async {
          print("极光推送 flutter onReceiveNotification: $message");
        },
        // 点击通知回调方法。
        onOpenNotification: onOpenNotification,
        // 接收自定义消息回调方法。
        onReceiveMessage: (Map<String, dynamic> message) async {
          print("极光推送 flutter onReceiveMessage: $message");
        },
      );

      print("极光推送 设置setAuth");
      jpush.setAuth(enable: true);
      print("极光推送 设置setAuth结束");

      print("极光推送 设置enableAutoWakeup");
      jpush.enableAutoWakeup(enable: true);
      print("极光推送 设置enableAutoWakeup结束");

      print("极光推送 setup");
      String buildType = (StorageUtil().getString(STORAGE_HTTP_ENV_KEY));
      jpush.setup(
        appKey: Config.jPushAppKey,
        channel: Config.jPushChannel,
        production: buildType == HttpEnvKey.pro,
        debug: true, // 设置是否打印 debug 日志
      );
      print("极光推送 setup结束");

      if (Platform.isIOS) {
        print("极光推送 applyPushAuthority");
        int? local = StorageUtil().getInt(PermissionUtils.notificationPermissionKey);
        if (local == null) {
          await StorageUtil().setInt(PermissionUtils.notificationPermissionKey, 1);
          jpush.applyPushAuthority(
            const NotificationSettingsIOS(
              sound: true,
              alert: true,
              badge: true,
            ),
          );
        }

        print("极光推送 applyPushAuthority结束");
      }

      print("极光推送 setBadge");
      jpush.setBadge(0);
      print("极光推送 setBadge结束");
      await setAlias();
    } catch (e) {
      print("极光推送 初始化失败$e");
    }

    getRegistrationID();
  }

  /// 获取注册ID
  Future<String?> getRegistrationID() async {
    if (!Platform.isAndroid && !Platform.isIOS) return null;
    try {
      String id = await jpush.getRegistrationID().then((val) {
        return val;
      });
      print('极光推送 成功获取到RegistrationID: $id'); // 添加日志
      return id;
    } catch (e, stack) {
      print('极光推送 获取RegistrationID失败: $e\n$stack');
      return null;
    }
  }

  /// 获取 iOS 点击推送启动应用的那条通知。
  Future<Map?> getLastNotification() async {
    if (!Platform.isAndroid && !Platform.isIOS) return null;

    return await jpush.getLaunchAppNotification();
  }

  /// 设置别名 登录
  Future<Map?> setAlias() async {
    if (!Platform.isAndroid && !Platform.isIOS) return null;
    Map res = await jpush.setAlias(UserStore.to.userId);
    print("极光推送 设置别名 :$res");
    return res;
  }

  /// 退出登录
  Future<void> logout() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    await jpush.deleteAlias();
  }

  /// 处理通知消息
  Future<void> onOpenNotification(Map<String, dynamic> message) async {
    print("极光推送 收到极光推送的原始: $message");
    LogManager().addLog("极光推送 收到极光推送的原始: $message");
    try {
      final extra = message['extras'];
      if (extra == null || extra is! Map) return;
      if (Platform.isIOS) {
        String? route = extra['code'];
        dynamic params = extra['params'];
        String type = extra['category'] ?? '';
        String module = extra['module'] ?? '';
        if (route == null) return;
        Map? paramsMap = params;
        Map<String, dynamic>? stringKeyMap = paramsMap?.cast<String, dynamic>();
        JumpPageUtils.jumpPage(PushMessageEntity(
          category: type,
          code: route,
          module: module,
          jump: PushMessageEntityJump(
            code: route,
            params: stringKeyMap,
          ),
        ));
      } else if (Platform.isAndroid) {
        Map? extraData = extra[EXTRA_EXTRA];
        if (extraData == null) return;
        String? route = extraData["code"];
        dynamic params = extraData['params'];
        String type = extraData['category'] ?? '';
        String module = extraData['module'] ?? '';
        if (route == null) return;
        Map<String, dynamic>? paramsMap = jsonDecode(params);
        JumpPageUtils.jumpPage(PushMessageEntity(
          category: type,
          module: module,
          code: route,
          jump: PushMessageEntityJump(code: route, params: paramsMap),
        ));
      }
    } catch (e) {
      LogManager().addLog("极光推送 异常 = $e");
    }
  }
}
