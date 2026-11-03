
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../../common/manage_zhendu_widgets.dart';
import '../controllers/manage_script_grouping_controller.dart';
import '../models/manage_script_grouping_model.dart';

class ManageScriptGroupingInfoWidget extends StatelessWidget {
  final ManageScriptGroupingController controller;
  const ManageScriptGroupingInfoWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Obx((){
        if(controller.listData.isEmpty) {
          return const NotDataWidget(
            message: "暂无数据",
          );
        }
        if(controller.currentIndex.value >= controller.listData.length) {
          return Container();
        }
        ManageScriptGroupingModel data = controller.listData[controller.currentIndex.value];

        return Column(
          children: [
            _buildTitleWidget(context, data),
            SizedBox(height: 12.wMin),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 12.wMin),
                child: Column(
                  children: [
                    _buildFromWidget(data),
                    Container(
                      height: 1.wMin,
                      color: AppTheme.cBorderPrimary.color,
                      margin: EdgeInsets.symmetric(vertical: 32.wMin),
                    ),
                  ],
                ),
              ),
            ),

            _buildButtonsWidget(context, data),
          ],
        );
      }),
    );
  }

  Widget _buildTitleWidget(BuildContext context, ManageScriptGroupingModel data) {
    bool isEditing = controller.isEditing.value;
    return Row(
      children: [
        Text(
          "分组编辑",
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SizedBox(width: 12.wMin),
        Visibility(
          visible: data.data?.uid == null,
          child: ManageTagFS16Widget(
            tag: "新增未保存",
            bgColor: AppTheme.cFeedbackErrorBackground.color,
            fontColor: AppTheme.cFeedbackErrorText.color,
          ),
        ),
        const Spacer(),
        Visibility(
          visible: isEditing,
          replacement: ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.dramaScriptGroupEdit],
            child: ButtonWidget(
              text: "编辑",
              padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
              borderRadius: 6.wMin,
              color: AppTheme.cSurfaceTertiary.color,
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
              fontColor: AppTheme.cTextPrimary.color,
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
              sclae: 1.03,
              onTap: () {
                controller.startEdit();
              },
            ),
          ),
          child: Row(
            children: [
              ManageAuthBoxWidget(
                authCodes: const [ManageAuthCode.dramaScriptGroupDelete],
                isCancel: data.data?.uid == null,
                child: ButtonWidget(
                  text: "删除",
                  padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
                  borderRadius: 6.wMin,
                  color: AppTheme.cFeedbackErrorBackground.color,
                  border: Border.all(width: 1.wMin, color: AppTheme.cFeedbackErrorBorder.color),
                  fontColor: AppTheme.cFeedbackErrorText.color,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                  sclae: 1.03,
                  onTap: () {
                    controller.deleteGroup(context);
                  },
                ),
              ),
              SizedBox(width: 8.wMin),
              ButtonWidget(
                text: "取消编辑",
                padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 4.wMin),
                borderRadius: 6.wMin,
                color: AppTheme.cSurfaceTertiary.color,
                border: Border.all(width: 1.wMin, color: AppTheme.cBorderSecondary.color),
                fontColor: AppTheme.cTextPrimary.color,
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                sclae: 1.03,
                onTap: () {
                  controller.cancelEdit(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFromWidget(ManageScriptGroupingModel data) {
    bool isEditing = controller.isEditing.value;
    return Column(
      spacing: 24.wMin,
      children: [
        Row(
          spacing: 24.wMin,
          children: [
            Expanded(
                child: ManageZhenduInputWidget(
                  title: "uid",
                  hintText: "uid",
                  controller: data.uidInput,
                  readOnly: true,
                ),
              ),
              Expanded(
                child: ManageZhenduNumberInputWidget(
                  title: "order",
                  hintText: "order",
                  controller: data.orderInput,
                  isInt: true,
                  readOnly: !isEditing,
                  onChanged: (value) {
                    controller.listData.refresh();
                  },
                ),
              ),
          ],
        ),
        Row(
          spacing: 24.wMin,
          children: [
            Expanded(
              child: ManageZhenduInputWidget(
                title: "中文名称",
                hintText: "中文名称",
                controller: data.zhNameInput,
                readOnly: !isEditing,
                onChanged: (value) {
                  controller.listData.refresh();
                },
              ),
            ),
            Expanded(
              child: ManageZhenduInputWidget(
                title: "英文名称",
                hintText: "英文名称",
                controller: data.enNameInput,
                readOnly: !isEditing,
              ),
            ),
          ],
        ),
        ManageZhenduInputWidget(
          title: "category",
          hintText: "category",
          controller: data.categoryInput,
          readOnly: !isEditing,
          onChanged: (value) {
            controller.listData.refresh();
          },
        ),
        Row(
          spacing: 24.wMin,
          children: [
            Expanded(
              child: ManageZhenduInputHeightWidget(
                title: "中文描述",
                hintText: "中文描述",
                controller: data.zhDescInput,
                height: 200.wMin,
                maxLines: 10,
                readOnly: !isEditing,
                fillColor: !isEditing ? Colors.transparent : AppTheme.cSurfaceTertiary,
                borderColor: AppTheme.cBorderSecondary,
                onChanged: (value) {
                  controller.listData.refresh();
                },
              ),
            ),
            Expanded(
              child: ManageZhenduInputHeightWidget(
                title: "英文描述",
                hintText: "英文描述",
                controller: data.enDescInput,
                height: 200.wMin,
                maxLines: 10,
                readOnly: !isEditing,
                fillColor: !isEditing ? Colors.transparent : AppTheme.cSurfaceTertiary,
                borderColor: AppTheme.cBorderSecondary,
              ),
            ),
          ],
        ),
        
      ],
    );
  }



  Widget _buildButtonsWidget(BuildContext context, ManageScriptGroupingModel data){
    bool isEditing = controller.isEditing.value;
    bool enabled = data.data?.enabled ?? false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [

        Visibility(
          visible: isEditing,
          child: ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.dramaScriptGroupEdit],
            margin: EdgeInsets.only(left: 8.wMin),
            child: Row(
              spacing: 8.wMin,
              children: [
                Visibility(
                  visible: data.data?.uid != null,
                  child: ButtonWidget(
                    text: enabled ? "已启用" : "已停用",
                    padding: EdgeInsets.only(left: 8.wMin, right: 12.wMin),
                    height: 38.wMin,
                    color: enabled ? AppTheme.cFeedbackSuccessBackground.color : AppTheme.cFeedbackErrorBackground.color,
                    borderRadius: 8.wMin,
                    fontColor: enabled ? AppTheme.cFeedbackSuccessText.color : AppTheme.cFeedbackErrorText.color,
                    fontSize: 18.wMin,
                    leftIcon: Container(
                      margin: EdgeInsets.only(right: 4.wMin),
                      child: SvgPicture.asset(
                        enabled ? "assets/svg/public/icon_enable.svg" : "assets/svg/public/icon_prohibit.svg",
                        height: 24.wMin,
                        colorFilter: ColorFilter.mode(
                          enabled ? AppTheme.cFeedbackSuccessText.color : AppTheme.cFeedbackErrorText.color,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    sclae: 1.03,
                    onTap: () {
                      controller.editEnabled(context);
                    },
                  ),
                ),
                ButtonWidget(
                  text: "保存",
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                  height: 38.wMin,
                  color: AppTheme.cTextPrimary.color,
                  borderRadius: 8.wMin,
                  fontColor: AppTheme.cBgPrimary.color,
                  fontSize: 18.wMin,
                  sclae: 1.03,
                  onTap: () {
                    controller.editGroup(context);
                  },
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }

}
