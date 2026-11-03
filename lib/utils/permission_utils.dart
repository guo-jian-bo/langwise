import 'dart:async';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permissions_macos_plugin/permissions_macos_plugin.dart';
import 'package:lib_common/common.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../theme/theme.dart';

class PermissionUtils {

  // 通知权限状态存储键名
  static const String notificationPermissionKey = 'notification_permission_status';

  // 麦克风权限状态存储键名
  static const String _microphonePermissionKey = 'microphone_permission_status';

  // 相机权限状态存储键名
  static const String _cameraPermissionKey = 'camera_permission_status';

  // 相册权限状态存储键名
  static const String _photosPermissionKey = 'photos_permission_status';

  /// 保存相册权限状态存储键名
  static const String _savePhotosPermissionKey = 'save_photos_permission_status';

  /// 安装权限状态
  static const String _installPermissionKey = 'install_permission_status';

  /// 定位权限状态
  static const String _locationPermissionKey = 'location_permission_status';

  /// 清除所有权限记录，应用将被视为首次运行
  /// 可以在main函数中调用该方法进行权限测试
  static Future<void> clearAllPermissions() async {
    print('清除所有权限记录');
    final StorageUtil storage = StorageUtil();

    // 清除应用内部所有权限状态记录
    await storage.remove(notificationPermissionKey);
    await storage.remove(_microphonePermissionKey);
    await storage.remove(_cameraPermissionKey);
    await storage.remove(_photosPermissionKey);
    await storage.remove(_locationPermissionKey);

    print('已清除所有权限记录，下次请求权限时将视为首次请求');
  }


  //定位权限检查
  static Future<bool> location(BuildContext context) async {

    final int? permissionState = StorageUtil().getInt(_locationPermissionKey);
    if(permissionState == null && Platform.isAndroid){// 代表没有请求过权限 弹窗提醒 
      bool ask = await showDescribrDialog( 
        context: context,
        title: "请求定位权限",
        content: "用于统计教材使用的城市",
        define: "去授权",
      );
      if(!ask) return false;
    }
    await StorageUtil().setInt(_locationPermissionKey, 1);

    // 检查位置服务是否启用
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // 位置权限被拒绝
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    //位置权限被永久拒绝
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }
  
  /// 通知权限请求与检查
  /// * windwos 直接返回true，不需要请求权限
  /// * macos 等不了授权还是拒绝 注意处理逻辑
  /// * Android和ios请求之前先弹窗说明用途
  static Future<bool> notification(BuildContext context, {bool isCheck = true}) async {
    if(Platform.isWindows || Platform.isLinux) return true;
    // await StorageUtil().remove(notificationPermissionKey);
    int? local = StorageUtil().getInt(notificationPermissionKey);

    if(Platform.isAndroid && local == null){
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      await StorageUtil().setInt(notificationPermissionKey, 1);
      if(sdkInt < 33) return true; // Android 13 以下无需请求
    }
    
    if(local == null){
      if(Platform.isIOS){
        await StorageUtil().setInt(notificationPermissionKey, 1);
        return false;
      }
      bool ask = await showDescribrDialog( 
        context: context,
        title: "请求通知权限",
        content: "用于发送学习提醒和其他重要通知",
        define: "去授权",
      );
      if(!ask) return false;
    }
    await StorageUtil().setInt(notificationPermissionKey, 1);
    
    PermissionStatus status = PermissionStatus.restricted;
    if(Platform.isMacOS){
      final macStatus = await PermissionsMacosPlugin.requestNotification();
      status = macStatus == PermissionsMacosPluginStatus.granted ? PermissionStatus.granted : PermissionStatus.denied;
    } else{ 
      status = await Permission.notification.request();
    }
    
    if(status.isGranted) return true;
    
    if(local != null && isCheck){
      bool ask = await showDescribrDialog(
        context: context,
        title: "请求通知权限",
        content: "用于发送学习提醒和其他重要通知",
      );
      if(!ask) return false;
      _openAppPermissionSettings("notification");
      return false;
    }
    return false;
  }

