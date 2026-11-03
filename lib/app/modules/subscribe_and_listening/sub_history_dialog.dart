import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/subscribe_and_listening/controller.dart';
import 'package:langwise/common/entities/user_reveal_push_record_entity.dart';
import 'package:langwise/common/values/star_colors.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';

class SubHistoryDialog {
  static Future<bool> show(BuildContext context) async {
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return SubHistoryDialogWidget();
      },
    );
    return res ?? false;
  }
}

class SubHistoryDialogWidget extends StatefulWidget {
  const SubHistoryDialogWidget({super.key});

  @override
  State<SubHistoryDialogWidget> createState() => _SubHistoryDialogWidgetState();
}

class _SubHistoryDialogWidgetState extends State<SubHistoryDialogWidget> {
  var controller = Get.find<SubListenController>();
  late UserRevealPushRecordEntity entity;
  @override
  void initState() {
    super.initState();

    entity = controller.pushRecord ?? UserRevealPushRecordEntity(pushNum: 0, averagePush: 0, averageRead: 0, readNum: 0, readRate: 0, readDetails: []);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.wMin),
          child: Container(
            width: 1000.wMin,
            height: 800.wMin,
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceSecondary.color,
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
            ),
            child: Stack(children: [
              Padding(
                padding: EdgeInsets.all(40.wMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('历史记录', style: TextStyle(fontSize: 32.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextPrimary)),
                    SizedBox(height: 6.wMin),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 16.wMin,
                      children: [_card('总推送', 0), _card('总甄听', 1), _card('完成率', 2)],
                    ),
                    SizedBox(height: 16.wMin),
                    Expanded(child: _historyList()),
                  ],
                ),
              ),
              Positioned(top: 6.wMin, right: 6.wMin, child: _backIcon()),
              Positioned(
                bottom: 0,
                child: Container(
                  width: 1000.wMin,
                  height: 62.wMin,
                  decoration: BoxDecoration(color: AppTheme.cSurfaceTertiary.color, border: Border(top: BorderSide(color: AppTheme.cBorderPrimary.color))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/svg/manage/icon_info_circle.svg',color: AppTheme.cSurfaceInfo.color, width: 24.wMin, height: 24.wMin),
                      SizedBox(width: 8.wMin),
                      Text('数据统计最近14天的推送和甄听情况', style: TextStyle(fontSize: 18.wMin, color: AppTheme.cTextTertiary.color))
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _historyList() {
    if(entity.readDetails == null) return const SizedBox.shrink();
    return ListView.builder(
      itemCount: entity.readDetails!.length,
      itemBuilder: (context, index) {
        var item = entity.readDetails![index];
        return Container(
          padding: EdgeInsets.all(16.wMin),
          margin: EdgeInsets.only(bottom: index == entity.readDetails!.length - 1 ? 64.wMin : 16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            border: Border.all(color: item.isToday ?? false ? AppTheme.cBorderBrand.color : AppTheme.cBorderSecondary.color),
          ),
          child: Column(
            children: [
              Row(children: [
                Text('${item.dateTime} ${item.week}',
                    style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500, color: item.isToday ?? false ? AppTheme.cTextBrand.color : AppTheme.cTextPrimary.color)),
                if (item.isToday ?? false)
                  Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(left: 8.wMin),
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 7.wMin),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(99.wMin), color: AppTheme.cFeedbackInfoBackground.color),
                      child: Text('今日', style: TextStyle(fontSize: 22.wMin, color: AppTheme.cTextBrand.color))),
                Spacer(),
                Text('上限 ${item.pushMaxNum ?? 0}篇', style: TextStyle(fontSize: 18.wMin, color: AppTheme.cTextTertiary.color))
              ]),
              SizedBox(height: 16.wMin),
              Container(
                padding: EdgeInsets.all(12.wMin),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.wMin),
                  color: AppTheme.cSurfaceTertiary.color,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text.rich(
                            TextSpan(children: [
                              TextSpan(text: "推送"),
                              TextSpan(text: "${item.pushNum}", style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500, color: AppTheme.cTextPrimary.color)),
                              TextSpan(text: "篇"),
                            ]),
                            style: TextStyle(fontSize: 22.wMin, color: AppTheme.cTextTertiary.color)),
                        Spacer(),
                        Text.rich(
                            TextSpan(children: [
                              TextSpan(text: "甄听"),
                              TextSpan(text: "${item.readNum}", style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500, color: AppTheme.cTextBrand.color)),
                              TextSpan(text: "篇"),
                            ]),
                            style: TextStyle(fontSize: 22.wMin, color: AppTheme.cTextTertiary.color))
                      ],
                    ),
                    SizedBox(height: 8.wMin),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('甄听进度', style: TextStyle(fontSize: 22.wMin, color: AppTheme.cTextTertiary.color)),
                        Spacer(),
                        Text('${item.readRate?.floor()??0}%', style: TextStyle(fontSize: 22.wMin, color: AppTheme.cTextTertiary.color)),
                      ],
                    ),
                    SizedBox(height: 8.wMin),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: ((item.readRate??0) / 100),
                        backgroundColor: AppTheme.cSurfaceSecondary.color,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.cInversePrimary.color),
                        minHeight: 12.wMin,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.wMin),
              Row(children: [
                if (item.isReadFinish ?? false)
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 7.wMin),
                      margin: EdgeInsets.only(right: 6.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99.wMin),
                        color: AppTheme.cFeedbackSuccessBackground.color,
                      ),
                      alignment: Alignment.center,
                      child: Text('全部读完', style: TextStyle(fontSize: 22.wMin, color: AppTheme.cSurfaceSuccess.color))),
                if (item.isDataLack ?? false)
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 7.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99.wMin),
                        color: AppTheme.cFeedbackWarningBackground.color,
                      ),
                      alignment: Alignment.center,
                      child: Text('内容不足，未推满', style: TextStyle(fontSize: 22.wMin, color: AppTheme.cFeedbackWarningText.color)))
              ])
            ],
          ),
        );
      },
    );
  }

  Widget _card(String title, int type) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: AppTheme.cSurfaceTertiary.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 22.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextTertiary.color)),
            Text(
                '${type == 0 ? entity.pushNum == 0 ? 0 : entity.pushNum : type == 1 ? entity.readNum == 0 ? 0 : entity.readNum : entity.readRate == 0 ? 0 : entity.readRate?.toStringAsFixed(1) ?? "0"}',
                style: TextStyle(fontSize: 40.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextPrimary.color)),
            Text(
                type == 2
                    ? "已推 / 已读"
                    : "平均 ${type == 0 ? entity.averagePush == 0 ? 0 : entity.averagePush?.toStringAsFixed(1) ?? "0" : entity.averageRead == 0 ? 0 : entity.averageRead?.toStringAsFixed(1) ?? "0"} / 天",
                style: TextStyle(fontSize: 18.wMin, color: AppTheme.cTextQuaternary.color)),
          ],
        ),
      ),
    );
  }

  Widget _backIcon() {
    return TapScaleWidget(
      sclae: 1.05,
      onTap: () => Get.back(),
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
