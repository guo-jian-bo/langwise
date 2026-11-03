import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../../../routes/routes.dart';
import '../../../common/commons.dart';
import '../../../utils/utils.dart';
import '../bindings/manage_employee_console_binding.dart';
import '../controllers/manage_employee_console_controller.dart';
import 'manage_employee_student_card_widget.dart';

class ManageEmployeeConsoleView extends GetView<ManageEmployeeConsoleController> {
  final String tagText;
  const ManageEmployeeConsoleView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_EMPLOYEE_CONSOLE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageEmployeeConsoleView(tagText: tag),
      binding: ManageEmployeeConsoleBinding(tag: tag),
      routeName: Routes.MANAGE_EMPLOYEE_CONSOLE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      onRefresh: () {
        controller.refreshList();
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWidget(),
          _buildStatisticsWidget(),
          Expanded(child: _buildStudentListWidget(context)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFilterWidget(context),
    );
  }

  /// 筛选的按钮
  Widget _buildFilterWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 70.wMin),
      child: Obx((){
        return FilterStripWidget(
          width: double.infinity,
          sorts: {...controller.filterSorts},
          conditions: {...controller.filterConditions},
          searchs: controller.filterSearchs,
          onSorts: (sorts) {
            controller.filterSorts.value = sorts;
            controller.refreshList();
          },
          onConditions: (conditions) {
            controller.filterConditions.value = conditions;
            controller.refreshList();
          },
          onReset: (sorts, conditions) {
            controller.filterSorts.value = sorts;
            controller.filterConditions.value = conditions;
            controller.refreshList();
          },
          onSearch: () {
            controller.refreshList();
          },
        );
      }),
    );
  }



  Widget _buildTitleWidget(){
    return Container(
      margin: EdgeInsets.only(top: 16.wMin),
      padding: EdgeInsets.symmetric(horizontal: 70.wMin),
      child: Row(
        children: [
          Text(
            "工作人员操作台",
            style: TextStyle(
              fontSize: 32.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(width: 24.wMin),
          Text(
            "用四色风险快速扫学员状态，优先处理新学员漏斗卡点、学习中断和待处理工单。",
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
      authCodes: [ManageAuthCode.staffConsoleSummary],
      margin: EdgeInsets.only(top: 16.wMin),
      padding: EdgeInsets.symmetric(horizontal: 70.wMin),
      child: Obx((){
        return Row(
          spacing: 16.wMin,
          children: [
            _buildStatisticsItemWidget(
              title: "今日新增",
              value: controller.summaryData.value.todayNewMemberCount?.toString() ?? "0",
              svg: "assets/svg/public/icon_hard_add.svg",
              svgColor: Color(0xff06B6D4),
            ),
            _buildStatisticsItemWidget(
              title: "未评测",
              value: controller.summaryData.value.unAssessedMemberCount?.toString() ?? "0",
              svg: "assets/svg/public/icon_mortarboard.svg",
              svgColor: Color(0xffF59E0B),
            ),
            _buildStatisticsItemWidget(
              title: "未设置计划",
              value: controller.summaryData.value.unPlannedMemberCount?.toString() ?? "0",
              svg: "assets/svg/public/icon_polyline.svg",
              svgColor: Color(0xffFF1C1C),
            ),
            _buildStatisticsItemWidget(
              title: "未开学",
              value: controller.summaryData.value.unStartedMemberCount?.toString() ?? "0",
              svg: "assets/svg/public/icon_notice.svg",
              svgColor: Color(0xffD946EF),
            ),
            _buildStatisticsItemWidget(
              title: "高风险",
              value: controller.summaryData.value.highRiskMemberCount?.toString() ?? "0",
              svg: "assets/svg/public/icon_high_risk.svg",
              svgColor: Color(0xffF97316),
            ),
            _buildStatisticsItemWidget(
              title: "待处理工单",
              value: controller.summaryData.value.pendingTicketMemberCount?.toString() ?? "0",
              svg: "assets/svg/public/icon_ticket.svg",
              svgColor: Color(0xffF43F5E),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatisticsItemWidget({
    required String title,
    required String value,
    required String svg,
    required Color svgColor,
  }){
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 10.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.wMin),
          color: AppTheme.cSurfaceLayerBase.color,
          border: Border.all(
            color: AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.wMin,
              height: 40.wMin,
              padding: EdgeInsets.all(8.wMin),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: svgColor.withValues(alpha: 0.2),
              ),
              child: SvgPicture.asset(
                svg,
                colorFilter: ColorFilter.mode(svgColor, BlendMode.srcIn),
              ),
            ),
            SizedBox(width: 16.wMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SelectableText(
                    title,
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextSecondary.color,
                    ),
                  ),
                  SelectableText(
                    value,
                    style: TextStyle(
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// 学员巡检卡片列表
  Widget _buildStudentListWidget(BuildContext context){
    return ManageAuthBoxWidget(
      authCodes: [ManageAuthCode.staffConsoleMemberPages],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.wMin),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 70.wMin),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "学员巡检卡片",
                  style: TextStyle(
                    fontSize: 28.wMin,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cTextPrimary.color,
                  ),
                ),
                Obx((){
                  return Visibility(visible:controller.memberCount.value>0 , child: Text(
                    "(${controller.memberCount.value})",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextSecondary.color,
                    ),
                  ));
                }),
              ],
            ),
          ),
          SizedBox(height: 10.wMin),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 2;
                double width = constraints.maxWidth;
                double height = constraints.maxHeight;
                double aspectRatio = width / height;
                if(aspectRatio < 0.8){
                  crossAxisCount = 1;
                }
      
                return Obx((){
                  if(controller.memberList.isEmpty && !controller.isLoading.value){
                    return Center(
                      child: NotDataWidget(
                        message: "暂无学员",
                      ),
                    );
                  }
                  return GridView.builder(
                    controller: controller.scrollController,
                    itemCount: controller.memberList.length,
                    padding: EdgeInsets.only(bottom: 200.wMin, left: 70.wMin, right: 70.wMin, top: 6.wMin),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16.wMin,
                      crossAxisSpacing: 16.wMin,
                      mainAxisExtent: 550.wMin,
                    ),
                    itemBuilder: (context, index) {
                      // return _buildStudentCardWidget(controller.memberList[index], context);
                      return ManageEmployeeStudentCardWidget(
                        controller: controller,
                        item: controller.memberList[index],
                      );
                    },
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  
}
