
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/common.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wise_http/wise_http.dart';

import '../../config.dart';
import '../../utils/utils.dart';
import '../entities/entities.dart';
import '../https/user.dart';
import '../values/values.dart';
import 'widgets.dart';

class AppCheckVersionDialog{

  /// * checkTodayShow:检查今天是否弹出过一次,如果弹出过一次就不弹出了
  /// * 返回结果 null：失败 false已经是最新版本 true弹出了更新弹窗
  static Future<bool?> checkVersion({bool checkTodayShow = true}) async{
    if(checkTodayShow){
      if(!_getIsChaeckToday()) return null;
    }
    String platform = PlatformUtils.getPlatformEnum();
    if(platform.isEmpty) return null;

    String localVersion = await _getVersion();
    // localVersion = "1.1.1";
    // platform = "ANDROID";
    if(localVersion.isEmpty) return null;

    AppCheckEntity? checkRes = await UserRequest.getAppLastVersion(platform, localVersion);
    if(checkRes == null) return false;
    String? url = checkRes.url;
    if(url == null) return null;

    if(checkRes.forceUpgrade == false){
      setAppCheckDate();
    }

    _showUpdateDialog(
      forceUpdate: checkRes.forceUpgrade??false,
      updateContent: checkRes.intro,
      serviceVersion: checkRes.version,
      url: url,
    );
    return true;
  }

  /// 获取存在本地的时间key
  static bool _getIsChaeckToday() {
    String localDate = StorageUtil().getString(STORAGE_APP_CHECK_DATE_KEY);
    if(localDate.isEmpty) return true;
    DateTime nowYMD = DateTime.now();
    String nowYMDStr = DateFormatUtil.formatStr(nowYMD, newPattern: "yyyyMMdd");
    if(nowYMDStr.isEmpty) return false;
    if(localDate == nowYMDStr) return false;
    return true;
  }

  /// 设置app更新的时间标识
  static Future<bool> setAppCheckDate() async{
    DateTime nowYMD = DateTime.now();
    String nowYMDStr = DateFormatUtil.formatStr(nowYMD, newPattern: "yyyyMMdd");
    return await StorageUtil().setString(STORAGE_APP_CHECK_DATE_KEY, nowYMDStr);
  }

  /// 获取版本信息
  static Future<String> _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }


  static Future<void> _showUpdateDialog({
    bool forceUpdate = false,
    String? updateContent,
    String? serviceVersion,
    String? url,
  }) async{

    if(Get.context == null) return;
    await showCupertinoDialog(
      context: Get.context!,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (context){
        return AppUpdateDialogWidget(
          updateContent: updateContent,
          forceUpdate: forceUpdate,
          serviceVersion: serviceVersion,
          url: url,
        );
      },
    );
  }
}

class AppUpdateDialogWidget extends StatefulWidget {
  final String? updateContent;
  final String? serviceVersion;
  final bool forceUpdate;
  final String? url;
  const AppUpdateDialogWidget({
    super.key, 
    this.updateContent, 
    this.serviceVersion, 
    this.forceUpdate = false,
    this.url,
  });

  @override
  State<AppUpdateDialogWidget> createState() => _AppUpdateDialogWidgetState();
}

class _AppUpdateDialogWidgetState extends State<AppUpdateDialogWidget> {

  String savePath = "";

  /// 0:未开始，1:开始下载，2:下载完成
  int downStatus = 0;
  int downPercentage = 0;

  CancelToken cancelToken = CancelToken();

  Future<void> appUpdate() async{
    if(Platform.isIOS){
      final url = Uri.parse('https://itunes.apple.com/cn/app/id${Config.iosAppId}');
      await launchUrl(url, mode: LaunchMode.externalApplication);
      return;
    }
    String? path = await getTempDirPath();
    if(path == null) return;
    if(widget.url == null) return;
    Uri uri = Uri.parse(widget.url!);
    path += Platform.pathSeparator + uri.pathSegments.last;
    savePath = path;
    downStatus = 1;
    cancelToken = CancelToken();
    if(mounted) setState(() {});
    try {
      WiseHttp().download(
        widget.url!, 
        path,
        cancelToken: cancelToken,
        onReceiveProgress: (count, total) {
          double p = count / total;
          downPercentage = (p * 100).toInt();
          if(mounted) setState(() {});
          if(count >= total){
            downStatus = 2;
            downPercentage = 0;
            if(mounted) setState(() {});
          }
        },
      );
    } catch (e) {
      ToastUtils.showToast(text: "下载失败");
    }
  }

