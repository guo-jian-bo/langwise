import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../utils/utils.dart';
import '../views/today_plan_calender_tip.dart';
import '../views/today_plan_min_list_tip.dart';

class SuperMemoCalenderController extends GetxController
    with RoutesBreadcrumbMixin {
  final String tagText;
  SuperMemoCalenderController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.SUPER_MEMO_CALENDER;

  @override
  String get breadcrumbTitle => "超级记忆日历";

  /// 日历控制器
  PageController? calendarController;

  /// 日历最小日期
  final DateTime calendarMinDate = DateTime(2025);

  /// 日历当前年月
  final Rx<DateTime> calendarCurrentDate = DateTime.now().obs;

  /// 切换日历的时候的加载
  final RxBool calendarLoading = false.obs;

  final Rx<StudyPlanCalendarEntity> studyPlanCalendar = StudyPlanCalendarEntity().obs;

  /// 当前月份学习日历数据
  final RxList<StudyPlanCalendarEntityList> calendarPlanList = <StudyPlanCalendarEntityList>[].obs;

  final RxList<StudyPlanEntityPlanCourses> planCoursesList = <StudyPlanEntityPlanCourses>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    getPlanList();
    getPlanCalendarList(isLoading: false);
  }

  /// 获取学习计划列表（用于顶部“分钟”统计）
  Future<void> getPlanList() async {
    StudyPlanEntity? studyPlanEntity = await StudyPlanRequest.getStudyPlanList();
    if (studyPlanEntity == null) return;

    final planCourses = studyPlanEntity.planCourses ?? [];
    planCoursesList.clear();
    for (final item in planCourses) {
      if (item == null) continue;
      planCoursesList.add(item);
    }
  }

  /// 获取课程学习日历
  Future<void> getPlanCalendarList({bool isLoading = true}) async {
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseMonthSupermemoDaily)) return;
    try {
      calendarLoading.value = isLoading;
      final reqParams = <String, dynamic>{
        'year': calendarCurrentDate.value.year,
        'month': calendarCurrentDate.value.month,
      };
      StudyPlanCalendarEntity? studyPlanCalendarEntity = await StudyPlanRequest.getPlanCalendarList(reqParams);
      if (studyPlanCalendarEntity == null) return;
      studyPlanCalendar.value = studyPlanCalendarEntity;

      final list = studyPlanCalendarEntity.list ?? [];
      calendarPlanList.clear();
      for (final item in list) {
        if (item == null) continue;
        calendarPlanList.add(item);
      }
    } finally {
      calendarLoading.value = false;
    }
  }

  /// 显示计划列表时长
  Future<void> tapCalenderAllDuration(BuildContext context) async {
    TodayPlanMinListTip.show(context: context, planCoursesList: planCoursesList.toList());
  }

  /// 显示超级日历说明
  void showCalenderTip(BuildContext context) {
    TodayPlanCalenderTip.show(context: context);
  }

  Future<void> toMemoryCardList(StudyPlanCalendarEntityList? data) async {
    if (data == null) return;
  }


  /// 去评测结果页面
  Future<void> toUserEvaluationResult(BuildContext context) async {
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.studyMemberCourseAssessmentDetailPlanV2)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }
    await TagRoutes.toNamed(Routes.USER_EVALUATION_LEVEL);
  }
}
