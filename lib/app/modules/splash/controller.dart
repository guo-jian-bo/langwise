import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
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
    print('[Splash] onInit');
    log('[Splash] onInit');
    super.onInit();
  }

  @override
  void onReady() {
    print('[Splash] onReady');
    log('[Splash] onReady');
    super.onReady();
    ThemeUtils.initTheme();
    _startErrorTimer();
    startLogin();
  }


  // 开始登录
  Future<void> startLogin() async {
    print('[Splash] startLogin enter');
    // log('[Splash] startLogin enter');
    log('[Splash] setPreferredOrientations before');
    // await SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeLeft, // 横屏，设备左侧朝上。
    //   DeviceOrientation.landscapeRight // 横屏，设备右侧朝上。
    // ]);
    // log('[Splash] setPreferredOrientations after');

    DateTime startNow = DateTime.now();
    
    if (login.value) return;
    login.value = true;
    try {
      log('[Splash] startLogin isLogin:${UserStore.to.isLogin}');
      log('[Splash] _checkPrivacy before');
      bool privacyAgreed = await _checkPrivacy();
      log('[Splash] _checkPrivacy after result:$privacyAgreed');
      if (UserStore.to.isLogin) {
        // 刷新token
        bool needRefreshToken = UserStore.to.isRefreshAccessToken();
        log('[Splash] isRefreshAccessToken:$needRefreshToken');
        if (needRefreshToken) {
          log('[Splash] onRefreshToken before');
          await UserStore.to.onRefreshToken();
          log('[Splash] onRefreshToken after');
        }
        log('[Splash] InitController.init before');
        await InitController.init();
        log('[Splash] InitController.init after');
        await StorageUtil().remove(EXPERIENCE_APP_KEY);
        log('[Splash] EXPERIENCE_APP_KEY removed');

        if(Platform.isAndroid || Platform.isIOS){
          DateTime now = DateTime.now();
          int millSeconds = now.difference(startNow).inMilliseconds;
          if(millSeconds < 1500){
            // 不足1.5秒，等待补足1.5秒
            await Future.delayed(Duration(milliseconds: 1500 - millSeconds));
          }
        }
        

        log('[Splash] route -> ${Routes.APPLICATION}');
        _cancelErrorTimer();
        Get.offAllNamed(Routes.APPLICATION);
      } else {
        log('[Splash] route -> ${Routes.SIGN_IN_UP}');
        _cancelErrorTimer();
        Get.offAllNamed(Routes.SIGN_IN_UP);
      }
    } catch (error) {
      log('[Splash] startLogin catch:$error');
      _cancelErrorTimer();
      Get.offAllNamed(Routes.SIGN_IN_UP);
      log(error.toString());
    } finally {
      log('[Splash] startLogin finally');
      login.value = false;
    }
  }

  Future<bool> _checkPrivacy() async{
    bool agreePrivacy = StorageUtil().getBool(STORAGE_USER_AGREE_PRIVACY_KEY);
    log('[Splash] _checkPrivacy storage agreePrivacy:$agreePrivacy');
    if (!agreePrivacy) {
      log('[Splash] PrivacyDialog.show before');
      bool result = await PrivacyDialog.show();
      log('[Splash] PrivacyDialog.show after result:$result');
      if(!result) return false;
    }
    await StorageUtil().setBool(STORAGE_USER_AGREE_PRIVACY_KEY, true);
    log('[Splash] set agree privacy true');
    UmengUtils.init();
    log('[Splash] UmengUtils.init triggered');
    
    return true;
  }

  void _startErrorTimer() {
    _cancelErrorTimer();
    error.value = false;
    _errorTimer = Timer(const Duration(seconds: 15), () {
      if (!error.value) {
        log('[Splash] timeout 15s, show error');
        error.value = true;
      }
    });
  }

  void _cancelErrorTimer() {
    _errorTimer?.cancel();
    _errorTimer = null;
  }

  Future<void> onExitApp() async {
    log('[Splash] onExitApp');
    if (Platform.isAndroid || Platform.isWindows) {
      await SystemNavigator.pop();
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
