
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../theme/theme.dart';
import '../../../../common/commons.dart';
import '../../common/manage_zhendu_widgets.dart';
import '../../../../utils/utils.dart';
import '../controllers/manage_script_genre_controller.dart';
import '../models/manage_script_genre_model.dart';

class ManageScriptGenreInfoWidget extends StatelessWidget {
  final ManageScriptGenreController controller;
  const ManageScriptGenreInfoWidget({super.key, required this.controller});

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
        ManageScriptGenreModel data = controller.listData[controller.currentIndex.value];

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

  Widget _buildTitleWidget(BuildContext context, ManageScriptGenreModel data) {
    bool isEditing = controller.isEditing.value;
    return Row(
      children: [
        Text(
          "题材编辑",
          style: TextStyle(
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SizedBox(width: 12.wMin),
        Visibility(
          visible: data.data?.nid == null,
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
            authCodes: const [ManageAuthCode.dramaScriptGenreEdit],
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
              Visibility(
                visible: data.data?.nid == null,
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
                    controller.deleteGenre(context);
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


  Widget _buildFromWidget(ManageScriptGenreModel data) {
    bool isEditing = controller.isEditing.value;
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
                    readOnly: true,
                    onChanged: (value) {
                      controller.listData.refresh();
                    },
                  ),
                  ManageZhenduInputWidget(
                    title: "中文名称",
                    hintText: "中文名称",
                    controller: data.zhNameInput,
                    readOnly: !isEditing,
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
                    readOnly: !isEditing,
                    fillColor: !isEditing ? Colors.transparent : AppTheme.cSurfaceTertiary,
                    borderColor: AppTheme.cBorderSecondary,
                    onChanged: (value) {
                      controller.listData.refresh();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                spacing: 24.wMin,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 16.wMin,
                    children: [
                      Expanded(
                        child: ManageZhenduNumberInputWidget(
                          title: "difficulty.min",
                          hintText: "difficulty.min",
                          minValue: 0,
                          maxValue: 6,
                          isInt: true,
                          controller: data.difficultyMinInput,
                          readOnly: !isEditing,
                          onChanged: (value) {
                            controller.listData.refresh();
                          },
                        ),
                      ),
                      Expanded(
                        child: ManageZhenduNumberInputWidget(
                          title: "difficulty.min",
                          hintText: "difficulty.min",
                          minValue: 0,
                          maxValue: 6,
                          isInt: true,
                          controller: data.difficultyMaxInput,
                          readOnly: !isEditing,
                          onChanged: (value) {
                            controller.listData.refresh();
                          },
                        ),
                      ),

                    ],
                  ),
                  ManageZhenduInputWidget(
                    title: "英文名称",
                    hintText: "英文名称",
                    controller: data.enNameInput,
                    readOnly: !isEditing,
                  ),
                  ManageZhenduInputHeightWidget(
                    title: "英文描述",
                    hintText: "英文描述",
                    controller: data.enDescInput,
                    height: 120.wMin,
                    maxLines: 5,
                    readOnly: !isEditing,
                    fillColor: !isEditing ? Colors.transparent : AppTheme.cSurfaceTertiary,
                    borderColor: AppTheme.cBorderSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
        ManageZhenduInputHeightWidget(
          title: "description_for_prompt",
          hintText: "description_for_prompt",
          height: 120.wMin,
          maxLines: 5,
          controller: data.descriptionForPromptInput,
          readOnly: !isEditing,
          fillColor: !isEditing ? Colors.transparent : AppTheme.cSurfaceTertiary,
          borderColor: AppTheme.cBorderSecondary,
        ),
        ManageZhenduInputHeightWidget(
          title: "audio_characteristics",
          hintText: "audio_characteristics",
          height: 120.wMin,
          maxLines: 5,
          controller: data.audioCharacteristicsInput,
          readOnly: !isEditing,
          fillColor: !isEditing ? Colors.transparent : AppTheme.cSurfaceTertiary,
          borderColor: AppTheme.cBorderSecondary,
        ),
      ],
    );
  }



  Widget _buildButtonsWidget(BuildContext context, ManageScriptGenreModel data){
    bool isEditing = controller.isEditing.value;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [

        Visibility(
          visible: isEditing,
          child: ManageAuthBoxWidget(
            authCodes: const [ManageAuthCode.dramaScriptGenreEdit],
            margin: EdgeInsets.only(left: 8.wMin),
            child: Row(
              spacing: 8.wMin,
              children: [
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
                    controller.editGenre(context);
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
