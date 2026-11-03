import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../enums/enums.dart';
import '../../../../utils/utils.dart';
import '../bindings/manage_permission_create_binding.dart';
import '../controllers/manage_permission_create_controller.dart';

class ManagePermissionCreateView extends GetView<ManagePermissionCreateController> {
  final String tagText;
  const ManagePermissionCreateView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_PERMISSION_CREATE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManagePermissionCreateView(tagText: tag),
      binding: ManagePermissionCreateBinding(tag: tag),
      routeName: Routes.MANAGE_PERMISSION_CREATE,
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
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 70.wMin),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleWidget(),
                      SizedBox(height: 24.wMin),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 70.wMin),
            child: ListView(
              padding: EdgeInsets.only(bottom: 140.wMin),
              children: [
                _buildBasicInfoWidget(context),
                SizedBox(height: 16.wMin),
                _buildChannelPermissionsWidget(),
                SizedBox(height: 16.wMin),
                _buildNotifyPermissionsWidget(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildButtonsWidget(context),
      ),
    );
  }

  Widget _buildTitleWidget() {
    return Container(
      margin: EdgeInsets.only(top: 10.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6.wMin,
        children: [
          Text(
            controller.isEdit ? "编辑员工" : "新建员工",
            style: TextStyle(
              fontSize: 32.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          Text(
            "配置员工基础信息，以及可见渠道与可发送通知模板两类权限。",
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

  Widget _buildButtonsWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 70.wMin, vertical: 24.wMin),
      color: AppTheme.cBgPrimary.color,
      child: Row(
        children: [
          Visibility(
            visible: controller.isEdit,
            child: ManageAuthBoxWidget(
              authCodes: [ManageAuthCode.channelUserEdit],
              child: ButtonWidget(
                text: "删除员工",
                height: 54.wMin,
                padding: EdgeInsets.symmetric(horizontal: 32.wMin),
                borderRadius: 99,
                color: AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
                fontColor: AppTheme.cSurfaceError.color,
                fontWeight: FontWeight.w500,
                fontSize: 24.wMin,
                sclae: 1.03,
                onTap: () async {
                  await controller.onDeleteEmployee(context);
                },
              ),
            ),
          ),
          const Spacer(),
          ButtonWidget(
            text: "返回列表",
            height: 54.wMin,
            padding: EdgeInsets.symmetric(horizontal: 32.wMin),
            borderRadius: 99,
            color: AppTheme.cSurfaceLayerElevated.color,
            fontColor: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w500,
            fontSize: 24.wMin,
            sclae: 1.03,
            onTap: () {
              Get.back();
            },
          ),
          SizedBox(width: 24.wMin),
          ManageAuthBoxWidget(
            authCodes: [controller.isEdit ? ManageAuthCode.channelUserEdit : ManageAuthCode.channelUserCreate],
            child: ButtonWidget(
              text: controller.isEdit ? "保存修改" : "创建员工",
              height: 54.wMin,
              padding: EdgeInsets.symmetric(horizontal: 32.wMin),
              borderRadius: 99,
              color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
              fontColor: AppTheme.cSurfaceBrand.color,
              fontWeight: FontWeight.w500,
              fontSize: 24.wMin,
              sclae: 1.03,
              onTap: () async {
                await controller.onCreate();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.wMin),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBodyTitleWidget(title: "基础信息", subTitle: "员工姓名、用户ID 与岗位。"),
              const Spacer(),
              Obx(() {
                return Row(
                  children: [
                    CardSwitchWidget(
                      value: controller.isEnable.value,
                      onChanged: (value) {
                        controller.isEnable.value = value;
                      },
                    ),
                    SizedBox(width: 8.wMin),
                    Text(
                      controller.isEnable.value ? "已启用" : "已停用",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          SizedBox(height: 16.wMin),
          Row(
            spacing: 16.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInputWidget(
                  title: "用户ID",
                  hintText: "请输入后台用户ID",
                  controller: controller.userIdController,
                  maxLength: 20,
                  readOnly: controller.isEdit,
                ),
              ),
              Expanded(
                child: _buildInputWidget(
                  title: "姓名",
                  hintText: "员工姓名",
                  controller: controller.nameController,
                  maxLength: 20,
                ),
              ),
              Expanded(
                child: Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormTitleWidget(title: "岗位", isRequired: true),
                      SizedBox(height: 8.wMin),
                      IconDropdownSelectWidget(
                        hintText: "请选择岗位",
                        items: controller.roleOptions
                            .map((e) => IconDropdownCheckData<int>(title: e.name, value: e.id))
                            .toList(),
                        multiSelect: true,
                        selectValues: controller.selectedRoleIds.toList(),
                        selectValue: null,
                        borderRadius: BorderRadius.circular(8.wMin),
                        borderColor: AppTheme.cBorderNone.color,
                        fillColor: AppTheme.cSurfaceLayerElevated2.color,
                        itemFontSize: 24.wMin,
                        itemHeight: 72.wMin,
                        valueStyle: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextPrimary.color,
                        ),
                        onChanged: (value, index) {
                          final dynamic roleId = value.value;
                          if (roleId is int) {
                            controller.toggleRoleId(roleId);
                          }
                        },
                      ),
                    ],
                  );
                }),
              ),
              Expanded(
                child: Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormTitleWidget(title: "用户组", isRequired: true),
                      SizedBox(height: 8.wMin),
                      IconDropdownSelectWidget(
                        hintText: "请选择用户组",
                        items: ManageUserRoleGruopEnum.values.map((e) => IconDropdownCheckData<ManageUserRoleGruopEnum>(title: e.name, value: e)).toList(),
                        multiSelect: false,
                        selectValue: controller.selectedAdminGroup.value,
                        selectValues: null,
                        borderRadius: BorderRadius.circular(8.wMin),
                        borderColor: AppTheme.cBorderNone.color,
                        fillColor: AppTheme.cSurfaceLayerElevated2.color,
                        itemFontSize: 24.wMin,
                        itemHeight: 72.wMin,
                        valueStyle: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextPrimary.color,
                        ),
                        onChanged: (value, index) {
                          final dynamic group = value.value;
                          if (group is ManageUserRoleGruopEnum) {
                            controller.setSelectedAdminGroup(group);
                          }
                        },
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChannelPermissionsWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.wMin),
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
          Row(
            children: [
              Expanded(child: _buildBodyTitleWidget(title: "可见渠道权限", subTitle: "勾选该员工可以看到哪些渠道的用户信息（来自渠道管理的二级节点）。")),
              _buildSmallButton(text: "全选", onTap: controller.selectAllChannels),
              SizedBox(width: 8.wMin),
              _buildSmallButton(text: "清空", onTap: controller.clearChannels),
            ],
          ),
          SizedBox(height: 16.wMin),
          ...controller.channelGroups.map((group) {
            return Container(
              margin: EdgeInsets.only(bottom: 16.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.title,
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextTertiary.color,
                    ),
                  ),
                  SizedBox(height: 10.wMin),
                  Obx(() {
                    return Wrap(
                      spacing: 10.wMin,
                      runSpacing: 10.wMin,
                      children: group.options.map((option) {
                        final selected = controller.selectedChannelIds.contains(option.id);
                        return _buildSelectChip(
                          text: option.name,
                          selected: selected,
                          onTap: () {
                            controller.toggleChannel(option.id);
                          },
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            );
          }).toList(),
          Obx(() {
            return Text(
              "已选 ${controller.selectedChannelIds.length} 个渠道节点",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotifyPermissionsWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.wMin),
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
          Row(
            children: [
              Expanded(child: _buildBodyTitleWidget(title: "可发送通知权限", subTitle: "勾选该员工可以发送哪些通知模板（来自通知管理）。")),
              _buildSmallButton(text: "全选", onTap: controller.selectAllNotifyTemplates),
              SizedBox(width: 8.wMin),
              _buildSmallButton(text: "清空", onTap: controller.clearNotifyTemplates),
            ],
          ),
          SizedBox(height: 16.wMin),
          ...controller.notifyTemplateGroups.map((group) {
            return Container(
              margin: EdgeInsets.only(bottom: 16.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.title,
                    style: TextStyle(
                      fontSize: 16.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextTertiary.color,
                    ),
                  ),
                  SizedBox(height: 10.wMin),
                  Obx(() {
                    return Wrap(
                      spacing: 10.wMin,
                      runSpacing: 10.wMin,
                      children: group.options.map((option) {
                        final selected = controller.selectedNotifyTemplateIds.contains(option.id);
                        return _buildSelectChip(
                          text: option.name,
                          selected: selected,
                          onTap: () {
                            controller.toggleNotifyTemplate(option.id);
                          },
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            );
          }).toList(),
          Obx(() {
            return Text(
              "已选 ${controller.selectedNotifyTemplateIds.length} 个通知模板",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSmallButton({required String text, required VoidCallback onTap}) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.05,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: AppTheme.cSurfaceLayerElevated2.color,
          border: Border.all(
            color: AppTheme.cBorderNone.color,
            width: 1.wMin,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectChip({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final Color bgColor = selected ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2) : AppTheme.cSurfaceLayerElevated2.color;
    final Color borderColor = selected ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.25) : AppTheme.cBorderNone.color;
    final Color textColor = selected ? AppTheme.cSurfaceBrand.color : AppTheme.cTextSecondary.color;

    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.05,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: bgColor,
          border: Border.all(
            color: borderColor,
            width: 1.wMin,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildBodyTitleWidget({
    required String title,
    required String subTitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SizedBox(height: 2.wMin),
        Text(
          subTitle,
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
      ],
    );
  }

  Widget _buildInputWidget({
    required String title,
    String? subTitle,
    bool isRequired = true,
    required String hintText,
    required TextEditingController controller,
    double? height,
    int? maxLength,
    int? maxLines,
    void Function(String value)? onChanged,
    Widget? suffixWidget,
    Widget? prefixWidget,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormTitleWidget(title: title, subTitle: subTitle, isRequired: isRequired),
        SizedBox(height: 8.wMin),
        Row(
          children: [
            Expanded(
              child: CardInputWidget(
                hintText: hintText,
                controller: controller,
                readOnly: readOnly,
                height: height ?? 72.wMin,
                maxLines: maxLines,
                maxLength: maxLength,
                borderRadius: BorderRadius.circular(8.wMin),
                borderWidth: 1.wMin,
                borderColor: AppTheme.cBorderNone.color,
                fillColor: AppTheme.cSurfaceLayerElevated2.color,
                hintStyle: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextTertiary.color,
                ),
                valueStyle: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.color,
                ),
                prefixIcon: prefixWidget,
                onChanged: onChanged,
              ),
            ),
            Visibility(
              visible: suffixWidget != null,
              child: Container(
                margin: EdgeInsets.only(left: 8.wMin),
                child: suffixWidget,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormTitleWidget({
    required String title,
    String? subTitle,
    bool isRequired = true,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        Visibility(
          visible: isRequired,
          child: Container(
            margin: EdgeInsets.only(left: 4.wMin),
            child: Text(
              "*",
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cSurfaceError.color,
              ),
            ),
          ),
        ),
        Visibility(
          visible: subTitle != null,
          child: Container(
            margin: EdgeInsets.only(left: 8.wMin),
            child: Text(
              subTitle ?? "",
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
