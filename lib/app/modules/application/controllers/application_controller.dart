import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/home/controllers/home_controller.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/utils/audio_handler.dart';
import 'package:langwise/utils/play_record_utils/play_record_utils.dart';
import 'package:langwise/utils/utils.dart';
import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/stores/stores.dart';
import '../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/dio_interceptors/dio_interceptor_utils.dart';
import '../../../../utils/mqtt_utils/mqtt_message_services_code.dart';
import '../../management/dialog/dialogs.dart';
import '../common/work_order_list_dialog.dart';
import 'message_controller.dart';
import 'work_order_list_controller.dart';

class ApplicationController extends GetxController with GetTickerProviderStateMixin, WidgetsBindingObserver, RoutesBreadcrumbMixin {
  bool _enteredBackground = false;

  @override
  String get breadcrumbRoute => Routes.APPLICATION;

  @override
  String get breadcrumbTitle => "HOME";

  final UserStore userStore = UserStore.to;

  final MessageController _messageController = Get.find<MessageController>();

  final WorkOrderListController _workOrderListController = Get.find<WorkOrderListController>();

  StreamSubscription<PushMessageServiceEnitiy>? _messageSubscription;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb("");
    WidgetsBinding.instance.addObserver(this);

    _messageSubscription = MqttNotificationMessage.instance.listenByCode(
      codes: [MqttMessageServicesCode.refreshTicketRecord], 
      onData: (value){
        _workOrderListController.getWorkOrderList();
      },
    );
  }


  Future<void> initApp() async {
    if (LockUtils.checkExperienceAppStorage()) return;
    await JPushUtils.instance.initJPush();
    if(UserStore.to.isLogin){
      Mqtt5ClientUtils.instance.initMqtt();
      MqttNotificationMessage.instance.listenMqttMessage();
      // 获取初始化消息
      _messageController.getInitMessageList();
      // 获取初始化工单列表
      _workOrderListController.getWorkOrderList();
      // 登录后上报本地缓存的播放记录
      PlayRecordManager.instance.reportPendingRecords();
      LearnRecordManager.instance.reportPendingRecords();
      AppLinksUtils.initAppLinks();
      WxUtils.initWechat();
    }
  }

  Future<void> changeNavIndex(AppHomeButtonEnum data, BuildContext context) async {
    if (data != AppHomeButtonEnum.home) {
      final bool experience = await LockUtils.checkExperienceApp(context);
      if (experience) {
        GuideTaskController.to.stop();
        return;
      }
      final bool student = await LockUtils.checkStudent(context);
      if (!student) {
        GuideTaskController.to.stop();
        return;
      }

      await _pushNavPage(data);
    }
    GuideTaskController.to.continueGuide(AppRoutesCode.home, data.widgetId);

    // await GuideTaskController.to.loadTasks(pageCode: AppRoutesCode.home);
    // GuideTaskController.to.start(AppRoutesCode.home);
  }

  Future<void> _pushNavPage(AppHomeButtonEnum data) async {
    switch (data) {
      case AppHomeButtonEnum.search:
        await TagRoutes.toNamed(
          Routes.INTELLIGENT_SEARCH,
          tagText: Routes.INTELLIGENT_SEARCH,
        );
        return;
      case AppHomeButtonEnum.zhenTing:
        await TagRoutes.toNamed(
          Routes.APP_SUBSCRIBE_LISTENING,
          tagText: Routes.APP_SUBSCRIBE_LISTENING,
        );
        return;
      case AppHomeButtonEnum.script:
        await TagRoutes.toNamed(
          Routes.ZHENDU_HOME,
          tagText: Routes.ZHENDU_HOME,
        );
        return;
      case AppHomeButtonEnum.music:
        await TagRoutes.toNamed(
          Routes.MUSIC,
          tagText: Routes.MUSIC,
        );
        return;
      case AppHomeButtonEnum.dictionary:
        await TagRoutes.toNamed(
          Routes.DICTIONARY,
          tagText: Routes.DICTIONARY,
        );
        return;
      case AppHomeButtonEnum.pronunciation:
        await TagRoutes.toNamed(
          Routes.PHONICS_COURSE,
          tagText: Routes.PHONICS_COURSE,
          arguments: {
            'useDefaultCourse': true,
            'asPrimaryPage': true,
          },
        );
        return;
      default:
        break;
    }
  }

  /// 刷新
  Future<void> refreshData({bool isLoading = true}) async {
    try {
      if (isLoading) ToastUtils.showLoading();
      if (Get.isRegistered<ConfigController>()) {
        await Get.find<ConfigController>().initConfig();
      }

      await refreshHomePages();
    } finally {
      if (isLoading) ToastUtils.hideLoading();
    }
  }

  /// 刷新几个首页
  Future<void> refreshHomePages() async {
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().initHomeCardList();
    }
  }

  Future<void> toUserCenter(BuildContext context, {int? toUserModelIndex}) async {
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) {
      GuideTaskController.to.stop();
      return;
    }



    bool isPwdRight = await ParentPasswordialog.show(context: context, isCheckHasPassword: false);
    if (!isPwdRight) {
      GuideTaskController.to.stop();
      return;
    }
    await TagRoutes.toNamed(
      Routes.USER_CENTER,
      arguments: {
        "toUserModelIndex": toUserModelIndex,
      },
    );
    GuideTaskController.to.continueGuide(AppRoutesCode.home, GuideWidgetIds.homeUserButton);
  }

  /// 跳转至我的收藏
  Future<void> toFavorite(BuildContext context) async{
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) {
      GuideTaskController.to.stop();
      return;
    }
    bool isStudent = await LockUtils.checkStudent(context);
    if (!isStudent) {
      GuideTaskController.to.stop();
      return;
    }
    await TagRoutes.toNamed(
      Routes.FAVOURITE,
      arguments: {},
    );
    GuideTaskController.to.continueGuide(AppRoutesCode.home, GuideWidgetIds.homeFavoriteButton);
  }

  /// 跳转新管理页面
  Future<void> toManageNewPage(BuildContext context) async {
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) return;

    bool isPwdRight = await ManagePasswordDialog.show(context: context);
    if (!isPwdRight) return;
    await TagRoutes.toNamed(Routes.MANAGEMENT);
  }

  /// 打开消息列表页面
  Future<void> openMessage(BuildContext context) async{
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) {
      GuideTaskController.to.stop();
      return;
    }
    _messageController.initData();
    Scaffold.maybeOf(context)?.openEndDrawer();
    GuideTaskController.to.continueGuide(AppRoutesCode.home, GuideWidgetIds.homeMessageButton);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    _logLifecycle('生命周期变化: $state');
    
    if (state == AppLifecycleState.resumed) {
      _logLifecycle('APP从后台返回到前台');
      if (_enteredBackground) {
        _enteredBackground = false;
        DioInterceptorUtils.reset();
        _logLifecycle('已在恢复前台时重置WiseHttp连接池');
      }
      // 刷新音频服务的锁屏控制状态
      _refreshAudioNowPlayingInfo();
    } else if (state == AppLifecycleState.paused) {
      _logLifecycle('APP进入后台');
      _enteredBackground = true;
      _refreshAudioNowPlayingInfo();
    } else if (state == AppLifecycleState.inactive) {
      _logLifecycle('APP进入inactive状态（如锁屏、来电等）');
    } else if (state == AppLifecycleState.detached) {
      _logLifecycle('APP进入detached状态');
    }
  }

  /// 刷新音频服务的锁屏控制状态
  void _refreshAudioNowPlayingInfo() {
    if (Get.isRegistered<NSAudioHandler>()) {
      Get.find<NSAudioHandler>().refreshNowPlayingInfo();
    }
  }

  void _logLifecycle(String message) {
    print(message);
    // ErrorLogUtils.to.logInfo('[ApplicationController] $message');
  }

  /// 打开任务列表弹窗
  Future<void> openTaskList(BuildContext context) async{
    await GuideTaskListDialog.show(context: context);
    GuideTaskController.to.continueGuide(AppRoutesCode.home, GuideWidgetIds.homeGuideDialogButton);
  }

  /// 打开工单列表弹窗
  Future<void> openWorkOrderList(BuildContext context) async{
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) {
      GuideTaskController.to.stop();
      return;
    }
    await WorkOrderListDialog.show(context);
    _workOrderListController.getWorkOrderList();
    GuideTaskController.to.continueGuide(AppRoutesCode.home, GuideWidgetIds.homeWorkOrderButton);
  }


  @override
  void onReady() {
    super.onReady();
    initApp();
    AppCheckVersionDialog.checkVersion();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    // WebsocketUtils.instance.closeWebSocket();
    Mqtt5ClientUtils.instance.disconnect();
    MqttNotificationMessage.instance.dispose();
    _messageSubscription?.cancel();
    super.onClose();
  }
}
