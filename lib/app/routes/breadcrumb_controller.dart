import 'package:get/get.dart';

import 'routes_breadcrumb_utils.dart';

class BreadcrumbController extends GetxController {
  /// 面包屑
  final RxList<RoutesBreadcrumbItem> _breadcrumbs = <RoutesBreadcrumbItem>[].obs;

  /// 管理端面包屑
  List<RoutesBreadcrumbItem> get breadcrumbs => _breadcrumbs;

  /// 增加面包屑
  void addBreadcrumb(RoutesBreadcrumbItem item){
    _breadcrumbs.add(item);
  }

  /// 根据id删除面包屑
  void removeBreadcrumb(String tag){
    _breadcrumbs.removeWhere((element) => element.tag == tag);
    _breadcrumbs.refresh();
  }


  /// 删除 page 之后的所有面包屑
  void removeBreadcrumbsAfterPage(String page){
    for(int i = _breadcrumbs.length - 1; i >= 0; i--){
      if(_breadcrumbs[i].route == page) break;
      _breadcrumbs.removeAt(i);
    }
    _breadcrumbs.refresh();
  }

  /// 清空面包屑并设置新的根面包屑
  void clearAndSetBreadcrumb(RoutesBreadcrumbItem item){
    _breadcrumbs.clear();
    _breadcrumbs.add(item);
  }

  /// 清空所有面包屑
  void clearAllBreadcrumb(){
    _breadcrumbs.clear();
  }

  /// 更新面包屑
  void updateBreadcrumb(RoutesBreadcrumbItem item){
    int index = _breadcrumbs.indexWhere((element) => element.tag == item.tag);
    if(index != -1){
      _breadcrumbs[index] = item;
    }
    _breadcrumbs.refresh();
  }


  /// 点击面包屑
  Future<void> onTapBreadcrumb(RoutesBreadcrumbItem item) async {
    if (item.disabled) return;
    if(_breadcrumbs.isEmpty) return;
    final current = _breadcrumbs.last;
    if (current.tag == item.tag && current.route == item.route) return;

    final targetIndex = _breadcrumbs.indexWhere(
      (element) => element.route == item.route && element.tag == item.tag,
    );
    if (targetIndex == -1) return;

    final currentIndex = _breadcrumbs.length - 1;
    final steps = currentIndex - targetIndex;
    if (steps <= 0) return;

    if (targetIndex == 0) {
      clearAndSetBreadcrumb(item);
    }

    for (int i = 0; i < steps; i++) {
      final canPop = Get.key.currentState?.canPop() ?? false;
      if (!canPop) break;
      Get.back();
      await Future<void>.delayed(Duration.zero);
    }
  }
}
