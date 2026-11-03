import 'dart:developer';
import 'package:api/api.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/common.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../common/public_controller/init_controller.dart';
import '../../../common/values/storage.dart';
import '../../../config.dart';
import '../../../main.dart';
import 'state.dart';

class SignInUpController extends GetxController {
  SignInUpController();

  bool _login = false;

  final SignInUpState state = SignInUpState();

  final TextEditingController phoneNumberController = TextEditingController();

  final TextEditingController authCodeController = TextEditingController();

  TimerUtil? _mCountDownTimerUtil;

  final RxString buildType = "".obs;
  final RxString version = "".obs;
  final RxString appName = "".obs;
  int _tapCount = 0;
  DateTime? _lastTapTime;

  /// 是否支持一键登录
  final RxBool isSupportJverifyLogin = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initTimer();
    getVersion();
    // initJverify();
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void _initData() {
    update(["sign_in_up"]);
  }

  /// 初始化极光一键登录
  Future<void> initJverify() async {
    JverifyUtils.init();
    bool res = await JverifyUtils.isNetworkAvailable();
    isSupportJverifyLogin.value = res;
  }

  /// 获取版本信息
  Future<void> getVersion() async {
    buildType.value = StorageUtil().getString(STORAGE_HTTP_ENV_KEY);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
    appName.value = packageInfo.appName;
  }

  /// 游客模式
  Future<void> onTourist() async {
    // StorageUtil().remove(STORAGE_USER_AGREE_PRIVACY_KEY);
    await StorageUtil().setBool(EXPERIENCE_APP_KEY, true);
    await InitController.init();
    UserStore.to.profile;
    Get.offAllNamed(Routes.APPLICATION);
  }

  // 定时器
  void _initTimer() async {
    _mCountDownTimerUtil = TimerUtil(mTotalTime: 60 * 1000);
    _mCountDownTimerUtil?.setOnTimerTickCallback((int tick) {
      int tk = tick ~/ 1000;
      state.currentTime--;
      if (tk.toInt() <= 0) {
        _invalidTimerUtil();
        state.isCountDown = false;
        state.currentTime = 60;
      }
    });
  }

  /// 选择国家区号码
  Future<void> onSelectCallingCode(BuildContext context) async {
    String? res = await InternationalAreaCodeDialog.show(
      context: context,
      initialSelectedCode: state.callingCode,
    );
    if (res == null) return;
    state.callingCode = res;
  }

