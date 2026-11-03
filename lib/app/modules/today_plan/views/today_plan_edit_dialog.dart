

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/https/https.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/static/static_data.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/utils.dart';

class TodayPlanEditDialog{

  static Future<bool> show({
    required BuildContext context,
    bool goldRatioSwitch = false,
    bool superMemo = false,
    int reviewLimit = 0,
  }) async {
    bool? res = await showCupertinoDialog(
      context: context,
      builder: (context) {
        return TodayPlanEditDialogWidget(
          goldRatioSwitch: goldRatioSwitch,
          superMemo: superMemo,
          reviewLimit: reviewLimit,
        );
      },
    );

    return res??false;
  }

}

class TodayPlanEditDialogWidget extends StatefulWidget {
  final bool goldRatioSwitch;
  final bool superMemo;
  final int reviewLimit;
  const TodayPlanEditDialogWidget({super.key, this.goldRatioSwitch = false, this.superMemo = false, this.reviewLimit = 0});

  @override
  State<TodayPlanEditDialogWidget> createState() => _TodayPlanEditDialogWidgetState();
}

class _TodayPlanEditDialogWidgetState extends State<TodayPlanEditDialogWidget> {

  bool goldRatioSwitch = false;
  bool superMemo = false;
  int reviewLimit = 0;

  @override
  void initState() {
    super.initState();
    goldRatioSwitch = widget.goldRatioSwitch;
    superMemo = widget.superMemo;
    reviewLimit = widget.reviewLimit;
  }

    /// 每日复习时长上限弹窗
  Future<void> timeSetUpDialog(BuildContext context) async{
    String? inputRes = await InputDialog.show(
      context: context,
      title: "设置每日复习题目数量",
      content: "请填写每日复习题目数量",
      hintText: "请输入数字",
      inputDesc: "输入0表示不限数量，最大可设置为999",
      keyboardType: TextInputType.number,
      maxLength: 3, //最大999
      realName: reviewLimit.toString(),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
    if(inputRes == null) return;
    int? value = int.tryParse(inputRes);
    if(value == null) return;
    reviewLimit = value;
    if(mounted) setState(() {});
  }

  Future<void> save() async{
    try {
      Map<String, dynamic> reqData = {
        "goldRatio": goldRatioSwitch,
        "superMemo": superMemo,
        "reviewLimit": {
          "language": Get.find<ConfigController>().userSetting.value.learningLang, 
          "enable": superMemo,
          "limit": reviewLimit,
        },
      };
      ToastUtils.showLoading();
      bool editRes = await StudyPlanRequest.createStudyPlan(reqData);
      ToastUtils.hideLoading();
      if(!editRes) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      Get.back(result: true);
    } catch (e) {
      ToastUtils.hideLoading();
    }
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
              Text(
                "编辑计划设置",
                style: TextStyle(
                  fontSize: 32.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 24.wMin),
              SizedBox(
                height: 64.wMin,
                child: CardTitleSwitchWidget(
                  title: "黄金学练",
                  backColor: AppTheme.cBgSecondary.color,
                  borderColor: AppTheme.cBorderPrimary.color,
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                  value: goldRatioSwitch,
                  onChanged: (val){
                    goldRatioSwitch = val;
                    if(mounted) setState(() {});
                  },
                ),
              ),

              SizedBox(height: 6.wMin),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                child: Text(
                  StaticData.goldRatioDesc,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextSecondary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              SizedBox(height: 24.wMin),
              SizedBox(
                height: 64.wMin,
                child: CardTitleSwitchWidget(
                  title: "超级记忆",
                  backColor: AppTheme.cBgSecondary,
                  borderColor: AppTheme.cBorderPrimary,
                  padding: EdgeInsets.symmetric(horizontal: 20.wMin),
                  value: superMemo,
                  onChanged: (val){
                    superMemo = val;
                    if(mounted) setState(() {});
                  },
                ),
              ),
              SizedBox(height: 6.wMin),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                child: Text(
                  StaticData.superMemoDesc,
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextSecondary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 24.wMin),

              DayReviewQuizNumberWidget(
                reviewLimit: reviewLimit,
                onTap: () {
                  timeSetUpDialog(context);
                },
              ),
              SizedBox(height: 24.wMin),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  color: AppTheme.cFeedbackWarningBackground.color,
                ),
                child: Text(
                  "温馨提示：当前设置修改，次日任务生效。",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cFeedbackWarningText.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              SizedBox(height: 32.wMin),
              Row(
                spacing: 24.wMin,
                children: [
                  Expanded(
                    child: ButtonWidget(
                      text: "取消",
                      sclae: 1.03,
                      color: AppTheme.cBgTertiary,
                      borderRadius: 8.wMin,
                      height: 56.wMin,
                      fontSize: 20.wMin,
                      fontColor: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w500,
                      onTap: () => Get.back(result: false),
                    ),
                  ),
                  Expanded(
                    child: ButtonWidget(
                      text: "确认编辑",
                      sclae: 1.03,
                      color: AppTheme.cSurfaceBrand,
                      borderRadius: 8.wMin,
                      height: 56.wMin,
                      fontSize: 20.wMin,
                      fontColor: AppTheme.cStaticWhite,
                      fontWeight: FontWeight.w500,
                      onTap: () {
                        save();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}