  Future<String?> getTempDirPath() async{
    if (Platform.isWindows || Platform.isMacOS) {
      try {
        ToastUtils.showLoading();
        return await FilePicker.getDirectoryPath();
      } finally{
        ToastUtils.hideLoading();
      }
    } else {
      // 其他平台（Android/iOS）
      return (await getTemporaryDirectory()).path + Platform.pathSeparator + "app";
    }
  }

  Future<void> updateButton()async{ 
    if(downStatus == 0){
      appUpdate();
    }else if(downStatus == 1){

    }else if(downStatus == 2){//需要安卓安装权限
      try {
        bool permRes = await PermissionUtils.reqandroidInstallPermission(context);
        if(!permRes) return;

        ToastUtils.showLoading();
        OpenResult res = await OpenFile.open(savePath);
        if(res.type != ResultType.done){
          ToastUtils.showToast(text: "打开失败");
        }
      } catch (e) {
        downStatus = 0;
        downPercentage = 0;
        if(mounted) setState(() {});
        ToastUtils.showToast(text: "打开失败");
      } finally{
        ToastUtils.hideLoading();
      }
    }
  }



  Future<void> cleanButton() async{
    if(downStatus == 0){
      Get.back();
    }else if(downStatus == 1){
      cancelToken.cancel();
      downStatus = 0;
      downPercentage = 0;
      if(mounted) setState(() {});
    }else if(downStatus == 2){
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    String buttonText = "立即更新";
    String button1Text = "下次再说";
    if(downStatus == 1){
      buttonText = "正在下载...($downPercentage%)";
      button1Text = "取消下载";
    }else if(downStatus == 2){
      buttonText = "打开";
      button1Text = "下次再说";
    }


    return PopScope(
      canPop: !widget.forceUpdate,
      onPopInvokedWithResult: (didPop, result) {
        if(!widget.forceUpdate){
          AppCheckVersionDialog.setAppCheckDate();
        }
      },
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            width: 800.wMin,
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceSecondary,
              borderRadius: BorderRadius.circular(24.wMin),
              border: Border.all(
                color: AppTheme.cBorderFocus,
                width: 2.wMin,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22.wMin),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 280.wMin,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: -10.wMin,
                          width: 800.wMin,
                          height: 280.wMin,
                          child: Image.asset(
                            "assets/images/update_app/update_app_bg.png", 
                            fit: BoxFit.fill,
                          ),
                        ),
                        Positioned(
                          left: 72.wMin,
                          top: 75.wMin,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "发现新版本",
                                style: TextStyle(
                                  fontSize: 64.wMin,
                                  color: AppTheme.cStaticWhite,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "V ${widget.serviceVersion}",
                                style: TextStyle(
                                  fontSize: 40.wMin,
                                  color: AppTheme.cStaticWhite,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                            ],
                          ),
                        ),
                        Positioned(
                          right: 34.wMin,
                          top: 40.wMin,
                          child: SvgPicture.asset(
                            "assets/svg/public/icon_upapp_rocket.svg",
                            width: 207.wMin,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 24.wMin, horizontal: 72.wMin),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight: 250.wMin,
                            maxHeight: 500.wMin,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "更新内容:",
                                  style: TextStyle(
                                    fontSize: 32.wMin,
                                    color: AppTheme.cTextPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 16.wMin),
                                Text(
                                  widget.updateContent??"",
                                  style: TextStyle(
                                    fontSize: 24.wMin,
                                    color: AppTheme.cTextPrimary,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16.wMin),
                        ButtonWidget(
                          width: 480.wMin,
                          height: 64.wMin,
                          borderRadius: 12.wMin,
                          color: AppTheme.cSurfaceBrand,
                          text: buttonText,
                          fontColor: AppTheme.cStaticWhite,
                          fontSize: 28.wMin,
                          sclae: 1.01,
                          onTap: (){
                            updateButton();
                          },
                        ),
                        Visibility(
                          visible: !widget.forceUpdate,
                          child: Container(
                            margin: EdgeInsets.only(top: 28.wMin),
                            child: TapScaleWidget(
                              onTap: (){
                                cleanButton();
                              },
                              sclae: 1.05,
                              child: Text(
                                button1Text,
                                style: TextStyle(
                                  fontSize: 24.wMin,
                                  color: AppTheme.cTextQuaternary.color,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.wMin),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}