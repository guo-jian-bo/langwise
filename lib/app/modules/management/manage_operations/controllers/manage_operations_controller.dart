
import 'package:get/get.dart';

import '../../../../routes/routes.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';

class ManageOperationsController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageOperationsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_OPERATIONS;

  @override
  String get breadcrumbTitle => '运营';

  final RxList<ManageAuthMenuModel> manageAdminList = <ManageAuthMenuModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    initAuth();

  }

  void initAuth(){
    manageAdminList.clear();

    if(ManageAuthUtils.isAnyAuth([ManageAuthCode.staffConsoleMemberPages, ManageAuthCode.staffConsoleSummary])){
      manageAdminList.add(ManageAuthMenuModel(
        name: "工作人员操作台",
        subtitle: "用四色风险快速扫学员状态，优先处理新学员漏斗卡点、学习中断和待处理工单。",
        authCode: "",
        route: Routes.MANAGE_EMPLOYEE_CONSOLE,
        params: {
          "isManagement": true,
        },
      ));
    }

    if(ManageAuthUtils.isAnyAuth([
      ManageAuthCode.notifyTemplatePages, 
      ManageAuthCode.channelTicketTemplatePages,
      ManageAuthCode.channelPages,
      ManageAuthCode.channelUserPages,
    ])){
      manageAdminList.add(ManageAuthMenuModel(
        name: "管理员操作台",
        subtitle: "通知 / 权限 / 渠道 / 工单模版配置",
        authCode: "",
        route: Routes.MANAGE_ADMIN_CONSOLE,
      ));
    }
  }

  void toPage(ManageAuthMenuModel data){
    if(data.route.isEmpty) return;
    ManagePageRegistry.jumpTo(
      data.route,
      arguments: data.params,
    );
  }


  /// 跳转至管理员操作台
  Future<void> navigateToAdminOperations() async{
    ManagePageRegistry.jumpTo(Routes.MANAGE_ADMIN_CONSOLE);
  }



  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
