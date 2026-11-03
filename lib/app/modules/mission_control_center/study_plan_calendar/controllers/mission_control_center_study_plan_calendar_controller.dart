import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';

class MissionControlCenterStudyPlanCalendarController extends GetxController {
  final String tagText;
  MissionControlCenterStudyPlanCalendarController({required this.tagText});

  PageController? calendarController;
  final DateTime calendarMinDate = DateTime(2025);
  final Rx<DateTime> calendarCurrentDate = DateTime.now().obs;
  final RxBool calendarLoading = false.obs;
  final Rx<StudyPlanCalendarEntity> studyPlanCalendar = StudyPlanCalendarEntity().obs;
  final RxList<StudyPlanCalendarEntityList> calendarPlanList = <StudyPlanCalendarEntityList>[].obs;
  final RxList<StudyPlanEntityPlanCourses> planCoursesList = <StudyPlanEntityPlanCourses>[].obs;

  Future<void> refreshData({bool isCalendarLoading = true}) async {
    await getPlanList();
    await getPlanCalendarList(isLoading: isCalendarLoading);
  }

  Future<void> getPlanList() async {
    final studyPlanEntity = await StudyPlanRequest.getStudyPlanList();
    if (studyPlanEntity == null) return;

    final planCourses = studyPlanEntity.planCourses ?? [];
    planCoursesList.clear();
    for (final item in planCourses) {
      if (item == null) continue;
      planCoursesList.add(item);
    }
  }

  Future<void> getPlanCalendarList({bool isLoading = true}) async {
    try {
      calendarLoading.value = isLoading;
      final reqParams = <String, dynamic>{
        'year': calendarCurrentDate.value.year,
        'month': calendarCurrentDate.value.month,
      };
      final studyPlanCalendarEntity = await StudyPlanRequest.getPlanCalendarList(reqParams);
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
}
