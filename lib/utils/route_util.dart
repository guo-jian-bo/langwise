/// 路由工具类
///
/// 优化点：
/// 1. 返回值支持
///   - removeAndNavigate 方法增加泛型参数<T>，支持返回目标页面的数据
///   - 正确传递 Get.toNamed 的结果，允许获取目标页面返回的数据
///   - 在所有分支中统一处理返回值逻辑
///
/// 2. 日志优化
///   - 使用 kDebugMode 条件判断，符合项目日志处理规范
///   - 保留关键日志信息，确保调试时的可见性
///   - 优化日志格式，提供更清晰的上下文信息
///
/// 3. 错误处理增强
///   - 完善异常处理逻辑，确保在出错时仍能正确导航
///   - 添加详细的错误日志，便于问题诊断
///   - 保证在各种情况下都能返回适当的结果
///
/// 4. 适用于频繁跳转场景
///   - 特别适用于拍照页面频繁销毁、创建相机的场景
///   - 确保路由正确移除，避免路由堆积和内存泄漏
///   - 优化了路由导航逻辑，减少不必要的延迟
///
/// 这些优化符合 GetX 框架的最佳实践，提高了应用在频繁跳转场景下的稳定性和性能。

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/observers.dart';

class RouteUtil {
  /// 私有构造函数，防止实例化
  RouteUtil._();

  /// 移除指定名称的路由
  ///
  /// [routeName] 要移除的路由名称
  static void removeRouteByName(String routeName) {
    try {
      // 直接从全局路由实例映射中获取路由
      final route = routeInstanceMap[routeName];

      if (route == null) {
        debugPrint('🔍[RouteUtil]【removeRouteByName】未找到路由: $routeName');
        return;
      }

      // 移除路由
      Get.removeRoute(route);

      // 从映射中移除
      routeInstanceMap.remove(routeName);

      debugPrint('🧹[RouteUtil]【removeRouteByName】已移除路由: $routeName');
    } catch (e) {
      debugPrint('❌[RouteUtil]【removeRouteByName】移除路由失败: $e');
    }
  }

  /// 移除多个指定名称的路由
  ///
  /// [routeNames] 要移除的路由名称列表
  static void removeRoutesByNames(List<String> routeNames) {
    for (final routeName in routeNames) {
      removeRouteByName(routeName);
    }
  }

  /// 使用 Get.removeRoute 移除指定路由后，跳转到新页面
  ///
  /// [removeRouteName] 要移除的路由名称
  /// [targetRouteName] 要跳转的目标路由名称
  /// [arguments] 传递给目标页面的参数
  /// [preventDuplicates] 是否防止重复跳转，默认为 false，允许重复跳转
  ///
  /// 返回 Future<T?>，其中 T 是目标页面通过 Get.back(result: value) 返回的值类型
  static Future<T?> removeAndNavigate<T>({
    required String removeRouteName,
    required String targetRouteName,
    dynamic arguments,
    bool preventDuplicates = false,
  }) async {
    try {
      // 先检查是否需要移除路由
      final routeExists = routeInstanceMap.containsKey(removeRouteName);

      if (routeExists) {
        // 先移除指定路由
        removeRouteByName(removeRouteName);

        // 添加小延迟，确保路由移除完成
        await Future.delayed(const Duration(milliseconds: 100));

        // 然后跳转到目标页面并返回结果
        return await Get.toNamed<T>(
          targetRouteName,
          arguments: arguments,
          preventDuplicates: preventDuplicates,
        );
      } else {
        // 直接跳转到目标页面并返回结果
        if (kDebugMode) {
          print('🔍[RouteUtil]【removeAndNavigate】未找到路由 $removeRouteName，直接跳转');
        }
        return await Get.toNamed<T>(
          targetRouteName,
          arguments: arguments,
          preventDuplicates: preventDuplicates,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌[RouteUtil]【removeAndNavigate】处理路由失败: $e');
      }
      // 出错时尝试直接跳转并返回结果
      return await Get.toNamed<T>(targetRouteName, arguments: arguments);
    }
  }
}
