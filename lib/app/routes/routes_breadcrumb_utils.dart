import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import 'breadcrumb_controller.dart';

class RoutesBreadcrumbItem {
  final String tag;
  final String route;
  final String? title;
  bool disabled;
  RoutesBreadcrumbItem({
    required this.tag,
    required this.route,
    this.title,
    this.disabled = false,
  });
}

class RoutesBreadcrumbUtils{

  /// 增加面包屑
  static void addBreadcrumb(RoutesBreadcrumbItem item){
    _runSafely(() {
      Get.find<BreadcrumbController>().addBreadcrumb(item);
    });
  }

  /// 根据id删除面包屑
  static void removeBreadcrumb(String id){
    _runSafely(() {
      Get.find<BreadcrumbController>().removeBreadcrumb(id);
    });
  }

  /// 删除 page 之后的所有面包屑
  static void removeBreadcrumbsAfterPage(String page){
    _runSafely(() {
      Get.find<BreadcrumbController>().removeBreadcrumbsAfterPage(page);
    });
  }

  /// 清空面包屑并设置新的根面包屑
  static void clearAndSetBreadcrumb(RoutesBreadcrumbItem item){
    _runSafely(() {
      Get.find<BreadcrumbController>().clearAndSetBreadcrumb(item);
    });
  }

  /// 清理所有面包屑
  static void clearAllBreadcrumb(){
    _runSafely(() {
      Get.find<BreadcrumbController>().clearAllBreadcrumb();
    });
  }

  /// 更新面包屑
  static void updateBreadcrumb(RoutesBreadcrumbItem item){
    _runSafely(() {
      Get.find<BreadcrumbController>().updateBreadcrumb(item);
    });
  }

  /// 安全运行操作，确保在主线程执行
  static void _runSafely(VoidCallback action) {
    final bool isRegistered = Get.isRegistered<BreadcrumbController>();
    if (!isRegistered) return;

    // 确保在主线程执行
    final SchedulerPhase phase = WidgetsBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        action();
      });
      return;
    }

    action();
  }

}


mixin RoutesBreadcrumbMixin on GetxController {
  late final String controllerTag;

  /// 子类必须实现：返回路由名称
  String get breadcrumbRoute;
  
  /// 子类必须实现：返回面包屑标题
  String get breadcrumbTitle;

  /// 初始化面包屑
  void initBreadcrumb(String tag, {String? title}) {
    controllerTag = tag;
    RoutesBreadcrumbUtils.addBreadcrumb(RoutesBreadcrumbItem(
      tag: tag,  // 直接用 tag 作为面包屑 ID
      title: title??breadcrumbTitle,
      route: breadcrumbRoute,
    ));
  }

  /// 修改面包屑标题
  void updateBreadcrumbTitle(String title){
    RoutesBreadcrumbUtils.updateBreadcrumb(RoutesBreadcrumbItem(
      tag: controllerTag,  // 直接用 tag 作为面包屑 ID
      title: title,
      route: breadcrumbRoute,
    ));
  }
  
  @override
  void onClose() {
    RoutesBreadcrumbUtils.removeBreadcrumb(controllerTag);
    super.onClose();
  }
}
