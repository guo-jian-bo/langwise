

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lib_common/common.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:umeng_apm_sdk/umeng_apm_sdk.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';

import '../common/values/storage.dart';
import '../config.dart';

class UmengUtils{

  static Future<void> init() async{
    if(Platform.isMacOS || Platform.isWindows || Platform.isLinux) return;
    // 如果没有同意协议则不初始化
    bool agreePrivacy = StorageUtil().getBool(STORAGE_USER_AGREE_PRIVACY_KEY);
    if(!agreePrivacy) return;
    String platform = Platform.isAndroid ? "android" : "ios";
    await UmengCommonSdk.initCommon(Config.umengAndroidAppKey, Config.umengIosAppKey, platform);
    UmengCommonSdk.setPageCollectionModeManual();
  }

  static Future<void> signIn() async{
    
    if(Platform.isMacOS || Platform.isWindows || Platform.isLinux) return;
    // 如果没有同意协议则不执行
    bool agreePrivacy = StorageUtil().getBool(STORAGE_USER_AGREE_PRIVACY_KEY);
    if(!agreePrivacy) return;
    String deviceId = StorageUtil().getString(STORAGE_DEVICE_ID_KEY);
    UmengCommonSdk.onProfileSignIn(deviceId);
  }

  static void signOut() {
    if(Platform.isMacOS || Platform.isWindows || Platform.isLinux) return;
    // 如果没有同意协议则不执行
    bool agreePrivacy = StorageUtil().getBool(STORAGE_USER_AGREE_PRIVACY_KEY);
    if(!agreePrivacy) return;

    UmengCommonSdk.onProfileSignOff();
  }

  static void error(String error) {
    if(Platform.isMacOS || Platform.isWindows || Platform.isLinux) return;
    // 如果没有同意协议则不执行
    bool agreePrivacy = StorageUtil().getBool(STORAGE_USER_AGREE_PRIVACY_KEY);
    if(!agreePrivacy) return;

    UmengCommonSdk.reportError(error);
  }


  static Future<bool> initApm({required FutureOr<Widget> Function(NavigatorObserver? observer) appRunner}) async{

    if(Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return false;
    }

    final UmengApmSdk umengApmSdk = UmengApmSdk(
      name: '',

      bver: '',

      // 是否开启SDK运行时日志输出
      enableLog: true,

      // 您使用的flutter版本，默认为空，为方便定位访问，建议配置
      flutterVersion: '3.27.3',

      engineVersion: 'e672b006cb',

      // 开启监测页面帧率（默认关闭) 版本 v2.1.3 可支持
      enableTrackingPageFps: true,

      // 开启监测页面性能（默认关闭）版本 v2.1.3 可支持
      enableTrackingPagePerf: true,
      

      // 带入继承ApmWidgetsFlutterBinding的覆写和初始化方法, 可用于自定义监听应用生命周期
      // 确保去掉原有的WidgetsFlutterBinding.ensureInitialized() ，以免出现重复初始化绑定的异常造成无法正常初始化，SDK内部已通过initFlutterBinding入参带入继承的WidgetsFlutterBinding实现初始化操作
      initFlutterBinding: ApmWidgetsFlutterBinding.ensureInitialized,

      env: UmengApmEnv.Dev,
      // 抛出异常事件
      onError: (exception, stack) {
        debugPrint('错误 message: $exception , stack: $stack');
      },
    );

    umengApmSdk.init(appRunner: (observer) async {

      // 确保去掉原有的WidgetsFlutterBinding.ensureInitialized() ，以免出现重复初始化绑定的异常造成无法正常初始化，SDK内部已通过initFlutterBinding入参带入继承的WidgetsFlutterBinding实现初始化操作
      // 依赖ensureInitialized()初始化的代码可在此调用
      // 需要异步获取设置应用名称和版本号可在此回调中操作
      // SDK实例化的设置可先将name和bver 为 "",然后通过以下方式进行设置
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String packageName = packageInfo.packageName;
      String buildNumber = packageInfo.buildNumber;
      String version = packageInfo.version;
      umengApmSdk.name = packageName;
      umengApmSdk.bver = '$version+$buildNumber';

      return await appRunner.call(observer);
    });

    return true;
  }

}
