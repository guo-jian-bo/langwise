import 'dart:io';

class PlatformUtils{

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

}