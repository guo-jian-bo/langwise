import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/https/https.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../routes/routes.dart';
import '../../../utils/utils.dart';
import '../models/manage_admin_console_menu_enum.dart';
import '../models/manage_admin_console_menu_model.dart';

class ManageAdminConsoleController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageAdminConsoleController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_ADMIN_CONSOLE;

  @override
  String get breadcrumbTitle => '管理员操作台';

  final Rx<ManageInspectionStatisticsEntity> inspectionStatistics = ManageInspectionStatisticsEntity().obs;

  /// 管理菜单列表
  final RxList<ManageAdminConsoleMenuModel> menuList = <ManageAdminConsoleMenuModel>[].obs;

  /// 数据菜单列表
  final RxList<ManageAdminConsoleMenuModel> dataMenuList = <ManageAdminConsoleMenuModel>[].obs;


  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    getManageInspectionStatistics();
    setMenuList();
  }


  /// 设置菜单 后续需要判断权限
  void setMenuList(){

    if(ManageAuthUtils.isAnyAuth([ManageAuthCode.notifyTemplatePages])){
      menuList.add(ManageAdminConsoleMenuModel(
        menu: ManageAdminConsoleMenuEnum.notificationTemplate,
        title: "通知模板",
        desc: "维护 push 模板：标题、内容、跳进 APP 的 Markdown 详情与跳转配置",
        iconBgColor: AppTheme.cSurfaceBrand.color.withValues(alpha: .12),
        svg: "assets/svg/public/icon_notice.svg",
        // tags: ["6个模版"],
      ));
    }

    if(ManageAuthUtils.isAnyAuth([ManageAuthCode.channelTicketTemplatePages])){
      menuList.add(ManageAdminConsoleMenuModel(
        menu: ManageAdminConsoleMenuEnum.workOrderTemplate,
        title: "工单模板",
        desc: "像表单搭建器一样插入多种表单项，定义工单收集的字段",
        iconBgColor: Color(0xffF43F5E).withValues(alpha: .12),
        svg: "assets/svg/public/icon_ticket.svg",
        // tags: ["6个模版"],
      ));
    }

    if(ManageAuthUtils.isAnyAuth([ManageAuthCode.channelPages])){
      menuList.add(ManageAdminConsoleMenuModel(
        menu: ManageAdminConsoleMenuEnum.channelManagement,
        title: "渠道管理",
        desc: "管理两级购买渠道（一级 · 二级），每个渠道拥有唯一ID",
        iconBgColor: Color(0xffF59E0B).withValues(alpha: .12),
        svg: "assets/svg/public/icon_channel.svg",
        // tags: ["4个一级"],
      ));
    }

    if(ManageAuthUtils.isAnyAuth([ManageAuthCode.channelUserPages])){
      menuList.add(ManageAdminConsoleMenuModel(
        menu: ManageAdminConsoleMenuEnum.permissionManagement,
        title: "权限管理",
        desc: "管理员工，配置可见渠道与可发送通知模板的权限",
        iconBgColor: Color(0xffA855F7).withValues(alpha: .12),
        svg: "assets/svg/public/icon_permission_avatar.svg",
        // tags: ["4 名员工"],
      ));
    }

    dataMenuList.value = [
      ManageAdminConsoleMenuModel(
        menu: ManageAdminConsoleMenuEnum.inspectionStatistics,
        title: "巡检统计",
        desc: "按工作人员查看领取、转交、通知、工单与学员数据操作留痕，点击进入详细记录。",
        iconBgColor: Color(0xff14B8A6).withValues(alpha: .12),
        svg: "assets/svg/public/icon_inspection.svg",
        // tags: ["3名在岗工作人员"],
      ),
    ];
  }

  /// 菜单跳转
  Future<void> navigateToMenu(ManageAdminConsoleMenuModel menu) async{
    if(menu.menu == ManageAdminConsoleMenuEnum.notificationTemplate){
      await ManagePageRegistry.jumpTo(Routes.MANAGE_NOTICE_TEMP);
    } else if(menu.menu == ManageAdminConsoleMenuEnum.workOrderTemplate){
      await ManagePageRegistry.jumpTo(Routes.MANAGE_TICKET_TEMP);
    } else if(menu.menu == ManageAdminConsoleMenuEnum.channelManagement){
      await ManagePageRegistry.jumpTo(Routes.MANAGE_CHANNEL);
    } else if(menu.menu == ManageAdminConsoleMenuEnum.permissionManagement){
      await ManagePageRegistry.jumpTo(Routes.MANAGE_PERMISSION);
    } else if(menu.menu == ManageAdminConsoleMenuEnum.inspectionStatistics){
      await ManagePageRegistry.jumpTo(Routes.MANAGE_INSPECTION_STATISTICS);
    }
    await getManageInspectionStatistics();
  }

  /// 查询统计
  Future<void> getManageInspectionStatistics() async{
    if(!ManageAuthUtils.isAuth(ManageAuthCode.channelUserConsoleSummary)) return;
    ManageInspectionStatisticsEntity? entity = await AccountConsoleRequest.getManageInspectionStatistics();
    if(entity == null) return;
    inspectionStatistics.value = entity;
    for(ManageAdminConsoleMenuModel menu in menuList){
      if(menu.menu == ManageAdminConsoleMenuEnum.notificationTemplate){
        menu.tags = ["${entity.notifyTemplateCount??0} 个模版"];
      }else if(menu.menu == ManageAdminConsoleMenuEnum.workOrderTemplate){
        menu.tags = ["${entity.ticketTemplateCount??0} 个模版"];
      }else if(menu.menu == ManageAdminConsoleMenuEnum.channelManagement){
        menu.tags = ["${entity.firstLevelChannelCount??0} 个一级"];
      }else if(menu.menu == ManageAdminConsoleMenuEnum.permissionManagement){
        menu.tags = ["${entity.assistantCount??0} 名员工"];
      }
    }
    menuList.refresh();
  }


  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
