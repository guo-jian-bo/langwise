
import 'package:flutter/material.dart';
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

  /// 增加管理端面包屑
  static void addBreadcrumb(RoutesBreadcrumbItem item){
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool isRegistered = Get.isRegistered<BreadcrumbController>();
      if(!isRegistered) return;
      Get.find<BreadcrumbController>().addBreadcrumb(item);
    });
  }

  /// 根据id删除管理端面包屑
  static void removeBreadcrumb(String id){
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool isRegistered = Get.isRegistered<BreadcrumbController>();
      if(!isRegistered) return;
      Get.find<BreadcrumbController>().removeBreadcrumb(id);
    });
  }

  /// 删除 page 之后的所有面包屑
  static void removeBreadcrumbsAfterPage(String page){
    bool isRegistered = Get.isRegistered<BreadcrumbController>();
    if(!isRegistered) return;
    Get.find<BreadcrumbController>().removeBreadcrumbsAfterPage(page);
  }

  /// 清空面包屑并设置新的根面包屑
  static void clearAndSetBreadcrumb(RoutesBreadcrumbItem item){
    bool isRegistered = Get.isRegistered<BreadcrumbController>();
    if(!isRegistered) return;
    Get.find<BreadcrumbController>().clearAndSetBreadcrumb(item);
  }

  /// 清理所有面包屑
  static void clearAllBreadcrumb(){
    bool isRegistered = Get.isRegistered<BreadcrumbController>();
    if(!isRegistered) return;
    Get.find<BreadcrumbController>().clearAllBreadcrumb();
  }

  /// 更新面包屑
  static void updateBreadcrumb(RoutesBreadcrumbItem item){
    bool isRegistered = Get.isRegistered<BreadcrumbController>();
    if(!isRegistered) return;
    Get.find<BreadcrumbController>().updateBreadcrumb(item);
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