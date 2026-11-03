import 'package:get/get.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';

import '../../app/modules/management/utils/utils.dart';

/// 同时维护路由面包屑和管理端面包屑
mixin DualBreadcrumbMixin on GetxController {
  /// 当前控制器对应的面包屑唯一标识
  late final String controllerTag;

  /// 子类必须提供当前路由
  String get breadcrumbRoute;

  /// 子类必须提供默认标题
  String get breadcrumbTitle;

  /// 同时初始化两套面包屑
  void initBreadcrumb(String tag, {String? title}) {
    controllerTag = tag;
    final String currentTitle = title ?? breadcrumbTitle;
    RoutesBreadcrumbUtils.addBreadcrumb(RoutesBreadcrumbItem(
      tag: tag,
      title: currentTitle,
      route: breadcrumbRoute,
    ));

    ManageBreadcrumbUtils.addBreadcrumb(ManagementBreadcrumbItem(
      id: tag,
      title: currentTitle,
      route: breadcrumbRoute,
    ));
  }

  /// 同时更新两套面包屑标题
  void updateBreadcrumbTitle(String title) {
    RoutesBreadcrumbUtils.updateBreadcrumb(RoutesBreadcrumbItem(
      tag: controllerTag,
      title: title,
      route: breadcrumbRoute,
    ));

    ManageBreadcrumbUtils.updateBreadcrumb(ManagementBreadcrumbItem(
      id: controllerTag,
      title: title,
      route: breadcrumbRoute,
    ));
  }

  @override
  void onClose() {
    RoutesBreadcrumbUtils.removeBreadcrumb(controllerTag);
    ManageBreadcrumbUtils.removeBreadcrumb(controllerTag);
    super.onClose();
  }
}
