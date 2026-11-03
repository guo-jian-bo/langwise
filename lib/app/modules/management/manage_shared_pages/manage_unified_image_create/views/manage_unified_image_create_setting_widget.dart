
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../theme/theme.dart';
import '../../../common/commons.dart';
import '../../../manage_content/manage_zhendu_console/common/manage_zhendu_widgets.dart';
import '../controllers/manage_unified_image_create_controller.dart';
import '../enums/manage_unified_image_create_enums.dart';

class ManageUnifiedImageCreateSettingWidget extends StatelessWidget {
  final ManageUnifiedImageCreateController controller;
  const ManageUnifiedImageCreateSettingWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStyleWidget(),
          SizedBox(height: 24.wMin),
          Container(height: 1.wMin, color: AppTheme.cBorderSecondary.color,),
          SizedBox(height: 24.wMin),
          _buildSettingWidget(context),
          SizedBox(height: 24.wMin),
          Container(height: 1.wMin, color: AppTheme.cBorderSecondary.color,),
          SizedBox(height: 24.wMin),
          const Spacer(),

          _buildButtonWidget(),

        ],
      ),
    );
  }

  Widget _buildStyleWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              "视觉风格",
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
            const Spacer(),
            Obx((){
              return Visibility(
                visible: controller.selectedStyleId.value != -1,
                child: ManageTagFS16Widget(
                  tag: "styleId: ${controller.selectedStyleId.value}",
                  bgColor: AppTheme.cSurfaceTertiary.color,
                  fontColor: AppTheme.cTextSecondary.color,
                ),
              );
            }),
          ],
        ),
        SelectableText(
          "styleId 将由画风与地域组合自动生成",
          style: TextStyle(
            fontSize: 14.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SizedBox(height: 16.wMin),

        Obx((){
          return Row(
            spacing: 8.wMin,
            children: [
              Expanded(
                child: ManageZhenduDropdownWidget(
                  title: "画风",
                  hintText: "请选择画风",
                  selectValue: controller.selectedStyleKey.value,
                  items: List.generate(controller.styleKeyList.length, (index){
                    return IconDropdownCheckData<String>(
                      title: controller.styleKeyList[index],
                      value: controller.styleKeyList[index],
                    );
                  }),
                  onChanged: (choiceData, index) {
                    controller.switchStyle(choiceData.value);
                  },
                ),
              ),
              Expanded(
                child: ManageZhenduDropdownWidget(
                  title: "地区风貌",
                  hintText: "请选择地区风貌",
                  selectValue: controller.selectedStyleAreaCode.value,
                  items: List.generate(controller.styleAreaList.length, (index){
                    return IconDropdownCheckData<String>(
                      title: controller.styleAreaList.toList()[index].localeTitle??"",
                      value: controller.styleAreaList.toList()[index].locale??"",
                    );
                  }),
                  onChanged: (choiceData, index) {
                    controller.switchArea(choiceData.value);
                  },
                ),
              ),
            ],
          );
        }),

      ],
    );
  }

  Widget _buildSettingWidget(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          "生成设置",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cTextPrimary.color,
          ),
        ),
        SelectableText(
          "模型、尺寸、数量统一在这里调整",
          style: TextStyle(
            fontSize: 14.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextTertiary.color,
          ),
        ),

        SizedBox(height: 16.wMin),

        _buildSettingModuleWidget(),

        SizedBox(height: 16.wMin),

        _buildSettingSizeWidget(context),

        SizedBox(height: 16.wMin),

        _buildSettingCountWidget(),

      ],
    );
  }


  /// 模型模式
  Widget _buildSettingModuleWidget(){
    return Column(
      spacing: 8.wMin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SelectableText(
              "模型模式",
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
            const Spacer(),

            Visibility(
              visible: controller.sceneType == SceneStoryboardTypeEnum.storyboard_sheet,
              child: ManageTagFS16Widget(
                tag: "分镜图强制 ${ModeModuleEnum.pro.name}",
                bgColor: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
                fontColor: AppTheme.cSurfaceWarning.color,
              ),
            ),
          ],
        ),
        Obx((){
          bool selectAuto = controller.modeModule.value == ModeModuleEnum.auto;
          bool selectPro = controller.modeModule.value == ModeModuleEnum.pro;
          return Row(
            spacing: 12.wMin,
            children: [
              Expanded(
                child: IgnorePointer(
                  ignoring: controller.sceneType == SceneStoryboardTypeEnum.storyboard_sheet,
                  child: Opacity(
                    opacity: controller.sceneType == SceneStoryboardTypeEnum.storyboard_sheet ? 0.6 : 1,
                    child: ButtonWidget(
                      text: ModeModuleEnum.auto.name,
                      height: 42.wMin,
                      borderRadius: 6.wMin,
                      color: selectAuto ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceLayerElevated.color,
                      border: Border.all(
                        width: 1.wMin,
                        color: selectAuto ? AppTheme.cSurfaceSuccess.color : AppTheme.cBorderDefault.color,
                      ),
                      fontSize: 18.wMin,
                      fontWeight: FontWeight.w500,
                      fontColor: selectAuto ? Colors.white : AppTheme.cTextPrimary.color,
                      sclae: 1.03,
                      onTap: () {
                        controller.switchModeModule(ModeModuleEnum.auto);
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ButtonWidget(
                  text: ModeModuleEnum.pro.name,
                  height: 42.wMin,
                  borderRadius: 6.wMin,
                  color: selectPro ? AppTheme.cFeedbackWarningText.color : AppTheme.cSurfaceLayerElevated.color,
                  border: Border.all(
                    width: 1.wMin,
                    color: selectPro ? AppTheme.cFeedbackWarningText.color : AppTheme.cBorderDefault.color,
                  ),
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                  fontColor: selectPro ? Colors.white : AppTheme.cTextPrimary.color,
                  sclae: 1.03,
                  onTap: () {
                    controller.switchModeModule(ModeModuleEnum.pro);
                  },
                ),
              ),
            ],
          );
        }),

      ],
    );
  }

  /// 尺寸
  Widget _buildSettingSizeWidget(BuildContext context){
    return Obx((){
      String ratio = controller.aspectRatio.value.name;
      String quality = controller.quality.value.name;
      Size size = controller.imageOrgSize.value;
      String sizeText = "${size.width.toInt()}x${size.height.toInt()}";
      String showText = "$ratio · $quality · $sizeText";

      if(controller.imageOrgSize.value != Size.zero){
        showText = "${controller.imageOrgSize.value.width.toInt()}x${controller.imageOrgSize.value.height.toInt()}";
      }

      return Builder(
        builder: (context) {
          return ManageZhenduSelectWidget(
            title: "尺寸 (${controller.isLockSize.value ? "已锁定" : ""})",
            hintText: "请选择尺寸",
            readOnly: controller.isLockSize.value,
            value: showText,
            onTap: () {
              controller.selectSize(context);
            },
          );
        },
      );
    });
  }

  /// 数量
  Widget _buildSettingCountWidget(){
    return Column(
      spacing: 8.wMin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          "数量",
          style: TextStyle(
            fontSize: 18.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextSecondary.color,
          ),
        ),
        Row(
          spacing: 12.wMin,
          children: List.generate(4, (index){
            return Expanded(
              child: Obx((){
                bool generateCount = controller.generateCount.value == index + 1;
                return TapScaleWidget(
                  onTap: () {
                    controller.generateCount.value = index + 1;
                  },
                  sclae: 1.01,
                  child: ButtonWidget(
                    text: "${index + 1}",
                    height: 42.wMin,
                    borderRadius: 6.wMin,
                    color: generateCount ? AppTheme.cSurfaceBrand.color : AppTheme.cSurfaceLayerElevated.color,
                    border: Border.all(
                      width: 1.wMin,
                      color: generateCount ? AppTheme.cSurfaceBrand.color : AppTheme.cBorderDefault.color,
                    ),
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w500,
                    fontColor: generateCount ? Colors.white : AppTheme.cTextPrimary.color,
                    sclae: 1.03,
                    onTap: () {
                      controller.generateCount.value = index + 1;
                    },
                  ),
                );
              })
            );
          }),
        ),
      ],
    );
  }

  Widget _buildButtonWidget(){
    return ButtonWidget(
      text: "开始生成",
      height: 48.wMin,
      borderRadius: 8.wMin,
      color: AppTheme.cSurfaceBrand.color,
      fontSize: 18.wMin,
      fontWeight: FontWeight.w500,
      fontColor: Colors.white,
      sclae: 1.01,
      onTap: () {
        controller.startGenerateImage();
      },
    );
  }


}