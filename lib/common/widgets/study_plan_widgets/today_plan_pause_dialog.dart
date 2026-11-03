import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../date_time_picker_widget.dart';
import '../widgets.dart';

class TodayPlanPauseDialogResult{
  /// 0无期限 1自定义日期
  int recoverType;
  /// 自定义日期
  DateTime? recoverDate;

  TodayPlanPauseDialogResult({
    required this.recoverType,
    this.recoverDate,
  });
}

class TodayPlanPauseDialog {
  /// 返回：null无修改 0无期限 1自定义日期
  static Future<TodayPlanPauseDialogResult?> show({
    required BuildContext context,
    String? planInfoText,
  }) async {
    return await showCupertinoDialog<TodayPlanPauseDialogResult?>(
      context: context,
      builder: (context) {
        return TodayPlanPauseDialogWidget(planInfoText: planInfoText);
      },
    );
  }
}

class TodayPlanPauseDialogWidget extends StatefulWidget {
  final String? planInfoText;

  const TodayPlanPauseDialogWidget({super.key, this.planInfoText});

  @override
  State<TodayPlanPauseDialogWidget> createState() => _TodayPlanPauseDialogWidgetState();
}

class _TodayPlanPauseDialogWidgetState extends State<TodayPlanPauseDialogWidget> {
  int _recoverType = 0;

  DateTime? _recoverDate;

  Future<void> _onSelectDate() async{
    DateTime? res = await DateTimePickerUtils.showYMD(
      title: "请选择恢复日期",
      context: context,
      initialDate: _recoverDate,
      minDate: DateTime.now().add(const Duration(days: 1)),
    );
    if(res == null) return;
    _recoverDate = res;
    if(mounted) setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Center(
        child: Container(
          width: 640.wMin,
          padding: EdgeInsets.all(32.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cBgSecondary.color,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          "要暂停学习新内容吗？",
                          style: TextStyle(
                            fontSize: 32.wMin,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.cTextPrimary.color,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.wMin),
                      Text.rich(TextSpan(
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextSecondary.color,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          const TextSpan(
                            text: "暂停后，系统将不再为您安排新内容的学习，但会保留已学知识的复习任务，帮您巩固记忆。您可以随时恢复学习。",
                          ),
                          TextSpan(
                            text: widget.planInfoText ?? "",
                            style: TextStyle(
                              fontSize: 24.wMin,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cTextPrimary.color,
                            ),
                          ),

                        ],
                      )),
                      SizedBox(height: 24.wMin),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            "恢复日期",
                            style: TextStyle(
                              fontSize: 24.wMin,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cTextPrimary.color,
                            ),
                          ),
                          _buildPauseIndefiniteWidget(),
                          SizedBox(height: 12.wMin),
                          _buildPauseDateWidget(),
                        ],
                      ),

                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: TapScaleWidget(
                      sclae: 1.05,
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 42.wMin,
                        height: 42.wMin,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.cBgActive,
                        ),
                        child: SvgPicture.asset(
                          "assets/svg/public/x.svg",
                          width: 24.wMin,
                          height: 24.wMin,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 38.wMin),
              ButtonWidget(
                text: "确认暂停",
                height: 74.wMin,
                fontColor: AppTheme.cStaticWhite.color,
                fontSize: 28.wMin,
                color: AppTheme.cFeedbackWarningBorder.color,
                borderRadius: 12.wMin,
                sclae: 1.02,
                onTap: () {
                  if(_recoverType == 1 && _recoverDate == null){
                    ToastUtils.showToast(text: "请选择恢复日期");
                    return;
                  }

                  TodayPlanPauseDialogResult result = TodayPlanPauseDialogResult(
                    recoverType: _recoverType,
                    recoverDate: _recoverType == 0 ? null : _recoverDate,
                  );

                  Get.back(result: result);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 无期限
  Widget _buildPauseIndefiniteWidget(){
    return TapScaleWidget(
      sclae: 1.008,
      onTap: (){
        _recoverType = 0;
        if(mounted) setState(() {});
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: AppTheme.cBgTertiary.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "无期限",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
                const Spacer(),
                SvgPicture.asset(
                  _recoverType == 0 ? "assets/svg/public/icon_radio.svg" : "assets/svg/public/icon_radio_un.svg",
                  height: 32.wMin,
                ),
              ],
            ),
            SizedBox(height: 10.wMin),
            Text(
              "需要手动恢复",
              style: TextStyle(
                fontSize: 22.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 定时恢复
  Widget _buildPauseDateWidget(){
    return TapScaleWidget(
      sclae: 1.005,
      onTap: (){
        _recoverType = 1;
        if(mounted) setState(() {});
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: AppTheme.cBgTertiary.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "自定义日期",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
                const Spacer(),
                SvgPicture.asset(
                  _recoverType == 1 ? "assets/svg/public/icon_radio.svg" : "assets/svg/public/icon_radio_un.svg",
                  height: 32.wMin,
                ),
              ],
            ),
            SizedBox(height: 10.wMin),
            Text(
              "将于指定日期自动恢复，在此之前也可以手动恢复",
              style: TextStyle(
                fontSize: 22.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
            SizedBox(height: 10.wMin),
            TapScaleWidget(
              sclae: 1.01,
              onTap: (){
                _onSelectDate();
              },
              child: Container(
                padding: EdgeInsets.all(16.wMin),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12.wMin),
                  border: Border.all(
                    color: AppTheme.cBorderSecondary.color,
                    width: 1.wMin,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _recoverDate == null ? "请选择日期" : DateFormatUtil.formatStr(_recoverDate!),
                      style: TextStyle(
                        fontSize: 22.wMin,
                        fontWeight: FontWeight.w400,
                        color: _recoverDate == null ? AppTheme.cTextTertiary.color : AppTheme.cTextPrimary.color,
                      ),
                    ),
                    const Spacer(),
                    SvgPicture.asset(
                      "assets/svg/public/icon_w_arrow_right.svg",
                      height: 32.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
            ),
      
          ],
        ),
      ),
    );
  }

}
