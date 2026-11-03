import 'dart:async';
import 'package:flutter/material.dart';

/// 路由过渡动画观察器，跟踪路由切换动画是否正在进行中
class RouteTransitionObserver extends NavigatorObserver {
  static final RouteTransitionObserver instance = RouteTransitionObserver();

  final ValueNotifier<bool> isTransitioning = ValueNotifier(false);

  Timer? _timer;

  void _onRouteChanged() {
    isTransitioning.value = true;
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 400), () {
      isTransitioning.value = false;
    });
  }

  @override
  void didPush(Route route, Route? previousRoute) => _onRouteChanged();

  @override
  void didPop(Route route, Route? previousRoute) => _onRouteChanged();

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) => _onRouteChanged();

  @override
  void didRemove(Route route, Route? previousRoute) => _onRouteChanged();
}
