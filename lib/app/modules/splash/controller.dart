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

  final RxBool login = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    ThemeUtils.initTheme();
    _initData();
    startLogin();
  }

  _initData() {
    update(["splash"]);
  }

  // 开始登录
  Future<void> startLogin() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft, // 横屏，设备左侧朝上。
      DeviceOrientation.landscapeRight // 横屏，设备右侧朝上。
    ]);

    DateTime startNow = DateTime.now();
    
    if (login.value) return;
    login.value = true;
    try {
      print('---startLogin, isLogin:${UserStore.to.isLogin}---');
      await _checkPrivacy();
      if (UserStore.to.isLogin) {
        // 刷新token
        if (UserStore.to.isRefreshAccessToken()) {
          await UserStore.to.onRefreshToken();
        }
        await InitController.init();
        await StorageUtil().remove(EXPERIENCE_APP_KEY);

        if(Platform.isAndroid || Platform.isIOS){
          DateTime now = DateTime.now();
          int millSeconds = now.difference(startNow).inMilliseconds;
          if(millSeconds < 1500){
            // 不足1.5秒，等待补足1.5秒
            await Future.delayed(Duration(milliseconds: 1500 - millSeconds));
          }
        }
        

        Get.offAllNamed(Routes.APPLICATION);
        // if (!UserStore.to.hasLoggedInBefore) {
        //   Get.offAllNamed(Routes.GUIDED_SETTINGS);
        // } else {
        //   Get.offAllNamed(Routes.APPLICATION);
        // }
      } else {
        Get.offAllNamed(Routes.SIGN_IN_UP);
      }
    } catch (error) {
      Get.offAllNamed(Routes.SIGN_IN_UP);
      log(error.toString());
    } finally {
      login.value = false;
    }
  }

  Future<bool> _checkPrivacy() async{
    bool agreePrivacy = StorageUtil().getBool(STORAGE_USER_AGREE_PRIVACY_KEY);
    if (!agreePrivacy) {
      bool result = await PrivacyDialog.show();
      if(!result) return false;
    }
    await StorageUtil().setBool(STORAGE_USER_AGREE_PRIVACY_KEY, true);
    UmengUtils.init();
    
    return true;
  }

  @override
  void onClose() {
    super.onClose();

  }
}