  /// 检查麦克风权限
  static Future<bool> microphone(BuildContext context) async {
    if(Platform.isLinux) return true; // 直接返回true，不请求权限

    final int? permissionState = StorageUtil().getInt(_microphonePermissionKey);
    if(permissionState == null && Platform.isAndroid){// 代表没有请求过权限 弹窗提醒 
    
      bool ask = await showDescribrDialog( 
        context: context,
        title: "请求麦克风权限",
        content: "用于语音评测、口语练习和音频录制",
        define: "去授权",
      );
      if(!ask) return false;
    }
    await StorageUtil().setInt(_microphonePermissionKey, 1);
    // 代表请求过权限 先检查权限
    PermissionStatus status = PermissionStatus.restricted;
    if(Platform.isMacOS){
      final macStatus = await PermissionsMacosPlugin.requestMicrophone();
      status = macStatus == PermissionsMacosPluginStatus.granted ? PermissionStatus.granted : PermissionStatus.denied;
    } else{ 
      status = await Permission.microphone.status; //这里是检查状态 但是ios在首次调用权限api的时候会请求权限
    }
    
    if(status.isGranted) return true;
    status = await Permission.microphone.request();
    if(status.isGranted) return true;
    if(permissionState != null){// 说明不是第一次请求 提示
      bool ask = await showDescribrDialog(
        context: context,
        title: "请求麦克风权限",
        content: "用于语音评测、口语练习和音频录制",
      );
      if(!ask) return false;
      _openAppPermissionSettings("microphone");
      return false;
    }
    return false;

  }

  // 相机权限检查
  static Future<bool> camera(BuildContext context) async {
    if(Platform.isWindows || Platform.isLinux) return true; // 直接返回true，不请求权限
    
    final int? permissionState = StorageUtil().getInt(_cameraPermissionKey);
    if(permissionState == null && Platform.isAndroid){// 代表没有请求过权限 弹窗提醒 
      bool ask = await showDescribrDialog( 
        context: context,
        title: "请求相机权限",
        content: "用于拍摄用户头像、课程封面、教材封面、写作任务上传图片等。",
        define: "去授权",
      );
      if(!ask) return false;
    }
    await StorageUtil().setInt(_cameraPermissionKey, 1);
    // 代表请求过权限 先检查权限
    PermissionStatus status = PermissionStatus.restricted;
    if(Platform.isMacOS){
      final macStatus = await PermissionsMacosPlugin.requestCamera();
      status = macStatus == PermissionsMacosPluginStatus.granted ? PermissionStatus.granted : PermissionStatus.denied;
    } else{ 
      status = await Permission.camera.status; //这里是检查状态 但是ios在首次调用权限api的时候会请求权限
    }
    
    if(status.isGranted) return true;
    status = await Permission.camera.request();
    if(status.isGranted) return true;
    if(permissionState != null){// 说明不是第一次请求 提示
      bool ask = await showDescribrDialog(
        context: context,
        title: "请求相机权限",
        content: "用于拍摄用户头像、课程封面、教材封面、写作任务上传图片等。",
      );
      if(!ask) return false;
      _openAppPermissionSettings("camera");
      return false;
    }
    return false;
  }

