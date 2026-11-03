import 'package:get/get.dart';

import '../entities/entities.dart';
import '../https/https.dart';
import '../stores/stores.dart';

class ManageAuthController extends GetxController{


  /// 所有权限列表
  final RxList<AdminAuthEntityRoutes> authRoutes = <AdminAuthEntityRoutes>[].obs;

  Future<bool> getAdminAuth() async {
    authRoutes.clear();
    bool userIsAdmin = UserStore.to.rolePermissions.value.userIsAdmin;
    bool isSalesAgent = UserStore.to.userInfo.value.isSalesAgent;

    if(userIsAdmin || isSalesAgent){
      // 如果是管理员和销售代理才去请求后台权限列表
      final response = await AccountConsoleRequest.getAuthList();

      List<AdminAuthEntityRoutes?> routes = response?.routes??[];

      authRoutes.clear();

      for(var route in routes){
        if(route == null) continue;
        authRoutes.add(route);
      }
    }

    bool isReviewers = UserStore.to.rolePermissions.value.isReviewers;
    bool isAuth = isReviewers || authRoutes.isNotEmpty;

    return isAuth;
  }

  

}