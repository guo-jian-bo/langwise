import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../utils/utils.dart';

class MissionControlCenterStudyPlanCalendarController extends GetxController {
  final String tagText;
  MissionControlCenterStudyPlanCalendarController({required this.tagText});

  PageController? calendarController;
  Timer? _nextDayTimer;
  final DateTime calendarMinDate = DateTime(2025);
  final Rx<DateTime> calendarCurrentDate = DateTime.now().obs;
  final RxnString calendarDataMonthKey = RxnString();
  final RxBool calendarLoading = false.obs;
  final Rx<StudyPlanCalendarEntity> studyPlanCalendar = StudyPlanCalendarEntity().obs;
  final RxList<StudyPlanCalendarEntityList> calendarPlanList = <StudyPlanCalendarEntityList>[].obs;
  final Map<String, StudyPlanCalendarEntity> _monthCache = <String, StudyPlanCalendarEntity>{};
  final Map<String, Future<StudyPlanCalendarEntity?>> _pendingMonthRequests = <String, Future<StudyPlanCalendarEntity?>>{};

  @override
  void onInit() {
    print('超级日历刷新');
    super.onInit();
    _nextDayRefresh();
  }

  Future<void> refreshData({
    bool isCalendarLoading = true,
    bool forceRemote = false,
  }) async {
    final month = _normalizeMonth(calendarCurrentDate.value);
    calendarCurrentDate.value = month;
    await getPlanCalendarList(
      isLoading: isCalendarLoading,
      forceRemote: forceRemote,
    );
    _prefetchAdjacentMonths(month);
  }

  Future<void> getPlanCalendarList({
    bool isLoading = true,
    bool forceRemote = false,
  }) async {
    final month = _normalizeMonth(calendarCurrentDate.value);
    final cacheApplied = forceRemote ? false : _applyCachedMonth(month);
    if (cacheApplied && !isLoading) {
      _prefetchAdjacentMonths(month);
      return;
    }
    try {
      if (isLoading) {
        calendarLoading.value = true;
      }
      final studyPlanCalendarEntity = forceRemote
          ? await _requestMonth(month)
          : await _fetchMonth(month);
      if (isClosed || studyPlanCalendarEntity == null) return;
      if (_monthKey(calendarCurrentDate.value) != _monthKey(month)) return;
      _applyMonthEntity(studyPlanCalendarEntity, month: month);
      _prefetchAdjacentMonths(month);
    } finally {
      if (!isClosed) {
        calendarLoading.value = false;
      }
    }
  }

  void onCalendarPageChanged(DateTime focusedDay) {
    final month = _normalizeMonth(focusedDay);
    calendarCurrentDate.value = month;

    if (_applyCachedMonth(month)) {
      _prefetchAdjacentMonths(month);
      return;
    }

    calendarDataMonthKey.value = null;
    studyPlanCalendar.value = StudyPlanCalendarEntity();
    calendarPlanList.clear();
    unawaited(getPlanCalendarList(isLoading: false));
    _prefetchAdjacentMonths(month);
  }

  Future<StudyPlanCalendarEntity?> _fetchMonth(DateTime month) {
    final key = _monthKey(month);
    final cached = _monthCache[key];
    if (cached != null) return Future.value(cached);

    final pending = _pendingMonthRequests[key];
    if (pending != null) return pending;

    final future = _requestMonth(month);
    _pendingMonthRequests[key] = future;
    future.whenComplete(() {
      _pendingMonthRequests.remove(key);
    });
    return future;
  }

  Future<StudyPlanCalendarEntity?> _requestMonth(DateTime month) async {
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseMonthSupermemoDaily)) return null;
    final reqParams = <String, dynamic>{
      'year': month.year,
      'month': month.month,
    };
    final studyPlanCalendarEntity = await StudyPlanRequest.getPlanCalendarList(reqParams);
    if (studyPlanCalendarEntity != null) {
      _monthCache[_monthKey(month)] = studyPlanCalendarEntity;
    }
    return studyPlanCalendarEntity;
  }

  bool _applyCachedMonth(DateTime month) {
    final cached = _monthCache[_monthKey(month)];
    if (cached == null) return false;
    _applyMonthEntity(cached, month: month);
    return true;
  }

  void _applyMonthEntity(
    StudyPlanCalendarEntity studyPlanCalendarEntity, {
    required DateTime month,
  }) {
    studyPlanCalendar.value = studyPlanCalendarEntity;
    calendarDataMonthKey.value = _monthKey(month);

    final list = studyPlanCalendarEntity.list ?? [];
    calendarPlanList.clear();
    for (final item in list) {
      if (item == null) continue;
      calendarPlanList.add(item);
    }
  }

  void _prefetchAdjacentMonths(DateTime currentMonth) {
    for (final month in [_previousMonth(currentMonth), _nextMonth(currentMonth)]) {
      final key = _monthKey(month);
      if (_monthCache.containsKey(key) || _pendingMonthRequests.containsKey(key)) {
        continue;
      }
      unawaited(_fetchMonth(month));
    }
  }

  DateTime _normalizeMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  DateTime _previousMonth(DateTime date) {
    return DateTime(date.year, date.month - 1, 1);
  }

  DateTime _nextMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 1);
  }

  String _monthKey(DateTime date) {
    final normalized = _normalizeMonth(date);
    final month = normalized.month.toString().padLeft(2, '0');
    return '${normalized.year}-$month';
  }

  bool isMonthDataReady(DateTime month) {
    return calendarDataMonthKey.value == _monthKey(month);
  }

  void _nextDayRefresh() {
    _nextDayTimer?.cancel();
    final now = DateTime.now().toLocal();

    const int minSeconds = 1;
    const int maxSeconds = 15 * 60;
    final int randomSeconds =
        minSeconds + Random().nextInt(maxSeconds - minSeconds + 1);
    final nextDay = DateTime(
      now.year,
      now.month,
      now.day + 1,
    ).add(Duration(seconds: randomSeconds));

    var refreshDuration = nextDay.difference(now);
    if (refreshDuration.isNegative) refreshDuration = const Duration(seconds: 1);

    _nextDayTimer = Timer(refreshDuration, () async {
      if (isClosed) return;
      _monthCache.clear();
      _pendingMonthRequests.clear();
      await refreshData(isCalendarLoading: false, forceRemote: true);
      if (isClosed) return;
      await Future.delayed(const Duration(seconds: 5));
      if (isClosed) return;
      _nextDayRefresh();
    });
  }

  @override
  void onClose() {
    _nextDayTimer?.cancel();
    _monthCache.clear();
    _pendingMonthRequests.clear();
    super.onClose();
  }
}
