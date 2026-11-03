import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/common.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../app/routes/routes.dart';
import '../../utils/utils.dart';
import '../stores/user.dart';
import '../values/values.dart';
import 'widgets.dart';

class SystemPromptDialog {
  static Future<void> show({
    String? title,
    String? message,
  }) async {
    await Get.dialog(
      SystemPromptDialogWidget(
        title: title,
        message: message,
      ),
      barrierDismissible: false,
    );
  }
}

class SystemMaintenanceDialog {
  static void show({
    int? time,
    String? message,
  }) {
    Get.dialog(
      SystemMaintenanceDialogWidget(
        time: time,
        message: message,
      ),
      barrierDismissible: false,
      barrierColor: AppTheme.cBgPrimary.color,
    );
  }
}

class SystemPromptDialogWidget extends StatefulWidget {
  final String? title;
  final String? message;
  const SystemPromptDialogWidget({super.key, this.title, this.message});

  @override
  State<SystemPromptDialogWidget> createState() => _SystemPromptDialogWidgetState();
}

class _SystemPromptDialogWidgetState extends State<SystemPromptDialogWidget> {
  

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Material(
        color: AppTheme.cOverlayBackground.color,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.wMin),
            child: Container(
              width: 700.wMin,
              padding: EdgeInsets.all(40.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                color: AppTheme.cBgSecondary,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          widget.title ?? "温馨提示",
                          style: TextStyle(
                            fontSize: 28.wMin,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.cTextPrimary.color,
                          ),
                        ),
                      ),
                      SizedBox(height: 26.wMin),
                      Text(
                        (widget.message ?? "").isEmpty ? "" : widget.message ?? "",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 38.wMin),
                  ButtonWidget(
                    text: "确定",
                    height: 64.wMin,
                    fontColor: AppTheme.cStaticWhite.color,
                    fontSize: 24.wMin,
                    color: AppTheme.cSurfaceBrand.color,
                    borderRadius: 12.wMin,
                    sclae: 1.01,
                    onTap: () {
                      Get.back();
                    },
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

class SystemMaintenanceDialogWidget extends StatefulWidget {
  final int? time;
  final String? message;
  const SystemMaintenanceDialogWidget({super.key, this.time, this.message});

  @override
  State<SystemMaintenanceDialogWidget> createState() => _SystemMaintenanceDialogWidgetState();
}

class _SystemMaintenanceDialogWidgetState extends State<SystemMaintenanceDialogWidget> {

  final RxString buildType = "".obs;
  final RxString version = "".obs;
  final RxString appName = "".obs;
  int _tapCount = 0;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    getVersion();
  }

  Future<void> checkAppVersionText(BuildContext context) async {
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
    await UserStore.to.clearUserInfo();
    Get.offAllNamed(Routes.SPLASH);
  }

  /// 获取版本信息
  Future<void> getVersion() async {
    buildType.value = StorageUtil().getString(STORAGE_HTTP_ENV_KEY);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
    appName.value = packageInfo.appName;

    if (mounted) setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    String timeStr = "";
    if (widget.time != null) {
      DateTime timeDate = DateTime.fromMillisecondsSinceEpoch(widget.time!).toLocal();
      timeStr = DateFormatUtil.formatStr(timeDate, newPattern: "yyyy-MM-dd HH:mm");
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppTheme.cOverlayBackground.color,
        body: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.wMin),
            child: Container(
              width: 700.wMin,
              padding: EdgeInsets.all(40.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                color: AppTheme.cBgSecondary,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          "温馨提示",
                          style: TextStyle(
                            fontSize: 28.wMin,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.cTextPrimary.color,
                          ),
                        ),
                      ),
                      SizedBox(height: 26.wMin),
                      Text(
                        (widget.message ?? "").isEmpty ? "系统维护中，请稍后访问。" : widget.message ?? "",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                        ),
                      ),
                      Visibility(
                        visible: timeStr.isNotEmpty,
                        child: Text(
                          "预计恢复时间：$timeStr",
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cTextPrimary.color,
                            fontWeight: FontWeight.w500,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 38.wMin),
                  ButtonWidget(
                    text: "退出",
                    height: 64.wMin,
                    fontColor: AppTheme.cStaticWhite.color,
                    fontSize: 24.wMin,
                    color: AppTheme.cSurfaceBrand.color,
                    borderRadius: 12.wMin,
                    sclae: 1.01,
                    onTap: () {
                      if (Platform.isIOS || Platform.isWindows) {
                        exit(0);
                      } else {
                        SystemNavigator.pop();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _buildVersionWidget(),
      ),
    );
  }


   Widget _buildVersionWidget() {
    if (appName.value.isEmpty || version.value.isEmpty) {
      return const SizedBox();
    }
    String environment = "";
    if (buildType.value == HttpEnvKey.dev) {
      environment = "Dev ";
    } else if (buildType.value == HttpEnvKey.beta) {
      environment = "Beta ";
    }

    return Container(
      margin: EdgeInsets.only(right: 20.wMin),
      child: GestureDetector(
        onTap: () {
          checkAppVersionText(context);
        },
        child: Material(
          type: MaterialType.transparency,
          child: Text(
            "Version $environment${version.value}",
            style: TextStyle(
              color: AppTheme.cTextSecondary.color,
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

}