  /// 保存相册权限检查
  static Future<bool> savePhoto(BuildContext context) async{
    if(Platform.isWindows || Platform.isLinux || Platform.isMacOS) return true; // 直接返回true，不请求权限
    
    final int? permissionState = StorageUtil().getInt(_savePhotosPermissionKey);
    if(permissionState == null && Platform.isAndroid){// 代表没有请求过权限 弹窗提醒 
      bool ask = await showDescribrDialog( 
        context: context,
        title: "请求相册权限",
        content: "用于保存分享海报",
        define: "去授权",
      );
      if(!ask) return false;
    }
    await StorageUtil().setInt(_savePhotosPermissionKey, 1);
    // 代表请求过权限 先检查权限
    PermissionStatus status = PermissionStatus.restricted;
    if(Platform.isIOS){
       status = await Permission.photosAddOnly.status;
    } else{ 
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt <= 32) {
          status = await Permission.storage.status;
        }  else {
          status = await Permission.photos.status;
        }
      }else{
        status = await Permission.photosAddOnly.status; //这里是检查状态 但是ios在首次调用权限api的时候会请求权限
      }
    }
    
    if(status.isGranted) return true;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        status = await Permission.storage.request();
      }  else {
        status = await Permission.photos.request();
      }
    }else{
      status = await Permission.photosAddOnly.request();
    }
    
    if(status.isGranted) return true;
    if(permissionState != null){// 说明不是第一次请求 提示
      bool ask = await showDescribrDialog(
        context: context,
        title: "请求相册权限",
        content: "用于保存分享海报",
      );
      if(!ask) return false;
      _openAppPermissionSettings("photos");
      return false;
    }
    return false;
  }







  

  // 相册读取权限检查
  static Future<bool> photos(BuildContext context) async {
    if(Platform.isWindows || Platform.isLinux) return true; // 直接返回true，不请求权限
    final int? permissionState = StorageUtil().getInt(_photosPermissionKey);

    if(permissionState == null && Platform.isAndroid){// 代表没有请求过权限 弹窗提醒 
      bool ask = await showDescribrDialog( 
        context: context,
        title: "请求相册权限",
        content: "用于选择用户头像、课程封面、教材封面图片",
        define: "去授权",
      );
      if(!ask) return false;
    }
    await StorageUtil().setInt(_photosPermissionKey, 1);
    // 代表请求过权限 先检查权限
    PermissionStatus status = PermissionStatus.restricted;
    if(Platform.isMacOS){
      final macStatus = await PermissionsMacosPlugin.requestCamera();
      status = macStatus == PermissionsMacosPluginStatus.granted ? PermissionStatus.granted : PermissionStatus.denied;
    } else{ 
      status = await Permission.camera.status; //这里是检查状态 但是ios在首次调用权限api的时候会请求权限
      if(Platform.isAndroid){
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        if(sdkInt >= 33){// Android 13+ (API 33+) 使用READ_MEDIA_IMAGES权限
          status = await Permission.photos.status;
        }else{ 
          status = await Permission.storage.status;
        }
      }else{
        status = await Permission.photos.status;
      }
    }
    
    if(status.isGranted || status.isLimited) return true;

    if(Platform.isAndroid){
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      if(sdkInt >= 33){// Android 13+ (API 33+) 使用READ_MEDIA_IMAGES权限
        status = await Permission.photos.request();
      }else{ 
        status = await Permission.storage.request();
      }
    }else{
      status = await Permission.photos.request();
    }

    if(status.isGranted || status.isLimited) return true;
    if(permissionState != null){// 说明不是第一次请求 提示
      bool ask = await showDescribrDialog(
        context: context,
        title: "请求相册权限",
        content: "用于选择用户头像、课程封面、教材封面图片",
      );
      if(!ask) return false;
      _openAppPermissionSettings("photos");
      return false;
    }
    return false;
  }

  /// 检查安卓安装权限
  static Future<bool> reqandroidInstallPermission(BuildContext context) async{
    if (!Platform.isAndroid) return true;
    
    final int? permissionState = StorageUtil().getInt(_installPermissionKey);

    if(permissionState == null && Platform.isAndroid){// 代表没有请求过权限 弹窗提醒 
      bool ask = await showDescribrDialog( 
        context: context,
        title: "请求安装应用权限",
        content: "用于应用新版本的安装",
        define: "去授权",
      );
      if(!ask) return false;
    }
    await StorageUtil().setInt(_installPermissionKey, 1);
    PermissionStatus status = await Permission.requestInstallPackages.status;
    if(status.isGranted) return true;

    status = await Permission.requestInstallPackages.request();

    if(status.isGranted) return true;

    if(permissionState != null){// 说明不是第一次请求 提示
      bool ask = await showDescribrDialog(
        context: context,
        title: "请求安装应用权限",
        content: "用于应用新版本的安装",
      );
      if(!ask) return false;
      openAppSettings();
      return false;
    }
    return false;
  }



  // 目录文件读写权限
  static Future<bool> directory(String path) async {
    bool granted = await PermissionsMacosPlugin.checkDirectoryAccess(path);
    if (!granted) {
      // 请求目录读写权限
      granted = await PermissionsMacosPlugin.requestDirectoryAccess(path);
    }
    return granted;
  }


  static Future<void> _openAppPermissionSettings(String permission) async {
    if (Platform.isMacOS) {
      await PermissionsMacosPlugin.openSpecificSettings(permission);
    } else {
      await openAppSettings();
    }
  }
  



  static Future<bool> showDescribrDialog({
    required BuildContext context,
    required String title,
    required String content,
    String define = "下一步",
  }) async{

    Completer<bool> completer = Completer<bool>();

    BotToast.showAnimationWidget(
      allowClick: false,
      onlyOne: false,
      backgroundColor: Colors.black54,
      wrapAnimation: (controller, cancelFunc, widget) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: controller,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
          child: widget,
        );
      },
      wrapToastAnimation: (controller, cancelFunc, widget) {
        final CurvedAnimation curvedAnimation = CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(curvedAnimation),
            child: widget,
          ),
        );
      },
      toastBuilder: (cancelFunc) {
        return ShowDescribrDialogWidget(
          title: title,
          content: content,
          define: define,
          cancelFunc: (isClose) {
            completer.complete(isClose ?? false);
            cancelFunc.call();
          },
        );
      },
      animationDuration: const Duration(milliseconds: 300),
    );

    return completer.future;

    // return await AskDialog.showUserAsk(
    //   context: context,
    //   title: title,
    //   content: content,
    //   define: define
    // );
  }


}


