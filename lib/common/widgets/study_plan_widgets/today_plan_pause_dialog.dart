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

  static Future<bool> showPauseDialog({
    required BuildContext context,
    required bool isPause,
    Color? primaryColor,
  }) async{
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return TodayPlanPauseDialog1Widget(isPause: isPause, primaryColor: primaryColor);
      },
    );
    return res??false;
  }


}


class TodayPlanPauseDialog1Widget extends StatefulWidget {
  final bool isPause;
  final Color? primaryColor;
  const TodayPlanPauseDialog1Widget({super.key, this.isPause = false, this.primaryColor});

  @override
  State<TodayPlanPauseDialog1Widget> createState() => _TodayPlanPauseDialog1WidgetState();
}

class _TodayPlanPauseDialog1WidgetState extends State<TodayPlanPauseDialog1Widget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Center(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(32.wMin),
              width: 720.wMin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.wMin),
                color: AppTheme.cSurfaceSecondary.color,
                border: Border.all(
                  color: AppTheme.cBorderPrimary.color,
                  width: 1.wMin,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleWidget(),
                  SizedBox(height: 24.wMin),
                  _buildContentWidget(),
                  SizedBox(height: 24.wMin),
                  Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
                  SizedBox(height: 40.wMin),
                  _buildButtonWidget(),
                ],
              ),
            ),
            Positioned(
              right: 16.wMin,
              top: 16.wMin,
              child: TapScaleWidget(
                sclae: 1.05,
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 48.wMin,
                  height: 48.wMin,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${widget.isPause ? "暂停" : "恢复"}新内容学习？",
          style: TextStyle(
            fontSize: 32.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SizedBox(height: 12.wMin),
        Text(
          widget.isPause ? "暂停后不再安排这门课的新内容，复习继续进行。" : "恢复后继续当前计划，新内容和复习都会正常安排。",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
      ],
    );
  }

  Widget _buildContentWidget(){

    List<String> pauseContents = widget.isPause ? [
      "这门课的新内容暂停安排",
      "已学内容继续复习",
      "空出来的时间转给复习和其他课程",
    ] :  [
      "从当前进度继续学习",
      "新内容和复习一起恢复",
      "分配给其他课程的时间会回到当前课程",
    ];

    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceLayerElevated2.color,
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isPause ? "暂停后会发生什么" : "恢复后会发生什么",
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          SizedBox(height: 12.wMin),
          Container(
            height: 1.wMin,
            width: double.infinity,
            color: AppTheme.cBorderDefault.color,
          ),
          SizedBox(height: 12.wMin),
          Text(
            widget.isPause ? "每日时长不变，时间自动重分配" : "当前计划恢复，时长回到这门课",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(height: 16.wMin),
          Column(
            spacing: 16.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(pauseContents.length, (index){

              return Row(
                spacing: 8.wMin,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: widget.primaryColor,
                    size: 24.wMin,
                  ),
                  Expanded(
                    child: Text(
                      pauseContents[index],
                      style: TextStyle(
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextSecondary.color,
                      ),
                    ),
                  ),
                ],
              );

            }),
          ),


        ],
      ),
    );
  }

  Widget _buildButtonWidget(){
    return ButtonWidget(
      text: widget.isPause ? "确认暂停" : "确认恢复",
      width: double.infinity,
      height: 56.wMin,
      borderRadius: 8.wMin,
      color: (widget.primaryColor ?? AppTheme.cSurfaceBrand.color).withValues(alpha: 0.3),
      border: Border.all(
        color: (widget.primaryColor ?? AppTheme.cSurfaceBrand.color).withValues(alpha: 0.12),
        width: 1.wMin,
      ),
      fontSize: 24.wMin,
      fontWeight: FontWeight.w500,
      fontColor: (widget.primaryColor ?? AppTheme.cSurfaceBrand.color),
      sclae: 1.01,
      onTap: () {
        Get.back(result: true);
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
