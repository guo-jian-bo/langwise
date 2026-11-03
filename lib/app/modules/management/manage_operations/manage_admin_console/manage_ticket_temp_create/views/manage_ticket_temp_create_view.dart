import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../bindings/manage_ticket_temp_create_binding.dart';
import '../controllers/manage_ticket_temp_create_controller.dart';
import 'manage_ticket_temp_create_form_widget.dart';

class ManageTicketTempCreateView extends GetView<ManageTicketTempCreateController> {
  final String tagText;
  const ManageTicketTempCreateView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_TICKET_TEMP_CREATE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageTicketTempCreateView(tagText: tag),
      binding: ManageTicketTempCreateBinding(tag: tag),
      routeName: Routes.MANAGE_TICKET_TEMP_CREATE,
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
        showCollectButton: false,
        body: NestedScrollView(
          controller: controller.scrollController,
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
                      _buildHeaderWidget(context),
                      SizedBox(height: 16.wMin),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 70.wMin),
            child: ManageTicketTempCreateFormWidget(controller: controller),
          ),
        ),
        bottomNavigationBar: _buildButtonsWidget(context),
      ),
    );
  }

  /// 按钮
  Widget _buildButtonsWidget(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 70.wMin, vertical: 24.wMin),
      color: AppTheme.cBgPrimary.color,
      child: Row(
        children: [
          Visibility(
            visible: controller.ticketTemp != null,
            child: ManageAuthBoxWidget(
              authCodes: [ManageAuthCode.channelTicketTemplateRemove],
              child: ButtonWidget(
                text: "删除模版",
                height: 54.wMin,
                padding: EdgeInsets.symmetric(horizontal: 32.wMin),
                borderRadius: 99,
                color: AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
                fontColor: AppTheme.cSurfaceError.color,
                fontWeight: FontWeight.w500,
                fontSize: 24.wMin,
                sclae: 1.03,
                onTap: () async {
                  await controller.deleteTicketTemp(context);
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
          ButtonWidget(
            text: controller.ticketTemp == null ? "创建模版" : "保存模版",
            height: 54.wMin,
            padding: EdgeInsets.symmetric(horizontal: 32.wMin),
            borderRadius: 99,
            color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
            fontColor: AppTheme.cSurfaceBrand.color,
            fontWeight: FontWeight.w500,
            fontSize: 24.wMin,
            sclae: 1.03,
            onTap: () async {
              if(controller.ticketTemp == null){
                await controller.createTicketTemp();
              }else{
                await controller.editTicketTemp();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitleWidget(){
    return Container(
      margin: EdgeInsets.only(top: 10.wMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6.wMin,
            children: [
              Text(
                controller.ticketTemp == null ? "新建工单模板" : "编辑工单模板",
                style: TextStyle(
                  fontSize: 32.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              Text(
                "从「添加表单项」面板插入字段，每个表单项可设置标题、提示、必填与选项。",
                style: TextStyle(
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextSecondary.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderWidget(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBasicInfoWidget(context),
      ],
    );
  }

  /// 基础信息
  Widget _buildBasicInfoWidget(BuildContext context){
  
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
              _buildBodyTitleWidget(title: "基础信息", subTitle: "工单模板名称与说明。"),
              const Spacer(),
              Obx((){
                return Row(
                  children: [
                    CardSwitchWidget(
                      value: controller.isEnable.value,
                      // switchActiveColor: AppTheme.cSwitchSuccess.color,
                      onChanged: (value){
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
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 16.wMin,
            children: [
              Expanded(
                child: _buildInputWidget(
                  title: "模板名称",
                  hintText: "例如：教材信息补充",
                  controller: controller.tempNameController,
                  maxLength: 50,
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    return Obx((){
                      // 开始结束时间
                      String startTime = controller.startTime.value != null ? DateFormatUtil.formatStr(controller.startTime.value!) : "";
                      String endTime = controller.endTime.value != null ? DateFormatUtil.formatStr(controller.endTime.value!) : "";
                      return _buildTapWidget(
                        title: "可提交开始结束时间",
                        hintText: "选择时间",
                        value: "$startTime ~ $endTime",
                        isRequired: false,
                        onTap: () async {
                          await controller.selectStartTime(context);
                        },
                      );
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16.wMin),
          Obx((){
            return Row(
              spacing: 16.wMin,
              children: [
                Expanded(
                  child: _buildTapWidget(
                    title: "工单处理完成通知模版",
                    hintText: "选择通知模版",
                    isRequired: false,
                    value: controller.completeNotifyTemp.value?.name,
                    onTap: () async {
                      await controller.selectCompleteNotify(context);
                    },
                  ),
                ),
                Expanded(
                  child: _buildTapWidget(
                    title: "工单要求修改通知模版",
                    hintText: "选择通知模版",
                    isRequired: false,
                    value: controller.modifyNotifyTemp.value?.name,
                    onTap: () async {
                      await controller.selectModifyNotify(context);
                    },
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 16.wMin),

          _buildInputWidget(
            title: "模板说明",
            hintText: "这个工单用来收集什么信息",
            isRequired: false,
            controller: controller.tempDescController,
          ),
          SizedBox(height: 16.wMin),
          Obx((){
            return Row(
              spacing: 16.wMin,
              children: [
                Expanded(
                  child: _buildSwitchWidget(
                    title: "是否在APP内打开",
                    value: controller.isOpenInApp.value,
                    onChanged: (value) {
                      controller.toggleIsInApp(value);
                    },
                  ),
                ),
                Expanded(
                  child: _buildSwitchWidget(
                    title: "是否必须登录",
                    value: controller.isMustLogin.value,
                    onChanged: (value) {
                      controller.toggleIsMustLogin(value);
                    },
                  ),
                ),
                Expanded(
                  child: _buildSwitchWidget(
                    title: "是否允许多次提交",
                    value: controller.isAllowMultipleSubmit.value,
                    onChanged: (value) {
                      controller.toggleIsAllowMultipleSubmit(value);
                    },
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }


  Widget _buildBodyTitleWidget({
    required String title,
    required String subTitle,
  }){
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

  /// 选择组件
  Widget _buildTapWidget({
    required String title,
    String? subTitle,
    bool isRequired = true,
    required String hintText,
    String? value,
    double? height,
    void Function()? onTap,
  }){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormTitleWidget(title: title, subTitle: subTitle, isRequired: isRequired),
        SizedBox(height: 8.wMin),
        TapScaleWidget(
          onTap: onTap,
          sclae: 1,
          child: Container(
            height: height ?? 72.wMin,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: AppTheme.cSurfaceLayerElevated2.color,
              border: Border.all(
                color: AppTheme.cBorderNone.color,
                width: 1.wMin,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: value != null && value.isNotEmpty ? Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextPrimary.color,
                    ),
                  ) : Text(
                    hintText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cTextTertiary.color,
                    ),
                  ),
                ),
                SvgPicture.asset(
                  "assets/svg/public/icon_w_arrow_right.svg",
                  width: 28.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  /// 开关
  Widget _buildSwitchWidget({
    required String title,
    required bool value,
    required void Function(bool value) onChanged,
  }){
    return Container(
      width: double.infinity,
      height: 72.wMin,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceLayerElevated2.color,
        border: Border.all(
          color: AppTheme.cBorderNone.color,
          width: 1.wMin,
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          const Spacer(),
          CardSwitchWidget(
            value: value,
            // switchActiveColor: AppTheme.cSwitchSuccess.color,
            onChanged: onChanged,
          ),
        ],
      ),
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
    int? maxLines = 1,
    void Function(String value)? onChanged,
    Widget? suffixWidget,
    Widget? prefixWidget,
  }){
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
  }){
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
          child: Text(
            "*",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cSurfaceError.color,
            ),
          ),
        ),
        const Spacer(),
        Visibility(
          visible: subTitle != null,
          child: SelectableText(
            subTitle??"",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ),
      ],
    );
  }


}
