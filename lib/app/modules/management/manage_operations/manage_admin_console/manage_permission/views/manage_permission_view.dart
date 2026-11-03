import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/date_format_util.dart';
import '../../../../../../routes/app_pages.dart';
import '../../../../common/manage_scaffold.dart';
import '../bindings/manage_permission_binding.dart';
import '../controllers/manage_permission_controller.dart';

class ManagePermissionView extends GetView<ManagePermissionController> {
  final String tagText;
  const ManagePermissionView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_PERMISSION}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManagePermissionView(tagText: tag),
      binding: ManagePermissionBinding(tag: tag),
      routeName: Routes.MANAGE_PERMISSION,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: ManageScaffold(
        body: Column(
          children: [
            _buildTitleWidget(),
            SizedBox(height: 10.wMin),
            Expanded(child: _buildListWidget()),
          ],
        ),
        floatingActionButton: _buildFilterWidget(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  /// 筛选的按钮
  Widget _buildFilterWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 70.wMin),
      child: Row(
        spacing: 18.wMin,
        children: [
          Expanded(
            child: Obx(() {
              return FilterStripWidget(
                sorts: {...controller.filterSorts},
                conditions: {...controller.filterConditions},
                searchs: controller.filterSearchs,
                onSorts: (sorts) {
                  controller.filterSorts.value = sorts;
                  // controller.refreshList();
                },
                onConditions: (conditions) {
                  controller.filterConditions.value = conditions;
                  // controller.refreshList();
                },
                onReset: (sorts, conditions) {
                  controller.filterSorts.value = sorts;
                  controller.filterConditions.value = conditions;
                  // controller.refreshList();
                },
                onSearch: () {
                  // controller.refreshList();
                },
              );
            
            
            }),
          ),
          ButtonWidget(
            text: "新建员工",
            height: 54.wMin,
            padding: EdgeInsets.symmetric(horizontal: 32.wMin),
            borderRadius: 99,
            color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
            fontColor: AppTheme.cSurfaceBrand.color,
            fontWeight: FontWeight.w500,
            fontSize: 24.wMin,
            sclae: 1.03,
            onTap: () async {
              await controller.createEmployee();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitleWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 70.wMin),
      margin: EdgeInsets.only(top: 16.wMin),
      child: Row(
        children: [
          Text(
            "权限管理",
            style: TextStyle(
              fontSize: 32.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          SizedBox(width: 24.wMin),
          Text(
            "管理员工，并为每位员工配置「可见渠道的用户信息」与「可发送的通知模板」两类权限。",
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

  Widget _buildListWidget() {
    return Obx(() {
      if (controller.permissionUserList.isEmpty && !controller.isLoading.value) {
        return Center(
          child: NotDataWidget(
            message: "暂无员工权限数据",
          ),
        );
      }
      return ListView.separated(
        controller: controller.scrollController,
        itemCount: controller.permissionUserList.length,
        padding: EdgeInsets.only(bottom: 200.wMin, left: 70.wMin, right: 70.wMin, top: 6.wMin),
        separatorBuilder: (context, index) => SizedBox(height: 16.wMin),
        itemBuilder: (context, index) {
          return _buildListItemWidget(controller.permissionUserList[index]);
        },
      );
    });
  }

  Widget _buildListItemWidget(ManagePermissionUserEntity user) {
    bool isEnabled = user.access == 'NORMAL';
    final List<String> roleNames = (user.roleNames ?? []).where((e) => e.trim().isNotEmpty).toList();
    final DateTime? updatedTime = DateFormatUtil.tryParseDate(user.updated ?? user.created);
    final String updatedText = DateFormatUtil.getTimeAgoText(updatedTime);
    return TapScaleWidget(
      onTap: () {
        controller.editEmployee(user);
      },
      sclae: 1,
      child: Container(
        padding: EdgeInsets.all(24.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceLayerBase.color,
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(
            color: AppTheme.cBorderNone.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
            Wrap(
                    spacing: 10.wMin,
                    runSpacing: 8.wMin,
                    children: roleNames.isEmpty
                        ? [
                            _buildListItemTagWidget("未分配岗位"),
                          ]
                        : roleNames.map((item) => _buildListItemTagWidget(item)).toList(),
                  ),
           
                SizedBox(width: 10.wMin),
                Text(
                  "更新：$updatedText",
                  style: TextStyle(
                    fontSize: 14.wMin,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.cTextTertiary.color,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
                  decoration: BoxDecoration(
                    color: isEnabled ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2) : AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6.wMin),
                    border: Border.all(
                      color: isEnabled ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12) : AppTheme.cSurfaceError.color.withValues(alpha: .12),
                      width: 1.wMin,
                    ),
                  ),
                  child: Text(
                    isEnabled ? "已启用" : "已停用",
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: isEnabled ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceError.color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.wMin),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      user.displayName,
                      style: TextStyle(
                        fontSize: 28.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                    SizedBox(width: 10.wMin),
                    SelectableText(
                      '用户ID：${user.userId ?? '--'}',
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextTertiary.color,
                      ),
                    )
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    _itemRightWight('可见渠道', user.channelCount, AppTheme.cFeedbackWarningBorder),
                    SizedBox(width: 12.wMin),
                    _itemRightWight('通知模版', user.notifyTemplateCount, Color(0xff06B6D4)),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItemTagWidget(String? text) {
    if (text == null) return SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cCardLevelColor3.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: AppTheme.cCardLevelColor3.color.withValues(alpha: 0.12),
          width: 1.wMin,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.wMin,
          fontWeight: FontWeight.w400,
          color: AppTheme.cCardLevelColor3.color,
        ),
      ),
    );
  }
  Widget _itemRightWight(String text, int i, Color? color) {
    return Container(
      height: 76.wMin,
      width: 80.wMin,
      padding: EdgeInsets.all(6.wMin),
      decoration: BoxDecoration(
          color: AppTheme.cSurfaceTranslucentBase,
          border: Border.all(
            color: AppTheme.cBorderNone,
          ),
          borderRadius: BorderRadius.circular(8.wMin)),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          Text(
            '$i',
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w600,
              color: color ?? AppTheme.cTextPrimary.color,
            ),
          )
        ],
      ),
    );
  }


}
