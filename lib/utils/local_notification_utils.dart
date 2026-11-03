import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';

import '../common/entities/entities.dart';
import '../config.dart';
import '../log_widget.dart';

class LocalNotificationUtils{

  static final LocalNotificationUtils _instance = LocalNotificationUtils._internal();
  factory LocalNotificationUtils() => _instance;
  LocalNotificationUtils._internal();

  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  Future<void> initializeLocal() async {
    if(flutterLocalNotificationsPlugin != null) return;
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // 初始化设置

    // Android 初始化设置
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS/macOS 初始化设置
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Windows 初始化设置
    const WindowsInitializationSettings initializationSettingsWindows = WindowsInitializationSettings(
      appName: Config.appName,
      appUserModelId: 'com.timelywise.langwise',
      guid: '2553aeb2-75ec-4777-b0a9-8779a40bdfb3',//随机生成的GUID
      iconPath: 'app_icon.ico',
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      windows: initializationSettingsWindows,
    );

    await flutterLocalNotificationsPlugin!.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    if(Platform.isAndroid || Platform.isMacOS || Platform.isIOS){ //ios申请通知权限由极光推送处理
      await PermissionUtils.notification(Get.context!, isCheck: false);
    }

    // 请求权限iOS
    // if (Platform.isIOS) {
    //   await flutterLocalNotificationsPlugin!.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
    //     alert: true,
    //     badge: true,
    //     sound: true,
    //   );
    // }


    // if (Platform.isMacOS) {
    //   await flutterLocalNotificationsPlugin!.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
    //     alert: true,
    //     badge: true,
    //     sound: true,
    //   );
    // }
    
    // 请求权限（Android 13+）
    // if (Platform.isAndroid) {
    //   final AndroidFlutterLocalNotificationsPlugin? androidImplementation = flutterLocalNotificationsPlugin!.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    //   await androidImplementation?.requestNotificationsPermission();
    // }
  }

  Future<bool?> requestIosNotificationsPermission() async{
    return await flutterLocalNotificationsPlugin?.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }


  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'main_channel', // 渠道ID
      '重要通知', // 渠道名称(用户可见)
      channelDescription: '应用的重要通知和提醒', // 渠道描述(用户可见)
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
      macOS: darwinNotificationDetails,
    );

    await flutterLocalNotificationsPlugin?.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
  

  /// 处理点击通知
  void onDidReceiveNotificationResponse(NotificationResponse response) {
    // 处理通知点击
    LogManager().addLog('点击通知: ${response.payload}');
    if(response.payload == null) return;
    Map<String, dynamic> payloadMap = jsonDecode(response.payload!);
    PushMessageEntity pushMessageEntity = PushMessageEntity.fromJson(payloadMap);
    JumpPageUtils.jumpPage(pushMessageEntity);
  }
  
}

