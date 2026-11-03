import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/create_study_plan/bindings/new_create_study_plan_binding.dart';
import 'package:langwise/app/modules/create_study_plan/controllers/new_create_study_plan_controller.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/widgets/guide_engine/guide_anchor.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/enum/enum.dart';
import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/utils.dart';

class NewCreateStudyPlanView extends GetView<NewCreateStudyPlanController> {
  final String tagText;
  const NewCreateStudyPlanView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      NewCreateStudyPlanView(tagText: tag),
      binding: NewCreateStudyPlanBinding(tagText: tag),
      routeName: Routes.NEW_CREATE_STUDY_PLAN,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        backgroundColor: AppTheme.cBgPrimary,
        body: Obx(() {
          return Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24.wMin, left: 40.wMin),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                        width: 40.wMin,
                        height: 40.wMin,
                        alignment: Alignment.centerLeft,
                        child: SvgPicture.asset(
                          'assets/svg/public/icon_arrow_back.svg',
                          width: 32.wMin,
                          height: 32.wMin,
                          colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
                        )),
                  ),
                  Text(
                    '执行${controller.titleName}计划',
                    style: TextStyle(fontSize: 32.wMin, color: AppTheme.cTextPrimary.color, fontWeight: FontWeight.w600),
                  ),
                ]),
              ),
              SizedBox(height: 24.wMin),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller.scrollController,
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 70.wMin),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        title('课程信息'),
                        GestureDetector(
                          onTap: () => controller.selectCourseAndStartPosition(context),
                          child: Container(
                              padding: EdgeInsets.all(24.wMin),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.wMin),
                                color: AppTheme.cSurfacePrimary.color,
                                border: Border.all(color: AppTheme.cBorderPrimary.color),
                              ),
                              child: Obx(() {
                                return Row(children: [
                                  controller.courseName.isEmpty
                                      ? Text(
                                          '请选择课程起点',
                                          style: TextStyle(fontSize: 32.wMin, color: AppTheme.cTextPrimary.color, fontWeight: FontWeight.w600),
                                        )
                                      : Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              controller.courseName.value,
                                              style: TextStyle(fontSize: 32.wMin, color: AppTheme.cTextPrimary.color, fontWeight: FontWeight.w600),
                                            ),
                                            Text(
                                              "${controller.planLevelName.value} / ${controller.planModuleName.value} / ${controller.planUnitName.value}",
                                              style: TextStyle(fontSize: 22.wMin, color: AppTheme.cTextTertiary.color, fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                  Spacer(),
                                  Container(
                                      height: 56.wMin,
                                      width: 56.wMin,
                                      alignment: Alignment.center,
                                      child: SvgPicture.asset(
                                        'assets/svg/user_center/icon_chevron_right1.svg',
                                        width: 32.wMin,
                                        height: 32.wMin,
                                        colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
                                      ))
                                ]);
                              })),
                        ),
                        SizedBox(height: 24.wMin),
                        controller.titleName=="自然拼读"||controller.courseName.isEmpty||controller.specialty.value == SpecialtyEnum.EN_PHONICS ? Container() : _courseChoose(),
                        // SizedBox(height: 24.wMin),
                        // Obx(() {
                        //   if (controller.specialty.value != SpecialtyEnum.EN_PHONICS) return Container();
                        //   final items = controller.phonicsModules;
                        //   if (items.isEmpty) return title('自然拼读模块');
                        //   return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        //     title('自然拼读模块'),
                        //     GridView.builder(
                        //       shrinkWrap: true,
                        //       physics: const NeverScrollableScrollPhysics(),
                        //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        //         crossAxisCount: 4,
                        //         childAspectRatio: 1,
                        //         mainAxisSpacing: 36.wMin,
                        //         crossAxisSpacing: 36.wMin,
                        //       ),
                        //       itemCount: items.length,
                        //       itemBuilder: (context, index) {
                        //         final item = items[index];
                        //         return _phonicsBody(item.contentInfo);
                        //       },
                        //     ),
                        //   ]);
                        // }),
                        SizedBox(height: 24.wMin),
                        _studyPlan(),
                      ])),
                ),
              ),
              SizedBox(height: 24.wMin),
              Obx(() {
                if(controller.isEditMode.value){
                 return Row(children: [
                  SizedBox(width: 70.wMin),
                  GestureDetector(
                    onTap: (){
                      controller.deletePlan(context);
                    },
                    child: Container(
                      width: 240.wMin,
                      height: 72.wMin,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.wMin), color: AppTheme.cSurfaceError.color),
                      child: Text('删除计划', style: TextStyle(fontSize: 28.wMin, color: AppTheme.cInverseTextLight.color, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: (){
                      controller.save(context);
                    },
                    child: Container(
                      width: 240.wMin,
                      height: 72.wMin,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.wMin), color: AppTheme.cSurfaceSuccess.color),
                      child: Text('保存', style: TextStyle(fontSize: 28.wMin, color: AppTheme.cInverseTextLight.color, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  SizedBox(width: 70.wMin)
                 ]); 
                }
                return GestureDetector(
                    onTap: (){
                      controller.save(context);
                    },
                    child: Container(
                      width: 788.wMin,
                      height: 72.wMin,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.wMin), color: AppTheme.cSurfaceSuccess.color),
                      child: Text('执行计划', style: TextStyle(fontSize: 28.wMin, color: AppTheme.cInverseTextLight.color, fontWeight: FontWeight.w500)),
                    ),
                  );
                }
              ),
              SizedBox(height: 20.wMin)
            ],
          );
        }),
      );
    });
  }

  Widget title(String txt) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.wMin),
      child: Text(
        txt,
        style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextTertiary.color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _courseChoose() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      title('课时选择'),
      Obx(() {
        final List<LessonTypeEntityList> lessonTypes = controller.allLessonTypeList;
        final selectedDirections = controller.selectLessonTypeList.map((e) => e.direction).toSet();
        if (lessonTypes.isEmpty) {
          return Container();
        }
        if(selectedDirections.isEmpty){
          int pos = lessonTypes.indexWhere((e)=>e.forceSelect);
          if(pos != -1){
            controller.selectLessonTypeList.add(lessonTypes[pos]);
          }
        }
        return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 422 / 196, mainAxisSpacing: 24.wMin, crossAxisSpacing: 24.wMin),
            itemCount: lessonTypes.length,
            itemBuilder: (context, index) {
              var item = lessonTypes[index];
              LanguageText? title = LearningLangUtils.getLocalLang(item.title);
              LanguageText? subtitle = LearningLangUtils.getLocalLang(item.subtitle);
              final bool isChoosed = selectedDirections.contains(item.direction);
              return GestureDetector(
                onTap: () {
                  if(item.forceSelect){
                    return;
                  }
                  int idx = controller.selectLessonTypeList.indexWhere((s)=>s.direction==item.direction);
                  if (idx != -1) {
                    controller.selectLessonTypeList.removeAt(idx);
                  } else {
                    controller.selectLessonTypeList.add(item);
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(16.wMin),
                  child: Column(children: [
                    Row(children: [
                      Image.network(
                        item.iconUrl ?? '',
                        width: 36.wMin,
                        height: 36.wMin,
                      ),
                      SizedBox(width: 12.wMin),
                      Text(
                        title?.text ?? '',
                        style: TextStyle(fontSize: 28.wMin, color: AppTheme.cTextPrimary.color, fontWeight: FontWeight.w500),
                      ),
                      Spacer(),
                      Container(
                          height: 32.wMin,
                          width: 32.wMin,
                          decoration: BoxDecoration(
                              border: Border.all(color: isChoosed ? Colors.transparent : AppTheme.cBorderSecondary.color),
                              borderRadius: BorderRadius.circular(8.wMin),
                              color: isChoosed ? AppTheme.cSurfaceSuccess.color : Colors.transparent),
                          alignment: Alignment.center,
                          child: isChoosed
                              ? SvgPicture.asset(
                                  'assets/svg/public/icon_check.svg',
                                  width: 28.wMin,
                                  height: 28.wMin,
                                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                )
                              : Container())
                    ]),
                    SizedBox(height: 12.wMin),
                    Text(
                      subtitle?.text ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 22.wMin, color: AppTheme.cTextTertiary.color, fontWeight: FontWeight.w400),
                    ),
                  ]),
                  decoration:
                      BoxDecoration(border: Border.all(color: AppTheme.cBorderPrimary.color), borderRadius: BorderRadius.circular(16.wMin), color: AppTheme.cSurfacePrimary.color),
                ),
              );
            });
      })
    ]);
  }

  Widget _studyPlan() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      title('学习时间安排'),
      GuideAnchor(
        id: 'study_days',
        route: Routes.NEW_CREATE_STUDY_PLAN,
        child: GestureDetector(
          onTap: () {
            controller.showStudyTimeChooseDialog();
          },
          child: Container(
              padding: EdgeInsets.all(24.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                color: AppTheme.cSurfacePrimary.color,
                border: Border.all(color: AppTheme.cBorderPrimary.color),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(controller.isDoubleRestDay.value ? '双休制' : '自定义', style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextPrimary.color, fontWeight: FontWeight.w600)),
                  Spacer(),
                  if (controller.holidayAdjustment.value)
                    Container(
                      padding: EdgeInsets.all(8.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.wMin),
                        color: AppTheme.cFeedbackInfoBackground.color,
                      ),
                      child: Text('智能节假日', style: TextStyle(fontSize: 24.wMin, color: AppTheme.cFeedbackInfoText.color, fontWeight: FontWeight.w400)),
                    ),
                  SizedBox(width: 16.wMin),
                  Container(
                      height: 56.wMin,
                      width: 56.wMin,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/svg/user_center/icon_chevron_right1.svg',
                        width: 32.wMin,
                        height: 32.wMin,
                        colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
                      ))
                ]),
                SizedBox(height: 8.wMin),
                Text('工作日：${getWeekStr(controller.weekdayWeeks)}', style: TextStyle(fontSize: 22.wMin, color: AppTheme.cTextTertiary.color, fontWeight: FontWeight.w400)),
              ])),
        ),
      ),
      SizedBox(height: 24.wMin),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: GuideAnchor(id: 'study_wordkdays',
        route: Routes.NEW_CREATE_STUDY_PLAN,
        child: setTimeCard("工作日", getWeekStr(controller.weekdayWeeks), controller.weekdayList, true))),
        SizedBox(width: 24.wMin),
        Expanded(child: GuideAnchor(id: 'study_holidays',
        route: Routes.NEW_CREATE_STUDY_PLAN,
        child: setTimeCard("休息日", getWeekStr(controller.holidayWeeks), controller.holidayList, false)))
      ])
    ]);
  }

  String getWeekStr(List<int> list) {
    return list.map((e) => controller.weekList[e]).join('、');
  }

  Widget setTimeCard(String title, String content, RxList<DateTime> timeList, bool isWeekday) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfacePrimary.color,
          border: Border.all(color: AppTheme.cBorderPrimary.color),
        ),
        padding: EdgeInsets.all(24.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: TextStyle(fontSize: 28.wMin, color: AppTheme.cTextPrimary.color, fontWeight: FontWeight.w500)),
                SizedBox(width: 8.wMin),
                Text(content, style: TextStyle(fontSize: 22.wMin, color: AppTheme.cTextTertiary.color, fontWeight: FontWeight.w400)),
              ],
            ),
            SizedBox(height: 16.wMin),
            Text('学习时长', style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextSecondary.color, fontWeight: FontWeight.w400)),
            SizedBox(height: 8.wMin),
            GestureDetector(
              onTap: () async {
                PlanSettingDurationModel durationList = PlanSettingDurationModel(name: "官方推荐", minute: controller.officialStudyDuration.value, color: AppTheme.cFeedbackInfoText.color);
                int? res = await NewPlanSettingDurationDialog.show(
                  context: Get.context!,
                  initMinute: isWeekday ? controller.weekdayStudyDuration.value : controller.holidayStudyDuration.value,
                  durationList: durationList,
                  maxMinute: 60,
                  minMinute: 5,
                );
                if(isWeekday){
                  controller.weekdayStudyDuration.value = res!;
                }else{
                  controller.holidayStudyDuration.value = res!;
                }
              },
              child: Container(
                width: double.infinity,
                height: 56.wMin,
                decoration: BoxDecoration(
                  color: AppTheme.cFeedbackInfoBackground.color,
                  borderRadius: BorderRadius.circular(12.wMin),
                ),
                alignment: Alignment.center,
                child: Text('${isWeekday ? controller.weekdayStudyDuration.value : controller.holidayStudyDuration.value}分钟',
                    style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextBrand.color, fontWeight: FontWeight.w600)),
              ),
            ),
            SizedBox(height: 16.wMin),
            Obx(() {
              final list = timeList.toList();
              if (list.isEmpty) return Container();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(list.length, (index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 12.wMin),
                    child: Row(
                      children: [
                        TapScaleWidget(
                          onTap: () {
                            timeList.removeAt(index);
                          },
                          sclae: 1.02,
                          child: SvgPicture.asset(
                            "assets/svg/public/icon_remove.svg",
                            width: 24.wMin,
                          ),
                        ),
                        SizedBox(width: 12.wMin),
                        Expanded(
                          child: TapScaleWidget(
                            sclae: 1.02,
                            onTap: () async {
                              await controller.editReminderTime(timeList: timeList, index: index);
                            },
                            child: Container(
                              height: 56.wMin,
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.wMin),
                                color: AppTheme.cSurfaceTertiary.color,
                                border: Border.all(color: AppTheme.cBorderSecondary.color),
                              ),
                              child: Text(
                                DateFormatUtil.formatStr(list[index], newPattern: "HH:mm"),
                                style: TextStyle(fontSize: 24.wMin, color: AppTheme.cTextPrimary.color, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            }),
            TapScaleWidget(
              sclae: 1.02,
              onTap: () async {
                await controller.addReminderTime(timeList: timeList);
              },
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 8.wMin),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      "assets/svg/public/icon_c_add.svg",
                      width: 24.wMin,
                    ),
                    SizedBox(width: 12.wMin),
                    Text(
                      "添加提醒",
                      style: TextStyle(
                        fontSize: 22.wMin,
                        color: AppTheme.cTextBrand,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

}