  // 发送验证码
  void onSendSms() async {
    if (ObjectUtil.isEmpty(phoneNumberController.text.trim())) {
      ToastUtils.showToast(text: "请填写手机号");
      return;
    }

    if (!GetUtils.isPhoneNumber(phoneNumberController.text.trim())) {
      ToastUtils.showToast(text: "手机号格式不正确");
      return;
    }

    if (!state.isChecked) {
      ToastUtils.showToast(text: "请阅读并同意用户协议和隐私政策");
      return;
    }

    if (state.isCountDown) {
      log('正在倒计时');
      return;
    }

    if (_mCountDownTimerUtil == null) {
      _initTimer();
    }

    if (!(await ConnectivityUtil.checkConnectivity())) {
      ToastUtils.showToast(text: "网络错误，请检查网络连接后重试!");
      return;
    }

    try {
      ToastUtils.showLoading();
      ResponseEntity<String> response = await UserStore.to.sendSms(state.callingCode, phoneNumberController.text.trim());

      if (!CommonUtil.isSuccess(response.code)) {
        ToastUtils.showToast(text: response.message ?? '');
        return;
      }

      state.isCountDown = true;
      // 启动倒计时
      _mCountDownTimerUtil?.startCountDown();
      ToastUtils.showToast(text: '验证码发送成功', type: ToastType.success);
    } on FormatException catch (e) {
      ToastUtils.showToast(text: e.source.message);
    } catch (e) {
      ToastUtils.showToast(text: e.toString());
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void onCheck() {
    state.isChecked = !state.isChecked;
  }

  // 开始登录
  Future<void> onLogin() async {
    if (ObjectUtil.isEmpty(phoneNumberController.text.trim())) {
      ToastUtils.showToast(text: "请填写手机号");
      return;
    }

    if (!GetUtils.isPhoneNumber(phoneNumberController.text.trim())) {
      ToastUtils.showToast(text: "手机号格式不正确");
      return;
    }

    if (ObjectUtil.isEmpty(authCodeController.text.trim())) {
      ToastUtils.showToast(text: "请填写验证码");
      return;
    }

    if (!state.isChecked) {
      ToastUtils.showToast(text: "请阅读并同意用户协议和隐私政策");
      return;
    }

    if (!(await ConnectivityUtil.checkConnectivity())) {
      ToastUtils.showToast(text: "网络错误，请检查网络连接后重试!");
      return;
    }

    if (_login) return;
    _login = true;
    try {
      ToastUtils.showLoading();
      String deviceId = StorageUtil().getString(STORAGE_DEVICE_ID_KEY);
      var response = await UserStore.to.onLogin(authCodeController.text.trim(), state.callingCode, phoneNumberController.text.trim(), platformId: deviceId);
      if (CommonUtil.isSuccess(response.code)) {
        await StorageUtil().remove(EXPERIENCE_APP_KEY);
        await StorageUtil().setBool(STORAGE_USER_AGREE_PRIVACY_KEY, true);
        await InitController.init();
        
        UmengUtils.signIn();
        
        if (UserStore.to.hasLoggedInBefore) {
          Get.offAllNamed(Routes.APPLICATION);
        } else {
          // Get.offAllNamed(Routes.GUIDED_SETTINGS);
          Get.offAllNamed(Routes.APPLICATION);
        }
      } else {
        ToastUtils.showToast(text: '登录失败');
      }
    } on FormatException catch (error) {
      ToastUtils.showToast(text: error.source?.message ?? '');
      log(error.source?.message ?? '');
    } catch (error) {
      ToastUtils.showToast(text: error.toString());
      log(error.toString());
    } finally {
      _login = false;
      ToastUtils.hideLoading();
    }
  }

  /// 使用本机号码一键登录
  Future<void> onLoginByPhoneNumber() async {
    String? _token = await JverifyUtils.getSimInfo();
    if (_token == null) {
      ToastUtils.showToast(text: '当前设备不支持一键登录');
      return;
    }
    JverifyUtils.setCustomUI();
    JverifyUtils.showJverifyLoginView();
  }

  Future<void> checkAppVersionText(BuildContext context) async{
    final now = DateTime.now();

    // 如果距离上次点击超过1秒，重置计数器
    if (_lastTapTime == null || now.difference(_lastTapTime!) > const Duration(seconds: 1)) {
      _tapCount = 0;
    }

    _tapCount++;
    _lastTapTime = now;

    if (_tapCount != 7) return;

    print('点击了7次!');
    _tapCount = 0; // 重置计数器
    String? pwd = await ShowPinPwdDialog.show(
      context: context,
      title: "切换服务器",
      content: "请输入密码",
    );
    if (pwd == null) return;

    String localPwd = "LW${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    if (localPwd != pwd) return ToastUtils.showToast(text: "密码错误");
    String? env = await SelectHttpenvDialog.show(context: context);
    if (env == null) return;
    try {
      ToastUtils.showLoading();
      await UserStore.to.clearUserInfo();
      await StorageUtil().setString(STORAGE_HTTP_ENV_KEY, env);
      await getVersion();
      await initHttp();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 跳转至用户协议
  Future<void> jumpToUserProtocol() async {
    await WebViewUtils.openWebView(url: Config.userProtocol);
  }

  /// 跳转至隐私协议
  Future<void> jumpToPrivacyProtocol() async {
    await WebViewUtils.openWebView(url: Config.userPrivacyProtocol);
  }

  // 销毁计时器
  void _invalidTimerUtil() {
    _mCountDownTimerUtil?.cancel();
    _mCountDownTimerUtil = null;
  }

  @override
  void onClose() {
    super.onClose();
    _invalidTimerUtil();
  }
}
