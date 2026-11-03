import 'package:get/get.dart';

import '../../../../routes/routes.dart';
import '../../models/manage_auth_menu_model.dart';
import '../../utils/manage_auth_utils.dart';
import '../../utils/manage_breadcrumb_utils.dart';
import '../../utils/manage_page_registry.dart';

class ManageUsersController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageUsersController({required this.tag});

  final RxList<ManageAuthMenuModel> manageUsersList = <ManageAuthMenuModel>[].obs;

  @override
  String get breadcrumbRoute => Routes.MANAGE_USERS;

  @override
  String get breadcrumbTitle => '用户';

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    initAuth();
  }

  void initAuth() {
    manageUsersList.clear();

    if (ManageAuthUtils.isAnyAuth([
      ManageAuthCode.rightsPages,
      ManageAuthCode.orderPage,
      ManageAuthCode.couponSupplyPage,
    ])) {

      manageUsersList.add(ManageAuthMenuModel(
        name: "商品管理",
        subtitle: "管理服务包和商品展示",
        authCode: ManageAuthCode.rightsPages,
        route: Routes.MANAGE_PRODUCTS,
      ));
    }

    manageUsersList.add(ManageAuthMenuModel(
      name: "用户管理",
      subtitle: "管理用户账号和权限",
      authCode: "",
      route: Routes.MANAGE_USERS_TABLE,
    ));

    // 新建人群
    if (ManageAuthUtils.isAuth(ManageAuthCode.apiTagsParamsList)) {
      manageUsersList.add(ManageAuthMenuModel(
        name: "新建人群",
        subtitle: "管理用户人群和标签",
        authCode: ManageAuthCode.apiTagsParamsList,
        route: Routes.MANAGE_NEW_CROWD,
      ));
    }

    // 任务管理
    if (ManageAuthUtils.isAuth(ManageAuthCode.taskList)) {
      manageUsersList.add(ManageAuthMenuModel(
        name: "任务管理",
        subtitle: "管理用户任务",
        authCode: ManageAuthCode.taskList,
        route: Routes.MANAGE_TASK,
      ));
    }

    // 奖励管理
    if (ManageAuthUtils.isAuth(ManageAuthCode.taskPrizeList)) {
      manageUsersList.add(ManageAuthMenuModel(
        name: "奖励管理",
        subtitle: "管理用户奖励",
        authCode: ManageAuthCode.taskPrizeList,
        route: Routes.MANAGE_PRIZE,
      ));
    }

  }

  /// 跳转到子页面
  void toPage(ManageAuthMenuModel data) {
    if (data.route.isEmpty) {
      return;
    }
    ManagePageRegistry.jumpTo(data.route);
  }
}
