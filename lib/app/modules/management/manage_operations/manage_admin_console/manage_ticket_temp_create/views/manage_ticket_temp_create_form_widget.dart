
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../enums/enums.dart';
import '../controllers/manage_ticket_temp_create_controller.dart';
import '../models/manage_ticket_form_model.dart';

class ManageTicketTempCreateFormWidget extends StatelessWidget {
  final ManageTicketTempCreateController controller;
  const ManageTicketTempCreateFormWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          spacing: 24.wMin,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 312.wMin,
              child: SingleChildScrollView(
                primary: false,
                child: _buildFromTypesWidget(),
              ),
            ),
            Expanded(
              child: ManageTicketTempCreateFormListWidget(controller: controller),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFromTypesWidget(){
    return Container(
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
          Text(
            "添加表单项",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
          Text(
            "点击类型即可追加一个表单项。",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
          SizedBox(height: 16.wMin),
          _buildFromTypesListWidget("基础", controller.baseFormTypes),
          SizedBox(height: 16.wMin),
          _buildFromTypesListWidget("选择", controller.selectedFormType),
          SizedBox(height: 16.wMin),
          _buildFromTypesListWidget("时间", controller.timeFormType),
          SizedBox(height: 16.wMin),
          _buildFromTypesListWidget("附件", controller.attachmentFormType),
          SizedBox(height: 16.wMin),
          _buildFromTypesListWidget("业务", controller.businessFormType),
        ],
      ),
    );
  }

  Widget _buildFromTypesListWidget(String title, List<TicketFormTypeEnum> types){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
        SizedBox(height: 12.wMin),
        Wrap(
          spacing: 12.wMin,
          runSpacing: 12.wMin,
          children: List.generate(types.length, (index){
            return TapScaleWidget(
              onTap: () {
                controller.addFormModel(types[index]);
              },
              sclae: 1.05,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 12.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.wMin),
                  color: AppTheme.cSurfaceLayerBase2.color,
                  border: Border.all(
                    color: AppTheme.cBorderThin.color,
                    width: 1.wMin,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      types[index].iconPath,
                      width: 16.wMin,
                    ),
                    SizedBox(width: 8.wMin),
                    Text(
                      types[index].name,
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

}


class ManageTicketTempCreateFormListWidget extends StatelessWidget {
  final ManageTicketTempCreateController controller;
  const ManageTicketTempCreateFormListWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(bottom: 100.wMin),
      children: [
        Obx((){
          return Text(
            "表单项（${controller.formList.length}）",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          );
        }),
        Text(
          "拖动顺序用上下按钮调整；选择类字段可编辑选项。",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
        SizedBox(height: 16.wMin),
        Obx((){
          if(controller.formList.isEmpty) return _buildNotWidget();
          return Column(
            spacing: 16.wMin,
            children: List.generate(controller.formList.length, (index){
              return _buildItemWidget(controller.formList[index], index);
            }),
          );
        }),
      ],
    );
  }

  Widget _buildNotWidget(){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
      ),
      height: 560.wMin,
      child: Center(
        child: Text(
          "还没有表单项，从左侧「添加表单项」面板点选类型开始搭建。",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),
      ),
    );
  }


  Widget _buildItemWidget(ManageTicketFormModel item, int index){
    return Container(
      key: item.key,
      padding: EdgeInsets.all(24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          width: 1.wMin,
          color: AppTheme.cBorderNone.color,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.center,
            width: 60.wMin,
            child: Text(
              "#${index + 1}",
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildItemTitleWidget(item, index),
                SizedBox(height: 12.wMin),
                _buildItemFromsWidget(item),
                _buildItemFromsOptionsWidget(item),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTitleWidget(ManageTicketFormModel item, int index){
    bool isFirst = index == 0;
    bool isLast = index == controller.formList.length - 1;

    return Row(
      children: [
        Container(
          width: 26.wMin,
          height: 26.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.wMin),
            color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
          ),
          child: SvgPicture.asset(
            item.formType.iconPath,
            width: 16.wMin,
          ),
        ),
        SizedBox(width: 6.wMin),
        Text(
          item.formType.name,
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        const Spacer(),
        CardSwitchWidget(
          value: item.isRequired,
          onChanged: (value){
            controller.toggleIsRequired(item);
          },
        ),
        SizedBox(width: 4.wMin),
        Text(
          item.isRequired ? "必填" : "选填",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SizedBox(width: 16.wMin),
        TapScaleWidget(
          onTap: isFirst ? null : () {
            controller.moveUpFormModel(index);
          },
          sclae: 1.05,
          child: Container(
            width: 34.wMin,
            height: 34.wMin,
            alignment: Alignment.center,
            color: Colors.transparent,
            child: Icon(
              Icons.arrow_upward_rounded,
              size: 26.wMin,
              color: AppTheme.cTextPrimary.color.withValues(alpha: isFirst ? 0.6 : 1),
            ),
          ),
        ),
        SizedBox(width: 10.wMin),
        TapScaleWidget(
          onTap: isLast ? null : () {
            controller.moveDownFormModel(index);
          },
          sclae: 1.05,
          child: Container(
            width: 34.wMin,
            height: 34.wMin,
            alignment: Alignment.center,
            color: Colors.transparent,
            child: Icon(
              Icons.arrow_downward_rounded,
              size: 26.wMin,
              color: AppTheme.cTextPrimary.color.withValues(alpha: isLast ? 0.6 : 1),
            ),
          ),
        ),
        SizedBox(width: 10.wMin),
        TapScaleWidget(
          onTap: () {
            controller.deleteFormModel(index);
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
    );
  }

  Widget _buildItemFromsWidget(ManageTicketFormModel item){
    return Row(
      spacing: 16.wMin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildInputWidget(
            title: "表单项标题",
            hintText: "标题",
            controller: item.titleController,
          ),
        ),
        Expanded(
          child: _buildInputWidget(
            title: "提示文案",
            isRequired: false,
            hintText: "提示文案",
            controller: item.hintController,
          ),
        ),
      ],
    );
  }

  Widget _buildItemFromsOptionsWidget(ManageTicketFormModel item){
    if(!item.formType.hasOptions) return Container();
    if(item.optionInputs == null) return Container();
    List<TextEditingController> optionInputs = item.optionInputs??[];
    return Column(
      children: [
        SizedBox(height: 16.wMin),
        Row(
          children: [
            Text(
              "选项",
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
            const Spacer(),
            Visibility(
              visible: item.addOptions,
              child: ButtonWidget(
                text: "添加选项",
                height: 36.wMin,
                padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                border: Border.all(
                  color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
                  width: 1.wMin,
                ),
                fontColor: AppTheme.cSurfaceBrand.color,
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                sclae: 1.05,
                onTap: () {
                  controller.addOption(item);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 8.wMin),
        Visibility(
          visible: optionInputs.isEmpty,
          child: Text(
            "还没有选项，点击「添加选项」。",
            style: TextStyle(
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextTertiary.color,
            ),
          ),
        ),
        Column(
          spacing: 8.wMin,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(optionInputs.length, (index){
            return _buildItemFromsOptionsItemWidget(item, optionInputs[index], index);
          }),
        ),
      ],
    );
  }

  Widget _buildItemFromsOptionsItemWidget(ManageTicketFormModel item, TextEditingController input, int index){
    return Row(
      children: [
        SizedBox(
          width: 35.wMin,
          child: Text(
            "${index+1}",
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
        ),
        Expanded(
          child: CardInputWidget(
            hintText: "输入选项内容",
            controller: input,
            height: 72.wMin,
            maxLines: 1,
            readOnly: !item.updateOptions,
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
          ),
        ),
        Visibility(
          visible: item.deleteOptions,
          child: TapScaleWidget(
            onTap: () {
              controller.deleteOption(item, index);
            },
            sclae: 1.03,
            child: Container(
              width: 70.wMin,
              height: 72.wMin,
              alignment: Alignment.center,
              color: Colors.transparent,
              child: SvgPicture.asset(
                "assets/svg/public/x.svg",
                width: 24.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
              ),
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
