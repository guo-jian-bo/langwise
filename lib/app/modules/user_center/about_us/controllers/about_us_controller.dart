import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/common.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../common/enum/enum.dart';
import '../../../../../common/stores/user.dart';
import '../../../../../common/values/values.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../config.dart';
import '../../../../../main.dart';
import '../../../../../utils/oss_upload_file_utils/oss_update_response_entity.dart';
import '../../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../../common/unsubscribe_dialog.dart';

class AboutUsController extends GetxController {

  final RxString version = "".obs;

  final RxString appName = "".obs;

  final Rx<String> buildType = HttpEnvKey.pro.obs;

  int _tapCount = 0;
  DateTime? _lastTapTime;

  @override
  void onInit() {
    super.onInit();
    buildType.value = StorageUtil().getString(STORAGE_HTTP_ENV_KEY);
    getVersion();
  }

  /// 获取版本信息
  Future<void> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
    appName.value = packageInfo.appName;
  }


  /// 检查新版本
  Future<void> checkNewVersion(BuildContext context) async {
    try {
      ToastUtils.showLoading();
      bool? res = await AppCheckVersionDialog.checkVersion(checkTodayShow: false);
      if(res == null || res) return;
      ToastUtils.showToast(text: "没有可更新版本", type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 联系客服
  Future<void> contactCustomerService(BuildContext context) async {
    await QrCodeDialog.reportCustomer(context);
  }

  /// 去给${Config.appName}打分
  Future<void> goScore() async {
    final url = Uri.parse('https://itunes.apple.com/app/id${Config.iosAppId}?action=write-review');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  /// 跳转至筑梦团页面
  Future<void> toBuildingDreams() async{
    await Get.toNamed(Routes.DREAM_BUILDING_TEAM);
  }

  /// 反馈意见
  Future<void> feedbackOpinion(BuildContext context) async {
    Get.toNamed(Routes.FEEDBACK_OPINION);
  }

  /// 违法不良信息举报
  Future<void> report(BuildContext context) async {
    Get.toNamed(Routes.ILLEGAL_REPORTING);
  }

  /// 开源许可
  Future<void> openSourceLicense() async {
    Get.toNamed(Routes.OPEN_SOURCE_LICENSE);
  }

  /// 协议
  Future<void> protocol(String url) async {
    await WebViewUtils.openWebView(url: url);
  }

  /// 清除缓存
  Future<void> clearCache(BuildContext context) async {

    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: "清除缓存",
      content: "确定要清除缓存吗？清除后图片音频等资源将重新下载。",
    );
    if(!askRes) return;

    try {
      ToastUtils.showLoading();
      // await ErrorLogUtils.to.clearErrorLogs();
      await CacheManagerUtils.instance.clearCache();
      await CacheManagerUtils.instance.clearShareDir();
      int userId = UserStore.to.userInfo.value.userId ?? 0;
      await StorageUtil().remove("${SPECIAL_PAY_NOT_REMIND_KEY}_$userId");
      await StorageUtil().remove("${SPECIAL_PAY_NOT_REMIND_KEY}_${KnowledgeTypeEnum.EN_TEXT.value}_$userId");
      await StorageUtil().remove("${SPECIAL_PAY_NOT_REMIND_KEY}_${KnowledgeTypeEnum.EN_SONG.value}_$userId");
      await StorageUtil().remove("${SPECIAL_PAY_NOT_REMIND_KEY}_${KnowledgeTypeEnum.EN_REVEAL.value}_$userId");
      await StorageUtil().remove("${SPECIAL_PAY_NOT_REMIND_KEY}_${KnowledgeTypeEnum.SCRIPT.value}_$userId");

      await StorageUtil().remove(STORAGE_PARENT_PASSWORD_FREE_KEY);
      await StorageUtil().remove(STORAGE_APP_CHECK_DATE_KEY);
      await StorageUtil().remove(SUB_LISTEN_NOT_REMIND_KEY);
      ToastUtils.showToast(text: "清除成功", type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 上传日志
  Future<void> uploadErrorLogs() async {
    File logFile = await ErrorLogUtils.to.getLogFile();
    if(logFile.lengthSync() == 0) {
      ToastUtils.showToast(text: "暂无日志", type: ToastType.success);
      return;
    }
    
    try {
      ToastUtils.showLoading();

      OssUpdateResponseEntity? uploadRes = await OssUploadFileUtils.uploadUserFile(
        filePath: logFile.path,
        fileType: OssUploadUserType.log,
      );
      if(uploadRes == null) {
        return;
      }
      bool res = await AccountUtil.uploadErrorLogs({
        "fileKey": uploadRes.key,
      });
      if(!res) return;
      
      ToastUtils.showToast(text: "上传成功", type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }

  }

  /// 注销账号
  Future<void> unsubscribe(BuildContext context) async {
    bool unRes = await UnsubscribeDialog.show(context);
    if(!unRes) return;
    try {
      String deviceId = StorageUtil().getString(STORAGE_DEVICE_ID_KEY);
      Map<String, dynamic> reqData = {
        "refreshToken": UserStore.to.refreshToken,
        "platform": UserStore.to.profile.platform,
        "platformId": deviceId,
        "platformName": UserStore.to.profile.platformName,
      };
      ToastUtils.showLoading();
      bool res = await AccountUtil.logoff(reqData);
      
      if(!res) return;
      ToastUtils.showToast(text: "提交成功", type: ToastType.success);
      await Future.delayed(const Duration(seconds: 1));
      await UserStore.to.clearUserInfo();
      Get.offAllNamed(Routes.SIGN_IN_UP);
    } finally{
      ToastUtils.hideLoading();
    }
  }


  Future<void> checkAppRecordInfoText(BuildContext context) async{
    final now = DateTime.now();
  
    // 如果距离上次点击超过1秒，重置计数器
    if (_lastTapTime == null || now.difference(_lastTapTime!) > const Duration(seconds:1)) {
      _tapCount = 0;
    }
    
    _tapCount++;
    _lastTapTime = now;

    if(_tapCount != 7) return;
    
    print('点击了7次!');
    _tapCount = 0; // 重置计数器
    String? pwd = await ShowPinPwdDialog.show(
      context: context,
      title: "切换服务器",
      content: "请输入密码",
    );
    if(pwd == null) return;

    String localPwd = "LW${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    if(localPwd != pwd) return ToastUtils.showToast(text: "密码错误");
    String? env = await SelectHttpenvDialog.show(context: context);
    if(env == null) return;
    try {
      ToastUtils.showLoading();
      await StorageUtil().setString(STORAGE_HTTP_ENV_KEY, env);
      await initHttp();
    } finally{
      ToastUtils.hideLoading();
    }
    await UserStore.to.clearUserInfo();
    Get.offAllNamed(Routes.SPLASH);

  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
