
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

    String appChannel = AppBuildChannelUtils.getAppChannel();

    AppCheckEntity? checkRes = await UserRequest.getAppLastVersion(platform, version: localVersion, appChannel: appChannel);
    if(checkRes == null) return false;

    // checkRes.forbidDownload = false;
    // checkRes.jump = AppCheckEntityJump(
    //   code: "systemAppMarket",
    //   url: "zpapp://com.zuoyebang.iot.pad.appstore/detail?id=4918",
    // );
    // checkRes.upgradeTips = "新版本已发布！去【应用商店】更新，即刻解锁更流畅的学习体验。";

    if(checkRes.forceUpgrade == false){
      setAppCheckDate();
    }

    _showUpdateDialog(
      data: checkRes,
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
    required AppCheckEntity data,
  }) async{

    if(Get.context == null) return;
    await showCupertinoDialog(
      context: Get.context!,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (context){
        return AppUpdateDialogWidget(
          data: data,
        );
      },
    );
  }
}

class AppUpdateDialogWidget extends StatefulWidget {
  final AppCheckEntity data;
  const AppUpdateDialogWidget({
    super.key, 
    required this.data,
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

  /// 更新app
  Future<void> appUpdate() async{
    if(Platform.isIOS){
      appUpdateIOS();
      return;
    }
    appUpdateDownload();
  }

  /// 更新ios 跳转至app store
  Future<void> appUpdateIOS() async{
    final url = Uri.parse('https://itunes.apple.com/cn/app/id${Config.iosAppId}');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  /// 更新 直接下载
  Future<void> appUpdateDownload() async{
    String? path = await getTempDirPath();
    if(path == null) return;
    if(widget.data.url == null) return;
    Uri uri = Uri.parse(widget.data.url!);
    path += Platform.pathSeparator + uri.pathSegments.last;
    savePath = path;
    downStatus = 1;
    cancelToken = CancelToken();
    if(mounted) setState(() {});
    try {
      WiseHttp().download(
        widget.data.url!, 
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
      return "${(await getTemporaryDirectory()).path}${Platform.pathSeparator}app";
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
    
    return PopScope(
      canPop: !(widget.data.forceUpgrade??false),
      onPopInvokedWithResult: (didPop, result) {
        if(!(widget.data.forceUpgrade??false)){
          AppCheckVersionDialog.setAppCheckDate();
        }
      },
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            width: 1200.wMin,
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceSecondary,
              borderRadius: BorderRadius.circular(24.wMin),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitleWidget(),
                _buildContentWidget(),

                Container(
                  height: 1.wMin,
                  color: AppTheme.cBorderPrimary.color,
                ),
            
                _buildButtonsWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildTitleWidget(){
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 147.wMin,
          width: double.infinity,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 40.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceBrand.color,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.wMin)),
          ),
          child: Text(
            "发现新版本 V ${widget.data.version??""}",
            style: TextStyle(
              fontSize: 56.wMin,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Positioned(
          top: -60.wMin,
          right: 0,
          child: Image.asset(
            "assets/images/public/app_upload_rocket.png",
            height: 187.wMin,
          ),
        ),
      ],
    );
  }

  Widget _buildContentWidget(){
    List<AppCheckEntityHistories?> histories = widget.data.histories??[];
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minWidth: 400.wMin,
        maxHeight: 600.wMin,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(40.wMin),
        child: Column(
          spacing: 24.wMin,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(histories.length, (index){
            if(index == 0){
              return _buildContentFirstItemWidget(history: histories[index]);
            }
            return _buildContentItemWidget(history: histories[index]);
          }),
        ),
      ),
    );
  }

  Widget _buildContentFirstItemWidget({
    required AppCheckEntityHistories? history,
  }){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          history?.title??"",
          style: TextStyle(
            fontSize: 28.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10.wMin),
        Text(
          history?.contents??"",
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w400,
            height: 1.8,
          ),
        ),

        SizedBox(height: 24.wMin),

      ],
    );
  }


  Widget _buildContentItemWidget({
    required AppCheckEntityHistories? history,
  }){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible: history?.stress??false,
              child: Container(
                margin: EdgeInsets.only(right: 8.wMin),
                child: Icon(Icons.star, size: 24.wMin, color: AppTheme.cTextPrimary.color),
              ),
            ),
            Text(
              history?.title??"",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Visibility(
              visible: history?.stress??false,
              child: Container(
                margin: EdgeInsets.only(left: 8.wMin),
                child: Icon(Icons.star, size: 24.wMin, color: AppTheme.cTextPrimary.color),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.wMin),
        Text(
          history?.contents??"",
          style: TextStyle(
            fontSize: 20.wMin,
            color: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w400,
            height: 1.8,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonsWidget(){
    if(widget.data.forbidDownload == false){
      return _buildButtonsTipWidget();
    }

    return _buildButtonsDownloadWidget();
  }

  Widget _buildButtonsTipWidget(){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.wMin, horizontal: 40.wMin),
      child: Row(
        children: [

          Expanded(
            child: Text(
              widget.data.upgradeTips??"",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          
          Visibility(
            visible: !(widget.data.forceUpgrade??false),
            child: SizedBox(width: 12.wMin),
          ),
          Visibility(
            visible: !(widget.data.forceUpgrade??false),
            child: ButtonWidget(
              height: 64.wMin,
              width: 314.wMin,
              borderRadius: 8.wMin,
              color: AppTheme.cSurfaceLayerElevated.color,
              border: Border.all(
                color: AppTheme.cBorderSubtle.color,
                width: 0.8.wMin,
              ),
              text: "稍后再说",
              fontColor: AppTheme.cTextSecondary.color,
              fontSize: 24.wMin,
              sclae: 1.01,
              onTap: (){
                cleanButton();
              },
            ),
          ),
          Visibility(
            visible: widget.data.jump != null,
            child: SizedBox(width: 12.wMin),
          ),

          Visibility(
            visible: widget.data.jump != null,
            child: ButtonWidget(
              height: 64.wMin,
              width: 314.wMin,
              borderRadius: 8.wMin,
              color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.1),
              border: Border.all(
                color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                width: 1.wMin,
              ),
              text: "立即更新",
              fontColor: AppTheme.cSurfaceBrand.color,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
              sclae: 1.01,
              onTap: (){
                JumpPageUtils.jumpUserPages(widget.data.jump);
              },
            ),
          ),

          
        ],
      ),
    );
  }

  Widget _buildButtonsDownloadWidget(){
    String buttonText = "立即更新";
    String button1Text = "稍后再说";
    if(downStatus == 1){
      buttonText = "正在下载...($downPercentage%)";
      button1Text = "取消下载";
    }else if(downStatus == 2){
      buttonText = "打开";
      button1Text = "稍后再说";
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.wMin, horizontal: 40.wMin),
      child: Row(
        children: [

          Visibility(
            visible: !(widget.data.forceUpgrade??false),
            child: Expanded(
              child: ButtonWidget(
                height: 64.wMin,
                borderRadius: 8.wMin,
                color: AppTheme.cSurfaceLayerElevated.color,
                border: Border.all(
                  color: AppTheme.cBorderSubtle.color,
                  width: 0.8.wMin,
                ),
                text: button1Text,
                fontColor: AppTheme.cTextSecondary.color,
                fontSize: 24.wMin,
                sclae: 1.01,
                onTap: (){
                  cleanButton();
                },
              ),
            ),
          ),

          Visibility(
            visible: !(widget.data.forceUpgrade??false),
            child: SizedBox(width: 12.wMin),
          ),
          
          Expanded(
            child: ButtonWidget(
              height: 64.wMin,
              borderRadius: 8.wMin,
              color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.1),
              border: Border.all(
                color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                width: 1.wMin,
              ),
              text: buttonText,
              fontColor: AppTheme.cSurfaceBrand.color,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
              sclae: 1.01,
              onTap: (){
                updateButton();
              },
            ),
          ),
        ],
      ),
    );
  }



}