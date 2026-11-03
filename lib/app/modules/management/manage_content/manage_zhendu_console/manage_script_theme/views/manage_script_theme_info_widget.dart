
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../common/commons.dart';
import '../../../../utils/utils.dart';
import '../../common/manage_zhendu_widgets.dart';
import '../controllers/manage_script_theme_controller.dart';
import '../models/manage_script_theme_model.dart';

class ManageScriptThemeInfoWidget extends StatelessWidget {
  final ManageScriptThemeController controller;
  const ManageScriptThemeInfoWidget({super.key, required this.controller});

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
        ManageScriptThemeModel data = controller.listData[controller.currentIndex.value];

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

  Widget _buildTitleWidget(BuildContext context, ManageScriptThemeModel data) {
    return Row(
      children: [
        Text(
          "主题编辑",
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        const Spacer(),
        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaScriptThemeDelete],
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
              controller.deleteTheme(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFromWidget(ManageScriptThemeModel data) {
    return Column(
      spacing: 24.wMin,
      children: [
        Row(
          spacing: 24.wMin,
          children: [
            Expanded(
              child: Column(
                spacing: 24.wMin,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ManageZhenduInputWidget(
                    title: "nid",
                    hintText: "nid",
                    controller: data.nidInput,
                    onChanged: (value) {
                      controller.listData.refresh();
                    },
                  ),
                  ManageZhenduInputWidget(
                    title: "中文名称",
                    hintText: "中文名称",
                    controller: data.zhNameInput,
                    onChanged: (value) {
                      controller.listData.refresh();
                    },
                  ),
                  ManageZhenduInputHeightWidget(
                    title: "中文描述",
                    hintText: "中文描述",
                    controller: data.zhDescInput,
                    height: 120.wMin,
                    maxLines: 5,
                    onChanged: (value) {
                      controller.listData.refresh();
                    },
                  ),
                  ManageZhenduNumberInputWidget(
                    title: "difficulty.min",
                    hintText: "difficulty.min",
                    minValue: 0,
                    maxValue: 6,
                    controller: data.difficultyMinInput,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                spacing: 24.wMin,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ManageZhenduInputWidget(
                    title: "category",
                    hintText: "category",
                    controller: data.categoryInput,
                    onChanged: (value) {
                      controller.listData.refresh();
                    },
                  ),
                  ManageZhenduInputWidget(
                    title: "英文名称",
                    hintText: "英文名称",
                    controller: data.enNameInput,
                  ),
                  ManageZhenduInputHeightWidget(
                    title: "英文描述",
                    hintText: "英文描述",
                    controller: data.enDescInput,
                    height: 120.wMin,
                    maxLines: 5,
                  ),
                  ManageZhenduNumberInputWidget(
                    title: "difficulty.max",
                    hintText: "difficulty.max",
                    minValue: 0,
                    maxValue: 6,
                    controller: data.difficultyMaxInput,
                  ),
                ],
              ),
            ),
          ],
        ),
        ManageZhenduInputWidget(
          title: "suggested_personas",
          hintText: "以英文逗号分隔",
          controller: data.suggestedPersonasInput,
        ),
      ],
    );
  }

  Widget _buildButtonsWidget(BuildContext context, ManageScriptThemeModel data){
    bool enabled = data.data?.enabled ?? false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [

        ManageAuthBoxWidget(
          authCodes: const [ManageAuthCode.dramaScriptThemeEdit],
          margin: EdgeInsets.only(left: 8.wMin),
          child: Row(
            spacing: 8.wMin,
            children: [
              ButtonWidget(
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
                  controller.editTheme(context);
                },
              ),
            ],
          ),
        ),

      ],
    );
  }



}