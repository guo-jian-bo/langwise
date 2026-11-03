import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/create_study_plan/controllers/new_create_study_plan_controller.dart';
import 'package:langwise/common/widgets/card_public_widgets.dart';
import 'package:langwise/common/widgets/icon_dropdown_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';



class StudyTimeChooseDialog {
  static Future<String> show(BuildContext context) async {
    String? res = await showCupertinoDialog<String?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StudyTimeChooseDialogWidget();
      },
    );
    return res ?? '';
  }
}

class StudyTimeChooseDialogWidget extends StatefulWidget {
  const StudyTimeChooseDialogWidget({super.key});

  @override
  State<StudyTimeChooseDialogWidget> createState() {
    return _StudyTimeChooseDialogWidgetState();
  }
}

class _StudyTimeChooseDialogWidgetState extends State<StudyTimeChooseDialogWidget> {
  final List<IconDropdownCheckData> weekSystemList = [
    IconDropdownCheckData(title: "双休制"),
    IconDropdownCheckData(title: "自定义"),
  ];
  List<String> weekList = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
  int weekSysteIndex = 0;
  List<int> weekSelectList = [1,2,3,4,5];
  bool isHolidaySwitch = true;
  final controller = Get.find<NewCreateStudyPlanController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    weekList = controller.weekList;
    isHolidaySwitch = controller.holidayAdjustment.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cOverlayBackground,
      body: Center(
        child: Container(
          width: 1028.wMin,
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceSecondary.color,
            borderRadius: BorderRadius.circular(24.wMin),
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.wMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 32.wMin),
                    Align(alignment: Alignment.center, child: Text('自定义学习时间安排', style: TextStyle(fontSize: 32.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextPrimary))),
                    SizedBox(height: 24.wMin),
                    Text('学习时间安排', style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500, color: AppTheme.cTextTertiary)),
                    SizedBox(height: 4.wMin),
                    IconDropdownCheckWidget(
                      sclae: 1.01,
                      selectIndex: weekSysteIndex,
                      onTap: (data, index) {
                        weekSysteIndex = index;
                        if (mounted) {
                          setState(() {
                            if (weekSysteIndex == 0) {
                              weekSelectList.clear();
                              weekSelectList.addAll({1, 2, 3, 4, 5});
                            } else {
                            }
                          });
                        }
                      },
                      items: weekSystemList,
                      child: CardMinBoxWidget(
                        title: weekSystemList[weekSysteIndex].title,
                        backColor: AppTheme.cBgTertiary.color,
                        borderColor: AppTheme.cBorderPrimary.color,
                        child: SvgPicture.asset("assets/svg/public/icon_code.svg", width: 24.wMin),
                      ),
                    ),
                    SizedBox(height: 40.wMin),
                    Text('自定义工作日', style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500, color: AppTheme.cTextTertiary)),
                    SizedBox(height: 4.wMin),
                    Row(
                        spacing: 9.wMin,
                        children: List.generate(weekList.length, (index) {
                          bool isSelected = weekSelectList.contains(index);
                          return Expanded(
                              child: GestureDetector(
                            onTap: () {
                              if (weekSelectList.contains(index)) {
                                weekSelectList.remove(index);
                              } else {
                                weekSelectList.add(index);
                              }
                              if (!weekSelectList.contains(0) && !weekSelectList.contains(6) && weekSelectList.length == 5) {
                                weekSysteIndex = 0;
                              } else {
                                weekSysteIndex = 1;
                              }
                              setState(() {
                                
                              });
                            },
                            child: Container(
                              height: 56.wMin,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  border: Border.all(color: isSelected ? AppTheme.cFeedbackInfoBorder : Colors.transparent),
                                  color: isSelected ? AppTheme.cFeedbackInfoBackground : AppTheme.cSurfaceTertiary.color,
                                  borderRadius: BorderRadius.circular(8.wMin)),
                              child: Text(weekList[index], style: TextStyle(fontSize: 24.wMin, fontWeight: FontWeight.w600, color: AppTheme.cTextSecondary)),
                            ),
                          ));
                        }).toList()),
                    SizedBox(height: 40.wMin),
                    Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
                    SizedBox(height: 24.wMin),
                    CardTitleSwitchWidget(
                      title: "智能把节假日当作休息日",
                      subContent: "节假日（春节、国庆等）当做休息日提醒，同时调休上班日当做工作日提醒",
                      value: isHolidaySwitch,
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            isHolidaySwitch = value;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 40.wMin),
                    Row(children: [
                      Expanded(
                          child: GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(
                                height: 72.wMin,
                                alignment: Alignment.center,
                                child: Text('取消', style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500, color: AppTheme.cTextTertiary)),
                                decoration: BoxDecoration(color: AppTheme.cSurfaceTertiary.color, borderRadius: BorderRadius.circular(12.wMin)),
                              ))),
                      SizedBox(width: 12.wMin),
                      Expanded(
                          child: GestureDetector(
                              onTap: (){
                                controller.weekdayWeeks.value = weekSelectList;
                                controller.holidayWeeks.value = [0,1,2,3,4,5,6].where((e)=>!weekSelectList.contains(e)).toList();
                                controller.isDoubleRestDay.value = weekSysteIndex==0;
                                controller.holidayAdjustment.value = isHolidaySwitch;
                                if(controller.weekdayWeeks.isEmpty){
                                  return ToastUtils.showToast(text: "工作日不允许为空");
                                }
                                if(controller.holidayWeeks.isEmpty){
                                  return ToastUtils.showToast(text: "休息日不允许为空");
                                }
                                Get.back();
                              },
                              child: Container(
                                height: 72.wMin,
                                alignment: Alignment.center,
                                child: Text('确定', style: TextStyle(fontSize: 28.wMin, fontWeight: FontWeight.w500, color: AppTheme.cTextPrimary)),
                                decoration: BoxDecoration(color: AppTheme.cSurfaceInfo.color, borderRadius: BorderRadius.circular(12.wMin)),
                              ))),
                    ]),
                    SizedBox(height: 40.wMin)
                  ],
                ),
              ),
              Positioned(
                top: 20.wMin,
                right: 16.wMin,
                child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: SvgPicture.asset('assets/svg/public/x.svg', width: 24.wMin, height: 24.wMin)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
