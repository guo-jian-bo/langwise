
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/stores/stores.dart';
import '../../../../common/widgets/learning_reminder_widget.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/utils.dart';
import '../controllers/create_study_plan_controller.dart';

class CreateStudyPlanView extends GetView<CreateStudyPlanController> {
  const CreateStudyPlanView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: AppTheme.cBgPrimary,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24.wMin, left: 80.wMin),
                child: const BackWidget(),
              ),
              Expanded(
                child: SizedBox(
                  child: Obx((){
                    return PageView(
                      controller: controller.pageController,
                      children: [
                        _buildSelectCoursesWidget(context),
                        if(controller.isShowSelectLessonType.value) _buildSelectModuleWidget(context),
                        if(controller.isShowLearningReminder.value) _buildStudyReminderWidget(context),
                        // ...List.generate(controller.courseList.length, (index){
                        //   return buildSelectCourses(controller.courseList[index], index);
                        // })
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  /// 课程
  Widget _buildSelectCoursesWidget(BuildContext context){

    String? planStartStr;
    if(controller.planLevelName.isNotEmpty && controller.planModuleName.isNotEmpty){
      planStartStr = "${controller.planLevelName} / ${controller.planModuleName}";
    }
    if(planStartStr != null && controller.planUnitName.isNotEmpty){
      planStartStr += " / ${controller.planUnitName}";
    }

    return CardBoxWidget(
      pageIndex: 0,
      height: 1000.wMin,
      currentPageIndex: controller.currentPageIndex.value,
      onContinue: () => controller.continueAddCourse(context),
      child: Column(
        children: [
          SizedBox(height: 24.wMin),
          Text(
            "创建学习计划",
            style: TextStyle(
              fontSize: 36.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 87.wMin),
          Text(
            "评测等级",
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextSecondary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.wMin),
          
          Row(
            spacing: 10.wMin,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/svg/public/icon_union_left.svg",
                height: 85.wMin,
              ),
              Obx((){
                int? assessmentTier = UserStore.to.userInfo.value.assessmentTier;
                if(assessmentTier == null){
                  return Text(
                    "暂无等级",
                    style: TextStyle(
                      fontSize: 56.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }
                return Text(
                  "Level ${UserStore.to.userInfo.value.assessmentTier??0}",
                  style: TextStyle(
                    fontSize: 56.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }),
              SvgPicture.asset(
                "assets/svg/public/icon_union_right.svg",
                height: 85.wMin,
              ),
            ],
          ),

          SizedBox(height: 24.wMin),

          Obx((){
            int? assessmentTier = UserStore.to.userInfo.value.assessmentTier;
            if(assessmentTier == null){
              return ButtonWidget(
                text: "去评测",
                width: 132.wMin,
                height: 52.wMin,
                borderRadius: 12.wMin,
                color: AppTheme.cFeedbackWarningBackground.color,
                fontColor: AppTheme.cFeedbackWarningText.color,
                fontSize: 28.wMin,
                fontWeight: FontWeight.w500,
                sclae: 1.03,
                onTap: () {
                  controller.goToEvaluate(context);
                },
              );
            }
            return TapScaleWidget(
              onTap: () {
                controller.goToEvaluate(context);
              },
              sclae: 1.03,
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4.wMin,
                  children: [
                    Text(
                      "重新评测",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextBrand.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Container(
                      width: 32.wMin,
                      height: 32.wMin,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.cBgBrand.color,
                      ),
                      child: SvgPicture.asset(
                        "assets/svg/public/icon_w_arrow_right.svg",
                        width: 24.wMin,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          

          SizedBox(height: 56.wMin),

          CardTapArrowWidget(
            title: "根据水平推荐课程起点",
            hintText: "请选官方课程或自定义教材",
            value: controller.courseName.isEmpty ? null : controller.courseName.value,
            onTap: () {
              controller.selectCourseAndStartPosition(context);
            },
          ),

          SizedBox(height: 8.wMin),

          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              planStartStr??"",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

        ],
      ),
    );
  }

  /// 选择学习模块卡片
  Widget _buildSelectModuleWidget(BuildContext context){
    return CardBoxWidget(
      pageIndex: 1,
      height: 1000.wMin,
      currentPageIndex: controller.currentPageIndex.value,
      onContinue: () => controller.continueAddLessonType(),
      child: Column(
        children: [
          // SizedBox(height: 24.wMin),
          // Text(
          //   "学习时长与学习模块设置",
          //   style: TextStyle(
          //     fontSize: 36.wMin,
          //     color: AppTheme.cTextPrimary.color,
          //     fontWeight: FontWeight.w600,
          //   ),
          // ),

          SizedBox(height: 32.wMin),
          const CardTitleIconTextWidget(
            // title: "学习时长与学习模块设置",
            title: "学习设置",
            svg: "assets/svg/today_plan/icon_title1.svg",
          ),
          SizedBox(height: 40.wMin),
          CardTapArrowWidget(
            title: "每日学习时长",
            hintText: "请选择学习时长",
            value: "${controller.dailyStudyDuration.value} 分钟",
            onTap: () {
              controller.selectDailyStudyDuration(context);
            },
          ),
          Visibility(
            visible: controller.specialty.value != SpecialtyEnum.EN_PHONICS,
            child: Container(
              margin: EdgeInsets.only(top: 16.wMin),
              child: CardTapArrowCoustomWidget(
                title: "学习模块",
                onTap: () {
                  controller.selectLessonType();
                },
                child: controller.selectLessonTypeList.length == controller.allLessonTypeList.length ? Text(
                  "默认全选",
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            "需要 ${((controller.exerciseDuration.value) / 60).round()} 分钟，预计 ${controller.nextUnitDay.value} 天到下一单元 ${controller.nextUnit.value}",
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
          

        ],
      ),
    );
  }

  /// 学习提醒卡片
  Widget _buildStudyReminderWidget(BuildContext context){
    return CardBoxWidget(
      pageIndex: 2,
      height: 1000.wMin,
      currentPageIndex: controller.currentPageIndex.value,
      padding: EdgeInsets.symmetric(horizontal: 100.wMin),
      continueText: "保存",
      onContinue: () {
        controller.save(context);
      },
      child: Column(
        children: [
          SizedBox(height: 24.wMin),
          Text(
            "计划时间设置",
            style: TextStyle(
              fontSize: 36.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 24.wMin),
          LearningReminderWidget(
            initHolidayAdjustment: controller.holidayAdjustment.value,
            initWerkWeeks: controller.werkWeeks.toList(),
            initHolidayDay: controller.holidayDayList.toList(),
            initRestWeeks: controller.holidayDaWeeks.toList(),
            initWorkDay: controller.werkDayList.toList(),
            onTap: (workDay, holidayDay, werkWeeks, restWeeks, holidayAdjustment) {
              controller.werkDayList.value = workDay;
              controller.holidayDayList.value = holidayDay;
              controller.werkWeeks.value = werkWeeks;
              controller.holidayDaWeeks.value = restWeeks;
              controller.holidayAdjustment.value = holidayAdjustment;
            },
          ),
        ],
      ),
    );
  }
  
  


}


// class CreateStudyPlanView extends GetView<CreateStudyPlanController> {
//   /// 创建学习计划
//   const CreateStudyPlanView({super.key});
//   @override
//   Widget build(BuildContext context) {
    
//     Widget buildSettingAllWidget(){

//       int multiple = 0;
//       if(controller.goldRatioSwitch.value) multiple += 2;
//       if(controller.superMemo.value) multiple += 7;
//       if(controller.goldRatioSwitch.value && controller.superMemo.value) multiple = 14;

//       return CardBoxWidget(
//         pageIndex: 0,
//         height: 920.wMin,
//         currentPageIndex: controller.currentPageIndex.value,
//         onContinue: () => controller.switchPage(),
//         child: Column(
//           children: [
//             SizedBox(height: 88.wMin),
//             const CardTitleIconTextWidget(
//               title: "此设置对整个学习计划有效",
//               svg: "assets/svg/today_plan/icon_title1.svg",
//             ),
//             SizedBox(height: 28.wMin),
//             ListAnimationWidget(
//               index: 1,
//               child: CardTitleSwitchWidget(
//                 title: "黄金学练",
//                 subContent: StaticData.goldRatioDesc,
//                 value: controller.goldRatioSwitch.value,
//                 onChanged: controller.goldRatioSwitch,
//               ),
//             ),
//             SizedBox(height: 24.wMin),
//             ListAnimationWidget(
//               index: 2,
//               child: CardTitleSwitchWidget(
//                 title: "超级记忆",
//                 subContent: StaticData.superMemoDesc,
//                 value: controller.superMemo.value,
//                 onChanged: controller.superMemo,
//               ),
//             ),
//             SizedBox(height: 12.wMin),
            
//             ListAnimationWidget(
//               index: 3,
//               child: DayReviewQuizNumberWidget(
//                 reviewLimit: controller.reviewLimit.value,
//                 onTap: () {
//                   controller.timeSetUpDialog(context);
//                 },
//               ),
//             ),
//             SizedBox(height: 24.wMin),
//             ListAnimationWidget(
//               index: 4,
//               child: Column(
//                 children: [
//                   CardTipAnimatedFlipCounterWidget(
//                     content: "记忆加成是别人的",
//                     multiple: multiple,
//                   ),
//                   SizedBox(height: 16.wMin),
//                   Container(
//                     width: double.infinity,
//                     alignment: Alignment.center,
//                     padding: EdgeInsets.symmetric(vertical: 8.wMin),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(6.wMin),
//                       color: AppTheme.cWhiteAlpha10,
//                     ),
//                     child: Text(
//                       "为什么设置学练比",
//                       style: TextStyle(
//                         fontSize: 20.wMin,
//                         color: AppTheme.cTextBrand,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
              
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     Widget buildSelectCourses(CreateStudyPlanCourseModel data, int index){
//       // int speedMultiplier = data.dailyStudyDuration.value ~/ 5;
//       // int completeMultiples = 0;
//       // if(data.learningReminderSwitch.value){
//       //   int allLenght = 0;
//       //   if(data.werkDayList.isNotEmpty){
//       //     allLenght += data.werkWeeks.length;
//       //   }
//       //   if(data.holidayDayList.isNotEmpty){
//       //     allLenght += data.holidayDaWeeks.length;
//       //   }
//       //   if(allLenght < 6){
//       //     completeMultiples = allLenght;
//       //   }else if(allLenght == 6){
//       //     completeMultiples = 7;
//       //   }else if(allLenght == 7){
//       //     completeMultiples = 10;
//       //   }
//       // }

//       String? planStartStr;
//       if(data.planLevelName != null && data.planModuleName != null && data.planUnitName != null){
//         planStartStr = "${data.planLevelName} / ${data.planModuleName} / ${data.planUnitName}";
//       }

//       // data.tier = null;

//       return CardBoxWidget(
//         height: 920.wMin,
//         pageIndex: index + (controller.continueAddCourse ? 0 : 1),
//         currentPageIndex: controller.currentPageIndex.value,
//         buttonNotCurrentOption: true,
//         onContinue: () {
//           controller.save(context);
//         },
//         continueText: "完成",
//         buttonDisable: controller.isDisable.value,
//         bottomButton: controller.courseList.length > controller.joinedCourseIds.length - (controller.hasReminderCourseIds.length) ? null : "再加一门课",
//         onBottomButton: controller.courseList.length > controller.joinedCourseIds.length - (controller.hasReminderCourseIds.length) ? null : () => controller.addCourse(),
//         onClose: controller.continueAddCourse && controller.courseList.length == 1 ? null : () {
//           controller.deleteCourse(index);
//         },
//         child: Column(
//           children: [
//             SizedBox(height: 32.wMin),
//             const CardTitleIconTextWidget(
//               title: "创建学习计划",
//               svg: "assets/svg/today_plan/icon_title2.svg",
//             ),
//             SizedBox(height: 28.wMin),
//             ListAnimationWidget(
//               index: 1,
//               child: CardTapArrowCoustomWidget(
//                 title: "语言水平",
//                 showArrow: false,
//                 padding: data.tier != null ? null : EdgeInsets.only(left: 16.wMin),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       data.tier == null ? "请先评测您的水平" : "Level ${data.tier}",
//                       style: TextStyle(
//                         fontSize: 24.wMin,
//                         color: data.tier == null ? AppTheme.cTextDisabled.color : AppTheme.cTextPrimary.color,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                     Visibility(
//                       visible: data.tier == null,
//                       child: TapScaleWidget(
//                         onTap: () {
//                           controller.goToAssessment(context, index);
//                         },
//                         sclae: 1.01,
//                         child: Container(
//                           height: 64.wMin,
//                           padding: EdgeInsets.symmetric(horizontal: 16.wMin),
//                           alignment: Alignment.center,
//                           color: Colors.transparent,
//                           child: Text(
//                             "去评测",
//                             style: TextStyle(
//                               fontSize: 24.wMin,
//                               color: AppTheme.cTextBrand.color,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 24.wMin),
//             ListAnimationWidget(
//               index: 2,
//               child: CardTapArrowWidget(
//                 title: "选择课程",
//                 hintText: "请选择课程",
//                 value: data.course?.courseName,
//                 onTap: () {
//                   controller.selectCourse(context, index);
//                 },
//               ),
//             ),
//             SizedBox(height: 24.wMin),
//             ListAnimationWidget(
//               index: 3,
//               child: CardTapArrowWidget(
//                 title: "计划起点",
//                 hintText: "请选择计划起点",
//                 value: planStartStr,
//                 onTap: () {
//                   controller.selectPlanStart(index);
//                 },
//               ),
//             ),
//             SizedBox(height: 24.wMin),
            
//             ListAnimationWidget(
//               index: 4,
//               child: Builder(
//                 builder: (ctx) {
//                   return CardTapArrowWidget(
//                     title: "每日学习时长",
//                     value: "${data.dailyStudyDuration.value}分钟",
//                     onTap: () {
//                       controller.selectLearningDuration(ctx, index);
//                     },
//                   );
//                 },
//               ),
//             ),

//             SizedBox(height: 24.wMin),

//             ListAnimationWidget(
//               index: 5,
//               child: CardTapArrowCoustomWidget(
//                   title: "课时类型",
//                   onTap: () {
//                     controller.selectLearningModule(context, index);
//                   },
//                   child: data.selectLessonTypeList.length == data.allLessonTypeList.length ? Text(
//                     "默认全选",
//                     style: TextStyle(
//                       fontSize: 24.wMin,
//                       color: AppTheme.cTextPrimary.color,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ) : Wrap(
//                     spacing: 12.wMin,
//                     runSpacing: 12.wMin,
//                     children: List.generate(data.selectLessonTypeList.length, (i){
//                       LanguageText? title = LearningLangUtils.getShowLList(data.selectLessonTypeList[i].title);
//                       return CardLabelWidget(
//                         name: title?.text??"",
//                         imageurl: data.selectLessonTypeList[i].iconUrl,
//                       );
//                     }),
//                   ),
//                 ),
//             ),

//             Visibility(
//               visible: data.nextUnit != null,
//               child: Container(
//                 margin: EdgeInsets.only(top: 16.wMin),
//                 alignment: Alignment.centerLeft,
//                 padding: EdgeInsets.all(16.wMin),
//                 decoration: BoxDecoration(
//                   color: AppTheme.cBgTertiary.color,
//                   borderRadius: BorderRadius.circular(12.wMin),
//                   border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
//                 ),
//                 child: Column(
//                   children: [
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "当前学习单元: ",
//                           style: TextStyle(
//                             fontSize: 22.wMin,
//                             color: AppTheme.cTextSecondary.color,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                         Expanded(
//                           child: Text(
//                             data.planUnitName??"",
//                             style: TextStyle(
//                               fontSize: 22.wMin,
//                               color: AppTheme.cTextBrand.color,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "预计学完当前单元: ",
//                           style: TextStyle(
//                             fontSize: 22.wMin,
//                             color: AppTheme.cTextSecondary.color,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                         Expanded(
//                           child: Text(
//                             "需要 ${((data.exerciseDuration??0) / 60).round()} 分钟，预计 ${data.nextUnitDay??0} 天到下一单元 ${data.nextUnit??''}",
//                             style: TextStyle(
//                               fontSize: 22.wMin,
//                               color: AppTheme.cTextBrand.color,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                   ],
//                 ),
//               ),
//             ),

//             SizedBox(height: 24.wMin),
//             ListAnimationWidget(
//               index: 6,
//               child: CardTitleSwitchWidget(
//                 title: "学习提醒",
//                 value: data.learningReminderSwitch.value,
//                 onChanged: (value) => controller.changeLearningReminder(value, index, context),
//               ),
//             ),
//             AnimatedSize(
//               duration: const Duration(milliseconds: 200),
//               alignment: Alignment.topCenter,
//               child: SizedBox(
//                 width: double.infinity,
//                 child: Visibility(
//                   visible: data.learningReminderSwitch.value,
//                   child: Container(
//                     margin: EdgeInsets.only(top: 12.wMin),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: CardLearningReminderListWidget(
//                             title: "工作日",
//                             weeks: data.werkWeeks.toList(),
//                             list: data.werkDayList.toList(),
//                             onRemove: (index) {
//                               data.werkDayList.removeAt(index);
//                             },
//                             onAdd: () {
//                               controller.showLearningReminderWindow(context, index);
//                             },
//                           ),
//                         ),
//                         SizedBox(width: 16.wMin),
//                         Expanded(
//                           child: CardLearningReminderListWidget(
//                             title: "休息日",
//                             weeks: data.holidayDaWeeks.toList(),
//                             list: data.holidayDayList.toList(),
//                             onRemove: (index) {
//                               data.holidayDayList.removeAt(index);
//                             },
//                             onAdd: () {
//                               controller.showLearningReminderWindow(context, index);
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 12.wMin),

//             // ListAnimationWidget(
//             //   index: 6,
//             //   child: Column(
//             //     crossAxisAlignment: CrossAxisAlignment.start,
//             //     children: [
//             //       CardTipAnimatedFlipCounterWidget(
//             //         content: "学习速度是别人的",
//             //         multiple: speedMultiplier,
//             //       ),
//             //       SizedBox(height: 12.wMin),
//             //       CardTipAnimatedFlipCounterWidget(
//             //         content: "学完概率是别人的",
//             //         multiple: completeMultiples,
//             //       ),
              
//             //     ],
//             //   ),
//             // ),
//           ],
//         ),
//       );
//     }

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return Scaffold(
//           backgroundColor: AppTheme.cBgPrimary,
//           body: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24.wMin, left: 80.wMin),
//                 child: const BackWidget(title: ""),
//               ),
//               Expanded(
//                 child: SizedBox(
//                   child: Obx((){
//                     return PageView(
//                       controller: controller.pageController,
//                       children: [
//                         if(!controller.continueAddCourse) buildSettingAllWidget(),
//                         ...List.generate(controller.courseList.length, (index){
//                           return buildSelectCourses(controller.courseList[index], index);
//                         })
//                       ],
//                     );
//                   }),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }
//     );
//   }
// }
