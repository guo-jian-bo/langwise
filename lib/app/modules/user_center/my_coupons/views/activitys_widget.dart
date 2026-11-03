
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../controllers/my_coupons_controller.dart';

class ActivitysWidget extends StatefulWidget {
  final MyCouponsController controller;
  const ActivitysWidget({super.key, required this.controller});

  @override
  State<ActivitysWidget> createState() => _ActivitysWidgetState();
}

class _ActivitysWidgetState extends State<ActivitysWidget>
    with WidgetsBindingObserver {
  Timer? _activityTimer;
  DateTime? _nextSwitchTime;

  /// 跳转至限时优惠详情
  void jump(PushMessageEntity data) {
    // TagRoutes.toNamed(Routes.LIMIT_DISCOUN_DETAIL);
    data.category = JumpPageUtils.userType;

    if (data.content?.isNotEmpty == true) {
      MqttNotificationToast.showModal(messages: [data]);
    } else if (data.jump != null) {
      JumpPageUtils.jumpPage(data);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ServiceDateUtils.instance.addListener(_handleServiceTimeChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ServiceDateUtils.instance.removeListener(_handleServiceTimeChanged);
    _cancelActivityTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshActivityWidget();
    }
  }

  bool isActivityVisible(
    PushMessageEntity item, {
    DateTime? currentTime,
  }) {
    final _ActivityTimeWindow? window = _buildActivityTimeWindow(item);
    if (window == null) return false;
    final DateTime nowTime = currentTime ?? ServiceDateUtils.instance.now();
    final DateTime? started = window.started;
    final DateTime? ended = window.ended;

    if (started != null && ended != null) {
      return !nowTime.isBefore(started) && nowTime.isBefore(ended);
    }
    if (started != null) {
      return !nowTime.isBefore(started);
    }
    if (ended != null) {
      return nowTime.isBefore(ended);
    }
    return false;
  }

  List<PushMessageEntity> filterVisibleActivities(
    List<PushMessageEntity> activities, {
    DateTime? currentTime,
  }) {
    final DateTime nowTime = currentTime ?? ServiceDateUtils.instance.now();
    return activities
        .where((item) => isActivityVisible(item, currentTime: nowTime))
        .toList();
  }

  DateTime? getNextActivitySwitchTime(
    List<PushMessageEntity> activities, {
    DateTime? currentTime,
  }) {
    final DateTime nowTime = currentTime ?? ServiceDateUtils.instance.now();
    DateTime? nextTime;

    for (final PushMessageEntity item in activities) {
      final _ActivityTimeWindow? window = _buildActivityTimeWindow(item);
      if (window == null) continue;

      final List<DateTime> candidates = <DateTime>[
        if (window.started != null && window.started!.isAfter(nowTime))
          window.started!,
        if (window.ended != null && window.ended!.isAfter(nowTime))
          window.ended!,
      ];

      for (final DateTime candidate in candidates) {
        if (nextTime == null || candidate.isBefore(nextTime)) {
          nextTime = candidate;
        }
      }
    }

    return nextTime;
  }

  _ActivityTimeWindow? _buildActivityTimeWindow(PushMessageEntity item) {
    final bool hasStarted = item.started?.isNotEmpty == true;
    final bool hasEnded = item.ended?.isNotEmpty == true;
    if (!hasStarted && !hasEnded) return null;

    final DateTime? started =
        hasStarted ? DateFormatUtil.tryParseDate(item.started) : null;
    final DateTime? ended =
        hasEnded ? DateFormatUtil.tryParseDate(item.ended) : null;

    if (hasStarted && started == null) return null;
    if (hasEnded && ended == null) return null;
    if (started != null && ended != null && !started.isBefore(ended)) {
      return null;
    }

    return _ActivityTimeWindow(started: started, ended: ended);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<PushMessageEntity> hotspotsActivityList =
          widget.controller.hotspotsActivityList.toList();
      final List<PushMessageEntity> visibleActivityList =
          filterVisibleActivities(hotspotsActivityList);
      _scheduleNextRefresh(hotspotsActivityList);
      if (visibleActivityList.isEmpty) {
        return const SizedBox.shrink();
      }
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(bottom: 16.wMin),
        child: Row(
          spacing: 16.wMin,
          children: List.generate(visibleActivityList.length, (index) {
            return _buildItemWidget(visibleActivityList[index]);
          }),
        ),
      );
    });
  }

  Widget _buildItemWidget(PushMessageEntity data) {
    return TapScaleWidget(
      onTap: () {
        jump(data);
      },
      sclae: 1,
      child: CachedImageWidget(
        data.iconUrl ?? "",
        height: 143.wMin,
        errorWidget: Container(),
        placeholder: Container(),
      ),
    );
  }

  void _handleServiceTimeChanged() {
    _refreshActivityWidget();
  }

  void _refreshActivityWidget() {
    if (!mounted) return;
    _nextSwitchTime = null;
    _cancelActivityTimer();
    setState(() {});
  }

  void _scheduleNextRefresh(List<PushMessageEntity> activities) {
    final DateTime? nextSwitchTime = getNextActivitySwitchTime(activities);
    if (nextSwitchTime == null) {
      _nextSwitchTime = null;
      _cancelActivityTimer();
      return;
    }

    if (_nextSwitchTime?.isAtSameMomentAs(nextSwitchTime) == true &&
        _activityTimer?.isActive == true) {
      return;
    }

    final Duration diff = nextSwitchTime.difference(
      ServiceDateUtils.instance.now(),
    );
    _nextSwitchTime = nextSwitchTime;
    _cancelActivityTimer();
    _activityTimer = Timer(
      diff.isNegative || diff == Duration.zero
          ? const Duration(milliseconds: 100)
          : diff,
      _refreshActivityWidget,
    );
  }

  void _cancelActivityTimer() {
    _activityTimer?.cancel();
    _activityTimer = null;
  }
}

class _ActivityTimeWindow {
  final DateTime? started;
  final DateTime? ended;

  const _ActivityTimeWindow({
    this.started,
    this.ended,
  });
}
