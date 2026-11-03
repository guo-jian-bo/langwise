import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../app/routes/app_pages.dart';
import '../../app/routes/observers.dart';

/// 页面刷新感知 mixin。
///
/// 统一提供：
/// 1. 当前页可见时的立即刷新回调
/// 2. 从下级页面返回后的延迟刷新回调
///
/// 通知入口和页面注册表都内聚在当前文件中，不额外拆刷新中心。
mixin PageRefreshAwareMixin on GetxController implements RouteAware {
  /// 当前已接入页面刷新能力的控制器实例集合。
  static final LinkedHashSet<PageRefreshAwareMixin> _instances =
      LinkedHashSet<PageRefreshAwareMixin>.identity();

  /// 统一的页面刷新通知入口。
  ///
  /// - `key == null` 表示全局通知
  /// - `key != null` 表示带作用域的通知
  static void notifyPageRefresh({String? key}) {
    final List<PageRefreshAwareMixin> instances = _instances.toList();
    for (final PageRefreshAwareMixin instance in instances) {
      instance._handlePageRefreshNotification(key);
    }
  }

  /// 当前控制器订阅到的页面路由实例。
  Route<dynamic>? _route;

  /// 是否已经注册到页面刷新实例集合。
  bool _isRefreshAwareRegistered = false;

  /// 是否已经订阅当前页面的 RouteObserver。
  bool _isRouteObserverSubscribed = false;

  /// 当前页面是否处于可见状态。
  bool _isPageVisible = true;

  /// 当前页面是否正在执行刷新任务。
  bool _isRefreshing = false;

  /// 当前页面返回后是否需要补一次刷新。
  bool _hasPendingReturnRefresh = false;

  /// 返回后待执行刷新的通知 key。
  String? _pendingReturnRefreshKey;

  /// 当前控制器是否已销毁。
  bool _isDisposed = false;

  @override
  void onReady() {
    super.onReady();
    _registerPageRefreshAwareInstance();
    _subscribePageRefreshRouteObserver();
  }

  @override
  void onClose() {
    _isDisposed = true;
    _clearPendingReturnRefresh();
    _unregisterPageRefreshAwareInstance();
    _unsubscribePageRefreshRouteObserver();
    super.onClose();
  }

  /// 当前页可见时触发的立即刷新回调。
  FutureOr<void> onImmediatePageRefresh(String? key) {}

  /// 从下级页面返回后触发的刷新回调。
  FutureOr<void> onReturnPageRefresh(String? key) {}

  /// 当前页面首次被推入路由栈。
  @override
  void didPush() {
    _isPageVisible = true;
  }

  /// 当前页面被下级页面覆盖。
  @override
  void didPushNext() {
    _isPageVisible = false;
  }

  /// 当前页面从下级页面返回，重新变为可见。
  @override
  void didPopNext() {
    _isPageVisible = true;
    _flushPendingReturnRefreshIfNeeded();
  }

  /// 当前页面自身被弹出。
  @override
  void didPop() {
    _isPageVisible = false;
  }

  /// 处理统一分发过来的页面刷新通知。
  void _handlePageRefreshNotification(String? key) {
    if (_isDisposed || _isRefreshing) return;
    if (_isPageVisible) {
      _runRefreshTask(onImmediatePageRefresh, key);
      return;
    }
    _markPendingReturnRefresh(key);
  }

  /// 注册当前控制器到页面刷新实例集合。
  void _registerPageRefreshAwareInstance() {
    if (_isRefreshAwareRegistered) return;
    _instances.add(this);
    _isRefreshAwareRegistered = true;
  }

  /// 从页面刷新实例集合中移除当前控制器。
  void _unregisterPageRefreshAwareInstance() {
    if (!_isRefreshAwareRegistered) return;
    _instances.remove(this);
    _isRefreshAwareRegistered = false;
  }

  /// 订阅当前页面的 RouteObserver，用于感知返回场景。
  void _subscribePageRefreshRouteObserver() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return;
      final Route<dynamic>? route = _resolveObservedRoute();
      if (_route == route && _isRouteObserverSubscribed) return;
      _unsubscribePageRefreshRouteObserver();
      _route = route;
      if (route is! PageRoute<dynamic>) return;
      AppPages.observer.subscribe(this, route);
      _isRouteObserverSubscribed = true;
    });
  }

  /// 取消当前页面的 RouteObserver 订阅。
  void _unsubscribePageRefreshRouteObserver() {
    if (!_isRouteObserverSubscribed) return;
    AppPages.observer.unsubscribe(this);
    _isRouteObserverSubscribed = false;
    _route = null;
  }

  /// 解析当前控制器需要监听的页面路由实例。
  Route<dynamic>? _resolveObservedRoute() {
    final String currentRouteName = Get.currentRoute.trim();
    if (currentRouteName.isNotEmpty) {
      final Route<dynamic>? currentRoute = routeInstanceMap[currentRouteName];
      if (currentRoute != null) return currentRoute;
    }
    if (AppPages.history.isEmpty) return null;
    final String latestRouteName = AppPages.history.last.trim();
    if (latestRouteName.isEmpty) return null;
    return routeInstanceMap[latestRouteName];
  }

  /// 标记当前页面在返回后需要补一次刷新。
  void _markPendingReturnRefresh(String? key) {
    if (!_hasPendingReturnRefresh) {
      _hasPendingReturnRefresh = true;
      _pendingReturnRefreshKey = key;
      return;
    }
    if (_pendingReturnRefreshKey == null || _pendingReturnRefreshKey == key) {
      return;
    }
    _pendingReturnRefreshKey = null;
  }

  /// 页面返回可见后，按需执行挂起的返回刷新。
  void _flushPendingReturnRefreshIfNeeded() {
    if (!_hasPendingReturnRefresh || _isRefreshing || _isDisposed) return;
    final String? key = _pendingReturnRefreshKey;
    _clearPendingReturnRefresh();
    _runRefreshTask(onReturnPageRefresh, key);
  }

  /// 清理当前页面挂起的返回刷新状态。
  void _clearPendingReturnRefresh() {
    _hasPendingReturnRefresh = false;
    _pendingReturnRefreshKey = null;
  }

  /// 统一执行页面刷新任务，并控制并发丢弃规则。
  Future<void> _runRefreshTask(
    FutureOr<void> Function(String? key) task,
    String? key,
  ) async {
    if (_isDisposed || _isRefreshing) return;
    _isRefreshing = true;
    try {
      await Future<void>.sync(() => task(key));
    } finally {
      _isRefreshing = false;
    }
  }
}
