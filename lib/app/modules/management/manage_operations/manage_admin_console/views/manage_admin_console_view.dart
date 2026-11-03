import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../common/manage_scaffold.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_admin_console_binding.dart';
import '../controllers/manage_admin_console_controller.dart';
import '../models/manage_admin_console_menu_model.dart';

class ManageAdminConsoleView extends GetView<ManageAdminConsoleController> {
  final String tagText;
  const ManageAdminConsoleView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_ADMIN_CONSOLE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageAdminConsoleView(tagText: tag),
      binding: ManageAdminConsoleBinding(tag: tag),
      routeName: Routes.MANAGE_ADMIN_CONSOLE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 70.wMin),
        child: Column(
          children: [
            _buildTitleWidget(),
            _buildStatisticsWidget(),
            Expanded(
              child: SingleChildScrollView(
                child: _buildBodyWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Container(
      margin: EdgeInsets.only(top: 16.wMin),
      child: Row(
        children: [
          Text(
            "管理员操作台",
            style: TextStyle(
              fontSize: 32.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(width: 24.wMin),
          Text(
            "集中维护工作人员端所依赖的基础资产与过程数据：通知模板、工单模板、渠道权限以及巡检统计留痕。",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
        ],
      ),
    );
  }

  /// 统计
  Widget _buildStatisticsWidget(){
    return ManageAuthBoxWidget(
      authCodes: [ManageAuthCode.channelUserConsoleSummary],
      child: Container(
        margin: EdgeInsets.only(top: 16.wMin),
        child: Obx((){
          ManageInspectionStatisticsEntity entity = controller.inspectionStatistics.value;
          return Row(
            spacing: 16.wMin,
            children: [
              _buildStatisticsItemWidget("通知模板", entity.notifyTemplateCount),
              _buildStatisticsItemWidget("工单模板", entity.ticketTemplateCount),
              _buildStatisticsItemWidget("渠道", entity.firstLevelChannelCount),
              _buildStatisticsItemWidget("员工", entity.assistantCount),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatisticsItemWidget(String name, int? value){
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: AppTheme.cBorderNone.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
            Text(
              value?.toString()??"0",
              style: TextStyle(
                fontSize: 38.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBodyWidget(){
    return Container(
      margin: EdgeInsets.only(top: 32.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryTitle("管理"),
          SizedBox(height: 16.wMin),
          Obx((){
            return GridView.builder(
              itemCount: controller.menuList.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16.wMin,
                crossAxisSpacing: 16.wMin,
                mainAxisExtent: 120.wMin,
              ),
              itemBuilder: (context, index) {
                return _buildCategoryItemWidget(controller.menuList[index]);
              },
            );
          }),
          
          SizedBox(height: 32.wMin),
          _buildCategoryTitle("数据"),
          SizedBox(height: 16.wMin),
          Obx((){
            return GridView.builder(
              itemCount: controller.dataMenuList.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16.wMin,
                crossAxisSpacing: 16.wMin,
                mainAxisExtent: 120.wMin,
              ),
              itemBuilder: (context, index) {
                return _buildCategoryItemWidget(controller.dataMenuList[index]);
              },
            );
          }),
      
        ],
      ),
    );
  }


  Widget _buildCategoryTitle(String text){
    return Text(
      text,
      style: TextStyle(
        fontSize: 24.wMin,
        fontWeight: FontWeight.w500,
        color: AppTheme.cTextPrimary.color,
      ),
    );
  }

  Widget _buildCategoryItemWidget(ManageAdminConsoleMenuModel item){
    return TapScaleWidget(
      onTap: () {
        controller.navigateToMenu(item);
      },
      sclae: 1.005,
      child: Container(
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: AppTheme.cBorderNone.color,
            width: 1.wMin,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 70.wMin,
              height: 70.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: item.iconBgColor,
                borderRadius: BorderRadius.circular(12.wMin),
              ),
              child: SvgPicture.asset(
                item.svg,
                width: 24.wMin,
              ),
            ),
            SizedBox(width: 12.wMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 6.wMin,
                children: [
                  Row(
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      ),
                      SizedBox(width: 8.wMin),
                      Visibility(
                        visible: (item.tags??[]).isNotEmpty,
                        child: Row(
                          spacing: 6.wMin,
                          children: List.generate(item.tags?.length??0, (index){
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 4.wMin),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.wMin),
                                color: AppTheme.cSurfaceTertiary.color,
                                border: Border.all(
                                  color: AppTheme.cBorderSecondary.color,
                                  width: 1.wMin,
                                ),
                              ),
                              child: Text(
                                item.tags?[index]??"",
                                style: TextStyle(
                                  fontSize: 18.wMin,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.cTextSecondary.color,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    item.desc,
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextSecondary.color,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.wMin),
            SvgPicture.asset(
              "assets/svg/public/icon_w_arrow_right.svg",
              width: 36.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cTextDisabled.color, BlendMode.srcIn),
            ),
    
          ],
        ),
      ),
    );
  }


}
