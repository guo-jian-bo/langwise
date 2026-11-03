import 'package:get/get.dart';

import 'routes_breadcrumb_utils.dart';

class BreadcrumbController extends GetxController {
  
  /// 管理端面包屑
  final RxList<RoutesBreadcrumbItem> _manageBreadcrumbs = <RoutesBreadcrumbItem>[].obs;

  /// 管理端面包屑
  List<RoutesBreadcrumbItem> get breadcrumbs => _manageBreadcrumbs;

  @override
  void onInit(){
    super.onInit();
    ever(_manageBreadcrumbs, (a){
      print("面包屑 ----------- ${a.length}");
      for(RoutesBreadcrumbItem item in a){
        print("面包屑 ----------- ${item.route} ${item.title}");
      }
      print("");
    });
  }

  /// 增加管理端面包屑
  void addBreadcrumb(RoutesBreadcrumbItem item){
    _manageBreadcrumbs.add(item);
    print("面包屑 ----------- 增加面包屑  route: ${item.route} tag: ${item.tag}");
  }

  /// 根据id删除管理端面包屑
  void removeBreadcrumb(String tag){
    _manageBreadcrumbs.removeWhere((element) => element.tag == tag);
    _manageBreadcrumbs.refresh();
    print("面包屑 ----------- 删除面包屑  tag: $tag");
  }


  /// 删除 page 之后的所有面包屑
  void removeBreadcrumbsAfterPage(String page){
    for(int i = _manageBreadcrumbs.length - 1; i >= 0; i--){
      if(_manageBreadcrumbs[i].route == page) break;
      _manageBreadcrumbs.removeAt(i);
    }
    _manageBreadcrumbs.refresh();
  }

  /// 清空面包屑并设置新的根面包屑
  void clearAndSetBreadcrumb(RoutesBreadcrumbItem item){
    _manageBreadcrumbs.clear();
    _manageBreadcrumbs.add(item);
  }

  /// 清空所有面包屑
  void clearAllBreadcrumb(){
    _manageBreadcrumbs.clear();
  }

  /// 更新面包屑
  void updateBreadcrumb(RoutesBreadcrumbItem item){
    int index = _manageBreadcrumbs.indexWhere((element) => element.tag == item.tag);
    if(index != -1){
      _manageBreadcrumbs[index] = item;
    }
    _manageBreadcrumbs.refresh();
  }


  /// 点击面包屑
  Future<void> onTapBreadcrumb(RoutesBreadcrumbItem item) async {
    if(item.disabled) return;
    if(item.route == Get.currentRoute) return;

    // 使用 Get.until 返回到指定路由
    Get.until((route) => route.settings.name == item.route);
  }

}