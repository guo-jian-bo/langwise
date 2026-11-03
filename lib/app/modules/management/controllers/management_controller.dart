
import 'package:get/get.dart';
import 'package:langwise/common/stores/stores.dart';

import '../../../routes/routes.dart';
import '../enums/enums.dart';
import '../utils/manage_auth_utils.dart';
import '../utils/manage_breadcrumb_utils.dart';
import '../utils/manage_page_registry.dart';
class ManagementController extends GetxController {

  final RxList<ManageNavEnum> manageNavList = <ManageNavEnum>[].obs;

  /// -1=正在加载中 0=加载失败 1=加载成功 2=没有权限
  final RxInt initStatus = (-1).obs;

  /// 显示的页面
  final Rx<ManageNavEnum?> currentNav = Rx(null);
  

  @override
  void onInit() {
    super.onInit();
    initAuth();
    
  }

  /// 初始化权限
  Future<void> initAuth() async{
    try {
      initStatus.value = -1;
      bool initRes = await ManageAuthUtils.init();
      if(!initRes){
        initStatus.value = 0;
        return;
      }

      tabsAuth();

    } catch (e) {
      initStatus.value = 0;
    }
  }

  /// 判断是否有tab权限
  void tabsAuth(){
    if(isClosed) return;
    manageNavList.clear();
    for(var item in ManageNavEnum.values){
      if(ManageAuthUtils.isAnyAuth(item.authCodes)){
        manageNavList.add(item);
      }
    }

    // 审核员不是管理员 要单独判断 还有 [ManageAuthController] 里的判断
    if(!manageNavList.contains(ManageNavEnum.review)){
      bool isReviewers = UserStore.to.rolePermissions.value.isReviewers;
      if(isReviewers){
        manageNavList.add(ManageNavEnum.review);
      }
    }

    // manageNavList.add(ManageNavEnum.users);

    if(manageNavList.isEmpty){
      initStatus.value = 2;
      return;
    }

    switchNavIndex(manageNavList.first);

  }

  /// 切换底部菜单
  void switchNavIndex(ManageNavEnum nav){
    if(currentNav.value == nav) return;

    currentNav.value = nav;
    _navigateToManageRoute(nav.route);

  }

  /// 导航到管理模块的指定路由
  /// 先返回到 management 根页面，再 push 到目标页面
  void _navigateToManageRoute(String route) {
    // 检查当前路由是否已经是目标路由
    if (Get.currentRoute == route) return;

    ManageBreadcrumbUtils.clearAllBreadcrumb();
    
    // 检查当前是否在 management 根页面
    if (Get.currentRoute == Routes.MANAGEMENT) {
      ManagePageRegistry.jumpTo(route);
      return;
    }
    
    // 先返回到 management 根页面
    Get.until((r) => r.settings.name == Routes.MANAGEMENT);
    // 然后 push 到目标页面
    ManagePageRegistry.jumpTo(route);
  }


  @override
  void onReady() {
    super.onReady();
  }

  

  @override
  void onClose() {
    super.onClose();
  }
}
