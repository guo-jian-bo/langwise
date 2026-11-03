import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/values/storage.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/common.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../theme/theme.dart';

class NoticeDialog {
  static Future<String> show(BuildContext context, String msg) async {
    String? res = await showCupertinoDialog<String?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return NoticeDialogWidget(msg: msg);
      },
    );
    return res ?? '';
  }
}

class NoticeDialogWidget extends StatefulWidget {
  const NoticeDialogWidget({super.key, required this.msg});

  final String msg;

  @override
  State<NoticeDialogWidget> createState() => _NoticeDialogWidgetState();
}

class _NoticeDialogWidgetState extends State<NoticeDialogWidget> {
  String title = '温馨提示';
  bool isChecked = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: AppTheme.cOverlayBackground,
        child: Center(
          child: Stack(
            children: [
              Container(
                  width: 640.wMin,
                  padding: EdgeInsets.all(32.wMin),
                  decoration: BoxDecoration(
                    color: AppTheme.cSurfaceSecondary.color,
                    border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
                    borderRadius: BorderRadius.circular(16.wMin),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/svg/public/icon_toast_warning.svg', width: 48.wMin, height: 48.wMin),
                        SizedBox(width: 12.wMin),
                        Text(title, style: TextStyle(fontSize: 32.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextPrimary.color)),
                      ],
                    ),
                    SizedBox(height: 32.wMin),
                    Container(child: Text(widget.msg, style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextSecondary.color))),
                    SizedBox(height: 40.wMin),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: TapScaleWidget(
                        onTap: () {
                          isChecked = !isChecked;
                          if (mounted) setState(() {});
                        },
                        sclae: 1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              isChecked ? "assets/svg/public/icon_check_box.svg" : "assets/svg/public/icon_uncheck_box.svg",
                              width: 24.wMin,
                              height: 24.wMin,
                            ),
                            SizedBox(width: 8.wMin),
                            Text(
                              "今日不再提醒",
                              style: TextStyle(
                                color: AppTheme.cTextSecondary,
                                fontSize: 20.wMin,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 40.wMin),
                    Align(
                      alignment: Alignment.center,
                      child: _bottomBtn(),
                    ),
                  ])),
              Positioned(top: 10.wMin, right: 10.wMin, child: _backIcon()),
            ],
          ),
        ));
  }

  Widget _bottomBtn() {
    return GestureDetector(
      onTap: () {
        if (isChecked) {
          var nowTime = DateTime.now();
          StorageUtil().setString(SUB_LISTEN_NOT_REMIND_KEY, DateFormatUtil.formatStr(nowTime));
        }
        Get.back();
      },
      child: Container(
          width: 576.wMin,
          height: 68.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppTheme.cSurfaceTertiary.color, borderRadius: BorderRadius.circular(8.wMin)),
          child: Text('知道了', style: TextStyle(fontSize: 24.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextPrimary.color))),
    );
  }

  Widget _backIcon() {
    return TapScaleWidget(
      sclae: 1.05,
      onTap: () => Get.back(result: ''),
      child: Container(
        width: 42.wMin,
        height: 42.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: SvgPicture.asset(
          "assets/svg/public/x.svg",
          width: 24.wMin,
          height: 24.wMin,
        ),
      ),
    );
  }
}
