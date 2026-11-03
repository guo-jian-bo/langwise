import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class PlatformUtils{

  static const int _lowEndAndroidSdkInt = 29;

  static String getPlatformEnum(){
    if(Platform.isAndroid){
      return "ANDROID";
    }else if(Platform.isIOS){
      return "IOS";
    }else if(Platform.isMacOS){
      return "MACOS";
    }else if(Platform.isWindows){
      return "WINDOWS";
    }else if(Platform.isLinux){
      return "LINUX";
    }else if(Platform.isFuchsia){
      return "FUCHSIA";
    }else {
      return "OTHER";
    }
  }

  static Future<bool> shouldReduceAndroidQuizPreload() async {
    if (!Platform.isAndroid) return false;
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt <= _lowEndAndroidSdkInt;
    } catch (_) {
      return false;
    }
  }

}
