import 'package:get/get.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../common/stores/stores.dart';

class ManageAuthController extends GetxController{


  /// 所有权限列表
  final RxList<AdminAuthEntityRoutes> authRoutes = <AdminAuthEntityRoutes>[].obs;

  Future<bool> getAdminAuth() async {
    bool userIsAdmin = UserStore.to.rolePermissions.value.userIsAdmin;

    if(userIsAdmin){
      // 如果是管理员才去请求后台权限列表
      final response = await AccountConsoleRequest.getAuthList();

      List<AdminAuthEntityRoutes?> routes = response?.routes??[];

      authRoutes.clear();

      for(var route in routes){
        if(route == null) continue;
        authRoutes.add(route);
      }
    }

    bool userIsImageReviewer = UserStore.to.rolePermissions.value.userIsImageReviewer;
    bool userIsExerciseReviewer = UserStore.to.rolePermissions.value.userIsExerciseReviewer;
    bool isAuth = userIsImageReviewer || userIsExerciseReviewer || authRoutes.isNotEmpty;

    return isAuth;
  }

  

}