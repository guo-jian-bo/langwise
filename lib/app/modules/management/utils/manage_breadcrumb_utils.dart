import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/management_breadcrumb_controller.dart';

class ManagementBreadcrumbItem {
  final String id;
  final String route;
  final String? title;
  bool disabled;
  ManagementBreadcrumbItem({
    required this.id,
    required this.route,
    this.title,
    this.disabled = false,
  });
}

class ManageBreadcrumbUtils{

  /// 增加管理端面包屑
  static void addBreadcrumb(ManagementBreadcrumbItem item){
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool isRegistered = Get.isRegistered<ManagementBreadcrumbController>();
      if(!isRegistered) return;
      Get.find<ManagementBreadcrumbController>().addBreadcrumb(item);
    });
  }

  /// 根据id删除管理端面包屑
  static void removeBreadcrumb(String id){
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool isRegistered = Get.isRegistered<ManagementBreadcrumbController>();
      if(!isRegistered) return;
      Get.find<ManagementBreadcrumbController>().removeBreadcrumb(id);
    });
  }

  /// 删除 page 之后的所有面包屑
  static void removeBreadcrumbsAfterPage(String page){
    bool isRegistered = Get.isRegistered<ManagementBreadcrumbController>();
    if(!isRegistered) return;
    Get.find<ManagementBreadcrumbController>().removeBreadcrumbsAfterPage(page);
  }

  /// 清空面包屑并设置新的根面包屑
  static void clearAndSetBreadcrumb(ManagementBreadcrumbItem item){
    bool isRegistered = Get.isRegistered<ManagementBreadcrumbController>();
    if(!isRegistered) return;
    Get.find<ManagementBreadcrumbController>().clearAndSetBreadcrumb(item);
  }

  /// 清理所有面包屑
  static void clearAllBreadcrumb(){
    bool isRegistered = Get.isRegistered<ManagementBreadcrumbController>();
    if(!isRegistered) return;
    Get.find<ManagementBreadcrumbController>().clearAllBreadcrumb();
  }

  /// 更新面包屑
  static void updateBreadcrumb(ManagementBreadcrumbItem item){
    bool isRegistered = Get.isRegistered<ManagementBreadcrumbController>();
    if(!isRegistered) return;
    Get.find<ManagementBreadcrumbController>().updateBreadcrumb(item);
  }

  /// 判断是不是根路由
  static bool isRootRoute(){
    bool isRegistered = Get.isRegistered<ManagementBreadcrumbController>();
    if(!isRegistered) return false;
    List<ManagementBreadcrumbItem> breadcrumbs = Get.find<ManagementBreadcrumbController>().breadcrumbs;
    return breadcrumbs.isEmpty || breadcrumbs.length == 1;
  }

}

mixin ManageBreadcrumbMixin on GetxController {
  late final String controllerTag;

  /// 子类必须实现：返回路由名称
  String get breadcrumbRoute;
  
  /// 子类必须实现：返回面包屑标题
  String get breadcrumbTitle;

  /// 初始化面包屑，使用外部传入的 tag 作为面包屑 ID
  void initBreadcrumb(String tag, {String? title}) {
    controllerTag = tag;
    ManageBreadcrumbUtils.addBreadcrumb(ManagementBreadcrumbItem(
      id: tag,  // 直接用 tag 作为面包屑 ID
      title: title??breadcrumbTitle,
      route: breadcrumbRoute,
    ));
  }

  /// 修改面包屑标题
  void updateBreadcrumbTitle(String title){
    ManageBreadcrumbUtils.updateBreadcrumb(ManagementBreadcrumbItem(
      id: controllerTag,  // 直接用 tag 作为面包屑 ID
      title: title,
      route: breadcrumbRoute,
    ));
  }
  
  @override
  void onClose() {
    ManageBreadcrumbUtils.removeBreadcrumb(controllerTag);
    super.onClose();
  }
}