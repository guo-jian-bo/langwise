import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/home/controllers/home_controller.dart';
import 'package:langwise/app/modules/music/controllers/music_controller.dart';
import 'package:langwise/app/modules/subscribe_and_listening/controller.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/guide_engine/guide_manager.dart';
import 'package:langwise/utils/audio_handler.dart';
import 'package:langwise/utils/play_record_utils/play_record_utils.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/common.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/stores/stores.dart';
import '../../../../common/values/values.dart';
import '../../../../common/widgets/widgets.dart';
import '../../elements/elements_detils/controllers/elements_detils_controller.dart';
import '../../management/dialog/dialogs.dart';
import '../../specialty/controllers/specialty_controller.dart';

class ApplicationController extends GetxController with GetTickerProviderStateMixin, WidgetsBindingObserver {
  final UserStore userStore = UserStore.to;

  final RxInt navIndex = 0.obs;
  int previousIndex = 0;
  bool isClickable = true;

  bool _guideUiReadyCalled = false;
  bool _isFirstTaskPrompt = true;
  Worker? _promptWorker;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _promptWorker = ever(GuideManager.instance.taskListPromptTaskId, _onPromptTaskIdChanged);
  }

  void _onPromptTaskIdChanged(String? taskId) {
    if (taskId == null || taskId.trim().isEmpty) return;
    if (_isFirstTaskPrompt) {
      int? userId = UserStore.to.userInfo.value.userId;
      if(userId != null){
        bool hideTask = StorageUtil().getBool("${NOVICE_TASK_REMINDER_KEY}_$userId");
        if(hideTask) return;
      }
      
    }
    // 延迟一帧确保页面已完成渲染
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute != Routes.APPLICATION) return;
      GuideManager.instance.showTaskListEntryGuide(taskId);
    });
  }

  Future<void> initApp() async {
    if (LockUtils.checkExperienceAppStorage()) return;
    WebsocketUtils.instance;
    await LocalNotificationUtils().initializeLocal();
    await JPushUtils.instance.initJPush();
    if(UserStore.to.isLogin){
      // 登录后上报本地缓存的播放记录
      PlayRecordManager.instance.reportPendingRecords();
    }
  }

  Future<void> changeNavIndex(int index, BuildContext context) async {
    if (index != 0) {
      bool experience = await LockUtils.checkExperienceApp(context);
      if (experience) return;
    }
    if (index != 0) {
      bool student = await LockUtils.checkStudent(context);
      if(!student) return;
    }
    if (index == 1) {
      if (Get.isRegistered<SubListenController>()) {
        Get.find<SubListenController>().initPage();
      }
    }
    if (index == 2) {
      if (Get.isRegistered<MusicController>()) {
        Get.find<MusicController>().initPage();
      }
    }
    if (index != 3) {
      if (Get.isRegistered<ElementsDetilsController>()) {
        Get.find<ElementsDetilsController>().clearSearch();
      }
    }

    if (!isClickable) return;
    isClickable = false;

    previousIndex = navIndex.value;
    navIndex(index);

    Future.delayed(const Duration(milliseconds: 400), () {
      isClickable = true;
    });
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
    if (LockUtils.checkExperienceAppStorage()) return;
    if (Get.isRegistered<ElementsDetilsController>()) {
      await Get.find<ElementsDetilsController>().externalRefresh();
    }
    if (Get.isRegistered<SpecialtyController>()) {
      await Get.find<SpecialtyController>().initHomeCardList();
    }
    if (navIndex.value == 1) {
      if (Get.isRegistered<SubListenController>()) {
        await Get.find<SubListenController>().initPage(showNotice: false);
      }
    }
    if (navIndex.value == 2) {
      if (Get.isRegistered<MusicController>()) {
        await Get.find<MusicController>().initPage();
      }
    }
  }

  Future<void> toUserCenter(BuildContext context, {int? toUserModelIndex}) async {
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) return;

    bool isPwdRight = await ParentPasswordialog.show(context: context, isCheckHasPassword: false);
    if (!isPwdRight) return;
    if (Get.isRegistered<ElementsDetilsController>()) {
      Get.find<ElementsDetilsController>().clearSearch();
    }

    await Get.toNamed(
      Routes.USER_CENTER,
      arguments: {
        "toUserModelIndex": toUserModelIndex,
      },
    );
  }

  /// 跳转至我的收藏
  Future<void> toFavorite(BuildContext context) async{
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) return;
    bool isStudent = await LockUtils.checkStudent(context);
    if (!isStudent) return;
    Get.toNamed(
      Routes.FAVOURITE,
      arguments: {},
    );
  }

  /// 跳转至新管理页面
  Future<void> toManageNewPage(BuildContext context) async {
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) return;

    bool isPwdRight = await ManagePasswordDialog.show(context: context);
    if (!isPwdRight) return;
    await Get.toNamed(
      Routes.MANAGEMENT,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    print('[ApplicationController] 生命周期变化: $state');
    
    if (state == AppLifecycleState.resumed) {
      print('APP从后台返回到前台');
      checkRefreshDate();
      // 刷新音频服务的锁屏控制状态
      _refreshAudioNowPlayingInfo();
    } else if (state == AppLifecycleState.paused) {
      print('APP进入后台');
      _refreshAudioNowPlayingInfo();
    } else if (state == AppLifecycleState.inactive) {
      print('APP进入inactive状态（如锁屏、来电等）');
    } else if (state == AppLifecycleState.detached) {
      print('APP进入detached状态');
    }
  }

  /// 刷新音频服务的锁屏控制状态
  void _refreshAudioNowPlayingInfo() {
    if (Get.isRegistered<NSAudioHandler>()) {
      Get.find<NSAudioHandler>().refreshNowPlayingInfo();
    }
  }

  Future<void> checkRefreshDate() async {
    DateTime now = DateTime.now().toLocal();
    String refreshDate = StorageUtil().getString(HOME_REFRESH_DATE_KEY);
    if (refreshDate == "${now.year}${now.month}${now.day}") return;
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().initHomeCardList();
    }
  }

  @override
  void onReady() {
    super.onReady();
    initApp();
    AppCheckVersionDialog.checkVersion();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (LockUtils.checkExperienceAppStorage()) return;
      if (_guideUiReadyCalled) return;
      _guideUiReadyCalled = true;
      GuideManager.instance.onUiReady().then((_) {
        // onUiReady 内部的 emitTaskListPrompt 在下一帧的 postFrameCallback 中触发
        // 再等一帧确保初始化阶段的回调已全部执行完毕，之后关闭首次入口标记
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _isFirstTaskPrompt = false;
        });
      });
    });
  }

  @override
  void onClose() {
    _promptWorker?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    WebsocketUtils.instance.closeWebSocket();
    super.onClose();
  }
}
