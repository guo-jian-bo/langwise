import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:lib_common/common.dart';
import '../../../common/public_controller/init_controller.dart';
import '../../../common/values/values.dart';
import '../../../common/widgets/widgets.dart';
import '../../../theme/theme_utils.dart';
import '../../../utils/utils.dart';

class SplashController extends GetxController {
  SplashController();

  final RxBool error = false.obs;

  final RxBool login = false.obs;

  Timer? _errorTimer;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    ErrorLogUtils.to.logInfo("[login] -------- 启动页onReady，开始执行启动流程");
    ThemeUtils.initTheme();
    _startErrorTimer();
    startLogin();
  }

  void _navigateTo(String route) {
    if (isClosed) {
      ErrorLogUtils.to.logInfo("[login] -------- 控制器已销毁，取消跳转:$route");
      return;
    }
    if (!Get.testMode && Get.key.currentState == null) {
      ErrorLogUtils.to.logInfo("[login] -------- Navigator未就绪，取消跳转:$route");
      return;
    }
    Get.offAllNamed(route);
  }


  // 开始登录
  Future<void> startLogin() async {
    DateTime startNow = DateTime.now();

    ErrorLogUtils.to.logInfo("[login] -------- 启动流程开始");
    if (login.value) {
      ErrorLogUtils.to.logInfo("[login] -------- 启动流程正在执行中，忽略重复调用");
      return;
    }
    login.value = true;
    try {
      ErrorLogUtils.to.logInfo("[login] -------- 开始检查隐私协议");
      bool privacyAgreed = await _checkPrivacy();
      log('[Splash] _checkPrivacy after result:$privacyAgreed');
      ErrorLogUtils.to.logInfo("[login] -------- 隐私协议检查结果:$privacyAgreed");
      if (!privacyAgreed) {
        ErrorLogUtils.to.logInfo("[login] -------- 用户未同意隐私协议，启动流程终止");
        return;
      }

      ErrorLogUtils.to.logInfo("[login] -------- 当前是否已登录:${UserStore.to.isLogin}");
      if (UserStore.to.isLogin) {
        ErrorLogUtils.to.logInfo("[login] -------- 检测到本地已有登录态，准备进入首页流程");
        // 刷新token
        bool needRefreshToken = UserStore.to.isRefreshAccessToken();
        ErrorLogUtils.to.logInfo("[login] -------- 是否需要刷新token:$needRefreshToken");
        if (needRefreshToken) {
          ErrorLogUtils.to.logInfo("[login] -------- 开始刷新token");
          await UserStore.to.onRefreshToken();
          ErrorLogUtils.to.logInfo("[login] -------- 刷新token流程结束");
        } else {
          ErrorLogUtils.to.logInfo("[login] -------- 本次启动无需刷新token");
        }

        ErrorLogUtils.to.logInfo("[login] -------- 开始初始化首页数据");
        await InitController.init();
        ErrorLogUtils.to.logInfo("[login] -------- 首页初始化完成");
        await StorageUtil().remove(EXPERIENCE_APP_KEY);
        ErrorLogUtils.to.logInfo("[login] -------- 已清理体验模式缓存");

        if(Platform.isAndroid || Platform.isIOS){
          DateTime now = DateTime.now();
          int millSeconds = now.difference(startNow).inMilliseconds;
          if(millSeconds < 1500){
            ErrorLogUtils.to.logInfo("[login] -------- 启动耗时${millSeconds}ms，等待补足启动页最短展示时长");
            // 不足1.5秒，等待补足1.5秒
            await Future.delayed(Duration(milliseconds: 1500 - millSeconds));
          }
        }

        ErrorLogUtils.to.logInfo("[login] -------- 准备跳转首页:${Routes.APPLICATION}");
        _cancelErrorTimer();
        RoutesBreadcrumbUtils.clearAllBreadcrumb();
        _navigateTo(Routes.APPLICATION);
        ErrorLogUtils.to.logInfo("[login] -------- 已发起跳转首页");
      } else {
        ErrorLogUtils.to.logInfo("[login] -------- 未检测到登录态，准备跳转登录页面:${Routes.SIGN_IN_UP}");
        _cancelErrorTimer();
        _navigateTo(Routes.SIGN_IN_UP);
        ErrorLogUtils.to.logInfo("[login] -------- 已发起跳转登录页面");
      }
    } catch (error) {
      ErrorLogUtils.to.logInfo("[login] -------- 启动流程异常，跳转登录页面，error:$error");
      _cancelErrorTimer();
      _navigateTo(Routes.SIGN_IN_UP);
      log(error.toString());
    } finally {
      ErrorLogUtils.to.logInfo("[login] -------- 启动流程结束");
      login.value = false;
    }
  }

  Future<bool> _checkPrivacy() async{
    bool agreePrivacy = StorageUtil().getBool(STORAGE_USER_AGREE_PRIVACY_KEY);
    ErrorLogUtils.to.logInfo("[login] -------- 本地隐私协议状态:$agreePrivacy");
    if (!agreePrivacy) {
      ErrorLogUtils.to.logInfo("[login] -------- 首次启动或未同意隐私协议，弹出隐私协议弹窗");
      bool result = await PrivacyDialog.show();
      ErrorLogUtils.to.logInfo("[login] -------- 隐私协议弹窗结果:$result");
      if(!result) return false;
    }
    await StorageUtil().setBool(STORAGE_USER_AGREE_PRIVACY_KEY, true);
    ErrorLogUtils.to.logInfo("[login] -------- 已写入隐私协议同意状态");
    UmengUtils.init();
    ErrorLogUtils.to.logInfo("[login] -------- 友盟初始化完成");
    return true;
  }

  void _startErrorTimer() {
    _cancelErrorTimer();
    error.value = false;
    _errorTimer = Timer(const Duration(seconds: 15), () {
      if (!error.value) {
        error.value = true;
      }
    });
  }

  void _cancelErrorTimer() {
    _errorTimer?.cancel();
    _errorTimer = null;
  }

  Future<void> onExitApp() async {
    if (Platform.isAndroid || Platform.isWindows) {
      exit(0);
    }
    await SystemNavigator.pop();
  }

  @override
  void onClose() {
    _cancelErrorTimer();
    super.onClose();

  }
}
