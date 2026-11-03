import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_pages.dart';

/// 全局路由实例映射表，存储路由名称到路由实例的映射
final Map<String, Route<dynamic>> routeInstanceMap = {};

class RouteObservers<R extends Route<dynamic>> extends RouteObserver<R> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    var name = route.settings.name ?? '';
    if (name.isNotEmpty) {
      // 添加到历史记录
      AppPages.history.add(name);
      // 存储路由实例
      routeInstanceMap[name] = route;

    }

    if (kDebugMode) {
      // print('🔄[RouteObservers]【didPush】当前路由历史: ${AppPages.history}');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    var name = route.settings.name ?? '';
    if (name.isNotEmpty) {
      // 从历史记录中移除
      AppPages.history.remove(name);
      // 从路由实例映射中移除
      routeInstanceMap.remove(name);
    }
    if (kDebugMode) {
      // print('🔄[RouteObservers]【didPop】当前路由历史: ${AppPages.history}');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      var oldName = oldRoute?.settings.name ?? '';
      var newName = newRoute.settings.name ?? '';

      // 更新历史记录
      if (oldName.isNotEmpty && newName.isNotEmpty) {
        var index = AppPages.history.indexWhere((element) => element == oldName);
        if (index >= 0) {
          AppPages.history[index] = newName;
        } else {
          AppPages.history.add(newName);
        }

        // 更新路由实例映射
        routeInstanceMap.remove(oldName);
        routeInstanceMap[newName] = newRoute;
      } else if (newName.isNotEmpty) {
        AppPages.history.add(newName);
        routeInstanceMap[newName] = newRoute;
      }
    }

    if (kDebugMode) {
      print('🔄[RouteObservers]【didReplace】当前路由历史: ${AppPages.history}');
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    var name = route.settings.name ?? '';
    if (name.isNotEmpty) {
      // 从历史记录中移除
      AppPages.history.remove(name);
      // 从路由实例映射中移除
      routeInstanceMap.remove(name);
    }
    if (kDebugMode) {
      print('🔄[RouteObservers]【didRemove】当前路由历史: ${AppPages.history}');
    }
  }
}
