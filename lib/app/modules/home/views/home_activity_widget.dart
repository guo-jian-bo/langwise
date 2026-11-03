import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/utils.dart';
import '../controllers/home_controller.dart';

class HomeActivityWidget extends StatefulWidget {
  final HomeController controller;
  const HomeActivityWidget({super.key, required this.controller});

  @override
  State<HomeActivityWidget> createState() => _HomeActivityWidgetState();
}

class _HomeActivityWidgetState extends State<HomeActivityWidget> with WidgetsBindingObserver {
  /// 只在最近一个开始/结束边界挂一次定时器，避免高频轮询。
  Timer? _activityTimer;
  /// 记录当前已安排的边界时间，防止重复创建相同定时器。
  DateTime? _nextSwitchTime;
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentActivityIndex = 0;

  Future<void> jump(PushMessageEntity item) async{
    // content 不为空 显示弹窗

    item.category = JumpPageUtils.userType;

    if(item.content?.isNotEmpty == true){
      MqttNotificationToast.showModal(messages: [item]);
    }else if(item.jump != null){
      await JumpPageUtils.jumpPage(item);
    }

  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 服务端时间初始化完成后，活动可见性可能需要立刻重新计算。
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
      // 后台期间定时器可能不准，回前台后主动重算一次。
      _refreshActivityWidget();
    }
  }

  /// 按约定的时间规则判断当前活动是否可见。
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

  /// 过滤出当前时刻可见的活动列表。
  List<PushMessageEntity> filterVisibleActivities(
    List<PushMessageEntity> activities, {
    DateTime? currentTime,
  }) {
    final DateTime nowTime = currentTime ?? ServiceDateUtils.instance.now();
    return activities.where((item) => isActivityVisible(item, currentTime: nowTime)).toList();
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

      // 只关心当前时刻之后的边界点，用于安排下一次刷新。
      final List<DateTime> candidates = <DateTime>[
        if (window.started != null && window.started!.isAfter(nowTime)) window.started!,
        if (window.ended != null && window.ended!.isAfter(nowTime)) window.ended!,
      ];

      for (final DateTime candidate in candidates) {
        if (nextTime == null || candidate.isBefore(nextTime)) {
          nextTime = candidate;
        }
      }
    }

    return nextTime;
  }

    /// 将 started / ended 规范化为一个可复用的时间区间。
  _ActivityTimeWindow? _buildActivityTimeWindow(PushMessageEntity item) {
    final bool hasStarted = item.started?.isNotEmpty == true;
    final bool hasEnded = item.ended?.isNotEmpty == true;
    if (!hasStarted && !hasEnded) return null;

    final DateTime? started = hasStarted ? DateFormatUtil.tryParseDate(item.started) : null;
    final DateTime? ended = hasEnded ? DateFormatUtil.tryParseDate(item.ended) : null;

    if (hasStarted && started == null) return null;
    if (hasEnded && ended == null) return null;
    if (started != null && ended != null && !started.isBefore(ended)) return null;

    return _ActivityTimeWindow(started: started, ended: ended);
  }

  @override
  Widget build(BuildContext context) {
    return _buildActivityWidget(context);
  }

  Widget _buildActivityWidget(BuildContext context){
    double rightPadding = 24.wMin;
    double safeAreaRightPadding = MediaQuery.of(context).padding.right;
    if(rightPadding < safeAreaRightPadding){
      rightPadding = safeAreaRightPadding;
    }

    return Container(
      padding: EdgeInsets.only(right: rightPadding),
      child: Obx((){
        List<PushMessageEntity> advertList = widget.controller.homeAdvertList.toList();
        // 这里始终按当前时间重新过滤，避免直接渲染所有活动。
        List<PushMessageEntity> visibleAdvertList = filterVisibleActivities(advertList);
        _scheduleNextRefresh(advertList);
        if (visibleAdvertList.isEmpty) return const SizedBox.shrink();
        final int currentIndex = _getSafeActivityIndex(visibleAdvertList.length);
        final PushMessageEntity currentItem = visibleAdvertList[currentIndex];
        final double currentHeight = _getActivityHeight(currentItem);
        final double currentAspectRatio = _getActivityAspectRatio(currentItem);

        return AnimatedContainer(
          key: ValueKey("$currentHeight$currentAspectRatio"),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          height: currentHeight,
          child: CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: visibleAdvertList.length,
            options: CarouselOptions(
              autoPlay: true,
              viewportFraction: 1,
              aspectRatio: currentAspectRatio,
              autoPlayInterval: const Duration(seconds: 12),
              onPageChanged: (index, reason) {
                if (_currentActivityIndex == index) return;
                setState(() {
                  _currentActivityIndex = index;
                });
                
              },
            ),
            itemBuilder: (context, index, realIndex) {
              return _buildActivityItemWidget(visibleAdvertList[index], index);
            },
          ),
        );

        // return Column(
        //   spacing: 50.wMin,
        //   children: List.generate(visibleAdvertList.length, (index){
        //     return _buildActivityItemWidget(visibleAdvertList[index], index);
        //   }),
        // );
      }),
    );
  }

  Widget _buildActivityItemWidget(PushMessageEntity item, int index){
    return TapScaleWidget(
      onTap: item.jump == null ? null : OptimizeUtils.noneThrottle(() async {
        jump(item);
      }, 1000),
      sclae: 1.05,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: CachedImageWidget(
          item.iconUrl??"",
          fit: BoxFit.contain,
          errorWidget: Container(),
          placeholder: Container(),
        ),
      ),
    );
  }

  /// 保证当前轮播索引始终落在可见活动列表范围内。
  int _getSafeActivityIndex(int activityCount) {
    if (activityCount <= 0) {
      _currentActivityIndex = 0;
      return 0;
    }
    final int safeIndex = _currentActivityIndex.clamp(0, activityCount - 1);
    if (safeIndex != _currentActivityIndex) {
      _currentActivityIndex = safeIndex;
    }
    return safeIndex;
  }

  /// 解析当前活动的展示高度，未配置或配置为 0 时回退到默认值。
  double _getActivityHeight(PushMessageEntity item) {
    final double? layoutHeight = item.layout?.height;
    if (layoutHeight == null || layoutHeight <= 0) {
      return 64.wMin;
    }
    return layoutHeight.wMin;
  }

  /// 解析类似 "5/1" 的比例字符串，异常数据统一回退到默认比例。
  double _getActivityAspectRatio(PushMessageEntity item) {
    final String? ratio = item.layout?.ratio?.trim();
    if (ratio == null || ratio.isEmpty) {
      return 5 / 1;
    }

    final List<String> parts = ratio.split('/');
    if (parts.length != 2) {
      return 5 / 1;
    }

    final double? width = double.tryParse(parts[0].trim());
    final double? height = double.tryParse(parts[1].trim());
    if (width == null || height == null || width <= 0 || height <= 0) {
      return 5 / 1;
    }

    return width / height;
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

  void _scheduleNextRefresh(List<PushMessageEntity> advertList) {
    final DateTime? nextSwitchTime = getNextActivitySwitchTime(advertList);
    if (nextSwitchTime == null) {
      _nextSwitchTime = null;
      _cancelActivityTimer();
      return;
    }

    if (_nextSwitchTime?.isAtSameMomentAs(nextSwitchTime) == true && _activityTimer?.isActive == true) {
      return;
    }

    // 以当前口径时间计算剩余时长，到点后再整体重算一次可见列表。
    final Duration diff = nextSwitchTime.difference(ServiceDateUtils.instance.now());
    _nextSwitchTime = nextSwitchTime;
    _cancelActivityTimer();
    _activityTimer = Timer(
      diff.isNegative || diff == Duration.zero ? const Duration(milliseconds: 100) : diff,
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