class ShowDescribrDialogWidget extends StatefulWidget {
  final String title;
  final String content;
  final String define;
  final void Function(bool? isClose) cancelFunc;
  const ShowDescribrDialogWidget({
    super.key, 
    required this.title, 
    required this.content, 
    required this.define, 
    required this.cancelFunc,
  });

  @override
  State<ShowDescribrDialogWidget> createState() => _ShowDescribrDialogWidgetState();
}

class _ShowDescribrDialogWidgetState extends State<ShowDescribrDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.wMin),
          child: Container(
            width: 640.wMin,
            padding: EdgeInsets.all(32.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              color: AppTheme.cBgSecondary,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 32.wMin,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cTextPrimary.color,
                            ),
                          ),
                        ),
                        SizedBox(height: 32.wMin),
                        Container(
                          //alignment: Alignment.center,
                          constraints: BoxConstraints(
                            minHeight: 60.wMin,
                          ),
                          child: Text(
                            widget.content,
                            //textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24.wMin,
                              color: AppTheme.cTextPrimary.color,
                              fontWeight: FontWeight.w500,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: TapScaleWidget(
                        sclae: 1.05,
                        onTap: () => widget.cancelFunc(null),
                        child: Container(
                          width: 42.wMin,
                          height: 42.wMin,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.cBgActive,
                          ),
                          child: SvgPicture.asset(
                            "assets/svg/public/x.svg",
                            width: 24.wMin,
                            height: 24.wMin,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 38.wMin),
                Row(
                  spacing: 18.wMin,
                  children: [
                    Expanded(
                      child: ButtonWidget(
                        text: "取消",
                        height: 64.wMin,
                        fontColor: AppTheme.cTextSecondary,
                        fontSize: 24.wMin,
                        color: AppTheme.cBgTertiary,
                        borderRadius: 12.wMin,
                        sclae: 1.03,
                        onTap: () {
                          widget.cancelFunc(false);
                        },
                      ),
                    ),
                    Expanded(
                      child: ButtonWidget(
                        text: widget.define,
                        height: 64.wMin,
                        fontColor: AppTheme.cStaticWhite.color,
                        fontSize: 24.wMin,
                        color: AppTheme.cBgBrand.color,
                        borderRadius: 12.wMin,
                        sclae: 1.03,
                        onTap: () {
                          widget.cancelFunc(true);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}