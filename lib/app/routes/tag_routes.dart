import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class TagRoutes{

  /// 路由注册表
  static final Map<String, Future<dynamic> Function({dynamic arguments, dynamic tag})> _pages = {

  };

  /// 路由历史
  static final List<TagRoutesHistoryData> _history = [];

  /// 根据路由跳转
  static Future<T?> toNamed<T>(String route, {dynamic arguments}) async {
    final tag = '${route}_${DateTime.now().millisecondsSinceEpoch}';
    final toMethod = _pages[route];
    if (toMethod != null) {
      final result = await toMethod(arguments: arguments, tag: tag);
      return result as T?;
    }
    if (kDebugMode) {
      print('⚠️ [ManagePageRegistry] 未注册的路由: $route');
    }
    return null;
  }

  /// 替换当前页面并跳转到新页面
  /// 相当于先 Get.back() 再 jumpTo()
  static Future<T?> offAndToNamed<T>(String route, {dynamic arguments}) async {
    // 先返回上一页
    Get.back();
    // 再跳转到新页面
    return await toNamed<T>(route, arguments: arguments);
  }

  /// 返回到指定路由，然后跳转到新页面
  /// predicate: 返回 true 时停止返回
  static Future<T?> offNamedUntil<T>(
    String route, {
    required bool Function(String routeName) predicate,
    dynamic arguments,
  }) async {
    // 使用 Get.until 返回到指定页面
    // 由于新管理端使用独立路由栈，这里简化为返回后跳转
    Get.until((r) => predicate(r.settings.name ?? ''));
    // 再跳转到新页面
    return await toNamed<T>(route, arguments: arguments);
  }

}

class TagRoutesHistoryData{
  String route;
  String tag;
  dynamic arguments;
  TagRoutesHistoryData({
    required this.route,
    required this.tag,
    this.arguments,
  });
}