import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/date_time_picker_widget.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../utils/utils.dart';

class ExamPreparationTimeDialogReslut{
  /// 备考开始日期
  DateTime preparationSartDate;
  /// 考试当天日期
  DateTime testDate;
  ExamPreparationTimeDialogReslut({
    required this.preparationSartDate,
    required this.testDate,
  });
}

class ExamPreparationTimeDialog{

  static Future<ExamPreparationTimeDialogReslut?> show({
    required BuildContext context,
    void Function(ExamPreparationTimeDialogReslut? reslut)? onReslut,
    ExamPreparationTimeDialogReslut? init,
  }) async{
    return await showCupertinoDialog<ExamPreparationTimeDialogReslut?>(
      context: context,
      builder: (context) {
        return ExamPreparationTimeDialogWidget(init: init, onReslut: onReslut);
      },
    );
  }

}

class ExamPreparationTimeDialogWidget extends StatefulWidget {
  final ExamPreparationTimeDialogReslut? init;
  final void Function(ExamPreparationTimeDialogReslut? reslut)? onReslut;
  const ExamPreparationTimeDialogWidget({super.key, this.init, this.onReslut});

  @override
  State<ExamPreparationTimeDialogWidget> createState() => _ExamPreparationTimeDialogWidgetState();
}

class _ExamPreparationTimeDialogWidgetState extends State<ExamPreparationTimeDialogWidget> {
  DateTime preparationSartDate = DateTime.now();
  DateTime testDate = DateTime.now();

  
  @override
  void initState() {
    super.initState();
    if(widget.init != null){
      preparationSartDate = widget.init!.preparationSartDate;
      testDate = widget.init!.testDate;
    }
  }

  Future<void> selectPreparationSartDate(BuildContext ctx) async{
    DateTimePickerUtils.showDateCalender(
      context: ctx,
      initialDate: preparationSartDate,
      minDate: DateTime.now(),
      onTap: (date) {
        preparationSartDate = date;
        if(mounted) setState(() {});
      },
    );
  }

  Future<void> selectTestDate(BuildContext ctx) async{
    DateTimePickerUtils.showDateCalender(
      context: ctx,
      initialDate: testDate,
      maxDate: preparationSartDate.add(const Duration(days: 365)),
      minDate: DateTime.now(),
      onTap: (date) {
        testDate = date;
        if(mounted) setState(() {});
      },
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return CardDialogBoxWidget(
      title: "编辑备考时间",
      onCancel: () => Get.back(),
      onConfirm: () {
        if(preparationSartDate.isAfter(testDate)){
          return ToastUtils.showToast(text: "备考开始日期不能大于考试当天日期");
        }
        ExamPreparationTimeDialogReslut reslut = ExamPreparationTimeDialogReslut(
          preparationSartDate: preparationSartDate,
          testDate: testDate,
        );
        widget.onReslut?.call(reslut);
        Get.back(result: reslut);
      },
      child: Column(
        children: [
          SizedBox(height: 40.wMin),
          CardMinBoxWidget(
            title: "备考开始日期",
            backColor: Colors.transparent,
            borderColor: Colors.transparent,
            child: Builder(
              builder: (ctx) {
                return TapScaleWidget(
                  onTap: () => selectPreparationSartDate(ctx),
                  sclae: 1.05,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.wMin),
                      color: AppTheme.cBgTertiary.color,
                    ),
                    child: Text(
                      DateFormatUtil.formatStr(preparationSartDate, locale: Get.locale),
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 24.wMin),
          CardMinBoxWidget(
            title: "考试当天日期",
            backColor: Colors.transparent,
            borderColor: Colors.transparent,
            child: Builder(
              builder: (ctx) {
                return TapScaleWidget(
                  onTap: () => selectTestDate(ctx),
                  sclae: 1.05,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.wMin),
                      color: AppTheme.cBgTertiary.color,
                    ),
                    child: Text(
                      DateFormatUtil.formatStr(testDate, locale: Get.locale),
                      style: TextStyle(
                        fontSize: 24.wMin,
                       color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}