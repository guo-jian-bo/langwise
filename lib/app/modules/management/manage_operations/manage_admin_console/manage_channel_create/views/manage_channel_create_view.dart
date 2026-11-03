import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../../../routes/routes.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../bindings/manage_channel_create_binding.dart';
import '../controllers/manage_channel_create_controller.dart';
import '../models/manage_sub_channel_model.dart';

class ManageChannelCreateView extends GetView<ManageChannelCreateController> {
  final String tagText;
  const ManageChannelCreateView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '${Routes.MANAGE_CHANNEL_CREATE}_${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ManageChannelCreateView(tagText: tag),
      binding: ManageChannelCreateBinding(tag: tag),
      routeName: Routes.MANAGE_CHANNEL_CREATE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if(didPop) return;
        controller.onBackPage(context);
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ManageScaffold(
          onBack: () async {
            await controller.onBackPage(context);
            return false;
          },
          showCollectButton: false,
          body: CustomScrollView(
            controller: controller.scrollController,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 70.wMin),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildTitleWidget(),
                    SizedBox(height: 24.wMin),
                    _buildBasicInfoWidget(),
                    SizedBox(height: 16.wMin),
                  ]),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 70.wMin),
                sliver: _buildSubChannelListWidget(context),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 100.wMin),
              ),
            ],
          ),
          bottomNavigationBar: _buildButtonsWidget(context),
        ),
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
            visible: controller.channelUid != null,
            child: ManageAuthBoxWidget(
              authCodes: [ManageAuthCode.channelRemove],
              child: ButtonWidget(
                text: "删除一级渠道",
                height: 54.wMin,
                padding: EdgeInsets.symmetric(horizontal: 32.wMin),
                borderRadius: 99,
                color: AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
                fontColor: AppTheme.cSurfaceError.color,
                fontWeight: FontWeight.w500,
                fontSize: 24.wMin,
                sclae: 1.03,
                onTap: () {
                  controller.deleteChannel(context);
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
              controller.onBackPage(context);
            },
          ),
          SizedBox(width: 24.wMin),
          ButtonWidget(
            text: controller.channelUid == null ? "创建渠道" : "保存编辑",
            height: 54.wMin,
            padding: EdgeInsets.symmetric(horizontal: 32.wMin),
            borderRadius: 99,
            color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
            fontColor: AppTheme.cSurfaceBrand.color,
            fontWeight: FontWeight.w500,
            fontSize: 24.wMin,
            sclae: 1.03,
            onTap: () {
              if(controller.channelUid != null){
                controller.editChannel();
              }else{
                controller.createChannel();
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
                "${controller.channelUid == null ? '新建' : '编辑'}一级渠道",
                style: TextStyle(
                  fontSize: 32.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              Text(
                "编辑一级渠道信息，并在下方增删 / 编辑二级渠道。二级渠道的唯一 ID 会被学员卡与员工权限引用。",
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

  /// 一级渠道信息
  Widget _buildBasicInfoWidget(){
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
              _buildBodyTitleWidget(title: "一级渠道信息", subTitle: "渠道大类，例如 官方 / 代理商 / 校园。"),
              const Spacer(),
              Obx((){
                return Row(
                  children: [
                    CardSwitchWidget(
                      width: 52.wMin,
                      height: 26.wMin,
                      value: controller.isEnable.value,
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
            spacing: 16.wMin,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInputWidget(
                  title: "一级渠道名称",
                  hintText: "例如：官方",
                  controller: controller.channelNameController,
                  maxLength: 50,
                  maxLines: 1,
                  onChanged: (value) {
                    controller.subChannelList.refresh();
                  },
                ),
              ),
              Expanded(
                child: _buildInputWidget(
                  title: "一级渠道code",
                  hintText: "code",
                  controller: controller.channelCodeController,
                  maxLength: 50,
                  maxLines: 1,
                ),
              ),
              Expanded(
                child: _buildInputWidget(
                  title: "唯一ID",
                  hintText: "创建后由后端分配",
                  controller: controller.uniqueIdController,
                  readOnly: true,
                  isRequired: false,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.wMin),
          _buildInputWidget(
            title: "描述",
            hintText: "这个工单用来收集什么信息",
            controller: controller.descriptionController,
            isRequired: false,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  /// 二级渠道信息
  Widget _buildSubChannelListWidget(BuildContext context){
    return SliverStickyHeader.builder(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
          decoration: BoxDecoration(
            color: !state.isPinned ? AppTheme.cSurfaceLayerBase.color : AppTheme.cSurfaceSecondary.color,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.wMin)),
            boxShadow: !state.isPinned ? null : [
              BoxShadow(
                color: AppTheme.cSurfacePrimary.color,
                blurRadius: 4.wMin,
                offset: Offset(0, 2.wMin),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildBodyTitleWidget(title: "二级渠道信息", subTitle: "具体来源，例如社群/王五。学员通过二级渠道ID 关联，展示为「一级 · 二级」。"),
              ),
              ButtonWidget(
                text: "添加二级渠道",
                height: 36.wMin,
                padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                border: Border.all(
                  color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                  width: 1.wMin,
                ),
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                fontColor: AppTheme.cSurfaceBrand.color,
                sclae: 1.05,
                onTap: () {
                  controller.addSubChannel();
                },
              ),
            ],
          ),
        );
      },
      sliver: SliverToBoxAdapter(
        child: Obx((){
          if(controller.subChannelList.isEmpty){
            return _buildSubChannelNotDataWidget();
          }
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 24.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceLayerBase.color,
            ),
            child: Column(
              spacing: 16.wMin,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(controller.subChannelList.length, (index){
                return _buildSubChannelListItemWidget(context, controller.subChannelList[index], index);
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSubChannelNotDataWidget(){
    return Container(
      width: double.infinity,
      height: 200.wMin,
      alignment: Alignment.center,
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          color: AppTheme.cBorderNone.color,
          width: 1.wMin,
        ),
      ),
      child: Text(
        "还没有二级渠道，点击右上角「添加二级渠道」。",
        style: TextStyle(
          fontSize: 18.wMin,
          fontWeight: FontWeight.w500,
          color: AppTheme.cTextSecondary.color,
        ),
      ),
    );
  }

  Widget _buildSubChannelListItemWidget(BuildContext context, ManageSubChannelModel model, int index){
    String ownerName = "";
    if(model.ownerId != null){
      ownerName = model.ownerName??"";
      if(ownerName.isNotEmpty) ownerName += " ";
      ownerName += "(${model.ownerId??''})";
    }

    return Container(
      key: model.key,
      padding: EdgeInsets.all(16.wMin),
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
              _buildListItemTagWidget(
                text: "一级·${controller.channelNameController.text.isEmpty ? "未命名" : controller.channelNameController.text}",
                bgColor: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                borderColor: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                fontColor: AppTheme.cSurfaceWarning.color,
              ),
              SizedBox(width: 6.wMin),
              _buildListItemTagWidget(
                text: model.child == null ? "id创建后分配" : "uid:${model.child?.uid??''}",
                bgColor: AppTheme.cSurfaceTertiary.color,
                borderColor: AppTheme.cBorderSecondary.color,
                fontColor: AppTheme.cTextSecondary.color,
              ),
              const Spacer(),
              CardSwitchWidget(
                width: 52.wMin,
                height: 26.wMin,
                value: model.isEnable,
                onChanged: (value){
                  controller.toggleSubChannelEnable(model);
                },
              ),
              SizedBox(width: 4.wMin),
              Text(
                model.isEnable ? "启用" : "停用",
                style: TextStyle(
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary.color,
                ),
              ),
              SizedBox(width: 10.wMin),
              TapScaleWidget(
                onTap: () {
                  controller.removeSubChannel(index);
                },
                sclae: 1.05,
                child: Container(
                  width: 34.wMin,
                  height: 34.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.wMin),
                    color: AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
                  ),
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_delete.svg",
                    width: 24.wMin,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.wMin),
          Row(
            spacing: 16.wMin,
            children: [
              Expanded(
                child: _buildInputWidget(
                  title: "二级渠道名称",
                  controller: model.subChannelNameController,
                  hintText: "例如：社群",
                  maxLines: 1,
                ),
              ),
              Expanded(
                child: _buildInputWidget(
                  title: "二级渠道code",
                  controller: model.subChannelCodeController,
                  hintText: "code",
                  maxLines: 1,
                ),
              ),
              Expanded(
                child: _buildTapWidget(
                  title: "负责人",
                  hintText: "联系人",
                  value: ownerName,
                  isRequired: false,
                  onTap: () {
                    controller.selectResponsiblePerson(context, model);
                  },
                ),
              ),
              Expanded(
                child: _buildInputWidget(
                  title: "备注",
                  controller: model.remarkController,
                  hintText: "补充说明",
                  isRequired: false,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildListItemTagWidget({
    String? text,
    required Color bgColor,
    required Color borderColor,
    required Color fontColor,
  }){
    if(text == null) return SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin, vertical: 4.wMin),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: borderColor,
          width: 0.8.wMin,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18.wMin,
          fontWeight: FontWeight.w500,
          color: fontColor,
        ),
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
    bool readOnly = false,
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
                readOnly: readOnly,
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


}
