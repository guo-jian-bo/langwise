import 'package:flutter/material.dart';
import 'package:langwise/common/enum/specialty_enum.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../controllers/edit_today_plan_controller.dart';

class EditTodayPlanView extends GetView<EditTodayPlanController> {
  const EditTodayPlanView({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: AppTheme.cBgPrimary,
          body: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24.wMin, left: 80.wMin),
                child: const BackWidget(title: ""),
              ),
              Expanded(
                child: buildSelectCourses(context),
              ),
            ],
          ),
          // floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
          // floatingActionButton: _buildLevelWidget(),
        );
      }
    );
  }

  // Widget _buildLevelWidget(){
  //   return Container(
  //     width: 368.wMin,
  //     padding: EdgeInsets.all(16.wMin),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(12.wMin),
  //       color: AppTheme.cBgTertiary.color,
  //       border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
  //     ),
  //     child: Row(
  //       children: [
  //         Text(
  //           "我的语言水平",
  //           style: TextStyle(
  //             fontSize: 24.wMin,
  //             color: AppTheme.cTextPrimary.color,
  //             fontWeight: FontWeight.w400,
  //           ),
  //         ),
  //         SizedBox(width: 12.wMin),
  //         Text(
  //           "Level ${UserStore.to.userInfo.value.assessmentTier??0}",
  //           style: TextStyle(
  //             fontSize: 24.wMin,
  //             color: AppTheme.cTextPrimary.color,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget buildSelectCourses(BuildContext context){
    return Obx((){
      // int speedMultiplier = controller.dailyStudyDuration.value ~/ 5;
      // int completeMultiples = 0;
      // if(controller.learningReminderSwitch.value){
      //   int allLenght = 0;
      //   if(controller.werkDayList.isNotEmpty){
      //     allLenght += controller.werkWeeks.length;
      //   }
      //   if(controller.holidayDayList.isNotEmpty){
      //     allLenght += controller.holidayDaWeeks.length;
      //   }
      //   if(allLenght < 6){
      //     completeMultiples = allLenght;
      //   }else if(allLenght == 6){
      //     completeMultiples = 7;
      //   }else if(allLenght == 7){
      //     completeMultiples = 10;
      //   }
      // }

      String? planStartStr;
      if(controller.planLevelName.isNotEmpty && controller.planModuleName.isNotEmpty && controller.planUnitName.isNotEmpty){
        planStartStr = "${controller.planLevelName.value} / ${controller.planModuleName.value} / ${controller.planUnitName.value}";
      }

      return CardBoxWidget(
        height: 920.wMin,
        pageIndex: 0,
        currentPageIndex: 0,
        buttonDisable: controller.isDisable.value,
        onContinue: () {
          controller.save(context);
        },
        continueText: "保存",
        onClose: () {
          controller.deletePlan(context);
        },
        child: Column(
          children: [
            SizedBox(height: 32.wMin),
            const CardTitleIconTextWidget(
              title: "编辑计划",
              svg: "assets/svg/today_plan/icon_title2.svg",
            ),
            SizedBox(height: 28.wMin),
            // ListAnimationWidget(
            //   index: 1,
            //   child: CardTapArrowWidget(
            //     title: "语言水平",
            //     hintText: "请选择语言水平",
            //     value: controller.languageLevel.value.name?.text,
            //     showArrow: false,
            //     // onTap: () {
            //     //   controller.selectLanguageLevel(context);
            //     // },
            //   ),
            // ),
            // SizedBox(height: 24.wMin),
            CardTapArrowWidget(
              title: "选择课程",
              hintText: "请选择课程",
              showArrow: false,
              value: controller.course.value.courseName ?? "",
            ),

            SizedBox(height: 24.wMin),
            CardTapArrowWidget(
              title: "计划起点",
              hintText: "请选择计划起点",
              value: planStartStr,
              onTap: () {
                controller.selectPlanStart();
              },
            ),
            // Container(
            //   alignment: Alignment.centerLeft,
            //   child: Text(
            //     "温馨提示：当前设置修改，次日任务生效",
            //     style: TextStyle(
            //       fontSize: 20.wMin,
            //       color: AppTheme.cFeedbackErrorText,
            //       fontWeight: FontWeight.w400,
            //     ),
            //   ),
            // ),
            SizedBox(height: 24.wMin),
            CardTapArrowWidget(
              title: "每日学习时长",
              value: "${controller.dailyStudyDuration.value}分钟",
              onTap: () {
                controller.selectLearningDuration(context);
              },
            ),
            // Container(
            //   alignment: Alignment.centerLeft,
            //   child: Text(
            //     "温馨提示：当前设置修改，次日任务生效",
            //     style: TextStyle(
            //       fontSize: 20.wMin,
            //       color: AppTheme.cFeedbackErrorText,
            //       fontWeight: FontWeight.w400,
            //     ),
            //   ),
            // ),

            Visibility(
              visible: controller.course.value.startUnitInfo?.specialty != SpecialtyEnum.EN_PHONICS,
              child: Container(
                margin: EdgeInsets.only(top: 24.wMin),
                child: CardTapArrowCoustomWidget(
                  title: "课时类型",
                  onTap: () {
                    controller.selectLearningModule();
                  },
                  child: controller.selectLessonTypeList.length == controller.allLessonTypeList.length ? Text(
                    "默认全部",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w400,
                    ),
                  ) : Wrap(
                    spacing: 12.wMin,
                    runSpacing: 12.wMin,
                    children: List.generate(controller.selectLessonTypeList.length, (i){
                      LanguageText? title = LearningLangUtils.getLocalLang(controller.selectLessonTypeList[i].title);
                      return CardLabelWidget(
                        name: title?.text??"",
                        imageurl: controller.selectLessonTypeList[i].iconUrl,
                      );
                    }),
                  ),
                ),
              ),
            ),

            // Container(
            //   alignment: Alignment.centerLeft,
            //   child: Text(
            //     "温馨提示：当前设置修改，次日任务生效",
            //     style: TextStyle(
            //       fontSize: 20.wMin,
            //       color: AppTheme.cFeedbackErrorText,
            //       fontWeight: FontWeight.w400,
            //     ),
            //   ),
            // ),


            Visibility(
              visible: controller.nextUnit.isNotEmpty,
              child: Container(
                margin: EdgeInsets.only(top: 16.wMin),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(16.wMin),
                decoration: BoxDecoration(
                  color: AppTheme.cBgTertiary.color,
                  borderRadius: BorderRadius.circular(12.wMin),
                  border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "当前学习单元: ",
                          style: TextStyle(
                            fontSize: 22.wMin,
                            color: AppTheme.cTextSecondary.color,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            controller.planUnitName.value,
                            style: TextStyle(
                              fontSize: 22.wMin,
                              color: AppTheme.cTextBrand.color,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "预计学完当前单元: ",
                          style: TextStyle(
                            fontSize: 22.wMin,
                            color: AppTheme.cTextSecondary.color,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "需要 ${(controller.exerciseDuration.value / 60).round()} 分钟，预计 ${controller.nextUnitDay.value} 天到下一单元 ${controller.nextUnit.value}",
                            style: TextStyle(
                              fontSize: 22.wMin,
                              color: AppTheme.cTextBrand.color,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),

            SizedBox(height: 24.wMin),
            
            CardTitleSwitchWidget(
              title: "学习提醒",
              value: controller.learningReminderSwitch.value,
              onChanged: (value) => controller.changeLearningReminder(value, context),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: double.infinity,
                child: Visibility(
                  visible: controller.learningReminderSwitch.value,
                  child: Container(
                    margin: EdgeInsets.only(top: 12.wMin),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CardLearningReminderListWidget(
                            title: "工作日",
                            weeks: controller.werkWeeks.toList(),
                            list: controller.werkDayList.toList(),
                            onRemove: (index) {
                              controller.werkDayList.removeAt(index);
                            },
                            onAdd: () {
                              controller.showLearningReminderWindow(context);
                            },
                          ),
                        ),
                        SizedBox(width: 16.wMin),
                        Expanded(
                          child: CardLearningReminderListWidget(
                            title: "休息日",
                            weeks: controller.holidayDaWeeks.toList(),
                            list: controller.holidayDayList.toList(),
                            onRemove: (index) {
                              controller.holidayDayList.removeAt(index);
                            },
                            onAdd: () {
                              controller.showLearningReminderWindow(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.wMin),
            // ListAnimationWidget(
            //   index: 7,
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       CardTipAnimatedFlipCounterWidget(
            //         content: "学习速度是别人的",
            //         multiple: speedMultiplier,
            //       ),
            //       SizedBox(height: 12.wMin),
            //       CardTipAnimatedFlipCounterWidget(
            //         content: "学完概率是别人的",
            //         multiple: completeMultiples,
            //       ),
              
            //     ],
            //   ),
            // ),
          ],
        ),
      );
    });
  }
}
